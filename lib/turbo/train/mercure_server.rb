module Turbo
  module Train
    class MercureServer < BaseServer
      def publish(topics:, data:)
        payload = { mercure: { publish: topics } }
        token = JWT.encode payload, server_config.publisher_key, ALGORITHM

        uri = URI(publish_url)

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

      def server_config
        configuration.mercure
      end
    end
  end
end