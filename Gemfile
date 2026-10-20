source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Config helps you easily manage environment specific settings in an easy and usable manner.
gem "config", "~> 5.6.1"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 2.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

# Alba is a JSON serializer for Ruby, JRuby, and TruffleRuby.
gem "alba", "~> 4.0.0"
# Agile pagination
gem "pagy", "~> 43.8"

# Catch unsafe migrations in development
gem "strong_migrations", "~> 2.8.0"

# Seamlessly adds a Swagger to Rails-based API's
gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  # Help to kill N+1 queries and unused eager loading
  gem "bullet"

  # Pry is a runtime developer console and IRB alternative with powerful introspection capabilities.
  gem "pry", "~> 0.16.0"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Shoulda Matchers provides RSpec and Minitest-compatible one-liners to test common Rails functionality
  gem "shoulda-matchers", "~> 8.0"

  # Seamlessly adds a Swagger to Rails-based API's
  gem "rswag-specs"

  # Code smell detector for Ruby
  gem "reek", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "rspec-rails", "~> 8.0.0"

  # Generate (almost) realistic fake data for testing, demos, and populating your database during development.
  gem "ffaker", require: false

  # A gem providing "time travel" and "time freezing" capabilities
  gem "timecop", "~> 0.9.11", require: false

  # factory_bot is a fixtures replacement with a straightforward definition syntax
  gem "factory_bot_rails", require: false
end
