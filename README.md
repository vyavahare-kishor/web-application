# Peloton x Event Processor

The pupose of this application is to receive and process incoming milestone events from various partners with which Peloton has integrated.  These milestones all:
  - contain data about different events in fulfillment life-cycle of a given order.  
  - are sent along with a token authenticating their origin with a valid Peloton partner
  - can contain data in any valid transport format (JSON, XML, etc...)

## Getting started

### Local Execution

**Prerequisites:**
- Ruby 3.2.9 — install via [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io)
- PostgreSQL 15 — `brew install postgresql@15`
- Redis 7 — `brew install redis`

```bash
cp .env.example .env
bundle install
rails db:create db:migrate
rails server
```

### Docker Execution

You can run this application using `docker-compose` using the following command

```
docker-compose up --build
```

**To run tests**
```
docker compose exec web bundle exec rspec
```

## Application Information

### Health Check

In order for Peloton Infrastructure to verify the health of this application a working health check endpoint is required

### Authenticating an integration

Milestone events are are all authenticated using the `AuthenticatedIntegration` module in @app/integrations/common/concerns/authenticated_integration.rb

### Testing + Code Style

Please ensure that all updates to this codebase are covered with appropriate RSpec tests and do not contain rubocop issues.