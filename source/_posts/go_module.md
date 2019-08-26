---
title: go 1.11 之 moudule
date: 2019-08-26 20:39:00
categories: 
    - Go 语言
tags: 
    - Go 语言
    - moudule
    - go.mod
---

## 1 ）Go 1.11版本的意义
在Go 1.11版本之前的Go user官方调查中，Gopher抱怨最多的三大问题如下：

- 包依赖管理
- 缺少泛型
- 错误处理

而Go 1.11解决了第一个问题：包依赖管理解决的实验。

同时，Go 1.11是 Russ Cox 在GopherCon 2017 大会上发表 “Toward Go2″之后的第一个Go版本，也是为后续“Go2”的渐进落地奠定基础的一个版本。

Go 1.11 的改变有很多，这里主要介绍一下 go module。

## 2 ）go module
由于刚开始学 go 语言不久，前面接触的都是关于 go 的 `src，pkg，lib` 结构，但是在具体项目中，突然发现了一个 go.mod 文件，并且发现其中引用了 github 上的一份开源代码的 v1.0.3 版本，但是实际业务代码中的一个方法，在 v1.0.3 中不存在，导致项目启动报错，那么如何更改版本，go.mod 又是什么？下面查阅资料后简单记录一下。

简单来说，go module 是 go 1.11 以后新增的对依赖包的一种管理方法，个人感觉比原来的管理方式好用很多，我们都知道，go 刚开始的时候要求所有源码放入 GOPATH 中的 src 子目录下。

而现在，我们不必将项目代码放入 GOPATH 中，我们可以放入任何一个我们自己喜欢的文件夹下面，然后只需要使用 go module 就可以解决依赖的问题。具体可以参考如下：

现在我们看一下我们的 GOPATH：

```bash
$ go env | grep GOPATH
GOPATH="/Users/user/go"
```

然后我们随便找一个我们喜欢的目录：

```bash
$ pwd
/Users/user/workspace
```

这时我们 `git clone` 一个项目（处于隐私，某些信息用****代替）：

```bash
$ git clone git@git.****.com:devops/go-cmdb.git
Cloning into 'go-cmdb'...
remote: Counting objects: 453, done.
remote: Compressing objects: 100% (257/257), done.
remote: Total 453 (delta 149), reused 409 (delta 109)
Receiving objects: 100% (453/453), 14.86 MiB | 10.08 MiB/s, done.
Resolving deltas: 100% (149/149), done.
```

这时候我们 `go build` 我们的项目：

```bash
$ go build
/Users/user/go/src/go-cmdb/src/backend/routers/router.go:5:2: cannot find package "github.com/gin-contrib/cors" in any of:
	/usr/local/Cellar/go/1.12.6/libexec/src/github.com/gin-contrib/cors (from $GOROOT)
	/Users/user/go/src/github.com/gin-contrib/cors (from $GOPATH)
```

很明显，又是我们熟悉的报错，由于现在没有处在 GOPATH 路径下，所以结果正如我们所料。

现在我们使用 go module 试一下：

回到项目根目录，使用 go mod init 命令初始化一个 go.mod：

```bash
$ go mod init go-cmdb
go: creating new go.mod: module go-cmdb
$ ls
go.mod src
```

然后回到 main.go 下，重新 go build 一下：

```bash
$ go build
go: finding github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/clb/v20180317 latest
go: finding github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/common latest
... ...
```

OK了，依赖解决了，接下来我们看一下 go.mod，会发现每一个依赖后面都会有一个版本号，并且这个版本号一般都会滞后一点，一些新功能里面不支持，那我们相应对应的开源库中的最新的 master 分支上的代码怎么办？我们可以用 go get ... @master 来解决：

如：此时的 xlsx 的版本为 v1.0.3，该版本中的一些新功能不支持，我们可以将其更新：

```bash
cat go.mod | grep xlsx
	github.com/tealeg/xlsx v1.0.3
	
$ go get github.com/tealeg/xlsx@master
go: finding github.com/tealeg/xlsx master

$ cat go.mod | grep xlsx
	github.com/tealeg/xlsx v1.0.4-0.20190807182118-a6243d92b369
```

OK，先记这么多。

下面把一些常用命令记在这里：

go mod 有以下命令：

命令说明

**download**

download modules to local cache(下载依赖包)

**edit**

edit go.mod from tools or scripts（编辑go.mod



**graph**

print module requirement graph (打印模块依赖图)

**init**

initialize new module in current directory（在当前目录初始化mod）

**tidy**

add missing and remove unused modules(拉取缺少的模块，移除不用的模块)

**vendor**

make vendored copy of dependencies(将依赖复制到vendor下)

**verify**

verify dependencies have expected content (验证依赖是否正确）


**why**

explain why packages or modules are needed(解释为什么需要依赖)
