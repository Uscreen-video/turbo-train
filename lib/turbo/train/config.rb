module Turbo
  module Train
    class MercureConfiguration
      attr_accessor :mercure_domain, :publisher_key, :subscriber_key

      def initialize
        super
        @mercure_domain = 'localhost'
        @publisher_key = 'test'
        @subscriber_key = 'testing'
      end

      def url
        "https://#{mercure_domain}/.well-known"
      end

      def publish_url
        "#{url}/mercure"
      end

      def listen_url(topic, platform: 'web')
        "#{url}/mercure?topic=#{Turbo::Train.signed_stream_name(topic)}&authorization=#{jwt_auth_token({ platform: platform })}"
      end

      def jwt_auth_token(payload)
        structured_payload = { mercure: { payload: payload } }
        JWT.encode structured_payload, subscriber_key, ALGORITHM
      end
    end

    class FanoutConfiguration
      attr_accessor :fastly_api_url, :service_url, :fastly_key, :service_id

      def initialize
        super
        @fastly_api_url = 'https://api.fastly.com'
        @service_url = 'https://johnny-cage-fake-url.edgecompute.app'
        @fastly_key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      end

      def publish_url
        "#{@fastly_api_url}/service/#{@service_id}/publish/"
      end

      def listen_url(topic, **)
        "#{service_url}/stream/sse?topic=#{Turbo::Train.signed_stream_name(topic)}"
      end
    end

    class Configuration
      attr_accessor :skip_ssl_verification, :mercure, :fanout, :default_server

      def initialize
        @skip_ssl_verification = Rails.env.development? || Rails.env.test?
        @mercure = nil
        @fanout = nil
        @default_server = :mercure
      end

      def server(server_name)
        case server_name
        when :mercure
          @mercure ||= MercureConfiguration.new
          yield(@mercure)
        when :fanout
          @fanout ||= FanoutConfiguration.new
          yield(@fanout)
        else
          raise ArgumentError, "Unknown server name: #{server_name}"
        end
      end
    end

    class << self
      attr_accessor :configuration

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end
    end
  end
end
