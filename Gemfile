# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in turbo-train-test.gemspec.
gemspec

rails_version = ENV.fetch('RAILS_VERSION', '6.1')

rails_constraint = if rails_version == 'main'
                     { github: 'rails/rails' }
                   else
                     "~> #{rails_version}.0"
                   end

group :development, :test do
  gem 'dotenv-rails'
  gem 'importmap-rails'
  gem 'rails', rails_constraint
  gem 'sprockets-rails'
end

group :test do
  gem 'capybara'
  gem 'puma'
  gem 'rexml'
  # Locked because on 4.9.1 getting error:
  # BroadcastingTest#test_Turbo::Train_broadcasts_Turbo_Streams:
  # ArgumentError: wrong number of arguments (given 2, expected 0..1)
  #     selenium-webdriver-4.9.1/lib/selenium/webdriver/common/logger.rb:51:in `initialize'
  # https://github.com/SeleniumHQ/selenium/issues/12013
  gem 'selenium-webdriver', '4.9.0'
  gem 'sqlite3'
  gem 'webdrivers', '= 5.3.0'
end

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
