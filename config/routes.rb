Rails.application.routes.draw do
  resources :levels, only: [:show]
end