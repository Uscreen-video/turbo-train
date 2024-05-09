source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in turbo-train-test.gemspec.
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "6.1")

if rails_version == "main"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}.0"
end

group :development, :test do
  gem "rails", rails_constraint
  gem "sprockets-rails"
  gem 'importmap-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'puma'
  gem 'capybara', '>= 3.39.2'
  gem 'rexml'
  gem 'selenium-webdriver', '4.20.0'
  gem 'sqlite3', '~> 1.4'
end

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
