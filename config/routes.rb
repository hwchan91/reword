Rails.application.routes.draw do
  root to: 'levels#show', id: 1
  resources :levels, only: [:show, :index] do
    member do
      get "move"
      get "reset"
      get "undo"
    end
  end
end