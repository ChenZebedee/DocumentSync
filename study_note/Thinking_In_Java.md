# Translation Thinking_In_JAVA

## 1. Overview -- 概观
```
1. Preface -- 前言
2. Introduction -- 介绍
3. Introduction to Objects -- 介绍对象
    3.1 Object -- 对象
4. Evertthing Is an Object -- 任何东西都是对象
5. Operators -- 运算符
6. Controlling Execution -- 调度执行(执行控制)
    6.1 Controlling -- 控制,管制,控,治理,管,操纵,监督,抑制,把持,调度,驾驭,掌管
    6.2 Execution -- 执行,肉刑,诛,悬料
7. Initialization & Cleanup -- 初始化和清理
    7.1 Initialization -- 初始化
    7.2 Cleanup -- 净化,清洁工人,清洁器
8. Access Control -- 访问控制(访问权限控制)
    8.1 Access -- 访问,接驳,进接,取数,存取,通路,进接
    8.2 Control -- 控制,管制,控,治理,管,操纵,监督,抑制,把持,名词,管制,管,节制
9. Reusing Classes -- 重用类{继承？}
    9.1 Reusing -- 重用
    9.2 Classes -- 类
10. Polymorphism -- 多态性
11. Interfaces -- 接口
12. Inner Classes -- 内部类
    12.1 Inner -- 内，内在的，里
    12.2 Classes -- 类
13. Holding Your Objects -- 拿着你的物体(持久化对象)
    13.1 Holding -- 保持
14. Error Handling with Exceptions -- 使用异常处理错误(异常处理机制)
    14.1 Handling -- 处理
    14.2 Exception -- 例外
15. Strings -- 字符串
16. Type Information -- 输入信息
    16.1 Type -- 类型，类，种
    16.2 Infomation -- 信息来源
17. Generics -- 泛型
18. Arrays -- 数组
19. Containers in Depth -- 容器深度
    19.1 Containers -- 集装箱,容器
    19.2 Depth -- 深度,深处
20. I/O -- input/output -- 输入/输出
21. Enumerated Type -- 枚举类型
    21.1 Enumerated -- 枚举
    21.2 Type -- 类型
22. Annotations -- 注释
23. Concurrency -- 并发
24. Graphical User Interfaces -- 图形用户界面
    24.1 Graphical -- 图形
25. Supplements -- 补充，拾遗
26. Resources -- 资源
27. Index -- 索引,指数
```


## Contents(What's Inside) -- 内容(什么内容) -- 就是目录的意思

### concurrency -- 并发 page 797
#### The many faces of concurrencry -- 并发的多面性
    1. faster execution -- 快速启动
    2. Improving code design -- 代码设计优化
        --> Improving -- 提高，改善，优于，演变
        --> design -- 设计
#### Basic threading -- 基本线程
--> basic -- 基本
--> threading -- 线程

    1. Defining tasks -- 明确任务
        --> defining -- 确定，明确，限定
        --> tasks -- 任务,工作，作业
    2. The Thread class -- 线程类
    3. Using Executors -- 使用执行者
        --> Executors -- 执行者
    4. producing return values from tasks -- 任务产生的返回值
        --> producing -- 产生，生产，产，创造，做
    5. sleeping -- 睡眠
    6. priority -- 优先权
    7. Yielding -- 生产，妹妹
    8. Daemon threads -- 守护线程
    9. coding variations -- 代码变异
        --> variations -- 变异，变动，变奏，异样
    10. Terminology -- 术语
    11. joining a thread -- 添加线程
    12. Creating responsive user interfaces -- 创建用户响应接口
        --> responsive -- 响应
    13. Thread groups -- 线程组（线程池？）
    14. Catching exception -- 捕捉异常
        --> catching -- 捕捉
        --> exception -- 列外(就是程序出现预先所知错误)




## Concurrency 
### Up to point,you've been learning about `squential` programming.Everything in a program happens one step at a time. 

最重要的一点，你已经学习了顺序编程，在程序运行的时候每件事的一个步骤至发生一次

1. point -- 点
2. squential -- 顺序

A large subset of programming problems can be solved using sequential programming.

可以用顺序编程解决大部分编程问题

1. large -- 大
2. subset -- 子集
3. solved -- 解决了，解释
4. sequential -- 顺序

For some problems,however,

然而对于一些问题

it becomes convenient or even essential to execute several parts of a program in parallel,

并行的执行程序的多个部分变得更方便甚至是必要的

1. becomes -- 变成，变,成，为，做，作
2. convenient -- 方便,合宜 -- con ve nient
3. even -- 甚至
4. essential -- 必要 -- e ssen tial -- i'senCHal
5. execute -- 执行
6. several -- 一些
7. parts -- 部分,部件，角色，组成
8. parallel -- 平行，并行

so that those portions either appear to be execution concurrently,

所以那些部分(程序并行执行的部分)或者看起来是同时执行的程序

1. portions -- 部
10. either -- 或
11. appear -- 出现
12. execution -- 执行
13. concurrently -- 同时

or if multiple processors are available,
或者可以使用多线程处理器
1. multiple -- 多，多种
2. processors -- 处理器 -- pro ces sors
3. available -- 可用的

actually do execute simultaneously.
我是可以同时执行
1. actually -- 其实
2. simultaneously -- 同时,并 -- simul ta neous ly