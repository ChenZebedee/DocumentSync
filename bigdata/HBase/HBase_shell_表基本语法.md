# HBase shell 表基本语法

## 通用命令
1. status:  提供HBase的状态，例如，服务器的数量。
2. version: 提供正在使用HBase版本。
3. table_help: 表引用命令提供帮助。
4. whoami: 提供有关用户的信息。
   
## 添加数据
语法：put `<table>,<rowkey>,<columnfamily:column>,<value>,<timestamp>`

例如：表t1的添加一行记录：rowkey 是 rowkey001，family name：f1，column name：col1，value：value01，timestamp：系统默认 
```
hbase(main)> put 't1','rowkey001','f1:col1','value01'
```
用法比较单一。

## 查询数据
### 查询某行记录
#### 语法：
get `<table>,<rowkey>,[<family:column>,....]`

#### 查询表t1，rowkey001中的f1下的col1的值
```
hbase(main)> get 't1','rowkey001', 'f1:col1'
```
#### 或者：
```
hbase(main)> get 't1','rowkey001', {COLUMN=>'f1:col1'}
```
### 查询表t1，rowke002中的f1下的所有列值（数据多的时候 不建议使用）
```
hbase(main)> get 't1','rowkey001'
```

### 扫描表
#### 语法：
```
scan <table>, {COLUMNS => [ <family:column>,.... ], LIMIT => num}
```
>另外，还可以添加STARTROW、TIMERANGE和FITLER等高级功能
#### 扫描表t1的前5条数据
```
hbase(main)> scan 't1',{LIMIT=>5}
```

### 查询表中的数据行数
#### 语法：
```
count <table>, {INTERVAL => intervalNum, CACHE => cacheNum}
```
>INTERVAL设置多少行显示一次及对应的rowkey，默认1000；CACHE每次去取的缓存区大小，默认是10，调整该参数可提高查询速度

#### 查询表t1中的行数，每100条显示一次，缓存区为500
```
hbase(main)> count 't1', {INTERVAL => 100, CACHE => 500}
```

## 删除表或数据
### 删除行中的某个列值
#### 语法：
```
delete <table>, <rowkey>,  <family:column> , <timestamp>,必须指定列名
```
#### 删除表t1，rowkey001中的f1:col1的数据
```
hbase(main)> delete 't1','rowkey001','f1:col1'
```
>将删除改行f1:col1列所有版本的数据

### 删除行
#### 语法：
```
deleteall <table>, <rowkey>,  <family:column> , <timestamp>，可以不指定列名，删除整行数据
```
#### 删除表t1，rowk001的数据
```
hbase(main)> deleteall 't1','rowkey001'
```

### 删除表中的所有数据
#### 语法： 
```
truncate <table>
```
>其具体过程是：disable table -> drop table -> create table
#### 删除表t1的所有数据
```
hbase(main)> truncate 't1'
```
### 删除表
#### 语法：
```
分两步，先disable,然后drop
```
#### 删除表t1
```
hbase(main)> disable 't1'
hbase(main)> drop 't1'
```
## 查看表
### 列出所有表
通过list可以列出所有已创建的表(除-ROOT表和.META表(被过滤掉了))
```    
hbase(main)> list
```  
### 查看表结构
#### 语法：
```
describe(desc) <table> （可以看到这个表的所有默认参数）
```
#### 查看表t1的结构
```
hbase(main)> describe 't1' 或 desc  't1'
```
### 修改表结构
>修改表结构必须先disable

#### 语法：
```
alter 't1', {NAME => 'f1'}, {NAME => 'f2', METHOD => 'delete'}
```
#### 修改表test1的cf的TTL为180天
```
hbase(main)> disable 'test1'
hbase(main)> alter 'test1',{NAME=>'body',TTL=>'15552000'},{NAME=>'meta', TTL=>'15552000'}
hbase(main)> enable 'test1'
```

### 表重命名
>因为HBase中没有rename命令，所以更改表名比较复杂。重命名主要通过hbase的快照功能。
1. 停止表继续插入 `hbase shell > disable 'tableName'`
2. 制作快照 `hbase shell> snapshot 'tableName', 'tableSnapshot'`
3. 克隆快照为新的名字 `hbase shell> clone_snapshot 'tableSnapshot', 'newTableName'`
4. 删除快照 `hbase shell> delete_snapshot 'tableSnapshot'`
5. 删除原来表 `hbase shell> drop 'tableName'`