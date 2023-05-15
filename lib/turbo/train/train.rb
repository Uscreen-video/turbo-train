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

      def server
        @server ||= Server.new(configuration)
      end

      def stream_name_from(streamables)
        if streamables.is_a?(Array)
          streamables.map  { |streamable| stream_name_from(streamable) }.join(":")
        else
          streamables.then { |streamable| streamable.try(:to_gid_param) || streamable.to_param }
        end
      end

      def url
        configuration.url
      end

      private

      def render_format(format, **rendering)
        ApplicationController.render(formats: [ format ], **rendering)
      end
    end
  end
end