# Dashboard 仪表盘
## 什么是仪表盘

在IWS中，仪表盘用来快速定位故障，在故障时为OP提供第一时间的故障情况判断。

每个核心功能故障，都会对应一张仪表盘，由于IWS希望在一个页面中解决所有的问题，因此仪表盘需要在一个WEB页面中尽量排版。

为了快速开发一张仪表盘，IWS提供了一些简单的JS库，以方便编辑修改仪表盘。

## 如何写一个仪表盘

### 仪表盘的位置

仪表盘代码位于`iws/views/dashboard`，组织方式和对应的故障URI一致，后缀为erb（是的，如果你愿意，你可以仪表盘里头写ruby代码，用`<% %>`来引用）。

比如故障项目`columbus/nginx_serviceability`，对应的仪表盘路径为`iws/views/dashboard/columbus/nginx_serviceability.erb`

### 仪表盘的布局

整个IWS布局使用了[bootstrap3.0](http://v3.bootcss.com)，仪表盘布局使用了其中的栅格系统。整个仪表盘被包在一个`<div class="row"> ... </div>`中，因此你可以使用`<div class="col-md-N"> </div>`来布局你的仪表盘。

更多栅格系统的介绍，请移步[bootstrap的帮助](http://v3.bootcss.com/css/#grid)。

### 编写仪表盘

在页面的框架中，我们已经引入了以下内容，因此你可以直接调用其中的方法：

* [jquery 1.10.2](http://www.w3school.com.cn/jquery/index.asp) - JS库
* [bootstrap3.0.3](http://v3.bootcss.com) - CSS
* [async.js](https://github.com/caolan/async) - 用来同步化JS调用
* [highstock.js](http://www.highcharts.com/) - 绘制canvas图表的js库
* [onechart.js](/help/onechart) - 为了方便开发仪表盘而开发的一个js

你可以再仪表盘中写HTML、CSS、JS甚至ruby，不过需要小心别破坏外层框架的逻辑，建议只写图表，少逻辑。

