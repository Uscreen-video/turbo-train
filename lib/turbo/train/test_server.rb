module Turbo
  module Train
    class TestServer < Server
      attr_reader :configuration, :channels_data

      def initialize(configuration)
        @configuration = configuration
        @channels_data = {}
      end

      def publish(topics:, data:)
        Array(topics).each do |topic|
          @channels_data[topic] ||= []
          @channels_data[topic] << data[:data]
        end

        super
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