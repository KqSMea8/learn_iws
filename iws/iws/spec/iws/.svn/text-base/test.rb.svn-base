#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'../..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))

@db = Db.new $config["db"]

issue = Issue.new 1
p issue.data_history

