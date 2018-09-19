# MYSQL_NOTE

## 查看连接线程

命令将每一个连接的线程，作为一条独立的记录输出。

```sql
SHOW PROCESSLIST;
```

## 修改数据库名

```shell
mysqladmin -u root -p create hwei
mysqldump Hwei | mysql -u root -p hwei
mysql> drop database Hwei
```

## 索引操作

```sql
show index from tablename\G
ALTER TABLE tablename DROP INDEX index_name;
```