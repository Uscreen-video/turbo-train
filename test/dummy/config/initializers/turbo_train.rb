Turbo::Train.configure do |config|
  config.mercure_domain = ENV['MERCURE_DOMAIN'] || raise('MERCURE_DOMAIN is not set')
  config.publisher_key = ENV['MERCURE_PUBLISHER_KEY'] || raise('MERCURE_PUBLISHER_KEY is not set')
  config.subscriber_key = ENV['MERCURE_SUBSCRIBER_KEY'] || raise('MERCURE_SUBSCRIBER_KEY is not set')
end
