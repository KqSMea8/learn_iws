#!/usr/bin/env ruby

require 'spec_helper'

describe Iws_server do
  include Rack::Test::Methods

  def app
    Iws_server
  end

  context 'Basic Function Test' do

    context 'Hello World!' do
      it "should return Hello" do
        get "/" 
        last_response.status.should == 302
      end
    end

    context 'static dir' do
      it "should return file" do
        get "/hello.html" 
        last_response.status.should == 200
        last_response.body.should == "Hello\n"
      end
    end

  end

  context '/alarm_list' do
    it "should return alarm_list" do
      get "/alarm_list" 
      last_response.status.should == 200
    end
  end

  context '/issue' do
    it "should return issue info" do
      get "/issue/columbus" 
      last_response.status.should == 200
    end

    it "should return issue info" do
      get "/issue/columbus/nginx_ff" 
      last_response.status.should == 200
    end

    it "should return sdc info when /issue" do
      get "/issue"
      last_response.status.should == 200
    end
  end

  context '/api' do
    it '/data/:pro/:issue should get issue data' do
      get 'api/data/columbus/nginx_serviceability'
      last_response.status.should == 200
    end
    it '/kpi/:type/:pro/:issue should get issue kpi' do
      get 'api/kpi/mttr/columbus/nginx_serviceability'
      last_response.status.should == 200
    end
    it '/kpi/:type/:pro should get product kpi' do
      get 'api/kpi/mttr/columbus'
      last_response.status.should == 200
    end
  end

end
