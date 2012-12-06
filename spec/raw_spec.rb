require 'spec_helper'

describe 'raw metrics logging' do

  before(:all) do
    config = { :mongo_host => 'localhost', :mongo_port => 27017}
    @raw = Maestro::Metrics::Raw.new(config)
  end


  before(:each) do
    @collection = double('collection')
    @raw.stub(:collection => @collection)
  end


  it "should log a hash containing raw metrics" do
    doc = { :name => 'testdoc' }
    @collection.stub(:insert => 1)
    @collection.should_receive(:insert).with(doc)

    @raw.log(doc).should eq 1

  end
end