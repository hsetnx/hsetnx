---
title: HashSet
date: 2017-02-23 18:34:21
description: java基础
categories: java
tags: java
toc: true
author: Yan
comments: 
original: 
permalink: 
---

##  HashSet 的实现

对于 HashSet 而言，它是基于 HashMap 实现的，HashSet 底层采用 HashMap 来保存所有
元素，因此 HashSet 的实现比较简单，查看 HashSet 的源代码，可以看到如下代码： 


	public class HashSet<E>
	        extends AbstractSet<E>
	        implements Set<E>, Cloneable, java.io.Serializable {
	        
	    // 使用 HashMap 的 key 保存 HashSet 中所有元素
	    private transient HashMap<E, Object> map;
	    // 定义一个虚拟的 Object 对象作为 HashMap 的 value 
	    private static final Object PRESENT = new Object();

	    // 初始化 HashSet，底层会初始化一个 HashMap 
	    public HashSet() {
	        map = new HashMap<E, Object>();
	    }

	    // 以指定的 initialCapacity、loadFactor 创建 HashSet 
	    // 其实就是以相应的参数创建 HashMap 
	    public HashSet(int initialCapacity, float loadFactor) {
	        map = new HashMap<E, Object>(initialCapacity, loadFactor);
	    }

	    public HashSet(int initialCapacity) {
	        map = new HashMap<E, Object>(initialCapacity);
	    }

	    HashSet(int initialCapacity, float loadFactor, boolean dummy) {
	        map = new LinkedHashMap<E, Object>(initialCapacity
	                , loadFactor);
	    }

	    // 调用 map 的 keySet 来返回所有的 key 
	    public Iterator<E> iterator() {
	        return map.keySet().iterator();
	    }

	    // 调用 HashMap 的 size() 方法返回 Entry 的数量，就得到该 Set 里元素的个数
	    public int size() {
	        return map.size();
	    }

	    // 调用 HashMap 的 isEmpty() 判断该 HashSet 是否为空，
	    // 当 HashMap 为空时，对应的 HashSet 也为空
	    public boolean isEmpty() {
	        return map.isEmpty();
	    }

	    // 调用 HashMap 的 containsKey 判断是否包含指定 key 
	    //HashSet 的所有元素就是通过 HashMap 的 key 来保存的
	    public boolean contains(Object o) {
	        return map.containsKey(o);
	    }

	    // 将指定元素放入 HashSet 中，也就是将该元素作为 key 放入 HashMap 
	    public boolean add(E e) {
	        return map.put(e, PRESENT) == null;
	    }

	    // 调用 HashMap 的 remove 方法删除指定 Entry，也就删除了 HashSet 中对应的元素
	    public boolean remove(Object o) {
	        return map.remove(o) == PRESENT;
	    }

	    // 调用 Map 的 clear 方法清空所有 Entry，也就清空了 HashSet 中所有元素
	    public void clear() {
	        map.clear();
	    }
	} 



由上面源程序可以看出，HashSet 的实现其实非常简单，它只是封装了一个 HashMap 对象来存储
所有的集合元素，所有放入HashSet中的集合元素实际上由HashMap的key来保存，而HashMap
的 value 则存储了一个 PRESENT，它是一个静态的 Object 对象。

HashSet 的绝大部分方法都是通过调用 HashMap 的方法来实现的，因此 HashSet 和 HashMap 两个集合在实现本质上是相同的。