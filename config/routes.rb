Rails.application.routes.draw do
  # Omniauth login route
  get "/auth/github", as: "github_login"

  # Omniauth callback route
  get "/auth/:provider/callback", to: "users#create", as:"omniauth_callback"

  resources :users

  delete "/logout", to: "users#destroy", as: "logout"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :products

end
