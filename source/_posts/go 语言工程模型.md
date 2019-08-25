---
title: Go 语言工程模型
date: 2019-08-24 18:38:45
categories: 
    - Go 语言
tags: 
    - Go 语言
    - 工程模型
---

Golang工程结构，从宏观方面来说分为两部分，根空间(GOROOT)和工作空间(GOPATH)。 其中根空间也就是 GOROOT 是 go 的安装目录，用来搜寻和加载 go 的工具链，例如执行 go build，go fmt 等等。 而GOPATH 是你的工作空间，也就是放置 go 代码的地方。

每个工作空间里面一定会存在三个目录: src，pkg和bin。

```bash
GOPATH/
       ├── bin
       ├── pkg
       └── src
```

这三个目录中，只有src目录是必须要存在的。 而pkg和bin这两个目录，go在涉及到时会自动创建。

pkg目录则用来放置生成的静态链接库。而最后的bin目录就用来放置构建出来的可执行的二进制工具。

## 1. src目录
src 目录用来存放所有的源代码，这些源代码有可能是你自己写的，也有可能是别人写的。src 用于以代码包的形式组织并保存 Go **源码文件**，这里的代码包与 src 下的子目录一一对应。

例如，若一个源码文件被声明属于代码包 log，那么它就应该保存在`src/log` 目录下。

当然，你也可以直接把Go源码文件直接放在src目录下，但这样的Go源码文件就只能被声明属于main代码包。除非用于临时测试或演示，一般还是建议把Go源码文件放入特定的代码包中。

### 源码文件

####（1）命令源码文件
如果一个源码文件被声明属于main代码包，且该文件代码中包含无参数声明和结果声明的main函数，则它就是命令源码文件。

命令源码文件可以直接通过 go run 命令直接启动运行。

同一个代码中的所有的源码文件，其所属代码包的名称必须一致。如果命令源码文件和库源码文件处于同一个代码包中，那么在该包中就无法正确执行 go build 和 go install 命令。

换句话说，这些源码文件将无法通过常规方法编译和安装。

因此，命令源码文件通常会单独放在一个代码包中，因为通常一个程序模块或软件的启动入口只有一个。

####（2）库源码文件
通常，库源码文件声明的包名会与它直接所属的代码包一致，且库源码文件中不包含无参数声明和无结果声明的main函数。

####（3）测试源码文件
测试源码文件是一种特殊的库文件，可以通过执行 go test 命令运行当前代码包下的所有测试源码文件。

成为测试源码文件的充分条件有两个：

1. 文件名需要以 "_test.go" 结尾，如 `login_test.go`。
2. 文件中需要至少包含一个名称以Test开头或Benchmark开头，且拥有一个类型为`*testing.T`或`*testing.B`的参数的函数。

`*testing.T` 或 `*testing.B` 是两个结构体类型。而`*testing.T` 或 `*testing.B` 则分别为前两者的指针类型。它们分别是功能测试和基准测试所需。

当在一个代码包中执行 go test 命令时，该代码包中的所有测试源码文件会被找到并运行。

## 2. pkg目录
用于存放通过go install命令安装后的代码包的归档文件。
前提是代码包中必须包含Go库源码文件。归档文件是指那些名称以“.a”结尾的文件。
该目录与GOROOT目录下的pkg目录功能类似。
区别在于，工作区中的pkg目录专门用来存放用户代码的归档文件。
编译和安装用户代码的过程一般会以代码包为单位进行。
比如log包被编译安装后，将生成一个名为log.a的归档文件，并存放在当前工作区的pkg目录下的平台相关目录中。


## 3. bin目录
与pkg目录类似，在通过go install命令完成安装后，保存由Go命令源码文件生成的可执行文件。
（其实上面文字的意思就是什么类型的文件放在什么目录下面，尽量规划好工作区）

命令源码文件：就是声明属于main代码包并包含无参声明和结果声明的main函数的源码文件。
这类源码文件就是程序的入口，它们可以独立运行（使用go run命令），
也可以通过go build或go install命令得到相应的可执行文件。

库源码文件：是指存在于某个代码包中普通源码文件。

## 4. src 目录之 Project Layout

Go 没有对项目的 layout 有硬性规定，也没有官方版本的 best practice，这里记录一种比较流行的方式：有兴趣的请看[源码地址](https://github.com/golang-standards/project-layout)

### 1 ) Go 相关目录

`cmd/`

一般来说，如果不是库函数，项目最终都会编译成 1 个或多个二进制可执行文件，每个可执行文件都会对应到一个 main()，而这些可执行文件的入口代码可认为都是一个 application。

cmd/ 就是用来放这些 application 代码，每个 application 都应对应到 cmd/ 的某个子目录下，比如我这个项目将生成 app1，app2 和 app3，那么目录结构就应该为：

```bash
go-project
└── cmd
    ├── app1
    ├── app2
    └── app3
```

应该注意的一点：不宜在 cmd/ 下放过多代码。如果你觉得你的某些代码可公开复用，应放置于 pkg/ 目录中，否则可放置于 internal/ 目录中。

一个好的工程习惯是：尽可能保持 cmd/ 下的 application 代码，即 main() 入口函数的简单，通过调用其他工程目录下的代码（比如 pkg/ 和 internal/） 来串联整个逻辑。

`internal/`

私有的 application 或者库代码（不希望 package 的接口被扩散到同层目录以外的空间中）。该目录下的代码受限于 Go internal package 机制的限制（见下文），只能被 internal/ 下同层代码所引用。

`pkg/`

用来放置库代码，可被项目内部或外部引用。注意和 GOPATH 路径下的 pkg 作区分。

`vendor/`

项目依赖代码。vendor/ 下放置着依赖代码的一个副本。如果项目是库代码，则无需提交依赖代码。

### 2 ) Service 应用相关目录

`api/`

一般用来放着 OpenAPI/Swagger 的 spec、JSON 的 schema 文件或者 protocol 的定义。可参考 kubernetes/api。

### 3 ) Web 应用相关目录

`web/`

Web application 相关的组件，比如静态资源、服务端模版等。

### 4 ) 通用目录

`configs/`

配置文件或者模版文件。

`init/`

系统初始化（如 systemd，upstart，sysv）和进程管理（如 runit，supervisord）相关工具的配置。

`scripts/`

构建，安装，分析等相关操作的脚本。

`build/`

打包（packaging）和 CI 相关文件。比如 Docker，OS（deb，rpm，pkg）相关的配置和脚本文件可放在 build/package 目录下，而 CI （travis，drone 等）相关文件可放置 build/ci 目录下。

`deployments/`

IaaS，PaaS 或者容器编排系统的配置和模版文件。

`test/`

额外的测试应用和测试数据，如 test/data。

### 5 ) 其他一些目录

`docs/`

设计或者用户文档。

`tools/`

项目相关的一些 tool，其代码可引用 pkg/ 和 internal/ 目录下的 package。

`examples/`

项目（应用或者库）相关的示例代码。

`third_party/`

外部的第三方工具、代码或其他组件。

`hack/`

放置一些跟项目相关的 hack 工具。

`githooks/`

放置 Git hooks。

`assets/`

项目相关的其他资源依赖。

### 6 ) 其他注意事项

- 搞清楚 Go 的 workspace 机制

Go 会将所有的代码放在一个单一的 workspace 中，其路径以 GOPATH 环境变量指定，所以你可以将你的代码放在 src 目录下，如

```bash
$GOPATH/src/github.com/your_github_username/your_project：绝对路径，推荐使用；
$GOPATH/src/your_project：相对路径，可以用，但不推荐；
```

- `internal/` 的设计

Go 鼓励使用者将程序分成 package 并暴露 API。但随着项目的膨胀，拆分 package 将会把一些不必要的 API 暴露在整个项目中。为解决这个问题，从 Go 1.4 开始，Go 提供了 internal package 机制。

根据 internal package 机制：只能在 `internal/` 的父目录下引用 `internal/` 下的 `package`。例如：

在 `/a/b/c/internal/d/e/f` 下的代码只能在 `/a/b/c` 下的代码使用，无法在 `/a/b/g` 下使用；

`$GOROOT/src/pkg/net/http/internal` 只能在 `net/http` 或者 `net/http/*` 下使用；

`$GOPATH/src/mypkg/internal/foo` 只能在 `$GOPATH/src/mypkg` 下使用；

- 不要使用 `src/` 目录

容易和 Go workspace 目录约束下的 `src/` 起冲突；