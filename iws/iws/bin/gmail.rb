#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#require 'mail'
require 'iconv'
home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))
require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

logger = Logger.new $config["log_path"], "gmail"

galert_list = Galertlist.new 0,'1987-01-01','2230-01-01','.*'
to_sendcnt = galert_list.to_send_cnt
timenow = Time.now.strftime("%M")
timehour = Time.now.strftime("%H")
alarmhour = ["08","09","10","11","12","13","14","15","16","17","18","19","20","21","22"]
if (timenow=="01" && to_sendcnt!=0 && (alarmhour.include?timehour))
	endtime = galert_list.endtime
	starttime = galert_list.statime
	alert = Alert.new "columbus-op@baidu.com","","$(echo -e '[IWS] Alarms Group [From #{starttime} to #{endtime}]\nContent-Type: text/html; charset=uft-8')"
	alert << <<HC_MAILCONTANT
<html><body>
<a href="http://sdc-iws.baidu.com/alarm">Details&More</a>
<br>
<table style="BORDER-COLLAPSE: collapse;word-break: break-all;" borderColor="#000000" border="2" cellspacing="0" width="1200">
<tr align="center" bgcolor="#2f4eaa">
<th align="center" width="80" style="word-break:keep-all">Count</th>
<th align="center" width="100" style="word-break:keep-all">NodeName</th>
<th align="center" width="100" style="word-break:keep-all">RuleName</th>
<th align="center" width="200" style="word-break:keep-all">Content</th>
<th align="center" width="120" style="word-break:keep-all">AlarmTime</th>
<th align="center" width="80" style="word-break:keep-all">OriginName</th>
</tr>
HC_MAILCONTANT
        smslength = 0
        smscontent=""
	galert_list.each do |galert|
	    cnt = galert["cnt"]
	    nodename = galert["nodename"][15..-1]
	    rulename = galert["rulename"]
	    title = galert["title"]
	    time = galert["time"][11..-1]
	    originName = galert["originName"]
	    origin = galert["origin"].to_i
	    pid = galert["product_id"].to_i
            ifsms = galert["ifsms"].to_i

            smslength += cnt.to_i
	  if origin!=13 && ifsms==1
            smscontent = "#{smscontent}[#{cnt}]-[#{originName}] #{nodename} #{rulename}\n-------\n"
	  end
	 #if origin!=4 && origin!=13
	  # info = "[IWS]#{nodename},#{rulename},#{title},#{time},#{cnt} times"
	  # input_encoding = "utf-8"
	  # output_encoding = "gbk"
	  # tinfo = Iconv.new(output_encoding, input_encoding).iconv(info)
	  # alertsms = Alert.new "linzhichao@baidu.com","g_ecomop_maop_manager;15601606977;13651832128","#{tinfo}"
          # alertsms.send_sms
	 #end
	   alert << <<HC_MAILCONTANT
<tr><td>#{cnt}</td><td>#{nodename}</td><td>#{rulename}</td><td>#{title}</td><td>#{time}</td><td>#{originName}</td></tr>
HC_MAILCONTANT
	end
        info = "[IWS] Alarm #{smslength} times"
        if smscontent!=""
          smscontent = "[IWS]\n" + smscontent
          input_encoding = "utf-8"
          output_encoding = "gbk"
          tinfo = Iconv.new(output_encoding, input_encoding).iconv(smscontent)
          alertsms = Alert.new "columbus-op@baidu.com","g_ecomop_maop_manager;g_ecomop_maop_all","#{tinfo}"
          alertsms.send_sms
        end
	alert << <<HC_MAILCONTANT
</table></body></html>
HC_MAILCONTANT
	alert.send_mail
	#system "echo -e '#{alert.text}' | grep -v '^$' | /usr/sbin/sendmail -t;"
	galert_list.update_send
end
