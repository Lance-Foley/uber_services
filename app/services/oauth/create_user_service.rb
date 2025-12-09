# frozen_string_literal: true

module Oauth
  class CreateUserService
    Result = Struct.new(:success?, :user, :error, keyword_init: true)

    def self.call(auth)
      new(auth).call
    end

    def initialize(auth)
      @auth = auth
    end

    def call
      user = find_or_create_user
      ensure_connected_service(user)
      Result.new(success?: true, user: user)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    rescue StandardError => e
      Rails.logger.error("OAuth CreateUserService error: #{e.message}")
      Result.new(success?: false, error: "Unable to authenticate. Please try again.")
    end

    private

    attr_reader :auth

    def find_or_create_user
      # First, try to find existing user via connected service
      connected_service = ConnectedService.find_for_oauth(auth)
      return connected_service.user if connected_service

      # Then, try to find user by email
      user = User.find_by(email_address: email)

      # Create new user if not found
      user ||= create_user

      user
    end

    def create_user
      User.create!(
        email_address: email,
        first_name: first_name,
        last_name: last_name,
        avatar_url: avatar_url,
        password: SecureRandom.hex(32) # Random password for OAuth users
      )
    end

    def ensure_connected_service(user)
      user.connected_services.find_or_create_by!(
        provider: auth.provider,
        uid: auth.uid
      )
    end

    def email
      auth.info.email
    end

    def first_name
      case auth.provider
      when "google_oauth2"
        auth.info.first_name
      when "apple"
        auth.info.first_name || auth.extra&.raw_info&.name&.firstName
      else
        auth.info.first_name || auth.info.name&.split&.first
      end
    end

    def last_name
      case auth.provider
      when "google_oauth2"
        auth.info.last_name
      when "apple"
        auth.info.last_name || auth.extra&.raw_info&.name&.lastName
      else
        auth.info.last_name || auth.info.name&.split&.last
      end
    end

    def avatar_url
      case auth.provider
      when "google_oauth2"
        auth.info.image
      else
        auth.info.image
      end
    end
  end
end
