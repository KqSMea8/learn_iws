require 'spec_helper'

describe Issue do

  before do
    @issue = Issue.new 1
  end

  context "initilize" do
    before do
      issue_list = IssueList.new 
    end

    it "should return issue list" do
      issue_list = IssueList.new 
      issue_list[0].name.should == "nginx_serviceability"
      issue_list[0].product.should == "columbus"
    end

    it "should return issue list by id" do
      issue_list = IssueList.new 1
      issue_list.each do |issue|
        issue.product_id.should == "1"
      end
    end

    it "should init issue" do
      issue = Issue.new 1
      issue.name.should == "nginx_serviceability"
      issue.product.should == "columbus"
    end

    it "should return json" do
      issue_list = IssueList.new
      issue_list.to_json
    end
    
  end

  context "action" do
    before do
      @issue = Issue.new 1
    end

    it "should be list" do
      @issue.actions.should be_kind_of Array
    end
  end

  context "update data" do

    it "should work with time" do
      d = rand.round 3
      t = DateTime.new(2013,12,25,15,12,25)
      @issue.update_data(d,t)
      @issue.data(t).should == d
    end

    it "should work when time not match in sec" do
      d = rand.round 3
      t = DateTime.new(2013,12,25,15,12,25)
      @issue.update_data(d,t)
      t = DateTime.new(2013,12,25,15,12,45)
      @issue.data(t).should == d
    end

    it "should query from remote if value is not set" do
      Noah2.stub(:cb_nginx_finally_failed_total).and_return(60.0)
      Noah2.stub(:cb_nginx_flow_total).and_return(100.0)
      @issue.data.should == 0.99
    end

    it "should get recent data" do
      @issue.recent_data.should be_kind_of Hash
    end

  end

  context "state machine" do

    it "should get last state" do
      @issue.last_state.should =~ /fine|warn|error|missing/
    end

    it "should get recent state" do
      @issue.recent_state.should =~ /fine|warn|error|missing/
    end

    it "should update state" do
      @issue.update_state "error"
      @issue.last_state.should == "error"
    end
  end

  context "data_calc" do

    it "should work" do
      Noah2.stub(:cb_nginx_finally_failed_total).and_return(60.0)
      Noah2.stub(:cb_nginx_flow_total).and_return(100.0)
      @issue.fetch_data.should == 0.99
    end

  end

  context "normalized" do
    it "should work" do
      @issue.stub(:data_normalized).and_return("input*2")
      @issue.send("normalize",0.1).should == 0.2
    end

    it "should between 0 and 1" do
      @issue.stub(:data_normalized).and_return("-1")
      @issue.send("normalize",0).should == 0
      @issue.stub(:data_normalized).and_return("2")
      @issue.send("normalize",0).should == 1
    end
  end

  context "kpi" do
    it "should should not raise error" do
      proc do
        @issue.calc_kpi
      end.should_not raise_error  
    end
    it "should calc last month" do
      proc do
        @issue.calc_kpi 1
      end.should_not raise_error  
    end
    it "should return kpi" do
      @issue.kpi.should be_kind_of Hash
    end

    it "kpi today should return float" do
      @issue.kpi_today.should be_kind_of Float
    end

  end

  context "case" do
    it "should avg kpi" do
      @issue.stub(:last_fine).and_return("2014-01-10 15:30:00")
      @issue.add_case
    end
  end

end
