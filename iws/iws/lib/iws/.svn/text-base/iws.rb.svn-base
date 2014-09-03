#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$config = Conf.new(File.join(File.dirname(__FILE__),"../../conf/iws.yml"))
require 'sinatra'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'

class Iws_server < Sinatra::Base

  disable :protection
  set :public_folder, File.join(File.dirname(__FILE__),'../../public')
  set :views, File.join(File.dirname(__FILE__),'../../views')

  configure :production, :development do
    enable :logging
  end

  set :port, 8360
  enable :sessions
  set :session_secret, 'secret'
    
  before do
    return if request.path_info =~ /^\/api/
    service = request.url.gsub('?' + request.query_string, '')

    start = Time.new 2014,6,30,10
    now = Time.now
    week = (now-start).to_i/(3600*24*7)%4
    oncall_list = ["屈剑平", "李东鹏", "林智超", "傅东旭"]
    $oncall = oncall_list[week]
    $next_oncall = oncall_list[(week+1)%4]

    if params[:ticket]
        url = "https://#{$config["enviro"]}.baidu.com/validate?ticket=#{params[:ticket]}&service=#{service}"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        res = http.get(uri.request_uri)
        ret = res.body.split("\n")
        if ret[0] != "yes"
            redirect("https://#{$config["enviro"]}.baidu.com/login?service=#{service}")
        else
            user = ret[1]
	    prole = "other"
            session[:user] = user
 	    role_info = $db.findOne "select * from authority where name = '#{user}'"
	    if role_info
	    	session[:prole] = role_info["role"]
	    else
		session[:prole] = prole
	    end
	    session[:ticket] = params[:ticket]
	    redirect("#{service}")
        end
    elsif session[:ticket]
    else
        redirect("https://#{$config["enviro"]}.baidu.com/login?service=#{service}")
    end
  end

  get '/logout' do
    url = "https://#{$config["enviro"]}.baidu.com/logout"
    uri = URI.parse(url)
    session.clear()
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.get(uri.request_uri)
    redirect(url)
  end

  get '/monitor' do
    begin
      $db.query "select now()"
      "<!--STATUS OK-->"
    rescue
      "<!--STATUS ERROR-->"
    end
  end

  get "/help" do
    erb :help, :layout => :header
  end

  get "/api/oncall" do
    {"oncall" => $oncall, "next_oncall" => $next_oncall}.to_json
  end

  get '/help/:file' do |file|
    head = <<HD_HEAD
    <link rel="stylesheet" href="/css/markdown.css">
    <ol class="breadcrumb">
    <li><a href="/">home</a></li>
    <li><a href="/help">help</a></li>
    <li class="active">#{file}</li>
    </ol>
    <%= yield %>
HD_HEAD
    erb head, :layout => :header do
      markdown :"help/#{file}" 
    end
  end

  get "/alarm_list" do
    issue_list = IssueList.new
    alarm_list = []
    issue_list.each do |issue|  
      if issue.recent_state != "fine"
        alarm_list << {:name => issue.name}.merge(issue.recent_data)
      end
    end
    erb :alarm_list,:locals => {:alarm_list => alarm_list}, :layout => :header  
  end

  get "/api/issue_list" do
    content_type "application/json"
    issue_list = IssueList.new
    ret = {}
    ret["records"] = issue_list
    ret["queryRecordCount"] = 44
    ret["totalRecordCount"] = 44
    ret.to_json
  end

  get "/argus" do
    erb :argus, :layout => :header
  end

  get "/trace" do
    trace_list = $db.list_trace
    erb :tracelist, :layout => :header, :locals => {:list => trace_list}
  end

  get "/trace/:id" do |id|
    trace = $db.findOne_trace_by_id id
    erb :trace, :layout => :header, :locals => {:trace => trace}
  end

  get "/delete/:id" do |id|
    sql = "delete from trace where id = #{id}"
    $db.query sql
    redirect "/trace", 302
  end

  get "/iop" do
    response = RestClient.get 'http://sdc-iop.baidu.com/statistic/icafe'
    resp = JSON.parse response.body
    if resp["state"] == 0
      list = resp["data"]
      erb :ioplist, :layout => :header, :locals => {:list => list}
    else
      erb 'API ERROR: try <a href="http://sdc-iop.baidu.com/statistic/icafe">http://sdc-iop.baidu.com/statistic/icafe</a>', :layout => :header
    end
  end

  post "/trace/:id" do |id|
    if id == "new"
      pendtext = <<HD_CONT
___
#{params[:context].force_encoding("UTF-8")} 
by #{session[:user]}
HD_CONT
      sql = "insert into trace (`title`, `context`, `status`, `owner`) values ( \"#{params["title"]}\", \"#{params[:context]}\", \"#{params[:status]}\", \"#{params[:owner]}\") on duplicate key update context=concat(context,'\n#{pendtext}')"
      $db.query sql
      redirect "/trace", 302
    else
      sql = "update trace set `title` = \"#{params["title"]}\", `context` = \"#{params[:context]}\", `status` = \"#{params[:status]}\", `owner` = \"#{params[:owner]}\" where `id` = #{id}"
      $db.query sql
      trace = $db.findOne_trace_by_id id
      erb :trace, :layout => :header, :locals => {:trace => trace}
    end
  end

  post "/trace_append/:id" do |id|
    trace = $db.findOne_trace_by_id id
    context = <<HD_CONT
#{trace["context"].force_encoding("UTF-8") }
___
#{params[:context].force_encoding("UTF-8")} 

by #{session[:user]}
#{Time.now.to_s}
HD_CONT
    sql = "update trace set `context` = \"#{context}\" where `id` = #{id}"
    sqlsta = "update trace set `status` = \"#{params[:status]}\" where `id` = #{id}"
    $db.query sql
    $db.query sqlsta
    redirect "/trace/#{id}", 302
  end

  get "/edit/:id" do |id|
    if id == "new"
      trace = {"id" => "new", "status" => "open", "title" => "", "context" => "", "owner" => session[:user] }
    else
      trace = $db.findOne_trace_by_id id
    end
    erb :trace_edit, :layout => :header, :locals => {:trace => trace}
  end

  get "/issue/:product" do
    pro_info = Product.new params[:product]
    issue_list = IssueList.new pro_info.id
    erb :product , :locals => {:product => pro_info, :issue_list => issue_list}, :layout => :header
  end

  get "/issue/:product/:issue_name" do
    pro_info = Product.new params[:product]
    pro_id = pro_info.id
    issue_info = $db.findOne "select * from issue where name = '#{params[:issue_name]}' and product_id = #{pro_id}"
    issue = Issue.new issue_info
    issue.be_viewed
    issue_case = Case.new issue_info["id"]
    erb :issue, :locals => {:issue => issue, :issue_case => issue_case, :product => pro_info, :role => session[:prole]}, :layout => :header do
      begin
        erb :"dashboard/#{params[:product]}/#{params[:issue_name]}"
      rescue
        "<p>NO Dashboard found. You may add Dashboard at <strong>views/dashboard/#{params[:product]}/#{params[:issue_name]}.erb</strong>. <a href=\"/help/dashboard\">More</a></p>"
      end
    end
  end

  get "/api/data/:product/:issue_name" do
    content_type "application/json"
    pro_info = Product.new params[:product]
    pro_id = pro_info.id
    issue_info = $db.findOne "select * from issue where name = '#{params[:issue_name]}' and product_id = #{pro_id}"
    issue = Issue.new issue_info
    from = request["startTime"] 
    to = request["endTime"] 
    type = request["type"] || "value"
    dat = issue.data_history(from,to)
    to_ret = [{"name" => params[:issue_name],"data" => []}]
    dat.each do |line|
      t = DateTime.parse line["time"]
      if issue.unit == '%'
        to_ret[0]["data"] << [t.to_time.to_i*1000,line[type].to_f*100]
      else
        to_ret[0]["data"] << [t.to_time.to_i*1000,line[type].to_f]
      end
    end
    to_ret.to_json
  end

  get "/api/kpi/:type/:product" do
    content_type "application/json"
    pro = Product.new params[:product]
    type = params[:type]
    to_ret = [{"type" => "column","name" => type,"data" => []}]
    (0..11).each do |last|
      now = DateTime.now
      d2c = now - ( 30 * last )
      time_stamp = DateTime.parse("#{d2c.strftime("%Y-%m")}-01").to_time.to_i*1000
      kpi = pro.kpi last
      stab = (kpi)? kpi[type]:0
      to_ret[0]["data"] << [time_stamp,stab]
    end
    to_ret[0]["data"].reverse!
    to_ret.to_json
  end

  get "/do_action" do
    if session[:prole] != "op" 
      halt 401, 'Login First!'
    end
    act_dir = File.join(File.dirname(__FILE__),'../..',params[:action])
    lawyer = Lawyer.new ({
      "script" => "#{act_dir}/action.sh",
      "config" => "#{act_dir}/action.yaml",
      "token" => $config["token"],
    })
    lawyer.go
    redirect "http://archer.noah.baidu.com/ci-web/index.php?r=ProcessView/QueryTask&listid=#{lawyer.archer_id}"
  end
  
   get "/api/alarm/:type/:atime" do
    content_type "application/json"
    type = params[:type]
    if type == "no"
       type = "and follower IS NULL"
    else 
       type = ""
    end
    atime = params[:atime]
    timenow = Time.now
    etime = timenow.strftime("%Y-%m-%d %H:%M:%S")
    if atime == "1hour"
       stime = (timenow-3600).strftime("%Y-%m-%d %H:%M:%S")
    elsif atime == "3hour"
       stime = (timenow-10800).strftime("%Y-%m-%d %H:%M:%S")
    else
       stime = (timenow-86400).strftime("%Y-%m-%d %H:%M:%S")
    end
    #query_str= "select count(*) as count from alarm where time between \"#{stime}\" and \"#{etime}\" and follower #{type}"
    #p query_str
    alarm_info = $db.query "select count(*) as count from alarm where time between \"#{stime}\" and \"#{etime}\" #{type}"
    alarm_cnt = Hash.new
    alarm_info.each_hash do |row|
      alarm_cnt.store(atime,row["count"])
    end
    alarm_cnt.to_json
  end

  get "/api/:type/:product/:issue_name" do
    content_type "application/json"
  end

  get "/" do
    main_product = ["houyi","mobads","dan"]
    kpi = {}
    product_list = ProductList.new
    main_product.each do |prod|
      product = product_list.find { |p| p.name == prod }
      kpi[prod] = product.kpi_today
    end

    alert = {}
    response = RestClient.get 'http://sdc-iws.baidu.com/api/alarm/all/1day'
    resp = JSON.parse response.body
    alert[:today] = resp["1day"].to_i
    response = RestClient.get 'http://sdc-iws.baidu.com/api/alarm/all/1hour'
    resp = JSON.parse response.body
    alert[:hour] = resp["1hour"].to_i
    response = RestClient.get 'http://sdc-iws.baidu.com/api/alarm/no/1day'
    resp = JSON.parse response.body
    alert[:unclose] = resp["1day"].to_i

    trace = {}
    ["open","doing", "fixed", "pending"].each do |st|
      trace[st] = $db.list_trace_by_status(st).length
    end

    score = {}
    response = RestClient.get 'http://sdc-iws.baidu.com/api/checkpoint'
    resp = JSON.parse response.body
    main_product.each do |prod|
      score[prod] = resp[prod] || nil
    end

    monitor = {}
    response = RestClient.get 'http://m1-dan-stat00.m1.baidu.com:8281/api/dashboard'
    resp = JSON.parse response.body
    main_product.each do |prod|
      monitor[prod] = resp[prod] || nil
    end

    iop = {:today => 0, :done => 0, :todo => 0, :approv => 0}
    response = RestClient.get 'http://sdc-iop.baidu.com/statistic/icafe'
    resp = JSON.parse response.body
    list = resp["data"]
    list.each_value do |i|
      iop[:today] += 1
      iop[:done] += 1 if i["state"] == "已完成"
      iop[:todo] += 1 if i["state"] == "待OP实施操作"
      iop[:approv] += 1 if i["state"] == "审批中"
    end

    erb :dashboard, :layout => :header, :locals => { :kpi => kpi, :alert => alert, :trace => trace, :score => score, :monitor => monitor, :iop => iop }
  end

  get "/issue" do
    # product_list = ProductList.new
    # erb :sdc, :locals => {:product_list => product_list}, :layout => :header  
    erb :building, :layout => :header  
  end

  get "/alarm" do
    stime = params[:stime]
    etime = params[:etime]
    pid = params[:pid]
    proname = "Default"
    timenow = Time.now
    if !stime
        stime=(timenow-3600).strftime("%Y-%m-%d %H:%M:%S")
    end
    if !etime
        etime=timenow.strftime("%Y-%m-%d %H:%M:%S")
    end
    if !params[:pid]
        pid = ".*"
    end
    if !params[:stime] || !params[:etime]
        redirect("/alarm?stime=#{stime}&etime=#{etime}&pid=#{pid}")
    end
    product_list = ProductList.new
    galert_list = Galertlist.new 1,stime,etime,pid
    if params[:pid] && params[:pid]!=".*"
        proname = galert_list.fetch_proname pid
    end
    not_send = Galertlist.new 0,stime,etime,pid
    galert_list = galert_list + not_send
    erb :galert, :locals => {:galert_list => galert_list,:proname => proname,:product_list => product_list}, :layout => :header
  end

  post "/alarm/follow" do
    if params[:alarmid]!=NIL
      sql = "update alarm set follower=\"#{session[:user]}\" where nodename=\"#{params[:nodename]}\" and rulename=\"#{params[:rulename]}\" and time between \"#{params[:startt]}\" and '#{params[:endt]}'"
      $db.query sql
      redirect "/alarm", 302
    end
  end

  post "/alarm/trace" do
    if params[:alarmid]!=NIL
      sql = "update alarm set trace=\"yes\",follower=\"#{session[:user]}\" where nodename=\"#{params[:nodename]}\" and rulename=\"#{params[:title]}\" and time between \"#{params[:startt]}\" and '#{params[:endt]}'"
      $db.query sql
      redirect "/alarm", 302
    end
  end

  get "/check_list" do
    mach = params[:mach]
    prod = params[:prd]
    type = params[:type]
    filename = "mach.#{prod}.result"
    if type != "machine"
      filename = "modu.#{prod}.result"
    end
    timestr = Time.new
    timestr = timestr.strftime("%Y%m%d")
    filen = File.join(File.dirname(__FILE__),"../../data/#{timestr}/#{filename}")
    ycontent = YAML.load(File.open(filen))    
    if mach
      ycontent = {type=>{mach => ycontent[type][mach]}}
    else
      ycontent = {type=>ycontent[type]}
    end
    erb :check_list, :locals => {:check_list => ycontent}, :layout => :header
  end
  
  get "/check_point" do
    prod = params[:prd]
    type = params[:type]
    filename = "mach.#{prod}.point"
    if type != "machine"
      filename = "modu.#{prod}.point"
    end
    timestr = Time.new
    timestr = timestr.strftime("%Y%m%d")
    filen = File.join(File.dirname(__FILE__),"../../data/#{timestr}/#{filename}")
    ycontent = YAML.load(File.open(filen))
    ycontent.keys.each do |type|
      ycontent[type].keys.each do |key|
        if ycontent[type][key]<80
          tmp =ycontent[type][key]
          ycontent[type][key] = "<font color=red>#{tmp}"
        end
      end
    end
    erb :check_point, :locals => {:check_point => ycontent,:prod => prod}, :layout => :header
  end

  get "/check_pro" do
    timestr = Time.new
    timestr = timestr.strftime("%Y%m%d")
    dir = File.join(File.dirname(__FILE__),"../../data/#{timestr}")
    prod = `cd #{dir} && ls | grep point`.split("\n")
    prolist = Hash.new
    prod.each do | key |
      point = `cd #{dir} && cat #{key}| awk -F':' '{print $2}' | grep -v ^$ |sort -n | head -1`
      pro_name = key.split('.')[1]
      type = key.split('.')[0]
      if type =="mach"
        type="machine"
      end
      if prolist[pro_name].kind_of?NilClass
        prolist[pro_name]= Hash.new
      end
      prolist[pro_name].store(type,point)
    end
    erb :check_pro, :locals => {:ch_prod => prolist}, :layout => :header 
  end

  get "/api/checkpoint" do
    content_type "application/json"
    timestr = Time.new
    timestr = timestr.strftime("%Y%m%d")
    dir = File.join(File.dirname(__FILE__),"../../data/#{timestr}")
    prod = `cd #{dir} && ls | grep point`.split("\n")
    prolist = Hash.new
    prod.each do | key |
      point = `cd #{dir} && cat #{key}| awk -F':' '{print $2}' | grep -v ^$ |sort -n | head -1`
      pro_name = key.split('.')[1]
      type = key.split('.')[0]
      if type =="mach"
        type="machine"
      else
        type="module"
      end
      if prolist[pro_name].kind_of?NilClass
        prolist[pro_name]= Hash.new
      end
      prolist[pro_name].store(type,point.to_i)
    end
    prolist.to_json
  end

end
