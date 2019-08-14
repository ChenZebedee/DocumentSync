<!-- TOC -->

- [HBase存储架构](#hbase%e5%ad%98%e5%82%a8%e6%9e%b6%e6%9e%84)
  - [Client](#client)
  - [Zookeeper](#zookeeper)
  - [HMaster](#hmaster)
  - [HRegionServer](#hregionserver)
  - [HRegion](#hregion)
    - [HRegion定位：](#hregion%e5%ae%9a%e4%bd%8d)
  - [Store](#store)
  - [StoreFile](#storefile)
  - [HFile](#hfile)

<!-- /TOC -->
# HBase存储架构
HBase 系统架构由 Client、Zookeeper、HMaster、HRegionServer、HRegion、HStore、HLog、HDFS 等部件组成。

![HBase存储结构图](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59oqg68qij30g80990us.jpg)

## Client
1. 使用 HBase RPC 机制（远程）与 HMaster 和 HRegionServer 进行通信
2. Client 与 HMaster 进行通信进行管理类操作
3. Client 与 HRegionServer 进行数据读写类操作

## Zookeeper
1. Zookeeper Quorm 存储 -ROOT- 表地址、HMaster 地址；
2. HRegionServer 把自己以 Ephedral 方式注册到 Zookeeper 中，HMaster 随时感知 HRegionServer 的健康状况。
3. Zookeeper 避免 HMaster 单点问题。

## HMaster
HMaster 没有单点问题，HMaster 中可以启动多个 HMaster,通过 Zookeeper 的 MasterElection 机制保证总有一个 Master 在运行,主要负责 Table 和 Region 的管理工作:
1. 管理用户对表的增删改查操作
2. 管理 HRegionServer 的负载均衡，调整Region分布
3. Region Split 后，负责新 Region 的分布
4. 在 HRegionServer 停机后，负责失效 HRegionServer 上 Region 迁移
   
## HRegionServer
1. client 访问 hbase 上的数据并不需要 master 参与（寻址访问 zookeeper 和 region server，数据读写访问 region server），master 仅仅维护 table 和 region 的元数据信息( table 的元数据信息保存在 zookeeper 上)，负载很低
2. HRegionServer 存取一个子表时，会创建一个 HRegion 对象，然后对表的每个列族创建一个 Store 实例，每个 Store 都会有一个 MemStore 和 0 个或多个 StoreFile 与之对应，每个 StoreFile 都会对应一个 HFile， HFile 就是实际的存储文件。因此，一个 HRegion 有多少个列族就有多少个 Store
3. 一个 HRegionServer 会有多个 HRegion 和一个 HLog

HRegionServer的作用：
* 维护 master 分配给他的 region，处理对这些 region 的 IO 请求。
* 负责切分正在运行过程中变的过大的 region

## HRegion
table 在行的方向上分隔为多个 Region。Region 是 HBase 中分布式存储和负载均衡的最小单元，即不同的 region 可以分别在不同的 Region Server 上，但同一个 Region 是不会拆分到多个 server 上。

Region 按大小分隔，每个表一行是只有一个 region。随着数据不断插入表，region 不断增大，当region 的某个列族达到一个阈值（默认256M）时就会分成两个新的 region。

每个 region 由以下信息标识：
* <表名, startRowkey ,创建时间>
* 由目录表( -ROOT- 和 .META. )可值该 region 的 endRowkey

### HRegion定位：
Region 被分配给哪个 Region Server 是完全动态的，所以需要机制来定位 Region 具体在哪个 region server。

HBase使用三层结构来定位region：
1. 通过 zk 里的文件 /hbase/rs 得到 -ROOT- 表的位置。-ROOT- 表只有一个 region。
2. 通过 -ROOT- 表查找 .META. 表的第一个表中相应的 region 的位置。其实 -ROOT- 表是 .META. 表的第一个 region；.META. 表中的每一个 region 在 -ROOT- 表中都是一行记录。
3. 通过 .META. 表找到所要的用户表 region 的位置。用户表中的每个 region 在 .META. 表中都是一行记录。

![HBase使用三层结构来定位region](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59ouxe2z5j30ah05raag.jpg)

-ROOT- 表永远不会被分隔为多个 region，保证了最多需要三次跳转，就能定位到任意的 region。client 会讲查询的位置信息保存缓存起来，缓存不会主动失效，因此如果 client 上的缓存全部失效，则需要进行 6 次网络来回，才能定位到正确的 region，其中蚕丝用来发现缓存失效，另外三次用来获取位置信息。

## Store
每一个 region 有一个或多个 store 组成，至少是一个 store，hbase 会把一起访问的数据放在一个store 里面，即为每个 ColumnFamily 建一个 store，如果有几个 ColumnFamily，也就有几个 Store。一个 Stor e由一个 memStore 和 0 或者多个 StoreFile 组成。HBase 以 store 的大小来判断是否需要切分 region。

## StoreFile
memStore 内存中的数据写到文件后就是 StoreFile，StoreFile 底层是以 HFile 的格式保存。

## HFile
HBase 中 `KeyValue` 数据的存储格式，是 hadoop 的二进制格式文件。首先 HFile 文件是不定长的，长度固定的只有其中的两块：Trailer 和 FileInfo 。Trailer 中有指针指向其他数据块的起始点，FileInfo 记录了文件的一些 meta 信息。Data Block 是 HBase io 的基本单元，为了提高效率，HRegionServer 中又基于 LRU 的 block cache 机制。每个 Data 块的大小可以在创建一个 Table 的时候通过参数指定（默认块大小64KB），大号的 Block 有利于顺序 Scan，小号的 Block 利于随机查询。每个 Data 块除了开头的 Magic 以外就是一个个 KeyValue 对拼接而成，Magic 内容就是一些随机数字，目的是防止数据损坏。

* 结构如下:

![Magic](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59p0f3ygnj30ff0320ti.jpg)

* HFile结构图如下：

![HFile结构图](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59p18pnewj30f1050755.jpg)

* Data Block 段用来保存表中的数据，这部分可以被压缩。
* Meta Block 段（可选的）用来保存用户自定义的kv段，可以被压缩。
* FileInfo 段用来保存 HFile 的元信息，本能被压缩，用户也可以在这一部分添加自己的元信息。
* Data Block Index 段（可选的）用来保存 Meta Blcok 的索引。
* Trailer 这一段是定长的。保存了每一段的偏移量，读取一个 HFile 时，会首先读取 Trailer，Trailer 保存了每个段的起始位置(段的 Magic Number 用来做安全 check)，然后，DataBlock Index 会被读取到内存中，这样，当检索某个 key 时，不需要扫描整个 HFile，而只需从内存中找到 key 所在的 block ，通过一次磁盘 io 将整个 block 读取到内存中，再找到需要的 key。DataBlock Index 采用 LRU 机制淘汰。
* HFile 的 Data Block，Meta Block 通常采用压缩方式存储，压缩之后可以大大减少网络 IO 和磁盘 IO，随之而来的开销当然是需要花费 cpu 进行压缩和解压缩。目标 HFile 的压缩支持两种方式：gzip、lzo。