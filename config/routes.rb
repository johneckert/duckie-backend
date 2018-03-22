Rails.application.routes.draw do

  resources :conversation_keywords
  resources :keywords
  resources :users, only: [:show, :create] do
    resources :conversations
  end

  post "/login", to: 'auth#login'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
