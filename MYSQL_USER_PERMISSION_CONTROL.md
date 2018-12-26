# MySQL用户管理

## 创建用户

```sql
CREATE USER 'username'@'%' IDENTIFIED WITH mysql_native_password BY 'youpassword';
```

## 密码修改

```sql
ALTER USER 'username'@'*' IDENTIFIED BY 'password';
```

## 新建权限规则

```sql
CREATE ROLE 'app_developer', 'app_read', 'app_write';
GRANT ALL ON *.* TO 'app_developer';
GRANT SELECT ON *.* TO 'app_read';
GRANT INSERT, UPDATE, DELETE ON *.* TO 'app_write';
```

## 修改加密规则

```sql
--更新密码
ALTER USER 'root'@'%' IDENTIFIED BY 'Mnw!@#456' PASSWORD EXPIRE NEVER;
--更改加密规则
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'Mnw!@#456';
```

## 给用户授权

```sql
GRANT  all privileges on *.* to test@'%';
GRANT pdc_developer to test@'%'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
```

## 刷新

```sql
--设置默认激活角色(在 GRANT ... TO ''@'%'后)
SET DEFAULT ROLE ALL TO
  'dev1'@'localhost';
--停用所有角色
SET ROLE NONE;
--只启用一个角色
SET ROLE ALL EXCEPT 'app_write';
--恢复所有角色
SET ROLE DEFAULT;

flush  privileges;
```

## 删除权限

```sql
--取消权限
REVOKE INSERT, UPDATE, DELETE ON app_db.* FROM 'app_write';
--删除角色
DROP ROLE 'app_read', 'app_write';
```

## 查看所有权限

```sql
查看MYSQL数据库中所有用户
SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;
SHOW GRANTS
    [FOR user_or_role
        [USING role [, role] ...]]
```

## 查看用户权限

```sql
SHOW GRANTS FOR ''@'%'\G
SHOW GRANTS FOR ''@'%' USING 'pdc_developer'\G
```