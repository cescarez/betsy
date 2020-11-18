Rails.application.routes.draw do
  # Omniauth login route
  get "/auth/github", as: "github_login"

  # Omniauth callback route
  get "/auth/:provider/callback", to: "users#create", as:"omniauth_callback"

  get 'users/create'
  get 'users/index'
  get 'users/show'
  get 'users/update'
  get 'users/destroy'
  get 'users/edit'
  get 'users/new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :products

end
