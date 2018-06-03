gem install bundler
cp -n config/application.yml.example config/application.yml
cp -n config/database.yml.example config/database.yml
cp -n config/tps_config.yml.example config/tps_config.yml
bundle install
RAILS_ENV=development bundle exec rake db:create db:migrate
RAILS_ENV=test bundle exec rake db:create db:migrate
