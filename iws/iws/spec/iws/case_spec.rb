#!/usr/bin/env ruby

require 'spec_helper'

describe Case do

  before do
    @case = Case.new 2
  end

  it "should init with id" do
    @case = Case.new 2
    @case.id.should == 2
    @case.list.should be_kind_of Array
  end

  it "should init with defined lenght" do
    @case = Case.new 2,1
    @case.list.length.should == 1
  end

end

