# mysql The JSON Data Type
## 1. JSON基本操作
### 1.1 基本知识
大小限制为max_allowed_packet系统变量的值;<br/>
JSON_STORAGE_SIZE()：获取这个JSON所需的空间;<br/>
[JSON函数的介绍](https://dev.mysql.com/doc/refman/8.0/en/json-functions.html)<br/>
[空间GeoJSON函数](https://dev.mysql.com/doc/refman/8.0/en/spatial-geojson-functions.html)
### 1.2 部分更新操作
不能直接进行update set操作，update时可以调用 JSON_SET()， JSON_REPLACE()或 JSON_REMOVE()三个函数进行操作；
### 1.3 基本函数
JSON_TYPE()：获取JSON类型，如果不是JSON数据，报错；<br/>
JSON_ARRAY()：将数据转换为JSON数据格式<br/>
JSON_OBJECT：将数据转换为键值对形式<br/>
JSON_SET()：替换存在的，新增不存在的<br/>
JSON_INSERT()：只新增，不替换<br/>
JSON_REPLACE()：只替换，不新增<br/>
JSON_REMOVE()：删除,返回剩余的
### example:
``` sql
mysql> SELECT JSON_TYPE('["a", "b", 1]');
```
运行结果
```
+----------------------------+
| JSON_TYPE('["a", "b", 1]') |
+----------------------------+
| ARRAY                      |
+----------------------------+
```
```sql
mysql> SELECT JSON_TYPE('"hello"');
```
运行结果
```
+----------------------+
| JSON_TYPE('"hello"') |
+----------------------+
| STRING               |
+----------------------+
```
```sql
mysql> SELECT JSON_TYPE('hello');
```
运行结果
```
ERROR 3146 (22032): Invalid data type for JSON data in argument 1
to function json_type; a JSON string or JSON type is required.
```
```sql
mysql> SELECT JSON_ARRAY('a', 1, NOW());
```
运行结果
```
+----------------------------------------+
| JSON_ARRAY('a', 1, NOW())              |
+----------------------------------------+
| ["a", 1, "2015-07-27 09:43:47.000000"] |
+----------------------------------------+
```
```sql
mysql> SELECT JSON_OBJECT('key1', 1, 'key2', 'abc');
```
运行结果
```
+---------------------------------------+
| JSON_OBJECT('key1', 1, 'key2', 'abc') |
+---------------------------------------+
| {"key1": 1, "key2": "abc"}            |
+---------------------------------------+
```
值的比较区分大小写,并且null、fasle、true只能写小写，大写会报错；<br/>
如果要存储引号，直接作为JSON数据存储，要用双反斜杆转义即 **\\\\'\\\\'** 或 **\\\\"\\\\"** ,而作为JSON_OBJECT时,只需要用单反斜杠转义即可 **\\'\\' 或 \\"\\"** ，直接查询可以看到反斜杠;<br/>
在查找特定的值时，可以用column-path运算符 -> 来进行运算 即 列名->"$.key" 这样可以保存反斜杠显示<br/>
如果想显示出一个单纯的字符串，用内联路径运算符 ->> 即可显示人们能理解的字符串；
> ## Note
>The previous example does not work as shown if the NO_BACKSLASH_ESCAPES server SQL mode is enabled. If this mode is set, a single backslash instead of double backslashes can be used to insert the JSON object literal, and the backslashes are preserved. If you use the JSON_OBJECT() function when performing the insert and this mode is set, you must alternate single and double quotes, like this:<br/>
>```sql
>mysql> INSERT INTO facts VALUES (JSON_OBJECT('mascot', 'Our mascot is a dolphin named "Sakila".'));
>```
>See the description of the JSON_UNQUOTE() function for more information about the effects of this mode on escaped characters in JSON values.

## 2. JSON值的规范化，合并和自动包装JSON值的规范化
### 之前版本：
规则化为：“ 第一次重复键获胜 ”
```sql
insert into test1 values ('{"x": "17","x": "red"}'), ('{"x":"17","x":"red","x": [3, 5, 7]}');
```
    输出结果为：
    +-----------+
    | c1        |
    +-----------+
    | {"x": 17} |
    | {"x": 17} |
    +-----------+
### 8.0
```sql
insert into test1 values ('{"x": "17","x": "red"}'), ('{"x":"17","x":"red","x": [3, 5, 7]}');
```
    输出结果为：
    +------------------+
    | column1          |
    +------------------+
    | {"x": "red"}     |
    | {"x": [3, 5, 7]} |
    +------------------+
## 2. 合并数组
有两个函数：
1. JSON_MERGE_PRESERVE 
2. JSON_MERGE_PATCH
对比sql语句
```sql
SELECT
JSON_MERGE_PRESERVE('[1, 2]', '["a", "b", "c"]', '[true, false]') AS Preserve1,
JSON_MERGE_PATCH('[1, 2]', '["a", "b", "c"]', '[true, false]') AS Patch1,
JSON_MERGE_PRESERVE('{"a": 1, "b": 2}', '{"c": 3, "a": 4}', '{"c": 5, "d": 3}') AS Preserve2,
JSON_MERGE_PATCH('{"a": 3, "b": 2}', '{"c": 3, "a": 4}', '{"c": 5, "d": 3}') AS Patch2,
JSON_MERGE_PRESERVE('1', '2') AS Preserve3,
JSON_MERGE_PATCH('1', '2') AS Patch3,
JSON_MERGE_PRESERVE('[10, 20]', '{"a": "x", "b": "y"}') AS Preserve4,
JSON_MERGE_PATCH('[10, 20]', '{"a": "x", "b": "y"}') AS Patch4\G
```

运行结果

    mysql> SELECT
        -> JSON_MERGE_PRESERVE('[1, 2]', '["a", "b", "c"]', '[true, false]') AS Preserve1,
        -> JSON_MERGE_PATCH('[1, 2]', '["a", "b", "c"]', '[true, false]') AS Patch1,
        -> JSON_MERGE_PRESERVE('{"a": 1, "b": 2}', '{"c": 3, "a": 4}', '{"c": 5, "d": 3}') AS Preserve2,
        -> JSON_MERGE_PATCH('{"a": 3, "b": 2}', '{"c": 3, "a": 4}', '{"c": 5, "d": 3}') AS Patch2,
        -> JSON_MERGE_PRESERVE('1', '2') AS Preserve3,
        -> JSON_MERGE_PATCH('1', '2') AS Patch3,
        -> JSON_MERGE_PRESERVE('[10, 20]', '{"a": "x", "b": "y"}') AS Preserve4,
        -> JSON_MERGE_PATCH('[10, 20]', '{"a": "x", "b": "y"}') AS Patch4\G
    *************************** 1. row ***************************
    Preserve1: [1, 2, "a", "b", "c", true, false]
    Patch1: [true, false]
    Preserve2: {"a": [1, 4], "b": 2, "c": [3, 5], "d": 3}
    Patch2: {"a": 4, "b": 2, "c": 5, "d": 3}
    Preserve3: [1, 2]
    Patch3: 2
    Preserve4: [10, 20, {"a": "x", "b": "y"}]
    Patch4: {"a": "x", "b": "y"}
    1 row in set (0.00 sec)
按照官方样例，可以知道JSON_MERGE_PRESERVE函数进行的是全部整合，同类型会合并成一个数组，即自动包装；<br/>
而JSON_MERGE_PATH合并时，同类型只会记录最后的数据，也就是只记录最后的一条，不会进行数组合并；<br/>
并且这一特性与之前版本比较并未修改；<br/>
> ### Note
>JSON_MERGE_PRESERVE() is the same as the JSON_MERGE() function found in previous versions of MySQL (renamed in MySQL 8.0.3). JSON_MERGE() is still supported as an alias for JSON_MERGE_PRESERVE() in MySQL 8.0, but is deprecated and subject to removal in a future release.

上诉为官方提醒，既是JSON_MERGE这种简写的方式要被删除了，目前8.0还支持，之后就不支持了；

## 3. 搜索和修改路径

### 3.1 路径语法
使用前导$字符来表示

    $[n] 匹配第n位<br/>
    $[n to m] 匹配下标为n到m <br/>
    $[*] 匹配所有<br/>
    $[last] 匹配最后一位<br/>
    $.key 匹配key<br/>
    $[last-3 to laset -1]

## 4. JSON值的比较和排序
### 4.1 基本比较类型
使用 =, <, <=, >, >=, <>, !=, <=> 进行比较；

不支持

    BETWEEN()
    IN()
    GREATEST()
    LEAST()

### 4.2 JSON与非JSON值进行转换
CAST()函数进行转换
>### example：
>ORDER BY CAST(JSON_EXTRACT(jdoc, '$.id') AS UNSIGNED);

主要用于排序时使用；

## 5. JSON值聚合函数使用
null会被忽略，转换为数字类型进行聚合；