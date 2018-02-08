---
title: Activiti+Spring配置
date: 2017-02-23 19:43:08
description: Activiti+Spring构建工作流平台
categories: Spring
tags: Spring
toc: true
author: Yan
comments: 
original: 
permalink: 
---

## Activiti+Spring配置(百度图片镇楼)

### 1.依赖的包（maven构建，其他Spring依赖的包不赘述了）


    <dependency>
      <groupId>org.activiti</groupId>
      <artifactId>activiti-engine</artifactId>
      <version>${activiti.version}</version>
    </dependency>
    <dependency>
      <groupId>org.activiti</groupId>
      <artifactId>activiti-spring</artifactId>
      <version>${activiti.version}</version>
    </dependency>
    <dependency>
      <groupId>org.activiti</groupId>
      <artifactId>activiti-json-converter</artifactId>
      <version>${activiti.version}</version>
    </dependency>
    
    
### 2.activiti.cfg.xml配置Activiti引擎，以及实例化7大接口（上图的接口）


		<!-- jingyan -->
		<?xml version="1.0" encoding="UTF-8"?>
		<beans xmlns="http://www.springframework.org/schema/beans"
		       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
		    <bean id="objectMapper" class="com.fasterxml.jackson.databind.ObjectMapper"/>
		    <bean id="processEngineConfiguration" class="org.activiti.spring.SpringProcessEngineConfiguration">
		    		<!-- Activiti第一次启动时会初始化自己的数据库，所以需要数据源 -->
		    		<!-- 如果自动创建表时，有索引外键之类的报错，请检查数据库驱动包的版本兼容性，我亲身经历过 -->
		        <property name="dataSource" ref="dataSource"/>
		        <property name="transactionManager" ref="transactionManager"/>
		        <property name="databaseSchemaUpdate" value="true"/>
		        <property name="jobExecutorActivate" value="false"/>
		        <!-- 配置部署缓存 可参考 API 实现自己的缓存 -->
		        <property name="processDefinitionCacheLimit" value="10"/>
		        <!-- 配置历史 -->
		        <property name="history" value="full"/>
		        <!-- mail配置，具体再配 -->
		        <property name="mailServerHost" value="xxx"/>
		        <property name="mailServerUsername" value="xxx"/>
		        <property name="mailServerPassword" value="xxx"/>
		        <property name="mailServerPort" value="xxx"/>
		        <!-- 批量发布流程 -->
		        <property name="deploymentResources">
		            <list>
		                <value>classpath*:/deployments/*</value>
		            </list>
		        </property>
		        <!-- 自动部署发布流程模板 单例模式 -->
		        <property name="deploymentMode" value="single-resource"/>
		    </bean>
		    <bean id="processEngine" class="org.activiti.spring.ProcessEngineFactoryBean">
		        <property name="processEngineConfiguration" ref="processEngineConfiguration"/>
		    </bean>
		    <!-- 7大接口 -->
		    <bean id="repositoryService" factory-bean="processEngine" factory-method="getRepositoryService"/>
		    <bean id="runtimeService" factory-bean="processEngine" factory-method="getRuntimeService"/>
		    <bean id="formService" factory-bean="processEngine" factory-method="getFormService"/>
		    <bean id="identityService" factory-bean="processEngine" factory-method="getIdentityService"/>
		    <bean id="taskService" factory-bean="processEngine" factory-method="getTaskService"/>
		    <bean id="historyService" factory-bean="processEngine" factory-method="getHistoryService"/>
		    <bean id="managementService" factory-bean="processEngine" factory-method="getManagementService"/>
		</beans>
		
		
		
Activiti-activiti-5.19.0 源码里面 MySql 初始化数据库的SQL如下：


	create table ACT_GE_PROPERTY (
	    NAME_ varchar(64),
	    VALUE_ varchar(300),
	    REV_ integer,
	    primary key (NAME_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	insert into ACT_GE_PROPERTY
	values ('schema.version', '5.18.0.1', 1);

	insert into ACT_GE_PROPERTY
	values ('schema.history', 'create(5.18.0.1)', 1);

	insert into ACT_GE_PROPERTY
	values ('next.dbid', '1', 1);

	create table ACT_GE_BYTEARRAY (
	    ID_ varchar(64),
	    REV_ integer,
	    NAME_ varchar(255),
	    DEPLOYMENT_ID_ varchar(64),
	    BYTES_ LONGBLOB,
	    GENERATED_ TINYINT,
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RE_DEPLOYMENT (
	    ID_ varchar(64),
	    NAME_ varchar(255),
	    CATEGORY_ varchar(255),
	    TENANT_ID_ varchar(255) default '',
	    DEPLOY_TIME_ timestamp(3),
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RE_MODEL (
	    ID_ varchar(64) not null,
	    REV_ integer,
	    NAME_ varchar(255),
	    KEY_ varchar(255),
	    CATEGORY_ varchar(255),
	    CREATE_TIME_ timestamp(3) null,
	    LAST_UPDATE_TIME_ timestamp(3) null,
	    VERSION_ integer,
	    META_INFO_ varchar(4000),
	    DEPLOYMENT_ID_ varchar(64),
	    EDITOR_SOURCE_VALUE_ID_ varchar(64),
	    EDITOR_SOURCE_EXTRA_VALUE_ID_ varchar(64),
	    TENANT_ID_ varchar(255) default '',
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_EXECUTION (
	    ID_ varchar(64),
	    REV_ integer,
	    PROC_INST_ID_ varchar(64),
	    BUSINESS_KEY_ varchar(255),
	    PARENT_ID_ varchar(64),
	    PROC_DEF_ID_ varchar(64),
	    SUPER_EXEC_ varchar(64),
	    ACT_ID_ varchar(255),
	    IS_ACTIVE_ TINYINT,
	    IS_CONCURRENT_ TINYINT,
	    IS_SCOPE_ TINYINT,
	    IS_EVENT_SCOPE_ TINYINT,
	    SUSPENSION_STATE_ integer,
	    CACHED_ENT_STATE_ integer,
	    TENANT_ID_ varchar(255) default '',
	    NAME_ varchar(255),
	    LOCK_TIME_ timestamp(3) NULL,
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_JOB (
	    ID_ varchar(64) NOT NULL,
	    REV_ integer,
	    TYPE_ varchar(255) NOT NULL,
	    LOCK_EXP_TIME_ timestamp(3) NULL,
	    LOCK_OWNER_ varchar(255),
	    EXCLUSIVE_ boolean,
	    EXECUTION_ID_ varchar(64),
	    PROCESS_INSTANCE_ID_ varchar(64),
	    PROC_DEF_ID_ varchar(64),
	    RETRIES_ integer,
	    EXCEPTION_STACK_ID_ varchar(64),
	    EXCEPTION_MSG_ varchar(4000),
	    DUEDATE_ timestamp(3) NULL,
	    REPEAT_ varchar(255),
	    HANDLER_TYPE_ varchar(255),
	    HANDLER_CFG_ varchar(4000),
	    TENANT_ID_ varchar(255) default '',
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RE_PROCDEF (
	    ID_ varchar(64) not null,
	    REV_ integer,
	    CATEGORY_ varchar(255),
	    NAME_ varchar(255),
	    KEY_ varchar(255) not null,
	    VERSION_ integer not null,
	    DEPLOYMENT_ID_ varchar(64),
	    RESOURCE_NAME_ varchar(4000),
	    DGRM_RESOURCE_NAME_ varchar(4000),
	    DESCRIPTION_ varchar(4000),
	    HAS_START_FORM_KEY_ TINYINT,
	    HAS_GRAPHICAL_NOTATION_ TINYINT,
	    SUSPENSION_STATE_ integer,
	    TENANT_ID_ varchar(255) default '',
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_TASK (
	    ID_ varchar(64),
	    REV_ integer,
	    EXECUTION_ID_ varchar(64),
	    PROC_INST_ID_ varchar(64),
	    PROC_DEF_ID_ varchar(64),
	    NAME_ varchar(255),
	    PARENT_TASK_ID_ varchar(64),
	    DESCRIPTION_ varchar(4000),
	    TASK_DEF_KEY_ varchar(255),
	    OWNER_ varchar(255),
	    ASSIGNEE_ varchar(255),
	    DELEGATION_ varchar(64),
	    PRIORITY_ integer,
	    CREATE_TIME_ timestamp(3),
	    DUE_DATE_ datetime(3),
	    CATEGORY_ varchar(255),
	    SUSPENSION_STATE_ integer,
	    TENANT_ID_ varchar(255) default '',
	    FORM_KEY_ varchar(255),
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_IDENTITYLINK (
	    ID_ varchar(64),
	    REV_ integer,
	    GROUP_ID_ varchar(255),
	    TYPE_ varchar(255),
	    USER_ID_ varchar(255),
	    TASK_ID_ varchar(64),
	    PROC_INST_ID_ varchar(64),
	    PROC_DEF_ID_ varchar(64),    
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_VARIABLE (
	    ID_ varchar(64) not null,
	    REV_ integer,
	    TYPE_ varchar(255) not null,
	    NAME_ varchar(255) not null,
	    EXECUTION_ID_ varchar(64),
	    PROC_INST_ID_ varchar(64),
	    TASK_ID_ varchar(64),
	    BYTEARRAY_ID_ varchar(64),
	    DOUBLE_ double,
	    LONG_ bigint,
	    TEXT_ varchar(4000),
	    TEXT2_ varchar(4000),
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_RU_EVENT_SUBSCR (
	    ID_ varchar(64) not null,
	    REV_ integer,
	    EVENT_TYPE_ varchar(255) not null,
	    EVENT_NAME_ varchar(255),
	    EXECUTION_ID_ varchar(64),
	    PROC_INST_ID_ varchar(64),
	    ACTIVITY_ID_ varchar(64),
	    CONFIGURATION_ varchar(255),
	    CREATED_ timestamp(3) not null DEFAULT CURRENT_TIMESTAMP(3),
	    PROC_DEF_ID_ varchar(64),
	    TENANT_ID_ varchar(255) default '',
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_EVT_LOG (
	    LOG_NR_ bigint auto_increment,
	    TYPE_ varchar(64),
	    PROC_DEF_ID_ varchar(64),
	    PROC_INST_ID_ varchar(64),
	    EXECUTION_ID_ varchar(64),
	    TASK_ID_ varchar(64),
	    TIME_STAMP_ timestamp(3) not null,
	    USER_ID_ varchar(255),
	    DATA_ LONGBLOB,
	    LOCK_OWNER_ varchar(255),
	    LOCK_TIME_ timestamp(3) null,
	    IS_PROCESSED_ tinyint default 0,
	    primary key (LOG_NR_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create table ACT_PROCDEF_INFO (
		ID_ varchar(64) not null,
	    PROC_DEF_ID_ varchar(64) not null,
	    REV_ integer,
	    INFO_JSON_ID_ varchar(64),
	    primary key (ID_)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_bin;

	create index ACT_IDX_EXEC_BUSKEY on ACT_RU_EXECUTION(BUSINESS_KEY_);
	create index ACT_IDX_TASK_CREATE on ACT_RU_TASK(CREATE_TIME_);
	create index ACT_IDX_IDENT_LNK_USER on ACT_RU_IDENTITYLINK(USER_ID_);
	create index ACT_IDX_IDENT_LNK_GROUP on ACT_RU_IDENTITYLINK(GROUP_ID_);
	create index ACT_IDX_EVENT_SUBSCR_CONFIG_ on ACT_RU_EVENT_SUBSCR(CONFIGURATION_);
	create index ACT_IDX_VARIABLE_TASK_ID on ACT_RU_VARIABLE(TASK_ID_);
	create index ACT_IDX_ATHRZ_PROCEDEF on ACT_RU_IDENTITYLINK(PROC_DEF_ID_);
	create index ACT_IDX_INFO_PROCDEF on ACT_PROCDEF_INFO(PROC_DEF_ID_);

	alter table ACT_GE_BYTEARRAY
	    add constraint ACT_FK_BYTEARR_DEPL 
	    foreign key (DEPLOYMENT_ID_) 
	    references ACT_RE_DEPLOYMENT (ID_);

	alter table ACT_RE_PROCDEF
	    add constraint ACT_UNIQ_PROCDEF
	    unique (KEY_,VERSION_, TENANT_ID_);
	    
	alter table ACT_RU_EXECUTION
	    add constraint ACT_FK_EXE_PROCINST 
	    foreign key (PROC_INST_ID_) 
	    references ACT_RU_EXECUTION (ID_) on delete cascade on update cascade;

	alter table ACT_RU_EXECUTION
	    add constraint ACT_FK_EXE_PARENT 
	    foreign key (PARENT_ID_) 
	    references ACT_RU_EXECUTION (ID_);
	    
	alter table ACT_RU_EXECUTION
	    add constraint ACT_FK_EXE_SUPER 
	    foreign key (SUPER_EXEC_) 
	    references ACT_RU_EXECUTION (ID_);

	alter table ACT_RU_EXECUTION
	    add constraint ACT_FK_EXE_PROCDEF 
	    foreign key (PROC_DEF_ID_) 
	    references ACT_RE_PROCDEF (ID_);
	    
	alter table ACT_RU_IDENTITYLINK
	    add constraint ACT_FK_TSKASS_TASK 
	    foreign key (TASK_ID_) 
	    references ACT_RU_TASK (ID_);
	    
	alter table ACT_RU_IDENTITYLINK
	    add constraint ACT_FK_ATHRZ_PROCEDEF 
	    foreign key (PROC_DEF_ID_) 
	    references ACT_RE_PROCDEF(ID_);
	    
	alter table ACT_RU_IDENTITYLINK
	    add constraint ACT_FK_IDL_PROCINST
	    foreign key (PROC_INST_ID_) 
	    references ACT_RU_EXECUTION (ID_);       
	    
	alter table ACT_RU_TASK
	    add constraint ACT_FK_TASK_EXE
	    foreign key (EXECUTION_ID_)
	    references ACT_RU_EXECUTION (ID_);
	    
	alter table ACT_RU_TASK
	    add constraint ACT_FK_TASK_PROCINST
	    foreign key (PROC_INST_ID_)
	    references ACT_RU_EXECUTION (ID_);
	    
	alter table ACT_RU_TASK
	  	add constraint ACT_FK_TASK_PROCDEF
	  	foreign key (PROC_DEF_ID_)
	  	references ACT_RE_PROCDEF (ID_);
	  
	alter table ACT_RU_VARIABLE 
	    add constraint ACT_FK_VAR_EXE 
	    foreign key (EXECUTION_ID_) 
	    references ACT_RU_EXECUTION (ID_);

	alter table ACT_RU_VARIABLE
	    add constraint ACT_FK_VAR_PROCINST
	    foreign key (PROC_INST_ID_)
	    references ACT_RU_EXECUTION(ID_);

	alter table ACT_RU_VARIABLE 
	    add constraint ACT_FK_VAR_BYTEARRAY 
	    foreign key (BYTEARRAY_ID_) 
	    references ACT_GE_BYTEARRAY (ID_);

	alter table ACT_RU_JOB 
	    add constraint ACT_FK_JOB_EXCEPTION 
	    foreign key (EXCEPTION_STACK_ID_) 
	    references ACT_GE_BYTEARRAY (ID_);

	alter table ACT_RU_EVENT_SUBSCR
	    add constraint ACT_FK_EVENT_EXEC
	    foreign key (EXECUTION_ID_)
	    references ACT_RU_EXECUTION(ID_);
	    
	alter table ACT_RE_MODEL 
	    add constraint ACT_FK_MODEL_SOURCE 
	    foreign key (EDITOR_SOURCE_VALUE_ID_) 
	    references ACT_GE_BYTEARRAY (ID_);

	alter table ACT_RE_MODEL 
	    add constraint ACT_FK_MODEL_SOURCE_EXTRA 
	    foreign key (EDITOR_SOURCE_EXTRA_VALUE_ID_) 
	    references ACT_GE_BYTEARRAY (ID_);
	    
	alter table ACT_RE_MODEL 
	    add constraint ACT_FK_MODEL_DEPLOYMENT 
	    foreign key (DEPLOYMENT_ID_) 
	    references ACT_RE_DEPLOYMENT (ID_);        

	alter table ACT_PROCDEF_INFO 
	    add constraint ACT_FK_INFO_JSON_BA 
	    foreign key (INFO_JSON_ID_) 
	    references ACT_GE_BYTEARRAY (ID_);

	alter table ACT_PROCDEF_INFO 
	    add constraint ACT_FK_INFO_PROCDEF 
	    foreign key (PROC_DEF_ID_) 
	    references ACT_RE_PROCDEF (ID_);
	    
	alter table ACT_PROCDEF_INFO
	    add constraint ACT_UNIQ_INFO_PROCDEF
	    unique (PROC_DEF_ID_);
    
    		
### 3.设计工作流模板

	根据具体业务自行设计（需要提前学习 BPMN2.0 规范）
	
### 4.调用接口，启用流程。（部署可选手动发布，也可以随着项目启动自动部署）


	import net.sf.json.JSONObject;
	import org.activiti.engine.*;
	import org.activiti.engine.repository.Deployment;
	import org.activiti.engine.runtime.ProcessInstance;
	import org.activiti.engine.task.Task;
	import org.slf4j.Logger;
	import org.slf4j.LoggerFactory;
	import org.springframework.beans.factory.annotation.Autowired;
	import org.springframework.stereotype.Service;
	import org.springframework.transaction.annotation.Propagation;
	import org.springframework.transaction.annotation.Transactional;
	import java.util.ArrayList;
	import java.util.List;
	import java.util.Map;

	/**
	 * Created by jingyan on 2016/8/23.
	 * activiti 主要接口，提供：
	 * 启动任务、
	 * 查询自己代办任务、
	 * 查询运行中 和 已完成流程、
	 * 签收任务、
	 * 完成任务、
	 * 查询任务详细数据。
	 */
	@Service
	public class ActWorkFlowServiceImp implements ActWorkFlowService {

	    private static Logger logger = LoggerFactory.getLogger(ActWorkFlowServiceImp.class);

	    @Autowired
	    private ProcessEngine processEngine;
	    @Autowired
	    private RuntimeService runtimeService;
	    @Autowired
	    protected TaskService taskService;
	    @Autowired
	    protected HistoryService historyService;
	    @Autowired
	    protected RepositoryService repositoryService;
	    @Autowired
	    private IdentityService identityService;

	    /**
	     * Created with: jingyan.
	     * Date: 2016/10/17  10:33
	     * Description: 手动部署工作流
	     */
	    @Transactional(rollbackFor = Exception.class, readOnly = false, propagation = Propagation.REQUIRED)
	    public JSONObject deployWorkflow(String deploymentName, String bpmnFileName) {
	        String resPath = ConstantCode.BPMN_PATH + bpmnFileName;
	        logger.info("工作流手动部署,资源路径：" + resPath);
	        Deployment deployment = processEngine.getRepositoryService().createDeployment().name(deploymentName).addClasspathResource(resPath).deploy();
	        if (!PubMethod.isEmpty(deployment)) {
	            logger.info("流程部署成功：ID=" + deployment.getId() + "   ,NAME=" + deployment.getName());
	            return ReturnUtil.createJSON(ReturnCode.REQ_SUCCESS.getCode(), "部署成功", deployment.getId());
	        }
	        return ReturnUtil.createJSON(ReturnCode.REQ_PARAM_ERROR.getCode(), "部署失败", "");
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/8/24  9:52
	     * Description: 启动工作流
	     * param: processDefinitionKey --- 流程文件定义KEY
	     */
	    @Transactional(rollbackFor = Exception.class, readOnly = false, propagation = Propagation.REQUIRED)
	    public JSONObject startActWorkFlow(String businessKey, String userId, String businessType, String jsonParamStr) {
	        logger.info("启动任务入参[businessKey:" + businessKey + ",userId:" + businessKey + ",jsonParamStr:" + jsonParamStr + "]");
	        try {
	            List<Task> listTask = getTasksByBusKey(businessKey);
	            if (!PubMethod.isEmpty(listTask)) {
	                logger.info("业务数据：" + businessKey + "的任务已存在.");
	                return ReturnUtil.createJSON(ReturnCode.REQ_PARAM_ERROR.getCode(), "该业务已存在审批中的数据", "");
	            }
	            JSONObject js = JSONObject.fromObject(jsonParamStr);
	            Map<String, Object> map = PubMethod.json2Map(js);
	            // 设置启动人员ID (DB： ACT_HI_PROCINST → START_USER_ID_）
	            identityService.setAuthenticatedUserId(userId);
	            String processDefKey = ProcessDefKeyEnum.valueOf(Integer.parseInt(businessType)).getProcessDefKey();
	            runtimeService.startProcessInstanceByKey(processDefKey, businessKey, map);
	            List<Task> tasks = getTasksByBusKey(businessKey);
	            if (PubMethod.isEmpty(tasks)) {
	                return ReturnUtil.createJSON(ReturnCode.BUES_DEAL_ERROR.getCode(), "启动失败", "");
	            }
	            List<UserTaskVo> list = handleUserTask(tasks, businessKey);
	            ResponseVo responseVo = new ResponseVo();
	            responseVo.setUserTaskVos(list);
	            return ReturnUtil.createJSONList(ReturnCode.REQ_SUCCESS.getCode(), "启动成功", responseVo);
	        } finally {
	            identityService.setAuthenticatedUserId(null);
	        }
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/8/24  11:11
	     * Description: 签收任务
	     */
	    @Transactional(rollbackFor = Exception.class, readOnly = false, propagation = Propagation.REQUIRED)
	    public JSONObject signforTask(String businessKey, String userId) {
	        logger.info("签收任务入参[businessKey:" + businessKey + ",userId:" + userId + "]");
	        List<Task> listTask = getTasksByCandidateUser(businessKey, userId);
	        if (PubMethod.isEmpty(listTask)) {
	            logger.info("签收-未查询到：" + businessKey + "的任务");
	            return ReturnUtil.createJSON(ReturnCode.REQ_PARAM_ERROR.getCode(), "您无权处理该笔数据", "");
	        }
	        if (listTask.size() != 1) {
	            logger.info("签收-业务主键：" + businessKey + "的任务不唯一");
	            return ReturnUtil.createJSON(ReturnCode.BUES_DEAL_ERROR.getCode(), "该笔业务异常", "");
	        }
	        taskService.claim(listTask.get(0).getId(), userId);
	        List<Task> tasks = getTasksByBusKey(businessKey);
	        if (PubMethod.isEmpty(tasks)) {
	            return ReturnUtil.createJSON(ReturnCode.BUES_DEAL_ERROR.getCode(), "签收失败", "");
	        }
	        List<UserTaskVo> list = handleUserTask(tasks, businessKey);
	        ResponseVo responseVo = new ResponseVo();
	        responseVo.setUserTaskVos(list);
	        return ReturnUtil.createJSONList(ReturnCode.REQ_SUCCESS.getCode(), "签收成功", responseVo);
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/8/24  11:11
	     * Description: 提交任务
	     */
	    @Transactional(rollbackFor = Exception.class, readOnly = false, propagation = Propagation.REQUIRED)
	    public JSONObject completeTask(String businessKey, String userId, String jsonParamStr) {
	        logger.info("提交任务入参[businessKey:" + businessKey + ",userId:" + userId + ",jsonParamStr:" + jsonParamStr + "]");
	        List<Task> listTask = getTasksByAssignee(businessKey, userId);
	        if (PubMethod.isEmpty(listTask)) {
	            logger.info("提交-未查询到：" + businessKey + "的任务");
	            return ReturnUtil.createJSON(ReturnCode.REQ_PARAM_ERROR.getCode(), "提交的任务不存在", "");
	        }
	        if (listTask.size() != 1) {
	            logger.info("提交-业务主键：" + businessKey + "的任务不唯一");
	            return ReturnUtil.createJSON(ReturnCode.BUES_DEAL_ERROR.getCode(), "该笔业务异常", "");
	        }
	        JSONObject js = JSONObject.fromObject(jsonParamStr);
	        Map<String, Object> map = PubMethod.json2Map(js);
	        taskService.complete(listTask.get(0).getId(), map);
	        List<Task> tasks = getTasksByBusKey(businessKey);
	        if (PubMethod.isEmpty(tasks)) {
	            if (null == js.get("fkwc_result")) {
	                return ReturnUtil.createJSON(ReturnCode.BUES_DEAL_ERROR.getCode(), "提交失败", "");
	            } else {
	                return ReturnUtil.createJSON(ReturnCode.REQ_SUCCESS.getCode(), "success", "");
	            }

	        }
	        List<UserTaskVo> list = handleUserTask(tasks, businessKey);
	        ResponseVo responseVo = new ResponseVo();
	        responseVo.setUserTaskVos(list);
	        return ReturnUtil.createJSONList(ReturnCode.REQ_SUCCESS.getCode(), "提交成功", responseVo);
	    }

			/**
	     * Created with: jingyan.
	     * Date: 2016/8/24  11:11
	     * Description: 挂起任务
	     */
	    @Transactional(rollbackFor = Exception.class, readOnly = false, propagation = Propagation.REQUIRED)
	    public JSONObject suspendProcess(String businessKey) {
	        ProcessInstance processInstance = runtimeService.createProcessInstanceQuery().processInstanceBusinessKey(businessKey).singleResult();
	        if (null == processInstance) {
	            return ReturnUtil.createJSON(ReturnCode.REQ_PARAM_ERROR.getCode(), "工作流未查询到业务数据", "");
	        }
	        runtimeService.suspendProcessInstanceById(processInstance.getProcessInstanceId());
	        return ReturnUtil.createJSON(ReturnCode.REQ_SUCCESS.getCode(), "success", null);
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/10/19  20:09
	     * Description: 根据 业务主键 获取任务实例
	     */
	    public List<Task> getTasksByBusKey(String businessKey) {
	        List<Task> tasks = taskService.createTaskQuery().processInstanceBusinessKey(businessKey).list();
	        return tasks;
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/10/19  20:09
	     * Description: 根据 业务主键 + 候选人 获取任务实例
	     */
	    public List<Task> getTasksByCandidateUser(String businessKey, String userId) {
	        List<Task> tasks = taskService.createTaskQuery().processInstanceBusinessKey(businessKey).taskCandidateUser(userId).list();
	        return tasks;
	    }

	    /**
	     * Created with: jingyan.
	     * Date: 2016/10/19  20:09
	     * Description: 根据 业务主键 + 签收人 获取任务实例
	     */
	    public List<Task> getTasksByAssignee(String businessKey, String userId) {
	        List<Task> tasks = taskService.createTaskQuery().processInstanceBusinessKey(businessKey).taskAssignee(userId).list();
	        return tasks;
	    }
	}


### 5.配置 ServiceTask （如需要）


	<serviceTask activiti:class="com.xx.activiti.servicetask.ApprovalServiceTask" activiti:exclusive="true" id="xx" name="serviceTask"/>
	
	
	