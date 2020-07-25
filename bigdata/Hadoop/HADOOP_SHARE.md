# HADOOP 分享

## hadoop是什么？

***

### 网上解释：

>* Hadoop是一个开源的框架，可编写和运行分布式应用处理大规模数据，是专为离线和大规模数据分析而设计的，并不适合那种对几个记录随机读写的在线事务处理模式。Hadoop=HDFS（文件系统，数据存储技术相关）+ Mapreduce（数据处理），Hadoop的数据来源可以是任何形式，在处理半结构化和非结构化数据上与关系型数据库相比有更好的性能，具有更灵活的处理能力，不管任何数据形式最终会转化为key/value，key/value是基本数据单元。用函数式变成Mapreduce代替SQL，SQL是查询语句，而Mapreduce则是使用脚本和代码，而对于适用于关系型数据库，习惯SQL的Hadoop有开源工具hive代替
>* Hadoop就是一个分布式计算的解决方案

### 个人理解：

hadoop其实就是开源的、可靠的、可扩展的分布式并行计算框架

## 什么时候用hadoop

***
![什么情况用大数据](http://wx1.sinaimg.cn/mw690/0060lm7Tly1fuwf108w1wj30kt0b4q3z.jpg)

由上图可知，当我们再遇到大数据的的情况下时，会用到hadoop这个东西

## hadoop包括什么

***

### 分布式文件系统的使用(hdfs)：

只用于存储数据，能新增，不能进行删除。也就是说，只要存进hdfs中，那就不能进行删除了

### 分布式并行计算框架(mapreduce)：

>MapReduce:
>MapReduce is the key algorithm that the Hadoop MapReduce engine uses to distribute work around a cluster.

#### 个人理解

就是对一行数据进行拆解，然后把多行数据进行同key合并

### yarn资源管理器

在hadoop MRv1版本中，都是直接mapreduce提交job到namenode节点中，namenode来进行资源分配，也就是将资源管理和任务调度的管理放到了一起管理。而到了 MRv2 版本中添加了yarn将资源管理和任务调度管理分开了

## hadoop怎么用

***

### hadoop版本

#### apache社区版

这个版本适合想在hadoop领域深入研究的人员，用这个版本来进行深入研究

#### Cloudera版本

这个版本是目前应用比较广的一个版本目前最新的是cdh6，cdh5中包含最高的hadoop版本为2.6，而cdh6目前来说不是刚需，没有什么大的改动。并且不用考虑各个组件的版本兼容问题

#### Hortonworks版本

开源免费的版本，分为商业版和免费版，在apache版本上修改的，非常具有apache特色

而目前实验主要用CDH版本,具体生产环境需要视情况而定，不过大部分学了CDH版本后就会直接将CDH用于生产中

### hadoop安装

#### ClouderaManager安装

打包安装，安装一个ClouderManager就可以全部安装，并且可以下载包含bin的软件包进行绿色安装

#### apache安装

可以下载源码进行安装，或者下载已经打过包的包含bin文件的项目进行绿色安装

#### Hortonworks这个版本有兴趣的去了解一下

### hadoop使用

#### hadoop基本命令

hadoop fs -command /path 或者 hdfs dfs -command /path

第一种是可以用于全部的文件操作系统，而第二种只能用于hdfs上的文件系统操作

#### mapreduce的运用

#### 结合hive

#### 结合zookeeper

#### 结合hbase

#### 结合kafka

#### 结合spark

### 总结

hdfs是一个用于存储文件的分布式文件系统，mapreduce是用于并行计算的一个框架，而yarn是用于资源调度的