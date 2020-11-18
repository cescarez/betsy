Rails.application.routes.draw do


  root "users#index"
  
  # Omniauth login route
  get "/auth/github", as: "github_login"

  # Omniauth callback route
  get "/auth/:provider/callback", to: "users#create", as:"omniauth_callback"

  resources :users

  delete "/logout", to: "users#destroy", as: "logout"

  resources :products

  post "/orders/status", to: "orders#status_filter", as: "order_status"
  get "orders/:id/checkout", to: "orders#checkout", as: "checkout_order"
  post "/orders/:id/complete", to: "orders#complete", as: "complete_order"
  resources :orders
end
