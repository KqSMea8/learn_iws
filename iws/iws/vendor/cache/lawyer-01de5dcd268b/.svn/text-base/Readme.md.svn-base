# Lawyer
---
预案执行机GEM，方便ruby用户执行预案，并简化了配置。

## Getting Started


### 使用ruby执行预案

```ruby
  require 'lawyer'
  law = Lawyer.new ({
    "command" => "echo haha",
    "target" => "sdcop-public.BACKUPPOOL.all",
    "token" => "xxx",
  }
  law.go
```

### 使用命令行工具执行预案

待开发

## 配置说明


## 获取GEM

由于不方便把公司内部代码放到外网，所以略有些麻烦，提供两种方法如下：

### 使用bundle来安装

首先，先编辑Gemfile。

```
  gem 'lawyer', :git => 'http://gitlab.baidu.com/wenli/lawyer.git'
```

然后，执行

```bash
  bundle install
```

### 自己打包

首先，先下载最新的代码

```bash
  git clone http://gitlab.baidu.com/wenli/lawyer.git
```

然后，打包

```bash
  cd lawyer && gem build .gemspec
```

最后，安装

```bash
  gem install ./lawyer-0.1.2.gem # 版本号可能不同
```

## 直接通过archer配置执行预案

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



