#!/usr/bin/env ruby

home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))

db=Db.new $config["db"]

tables = db.query "show tables"
tables.each do | row |
  table_name = row[0]
  puts table_name
  desc = db.query "desc #{table_name}"
  puts "| Field | Type | Null | Key | Default | Extra |"
  desc.each_hash do | row |
    puts "|#{row["Field"]}|#{row["Type"]}|#{row["Null"]}|#{row["Key"]}|#{row["Default"]}|#{row["Extra"]}|"
  end
end

