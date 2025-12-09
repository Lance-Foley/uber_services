# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an "Uber for home services" marketplace Rails 8.1 application connecting consumers who need home services (lawn care, snow removal, cleaning, etc.) with service providers. The platform handles the full lifecycle: job requests, bidding, payments via Stripe Connect, and reviews.

## Development Commands

```bash
# Start development server (runs web + Tailwind CSS watcher)
bin/dev

# Or run separately:
bin/rails server
bin/rails tailwindcss:watch[always]

# Database
bin/rails db:create db:migrate
bin/rails db:seed

# Run all tests
bundle exec rspec

# Run single test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test by line number
bundle exec rspec spec/models/user_spec.rb:15

# Linting
bundle exec rubocop

# Security scan
bundle exec brakeman
```

## Architecture

### Core Domain Models

**Users & Roles:**
- `User` - Single user model; providers are users with a `ProviderProfile`
- `ProviderProfile` - Provider-specific data (Stripe account, ratings, service radius)
- `ConnectedService` - OAuth provider connections (Google, Apple)

**Services:**
- `ServiceCategory` - Top-level groupings (e.g., "Lawn Care", "Snow Removal")
- `ServiceType` - Specific services within categories (e.g., "Mowing", "Driveway Plowing")
- `ProviderService` - Links providers to services they offer with pricing

**Job Lifecycle:**
- `JobRequest` - Consumer's request for service; uses AASM state machine
- `JobBid` - Provider's bid on a job request
- `Payment` - Stripe-backed payments with authorize/capture/release flow
- `Review` - Bidirectional reviews after job completion

**Supporting:**
- `Property` - Consumer's properties with geocoding
- `Conversation` / `Message` - In-app messaging between users
- `Notification` / `DeviceToken` - Push notifications

### Job Request State Machine (AASM)

States flow: `pending` → `open_for_bids` → `accepted` → `payment_authorized` → `in_progress` → `completed` → `payment_released`

Also: `cancelled`, `disputed`

### Key Patterns

**View Components:** Uses Phlex (`app/views/`, `app/components/`) with RubyUI component library. RubyUI provides pre-built Phlex components with their own Stimulus controllers for interactive behavior.

**Service Objects:** Located in `app/services/` (e.g., `Oauth::CreateUserService`)

**Authentication:** Rails 8 built-in authentication (`has_secure_password`) plus OmniAuth for Google/Apple OAuth

**Payments:** Stripe Connect marketplace model - platform authorizes payment, releases to provider's connected account after job completion

## Tech Stack

- Rails 8.1, Ruby (see .ruby-version)
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Tailwind CSS via tailwindcss-rails
- Phlex for view components
- RSpec + FactoryBot for testing
- AASM for state machines
- Geocoder for location services
- Solid Queue/Cache/Cable for background jobs and real-time
