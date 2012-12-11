require "spec_helper"
require 'maestro_metrics'

describe 'Stats logging' do

  @metric = 'test'

  before(:all) do
    config = { :statsd_host => '192.168.56.10', :statsd_port => 8125, :mongo_host => 'localhost', :mongo_port => 27017}
    @maestro_metrics = Maestro::Metrics::Metrics.new(config)
  end

  before(:each) do

    @statsd = double('statsd')
    @maestro_metrics.stub(:statsd => @statsd)

  end

  it 'should log counts of things' do
    value = 8
    @statsd.should_receive(:count).with(@metric, value, 1)
    @maestro_metrics.count(@metric, value)

  end

  it 'should increment a counter' do
    @statsd.should_receive(:increment).with(@metric, 1)
    @maestro_metrics.increment(@metric)
  end

  it 'should decrement a counter' do
    @statsd.should_receive(:decrement).with(@metric, 1)
    @maestro_metrics.decrement(@metric)
  end


  it 'should log timing stats' do
    @statsd.should_receive(:timing).with(@metric, 1, 1)
    @maestro_metrics.timing(@metric, 1)
  end

  it 'should time the execution of a block of code' do
    ran = false

    proc = Proc.new do
      ran = true
    end

    @statsd.should_receive(:time).with(@metric, 1, &proc)
    @maestro_metrics.time(@metric,1, &proc)
    ran.should be_true

  end

end

describe 'raw metrics logging' do

  before(:all) do
    config = { :statsd_host => '192.168.56.10', :statsd_port => 8125, :mongo_host => 'localhost', :mongo_port => 27017}
    @maestro_metrics = Maestro::Metrics::Metrics.new(config)
  end


  before(:each) do
    @collection = double('collection')
    @maestro_metrics.stub(:mongo_collection => @collection)
  end


  it "should log a hash containing raw metrics" do
    doc = { :name => 'testdoc' }
    @collection.stub(:insert => 1)
    @collection.should_receive(:insert).with(doc)

    @maestro_metrics.log(doc).should eq 1

  end
end