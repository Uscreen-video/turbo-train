module Turbo
  module Train
    class TestServer
      attr_reader :configuration, :channels_data

      def initialize(configuration)
        @configuration = configuration
        @channels_data = {}
        @real_server = Turbo::Train::Server.new(configuration)
      end

      def publish(topics:, data:)
        Array(topics).each do |topic|
          @channels_data[topic] ||= []
          @channels_data[topic] << data[:data]
        end
        puts @channels_data
        @real_server.publish(topics: topics, data: data)
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