+function ($) {

  var style_default = {
    rangeSelector : {
      enabled : false,
    },
  }

  var style_legend = {
    rangeSelector : {
      enabled : false,
    },
    legend : {
      enabled : true
    },
  }

  var style_simple = {
    rangeSelector : {
      enabled : false,
    },
    navigator : {
      enabled : false
    },
  }

  var style_oneday = {
    rangeSelector : {
      buttons : [{
        type : 'hour',
        count : 1,
        text : '1h'
        }, {
        type : 'day',
        count : 1,
        text : '1D'
      }],
      selected : 0
    },
    navigator : {
      enabled : false
    },
  }

  Date.prototype.Format = function(fmt) 
  { //author: meizz 
    var o = { 
      "M+" : this.getMonth()+1,                 
      "d+" : this.getDate(),                   
      "h+" : this.getHours(),                 
      "m+" : this.getMinutes(),              
      "s+" : this.getSeconds(),             
      "q+" : Math.floor((this.getMonth()+3)/3),
      "S"  : this.getMilliseconds()           
    }; 
    if(/(y+)/.test(fmt)) 
      fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length)); 
    for(var k in o) 
      if(new RegExp("("+ k +")").test(fmt)) 
    fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length))); 
    return fmt; 
  } 

  $(window).on('load', function () {
    $("div.onechart").each(function(index,element){
      $(element).html("Loading Chart ...");
      if ($(element).attr("url_type") == "noah") {
        Highcharts.setOptions({  
          global: {  
            useUTC: false  
          }  
        }); 
      }else{
        Highcharts.setOptions({  
          global: {  
            useUTC: true
          }  
        }); 
      }
      if ( typeof($(element).attr("setting")) == "undefined") {
        setting = style_default;
      } else {
        eval("var setting = " + $(element).attr("setting"));
      }
      if ( typeof($(element).attr("title")) != "undefined") {
        setting["title"] = {
          text : $(element).attr("title")
        };
      }
      if ( typeof($(element).attr("ago")) == "undefined") {
        ago = 0;
      } else {
        ago = $(element).attr("ago")
      }
      if ($(element).attr("display_style") == "relative") {
        async.parallel({
          td: function(callback) {
            var endTime = new Date();
            var query = $(element).attr("url")+"&startTime="+endTime.Format("yyyy-MM-dd+00:00:00")+"&endTime="+endTime.Format("yyyy-MM-dd+hh:mm:ss");
            $.getJSON(query, function(data) {
              if ($(element).attr("url_type") == "noah") {
                ret = data["data"]["trendItem"][0]["series"][0];
              } else {
                ret = data[0];
              }
              ret["name"] = "Today"
              ret["color"] = "#c00000"
              callback(null,ret);
            });
          },
          tb: function(callback) {
            var endTime = new Date();
            var startTime = new Date();
            startTime.setDate(endTime.getDate() - 1);
            var query = $(element).attr("url")+"&startTime="+startTime.Format("yyyy-MM-dd+00:00:00")+"&endTime="+startTime.Format("yyyy-MM-dd+23:59:59");
            $.getJSON(query, function(data) {
              if ($(element).attr("url_type") == "noah") {
                ret = data["data"]["trendItem"][0]["series"][0];
              } else {
                ret = data[0];
              }
              for (i in ret["data"]) {
                ret["data"][i][0] += 1000*3600*24;
              }
              ret["name"] = "Yesterday";
              ret["type"] = 'area';
              ret["color"] = "#0040ff"
              callback(null,ret);
            });
          },
          hb: function(callback) {
            var endTime = new Date();
            var startTime = new Date();
            startTime.setDate(endTime.getDate() - 7);
            var query = $(element).attr("url")+"&startTime="+startTime.Format("yyyy-MM-dd+00:00:00")+"&endTime="+startTime.Format("yyyy-MM-dd+23:59:59");
            $.getJSON(query, function(data) {
              if ($(element).attr("url_type") == "noah") {
                ret = data["data"]["trendItem"][0]["series"][0];
              } else {
                ret = data[0];
              }
              for (i in ret["data"]) {
                ret["data"][i][0] += 1000*3600*7*24;
              }
              ret["name"] = "Last Week"
              ret["type"] = 'area';
              ret["color"] = "#ffff00"
              callback(null,ret);
            });
          }
        },function(err,results) {
          setting["series"] = []
          setting["series"][0] = results["hb"]
          setting["series"][1] = results["tb"]
          setting["series"][2] = results["td"]
          $(element).highcharts('StockChart', setting);
        });
      } else {
        if (ago != 0) {
          var endTime = new Date();
          var startTime = new Date();
          startTime.setMinutes(endTime.getMinutes()-ago);
          var query = $(element).attr("url")+"&startTime="+startTime.Format("yyyy-MM-dd+hh:mm:ss")+"&endTime="+endTime.Format("yyyy-MM-dd+hh:mm:ss");
        } else {
          var query = $(element).attr("url");
        }
        $.getJSON(query, function(data) {
          if ($(element).attr("url_type") == "noah") {
            ret = data["data"]["trendItem"][0]["series"];
          } else {
            ret = data;
          }
          setting["series"] = ret;
          $(element).highcharts('StockChart', setting);
        });
      }
    });
  });
}(jQuery);
