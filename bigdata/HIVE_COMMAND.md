# hive 命令行操作

## 角色权限控制
```sql
--创建和删除角色
create role role_name;
drop role role_name;
--展示所有roles
show roles
--赋予角色权限
grant select on database db_name to role role_name;  
grant select on [table] t_name to role role_name;  
--查看角色权限
show grant role role_name on database db_name; 
show grant role role_name on [table] t_name; 
--角色赋予用户
grant role role_name to user user_name
--回收角色权限
revoke select on database db_name from role role_name;
revoke select on [table] t_name from role role_name;
--查看某个用户所有角色
show role grant user user_name;
```

## 权限控制表
|操作|解释
|:--| --:|
|ALL				|所有权限|
|ALTER			|允许修改元数据（modify metadata data of  object）---表信息数据|
|UPDATE			|允许修改物理数据（modify physical data of  object）---实际数据|
|CREATE			|允许进行Create操作|
|DROP			|允许进行DROP操作|
|INDEX			|允许建索引（目前还没有实现）|
|LOCK			|当出现并发的使用允许用户进行LOCK和UNLOCK操作|
|SELECT			|允许用户进行SELECT操作|
|SHOW_DATABASE	|允许用户查看可用的数据库|

## 用户权限控制
```sql
--赋予用户权限
grant opera on database db_name to user user_name;  
grant opera on [table] t_name to user user_name; 
--回收用户权限
revoke opera on database db_name from user user_name;
--查看用户权限
show grant user user_name on database db_name;     
show grant user user_name on [table] t_name;
```

