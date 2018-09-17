[![Build Status](https://travis-ci.org/BaritoLog/BaritoMarket.svg?branch=master)](https://travis-ci.org/BaritoLog/BaritoMarket)
[![Coverage Status](https://coveralls.io/repos/github/BaritoLog/BaritoMarket/badge.svg?branch=master)](https://coveralls.io/github/BaritoLog/BaritoMarket?branch=master)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/BaritoLog/BaritoMarket)
[![Inline docs](http://inch-ci.org/github/BaritoLog/BaritoMarket.svg)](http://inch-ci.org/github/BaritoLog/BaritoMarket)

# Barito Market
### Transports the Logs to where it should be

---
Inspired by [Barito River](https://en.wikipedia.org/wiki/Barito_River), this app will handle logs management, service discovery & log stream provisioning.

Please see details in [here](https://docs.google.com/presentation/d/1u_13mW8K3C5n5Qov8mjmvpxBY4jGyIsAgjxvTXJbDrE/edit?usp=sharing)

## Development Setup

1. Ensure you have vagrant installed
2. We should resize default vagrant disk (min 20GB). We can use vagrant plugin `git clone https://github.com/sprotheroe/vagrant-disksize.git`
3. Run `vagrant plugin install vagrant-disksize`
4. Clone this repo `git clone https://github.com/BaritoLog/BaritoMarket.git`
5. Go to BaritoMarket directory and type `vagrant up --provision`

Now you can open Barito Market from `http://192.168.20.10:8090`
and Pathfinder from `http://192.168.20.10:8080`

Run `vagrant ssh` if you want to login into virtual manchine
