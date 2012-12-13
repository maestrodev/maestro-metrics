require 'spec_helper'
require 'maestro_metrics'

include Maestro

describe Maestro::Metrics do

  before(:all) do
    Metrics.configure( { :mongo_host => '192.168.56.10', :statsd_host => '192.168.56.10' } )
  end

  before(:each) do
    Metrics.unmock!
  end

  context 'Stats logging' do

    @metric = 'test'

    before(:each) do

      @statsd = double('statsd')
      Metrics::Real.instance.stub(:statsd => @statsd)
    end

    it 'should log counts of things' do
      value = 8
      @statsd.should_receive(:count).with(@metric, value, 1)
      Metrics.count(@metric, value)

    end

    it 'should increment a counter' do
      @statsd.should_receive(:increment).with(@metric, 1)
      Metrics.increment(@metric)
    end

    it 'should decrement a counter' do
      @statsd.should_receive(:decrement).with(@metric, 1)
      Metrics.decrement(@metric)
    end


    it 'should log timing stats' do
      @statsd.should_receive(:timing).with(@metric, 1, 1)
      Metrics.timing(@metric, 1)
    end

    it 'should time the execution of a block of code' do
      ran = false

      proc = Proc.new do
        ran = true
      end

      @statsd.should_receive(:time).with(@metric, 1, &proc)
      Metrics.time(@metric,1, &proc)
      ran.should be_true

    end

    it 'should do nothing when using a mock' do
      Metrics.mock!
      value = 8
      @statsd.should_not_receive(:count)
      Metrics.count(@metric, value)
    end

  end

  context 'raw metrics logging' do

    it 'should log a hash containing raw metrics' do

      @collection = double('collection')
      Metrics::Real.instance.stub(:mongo_collection => @collection)

      doc = { :name => 'testdoc' }
      @collection.stub(:insert => 1)
      @collection.should_receive(:insert).with(doc)

      Metrics.log("test", doc).should eq 1

    end

    it 'should log a complex document' do

      require 'mongo_mapper'

      doc = {
          :composition_id => 1,
          :run_id => 1,
          :start_time => Time.to_mongo(Time.new),
          :user=> 'maestro',
          :trigger_type => 'manual',
          :run_time => 1234,
          :wait_time => 0,
          :success => true,
          :agent_name => 'some-agent',
          :agent_host => 'agenthost.example.com',
          :tasks => [
            {
              :task_id => 1,
              :start_time =>  Time.to_mongo(Time.new),
              :run_time => 1234,
              :wait_time => 0,
              :success => true
            }
          ]
        }

      Metrics.log('runs', doc)
      results = Metrics.aggregate('runs',
                                 [ { '$group' => { '_id' => '$composition_id',
                                                   'numRuns'          => { '$sum' => 1 },
                                                   'numSuccessfulRuns' => { '$sum' => { '$cond' => [ '$success', 1, 0 ] } },
                                                   'avgRunTime'       => { '$avg' => '$run_time' },
                                                   'maxRunTime'       => { '$max' => '$run_time' },
                                                   'minRunTime'       => { '$min' => '$run_time' }
                                 }
                                   } ] )
      puts results.inspect
    end
  end
end