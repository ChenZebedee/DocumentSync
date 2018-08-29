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

## 给用户授权

```sql
GRANT  all privileges on *.* to test@'%';
GRANT pdc_developer to test@'%'
```

## 刷新

```sql
flush  privileges;
```