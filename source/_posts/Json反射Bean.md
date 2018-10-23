---
title: Json反射Bean
date: 2018-10-23 13:33:20
tags: java
toc: true
author: Yan
comments: 
original: 
permalink: 
description: Json key和java field 不对应时反射序列化
---

#  Json反射Bean

## 新加注解，标记别名。

```
/**
 * Created with Jingyan
 * Time: 2018-10-19 18:33
 * Description: FIELD 别名注解
 */ 
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Alias {

    String name() default "";
}

```

## 增加工具类，通过反射找到匹配的field，并调用set方法

```
/**
 * @Author: Jingyan
 * @Time: 2018-10-19 17:15
 * @Description: class 的属性名 和 json的key值 不对应的转换，需要做映射，基于Alias注解
 */
public class JsonToBeanUtil {

    private static final Logger logger = LoggerFactory.getLogger(JsonToBeanUtil.class);
    private static final String GET = "get";
    private static final String SET = "set";

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:29
     * Description: LIST JSON 转 LIST Bean 基于 Alias 注解
     */
    public static <T> List<T> jsonToBean(List<JSONObject> jsonList, Class<T> clazz) {
        List<T> list = new ArrayList<>();
        try {
            Map<String, String> aliasMap = getAliasMapping(clazz);
            for (JSONObject jsonObject : jsonList) {
                Object object = clazz.newInstance();
                Set<String> keySet = jsonObject.keySet();
                for (String key : keySet) {
                    String fieldName = aliasMap.get(key);
                    setValue(object, clazz, fieldName, clazz.getDeclaredField(fieldName).getType(), jsonObject.get(key));
                }
                list.add((T) object);
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return list;
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:49
     * Description: 单个JSON 转 Bean
     */
    public static <T> T jsonToBean(JSONObject jsonObject, Class<T> clazz) {
        Object object = null;
        try {
            Map<String, String> aliasMap = getAliasMapping(clazz);
            object = clazz.newInstance();
            Set<String> keySet = jsonObject.keySet();
            for (String key : keySet) {
                String fieldName = aliasMap.get(key);
                if (null == fieldName || "".equals(fieldName)) {
                    throw new RuntimeException("json key [" + key + "]未匹配到bean的field...");
                } else {
                    setValue(object, clazz, fieldName, clazz.getDeclaredField(fieldName).getType(), jsonObject.get(key));
                }
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return (T) object;
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:49
     * Description: 单个 map 转 Bean
     */
    public static <T> T mapToBean(Map<String, Object> map, Class<T> clazz) {
        Object object = null;
        try {
            Map<String, String> aliasMap = getAliasMapping(clazz);
            object = clazz.newInstance();
            Set<String> keySet = map.keySet();
            for (String key : keySet) {
                String fieldName = aliasMap.get(key);
                if (null == fieldName || "".equals(fieldName)) {
                    throw new RuntimeException("map key [" + key + "]未匹配到bean的field...");
                } else {
                    setValue(object, clazz, fieldName, clazz.getDeclaredField(fieldName).getType(), map.get(key));
                }
            }
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return (T) object;
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-22 13:44
     * Description: 获取 alias-name 和 filed-name的映射
     */
    private static <T> Map<String, String> getAliasMapping(Class<T> clazz) {
        Field[] fields = clazz.getDeclaredFields();
        Map<String, String> map = new HashMap<>();
        for (Field field : fields) {
            Alias alias = field.getAnnotation(Alias.class);
            if (null == alias) {
                map.put(field.getName(), field.getName());
            } else {
                map.put(alias.name(), field.getName());
            }
        }
        return map;
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:25
     * Description: 调用set方法
     *
     * @Param: {
     * --- obj: Java对象实例;
     * --- clazz:obj.class;
     * --- filedName:set方法对应的属性名;
     * --- typeClass: 属性的类型;
     * --- value:属性要set的值
     * }
     */
    public static void setValue(Object obj, Class<?> clazz, String filedName, Class<?> typeClass, Object value) {
        try {
            String methodName = getSetMethodName(filedName, SET);
            if (null == methodName) {
                logger.error("属性[{}]set异常", filedName);
                return;
            }
            Method method = clazz.getDeclaredMethod(methodName, new Class[]{typeClass});
            method.invoke(obj, new Object[]{getClassTypeValue(typeClass, value)});
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:26
     * Description: 格式化名字，获取set方法名
     */
    public static String getSetMethodName(String filedName, String getSet) {
        if (null == filedName || "".equals(filedName)) {
            return null;
        }
        String methodName = SET + filedName.substring(0, 1).toUpperCase() + filedName.substring(1);
        return methodName;
    }

    /**
     * Created with Jingyan
     * Time: 2018-10-19 18:26
     * Description: 设置默认值
     */
    private static Object getClassTypeValue(Class<?> typeClass, Object value) {
        if (typeClass == int.class || typeClass == Integer.class) {
            if (null == value) {
                return 0;
            }
            return value;
        } else if (typeClass == short.class) {
            if (null == value) {
                return 0;
            }
            return value;
        } else if (typeClass == byte.class) {
            if (null == value) {
                return 0;
            }
            return value;
        } else if (typeClass == double.class) {
            if (null == value) {
                return 0;
            }
            return value;
        } else if (typeClass == long.class) {
            if (null == value) {
                return 0;
            }
            return value;
        } else if (typeClass == String.class) {
            if (null == value) {
                return "";
            }
            return String.valueOf(value);
        } else if (typeClass == boolean.class) {
            if (null == value) {
                return true;
            }
            return value;
        } else if (typeClass == BigDecimal.class) {
            if (null == value) {
                return new BigDecimal(0);
            }
            return new BigDecimal(value + "");
        } else {
            return typeClass.cast(value);
        }
    }
}
```

## 实际使用

```
    @Alias(name = "OrderID")
    private String orderId;
    @Alias(name = "UserID")
    private String userId;
    @Alias(name = "cityCode")
    private String cityCode;
    @Alias(name = "State")
    private String state;
```

```
public static <T> List<T> parseResponse(SearchResponse response, Class<T> clazz)throws Exception {
    List<T> list = new ArrayList<>();
    if (null != response.getHits() && response.getHits().getHits().length > 0) {
      for (SearchHit searchHit : response.getHits()) {
        Map<String, Object> hit = searchHit.getSourceAsMap();
        //map 转 对象
        T t = JsonToBeanUtil.mapToBean(hit,clazz);
        list.add(t);
      }
    }
    return list;
}
```

