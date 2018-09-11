[![Build Status](https://travis-ci.org/BaritoLog/BaritoMarket.svg?branch=master)](https://travis-ci.org/BaritoLog/BaritoMarket)
[![Coverage Status](https://coveralls.io/repos/github/BaritoLog/BaritoMarket/badge.svg?branch=master)](https://coveralls.io/github/BaritoLog/BaritoMarket?branch=master)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/BaritoLog/BaritoMarket)
[![Inline docs](http://inch-ci.org/github/BaritoLog/BaritoMarket.svg)](http://inch-ci.org/github/BaritoLog/BaritoMarket)

# Barito Market
### Transports the Logs to where it should be

---
Inspired by [Barito River](https://en.wikipedia.org/wiki/Barito_River), this app will handle logs management, service discovery & log stream provisioning.

Please see details in [here](https://docs.google.com/presentation/d/1u_13mW8K3C5n5Qov8mjmvpxBY4jGyIsAgjxvTXJbDrE/edit?usp=sharing)

### Prerequisite for development environment
* Install [Homebrew](http://brew.sh/)
* Install [Hombrew Cask](http://caskroom.io/)
* Install rbenv using Homebrew `brew install rbenv`
* Install Postgres using Homebrew `brew install postgresql`
* Install Bundler using RubyGems `gem install bundler`

### Setup
> Note: You can run `./devbox.sh` from project directory which automatically do these steps.

* Run `gem install bundler`
* Copy over configuration files and modify as necessary
  - `config/application.yml.example` to `config/application.yml`
  - `config/database.yml.example` to `config/database.yml`
  - `config/tps_config.yml.example` to `config/tps_config.yml`
* Run `bundle install` to install project gem dependencies
* Create and migrate the databases:
  - `RAILS_ENV=development bundle exec rake db:create db:migrate`
  - `RAILS_ENV=test bundle exec rake db:create db:migrate`

* Set `GATE_URL` to current running GATE server
* You can turn off GATE integration by setting `ENABLE_CAS_INTEGRATION` to `false` in `application.yml`
* Run seeds `RAILS_ENV=development rake db:seed`
* Set `GATE_ACCESS_TOKEN` to communicate with GATE API

### Running
* Run `RAILS_ENV=development bundle exec rake` to run the build
* Run `RAILS_ENV=development bundle exec rake coverage:all` to generate coverage reports
* Run `bundle exec rails s` to run the server.

### Rake task

All tasks reside in `lib/tasks`
