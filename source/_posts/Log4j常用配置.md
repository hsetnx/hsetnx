---
title: Log4j常用配置
date: 2017-02-23 19:01:46
description: Log4j常用配置
categories: Spring
tags: Spring
toc: true
author: Yan
comments: 
original: 
permalink: 
---

## Log4j常用配置


	# DEBUG,INFO,WARN,ERROR,FATAL
	# change in pom.xml

	log4j.rootLogger=DEBUG,CONSOLE,FILE

	log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
	log4j.appender.CONSOLE.Encoding=utf-8
	log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
	#log4j.appender.CONSOLE.layout.ConversionPattern=[%-5p] %d{yyyy-MM-dd HH:mm:ss} %C{1}@(%F:%L):%m%n
	log4j.appender.CONSOLE.layout.ConversionPattern=[core-erz] %-5p %d{yyyy-MM-dd HH:mm:ss,SSS} %c{1}.%M,%L : %m%n

	log4j.appender.FILE=org.apache.log4j.DailyRollingFileAppender
	## 绝对路径
	log4j.appender.FILE.File=/xx/xx/xx.log
	log4j.appender.FILE.Append=true
	log4j.appender.FILE.Encoding=utf-8
	log4j.appender.FILE.DatePattern='.'yyyy-MM-dd
	log4j.appender.FILE.layout=org.apache.log4j.PatternLayout
	#log4j.appender.FILE.layout.ConversionPattern=[%-5p] %d{yyyy-MM-dd HH\:mm\:ss} %C{8}@(%F\:%L)\:%m%n
	log4j.appender.FILE.layout.ConversionPattern=[core-erz] %-5p %d{yyyy-MM-dd HH:mm:ss,SSS} %c{1}.%M,%L : %m%n

	#for mybatis3
	log4j.logger.com.ibatis=DEBUG
	log4j.logger.com.ibatis.common.jdbc.SimpleDataSource=DEBUG
	log4j.logger.com.ibatis.common.jdbc.ScriptRunner=DEBUG
	log4j.logger.com.ibatis.sqlmap.engine.impl.SqlMapClientDelegate=DEBUG
	log4j.logger.java.sql.Connection=DEBUG
	log4j.logger.java.sql.Statement=DEBUG
	log4j.logger.java.sql.PreparedStatement=DEBUG
	log4j.logger.java.sql.ResultSet=DEBUG