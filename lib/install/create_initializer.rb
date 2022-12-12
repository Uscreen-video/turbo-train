say "Creating initializer"
create_file Rails.root.join("config/initializers/turbo_train.rb") do
  %{
Turbo::Train.configure do |config|
  config.mercure_domain = 'localhost'
  config.publisher_key = 'testing'
  config.subscriber_key = 'test'
  config.skip_ssl_verification = true # Development only; don't do this in production
end
  }
end
