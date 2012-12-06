require 'statsd'

module Maestro
  module Metrics

    class Stats

      def initialize(config)
        @config = config
      end

      attr_reader :statsd

      def count(metric, value)
        statsd.count(metric, value)
      end

      def timing(metric, value)
        statsd.timing(metric, value)
      end

      def increment(metric)
        statsd.increment(metric)
      end

      def decrement(metric)
        statsd.decrement(metric)
      end

      def time(metric, &block)
        statsd.time(metric, 1, &block)
      end

      private

      def statsd
        @statsd ||= Statsd.new(@config[:statsd_host], @config[:statsd_port])
        @statsd.namespace= 'maestro-metrics'
        @statsd
      end

    end
  end

end
