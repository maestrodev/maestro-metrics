require 'maestro_metrics/version'
require 'singleton'
require 'mongo'
require 'statsd'

module Maestro
  module Metrics

    @mocking = false
    @config = {}

    def Metrics.mock!
      @mocking = true
    end

    def Metrics.unmock!
      @mocking = false
    end

    def Metrics.mock?
      @mocking
    end

    def Metrics.mocking?
      @mocking
    end

    def self.configure(config={})
      @config = config unless config.nil?
    end

    def Metrics.count(metric, value, sample_rate=1)
      logger.count(metric, value, sample_rate)
    end

    def Metrics.timing(metric, value, sample_rate=1)
      logger.timing(metric, value, sample_rate)
    end

    def Metrics.increment(metric, sample_rate=1)
      logger.increment(metric, sample_rate)
    end

    def Metrics.decrement(metric, sample_rate=1)
      logger.decrement(metric, sample_rate)
    end

    def Metrics.time(metric, sample_rate=1, &block)
      logger.time(metric, sample_rate, &block)
    end

    def Metrics.log(collection, metrics)
      logger.log(collection, metrics)
    end

    def Metrics.aggregate(collection, pipeline=nil)
      logger.aggregate(collection, pipeline)
    end

    def Metrics.find(collection, selector={}, opts={})
      logger.find(collection, selector, opts)
    end

    def Metrics.to_mongo(value)
      if value.nil? || value == ''
        nil
      else
        date = value.is_a?(::Date) || value.is_a?(::Time) ? value : ::Date.parse(value.to_s)
        ::Time.utc(date.year, date.month, date.day)
      end
      rescue
      nil
    end

    protected

    def self.config
      @config
    end

    private

    def self.logger
      self.mocking? ? Mock.instance : Real.instance
    end

    class Real

      include Mongo
      include Singleton

      def initialize
        @mongo_host = Metrics.config[:mongo_host] || 'localhost'
        @mongo_port = Metrics.config[:mongo_port] || 27017
        @statsd_host = Metrics.config[:statsd_host] || 'localhost'
        @statsd_port = Metrics.config[:statsd_port] || 8125
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

      def log(collection, metrics)
        mongo_collection(collection).insert(metrics)
      end

      def aggregate(collection, pipeline=nil)
        mongo_collection(collection).aggregate(pipeline)
      end

      def find(collection, selector={}, opts={})
        mongo_collection(collection).find(selector, opts)
      end

      private

      def mongo_client
        @mongo_client ||= MongoClient.new(@mongo_host, @mongo_port)
      end

      def mongo_db
        @mongo_db ||= mongo_client['maestro-metrics']
      end

      def mongo_collection(name)
        mongo_db[name]
      end

      def statsd
        @statsd ||= Statsd.new(@statsd_host, @statsd_port)
        @statsd.namespace= 'maestro_metrics'
        @statsd
      end

    end

  end

  class Mock

    include Singleton

    def count(metric, value, sample_rate=1)

    end

    def timing(metric, value, sample_rate=1)

    end

    def increment(metric, sample_rate=1)

    end

    def decrement(metric, sample_rate=1)

    end

    def time(metric, sample_rate=1, &block)

    end

    def log(collection, metrics)
      -1
    end

    def aggregate(collection, pipeline=nil)
      Array.new
    end

    def find(collection, selector={}, opts={})
      Array.new
    end

  end

end