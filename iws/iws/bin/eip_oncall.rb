#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))

db=Db.new $config["db"]

yesterday = (Date.today-1).strftime("%Y-%m-%d %H:%M:%S").to_s
today = Date.today.strftime("%Y-%m-%d %H:%M:%S").to_s
eip_sql = db.query "select distinct(title) from alarm where time between \"#{yesterday}\" and \"#{today}\" and ifsms=1 order by title"
alert = []
alert_gsub = []
eip_sql.each_hash do | row |
  next if row["title"] =~ /\[IWS\]/
  alert.push("#{row["title"]}")
  alert_gsub.push("#{row["title"].scan(/[A-Za-z]/).join()}")
end
f=File.new("/home/work/opdir/tmp/eip.out", "wb")
f.puts alert_gsub
f.close

oncall_file=(Date.today-1).to_s.gsub('-','')
`wget db-ecomop-sdcop.db01.baidu.com:/home/work/yangguangyi/sdc_sms_mon/data/data_txt/#{oncall_file}/13651832128_#{oncall_file}.day -O ../data/oncall`
`cat "../data/oncall"|awk -F'|' '{print $6}'| sort |uniq > ../data/oncall_list`
oncall=[]
oncall_gsub=[]
File.open("../data/oncall_list","r") do |file|
  while line  = file.gets
    oncall.push("#{line}")
    oncall_gsub.push("#{line.scan(/[A-Za-z]/).join()}")
  end
end
f=File.new("/home/work/opdir/tmp/oncall.out", "wb")
f.puts oncall_gsub
f.close

mail = Alert.new "linzhichao@baidu.com fudongxu@baidu.com lidongpeng@baidu.com qujianping@baidu.com wenli@baidu.com","","[IWS] EIPvsONCALL DAILY REPORT-ONCALL_ONLY #{oncall_file}"
mail << "ONCALL ONLY (oncall all:#{oncall.length})"
oncall.each do |info|
  tmp=info.split(']')
  info_tmp= "#{tmp[0]}"+"#{tmp[1]}"+"#{tmp[2]}"
  p "#{info_tmp.scan(/[A-Za-z]/).join()}"
  if not alert_gsub.join().include? "#{info_tmp.scan(/[A-Za-z]/).join()}"
    mail << "#{info}"
  end
end
mail.send_mail

mail = Alert.new "linzhichao@baidu.com fudongxu@baidu.com lidongpeng@baidu.com qujianping@baidu.com wenli@baidu.com","","[IWS] EIPvsONCALL DAILY REPORT-EIP_ONLY #{oncall_file}"
mail << "EIP ONLY (eip all:#{alert.length})"
alert.each do |info|
  tmp=info.split(']')
  info_tmp= "#{tmp[0]}"+"#{tmp[1]}"+"#{tmp[2]}"
  if not oncall_gsub.join().include? "#{info_tmp.scan(/[A-Za-z]/).join()}"
    mail << "#{info}"
  end
end
mail.send_mail
