require 'maestro_metrics/stats/stats'
require 'maestro_metrics/raw/raw'
require 'singleton'

module Maestro
  module Metrics

    class Metrics

      include Singleton
      def initialize(config)
        @config = config
      end

      def log(metrics)
        raw.log(metrics)
      end

      def count(metric, value)
        stats.count(metric, value)
      end

      def timing(metric, value)
        stats.timing(metric, value)
      end

      def increment(metric)
        stats.increment(metric)
      end

      def decrement(metric)
        stats.decrement(metric)
      end

      def time(metric, &block)
        stats.time(metric, &block)
      end

      private

      def raw
        @raw ||= Raw.new(@config)
      end

      def stats
        @stats ||= Stats.new(@config)
      end


    end



  end

end