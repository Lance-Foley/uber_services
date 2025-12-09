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

---

## Namespace Conventions

This project follows strict namespacing conventions for maintainability and scalability. **All new code MUST follow these patterns.**

### Controllers (`app/controllers/`)

Controllers are organized by domain/user-role namespaces with dedicated base controllers.

```
app/controllers/
├── application_controller.rb           # Global base
├── concerns/
│   ├── controllers/                    # Namespaced controller concerns
│   │   ├── authentication.rb           # Controllers::Authentication
│   │   └── authorization.rb            # Controllers::Authorization
├── admin/
│   ├── base_controller.rb              # Admin::BaseController
│   ├── dashboard_controller.rb         # Admin::DashboardController
│   └── users_controller.rb             # Admin::UsersController
├── provider/
│   ├── base_controller.rb              # Provider::BaseController
│   ├── services_controller.rb          # Provider::ServicesController
│   └── bids_controller.rb              # Provider::BidsController
├── api/
│   └── v1/
│       ├── base_controller.rb          # Api::V1::BaseController
│       └── job_requests_controller.rb  # Api::V1::JobRequestsController
├── job_requests/                       # Nested resource controllers
│   ├── bids_controller.rb              # JobRequests::BidsController
│   └── reviews_controller.rb           # JobRequests::ReviewsController
└── omniauth/
    └── sessions_controller.rb          # Omniauth::SessionsController
```

**Rules:**
- Each namespace MUST have a `BaseController` that inherits from `ApplicationController`
- Nested controllers inherit from their namespace's `BaseController`
- API controllers MUST be versioned (`Api::V1::`, `Api::V2::`, etc.)
- Use resource nesting for parent-child relationships (`JobRequests::BidsController`)

### Models (`app/models/`)

Models stay flat but concerns MUST be namespaced by domain.

```
app/models/
├── application_record.rb
├── concerns/
│   ├── jobs/                           # Job-related concerns
│   │   ├── stateable.rb                # Jobs::Stateable
│   │   └── priceable.rb                # Jobs::Priceable
│   ├── users/                          # User-related concerns
│   │   ├── authenticatable.rb          # Users::Authenticatable
│   │   └── notifiable.rb               # Users::Notifiable
│   └── payments/                       # Payment-related concerns
│       └── stripeable.rb               # Payments::Stripeable
├── job_request.rb
├── job_bid.rb
└── user.rb
```

**Rules:**
- Model files remain flat (no subdirectories for models themselves)
- Concerns MUST be namespaced by domain in subdirectories
- Concern modules follow pattern: `DomainName::ConcernName`

### Service Objects (`app/services/`)

Services are namespaced by domain/feature area.

```
app/services/
├── base_service.rb                     # Optional shared base class
├── oauth/
│   └── create_user_service.rb          # Oauth::CreateUserService
├── jobs/
│   ├── create_request_service.rb       # Jobs::CreateRequestService
│   ├── accept_bid_service.rb           # Jobs::AcceptBidService
│   └── complete_service.rb             # Jobs::CompleteService
├── payments/
│   ├── authorize_service.rb            # Payments::AuthorizeService
│   ├── capture_service.rb              # Payments::CaptureService
│   └── refund_service.rb               # Payments::RefundService
├── notifications/
│   └── send_push_service.rb            # Notifications::SendPushService
└── stripe/
    ├── connect_account_service.rb      # Stripe::ConnectAccountService
    └── webhook_handler_service.rb      # Stripe::WebhookHandlerService
```

**Rules:**
- Services follow pattern: `Namespace::VerbNounService`
- Use `call` class method pattern with Result objects
- Group by domain, not by action type

### Phlex Components (`app/components/`)

Components use the `Components::` namespace with domain groupings.

```
app/components/
├── base.rb                             # Components::Base
├── icons.rb                            # Components::Icons module
├── shared/                             # Shared UI components
│   ├── page_header.rb                  # Components::Shared::PageHeader
│   ├── empty_state.rb                  # Components::Shared::EmptyState
│   └── flash_messages.rb               # Components::Shared::FlashMessages
├── navigation/                         # Navigation components
│   ├── top_nav.rb                      # Components::Navigation::TopNav
│   └── bottom_nav.rb                   # Components::Navigation::BottomNav
├── job_requests/                       # Job request domain
│   ├── job_request_card.rb             # Components::JobRequests::JobRequestCard
│   └── job_status_badge.rb             # Components::JobRequests::JobStatusBadge
├── bids/                               # Bid domain
│   └── bid_card.rb                     # Components::Bids::BidCard
├── reviews/                            # Review domain
│   └── star_rating_input.rb            # Components::Reviews::StarRatingInput
└── ruby_ui/                            # Third-party RubyUI (don't modify)
    └── ...
```

**Rules:**
- All components inherit from `Components::Base`
- Use `Shared::` for reusable UI primitives (buttons, cards, etc.)
- Domain components match model/feature areas
- Never modify `ruby_ui/` - it's a third-party library

### Phlex Views (`app/views/`)

Views use the `Views::` namespace mirroring controller structure.

```
app/views/
├── base.rb                             # Views::Base
├── layouts/
│   ├── application_layout.rb           # Views::Layouts::ApplicationLayout
│   └── public_layout.rb                # Views::Layouts::PublicLayout
├── dashboard/
│   └── index.rb                        # Views::Dashboard::Index
├── job_requests/
│   ├── index.rb                        # Views::JobRequests::Index
│   ├── show.rb                         # Views::JobRequests::Show
│   ├── new.rb                          # Views::JobRequests::New
│   ├── edit.rb                         # Views::JobRequests::Edit
│   ├── job_request_form.rb             # Views::JobRequests::JobRequestForm (partial)
│   └── bids/                           # Nested resources
│       ├── index.rb                    # Views::JobRequests::Bids::Index
│       └── show.rb                     # Views::JobRequests::Bids::Show
├── provider/                           # Provider namespace
│   ├── services/
│   │   ├── index.rb                    # Views::Provider::Services::Index
│   │   └── new.rb                      # Views::Provider::Services::New
│   └── my_jobs/
│       └── index.rb                    # Views::Provider::MyJobs::Index
└── admin/                              # Admin views (ERB legacy OK)
    └── ...
```

**Rules:**
- Views mirror controller namespaces exactly
- Naming: `Views::ControllerNamespace::ActionName`
- Form partials: `Views::ResourceName::ResourceNameForm`
- All views inherit from `Views::Base`

### Stimulus Controllers (`app/javascript/controllers/`)

Stimulus controllers use directory-based namespacing.

```
app/javascript/controllers/
├── application.js
├── index.js
├── hello_controller.js                 # hello (app-level)
├── forms/                              # Form-related controllers
│   ├── auto_submit_controller.js       # forms--auto-submit
│   ├── validation_controller.js        # forms--validation
│   └── dynamic_fields_controller.js    # forms--dynamic-fields
├── maps/                               # Map-related controllers
│   └── location_picker_controller.js   # maps--location-picker
├── payments/                           # Payment-related controllers
│   └── stripe_controller.js            # payments--stripe
├── notifications/                      # Notification controllers
│   └── push_controller.js              # notifications--push
└── ruby_ui/                            # RubyUI (don't modify)
    └── ...
```

**Data Attribute Pattern:**
```html
<!-- Namespaced controller -->
<div data-controller="forms--validation">

<!-- Multiple controllers -->
<div data-controller="forms--validation payments--stripe">
```

**Rules:**
- Directory names become controller prefixes with `--` separator
- Use lowercase kebab-case for filenames
- Group by feature/domain, not by behavior type
- Never modify `ruby_ui/` controllers

### API Versioning

All API endpoints MUST be versioned from the start.

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :job_requests, only: [:index, :show, :create]
    resources :users, only: [:show, :update]
  end
end

# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!
      
      respond_to :json
    end
  end
end
```

**Rules:**
- Version in URL path: `/api/v1/resources`
- Each version has its own `BaseController`
- Never break backwards compatibility within a version
- Deprecate versions with minimum 6-month notice

### Spec Organization (`spec/`)

Specs mirror the app structure exactly.

```
spec/
├── controllers/
│   ├── admin/
│   │   └── users_controller_spec.rb
│   └── provider/
│       └── services_controller_spec.rb
├── models/
│   └── concerns/
│       └── jobs/
│           └── stateable_spec.rb
├── services/
│   ├── oauth/
│   │   └── create_user_service_spec.rb
│   └── payments/
│       └── authorize_service_spec.rb
├── components/
│   └── shared/
│       └── page_header_spec.rb
└── system/                             # Feature specs by user flow
    ├── consumer/
    │   └── job_request_flow_spec.rb
    └── provider/
        └── bidding_flow_spec.rb
```

---

## Code Style Enforcement

### File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Controllers | `snake_case_controller.rb` | `users_controller.rb` |
| Models | `snake_case.rb` | `job_request.rb` |
| Services | `snake_case_service.rb` | `create_user_service.rb` |
| Components | `snake_case.rb` | `job_status_badge.rb` |
| Views | `snake_case.rb` | `index.rb`, `show.rb` |
| Stimulus | `kebab-case_controller.js` | `auto-submit_controller.js` |

### Module/Class Declaration

Always use explicit nesting, never compact notation:

```ruby
# GOOD - explicit nesting
module Admin
  class UsersController < Admin::BaseController
  end
end

# BAD - compact notation
class Admin::UsersController < Admin::BaseController
end
```

### Autoload Paths

Custom autoload paths are configured in `config/application.rb`:

```ruby
config.autoload_paths += %W[
  #{config.root}/app/services
  #{config.root}/app/components
]
```
