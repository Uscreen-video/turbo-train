# Based on: ActionCable::TestHelper
module Turbo
  module Train
    module TestHelper
      def before_setup
        test_server = case ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym
                      when :mercure
                        Turbo::Train::TestServer.new(Turbo::Train.mercure_server, Turbo::Train.configuration)
                      when :fanout
                        Turbo::Train::TestServer.new(Turbo::Train.fanout_server, Turbo::Train.configuration)
                      else
                        raise "Unknown test server: #{ENV['TURBO_TRAIN_TEST_SERVER']}"
                      end

        Turbo::Train.instance_variable_set(:@server, test_server)
        super
      end

      def after_teardown
        test_server = case ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym
                      when :mercure
                        Turbo::Train.mercure_server
                      when :fanout
                        Turbo::Train.fanout_server
                      else
                        raise "Unknown test server: #{ENV['TURBO_TRAIN_TEST_SERVER']}"
                      end

        super
        Turbo::Train.instance_variable_set(:@server, test_server)
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

      def assert_body_match(r)
        if Turbo::Train.server.real_server.is_a?(Turbo::Train::FanoutServer)
          assert_match "Published\n", r.body
        elsif Turbo::Train.server.real_server.is_a?(Turbo::Train::MercureServer)
          assert_match /urn:uuid:.*/, r.body
        else
          raise "Unknown server type"
        end
      end
    end
  end
end