# onechart.js

## 什么是onechart.js

onechart.js是一个对highstock.js的封装，可以让前端在不编写js的情况下制作图表，方便不会js的同学使用。

最酷的是，onchart支持直接调用NOAH的数据（[传送门](#noah)），无需调用noahquery，无需解析数据解构，只需要纯静态页面就能制作漂亮的仪表盘，只需要一个html文件，连webserver都不需要搭建。

你可以在<http://sdc-iws.baidu.com/js/onechart.js>下周最新的js。

## 依赖库

onechart依赖以下库：

* [jquery 1.10.2](http://www.w3school.com.cn/jquery/index.asp)
* [async.js](https://github.com/caolan/async) - 用来同步化JS调用
* [highstock.js](http://www.highcharts.com/) - 绘制canvas图表的js库

## 使用示例

### 最简调用

使用一个`<div class="onechart">`即可调用一张图，
	
	<div 
	  class="onechart" 
	  url="http://someurl"
	>
	</div>

另外，`url`的数据格式需要符合highstock的接口要求（[传送门](http://api.highcharts.com/highstock#series.data)），和series项目同构，即符合如下格式：

	[{
		"name" : "some name",
		"data" : [1,2,3...]
	}]


### 调用样式

可以使用`setting`参数调用样式，比如

	<div 
	  class="onechart" 
	  setting = "style_simple"  
	  url="http://someurl"
	>
	</div>

目前预定义的样式包括：

* `style_default`（默认）：highstock默认，但是没有rangeSelector，我觉得大部分仪表盘都不需要它；
* `style_legend`：在`style_default`基础上新增了legned；
* `style_simple`：在`style_default`基础上缩减了rangeSelector；
* `style_oneday`：在`style_default`基础上，修改了rangeSelector，只保留1h和1d两个按钮，且选中1h；

如果你想要自定义样式，可以修改setting为你想要的任何样式，setting的格式和highstock一致（[传送门](api.highcharts.com/highstock)），示例

	<div 
	  class="onechart" 
      setting = '{
        rangeSelector : {
          enabled : false
        }
      }'
	  url="http://someurl"
	>
	</div>

### 定义标题

	<div 
	  class="onechart" 
	  title = "Some Title"  
	  url="http://someurl"
	>
	</div>

### 定义时间戳

很多仪表盘需要拿到当前时间，onechart支持ago参数，可以自动生成从ago时间前到现在的时间戳，加入GET请求串，方便制作最近一段时间的仪表盘。

	<div 
	  class="onechart" 
	  ago = 60   // 单位为分钟
	  url="http://someurl?"
	>
	</div>

这个例子中使用了ago的参数，所以实际上的请求为`http://someurl?startTime=now-ago&stopTime=now`，注意为了加入GET串，`url`需要有'?'，而且需要接受startTime和stopTime参数。

### 使用同环比

很多仪表盘需要同环比数据，使用onechart，只需要一个标签即可：

	<div 
	  class="onechart" 
	  display_style="relative" 
	  url="http://someurl?"
	>
	</div>

## 调用NOAH数据
<span id="noah"></span>

首先，我们需要搞到NOAH趋势图的后端请求URL，使用firebug等很容易拿到，找到类似的请求：

> http://infoquery.noah.baidu.com//crius/metis-visualize/index.php?r=Trend/getTrendData&callback=jQuery17108266891304940803_1392890062927&....&chartDataType[]=sum&startTime=2014-02-20+16%3A54%3A23&endTime=2014-02-20+17%3A54%3A23&_=1392890066802

然后，我们修改callback函数为？，并删除startTime和stopTime

> http://infoquery.noah.baidu.com//crius/metis-visualize/index.php?r=Trend/getTrendData&callback=?&....&chartDataType[]=sum

然后需要新增一个`url_type = "noah"`的标签即可，格式转化的事情onechart会帮你解决的。

	<div 
	  class="onechart" 
	  url_type = "noah"
	  url="http://infoquery.noah.baidu.com/...."
	>
	</div>

## 联系作者

文立

<wenli@baidu.com>


