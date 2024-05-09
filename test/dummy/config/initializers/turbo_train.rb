# frozen_string_literal: true

Turbo::Train.configure do |config|
  config.default_server = ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym

  if ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym == :mercure
    config.server :mercure do |mercure|
      mercure.mercure_domain = ENV['MERCURE_DOMAIN'] || raise('MERCURE_DOMAIN is not set')
      mercure.publisher_key = ENV['MERCURE_PUBLISHER_KEY'] || raise('MERCURE_PUBLISHER_KEY is not set')
      mercure.subscriber_key = ENV['MERCURE_SUBSCRIBER_KEY'] || raise('MERCURE_SUBSCRIBER_KEY is not set')
    end
  end

  if ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym == :fanout
    config.server :fanout do |fanout|
      fanout.service_url = ENV['FANOUT_SERVICE_URL'] || raise('FANOUT_SERVICE_URL is not set')
      fanout.service_id = ENV['FANOUT_SERVICE_ID'] || raise('FANOUT_SERVICE_ID is not set')
      fanout.fastly_key = ENV['FANOUT_FASTLY_KEY'] || raise('FANOUT_FASTLY_KEY is not set')
    end
  end

  if ENV.fetch('TURBO_TRAIN_TEST_SERVER', 'mercure').to_sym == :anycable
    config.server :anycable do |anycable|
      anycable.anycable_url = ENV['ANYCABLE_URL'] || raise('ANYCABLE_URL is not set')
      anycable.broadcast_key = ENV['ANYCABLE_BROADCAST_KEY'] || raise('ANYCABLE_BROADCAST_KEY is not set')
    end
  end
end
