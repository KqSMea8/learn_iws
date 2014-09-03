#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

logger = Logger.new $config["log_path"], "alarm"

issue_list = IssueList.new

issue_list.each do |issue|
  rs = issue.recent_state
  ls = issue.last_state
  if rs != ls
    alert = Alert.new issue.alarm_mail,issue.alarm_sms,"[IWS] #{issue.product}/#{issue.name}: #{rs} (NOW = #{issue.recent_data()["value"]})"
    alert << <<HC_MAILCONTANT
#{issue.product}/#{issue.name}: Now #{rs}
NOW: #{issue.recent_data}
http://sdc-iws.baidu.com/issue/#{issue.product}/#{issue.name}
HC_MAILCONTANT
    logger << alert.info.to_s
    alert.send_mail
    if rs != "warn" && !(ls == "warn" && rs == "fine")
      alert.send_sms
    end
    if issue.recent_state == "fine"
      issue.add_case
    end
  end
  issue.update_state
end
