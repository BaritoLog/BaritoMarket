# Barito Market

## Centralized Log Management Platform

**Barito Market** is a web-based platform for managing log infrastructure, service discovery, and log stream provisioning. Named after the [Barito River](https://en.wikipedia.org/wiki/Barito_River), this application handles the complex task of log management in distributed systems.

## Overview

Barito Market serves as the central control plane for the Barito logging ecosystem, providing:

- **Infrastructure Provisioning**: Automated setup of logging clusters
- **Service Discovery**: Application registration and cluster assignment  
- **User Management**: Role-based access control and authentication
- **Monitoring**: Dashboard for cluster health and log statistics
- **API Gateway**: RESTful APIs for integration with other Barito components

For detailed architecture and concepts, visit our [wiki](https://github.com/BaritoLog/wiki).

## Features

- 🏗️ **Automated Cluster Provisioning** - Deploy logging infrastructure on-demand
- 🔍 **Service Discovery** - Automatic application to cluster mapping
- 👥 **Multi-tenancy** - Isolated logging environments per application group
- 📊 **Monitoring Dashboard** - Real-time cluster and application metrics
- 🔐 **Authentication** - SSO integration and role-based access
- 🔌 **API-First** - Complete REST API for automation and integration

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

### Newrelic Support

If you want to enable Newrelic monitoring on your BaritoMarket deployment, you just have to create these additional keys on your environment variables:

```bash
NEWRELIC_LICENSE_KEY                - Your Newrelic license key
NEWRELIC_APP_NAME                   - Your application name (identifer) on Newrelic
NEWRELIC_AGENT_ENABLED              - Set it true if you want Newrelic agent to runs
```

## Development

### Requirements

These tools are required for developing in local machine:

- [Ruby](https://www.ruby-lang.org/en/downloads) version 2.5.1, or you can use RVM, or equivalent tools.
- [PostgreSQL](https://postgresql.org/download).

### Run via Docker Compose

```shell
docker compose up --build
# migrate database if needed
docker exec -it baritomarket-web-1 bundle exec rake db:migrate
```

## Testing

To run unit tests:

1. Ensure you have development requirement installed on your local machine.
2. Copy `config/application.yml.example` to `config/application.yml` and configure according to your system. Example: database host, username, etc.
3. Copy `config/tps_config.yml.example` to `config/tps_config.yml`.
4. Copy `config/database.yml.example` to `config/database.yml`.
5. Install Gem dependencies by running `bundle install`.
6. Migrate the database by running `RAILS_ENV=test bundle exec rake db:migrate`.
7. Run the test by running `bundle exec rspec`.
