source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.4'

gem 'rails', '3.2.16'
gem 'puma'
gem 'warbler'
gem 'jruby-jars', '1.7.4'

gem 'epdq', :git => "https://github.com/alphagov/epdq.git", :branch => "gds_master"

gem 'exception_notification', "3.0.1"
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification

gem 'logstasher', '0.4.1'

if ENV['GOVUK_TEMPLATE_DEV']
  gem 'govuk_template', :path => "../govuk_template"
else
  gem 'govuk_template', '0.1.0'
end

group :assets do
  gem 'sass-rails', "3.2.6"
  gem 'govuk_frontend_toolkit', '0.32.2'

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'capybara', '1.1'
  gem 'ci_reporter'
  gem 'simplecov-rcov', '0.2.3'
  gem 'webmock', '1.9.0', :require => false
end
