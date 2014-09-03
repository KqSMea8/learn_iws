#!/usr/bin/env ruby
require 'spec_helper'

describe Noah2 do

  context ":get" do
    it "should return Float" do
      Noah2.stub(:noahquery).and_return 0.5
      Noah2.get("cb_nginx_flow_total").should == 0.5
      Noah2.cb_nginx_flow_total.should == 0.5
      Noah2["cb_nginx_flow_total"].should == 0.5
    end
  end

  context ":get_data" do
    it "should return Hash" do
      Noah2.get_data("cb_nginx_flow_total").should be_kind_of Hash
    end
  end

  context ":noahquery" do
    it "should return Float" do
      case $os
      when :centos
        Noah2.noahquery("avg","BAIDU_RD_ECOMRD_ECOM-QAOP_COLUMBUS_OP-HUDSON","CPU_IDLE").should be_kind_of Float
      when :redhat
        Noah2.noahquery("sum","BAIDU_ECOM_SDC_COLUMBUS_CB-NGINX_CB","cb-nginx-flow_total").should be_kind_of Float
      end
    end
  end

end

describe RestAPI do
  it ":query should return Float" do
    RestAPI.query("http://10.50.35.55:8057/data/FF.php").should be_kind_of Float
  end

  it "should work" do
    RestAPI.nginx_ff.should be_kind_of Float
  end
end

describe Noah3 do
  it ":query should return 1" do
   Noah3.query("http://mt.noah.baidu.com/visualize/index.php?r=warning/queryStatus&rule=mobads-se.MOBADS.all:instance:ct_inc_proc_mon").to_s.should == "1"
  end

  it ":domain test" do
   # Noah3.get("cbjs_e_shifen_com").to_s.should == "1"
#    Noah3["cbjs_e_shifen_com"].to_s.should =~ /^[01]$/
    #Noah3."cbjs.e.shifen.com".to_s.should =~ /^[01]$/
     Noah3.cbjs_e_shifen_com.to_s.should == "1"
#    Noah3.get_data("cbjs_e_shifen_com").should be_kind_of Hash
  end

end

describe Noah2Series do
  it ":query should return" do
    ret = Noah2Series.noahquery("sum","BAIDU_ECOM_SDC_COLUMBUS_CB-NGINX_CB","cb-nginx-flow_total","20140303000000","20140304000000")
    ret.should > 2e10
  end
  it ":query should return" do
    ret = Noah2Series.cb_nginx_flow_total
    ret.should > 2e10
  end
end
