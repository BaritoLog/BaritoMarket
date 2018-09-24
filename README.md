[![Build Status](https://travis-ci.org/BaritoLog/BaritoMarket.svg?branch=master)](https://travis-ci.org/BaritoLog/BaritoMarket)
[![Coverage Status](https://coveralls.io/repos/github/BaritoLog/BaritoMarket/badge.svg?branch=master)](https://coveralls.io/github/BaritoLog/BaritoMarket?branch=master)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/BaritoLog/BaritoMarket)
[![Inline docs](http://inch-ci.org/github/BaritoLog/BaritoMarket.svg)](http://inch-ci.org/github/BaritoLog/BaritoMarket)

# Barito Market
### Transports logs to where it should be

---
Inspired by [Barito River](https://en.wikipedia.org/wiki/Barito_River), this app will handle logs management, service discovery & log stream provisioning.

Read the details [here](https://docs.google.com/presentation/d/1u_13mW8K3C5n5Qov8mjmvpxBY4jGyIsAgjxvTXJbDrE/edit?usp=sharing)

## Development Setup

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
