# Deployment Guide - Render

This guide will help you deploy the Uber Services app to Render.

## Prerequisites

- GitHub repository: https://github.com/Lance-Foley/uber_services
- Render account: https://render.com
- Rails master key from `config/master.key` (keep this secure!)

## Quick Deploy to Render

### Option 1: Blueprint (Recommended)

1. Go to https://render.com/dashboard
2. Click "New" → "Blueprint"
3. Connect your GitHub account if not already connected
4. Select the `uber_services` repository
5. Render will detect `render.yaml` and show the services to be created:
   - Web Service: `uber-services`
   - PostgreSQL Database: `uber-services-db`
6. Click "Apply" to create both services

### Option 2: Manual Setup

#### Step 1: Create PostgreSQL Database

1. Go to https://render.com/dashboard
2. Click "New" → "PostgreSQL"
3. Configure:
   - **Name**: `uber-services-db`
   - **Database**: `uber_services_production`
   - **Plan**: Starter ($7/month)
   - **Region**: Choose closest to your users
4. Click "Create Database"
5. Wait for the database to provision (1-2 minutes)

#### Step 2: Create Web Service

1. Click "New" → "Web Service"
2. Connect to your GitHub repository: `Lance-Foley/uber_services`
3. Configure:
   - **Name**: `uber-services`
   - **Region**: Same as database
   - **Branch**: `main`
   - **Runtime**: Docker
   - **Plan**: Starter ($7/month)
   - **Docker Build Context**: `.`
   - **Dockerfile Path**: `./Dockerfile`

## Required Environment Variables

After creating the web service, add these environment variables in the Render dashboard:

### Auto-configured (when using Blueprint)
- `DATABASE_URL` - Automatically linked from the PostgreSQL service

### Required Manual Configuration

1. **RAILS_MASTER_KEY** (Critical!)
   - Go to your local project
   - Run: `cat config/master.key` (keep this secret!)
   - Add to Render as a Secret File or Environment Variable
   - This decrypts credentials including API keys

2. **RAILS_ENV**
   - Value: `production`
   - Usually auto-set by Render

3. **RAILS_LOG_TO_STDOUT**
   - Value: `true`
   - Enables logging to Render's log viewer

4. **RAILS_SERVE_STATIC_FILES**
   - Value: `true`
   - Serves compiled assets

### Optional but Recommended

5. **Stripe Keys** (for payments)
   - `STRIPE_PUBLISHABLE_KEY`
   - `STRIPE_SECRET_KEY`
   - Get from https://dashboard.stripe.com/apikeys

6. **OAuth Provider Keys**
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - `APPLE_CLIENT_ID`
   - `APPLE_CLIENT_SECRET`

## Post-Deployment Steps

### 1. Run Database Migrations

The build script (`bin/render-build.sh`) automatically runs migrations, but if needed:

```bash
# Access Rails console via Render Shell
rails db:migrate
```

### 2. Seed Initial Data (Optional)

```bash
rails db:seed
```

### 3. Create Admin User

```bash
# In Render Shell
rails console
> User.create!(
    email: 'admin@example.com',
    password: 'secure_password',
    password_confirmation: 'secure_password',
    admin: true,
    name: 'Admin User'
  )
```

## Accessing Your App

- **Web URL**: `https://uber-services.onrender.com` (or custom domain)
- **Render Dashboard**: https://render.com/dashboard
- **Logs**: Available in Render dashboard under "Logs" tab
- **Shell Access**: Click "Shell" in Render dashboard to access Rails console

## Deployment Process

Render automatically deploys when you push to the `main` branch:

```bash
git push origin main
```

Each deployment:
1. Builds Docker image
2. Runs `bin/render-build.sh`:
   - Installs gems
   - Precompiles assets
   - Runs database migrations (`db:prepare`)
3. Starts the app with Thruster (HTTP/2, caching)
4. Health check at `/up` endpoint

## Troubleshooting

### Build Fails

**Check Ruby Version**
- Current: 3.5.0-preview1 (preview release)
- If Render doesn't support it, update `.ruby-version` to `3.3.6` or `3.4.2`

**Check Logs**
- Go to Render Dashboard → Select Service → Logs tab
- Look for specific error messages

### Database Connection Issues

**Verify DATABASE_URL**
- Check Environment Variables in Render dashboard
- Should be linked to your PostgreSQL database

**Connection Pool**
- Render Starter plan supports 97 connections
- Default pool size: 5 (configurable in `database.yml`)

### Assets Not Loading

**Check Build Logs**
- Ensure `rails assets:precompile` ran successfully
- Verify `RAILS_SERVE_STATIC_FILES=true` is set

**CSP Issues**
- Check `config/initializers/content_security_policy.rb`
- May need to allow Render domains

### SSL/Host Issues

The app is pre-configured to allow Render hosts:
- `*.onrender.com`
- `*.render.app`

If using a custom domain, update `config/environments/production.rb`:

```ruby
config.hosts = [
  /.*\.onrender\.com/,
  /.*\.render\.app/,
  "yourdomain.com",
  /.*\.yourdomain\.com/
]
```

## Cost Estimate

**Starter Tier (Recommended for MVP)**
- Web Service: $7/month
- PostgreSQL: $7/month
- **Total**: $14/month

**Free Tier (Limited)**
- Web Service: Free (spins down after 15 min inactivity)
- PostgreSQL: Not available (need external DB)

## Monitoring & Scaling

### Health Checks
- Endpoint: `/up`
- Automatic restarts if health check fails

### Scaling Options
1. **Vertical**: Upgrade to Standard/Pro plans (more CPU/RAM)
2. **Horizontal**: Add more web service instances
3. **Database**: Upgrade PostgreSQL plan for more connections/storage

### Performance
- Thruster provides HTTP/2 and X-Sendfile acceleration
- Solid Cache/Queue use PostgreSQL (no Redis needed)
- Consider Redis add-on for high traffic

## Support

- **Render Docs**: https://render.com/docs
- **Rails Guides**: https://guides.rubyonrails.org/
- **Project Issues**: https://github.com/Lance-Foley/uber_services/issues

## Next Steps

1. Set up custom domain (Render Dashboard → Settings → Custom Domain)
2. Configure Stripe webhooks (point to your Render URL)
3. Set up OAuth redirect URIs in Google/Apple consoles
4. Enable backups (automatic on paid PostgreSQL plans)
5. Set up monitoring (Render provides basic metrics)
6. Consider CDN for assets (Cloudflare, CloudFront)

---

**Security Reminder**: Never commit `config/master.key` or environment secrets to Git!
