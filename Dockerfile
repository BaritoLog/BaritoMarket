FROM ruby:2.5.5-slim AS base

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV RACK_ENV=${RAILS_ENV}

RUN apt-get -y update && \
  apt-get -y install libcurl4 libpq5 && \
  rm -vrf /var/lib/apt/lists/* && \
  gem install bundler -v "~>2.0" && \
  rm -vf /usr/local/bundle/cache/*.gem && \
  useradd -mU -d /app app
WORKDIR /app

FROM base AS build

RUN apt-get -y update && \
  apt-get install -y build-essential libpq-dev nodejs
USER app

COPY --chown=app:app Gemfile* ./
RUN bundle config --local deployment 'true' && \
  bundle config --local without $(echo 'development test' | sed "s/\\s*$RAILS_ENV\\s*//g") && \
  bundle install && \
  rm -vf /usr/local/bundle/ruby/*/cache/*.gem

ENV DB_NAME barito_production

COPY --chown=app:app . .
RUN mv config/application.yml.example config/application.yml && \
  mv config/database.yml.example config/database.yml && \
  mv config/tps_config.yml.example config/tps_config.yml && \
  SECRET_KEY_BASE=$(printf %128s | tr ' ' '0') bundle exec rails assets:precompile

FROM base
USER app

ENV RAILS_LOG_TO_STDOUT=true

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=build /app .
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "--port", "8080"]
