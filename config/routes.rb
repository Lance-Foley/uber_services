Rails.application.routes.draw do
  # Rails 8 Built-in Authentication
  resource :session
  resources :passwords, param: :token

  # User Registration
  resource :registration, only: [ :new, :create ]

  # OmniAuth Routes
  # POST /auth/:provider (handled by OmniAuth middleware)
  # GET /auth/:provider/callback (handled by our controller)
  get "auth/:provider/callback", to: "omniauth/sessions#create"
  get "auth/failure", to: "omniauth/sessions#failure"

  # Landing page (public)
  root "home#index"

  # Dashboard (authenticated users)
  get "dashboard", to: "dashboard#index"

  # ============================================
  # Consumer Routes
  # ============================================

  # User Profile
  resource :profile, only: [ :show, :edit, :update ]

  # Properties Management
  resources :properties do
    member do
      patch :set_primary
    end
  end

  # Job Requests (Consumer creates and manages)
  resources :job_requests do
    resources :bids, only: [ :index, :show ], controller: "job_requests/bids" do
      member do
        post :accept
        post :reject
      end
    end
    resource :review, only: [ :new, :create ], controller: "job_requests/reviews"
  end

  # ============================================
  # Shared Routes (Consumer & Provider)
  # ============================================

  # Conversations and Messages
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  # Notifications
  resources :notifications, only: [ :index ] do
    collection do
      post :mark_all_read
    end
    member do
      post :mark_read
    end
  end

  # ============================================
  # Provider Routes
  # ============================================

  namespace :provider do
    # Provider Onboarding
    resource :onboarding, only: [ :show, :create, :update ], controller: "onboarding"

    # Provider Profile
    resource :profile, only: [ :show, :edit, :update ]

    # Provider Services
    resources :services

    # Browse Available Jobs
    resources :available_jobs, only: [ :index, :show ] do
      resource :bid, only: [ :new, :create, :destroy ]
    end

    # My Jobs (Provider's accepted jobs)
    resources :my_jobs, only: [ :index, :show ] do
      member do
        post :start
        post :complete
      end
      resource :review, only: [ :new, :create ]
    end

    # Stripe Connect
    resource :stripe_account, only: [ :show ] do
      get :onboard
      get :return
      get :refresh
    end
  end

  # ============================================
  # Admin Routes
  # ============================================

  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [ :index, :show, :edit, :update ]
    resources :payments, only: [ :index, :show ]
    resources :job_requests, only: [ :index, :show ]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
