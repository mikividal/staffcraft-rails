source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.5'

# Core
gem 'rails', '~> 7.1.0'
gem 'sqlite3', '~> 1.4'  # SQLite for local development
gem 'puma', '~> 6.0'

# Background jobs
gem 'sidekiq', '~> 7.0'
gem 'redis', '~> 5.0'

# HTTP & API
gem 'httparty'
gem 'faraday'

# Frontend
gem 'bootstrap', '~> 5.3'
gem 'sassc-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem "importmap-rails"
gem "simple_form"

# Utilities
gem 'dotenv-rails'
gem 'bootsnap', require: false

group :development, :test do
  gem 'debug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'gemini-ai', '~> 4.3'
