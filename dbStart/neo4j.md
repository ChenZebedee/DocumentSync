# neo4j 学习文档

## docker 安装使用

### 配置neo4j主目录

```s
export NEO4J_HOME=/srv/neo4j
```

### 新建相关目录

```shell
mkdir -p ${NEO4J_HOME}/data
mkdir -p ${NEO4J_HOME}/plugins
mkdir -p ${NEO4J_HOME}/import
```

### docker-compose文件编写

```s
cat << EOF > docker-compose.yml
version: '4.4'
services:
  db:
    image: 'neo4j'
    restart: always
    hostname: 'neo4j.19951106.xyz'
    environment:
      NEO4J_apoc_export_file_enabled: true
      NEO4J_apoc_import_file_enabled: true
      NEO4J_apoc_import_file_use__neo4j__config: true
    ports:
      - '7474:7474'
      - '7687:7687'
    volumes:
      - '\$NEO4J_HOME/data:/data'
      - '\$NEO4J_HOME/plugins:/plugins'
      - '\$NEO4J_HOME/import:/var/lib/neo4j/import'
    shm_size: '256m'
EOF
```

### 配置启动/停止脚本

start.sh
```s
cat << EOF > start.sh
#!/bin/bash

export NEO4J_HOME=/srv/neo4j
docker compose up -d
EOF
```

stop.sh
```s
cat << EOF > stop.sh
#!/bin/bash

export NEO4J_HOME=/srv/neo4j
docker compose stop
EOF
```

restart.sh
```s
cat << EOF > restart.sh
#!/bin/bash

export NEO4J_HOME=/srv/neo4j
docker compose stop
docker compose up -d
EOF
```


## neo4j 基本命令

### 创建index

```java
// Create an index
// Replace:
//   'IndexName' with name of index (optional)
//   'LabelName' with label to index
//   'propertyName' with property to be indexed
CREATE INDEX [IndexName] 
FOR (n:LabelName)
ON (n.propertyName)
```


### 创建唯一约束索引

```java
// Create unique property constraint
// Replace:
//   'LabelName' with node label
//   'propertyKey' with property that should be unique
CREATE CONSTRAINT ON (n:<LabelName>) ASSERT n.<propertyKey> IS UNIQUE
```

### 查询数据

```java
// Get some data
MATCH (n3)<-(n1)-[r]->(n2) RETURN r, n1, n2 LIMIT 25
```

### HELLO,WORLD

```java
// Hello World!
CREATE (database:Database {name:"Neo4j"})-[r:SAYS]->(message:Message {name:"Hello World!"}) RETURN database, message, r
```