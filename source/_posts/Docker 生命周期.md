---
title: Docker 生命周期
date: 2019-08-23 18:38:45
categories: 
    - Docker
tags: 
    - Docker
    - 生命周期
---

## 1 ）相关概念
圆形 代表容器的五种状态：

- created：初建状态
- running：运行状态
- stopped：停止状态
- paused： 暂停状态
- deleted：删除状态

长方形 代表容器在执行某种命令后进入的状态：

- docker create  ： 创建容器后，不立即启动运行，容器进入初建状态；
- docker run     ： 创建容器，并立即启动运行，进入运行状态；
- docker start   ： 容器转为运行状态；
- docker stop    ： 容器将转入停止状态；
- docker kill    ： 容器在故障（死机）时，执行kill（断电），容器转入停止状态，这种操作容易丢失数据，除非必要，否则不建议使用；
- docker restart ： 重启容器，容器转入运行状态；
- docker pause   ： 容器进入暂停状态；
- docker unpause ： 取消暂停状态，容器进入运行状态；
- docker rm      ： 删除容器，容器转入删除状态（如果没有保存相应的数据库，则状态不可见）。

菱形 需要根据实际情况选择的操作

- killed by out-of-memory（因内存不足被终止）
 - 宿主机内存被耗尽，也被称为OOM：非计划终止
 - 这时需要杀死最吃内存的容器
 - 然后进行选择操作

- container process exited（异常终止）
 - 出现容器被终止后，将进入Should restart?选择操作：
 - yes 需要重启，容器执行start命令，转为运行状态。
 - no  不需要重启，容器转为停止状态。

## 2 ）生命周期图
图片里面大概描述了 Docker 整个的生命周期，具体再细节的话可能就要结合源码来分析了。
![](http://ww1.sinaimg.cn/large/006tNc79gy1g540jwerjmj31ja0mgdm5.jpg)
