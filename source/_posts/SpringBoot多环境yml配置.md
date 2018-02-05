---
layout: w
title: SpringBoot多环境yml配置
date: 2018-02-05 11:48:29
tags: [SpringBoot,yml]
comments: true
categories: Spring
---
## SpringBoot多环境yml配置

通常情况下，我们的Spring boot项目都会涉及多个环境的部署，例如最基本的开发、测试、预生产、生产。这种情况下，我们依赖的一些外部组件的配置往往是不同的，例如DB、接口、ZK等，这样就需要我们根据不同环境选择不同的配置文件。在springboot之前，我们通常都是通过pom配置多个profile，然后打包时动态替换配置文件的参数，但是，在有了spring boot之后，还有一种更方便办法，就是在项目启动时，根据环境动态选择不同的配置文件。

给个例子：

	spring:
	  profiles:
	    active: test
	# spring environment --- 分区
	# java -jar distributed-idempotent.jar --spring.profiles.active=dev
	# java -jar distributed-idempotent.jar --spring.profiles.active=test
	---
	spring:
	  profiles: dev
	  redis:
	    host: 0.0.0.0
	    port: 6379
	    password: ****
	    pool:
	      max-active: 8
	      max-wait: 1
	      max-idle: 8
	      min-idle: 0
	logging:
	  path: /usr/local/logs/distributed-idempotent/
	  level:
	    root: INFO
	---
	spring:
	  profiles: test
	  redis:
	    host: 0.0.0.0
	    port: 6379
	    password: ****
	    pool:
	      max-active: 8
	      max-wait: 1
	      max-idle: 8
	      min-idle: 0
	logging:
	  path: /usr/local/logs/distributed-idempotent/
	  level:
	    root: DEBUG

在yml文件中三个短横线（---）代表分区，这样，我们就可以将一个yml文件根据部署环境的数量，分成若干个区，然后在每个区做单独的配置，就成了如上的效果；2个区（dev，test）,然后分别配置这个环境的信息。这样的好处是，一个配置文件，可以配置不同环境的信息，方便维护。这是有人就问了，既然一个配置文件加载了多个环境的配置信息，那么项目怎么选择启动哪个环境呢？其实很简单，首先是默认环境。怎么指定默认环境呢，上面的配置文件已经有指定的方式了，就是如下的配置：

	spring:
	  profiles:
	    active: test

这个配置表示默认加载测试环境的配置信息。这个没问题了，新的问题又出现了，那我要指定用开发环境呢？只能修改active项的配置？答案是不用，不用这么麻烦。默认只是一种规定，可以写死，但是部署的动作是活的，没法指定的，这时，我们就需要在环境加载时选择环境，因此，放在启动命令执行时就最合适不过了。那么怎么在启动时选择加载呢？
例子如下：

	
	java -jar distributed-idempotent.jar --spring.profiles.active=dev

这行shell表示启动一个当前目录下，名字为distributed-idempotent.jar的jar包，然后选择启动spring的环境，环境配置的名字为dev,即本次项目启动加载开发环境的配置文件，这样就替换了默认的测试环境，方便简单。