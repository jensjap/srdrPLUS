FROM ruby:3.4

ENV BUNDLER_VERSION=2.6.8 \
      LOGGER_VERSION=1.7.0

RUN apt-get update -qq && apt-get install -y curl

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

RUN apt-get install -y nodejs \
    && npm install --global yarn

RUN apt-get update -qq && apt-get install -y \
      build-essential \
      libmariadb-dev \
      libmariadb-dev-compat \
      libxml2-dev \
      libxslt1-dev \
      libffi-dev \
      git \
      libssl-dev \
      pkg-config \
      tzdata \
      && rm -rf /var/lib/apt/lists/*

RUN gem install logger -v ${LOGGER_VERSION} --no-document \
      && gem install bundler -v ${BUNDLER_VERSION} --no-document

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform false \
      && bundle config build.nokogiri --use-system-libraries

RUN bundle install --jobs 4 --retry 3

COPY . ./

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
