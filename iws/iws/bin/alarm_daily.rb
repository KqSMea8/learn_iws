#!/usr/bin/env ruby
#encoding:utf-8
home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))

db=Db.new $config["db"]

lastweek = (Date.today-8).to_s
yesterday = (Date.today-1).to_s
today = Date.today.to_s
alert_sql = db.query "select * from alarm where time between \"#{lastweek}\" and \"#{today}\""
alert = {}
alert_doing={}
alert_sql.each_hash do | row |
  next if row["title"] =~ /\[IWS\]/
  name = "#{row["nodename"]}|#{row["originName"]}|#{row["rulename"]}"
  dat = row["time"].sub(/ .*$/,"")
  alert[name] = {"cnt" => 0, "week_cnt" => 0, "list" => [], "dat" => {}} if !alert[name]
  alert[name]["title"] = row["title"]
  alert[name]["list"] << { "title" => row["title"], "time" => dat }
  alert[name]["follower"] = row["follower"]
  alert[name]["week_cnt"] += 1 
  alert[name]["cnt"] += 1 if dat == yesterday
  alert[name]["dat"][dat] = 1
  alert[name]["sms"] = row["ifsms"]

  nodename=row["nodename"]
  originName="["+row["originName"]+"]"
  rulename=row["rulename"]
  idlist=db.query "select id,status from trace where title=\"#{nodename}\n#{originName}\n#{rulename}\""
  idlist.each_hash do |idt|
    alert[name]["url"]="http://sdc-iws.baidu.com/trace/"+idt["id"]
		alert[name]["status"]=idt["status"]
  end
end

alert_sort = alert.sort do |a,b| 
  ta = (a[1]["cnt"] + a[1]["dat"].count * 10 - 10) * (a[1]["sms"].to_i + 1)
  
  if a[1].include?("url")
    ta=ta/2
  end
		  
  tb = (b[1]["cnt"] + b[1]["dat"].count * 10 - 10) * (b[1]["sms"].to_i + 1)
  
  if b[1].include?("url")
    ta=ta/2
  end
		  
  tb <=> ta
end
alert_cnt = 0
list_cnt = 0

mail = Myalert.new "baizhenchao@baidu.com","","[IWS] ALARM DAILY REPORT #{yesterday}"

alert_sort.each do |v|
  alert_cnt += 1
  next if alert_cnt > 50
  cnt = v[1]["cnt"]
  week = v[1]["dat"].count
  week_cnt = v[1]["week_cnt"]
  sms = v[1]["sms"] == '0' ? "[NOSMS]":""
	title=v[0].split("|")
	if match=(/^(BAIDU_ECOM_SDC)_([a-zA-Z]*)/.match title[0])
			title[0]=match[2]
	end
		
  if v[1]["url"]!="" && v[1]["url"]!=nil
		#title = "&nbsp info : #{v[0]}(本周报警 #{week} 天 共 #{week_cnt} 次 今天 #{cnt} 次) #{sms}"
		#title = "&nbsp info : <strong>#{v[0]}(week alert #{week} per day , total #{week_cnt}  , today #{cnt} ) #{sms}</strong>"
		#mail.mess_doing title
		#mail.mess_doing "&nbsp url : #{v[1]["url"]} , doing_status : #{v[1]["status"]}"
		#mail.mess_doing  "&nbsp detial : #{v[1]["list"][0]["time"]} : #{v[1]["list"][0]["title"]}"
		#list_cnt+=1
		#mail.mess_doing "&nbsp url : #{v[1]["url"]} , 跟进状态 : #{v[1]["status"]}"
		mail.tr_doing 
		mail.td_doing title[0]
		mail.td_doing title[1]
		mail.td_doing title[2]
		mail.td_doing week.to_s
		mail.td_doing week_cnt.to_s
		mail.td_doing cnt.to_s
		mail.td_doing "<a href=\"#{v[1]["url"]}\">#{v[1]["status"]}</a>"
		mail.td_doing "#{v[1]["list"][0]["time"]} : #{v[1]["list"][0]["title"]}"
		mail.trend_doing
	else
		#title = "&nbsp info : <strong>#{v[0]}(week alert #{week} per day , total #{week_cnt} , today #{cnt} ) #{sms}</strong>"
		#title = "&nbsp info : #{v[0]}(本周报警 #{week} 天 , 共 #{week_cnt} 次 今天 #{cnt} 次) #{sms}"
		#mail.mess title
		mail.tr 
		mail.td title[0]
		mail.td title[1]
		mail.td title[2]
		mail.td week.to_s
		mail.td week_cnt.to_s
		mail.td cnt.to_s
		mail.td "null"
		mail.td "#{v[1]["list"][0]["time"]} : #{v[1]["list"][0]["title"]}"
		mail.trend
#mail.mess  "&nbsp detial : #{v[1]["list"][0]["time"]}: #{v[1]["list"][0]["title"]}"
  end
end
#mail.mess "&nbsp <strong>total : #{alert_cnt-list_cnt}</strong>"
#mail.hl "&nbsp 总计 : #{alert_cnt-list_cnt}"
#mail.mess " "
#mail.mess_doing "&nbsp <strong>total : #{list_cnt}</strong>"
#mail.hl.doing "&nbsp 总计 : #{list_cnt}"
#mail.mess_doing " "
mail.tabend_doing
mail.tabend
mail.combine
#mail.hl "(week total :  #{alert_cnt})"
#mail.hl "(周总数 :  #{alert_cnt})"
File.open("#{home}/data/chart.dat","w") do |file|
	today=Date.today
	yester=Date.new(2014,07,01)
	i=1;
	for date in yester..today do
		startdate=date.to_s
		enddate=(date+1).to_s
		alert_cnt=db.query "select count(*) from alarm where title like '%[iws]%' and time between \"#{startdate}\" and \"#{enddate}\""
		alert_cnt.each_hash do |cnt|
			file.puts i.to_s+" "+cnt["count(*)"]
			#puts i.to_s+" "+cnt["count(*)"]
		end
		i+=1
	end
end

#mail.putsout
`#{home}/lib/gnuplot/bin/gnuplot #{home}/bin/line.plt`
mail << '<img src="http://10.50.35.55:8903/case.jpeg">'

mail.send_mail
