say "Creating initializer"
create_file Rails.root.join("config/initializers/turbo_train.rb") do
  %{
Turbo::Train.configure do |config|
  config.skip_ssl_verification = true # Development only; don't do this in production
  config.default_server =  # Default value is :mercure

  config.server :mercure do |mercure|
    mercure.mercure_domain = 'localhost'
    mercure.publisher_key = 'testing'
    mercure.subscriber_key = 'test'
  end

  config.server :fanout do |fanout|
    fanout.service_url = ''
    fanout.service_id = ''
    fanout.fastly_key = ''
  end
end
  }
end
