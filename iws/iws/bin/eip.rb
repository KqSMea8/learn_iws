#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]
$logger = Logger.new $config["log_path"], "eip" 

def eip nodeName, pv, pvLoss, token
  # url = 'http://tc-oped-dev03.tc.baidu.com:8888/eip/productKPI/import.do'  # test
  url = 'http://noah.baidu.com/eip/productKPI/import.do'
  
  date = (Time.new - 1440*60).strftime("%F") 
  kpi = 1 - pvLoss/pv
  ret = RestClient.get url, ({:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}})
  if kpi > 0.9999
    ret = RestClient.get url, ({:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}})
    $logger << [ret.to_str, kpi, {:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}}]
  else
    alert = Alert.new "wenli@baidu.com","","[IWS] #{nodeName} PUSH EIP FAIL"
    alert << [kpi, {:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}}].to_s
    $logger << ["KPI TO LOW", ret.to_str, kpi, {:params=>{"nodeName"=>nodeName, "token"=>token, "dateTime"=>date, "data"=>{"pvDailyTotal" => pv, "pvLoss" => pvLoss, "computeType" => "pv"}.to_json}}]
    alert.send_mail
  end
end

# COLUMBUS
=begin
pv = Noah2Series.cb_nginx_flow_total
pvLoss = (Noah2Series.cb_nginx_finally_failed_total) / 60
token = "e12594c31017ba1e2618757f6dce62c2" # test
token = "e119f38ddb805d34ce40446005e2d6e6"
ret = eip "BAIDU_ECOM_SDC_COLUMBUS", pv, pvLoss, token
=end

# HOUYI
pv = Noah2Series.hy_ui_flow_total
pvLoss = Noah2Series.hy_hyui_search_fail_total/60
# token = "e12594c31017ba1e2618757f6dce62c1" # test
token = "9a3a2ce372fc91d8b328f9c001342547" # on
ret = eip "BAIDU_ECOM_SDC_HOUYI", pv, pvLoss, token

