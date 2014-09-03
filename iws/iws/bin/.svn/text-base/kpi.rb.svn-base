#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

logger = Logger.new $config["log_path"], "kpi"

issue_list = IssueList.new
issue_list.each do |issue|
  issue.calc_kpi
  logger << "update issue: #{issue.kpi}"
end

product_list = ProductList.new
product_list.each do | product |
  product.update_kpi
  logger << "update product: #{product.kpi}"
end
