# Parachute / met-art-ruby

This Rails application powers a small art cataloging service that integrates
with The Met's API and provides a simple UI for managing art records.

## Requirements

- Ruby: 4.0.1 (see `.ruby-version`)
- Bundler
- SQLite3 (development/test)
- Image processing library for Active Storage variants (ImageMagick or libvips)
- Docker (optional)

The project uses Rails ~> 8.1 with importmap and Hotwire (Turbo + Stimulus).

## Quickstart (development)

1. Install Ruby 4.0.1 and Bundler:

```bash
gem install bundler
bundle install
```

2. Install system deps (macOS example):

```bash
brew install sqlite imagemagick # or libvips
```

3. Setup the database:

```bash
bin/rails db:create db:migrate db:seed
```

4. Start the Rails server:

```bash
bin/rails server
# then open http://localhost:3000
```

Notes:
- Credentials are stored in `config/credentials.yml.enc`. Use `bin/rails credentials:edit` to manage them.

## Running in Docker (optional)

Build and run a development container:

```bash
docker build -t parachute .
docker run --rm -p 3000:3000 -e RAILS_ENV=development parachute
```

Adjust volumes and environment variables as needed for local development.

## Tests

Run the test suite with:

```bash
bin/rails test
```

System tests (Capybara + Selenium) are available in the `test/system` folder.

## Linters & Security Scans

Useful helper tasks are included; run them from the project root:

```bash
bundle exec brakeman    # static analysis for common security issues
bundle exec bundler-audit # checks for vulnerable gems
rubocop                 # code style and static analysis
```

Some helper binaries are provided in `bin/` (e.g., `bin/brakeman`, `bin/bundler-audit`).

## Deployment

This project includes a `Dockerfile` and integrates with `kamal` for container-based
deployments. For simple deployments, build the Docker image and run it in your
environment. For production, ensure you:

- Set `RAILS_ENV=production` and precompile assets.
- Configure a production database (Postgres or other supported adapter).
- Provide credentials and environment secrets.

## Notes for contributors

- The app uses importmap (no Node/Yarn required for basic usage).
- Hotwire (Turbo) is used for progressive enhancement; links that perform non-GET
	actions should use `data-turbo-method` or `button_to` so Turbo can handle them.
- Active Storage is configured; install ImageMagick or libvips to enable image variants.
