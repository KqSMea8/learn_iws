#!/usr/bin/env ruby
require 'spec_helper'

describe Lawyer do
  def check_archer_dir path
    cnt = 0
    Dir.foreach "#{path}/archer_conf" do |file|
      next if file =~ /^\.\.*$/
      ["deploy.yaml","module.yaml","server.yaml","setting.yaml"].should be_include file
      cnt +=1
      proc { YAML.load_file "#{path}/archer_conf/#{file}" }.should_not raise_error
    end
    cnt.should == 4

    server = YAML.load_file "#{path}/archer_conf/server.yaml"
    server.should == {"sdcop-public.BACKUPPOOL.all" => ["all"]}
  end

  context "prepare" do

    it "should prepare pure_archer" do
      lawyer = Lawyer.new ({
        "archer_conf" => "#{res_path}/pure_action/conf"
      })
      lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end

    it "should prepare simple_archer" do
      lawyer = Lawyer.new ({
        "script" => "#{res_path}/simple_action/action.sh",
        "config" => "#{res_path}/simple_action/action.yaml"
      })
      dir = lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end

    it "should prepare command" do
      lawyer = Lawyer.new ({
        "command" => "echo haha",
        "config" => "#{res_path}/simple_action/action.yaml"
      })
      dir = lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end

  end

  context "simple_archer no conf" do
    it "should work with String" do
      lawyer = Lawyer.new ({
        "script" => "#{res_path}/simple_action/action.sh",
        "target" => "sdcop-public.BACKUPPOOL.all"
      })
      dir = lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end

    it "should work with Array" do
      lawyer = Lawyer.new ({
        "script" => "#{res_path}/simple_action/action.sh",
        "target" => ["sdcop-public.BACKUPPOOL.all"]
      })
      dir = lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end

    it "should work with Hash" do
      lawyer = Lawyer.new ({
        "script" => "#{res_path}/simple_action/action.sh",
        "target" => {"sdcop-public.BACKUPPOOL.all" => ["all"]}
      })
      dir = lawyer.prepare
      puts lawyer.prepare_path
      check_archer_dir lawyer.prepare_path
    end
  end

  context "do archer" do
    before do
      @lawyer = Lawyer.new ({
        "archer_conf" => "#{res_path}/pure_action/conf"
      })
    end

    it "should raise archer return code error" do
      @lawyer.stub(:do_archer).and_return "Success: 0\nListID: 8912116\nStatusAPI: http://archer.noah.baidu.com/ci-web/index.php?r=api/deploy/getStatus&listid=8912116\nViewURL: http://archer.noah.baidu.com/ci-web/index.php?r=ProcessView/QueryTask&listid=8912116\n"
      proc { @lawyer.archer }.should raise_error "Error in launch archer, archer return code 0"
    end

    it "should get archer id" do
      @lawyer.stub(:do_archer).and_return "Success: 1\nListID: 8912116\nStatusAPI: http://archer.noah.baidu.com/ci-web/index.php?r=api/deploy/getStatus&listid=8912116\nViewURL: http://archer.noah.baidu.com/ci-web/index.php?r=ProcessView/QueryTask&listid=8912116\n"
      @lawyer.archer
      @lawyer.archer_id.should == 8912116
    end
  end
end

