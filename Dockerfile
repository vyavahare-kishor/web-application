FROM ruby:3.2.9-alpine

RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  tzdata \
  git \
  yaml-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
