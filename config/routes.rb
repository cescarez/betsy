Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :products

  post "/orders/status", to: "orders#status_filter", as: "order_status"
  get "orders/:id/checkout", to: "orders#checkout", as: "checkout_order"
  post "/orders/:id/complete", to: "orders#complete", as: "complete_order"
  resources :orders
end
