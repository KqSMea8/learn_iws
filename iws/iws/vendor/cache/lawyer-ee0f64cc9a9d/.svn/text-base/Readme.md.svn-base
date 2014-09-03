# Lawyer
---
在日常运维工作中，我们进程遇到需要执行批处理的时候，传统的ssck和lhck并不方便重用，且依赖ssh。
利用Noah的Archer工具，我们开发了Lawyer，用于统一的预案管理和批处理操作管理。
预案执行机GEM，方便ruby用户执行预案，并简化了配置。

## 使用依赖

  * ruby (1.9.3 is prefered)
  * bundle
  * archer2 

## Getting Started

### 使用ruby执行特定命令

```ruby
require 'lawyer'
law = Lawyer.new ({
  "command" => "echo haha",
  "target" => "bns.baidu.all",
  "token" => "xxx",
}
law.go
```
### 使用ruby分发脚本并执行

```ruby
require 'lawyer'
law = Lawyer.new ({
  "command" => "somebash.sh",
  "target" => "bns.baidu.all",
  "token" => "xxx",
}
law.go
```

### 使用命令行工具执行预案

待开发

```bash
./lawyer -f action.sh -t bns.baidu.all
```

## 配置说明

`lawyer`接收一个Hash作为初始化参数，包括如下配置项目

* target: 【必须】目标BNS，可以是字符串、数组或者Hash（格式参考Archer的serverlist.yaml）
* token: 【必须】token
* script: 执行脚本，会先部署到服务器再执行，会自动添加可执行权限
* command: 执行命令，会在script后执行，如果和script都未配置，则不执行任何操作
* name: 预案在目标服务器所在的目录名，默认为action
* target_dir: 预案在目标服务器所在的地址Prefix，默认为/home/work/opdir/lawyer
* prepare_dir: 在发起预案的服务器准备配置文件的路径，默认为/tmp
* pausepoint: 暂停点，默认为1，可以设置为"1,2,4"这样，但是只对第一个服务单元有效
* concurrency: 并发度，默认为1，对所有服务单元一致
* config: 配置文件路径，以上配置均可以写入一个yaml格式的配置文件并直接调用
* archer_conf: Archer配置文件目录，一旦配置上述其他配置都不生效

```ruby
require 'lawyer'
law = Lawyer.new ({
  "config" => "config.yaml",
}
law.go
```

配置文件举例

```
# config.yaml
target: 
- bns1.baidu.all
- bns2.baidu.all
token: xxx
script: action.sh
command: "echo haha"
name: action
target_dir: /home/opdir/
prepare_dir: /tmp
pausepoint: 1,2
concurrency: 2
```

## 获取GEM

由于不方便把公司内部代码放到外网，所以略有些麻烦，提供两种方法如下：

### 使用bundle来安装

首先，先编辑Gemfile。

```
# Gemfile
gem 'lawyer', :git => 'http://gitlab.baidu.com/wenli/lawyer.git'
```

然后，执行

```bash
bundle install
```

### 自己打包

```bash
git clone http://gitlab.baidu.com/wenli/lawyer.git
cd lawyer
gem build .gemspec
gem install ./lawyer-0.1.2.gem # 版本号可能不同
```

## 直接通过archer配置执行预案

对于一些比较复杂的预案和批处理操作，可能无法用一个脚本来执行，或者并发逻辑复杂，`lawyer`支持完整的`archer`功能：

```ruby
require 'lawyer'
law = Lawyer.new ({
  "archer_conf" => "./conf",
  "token" => "xxx",
}
law.go
```

相当于

```bash
  archer2 -c ./conf
```

当简化的参数无法满足需求时，最后的选择 :stuck_out_tongue_winking_eye:

## Lawyer Server

待开发，预期可以作为一个无需数据库的批处理执行库存在。
以下为设计，还没实现 :stuck_out_tongue_winking_eye:

### 启动服务器

```bash
./lawyer_server [-c config.yaml]
```
可以通过`localhost:8352/`访问预案服务。
服务可以通过web来访问预案，查看预案执行历史，支持UUAP。
此外，服务支持命令行客户端`lawyerc`，可以在命令行使用，支持BNS白名单。

### 配置操作列表

在`$LAWYER_HOME`下的Actions目录，所有的批处理操作以文件夹形式存放形成树形结构，如果文件夹内存在action.yaml文件，则表示这是一个预案文件夹，系统会读取其中的配置形成预案。

