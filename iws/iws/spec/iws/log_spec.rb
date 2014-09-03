#!/usr/bin/env ruby

require 'spec_helper'

describe Logger do

  before do
    @log = Logger.new "./log/iws.log.test"
  end

  it "should log data" do
    @log << "haha"
  end


  after do
    @log.close
  end

end

