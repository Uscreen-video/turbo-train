Turbo::Train.configure do |config|
  config.mercure_domain = ENV['MERCURE_DOMAIN']
  config.publisher_key = ENV['MERCURE_PUBLISHER_KEY']
  config.subscriber_key = ENV['MERCURE_SUBSCRIBER_KEY']
end
