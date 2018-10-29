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
ALTER TABLE table_name DROP INDEX index_name;
ALTER TABLE table_name ADD INDEX index_name (column_name);
--组合索引
ALTER TABLE table_name ADD INDEX index_name ( column1, column2, column3 );
```

## 获取索引(除去主键)

```shell
mysql -u -p'' -Ne"show index from ${DATABASE}.${TABLE}\g" | awk 'BEGIN{OFS=","}{ print $5,$3}' | grep -v "PRIMARY"
```