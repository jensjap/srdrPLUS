FROM ruby:3.1.2-slim

ENV BUNDLER_VERSION=2.3.15

RUN apt-get update -qq && apt-get install -y \
      build-essential \
      libmariadb-dev \
      libmariadb-dev-compat \
      libxml2-dev \
      libxslt1-dev \
      libffi-dev \
      git \
      curl \
      libssl-dev \
      pkg-config \
      tzdata \
      nodejs \
      yarn \
      && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v $BUNDLER_VERSION

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform true

RUN bundle config build.nokogiri --use-system-libraries

RUN bundle install

COPY . ./

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
