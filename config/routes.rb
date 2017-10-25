Rails.application.routes.draw do
  resources :levels, only: [:show] do
    member do
      get "move"
      get "reset"
    end
  end
end