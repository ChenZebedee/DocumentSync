# SPRING_CLOUD （version：Hoxton.SR7） 学习
![spring cloud 总体思路](https://spring.io/images/diagram-microservices-dark-4a2e5817aac093437f4f3b3a5be8be88.svg)

## Service discovery - 服务发现
> In the cloud, applications can’t always know the exact location of other services. A service registry, such as Netflix Eureka, or a sidecar solution, such as HashiCorp Consul, can help. Spring Cloud provides DiscoveryClient implementations for popular registries such as Eureka, Consul, Zookeeper, and even Kubernetes' built-in system. There’s also a Spring Cloud Load Balancer to help you distribute the load carefully among your service instances.

Netflix Eureka 或 HashiCorp Consul 服务

spring cloud 提供 DiscoveryClient 对 流行的框架进行安装登记 例如：Eureka, Consul, Zookeeper, and even Kubernetes' built-in system

Spring Cloud Load Balancer 登记其他服务

## API gateway - API 网关

> With so many clients and servers in play, it’s often helpful to include an API gateway in your cloud architecture. A gateway can take care of securing and routing messages, hiding services, throttling load, and many other useful things. Spring Cloud Gateway gives you precise control of your API layer, integrating Spring Cloud service discovery and client-side load-balancing solutions to simplify configuration and maintenance.

Spring cloud gateway 解决服务发现和客户端负载均衡

## Cloud configuration - cloud 配置服务
> In the cloud, configuration can’t simply be embedded inside the application. The configuration has to be flexible enough to cope with multiple applications, environments, and service instances, as well as deal with dynamic changes without downtime. Spring Cloud Config is designed to ease these burdens and offers integration with version control systems like Git to help you keep your configuration safe.

spring cloud config 解决配置灵活化，不停机动态变化，并且集成了Git等版本更新

## Circuit breakers - 熔断器
> Distributed systems can be unreliable. Requests might encounter timeouts or fail completely. A circuit breaker can help mitigate these issues, and Spring Cloud Circuit Breaker gives you the choice of three popular options: Resilience4J, Sentinel, or Hystrix.

Spring Cloud Circuit Breaker 可选择  Resilience4J, Sentinel, Hystrix 三个中的一个
### Resilience4J
### Sentinel
### Hystrix

## Tracing - 追踪
> Debugging distributed applications can be complex and take a long time. For any given failure, you might need to piece together traces of information from several independent services. Spring Cloud Sleuth can instrument your applications in a predictable and repeatable way. And when used in conjunction with Zipkin, you can zero in on any latency problems you might have.

Spring Cloud Sleuth 多服务信息缓存



## martinfowler 的微服务论文学习 


## spring-cloud-AWS -> spring-cloud-aws Reference Documentation, version 2.2.3.RELEASE
![AMS服务](https://s1.ax1x.com/2020/08/25/d6aU9P.png)


## spring-cloud-build
## 2. spring-cloud-bus
## spring-cloud-circuitbreaker
## spring-cloud-cli
## spring-cloud-cloudfoundry
## 1. spring-cloud-commons
> Cloud Native is a style of application development that encourages easy adoption of best practices in the areas of continuous delivery and value-driven development. A related discipline is that of building 12-factor Applications, in which development practices are aligned with delivery and operations goals — for instance, by using declarative programming and management and monitoring. Spring Cloud facilitates these styles of development in a number of specific ways. The starting point is a set of features to which all components in a distributed system need easy access.
### 


## spring-cloud-config
## spring-cloud-consul
## spring-cloud-contract
## spring-cloud-function
## spring-cloud-gateway
## spring-cloud-gcp
## spring-cloud-kubernetes
## spring-cloud-netflix
## spring-cloud-openfeign
## spring-cloud-security
## spring-cloud-sleuth
## spring-cloud-task
## spring-cloud-vault
## spring-cloud-zookeeper