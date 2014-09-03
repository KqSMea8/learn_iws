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
alert_sql.each_hash do | row |
  next if row["title"] =~ /\[IWS\]/
  name = "#{row["nodename"]} | #{row["originName"]} | #{row["ruleName"]}"
  dat = row["time"].sub(/ .*$/,"")
  alert[name] = {"cnt" => 0, "week_cnt" => 0, "list" => [], "dat" => {}} if !alert[name]
  alert[name]["title"] = row["title"]
  alert[name]["list"] << { "title" => row["title"], "time" => dat }
  alert[name]["follower"] = row["follower"]
  alert[name]["week_cnt"] += 1 
  alert[name]["cnt"] += 1 if dat == yesterday
  alert[name]["dat"][dat] = 1
  alert[name]["sms"] = row["ifsms"]

  #p "select id from trace where title=\"#{row["nodename"]}\n[#{row["originName"]}]\n#{row["rulename"]}\""
  nodename=row["nodename"]
  originName="["+row["originName"]+"]"
  rulename=row["rulename"]
  idlist=db.query "select id from trace where title=\"#{nodename}\n#{originName}\n#{rulename}\""
  idlist.each_hash do |idt|
    alert[name]["url"]="http://sdc-iws.baidu.com/trace/"+idt["id"]
  end
end

mail = Myalert.new "wenli@baidu.com","","[IWS] ALARM DAILY REPORT #{yesterday}"
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

alert_maxscore=(alert_sort[0][1]["cnt"]+alert_sort[0][1]["dat"].count*10-10)*(alert_sort[0][1]["sms"].to_i+1)
if alert_sort[0][1].include?("url")
	alert_maxscore=alert_maxscore/2
end
alert_sort.each do |v|
  alert_cnt += 1
  next if alert_cnt > 50
  cnt = v[1]["cnt"]
  week = v[1]["dat"].count
  week_cnt = v[1]["week_cnt"]
  sms = v[1]["sms"] == '0' ? "[NOSMS]":""
  title = "#{cnt}: #{v[0]} (#{week} times this week, all #{week_cnt}) #{sms}"
  mail.h2 title

  url = v[1]["url"]
  if url!="" && url!=nil
  mail << "url: #{v[1]["url"]}"
  else
  mail << "url: not find"
  end
		  
  list_cnt = 0
  v[1]["list"].each do |l|
    list_cnt += 1
    mail <<  "&nbsp;&nbsp;&nbsp;#{l["time"]}: #{l["title"]}" if list_cnt < 10
  end
  mail.h2 "&nbsp;&nbsp;&nbsp;... (total #{list_cnt})" if list_cnt >= 10
  mail << ""
end
mail.h2 "... (week total #{alert_cnt})"

idstr=`cat chart.dat | awk 'END {print $1}'`
idstr=idstr.rstrip
id=idstr.to_i+1
File.open("chart.dat","a") do |file|
	file.puts id.to_s+" "+alert_cnt.to_s+" "+alert_maxscore.to_s
end
mail.send_mail
`gnuplot line.plt`
mail << '<img src="http://10.50.35.55:8903/case.jpeg"><img src="http://10.50.35.55:8903/score.jpeg">'

