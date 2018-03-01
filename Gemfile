ruby '2.3.1', :engine => 'jruby', :engine_version => '9.1.6.0'

source 'http://artifactory-gojek.golabs.io/artifactory/api/gems/rubies'

gem 'rails', '4.2.5.1'
gem 'jquery-rails'
gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.19'
gem 'jar-dependencies', '~> 0.3.5'
gem 'puma', '~> 3.7'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'figaro'

gem 'devise'
gem 'devise_cas_authenticatable'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
