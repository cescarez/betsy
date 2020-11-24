Rails.application.routes.draw do

  root to: "users#index"

  get "/users/current", to: "users#current", as: "current_user"

  # Omniauth login route
  get "/auth/github", as: "github_login"

  # Omniauth callback route
  get "/auth/:provider/callback", to: "users#create", as: "omniauth_callback"

  resources :users

  delete "/logout", to: "users#destroy", as: "logout"

  resources :products do
    resources :reviews, only: [:create, :new]
  end

  patch "products/:id/add_to_cart", to: 'products#add_to_cart', as: 'add_to_cart'
  patch "products/:id/retire", to: 'products#set_retire', as: 'retire'
  resources :categories, except: [:edit, :update, :destroy]

  post "/orders/status", to: "orders#status_filter", as: "order_status_filter"

  resources :shipping_infos, except: [:index]
  resources :billing_infos, except: [:index]


  patch "/orders", to: 'orders#create', as: 'create_cart'
  get "/orders/:id/checkout", to: "orders#checkout", as: "checkout_order"
  get "/orders/:id/summary", to: "orders#summary", as: "order_summary"
  post "/orders/:id/checkout", to: "orders#submit"
  post "/orders/:id/complete", to: "orders#complete", as: "complete_order"
  post "/orders/:id/cancel", to: "orders#cancel", as: "cancel_order"
  patch "/orders/:id/edit_quantity", to: 'orders#edit_quantity', as: 'edit_quantity'
  resources :orders, except: [:new, :edit, :destroy]


end
