# frozen_string_literal: true

module Turbo
  module Train
    class FanoutServer < BaseServer
      def publish(topics:, data:)
        uri = URI(server_config.publish_url)
        req = Net::HTTP::Post.new(uri)
        req['Fastly-Key'] = server_config.fastly_key

        message = data[:data].gsub("\n", '')
        payload = { items: [] }

        Array(topics).each do |topic|
          payload[:items] << { channel: topic,
                               formats: { 'http-stream': { content: "event: message\ndata: #{message}\n\n" } } }
        end

        req.body = payload.to_json

        opts = {
          use_ssl: uri.scheme == 'https'
        }

        opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if configuration.skip_ssl_verification

        Net::HTTP.start(uri.host, uri.port, opts) do |http|
          http.request(req)
        end
      end

      def server_config
        configuration.fanout
      end
    end
  end
end
