#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]
$logger = Logger.new $config["log_path"], "eip" 

def eip nodeName, pv, pvLoss, token, date=nil
  # url = 'http://tc-oped-dev03.tc.baidu.com:8888/eip/productKPI/import.do'  # test
  url = 'http://noah.baidu.com/eip/productKPI/import.do'
  
  date = (Time.new - 1440*60).strftime("%F") if date == nil
  kpi = 1 - pvLoss/pv
  p [kpi, {:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}}]
  ret = RestClient.get url, ({:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}})
  $logger << [ret.to_str, kpi, {:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}}]
end

# COLUMBUS
for i in 3..30 do
  begin
    date = (Time.new - i*1440*60).strftime("%F")
    pv = Noah2Series.hy_ui_flow_total i
    pvLoss = Noah2Series.hy_hyui_search_fail_total(i)/60
    puts date,pvLoss,pv,1 - pvLoss/pv
#    token = "e12594c31017ba1e2618757f6dce62c2" # test
    token = "9a3a2ce372fc91d8b328f9c001342547"
    ret = eip "BAIDU_ECOM_SDC_HOUYI", pv, pvLoss, token, date
  rescue => e
    p [date, e]
  end
end

# HOUYI
=begin
pv = Noah2Series.hy_ui_flow_total
pvLoss = Noah2Series.hy_hyui_search_fail_total
token = "e12594c31017ba1e2618757f6dce62c1"
ret = eip "BAIDU_ECOM_SDC_HOUYI", pv, pvLoss, token
=end


