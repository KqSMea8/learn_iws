class Monitor

  def self.fetch data=nil
    raise  NotImplementedError,"should be implemented in inheritance"
  end

  def self.get name,*args
    ret = get_data name
    fetch ret, *args
  end

  def self.[] name
    get name
  end

  def Monitor.method_missing(name, *args, &blk)
    get name.to_s, *args
  end

  def self.table
    raise  NotImplementedError,"should be implemented in inheritance"
  end

  def self.get_data name
    begin
      $db.send("findOne_#{table}_by_name", name)
    rescue
      nil
    end
  end

end

class Noah2 < Monitor

  def self.table
    "monitor_noah2"
  end

  def self.fetch dat=nil
    dat = @data if !dat
    noahquery(dat["k"],dat["node"],dat["item"])
  end

  def self.noahquery(k,node,item)
    begin
      # query
      dir = File.join(File.dirname(__FILE__),'../../lib/noahquery') 
      tmpdir = "/tmp/noah_query_#{Time.now.to_f}"
      query = "cd #{dir} && ./noahquery -o cluster -k #{k} -t latest -h #{node} -i #{item} -d #{tmpdir} &> /dev/null"
      system(query)
      # read
      fd = File.new "#{tmpdir}/LatestData"
      line = fd.readlines[1]
      value = /.*\t([0-9.]*)\(.*/.match(line)[1]
      fd.close
      # clear
      FileUtils.rm_rf tmpdir
      # return
      value.to_f
    rescue
      # clear
      FileUtils.rm_rf tmpdir
      nil
    end
  end

end

class RestAPI < Monitor

  def self.table
   "monitor_restapi"
  end

  def self.fetch dat=nil
    dat = @data if !dat
    query dat["url"]
  end

  def self.query url
    begin
      ret = RestClient.get url
      JSON.parse(ret)["stability"].to_f
    rescue
      nil
    end
  end

end

class Noah3 < Monitor

  def self.table
   "monitor_noah3"
  end

  def self.fetch dat=nil
    dat = @data if !dat
    moniurl = "http://mt.noah.baidu.com/visualize/index.php?r=warning/queryStatus&rule=#{dat["instance"]}:#{dat["type"]}:#{dat["rule"]}"
    query moniurl
  end

  def self.query url
    begin
      ret = RestClient.get url
      flag = 1
      jsonlen = JSON.parse(ret)["data"].length-1
      for jsoni in 0..jsonlen do
	if(JSON.parse(ret)["data"][jsoni]["status"].nil?)
	  flag = nil
        elsif(JSON.parse(ret)["data"][jsoni]["status"].to_i != 0)
          flag = 0
        end
      end
      flag
    rescue
      nil
    end
  end

end

class Noah2Series < Monitor

  def self.table
    "monitor_noah2"
  end

  def self.fetch dat=nil,his=1
    dat = @data if !dat
    start_time = (Time.now - his*1440*60).strftime("%Y%m%d000000")
    end_time = (Time.now - his*1440*60).strftime("%Y%m%d235959")
    ret = noahquery(dat["k"],dat["node"],dat["item"],start_time,end_time)
  end

  def self.noahquery(k,node,item,start_time,end_time)
    begin
      # query
      dir = File.join(File.dirname(__FILE__),'../../lib/noahquery') 
      tmpdir = "/tmp/noah_query_#{Time.now.to_f}"
      query = "cd #{dir} && ./noahquery -o cluster -k #{k} -h #{node} -i #{item} -s #{start_time} -e #{end_time} -d #{tmpdir} &> /dev/null"
      system(query)
      # read
      fd = File.new "#{tmpdir}/#{node}"
      timestamp = 0
      sum = 0
      fd.each_line do |line|
        last_timestamp = timestamp
        timestamp = line.split(" ")[0]
        value = line.split(" ")[1].to_f
        if timestamp != 'TIMESTAMP' && last_timestamp != 'TIMESTAMP' && last_timestamp != 0
          t = DateTime.parse timestamp
          lt = DateTime.parse last_timestamp
          time_step = t.to_time - lt.to_time
          sum += value * time_step
        end
      end
      fd.close
      # clear
      FileUtils.rm_rf tmpdir
      # return
      sum
    rescue
      # clear
      FileUtils.rm_rf tmpdir
      raise "error in fetch"
    end
  end

end
