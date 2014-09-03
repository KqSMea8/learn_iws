#!/usr/bin/env ruby

# Action lunancher using archer
# @author Wen Li
class Lawyer
  attr_reader :config, :prepare_path, :archer_id

  def initialize conf={}
    read_conf conf
  end

  # do all process
  def go
    prepare
    archer
  end

  def prepare
    mkprepare_path
    if @config["archer_conf"]
      prepare_pure_archer
    else
      prepare_simple_archer
    end
  end

  def mkprepare_path
    @prepare_path = "#{@config["prepare_dir"]}/lawyer/#{Time.new.strftime("%F_%H-%M-%S-%3N")}"
    raise "Two actions in one second!" if Dir.exist? prepare_path
    FileUtils.mkdir_p "#{@prepare_path}/archer_conf"
  end

  def prepare_pure_archer
    FileUtils.cp_r "#{@config["archer_conf"]}/.", "#{@prepare_path}/archer_conf"
  end

  def prepare_simple_archer
    FileUtils.mkdir_p "#{@prepare_path}/tmp/bin"

    # control
    timestamp = Time.new.strftime("%F_%H-%M-%S")
    ctl = File.new("#{@prepare_path}/tmp/bin/control","w")
    ctl.puts <<HD_CONTROL
#!/bin/bash 
[[ "$1" != "start" ]] && exit 0
cd #{@config["target_dir"]}/#{@config["name"]}/#{timestamp}/bin || {
  echo "action dir not exist!"
  exit 1
}
HD_CONTROL

    # action script
    if @config["script"]
      script_name = File.basename @config["script"]
      FileUtils.cp "#{@config["script"]}", "#{@prepare_path}/tmp/bin"
      FileUtils.chmod 0755, "#{@prepare_path}/tmp/bin/#{script_name}"
      ctl.puts <<HD_CONTROL
./#{script_name} || {
  echo "run #{script_name} fail."
  exit 2
}
HD_CONTROL
    end

    # command
    if @config["command"]
      ctl.puts <<HD_CONTROL
#{@config["command"]} || {
  echo "run command fail."
  exit 3
}
HD_CONTROL
    end
    ctl.close
    FileUtils.chmod 0755, "#{@prepare_path}/tmp/bin/control"

    # package
    FileUtils.mkdir_p "#{@prepare_path}/tar"
    system "cd #{@prepare_path}/tmp && tar zcvf ../tar/action.tgz * &>/dev/null"
    system "cd #{@prepare_path}/tar && md5sum action.tgz > action.tgz.md5"
    package = "ftp://#{`hostname`.chomp}/#{@prepare_path}/tar/action.tgz"

    # server.yaml
    server = {}
    if @config["target"].kind_of? String
      server[@config["target"]] = ["all"]
    elsif @config["target"].kind_of? Array
      @config["target"].each do |bns|
        server[bns] = ["all"]
      end
    elsif @config["target"].kind_of? Hash
      server = @config["target"]
    else
      raise "Error in server target config,should be kind of String/Hash/Array"
    end
    dump_yaml "#{@prepare_path}/archer_conf/server.yaml", server

    # module.yaml 
    mod = {
      "#{@config["name"]}/#{timestamp}" => [{
        "src" => package
      }]
    }
    dump_yaml "#{@prepare_path}/archer_conf/module.yaml", mod

    # deploy.yaml
    deploy = {
      "tagconcurrency" => 1,
      "tags" => {}
    }
    server.each do |bns,value|
      deploy["tags"][bns] = {
        "concurrency" => @config["concurrency"],
        "pausepoint" => @config["pausepoint"],
        "account" => "work",
        "deploypath" => @config["target_dir"],
      }
    end
    dump_yaml "#{@prepare_path}/archer_conf/deploy.yaml", deploy

    # setting.yaml
    setting = {
      "limitrate" => "3m",
      "token" => @config["token"],
    }
    dump_yaml "#{@prepare_path}/archer_conf/setting.yaml", setting
  end

  def archer 
    cmd_response = do_archer
    ret = YAML.load cmd_response
    if ret["Success"] != 1
      raise "Error in launch archer, archer return code #{ret["Success"]}"
    end
    @archer_id = ret["ListID"]
  end

  def do_archer 
    begin
      cmd_ret = `archer2 -c #{@prepare_path}/archer_conf`
    rescue => err
      raise "Error in launch archer task, #{err}"
    end
    cmd_ret
  end

  def read_conf conf
    @config = default_config
    @config.merge! conf
    if conf["config"] && File.exist?(conf["config"])
      conf_file = conf["config"]
      begin 
        c = YAML.load_file(conf_file) 
        @config.merge! c if c != false
      rescue => err
        raise "Error in read config. #{err}."
      end
    end

    if !@config["archer_conf"] && !@config["script"] && !@config["command"]
      raise "Error in config. Either archer_conf/script/command must be defined."
    end
  end

  def default_config
    {
      "name" => "action",
      "prepare_dir" => "/tmp",
      "pausepoint" => 1,
      "concurrency" => 1,
      "target_dir" => "/home/work/opdir/lawyer",
    }
  end

  private
  def dump_yaml filepath, value
    File.open(filepath, "wb") {|f| YAML.dump(value, f) }
    system "sed -i 's/^- /  - /' #{filepath}"
  end


end
