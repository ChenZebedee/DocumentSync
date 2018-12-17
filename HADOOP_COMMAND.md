# HADOOP 操作

## hive 权限控制
```sql

create role query;
grant SELECT,SHOW_DATABASE on database rme to role query;
grant role query to user fengkong with admin option;

show grant role query;

grant ALL on database fengkong to user hadoop;
revoke ALL on database fengkong from user hadoop;
```