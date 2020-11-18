Rails.application.routes.draw do
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
