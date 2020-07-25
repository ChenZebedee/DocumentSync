# HIVE_DATA_SKEW
## JOIN 无关数据倾斜优化
### group by 数据倾斜优化
```sql
set hive.map.aggr=true
set hive.groupby.skewindata=true
```
设置两个参数可以在数据倾斜时进行负载均衡，产生两个 MapReduce Job，第一个 Job Map 输出的结果随机散列在各个 Reduce 中，那么就可以把同 Key 的数据散列在不同的 Reduce 中，做完处理之后，进入第二个 MapReduce Job，第二个就是正常的 Job Reduce 根据 group by key 实现聚合

### count distinct 优化
如 ``` select count(distinct user) from user;``` 的优化
先进行 group by 分组去重查询，再通过 count 统计分组后的数据
```sql
select count(*)
from 
(
    select user
    from some table
    group by user
) tmp;
```
## JOIN 相关数据倾斜优化
分为 MapJoin 可以解决的优化(大表 join 小表)和 MapJoin 无法解决的优化(大表 join 大表)
### 大表 join 小表优化

假如供应商会进行评级，比如（五星、四星、三星、两星、一星），此时业务人员希望能够分析各供应商星级的每天销售情况及其占比。

普通人写sql:
```sql
select 
    b.seller_star,
    count(a.order_id) as order_cnt
from (
    Select order_id,seller_id
    from
    dwd_sls_fact_detail_table
    where partition_value='20190101'
) a 
left outer join
(
    Select seller_id,seller_star
    from dim_seller
    where partition_value='20190101'
) b
on a.seller_id=b.seller_id
group by b.seller_star;
```
使用 MapJoin:
```sql
select /*+mapjoin(b)*/
    b.seller_star,
    count(a.order_id) as order_cnt
from (
    Select order_id,seller_id
    from
    dwd_sls_fact_detail_table
    where partition_value='20190101'
) a 
left outer join
(
    Select seller_id,seller_star
    from dim_seller
    where partition_value='20190101'
) b
on a.seller_id=b.seller_id
group by b.seller_star;
```
MapJoin 默认开启，参数是:```set hive.auto.convert=true;```

判断为小表的配置为:```hive.mapjoin.smalltable.filesize``` 0.11.0 版本之后参数为:```hive.auto.convert.join.noconditionaltask.size```，默认大小为 `25MB`，最大不能超过内存的十分之一

### 大表 join 大表
A表：buyer_id、seller_id和pay_cnt_90d

B表：seller_id 和 s_level

Q:每个买家在各个级别卖家的成交比例信息

普通 SQL:
```sql
select
    m.buyer_id,
    sum(m.pay_cnt_90d),
    sum(case when m.s_level=0, then m.pay_cnt_90d end) as pay_cnt_90d_s0,
    sum(case when m.s_level=1, then m.pay_cnt_90d end) as pay_cnt_90d_s1,
    sum(case when m.s_level=2, then m.pay_cnt_90d end) as pay_cnt_90d_s2,
    sum(case when m.s_level=3, then m.pay_cnt_90d end) as pay_cnt_90d_s3,
    sum(case when m.s_level=4, then m.pay_cnt_90d end) as pay_cnt_90d_s4,
    sum(case when m.s_level=5, then m.pay_cnt_90d end) as pay_cnt_90d_s5
from
(
    select a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select 
            buyer_id,seller_id,pay_cnt_90d
        from table_A
    ) a
    join
    (
        select
            seller_id,s_level
        from table_B
    ) b
    on a.seller_id = b.seller_id
) m
group by m.buyer_id
```

#### 方案一：间接 MapJoin
对 A 表限制列取出需要的列先

对 B 表限制行，先取出 B 表中满足 A 表条件的数据，如果这个结果数据可以满足 MapJoin 的条件，就可以实现间接 MapJoin 代码如下：
```sql
select
    m.buyer_id,
    sum(m.pay_cnt_90d),
    sum(case when m.s_level=0, then m.pay_cnt_90d end) as pay_cnt_90d_s0,
    sum(case when m.s_level=1, then m.pay_cnt_90d end) as pay_cnt_90d_s1,
    sum(case when m.s_level=2, then m.pay_cnt_90d end) as pay_cnt_90d_s2,
    sum(case when m.s_level=3, then m.pay_cnt_90d end) as pay_cnt_90d_s3,
    sum(case when m.s_level=4, then m.pay_cnt_90d end) as pay_cnt_90d_s4,
    sum(case when m.s_level=5, then m.pay_cnt_90d end) as pay_cnt_90d_s5
from
(
    select /*mapjoin(b)*/
        a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select 
            buyer_id,seller_id,pay_cnt_90d
        from table_A
    ) a
    join
    (
        select
            b0.seller_id,b0.s_level
        from table_B b0
        join
        (select seller_id from table_A group by seller_id) a0
        on b0.seller_id=a0.seller_id
    ) b
    on a.seller_id = b.seller_id
) m
group by m.buyer_id
```

#### 方案二：join 时使用 case when 语句
当倾斜的值是明确的且数量很少的时候，比如 null 值引起的倾斜

核心是将这些数据随机分发到不同的 reduce 中，就是在 join 时对这些特殊数据进行 concat 随机数操作，从而达到随机分发的目的

SQL 逻辑如下：
```sql
select 
    a.user_id,a.order_id,b.user_id
from table_a a
join table_b b
on (case when a.user_id is null then concat( 'hive',read()) else a.user_id end) = b.user_id
```
Hive 默认是提供了优化的，只需要设置 skewinfo 和 skewjoin 两个参数即可，如：由于 table_B 的值 "0" 和 "1" 引起的倾斜，则可以做如下设置：
```sql
set hive.optimize.skewinfo=table_B:(seller_id)[("0")("1")];
set hive.optimize.skewjoin=true;
```

#### 方案三：倍数 B 表再取模 join
##### 通用方案：
建立一个中间表 numbers 表，只有一列 int 行，从 1-10(根据倾斜度而定)，然后 B 表放大 10 倍，再取模 join，sql如下
```sql
select
    m.buyer_id,
    sum(m.pay_cnt_90d),
    sum(case when m.s_level=0, then m.pay_cnt_90d end) as pay_cnt_90d_s0,
    sum(case when m.s_level=1, then m.pay_cnt_90d end) as pay_cnt_90d_s1,
    sum(case when m.s_level=2, then m.pay_cnt_90d end) as pay_cnt_90d_s2,
    sum(case when m.s_level=3, then m.pay_cnt_90d end) as pay_cnt_90d_s3,
    sum(case when m.s_level=4, then m.pay_cnt_90d end) as pay_cnt_90d_s4,
    sum(case when m.s_level=5, then m.pay_cnt_90d end) as pay_cnt_90d_s5
from
(
    select a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select 
            buyer_id,seller_id,pay_cnt_90d
        from table_A
    ) a
    join
    (
        select /*mapjoin(numbers)*/
            b1.seller_id,b1.s_level,b2.number
        from table_B b1
        join numbers b2 
    ) b -- 每条 table_B 的数据都会变成 10 条
    on a.seller_id = b.seller_id
    and mod(a.pay_cnt_90d,10)+1=b.number -- 因为 numbers 是 1-10 所以对 pay_cnt_90d 进行取模后要 +1
) m
group by m.buyer_id
```
个人理解：
>当 B 表扩大10倍之后，那么B表可以在添加一个进入 reduce 分区的判断条件，这样扩大 10 倍之后，再拿 A 表的 pay_cnt_90d 的值取模 join 那就可以进行随机散列操作不会一个人一直在一个 reduce 中，一个人可以在多个 reduce 中

##### 专用方案:
只需要把大卖家扩大就行，小卖家不用放大倍数

1. 先把大卖家找出来，然后生成大卖家临时表(dim_big_seller),同时预先设定要扩大的倍数 1000 倍
2. 在 A 表和 B 表都新建一个 join 列，逻辑为：如果是大卖家，那么 concat 一个随机分配整数(0到预定义的倍数之间)，如果不是，则保持不变

sql逻辑如下
```sql
select
    m.buyer_id,
    sum(m.pay_cnt_90d),
    sum(case when m.s_level=0, then m.pay_cnt_90d end) as pay_cnt_90d_s0,
    sum(case when m.s_level=1, then m.pay_cnt_90d end) as pay_cnt_90d_s1,
    sum(case when m.s_level=2, then m.pay_cnt_90d end) as pay_cnt_90d_s2,
    sum(case when m.s_level=3, then m.pay_cnt_90d end) as pay_cnt_90d_s3,
    sum(case when m.s_level=4, then m.pay_cnt_90d end) as pay_cnt_90d_s4,
    sum(case when m.s_level=5, then m.pay_cnt_90d end) as pay_cnt_90d_s5
from
(
    select a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select /*mapjoin(big)*/
            buyer_id,seller_id,pay_cnt_90d,
            if(big.seller_id is not null,concat(table_A.seller_id,'rnd',cast(rand()*1000) as bigint),table_A.seller_id) as seller_id_joinkey
        from table_A
        left outer join 
        -- big 表的 seller_id 有重复，所以一定要先 group by 之后再 join，以保证 table_A 的行数不变
        (select seller_id from dim_big_seller group by seller_id) big
        table_A.seller_id=big.seller_id
    ) a
    join
    (
        select /*mapjoin(big)*/
            seller_id,s_level,
            coalesce(seller_id_joinkey,table_B.seller_id) as seller_id_joinkey
        from table_B
        left outer join
        (select seller_id,seller_id_jionkey from dim_big_seller) big 
        on table_B.seller_id=big.seller_id
    ) b
    on a.seller_id_joinkey = b.seller_id_joinkey
) m
group by m.buyer_id
```

其实就是生成一个 big 的中间表，大表的seller_id变成随机数，0-1000以内，再通过两个表各自关联，取出这个随机生成的id，然后再通过这个id进行join


#### 方案4：动态一分为二
把倾斜的和不倾斜的分开处理，如果是倾斜的就找出来，进行 mapjoin ，最后通过 union all 结果

缺点：代码复杂，且需要一个临时表来存储倾斜的键值对

伪代码：
```sql
-- 先找出 90 天买家数超过 10000 的卖家
insert overwrite table tmp_table_B
select 
    m.seller_id,
    n.s_level
from 
(
    select
        seller_id
    from
    (
        select
            seller_id,
            count(buyer_id) as byr_cnt
        from table_A
        group by seller_id
    ) a
    where a.byr_cnt > 10000   
) m
left outer join
(
    select 
        user_id,
        s_level,
    from table_B
) n
on m.seller_id=n.user_id

-- 对于 90 天超过 10000 的卖家进行 mapjoin，其他卖家正常 join
select
    m.buyer_id,
    sum(m.pay_cnt_90d),
    sum(case when m.s_level=0, then m.pay_cnt_90d end) as pay_cnt_90d_s0,
    sum(case when m.s_level=1, then m.pay_cnt_90d end) as pay_cnt_90d_s1,
    sum(case when m.s_level=2, then m.pay_cnt_90d end) as pay_cnt_90d_s2,
    sum(case when m.s_level=3, then m.pay_cnt_90d end) as pay_cnt_90d_s3,
    sum(case when m.s_level=4, then m.pay_cnt_90d end) as pay_cnt_90d_s4,
    sum(case when m.s_level=5, then m.pay_cnt_90d end) as pay_cnt_90d_s5
from
(
    select a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select 
            buyer_id,seller_id,pay_cnt_90d
        from table_A
    ) a
    join
    (
        select
            seller_id,s_level
        from table_A a
        left outer join tmp_table_B b
        on a.seller_id=b.seller_id
        where b.seller_id is null
    ) b
    on a.seller_id = b.seller_id
    union all
    select /*mapjoin(b)*/
        a.buyer_id,a.seller_id,a.pay_cnt_90d,b.s_level
    from
    (
        select 
            buyer_id,seller_id,pay_cnt_90d
        from table_A
    ) a
    join
    (
        select
            seller_id,s_level
        from tmp_table_B
    ) b
    on a.seller_id = b.seller_id
) m
group by m.buyer_id

```