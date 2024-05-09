# frozen_string_literal: true

module Turbo
  module Train
    class BaseServer
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def publish(topics:, data:)
        raise NotImplementedError
      end

      def server_config
        raise NotImplementedError
      end

      def publish_url
        server_config.publish_url
      end

      def listen_url(topic, **options)
        server_config.listen_url(topic, **options)
      end
    end
  end
end
