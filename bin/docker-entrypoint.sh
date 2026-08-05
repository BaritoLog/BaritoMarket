#!/bin/sh
set -e

if [ "$1" = "puma" ]; then
  if [ "$RAILS_ENV" != "production" ]; then
    bundle exec rake db:create
  fi
  bundle exec rake db:migrate
fi

exec bundle exec "$@"
