# Barito Market
### Transports the Logs to where it should be
---

Inspired by [Barito River](https://en.wikipedia.org/wiki/Barito_River), this app will
handle logs management, service discovery & log stream provisioning for GO-PAY System.

### Setting up development environment

* Install [Homebrew](http://brew.sh/)
* Install [Hombrew Cask](http://caskroom.io/)
* Install rbenv using Homebrew `brew install rbenv`
* Install ruby-build using Homebrew `brew install ruby-build`
* Install Java 8 using Homebrew Cask `brew cask install java`
* Install JRuby 9.1.6.0 using rbenv `rbenv install jruby-9.1.6.0`
* Install Postgres using Homebrew `brew install postgresql`
* Install Bundler using RubyGems `gem install bundler`

### Setup

Note: You can run `./devbox.sh` from project directory which does the project initialization.

* Run `gem install bundle`
* Run `bundle install` to install project gem dependencies
* Run `jbundle install` to install jar dependencies
* Copy over `config/application.yml.example` to `config/application.yml`
* Modify `config/application.yml` based on your environment
* Create the databases: `RAILS_ENV=development bundle exec rake db:create db:migrate prepare_local`
* Migrate the test database: `RAILS_ENV=test rake db:migrate`
* Run `RAILS_ENV=development bundle exec rake` to run the build
* Run `RAILS_ENV=development bundle exec rake coverage:all` to generate coverage reports
* Run `bundle exec rails s` to run the server.

### Rake task

All tasks resides in `lib/tasks`

* `prepare_local` will initialize dummy data for local development
