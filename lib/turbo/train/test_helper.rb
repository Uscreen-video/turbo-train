# Based on: ActionCable::TestHelper
module Turbo
  module Train
    module TestHelper
      def before_setup
        Turbo::Train.instance_variable_set(:@server, Turbo::Train::TestServer.new(Turbo::Train.configuration))
        super
      end

      def after_teardown
        super
        Turbo::Train.instance_variable_set(:@server, Turbo::Train::Server.new(Turbo::Train.configuration))
      end

      def assert_broadcast_on(stream, data, &block)
        signed_stream_name = Turbo::Train.signed_stream_name(stream)

        new_messages = Turbo::Train.server.broadcasts(signed_stream_name)
        if block_given?
          old_messages = new_messages
          Turbo::Train.server.clear_messages(signed_stream_name)

          assert_nothing_raised(&block)
          new_messages = Turbo::Train.server.broadcasts(signed_stream_name)
          Turbo::Train.server.clear_messages(signed_stream_name)

          # Restore all sent messages
          (old_messages + new_messages).each { |m| Turbo::Train.server.broadcasts(signed_stream_name) << m }
        end

        message = new_messages.find { |msg| msg == data }
        if message.nil?
          puts "signed_stream_name => #{signed_stream_name}"
          puts "channels_data: #{Turbo::Train.server.channels_data.inspect}}"
        end

        assert message, "No messages sent with #{data} to #{Turbo::Train.stream_name_from(stream)}"
      end
    end
  end
end