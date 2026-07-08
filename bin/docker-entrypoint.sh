#!/bin/sh
set -e

if [ "$1" = "puma" ]; then
  bundle exec rake db:create db:migrate
fi

exec bundle exec "$@"
