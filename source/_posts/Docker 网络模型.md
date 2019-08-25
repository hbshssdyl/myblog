---
title: Docker 网络模型
date: 2019-08-25 18:38:45
categories: 
    - Docker
tags: 
    - Docker
    - 网络模型
---

## 1 ）Bridge模式

当Docker进程启动时，会在主机上创建一个名为docker0的虚拟网桥，此主机上启动的Docker容器会连接到这个虚拟网桥上。虚拟网桥的工作方式和物理交换机类似，这样主机上的所有容器就通过交换机连在了一个二层网络中。

![image-20190727000914285](http://ww4.sinaimg.cn/large/006tNc79ly1g5doxm1yd1j30m80hywfm.jpg)

这里有个比较坑的地方，这个 Docker bridge模式的名字和桥接很像，但是实际上关系不大，Docker bridge模式有点像虚拟机中的 NAT 模式。

## 2 ）Host 模式

如果启动容器的时候使用host模式，那么这个容器将不会获得一个独立的Network Namespace，而是和宿主机共用一个Network Namespace。容器将不会虚拟出自己的网卡，配置自己的IP等，而是使用宿主机的IP和端口。但是，容器的其他方面，如文件系统、进程列表等还是和宿主机隔离的。

![image-20190727001343760](http://ww4.sinaimg.cn/large/006tNc79ly1g5dp2a5jaoj30m60het9i.jpg)

这个比较简单，感觉上去就是在网络层面没有隔离容器，当作一个进城来处理，只把其他资源隔离开。

## 3 ）Container模式

这个模式指定新创建的容器和已经存在的一个容器共享一个 Network Namespace，而不是和宿主机共享。新创建的容器不会创建自己的网卡，配置自己的 IP，而是和一个指定的容器共享 IP、端口范围等。同样，两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。两个容器的进程可以通过 lo 网卡设备通信。

![image-20190727001844391](http://ww4.sinaimg.cn/large/006tNc79ly1g5dp7hvmelj30lm0i23zp.jpg)

这里其实与 host 模式相比，就是又多划分了一个 namespace，然后将容器放入同一个namespace中，使其共享网络，但是其他资源是隔离的。

## 4 ）None 模式

使用none模式，Docker容器拥有自己的Network Namespace，但是，并不为Docker容器进行任何网络配置。也就是说，这个Docker容器没有网卡、IP、路由等信息。需要我们自己为Docker容器添加网卡、配置IP等。

![image-20190727002242982](http://ww4.sinaimg.cn/large/006tNc79ly1g5dpbnpl3uj30lu0i6q3j.jpg)

## 5 ）跨主机通信

**Pipework**

Pipework是一个简单易用的Docker容器网络配置工具。由200多行shell脚本实现。通过使用ip、brctl、ovs-vsctl等命令来为Docker容器配置自定义的网桥、网卡、路由等。

- 使用新建的bri0网桥代替缺省的docker0网桥
- bri0网桥与缺省的docker0网桥的区别：bri0和主机eth0之间是veth pair

这里我就不自己画图（偷懒贴一张网图）了，和前面的图很类似，只是将其中的docker0，更换成了自己的bri0，然后这样可以自己将bri0 和主机 eth0 之间设置成 veth pair，然后就能实现跨主机通信。

来一张网图：

![image-20190727002730161](http://ww1.sinaimg.cn/large/006tNc79ly1g5dpgn3n5zj30zo0u0kba.jpg)

其他模式还没有细看，就暂时不整理了，首先把Pipework弄清楚了。

k8s的网络模型也看了一下，和 Docker 几乎一样，所以很明显 Pipework 也可以用到k8s上，但是肯定会有优点和缺点，这一块还没有总结好，总结好后再整理一下。