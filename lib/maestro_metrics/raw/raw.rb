require 'mongo'

module Maestro
  module Metrics

    class Raw

      include Mongo

      def initialize(config)
        @config = config
      end

      def log(metrics)
        collection.insert(metrics)
      end

      private

      def client
        @client ||= MongoClient.new(config[:mongo_host], config[:mongo_port])
      end

      def db
        @db ||= client['maestro-metrics']
      end

      def collection
        @collection ||= db['raw']
      end

    end

  end

end