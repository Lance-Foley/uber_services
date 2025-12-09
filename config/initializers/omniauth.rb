# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  # Developer provider for local testing (only in development)
  provider :developer if Rails.env.development?

  # Google OAuth2
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id),
    Rails.application.credentials.dig(:google, :client_secret),
    {
      scope: "email,profile",
      prompt: "select_account",
      image_aspect_ratio: "square",
      image_size: 200
    }

  # Apple Sign In
  provider :apple,
    Rails.application.credentials.dig(:apple, :client_id),
    "",
    {
      scope: "email name",
      team_id: Rails.application.credentials.dig(:apple, :team_id),
      key_id: Rails.application.credentials.dig(:apple, :key_id),
      pem: Rails.application.credentials.dig(:apple, :private_key)
    }
end

# Configure OmniAuth
OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true

# Handle OAuth failures
OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
