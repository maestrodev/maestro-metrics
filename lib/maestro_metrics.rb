require 'mongo'
require 'statsd'

module Maestro
  module Metrics

    class Metrics

      include Mongo

      def initialize(config)
        @config = config
      end

      def count(metric, value, sample_rate=1)
        statsd.count(metric, value, sample_rate)
      end

      def timing(metric, value, sample_rate=1)
        statsd.timing(metric, value, sample_rate)
      end

      def increment(metric, sample_rate=1)
        statsd.increment(metric, sample_rate)
      end

      def decrement(metric, sample_rate=1)
        statsd.decrement(metric, sample_rate)
      end

      def time(metric, sample_rate=1, &block)
        statsd.time(metric, sample_rate, &block)
      end

      def log(metrics)
        mongo_collection.insert(metrics)
      end

      private

      def mongo_client
        @mongo_client ||= MongoClient.new(config[:mongo_host], config[:mongo_port])
      end

      def mongo_db
        @mongo_db ||= mongo_client['maestro-metrics']
      end

      def mongo_collection
        @mongo_collection ||= mongo_db['raw']
      end


      def statsd
        @statsd ||= Statsd.new(@config[:statsd_host], @config[:statsd_port])
        @statsd.namespace= 'maestro_metrics'
        @statsd
      end

      def raw
        @raw ||= Raw.new(@config)
      end

    end



  end

end