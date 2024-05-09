module Turbo
  module Train
    class AnycableServer < BaseServer
      def publish(topics:, data:)
        uri = URI(server_config.publish_url)
        req = Net::HTTP::Post.new(uri)
        req['Content-Type'] = 'application/json'
        req['Authorization'] = "Bearer #{server_config.broadcast_key}"

        message = data[:data].gsub("\n", '')

        opts = {
          use_ssl: uri.scheme == 'https'
        }

        payload = []

        Array(topics).each do |topic|
          payload << { stream: topic, data: message }
        end

        req.body = payload.to_json

        opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE if configuration.skip_ssl_verification

        Net::HTTP.start(uri.host, uri.port, opts) do |http|
          http.request(req)
        end
      end

      def server_config
        configuration.anycable
      end
    end
  end
end