---
title: 简单的分布式幂等注解的设计与实现
date: 2018-02-02 14:44:09
description: 简单的分布式幂等注解的设计与实现
categories: Spring
tags: Spring
toc: true
author: Yan
comments: 
original: 
permalink: 
---

## 简单的分布式幂等注解的设计与实现

近几年，互联网后台都在朝着微服务化的方向发展，和传统的单项目相比，微服务化的后台，没了传统的数据库事物的支持，数据的一致性就显得尤为的重要。
要保证数据一致性，有很多方面需要注意，其中，最常见的就是接口的幂等。
分布式的环境，对网络的依赖比较严重，因此，一些网络异常的重试机制就理所应当的存在着，这时，如果不考虑接口的幂等性，那将会带来无穷的灾难。
幂等性是系统的接口对外一种承诺(而不是实现), 承诺只要调用接口成功, 外部多次调用对系统的影响是一致的。声明为幂等的接口会认为外部调用失败是常态, 并且失败之后必然会有重试.
保证接口的幂等呢个，要从两个方面入手：

     一.接口本身设计成幂等的（根据业务实现）;
     二.对接口做额外的幂等处理。
    
对于第一点，需要根据业务不同，具体设计实现，而对于第二点，则可以设计一个共同的方式处理。
以下是几种常见的方案：

1.MVCC方案

&nbsp;&nbsp;&nbsp;&nbsp;多版本并发控制，该策略主要使用update with condition（更新带条件来防止）来保证多次外部请求调用
对系统的影响是一致的。在系统设计的过程中，合理的使用乐观锁，通过version或者updateTime（timestamp）
等其他条件，来做乐观锁的判断条件，这样保证更新操作即使在并发的情况下，也不会有太大的问题。
例如：
select * from tablename where condition=#condition# //取出要跟新的对象，带有版本versoin
update tableName set name=#name#,version=version+1 where version=#version#
在更新的过程中利用version来防止，其他操作对对象的并发更新，导致更新丢失。为了避免失败，通常需要一定的重试机制。

2.去重表

&nbsp;&nbsp;&nbsp;&nbsp;在插入数据的时候，插入去重表，利用数据库的唯一索引特性，保证唯一的逻辑。

3.悲观锁

&nbsp;&nbsp;&nbsp;&nbsp;select for update，整个执行过程中锁定该订单对应的记录。注意：这种在DB读大于写的情况下尽量少用。

4.select + insert

&nbsp;&nbsp;&nbsp;&nbsp;并发不高的后台系统，或者一些任务JOB，为了支持幂等，支持重复执行，简单的处理方法是，先查询下一些关键数据，判断是否已经执行过，
在进行业务处理，就可以了。注意：核心高并发流程不要用这种方法。

5.状态机幂等

&nbsp;&nbsp;&nbsp;&nbsp;在设计单据相关的业务，或者是任务相关的业务，肯定会涉及到状态机，就是业务单据上面有个状态，状态在不同的情况下会发生变更，一般情况下存
在有限状态机，这时候，如果状态机已经处于下一个状态，这时候来了一个上一个状态的变更，理论上是不能够变更的，这样的话，保证了有限状态机的幂等。

6.token机制，防止页面重复提交

&nbsp;&nbsp;&nbsp;&nbsp;业务要求：页面的数据只能被点击提交一次.
&nbsp;&nbsp;&nbsp;&nbsp;发生原因：由于重复点击或者网络重发，或者nginx重发等情况会导致数据被重复提交. 
&nbsp;&nbsp;&nbsp;&nbsp;解决办法：<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;集群环境：采用token加redis（redis单线程的，处理需要排队）
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;单JVM环境：采用token加redis或token加jvm内存
&nbsp;&nbsp;&nbsp;&nbsp;处理流程：
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;数据提交前要向服务的申请token，token放到redis或jvm内存，token有效时间
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;提交后后台校验token，同时删除token，生成新的token返回
token特点:要申请，一次有效性，可以限流 

7.对外提供接口的api如何保证幂等 

&nbsp;&nbsp;&nbsp;&nbsp;如银联提供的付款接口：需要接入商户提交付款请求时附带：source来源，seq序列号。source+seq在数据库里面做唯一索引，防止多次付款，
(并发时，只能处理一个请求)
    
以上7中均为常见的幂等保证方式，今天我们就采用第7种做幂等处理。

直接上代码：

&nbsp;&nbsp;&nbsp;&nbsp;1.幂等切入的切点注解。

    /**
     * Created with Jingyan
     * Time: 2018-01-02 15:42
     * Description: 幂等注解
     */
    @Target(ElementType.METHOD)
    @Retention(RetentionPolicy.RUNTIME)
    @Documented
    public @interface Idempotent {
    
    }
    
&nbsp;&nbsp;&nbsp;&nbsp;2.切面，处理通知。

    /**
     * @Author: Jingyan
     * @Time: 2017-11-28 14:32
     * @Description:
     */
    @Aspect
    @Component
    @Order(-1)
    public class IdempotentAspect {
    
        private static Logger logger = LoggerFactory.getLogger(IdempotentAspect.class);
        //默认超时时间一天
        private static final int UUID_KEEP_TIME = 86400;
        //获取stringRedisTemplate
        private StringRedisTemplate stringRedisTemplate = SpringContainer.getBean(StringRedisTemplate.class);
    
        /**
         * Created with Jingyan
         * Time: 2018-01-25 14:39
         * Description: 切点
         */
        @Pointcut("@annotation(com.framework.distributed.idempotent.aop.Idempotent)")
        public void idempotentPointCut() {
            logger.debug("idempotentPointCut()");
        }
    
        /**
         * Created with Jingyan
         * Time: 2017-11-28 18:45
         * Description：切面
         */
        @Before("idempotentPointCut()")
        public void doBefore(JoinPoint joinPoin) {
            try {
                Object[] params = joinPoin.getArgs();
                if (null != params && params.length > 0) {
                    for (Object obj : params) {
                        if (obj instanceof BaseVo) {
                            BaseVo baseVo = (BaseVo) obj;
                            String newUuid = baseVo.getUuid();
                            if (null != newUuid && !"".equals(newUuid)) {
                                String oldUuid = this.stringRedisTemplate.opsForValue().getAndSet(newUuid, newUuid);
                                this.stringRedisTemplate.expire(newUuid, UUID_KEEP_TIME, TimeUnit.SECONDS);
                                logger.info("idempotent --- this time uuid = {} , and the last time uuid = {}", newUuid, oldUuid);
                                if (null == oldUuid || "".equals(oldUuid)) {
                                    baseVo.setNeedConsumer(true);
                                } else {
                                    baseVo.setNeedConsumer(false);
                                }
                            } else {
                                logger.info("idempotent --- uuid is null or empty...");
                            }
                        }
                    }
                }
            } catch (Exception e) {
                logger.error("幂等切面处理异常...");
                logger.error(e.getMessage());
            }
        }
    
    }
    
此种方案是通过全局的UUID来做，我们利用reids单线程的特点，以及getSet命令的原子性，替换了传统的数据库唯一索引方式，更加合理高效，再加之redis对过期的方便处理，使之成为一个
比较优的解决方案。对于RedisTemplate对象的获取，采用通过Class的方式，释放了对项目的约束性。

    private StringRedisTemplate stringRedisTemplate = SpringContainer.getBean(StringRedisTemplate.class);
    
接口的幂等性处理思想应该是一个程序员的基因，这是保证后台服务高效、稳定运行的基石，因此，设计接口时，多多考虑会事半功倍。
