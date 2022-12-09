module Turbo
  module Train
    class Configuration
      attr_accessor :mercure_domain, :publisher_key, :subscriber_key, :skip_ssl_verification

      def initialize
        @mercure_domain = 'localhost'
        @publisher_key = 'test'
        @subscriber_key = 'testing'
        @skip_ssl_verification = Rails.env.development? || Rails.env.test?
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
