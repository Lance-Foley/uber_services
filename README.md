# Uber Services

A marketplace platform connecting consumers who need home services with qualified service providers. Built with Rails 8.1.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

## Overview

This is an "Uber for home services" marketplace application that handles:

- **Job Requests**: Consumers post jobs (lawn care, snow removal, cleaning, etc.)
- **Bidding System**: Providers bid on available jobs
- **Payments**: Secure payments via Stripe Connect
- **Reviews**: Bidirectional reviews after job completion
- **Messaging**: In-app real-time messaging between users
- **Geolocation**: Provider search by service radius

## Tech Stack

- **Framework**: Rails 8.1
- **Ruby**: 3.5.0-preview1 (or 3.3.6+ recommended for production)
- **Database**: PostgreSQL
- **Background Jobs**: Solid Queue
- **Cache**: Solid Cache
- **WebSockets**: Solid Cable (Action Cable)
- **Frontend**: Hotwire (Turbo + Stimulus)
- **CSS**: Tailwind CSS
- **Components**: Phlex + RubyUI
- **Authentication**: Rails built-in + OmniAuth (Google/Apple)
- **Payments**: Stripe Connect
- **State Machine**: AASM
- **Geocoding**: Geocoder gem
- **Testing**: RSpec + FactoryBot

## Quick Start

### Prerequisites

- Ruby 3.3.6+ (or 3.5.0-preview1)
- PostgreSQL 14+
- Node.js 18+ (for JavaScript)
- Bundler 2.x

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Lance-Foley/uber_services.git
   cd uber_services
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

4. **Start development server**
   ```bash
   bin/dev
   ```
   
   This runs:
   - Rails server on http://localhost:3000
   - Tailwind CSS watcher (for live CSS updates)

   Or run separately:
   ```bash
   bin/rails server
   bin/rails tailwindcss:watch[always]
   ```

5. **Visit the app**
   
   Open http://localhost:3000 in your browser

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test
bundle exec rspec spec/models/user_spec.rb:15
```

### Code Quality

```bash
# Linting
bundle exec rubocop

# Security scan
bundle exec brakeman
```

## Features

### For Consumers

- Create and manage properties
- Post job requests with details and urgency levels
- Review provider bids
- Secure payment authorization
- Real-time job status updates
- Review providers after job completion
- In-app messaging with providers

### For Service Providers

- Create provider profile
- List services offered with pricing
- Browse available jobs by location
- Submit bids on jobs
- Receive Stripe Connect payments
- Review consumers after job completion
- In-app messaging with consumers

### For Administrators

- User management
- Job request monitoring
- Payment oversight
- Platform analytics

## Architecture

### Domain Models

**Users & Authentication**
- `User` - Core user model with password authentication
- `ProviderProfile` - Provider-specific data (Stripe account, ratings)
- `ConnectedService` - OAuth provider connections
- `Session` - User sessions

**Service Catalog**
- `ServiceCategory` - Top-level service groupings
- `ServiceType` - Specific services within categories
- `ProviderService` - Links providers to services with pricing

**Job Lifecycle**
- `JobRequest` - Consumer's service request (AASM state machine)
- `JobBid` - Provider's bid on a job
- `Payment` - Stripe payment with authorize/capture flow
- `Review` - Post-job reviews (bidirectional)

**Supporting Models**
- `Property` - Consumer properties with geocoding
- `Conversation` / `Message` - Real-time messaging
- `Notification` / `DeviceToken` - Push notifications

### Job State Machine

```
pending → open_for_bids → accepted → payment_authorized → 
in_progress → completed → payment_released

Alternative states: cancelled, disputed
```

### Key Design Patterns

- **Service Objects**: Complex operations in `app/services/`
- **View Components**: Phlex components in `app/views/` and `app/components/`
- **Hotwire**: Turbo Frames and Streams for dynamic updates
- **Solid Stack**: Database-backed jobs, cache, and real-time

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

### Quick Deploy to Render

1. Fork this repository
2. Go to [Render Dashboard](https://render.com/dashboard)
3. Click "New" → "Blueprint"
4. Select your fork
5. Add `RAILS_MASTER_KEY` environment variable
6. Click "Apply"

Your app will be live at `https://uber-services.onrender.com` (or your chosen name)!

### Environment Variables

Required for production:
- `RAILS_MASTER_KEY` - Decrypts credentials
- `DATABASE_URL` - PostgreSQL connection (auto-set by Render)
- `RAILS_ENV=production`

Optional:
- `STRIPE_PUBLISHABLE_KEY` / `STRIPE_SECRET_KEY`
- `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`
- `APPLE_CLIENT_ID` / `APPLE_CLIENT_SECRET`

## Project Structure

```
app/
├── channels/          # Action Cable channels
├── components/        # Phlex view components
├── controllers/       # Rails controllers
├── jobs/              # Background jobs
├── models/            # ActiveRecord models
├── services/          # Service objects
└── views/             # Phlex views

config/
├── environments/      # Environment configs
├── initializers/      # App initialization
└── routes.rb          # Route definitions

db/
├── migrate/           # Database migrations
└── seeds.rb           # Seed data

spec/
├── factories/         # FactoryBot factories
└── models/            # Model specs
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Documentation

- [CLAUDE.md](CLAUDE.md) - AI assistant guidance
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [docs/OVERVIEW.md](docs/OVERVIEW.md) - Detailed project overview

## License

This project is available as open source under the terms of the [MIT License](LICENSE).

## Support

For questions or issues:
- Open an issue on [GitHub](https://github.com/Lance-Foley/uber_services/issues)
- Check existing documentation in `/docs`

## Acknowledgments

- Built with [Rails 8.1](https://rubyonrails.org/)
- UI components from [RubyUI](https://ruby-ui.com/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Powered by [Hotwire](https://hotwired.dev/)
