gem install bundle
cp -n config/application.yml.example config/application.yml
cp -n config/database.yml.example config/database.yml
bundle install
bundle exec jbundle install
RAILS_ENV=development bundle exec rake db:create db:migrate prepare_local
RAILS_ENV=test rake db:migrate
