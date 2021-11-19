source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'omniauth-oktaoauth'
gem 'activerecord-session_store'
gem "figaro"
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry-rails'
  gem 'letter_opener'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'
gem "pundit"
gem 'bootstrap', '~> 4.1.0'
gem 'bootstrap-email'

# gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'cancancan'
gem 'simple_form'
gem 'wicked'
gem 'selectize-rails'
gem 'cocoon'
gem 'jquery-ui-rails'
gem 'rails_sortable'
gem 'deep_cloneable', '~> 2.4.0'
gem 'popper_js', '~> 1.14.5'
gem 'city-state'
gem 'momentjs-rails'
gem 'time_difference'
gem 'permalink'
gem 'data-confirm-modal'
gem 'chart-js-rails'
gem 'rake_text'
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
gem 'jquery-validation-rails'

gem 'cloudinary'
gem 'activestorage-cloudinary-service'
gem 'autosize'
gem 'bootstrap-switch-rails', '~> 3.0.0'
gem 'dotenv-rails', groups: [:development, :test]

# gem truemail for checking the fake mail ids
gem 'truemail'
gem 'wicked_pdf', '~> 1.1'
gem 'will_paginate', '~> 3.3'
gem 'sidekiq',  '5.2.8'

group :development do
  # gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
  gem 'wkhtmltopdf-heroku', '~> 2.12', '>= 2.12.6.0'
end

group :production do
  # gem 'wkhtmltopdf-heroku', :git => 'https://github.com/gregnavis/wkhtmltopdf-heroku.git', :branch => 'master'
  gem 'wkhtmltopdf-heroku', '~> 2.12', '>= 2.12.6.0'
end

gem 'rollbar'