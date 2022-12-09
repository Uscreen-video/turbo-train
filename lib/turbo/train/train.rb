require 'jwt'
require 'net/http'

module Turbo
  module Train
    extend Turbo::Streams::ActionHelper

    ALGORITHM = "HS256"

    class << self
      def url
        "https://#{configuration.mercure_domain}/.well-known"
      end

      def encode(payload)
        structured_payload = { mercure: { payload: payload } }
        JWT.encode structured_payload, configuration.subscriber_key, ALGORITHM
      end

      def signed_stream_name(streamables)
        Turbo.signed_stream_verifier.generate stream_name_from(streamables)
      end

      def broadcast_action_to(*streamables, action:, target: nil, targets: nil, **rendering)
        broadcast(streamables, content: turbo_stream_action_tag(action, target: target, targets: targets, template:
          rendering.delete(:content) || rendering.delete(:html) || (rendering.any? ? render_format(:html, **rendering) : nil)
        ))
      end

      def broadcast_render_to(*streamables, **rendering)
        broadcast(*streamables, content: render_format(:turbo_stream, **rendering))
      end

      def broadcast_remove_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :remove, **opts)
      end

      def broadcast_replace_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :replace, **opts)
      end

      def broadcast_update_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :update, **opts)
      end

      def broadcast_before_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :before, **opts)
      end

      def broadcast_after_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :after, **opts)
      end

      def broadcast_append_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :append, **opts)
      end

      def broadcast_prepend_to(*streamables, **opts)
        broadcast_action_to(*streamables, action: :prepend, **opts)
      end

      private

      def domain
        Rails.configuration.turbo_train.mercure_domain
      end

      def render_format(format, **rendering)
        ApplicationController.render(formats: [ format ], **rendering)
      end

      def broadcast(streamables, content:)
        topics = if streamables.is_a?(Array)
          streamables.map { |s| signed_stream_name(s) }
        else
          [signed_stream_name(streamables)]
        end

        data = {
          topic: topics,
          data: content
        }
        payload = { mercure: { publish: topics } }
        token = JWT.encode payload, configuration.publisher_key, ALGORITHM

        uri = URI("#{url}/mercure")

        req = Net::HTTP::Post.new(uri)
        req['Content-Type'] = 'application/x-www-form-urlencoded'
        req['Authorization'] = "Bearer #{token}"
        req.body = URI.encode_www_form(data)
        opts = {
          use_ssl: uri.scheme == 'https'
        }

        if configuration.skip_ssl_verification
          opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
        end

        Net::HTTP.start(uri.host, uri.port, opts) do |http|
          http.request(req)
        end
      end

      def stream_name_from(streamables)
        if streamables.is_a?(Array)
          streamables.map  { |streamable| stream_name_from(streamable) }.join(":")
        else
          streamables.then { |streamable| streamable.try(:to_gid_param) || streamable.to_param }
        end
      end
    end
  end
end
