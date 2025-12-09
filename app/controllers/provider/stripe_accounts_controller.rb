# frozen_string_literal: true

module Provider
  class StripeAccountsController < BaseController
    def show
      @profile = Current.user.provider_profile
    end

    def onboard
      profile = Current.user.provider_profile

      # Create Stripe account if not exists
      if profile.stripe_account_id.blank?
        account = Stripe::Account.create(
          type: "express",
          country: "US",
          email: Current.user.email_address,
          capabilities: {
            card_payments: { requested: true },
            transfers: { requested: true }
          }
        )
        profile.update!(stripe_account_id: account.id)
      end

      # Create account link for onboarding
      account_link = Stripe::AccountLink.create(
        account: profile.stripe_account_id,
        refresh_url: provider_stripe_account_refresh_url,
        return_url: provider_stripe_account_return_url,
        type: "account_onboarding"
      )

      redirect_to account_link.url, allow_other_host: true
    rescue Stripe::StripeError => e
      redirect_to provider_onboarding_path, alert: "Stripe error: #{e.message}"
    end

    def return
      profile = Current.user.provider_profile

      # Check account status
      account = Stripe::Account.retrieve(profile.stripe_account_id)

      profile.update!(
        stripe_account_status: account.details_submitted ? "active" : "pending",
        stripe_charges_enabled: account.charges_enabled,
        stripe_payouts_enabled: account.payouts_enabled
      )

      if account.charges_enabled
        redirect_to provider_profile_path, notice: "Stripe account connected successfully!"
      else
        redirect_to provider_onboarding_path, alert: "Please complete your Stripe setup."
      end
    rescue Stripe::StripeError => e
      redirect_to provider_onboarding_path, alert: "Stripe error: #{e.message}"
    end

    def refresh
      redirect_to provider_stripe_account_onboard_path
    end
  end
end
