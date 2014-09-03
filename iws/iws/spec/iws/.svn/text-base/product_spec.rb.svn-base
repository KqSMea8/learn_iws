#!/usr/bin/env ruby

require 'spec_helper'

describe Product do

  before do
    @product = Product.new 1
  end

  it "should init with id" do
    @product.name.should == "columbus"
  end

  it "should init by name" do
    pro = Product.new "columbus"
    @product.name.should == "columbus"
  end

  it "should get kpi" do
    @product.get_kpi 
    @product.kpi1.should be_kind_of Float
  end

  it "should get today's kpi" do
    @product.kpi_today.should be_kind_of Float
  end

  it "should update kpi" do
    @product.update_kpi  
    @product.kpi.should be_kind_of Hash
  end

  it "should get proname" do
    ProductList.fetch_name(1).should == "columbus"
  end

  it "should get proname" do
    ProductList.fetch_id("columbus").should == 1
  end


end

