#!/usr/bin/env ruby

require 'spec_helper'

describe Conf do

  before do
    @config_file = "./conf/iws.yml"
  end

  context "initilize" do

    it "should read config" do
      proc do
        Conf.new(@config_file)
      end.should_not raise_error
    end

    it "should return default value if config_file not set" do
      c = Conf.new
      c.should == c.default_value
    end

  end

end
