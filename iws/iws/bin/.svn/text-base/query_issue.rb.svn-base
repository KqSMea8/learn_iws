#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

logger = Logger.new $config["log_path"], "query"

issue_list = IssueList.new

issue_list.each do |issue|
  issue.update_data
  logger << "update issue: #{issue.recent_data}"
end
