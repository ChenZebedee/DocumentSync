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

### 方案三：倍数 B 表再取模 join
建立一个中间表 number 表，只有一列 int 行，从 1-10(根据倾斜度而定)，然后 B 表放大 10 倍，再取模 join，sql如下
```sql

```