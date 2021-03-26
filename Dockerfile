FROM ruby:2.5.1-slim AS base

ENV BUNDLER_VERSION 2.1.4
ENV RAILS_LOG_TO_STDOUT true

RUN apt-get -y update && \
  apt-get -y install apt-transport-https curl gnupg libpq5 shared-mime-info && \
  (curl https://baltocdn.com/helm/signing.asc | apt-key add -) && \
  (echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list) && \
  apt-get -y update && \
  apt-get -y install helm && \
  rm -vrf /var/lib/apt/lists/* && \
  gem install bundler -v "$BUNDLER_VERSION" && \
  rm -vf /usr/local/bundle/cache/*.gem && \
  useradd -mU -d /app app
WORKDIR /app

ARG RAILS_ENV=production
ARG RACK_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV RACK_ENV=${RACK_ENV}
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
ARG NODE_ENV=${RAILS_ENV}
ENV NODE_ENV=${NODE_ENV}

COPY --chown=app:app . .
RUN mv config/application.yml.example config/application.yml && \
  mv config/database.yml.example config/database.yml && \
  mv config/tps_config.yml.example config/tps_config.yml && \
  SECRET_KEY_BASE=$(printf %128s | tr ' ' '0') bundle exec rails assets:precompile

FROM base
USER app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=build /app .
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "--port", "8080"]
