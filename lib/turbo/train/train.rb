require 'jwt'
require 'net/http'

module Turbo
  module Train
    extend Turbo::Streams::ActionHelper
    extend Broadcasts

    ALGORITHM = "HS256"

    class << self
      def encode(payload)
        structured_payload = { mercure: { payload: payload } }
        JWT.encode structured_payload, configuration.subscriber_key, ALGORITHM
      end

      def signed_stream_name(streamables)
        Turbo.signed_stream_verifier.generate stream_name_from(streamables)
      end

      def server(server = nil)
        @server ||= case server || configuration.default_server
        when :mercure
          mercure_server
        when :fanout
          fanout_server
        when :anycable
          anycable_server
        else
          raise ArgumentError, "Unknown server: #{server}"
        end
      end

      def mercure_server
        raise ArgumentError, "Mercure configuration is missing" unless configuration.mercure

        @mercure_server ||= MercureServer.new(configuration)
      end

      def fanout_server
        raise ArgumentError, "Fanout configuration is missing" unless configuration.fanout

        @fanout_server ||= FanoutServer.new(configuration)
      end

      def anycable_server
        raise ArgumentError, "Anycable configuration is missing" unless configuration.anycable

        @anycable_server ||= AnycableServer.new(configuration)
      end

      def stream_name_from(streamables)
        if streamables.is_a?(Array)
          streamables.map  { |streamable| stream_name_from(streamable) }.join(":")
        else
          streamables.then { |streamable| streamable.try(:to_gid_param) || streamable.to_param }
        end
      end

      private

      def render_format(format, **rendering)
        ApplicationController.render(formats: [ format ], **rendering)
      end
    end
  end
end