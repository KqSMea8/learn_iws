#!/usr/bin/env ruby
Encoding.default_internal = 'UTF-8'

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))
$db = Db.new $config["db"]

Iws_server.set :port,8456
Iws_server.set :bind,"0.0.0.0"
Iws_server.run!
