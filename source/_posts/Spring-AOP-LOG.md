---
title: Spring AOP-LOG
date: 2018-02-01 19:25:40
tags: spring
comments: true
categories: spring
---
## Spring AOP-LOG
AOP是Spring的核心思想,但是我们自己编程却很少用到这个思想，其实这个听起来很抽象的概念，如果弄清楚了，用起来还是很方便的。
下面写个例子,可以体会下AOP做日志打印的便利之处。

	@Aspect
	@Component
	@Order(-5)
	public class LogAspect {

	    private static Logger logger = LoggerFactory.getLogger(LogAspect.class);
	    private static final String POINT_CUT = "execution(public * com..*.controller.*.*(..)) " +
	            "&& @annotation(org.springframework.web.bind.annotation.RequestMapping))";

	    /**
	     * Created with Jingyan
	     * Time: 2017-11-24 17:56
	     * Description:  日志打印切点
	     */
	    @Pointcut(POINT_CUT)
	    public void webLog() {

	    }

	    /**
	     * Created with Jingyan
	     * Time: 2017-12-18 9:37
	     * Description:  入参
	     */
	    @Before(value = "webLog()")
	    public void doBefore(JoinPoint joinPoint) {
	        try {
	            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
	            HttpServletRequest request = attributes.getRequest();
	            Enumeration<String> paramNames = request.getParameterNames();
	            Map<String, Object> map = new HashMap<>();
	            while (paramNames.hasMoreElements()) {
	                String paraName = paramNames.nextElement();
	                map.put(paraName, request.getParameter(paraName));
	            }
	            logger.info(" method={} 入参: param={}", joinPoint.getSignature().getDeclaringTypeName()
	                    + "."
	                    + joinPoint.getSignature().getName(), JsonUtil.toJson(map));
	        } catch (Exception e) {
	            logger.error(e.getMessage());
	        }
	    }

	    /**
	     * Created with Jingyan
	     * Time: 2017-12-18 9:37
	     * Description: 出参
	     */
	    @AfterReturning(value = "webLog()", returning = "retVal")
	    public void doAfterReturning(JoinPoint joinPoint, Object retVal) {
	        try {
	            logger.info(" method={} 出参: param={}", joinPoint.getSignature().getDeclaringTypeName()
	                    + "."
	                    + joinPoint.getSignature().getName(), JsonUtil.toJson(retVal));
	        } catch (Exception e) {
	            logger.error(e.getMessage());
	        }
	    }

	}

首先，定义一个切入点，即在 controller 包下并且有 RequestMapping 注解的方法；**
接着，对切点进行拦截，实现通知。

在Spring AOP中支持4中类型的通知：

	1：before advice 在方法执行前执行。
	2：after returning advice 在方法执行后返回一个结果后执行。
	3：after throwing advice 在方法执行过程中抛出异常的时候执行。
	4：around advice 环绕通知，在方法执行前后和抛出异常时执行，相当于综合了以上三种通知。

这样，一个简单的日志切面就写完了，核心思想就两步，1.定义切点；2.实现通知。