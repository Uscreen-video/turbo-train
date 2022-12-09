say "Creating initializer"
create_file Rails.root.join("config/initializers/turbo_train.rb") do
  %{
Turbo::Train.configure do |config|
  config.mercure_domain = 'localhost'
  config.publisher_key = 'test'
  config.subscriber_key = 'testing'
end
  }
end
