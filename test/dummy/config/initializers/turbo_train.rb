Turbo::Train.configure do |config|
  config.default_server = ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym

  config.mercure.mercure_domain = ENV['MERCURE_DOMAIN'] || raise('MERCURE_DOMAIN is not set')
  config.mercure.publisher_key = ENV['MERCURE_PUBLISHER_KEY'] || raise('MERCURE_PUBLISHER_KEY is not set')
  config.mercure.subscriber_key = ENV['MERCURE_SUBSCRIBER_KEY'] || raise('MERCURE_SUBSCRIBER_KEY is not set')

  config.fanout.service_url = ENV['FANOUT_SERVICE_URL'] || raise('FANOUT_SERVICE_URL is not set')
  config.fanout.service_id = ENV['FANOUT_SERVICE_ID'] || raise('FANOUT_SERVICE_ID is not set')
  config.fanout.fastly_key = ENV['FANOUT_FASTLY_KEY'] || raise('FANOUT_FASTLY_KEY is not set')
end
