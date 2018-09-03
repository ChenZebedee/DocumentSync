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

## hadoop怎么用

***

### 分布式文件系统的使用(hdfs)：

只用于存储数据，能新增，不能进行删除。也就是说，只要存进hdfs中，那就不能进行删除了

### 分布式并行计算框架(mapreduce)：

>MapReduce:
>MapReduce is the key algorithm that the Hadoop MapReduce engine uses to distribute work around a cluster.

#### 个人理解

就是对一行数据进行拆解，然后把多行数据进行同key合并

### 