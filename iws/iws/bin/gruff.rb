#!/usr/bin/env ruby
home = File.join(File.dirname(__FILE__),'..')
ENV['BUNDLE_GEMFILE'] ||= "#{home}/Gemfile"
$LOAD_PATH.unshift(File.join(home,'lib'))
#require 'gruff'
require 'date'
require 'mysql'

require "iws"

$config = Conf.new(File.join(home,"conf/iws.yml"))

$db=Db.new $config["db"]

def drawline
	g = Gruff::Line.new
	g.title = 'Wow!  Look at this!'
	g.labels = { 0 => '5/6', 1 => '5/15', 2 => '5/24', 3 => '5/30', 4 => '6/4',5 => '6/12', 6 => '6/21', 7 => '6/28' }
	g.data :Jimmy, [25, 36, 86, 39, 25, 31, 79, 88]
	g.data :Charles, [80, 54, 67, 54, 68, 70, 90, 95]
	g.data :Julie, [22, 29, 35, 38, 36, 40, 46, 57]
	g.data :Jane, [95, 95, 95, 90, 85, 80, 88, 100]
	g.data :Philip, [90, 34, 23, 12, 78, 89, 98, 88]
	g.data :Arthur, [5, 10, 13, 11, 6, 16, 22, 32]
	g.write('exciting.png')
end
def datetest
	today=Date.today
	yester=Date.new(2014,07,01)	
	i=1;
	for date in yester..today do
		startdate=date.to_s
		enddate=(date+1).to_s
		alert_cnt=$db.query "select count(*) from alarm where title like '%[iws]%' and time between \"#{startdate}\" and \"#{enddate}\""
		alert_cnt.each_hash do |cnt|
			puts i.to_s+" "+cnt["count(*)"]
		end
		i+=1
	end
end
#drawline
datetest
