require 'spec_helper'
require 'maestro_metrics'

describe 'Stats logging' do

  @metric = 'test'

  before(:all) do
    config = { :statsd_host => '192.168.56.10', :statsd_port => 8125}
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
    config = { :mongo_host => '192.168.56.10', :mongo_port => 27017}
    @maestro_metrics = Maestro::Metrics::Metrics.new(config)
  end


  before(:each) do
    @collection = double('collection')
    @maestro_metrics.stub(:mongo_collection => @collection)
  end


  it 'should log a hash containing raw metrics' do
    @collection = double('collection')
    @maestro_metrics.stub(:mongo_collection => @collection)


    doc = { :name => 'testdoc' }
    @collection.stub(:insert => 1)
    @collection.should_receive(:insert).with(doc)

    @maestro_metrics.log("test", doc).should eq 1

  end

  #it 'should log a complex document' do
  #
  #  require 'mongo_mapper'
  #
  #  doc = {
  #      :composition_id => 1,
  #      :run_id => 1,
  #      :start_time => Time.to_mongo(Time.new),
  #      :user=> 'maestro',
  #      :trigger_type => 'manual',
  #      :run_time => 1234,
  #      :wait_time => 0,
  #      :success => true,
  #      :agent_name => 'some-agent',
  #      :agent_host => 'agenthost.example.com',
  #      :tasks => [
  #        {
  #          :task_id => 1,
  #          :start_time =>  Time.to_mongo(Time.new),
  #          :run_time => 1234,
  #          :wait_time => 0,
  #          :success => true
  #        }
  #      ]
  #    }
  #
  #  @maestro_metrics.log('runs', doc)
  #  results = @maestro_metrics.aggregate('runs',
  #                             [ { '$group' => { '_id' => '$composition_id',
  #                                               'numRuns'          => { '$sum' => 1 },
  #                                               'numSuccessfulRuns' => { '$sum' => { '$cond' => [ '$success', 1, 0 ] } },
  #                                               'avgRunTime'       => { '$avg' => '$run_time' },
  #                                               'maxRunTime'       => { '$max' => '$run_time' },
  #                                               'minRunTime'       => { '$min' => '$run_time' }
  #                             }
  #                               } ] )
  #end
end