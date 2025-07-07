source "https://rubygems.org"

ruby "3.3.5"  # Mantén tu versión actual

# Core Rails
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

# Frontend (Rails estándar)
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Background Jobs (StaffCraft)
gem 'sidekiq', '~> 7.0'

# Authentication & Authorization (StaffCraft)
gem 'devise'
gem 'jwt'
gem 'pundit'

# API & Serialization (StaffCraft)
gem 'fast_jsonapi'
gem 'kaminari'
gem 'rack-cors'

# HTTP Client (StaffCraft)
gem 'httparty'
gem 'faraday'

# Utilities
gem 'dotenv-rails'
gem 'redis', '>= 4.0.1'  # Descomentado para Sidekiq
gem "bootsnap", require: false

# Validation & Form Handling (StaffCraft)
gem 'dry-validation'
gem 'reform'

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  # Testing gems (StaffCraft)
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
end

group :development do
  gem "web-console"
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'annotate'
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  # Additional testing (StaffCraft)
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner-active_record'
end
