# Uber Services - Application Overview

## Executive Summary

Uber Services is an on-demand home services marketplace that connects homeowners with local service providers for seasonal property maintenance. The platform enables homeowners to quickly request services like snow removal or lawn care, receive competitive bids from qualified providers, and pay securely through the app.

### Core Value Proposition

- **For Homeowners:** Fast, reliable access to vetted local service providers with transparent pricing and secure payments
- **For Providers:** A steady stream of local jobs with guaranteed payment and minimal administrative overhead

---

## Service Categories

### Winter Services (24-Hour Response)

Winter services are designed for urgent, weather-dependent needs with expedited response times.

| Service | Description |
|---------|-------------|
| **Snow Removal / Driveway Plowing** | Clearing driveways and parking areas of snow accumulation |
| **Snow Shoveling** | Manual clearing of sidewalks, walkways, and smaller areas |
| **Deicing / Salt Treatment** | Application of ice melt or salt to prevent ice formation |
| **Roof Snow Clearing** | Removal of heavy snow loads from roofs to prevent damage |

### Summer / Landscaping Services

Seasonal lawn and yard maintenance services.

| Service | Description |
|---------|-------------|
| **Lawn Mowing** | Regular grass cutting and edging |
| **Leaf Raking** | Removal of fallen leaves from lawns and gardens |
| **Trimming** | Hedge, bush, and ornamental plant trimming |

---

## User Types & Authentication

The platform supports two distinct user types, each with a separate registration and login experience.

### Consumers (Homeowners)

Homeowners seeking property maintenance services.

**Account Features:**
- Email/password registration or OAuth via Google/Apple
- Property management (multiple addresses supported)
- Service request creation and tracking
- Bid review and provider selection
- Secure payment processing
- Review and rating system

### Service Providers

Local professionals offering home services.

**Account Features:**
- Dedicated provider registration flow
- Provider profile with business name and bio
- Stripe Connect onboarding for secure payouts
- Configurable service radius (1-100 miles)
- Service offerings with custom pricing
- Availability schedule management
- Performance metrics (rating, reviews, completed jobs)

---

## Core User Journeys

### Consumer Journey

```
1. Sign Up / Log In
   └── Create account or authenticate via Google/Apple

2. Add Property
   └── Register property address with size classification

3. Request Service
   ├── Select service type (e.g., Snow Removal)
   ├── Choose date and time window
   ├── Set urgency level (Normal / Urgent / Emergency)
   └── Add special instructions

4. Review Bids
   ├── Receive bids from available providers
   ├── Compare pricing, ratings, and estimated arrival
   └── View provider profiles and reviews

5. Accept Bid
   └── Payment authorization (hold placed on card)

6. Track Job
   ├── Real-time status updates
   ├── In-app messaging with provider
   └── Push notifications for status changes

7. Job Completion
   ├── Provider marks work complete
   └── Payment released after 24-hour hold

8. Leave Review
   └── Rate provider (1-5 stars) with optional comment
```

### Provider Journey

```
1. Sign Up as Provider
   └── Create account and provider profile

2. Stripe Onboarding
   └── Complete Stripe Connect setup for payouts

3. Configure Services
   ├── Select services offered
   ├── Set pricing (hourly / per-job / by property size)
   └── Define service radius

4. Browse Job Requests
   └── View available jobs within service area

5. Submit Bids
   ├── Enter bid amount
   ├── Provide estimated arrival time
   ├── Include message to homeowner
   └── Specify estimated duration

6. Complete Job
   ├── Accept job when bid is chosen
   ├── Mark job as started
   ├── Communicate via in-app messaging
   └── Mark job as complete

7. Receive Payment
   └── Automatic payout (85%) after 24-hour hold

8. Respond to Reviews
   └── View and respond to customer feedback
```

---

## Key Platform Features

### Bidding System
- Multiple providers can bid on each job request
- Consumers see bid amount, provider rating, and estimated arrival
- Accepting a bid automatically rejects other bids

### Urgency Pricing
| Level | Multiplier | Use Case |
|-------|------------|----------|
| Normal | 1.0x | Standard scheduling |
| Urgent | 1.25x | Same-day service needed |
| Emergency | 1.5x | Immediate response required |

### Property Size Pricing
Providers can set pricing tiers based on property size:
- Small
- Medium
- Large
- Extra Large

### In-App Messaging
- Direct communication between consumer and provider
- Conversation created when bid is accepted
- Push notifications for new messages

### Push Notifications
Triggered for key events:
- New bid received
- Bid accepted/rejected
- Job started
- Job completed
- Payment released
- New message
- New review

### Automated Payment Release
- Payment authorized when bid is accepted
- 24-hour hold after job completion
- Automatic release to provider's Stripe account
- Dispute window for consumer protection

### Bidirectional Review System
- Both parties can review each other after job completion
- 1-5 star rating with optional comment
- Reviewee can respond to reviews
- Provider ratings displayed on profile

---

## Business Model

### Revenue
- **15% platform fee** on all completed transactions
- Fee calculated from final job price
- Provider receives 85% of payment

### Payment Flow
```
Consumer Payment ($100)
    │
    ├── Platform Fee: $15 (15%)
    │
    └── Provider Payout: $85 (85%)
```

### Payment Security
- **Stripe Connect** marketplace model
- Payment authorized (not charged) at bid acceptance
- Funds captured after job completion
- 24-hour hold before release to provider
- Full refund capability during dispute window

---

## Technical Architecture

### Authentication
- Rails 8 built-in authentication (`has_secure_password`)
- OAuth providers: Google, Apple
- Session-based authentication with secure cookies

### Core Models
- **User** - Single model for all users
- **ProviderProfile** - Provider-specific data (1:1 with User)
- **ServiceCategory** - Top-level service groupings
- **ServiceType** - Specific services within categories
- **Property** - Consumer property with geocoding
- **JobRequest** - Service request with state machine
- **JobBid** - Provider bids on job requests
- **Payment** - Stripe-backed payment processing
- **Review** - Bidirectional reviews

### Job Request States
```
pending → open_for_bids → accepted → payment_authorized → in_progress → completed → payment_released
                                                                              ↓
                                                                         cancelled
                                                                              ↓
                                                                          disputed
```

### Tech Stack
- Ruby on Rails 8.1
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Phlex view components
- Stripe Connect
- Geocoder for location services
