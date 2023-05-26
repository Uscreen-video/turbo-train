module Turbo
  module Train
    class TestServer < BaseServer
      attr_reader :configuration, :channels_data, :real_server

      def initialize(real_server, configuration)
        @configuration = configuration
        @channels_data = {}
        @real_server = real_server
      end

      def publish(topics:, data:)
        Array(topics).each do |topic|
          @channels_data[topic] ||= []
          @channels_data[topic] << data[:data]
        end

        real_server.publish(topics: topics, data: data) if real_server
      end

      def broadcasts(channel)
        channels_data[channel] ||= []
      end

      def clear_messages(channel)
        channels_data[channel] = []
      end

      def clear
        @channels_data = []
      end
    end
  end
end