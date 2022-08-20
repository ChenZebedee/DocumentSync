# 流程图标准

## flowchart 流程图

```mermaid
graph TD;
    A-->B;
    A-->C;
    A-->D;
    M;
    B-->F;
    B-->G;
    G-->F
    C-->H;
```

```mermaid
graph LR;
a==>b;
b-->c;
a--联系-->c;
a-->s;
a-.->f;
s-->j;
c---id2;

subgraph 图表名;
        id2[默认方形]==粗线==>id3{菱形}
        id3-.虚线.->id4>右向旗帜]
        id3--无箭头---id5((圆形))
    end
```

## 语法

1. 方向

|符号|意义|
|:----|----:|
|TB|从上到下|
BT | 从下到上
RL | 从右到左
LR | 从左到右

2. 连线类型

|符号|意义|
|:----|----:|
– | 单线
–text-- | 单线上加文字
== | 粗线
\=\=text\=\= | 粗线加文字
-.- | 虚线
-.text.- | 虚线加文字

3. 节点

|符号|意义|
|:----|----:|
id[文字] | 矩形节点
id(文字) | 圆角矩形节点
id((文字)) | 圆形节点
id>文字] | 右向旗帜状节点
id{文字} | 菱形节点

## Sequence diagram(顺序图)

```mermaid
sequenceDiagram
    participant Alice
    participant Bob
    Alice->>John: Hello John, how are you?
    loop Healthcheck
        John->>John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>dfafqfew..
    John-->>Alice: Great!
    John->>Bob: How about you?
    Bob-->>John: Jolly good!
```


## 甘特图(Gantt diagram)

```mermaid
gantt
    dateFormat  YYYY-MM-DD
    title 为mermaid加入甘特图功能
    section A部分
    完成任务        :done, des1,2019-01-06,2019-01-08
    正进行任务      :active, des2,2019-01-09,3d
    待开始任务      :des3, after des2, 5d
    待开始任务2     :des4, after des3, 5d
    section 紧急任务
    完成任务        :crit,done,2019-01-06,24h
    实现parser     :crit,done,after des1, 2d
    为parser编写test :crit, active, 3d
    待完成任务      :crit,5d
    为rendere编写test: 2d
    将功能加入到mermaid: 1d
    section B部分
    完成任务 :crit,done,2019-01-06,24h
 
```
