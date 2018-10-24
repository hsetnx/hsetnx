---
layout: 
title: Elasticsearch
date: 2018-10-24 10:13:36
description: Elasticsearch 倒排索引
categories: [缓存,Elasticsearch]
tags: [缓存,Elasticsearch]
toc: true
author: Yan
comments: 
original: 
permalink: 
---

# Elasticsearch倒排索引

## 倒排索引的设计思路

发布清单（值和文档ID的映射）→ 术语（前缀）字典 → 字典再建索引 （B-Tree）→ 索引再通过有限状态机压缩存储 →  状态机的路径编号再进行增量压缩 →  搜索速度和内存的同步优化

![Alt text](https://raw.githubusercontent.com/Neway6655/neway6655.github.com/master/images/elasticsearch-study/inverted-index.png)

假设有这么几条数据:
ID是Elasticsearch自建的文档id，那么Elasticsearch建立的索引如下:
Name:
Age:
Sex:

### Posting List

Elasticsearch分别为每个field都建立了一个倒排索引，Kate, John, 24, Female这些叫term，而[1,2]就是Posting List。Posting list就是一个int的数组，存储了所有符合某个term的文档id。
看到这里，不要认为就结束了，精彩的部分才刚开始...
通过posting list这种索引方式似乎可以很快进行查找，比如要找age=24的同学，爱回答问题的小明马上就举手回答：我知道，id是1，2的同学。但是，如果这里有上千万的记录呢？如果是想通过name来查找呢？

### Term Dictionary

Elasticsearch为了能快速找到某个term，将所有的term排个序，二分法查找term，logN的查找效率，就像通过字典查找一样，这就是Term Dictionary。现在再看起来，似乎和传统数据库通过B-Tree的方式类似啊，为什么说比B-Tree的查询快呢？

### Term Index

B-Tree通过减少磁盘寻道次数来提高查询性能，Elasticsearch也是采用同样的思路，直接通过内存查找term，不读磁盘，但是如果term太多，term dictionary也会很大，放内存不现实，于是有了Term Index，就像字典里的索引页一样，A开头的有哪些term，分别在哪页，可以理解term index是一颗树：

![Alt text](https://raw.githubusercontent.com/Neway6655/neway6655.github.com/master/images/elasticsearch-study/term-index.png)

这棵树不会包含所有的term，它包含的是term的一些前缀。通过term index可以快速地定位到term dictionary的某个offset，然后从这个位置再往后顺序查找。

![Alt text](https://raw.githubusercontent.com/Neway6655/neway6655.github.com/master/images/elasticsearch-study/index.png)

但是索引本身也能很大，会产生2个问题：
1）.索引本身查找较慢
2）.索引本身很吃内存

这时需要建立 索引字典，能快速查找索引本身，同时，还要压缩索引本身大小。
    1.利用 有限状态机 拆解单词，然后按权重记录前缀的编号
    2.在对编号本身做增量压缩
这样，通过B树建立索引字典提高了索引本身的检索速度；
同时，通过分词，分字母，然后通过 有限状态机 压缩索引 前缀，在把状态机的序号进行增量压缩，大大减少了索引字典对内存的消耗。

![Alt text](https://raw.githubusercontent.com/Neway6655/neway6655.github.com/master/images/elasticsearch-study/fst.png)

Elasticsearch要求posting list是有序的，这样做的一个好处是方便压缩，看下面这个图例： 

![Alt text](https://raw.githubusercontent.com/Neway6655/neway6655.github.com/master/images/elasticsearch-study/frameOfReference.png)

增量压缩就是上面的方式：

73+227=300 

73+227+2=302

依此类推；



这样的结果就是：基于完备的索引，搜索查询很快；索引又做了存储的优化，内存不会严重消耗，双赢。