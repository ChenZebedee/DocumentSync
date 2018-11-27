# SQOOP 脚本

## mysql到HBase
```shell
sqoop import --connect jdbc:mysql://ip:3306/rme?zeroDateTimeBehavior=convertToNull --query 'select concat(a.f_order_sn,unix_timestamp(a.f_modify_time)) as rowkey,a.* from rme.t_borrower_contact a where a.f_order_sn is not null AND $CONDITIONS' --hbase-table rme -m 5 --split-by f_order_sn --column-family cf1 --hbase-row-key rowkey --hbase-create-table --username 'admin' --password 'Mnw!@#456'

sqoop import --connect jdbc:mysql://ip:3306/rme --table t_borrower_info --where "f_order_sn is not null" --hbase-table rme -m 5 --column-family t_borrower_info --hbase-row-key f_order_sn --hbase-create-table --username 'admin' --password 'Mnw!@#456'
```