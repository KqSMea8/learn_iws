# -*- coding: utf-8 -*-
require 'json'

class Galert < Hash

  def initialize desc 
    @filen = "/home/work/tmp/iwstest/json_file"
    if desc.kind_of? Fixnum
      fetch_by_id desc
    elsif desc.kind_of? Hash
      self.merge! desc
    end
  end

  def insert_data
    uuap_path="/home/work/tmp/iwstest/uuap_cookie"
    system "wget st01-sdcop-dev.st01:/home/work/Monitor/cookie/uuap_cookie -O #{uuap_path}"
    nodeid = [2294,19444,23700,1078,200013276]
    proid = [1,5,2,3,9]
    endtime = Time.now
    starttime = endtime - 300
    sdate,shour,smin,ssec = starttime.strftime("%Y-%m-%d:%H:%M:%S").split(":")
    edate,ehour,emin,esec = endtime.strftime("%Y-%m-%d:%H:%M:%S").split(":")
    
    nodeid.each_with_index{|id,idx|
	eurl = "http://noah.baidu.com/eip/incident/incidentList.do?curPage=1&perPage=100&nodeId=#{id}&q=%5Bstatus%5D%5BnotEqual%5D%5B6%5D%2B%5BcreatedAt%5D%5Bbetween%5D%5B#{sdate}%20#{shour}%3A#{smin}%3A#{ssec}~#{edate}%20#{ehour}%3A#{emin}%3A#{esec}%5D&token=&sidx=id&sord=desc"
#	p eurl
       `export UUAP_COOKIEJAR="#{uuap_path}";curl -b $UUAP_COOKIEJAR -c $UUAP_COOKIEJAR -i -A 'BaiduUUAPLoginBot/1.0' -L '#{eurl}'>#{@filen}`
#    content = File.readlines(@filen)
        content = `tail -1 #{@filen}`
        contentj = JSON.parse content
        dlist = contentj["data"]["list"]
        dlen = dlist.length - 1
        for i in 0..dlen
	    id = dlist[i]["id"]
    	    origin = dlist[i]["origin"]
	    originName = dlist[i]["originName"]
	    rulename = dlist[i]["ruleName"]
	    nodename = dlist[i]["nodeName"]
	    time = dlist[i]["createdAt"]
	    title = dlist[i]["title"]
            smsif = ifsms rulename,title
            $db.query "insert into alarm (`id`, `origin`, `originName`, `rulename`, `nodename`, `time`, `title`, `product_id`,`ifsms` ) VALUES (#{id}, '#{origin}', '#{originName}', '#{rulename}', '#{nodename}', '#{time}', '#{title}', '#{proid[idx]}', #{smsif} );"
#           p "insert into alarm (`id`, `origin`, `originName`, `rulename`, `nodename`, `time`, `title` ) VALUES (#{id}, '#{origin}', '#{originName}', '#{rulename}', '#{nodename}', '#{time}', '#{title}' );"
	end
    }
  end


  def fetch_by_id id
    ret = $db.findOne_alarm_by_id id
    self.merge! ret if ret
  end
 
  def ifsms title,content
    blackfile = "/home/work/iws/conf/blacklist"
    tsms = `grep "#{title}" #{blackfile}`
    csms = `grep "#{content}" #{blackfile}`
    if tsms !="" || csms !=""
      return 0
    else
      return 1
    end
  end
end

class Galertlist < Array
  def initialize(flag,stime,etime,pid)
      ret = $db.query "select distinct(rulename) as rulename,id,originName,origin,nodename,title,time,product_id,follower,trace,count(rulename) as cnt,ifsms from alarm  where send='#{flag}' and time<='#{etime}' and time>='#{stime}' and product_id REGEXP '#{pid}' group by nodename,rulename order by cnt desc;"
#      ret = $db.query_alarm
      ret.each_hash do | row |
        galert = Galert.new row
        self << galert
      end
  end
  
  def update_send
        $db.query "update alarm set send=1;"
  end

  def to_send_cnt
	ret = $db.findOne "select count(*) as cnt from alarm where send=0;"
	ret["cnt"].to_i
  end

  def endtime
        ret = $db.findOne "select time from alarm where send=0 order by time desc limit 1;"
	if ret
           return ret["time"]
	else 
	   return 0
	end
  end

  def statime
        ret = $db.findOne "select time from alarm where send=0 order by time limit 1;"
	if ret
           return ret["time"]
        else
           return 0
        end
  end

  def fetch_proname(id)
	ret = $db.findOne "select name from product where id='#{id}';"
	ret["name"]
  end
end

