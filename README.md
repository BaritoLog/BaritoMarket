[![Build Status](https://travis-ci.org/BaritoLog/BaritoMarket.svg?branch=master)](https://travis-ci.org/BaritoLog/BaritoMarket)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/BaritoLog/BaritoMarket)

# Barito Market
### Transports logs to where it should be

---
Inspired by [Barito River](https://en.wikipedia.org/wiki/Barito_River), this app will handle logs management, service discovery & log stream provisioning.

Read the details on our wiki, [here](https://github.com/BaritoLog/wiki)

## Quick Development Setup

1. Ensure you have vagrant installed
2. Default vagrant disk should be resized (min 20GB). We will use vagrant plugin for this:
   - Do `git clone https://github.com/sprotheroe/vagrant-disksize.git`
   - Run `vagrant plugin install vagrant-disksize`
3. Clone this repo `git clone https://github.com/BaritoLog/BaritoMarket.git`
4. Go inside directory that you just cloned and type `vagrant up --provision`
5. Grab a coffee, it will automatically setup everything :)

Now you can open Barito Market at `http://192.168.20.10:8090` (username: `superadmin@barito.com`, password: `123456`)
and Pathfinder Container Manager at `http://192.168.20.10:8080` (username: `admin`, password: `pathfinder`)

Run `vagrant ssh` if you want to login into virtual machine that was just created.

#### Newrelic Support
If you want to enable Newrelic monitoring on your BaritoMarket deployment, you just have to create these additional keys on your environment variables:
```
NEWRELIC_LICENSE_KEY                - Your Newrelic license key
NEWRELIC_APP_NAME                   - Your application name (identifer) on Newrelic
NEWRELIC_AGENT_ENABLED              - Set it true if you want Newrelic agent to runs
```

## Development

### Requirements

These tools are required for developing in local machine:

- [Ruby](https://www.ruby-lang.org/en/downloads) version 2.5.1, or you can use RVM, or equivalent tools.
- [PostgreSQL](https://postgresql.org/download).

## Testing

To run unit tests:

1. Ensure you have development requirement installed on your local machine.
2. Copy `config/application.yml.example` to `config/application.yml` and configure according to your system. Example: database host, username, etc.
3. Copy `config/tps_config.yml.example` to `config/tps_config.yml`.
4. Copy `config/database.yml.example` to `config/database.yml`.
5. Install Gem dependencies by running `bundle install`.
6. Migrate the database by running `RAILS_ENV=test bundle exec rake db:migrate`.
7. Run the test by running `bundle exec rspec`.
