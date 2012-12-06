require 'spec_helper'

describe Maestro::Metrics::Stats do

  @metric = 'metric'

  before(:all) do
    config = { :statsd_host => 'localhost', :statsd_port => 9125}
    @stats = Maestro::Metrics::Stats.new(config)
  end

  before(:each) do

    @statsd = double('statsd')
    @stats.stub(:statsd => @statsd)

  end

  it 'should log counts of things' do
    value = 8
    @statsd.should_receive(:count).with(@metric, value)
    @stats.count(@metric, value)

  end

  it 'should increment a counter' do
    @statsd.should_receive(:increment).with(@metric)
    @stats.increment(@metric)
  end

  it 'should decrement a counter' do
    @statsd.should_receive(:decrement).with(@metric)
    @stats.decrement(@metric)
  end


  it 'should log timing stats' do
    @statsd.should_receive(:timing).with(@metric, 1)
    @stats.timing(@metric, 1)
  end

  it 'should time the execution of a block of code' do
    ran = false

    proc = Proc.new do
      ran = true
    end

    @statsd.should_receive(:time).with(@metric, 1, &proc)
    @stats.time(@metric, &proc)
    ran.should be_true

  end
end