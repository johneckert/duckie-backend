Rails.application.routes.draw do
  resources :conversation_keywords
  resources :keywords
  resources :conversations
  resources :users, only: [:show, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
