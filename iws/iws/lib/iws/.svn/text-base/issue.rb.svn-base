# -*- coding: utf-8 -*-
class Issue < Hash

  def initialize desc
    if desc.kind_of? Fixnum
      fetch_by_id desc
    elsif desc.kind_of? Hash
      self.merge! desc
    end

    self["desc"] = self["desc"].force_encoding("UTF-8")
    fetch_actions
    fetch_product
  end

  def fetch_product
    self["product"] = $db.findOne_product_by_id(product_id)["name"]
  end

  def fetch_actions
    self["actions"] = []
    return nil if /^ *$/ =~ action_list
    action_list.split(",").each do |id|
      act = $db.findOne_action_by_id id
      self["actions"] << act
    end
  end

  def fetch_by_id id
    ret = $db.findOne_issue_by_id id
    self.merge! ret if ret
  end

  def update_data(value=nil,time=nil)
    smooth = (time || value)? 0:data_smooth.to_i
    time = DateTime.now if !time
    value = fetch_data if !value
    value_n = normalize(value,smooth)
    t = chomp_time time
    return false if !value_n
    $db.query "replace into issue_data value (\"#{t}\",#{id},#{value},#{value_n})"
    $db.query "update issue_state set value = #{value},serviceability = #{value_n} where issue_id = #{id}"
  end

  def data(time=nil)
    if time == nil
      return @data if defined?(@data) && !@data
      fetch_data
    else
      t = chomp_time time
      ret = $db.findOne "select * from issue_data where `time` = \"#{t}\" and `issue_id` = #{id}"
      ret["value"].to_f
    end
  end

  def show_value
    value = recent_data["value"].to_f
    case unit
    when '%'
      "#{(value*100).round(4)} #{unit}"
    when '01'
      value = 1 ? "正常":"异常"
    else
      "#{value.round(4)} #{unit}"
    end
  end

  def recent_data
    $db.findOne "select * from issue_data where `issue_id` = #{id} order by time desc limit 1"
  end

  def last_data num
    $db.findOne "select * from issue_data where `issue_id` = #{id} order by time desc limit #{num},1"
  end

  def data_history(from=nil,to=nil)
    from = chomp_time(Time.now - 60*60*24) if !from# 1 day ago
    to = chomp_time(Time.now) if !to
    ret = $db.list "select * from issue_data where `issue_id` = #{id} and time between '#{from}' and '#{to}' order by time"
  end

  def recent_state
    dat = recent_data
    recent_time = DateTime.parse(dat["time"]+"+8").to_time
    recent_value = dat["kpi"]
    now_time = Time.now
    datl = last_data 1
    dat2 = last_data 2
    last_value = datl["kpi"]
    thr_value = dat2["kpi"]
    last_s = last_state
    if (now_time - recent_time)/60 > $config["missing_thr"].to_f
      "missing"
    elsif recent_value <= error_thr || (recent_value <= warn_thr && last_value <= warn_thr && thr_value <= warn_thr) || (recent_value <= warn_thr && last_s == "error")
      "error"
    elsif recent_value <= warn_thr
      "warn"
    else
      "fine"
    end
  end

  def last_state
    ret = $db.findOne_issue_state_by_issue_id id
    if ret
      return ret["state"]
    else
      return nil
    end
  end

  def last_fine
    ret = $db.findOne_issue_state_by_issue_id id
    if ret && ret["last_fine"]
      return ret["last_fine"]
    else
      return "2000-01-01 00:00"
    end
  end

  def add_case
    last_f = get_time last_fine
    last_v = get_time last_view 
    now = chomp_time DateTime.now
    if last_f && last_v && last_v > last_f
      viewed = 1
    else
      viewed = 0
    end
    ret = $db.findOne "select avg(kpi) as kpi, avg(value) as value, count(value) as cnt from issue_data where issue_id = #{id} and time between '#{chomp_time last_f}' and '#{now}' " 
    $db.query "insert into issue_history (`start_time`, `close_time`, `name`, `issue_id`, `viewed`, `kpi_avg`, `value_avg`, `count` ) VALUES ('#{chomp_time last_f}', '#{now}', '#{name}', #{id}, #{viewed}, #{ret["kpi"]}, #{ret["value"]}, #{ret["cnt"]} );"
  end

  def update_state state=nil
    state = recent_state if !state 
    if state == "fine"
      $db.query "update issue_state set state = '#{state}',last_fine = now() where issue_id = #{id}"
    else
      $db.query "update issue_state set state = '#{state}' where issue_id = #{id}"
    end
  end

  def last_view
    ret = $db.findOne_issue_state_by_issue_id id
    if ret
      return ret["last_view"]
    else
      return nil
    end
  end

  def be_viewed
    $db.query "update issue_state set last_view = now() where issue_id = #{id}"
  end

  def fetch_data
    begin
      ret = eval data_calc
      @data = ret
      return ret
    rescue
      return nil
    end
  end

  def calc_kpi last = 0
    now = DateTime.now
    d2c = now - ( 30 * last )
    ret = $db.query "select * from issue_history where issue_id = #{id} and DATE_FORMAT(start_time,'%Y-%m') = '#{d2c.strftime("%Y-%m")}';"
    sum = 0.0
    cnt = 0
    ret.each_hash do |row|
      start = DateTime.parse(row["start_time"])
      close = DateTime.parse(row["close_time"])
      sum += ((close-start)*24*60).to_f
      cnt += 1
    end
    mttr = (cnt == 0)? 0:sum/cnt
    mtbf = (cnt == 0)? 30:30.0/cnt # assume every month has 30 days
    ret = $db.findOne "select avg(kpi) as stability from issue_data where issue_id = #{id} and DATE_FORMAT(time,'%Y-%m') = '#{d2c.strftime("%Y-%m")}'"
    stability = ret["stability"]? ret["stability"]:1
    $db.query "replace into issue_kpi (issue_id,stability,month,mttr,mtbf,cnt) values( #{id},#{stability},'#{d2c.strftime("%Y-%m-01")}',#{mttr},#{mtbf},#{cnt})"
    
    # today's kpi
    now = DateTime.now
    ret = $db.findOne "select avg(kpi) as stability from issue_data where issue_id = #{id} and DATE_FORMAT(time,'%Y-%m-%d') = '#{now.strftime("%Y-%m-%d")}'"
    kpi_today = (ret["stability"])? ret["stability"].to_f : 1.0
    $db.query "replace into issue_kpi (issue_id,stability,month) values( #{id},#{kpi_today},'0000-00-00')"
  end

  def kpi_today
    now = DateTime.now
    ret = $db.findOne "select stability from issue_kpi where issue_id = #{id} and month = '0000-00-00'"
    (ret["stability"])? ret["stability"].to_f * 100 : 100.0
  end

  def kpi_daily last = 0
    now = DateTime.now
    d2c = now - last
    ret = $db.findOne "select * from issue_kpi where issue_id = #{id} and date_format(month,'%Y-%m') = '#{d2c.strftime("%Y-%m")}'"
    ret["stability"] = ret["stability"].to_f * 100
    ret["mttr"] = ret["mttr"].to_f
    ret["mtbf"] = ret["mtbf"].to_f
    ret
  end

  def kpi last = 0
    now = DateTime.now
    d2c = now - ( 30 * last )
    ret = $db.findOne "select * from issue_kpi where issue_id = #{id} and date_format(month,'%Y-%m') = '#{d2c.strftime("%Y-%m")}'"
    ret["stability"] = ret["stability"].to_f * 100
    ret["mttr"] = ret["mttr"].to_f
    ret["mtbf"] = ret["mtbf"].to_f
    ret
  end

  def method_missing(method_id, *arguments, &block)
    if defined? self[method_id.to_s]
      self[method_id.to_s]
    else
      super
    end
  end

  def respond_to?(method_id, include_private = false)
    if defined? self[method_id.to_s]
      true
    else
      super
    end
  end

  private

  def chomp_time time
    time.strftime("%Y-%m-%d %H:%M")
  end

  def get_time time_str
    begin 
      DateTime.parse time_str
    rescue 
      nil
    end
  end

  def normalize input=nil,smooth=0
    input = @data if !input
    begin 
      if smooth > 0
        ret = $db.findOne "select max(value) as max from issue_data where `issue_id` = #{id} order by time desc limit #{smooth}"
        max = ret["max"].to_i
        input = [input,max].max
      end
      eval "[[#{data_normalized},0].max,1].min"
    rescue
      nil
    end
  end

end

class IssueList < Array
  def initialize id=nil,weight = 1
    if !id # fetch all
      ret = $db.query_issue
      ret.each_hash do | row |
        issue = Issue.new row
        self << issue
      end
    else # fetch by product
      ret = $db.query_issue_by_product_id id
      ret.each_hash do | row |
        issue = Issue.new row
        self << issue
      end
    end
  end
end
