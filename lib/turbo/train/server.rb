module Turbo
  module Train
    class Server
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def publish(topics:, data:)
        payload = { mercure: { publish: topics } }
        token = JWT.encode payload, configuration.publisher_key, ALGORITHM

        uri = URI("#{configuration.url}/mercure")

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
    end
  end
end