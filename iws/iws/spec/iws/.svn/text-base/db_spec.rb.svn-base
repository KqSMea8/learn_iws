#!/usr/bin/env ruby

require 'spec_helper'

describe Db do

  before do
    @config = Conf.new
  end

  context 'initilize' do
    it "should set up connaction" do
      proc do
        Db.new(@config["db"])
      end.should_not raise_error
    end
    it "should raise_err if no argu is setting" do
      proc do
        Db.new
      end.should raise_error
    end
  end

  context 'query' do
    before do
      @db = Db.new @config["db"]
      @db.query "CREATE TABLE IF NOT EXISTS `test` (`test` varchar(50));"
      @db.query "INSERT INTO `test` (`test`) VALUES ('1')"
      @db.query "INSERT INTO `test` (`test`) VALUES ('2')"
    end

    it "should work ok with query" do
      res = @db.query "SELECT * FROM `test`;"
      res.each_hash do | row |
        row["test"].should =~ /[12]/
      end
      res.free
    end

    it "should work ok with list" do
      res = @db.list "SELECT * FROM `test`;"
      res.should == [{"test" => "1"},{"test" => "2"}]
    end

    it "should work ok with one" do
      res = @db.one "SELECT * FROM `test`;"
      res.should == {"test" => "1"}
    end

    context "select" do

      it "should work ok with select with where" do
        res = @db.select_list("test","`test` = '1'")
        res.should == [{"test" => "1"}]
      end

      it "should work ok with select" do
        res = @db.select_list("test")
        res.should == [{"test" => "1"},{"test" => "2"}]
      end
    
    end

    context "find" do

      it "should work ok with list_a" do
        res = @db.list_test
        res.should == [{"test" => "1"},{"test" => "2"}]
      end

      it "should work ok with findOne_a_by_b" do
        res = @db.findOne_test_by_test("2")
        res.should == {"test" => "2"}
      end

    end

    after do
      @db.query "DROP TABLE `test`;"
    end

  end


end
