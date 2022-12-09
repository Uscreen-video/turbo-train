Rails.application.routes.draw do
  mount Turbo::Train::Engine => "/turbo-train-test"

  resources :messages, only: %i[index]
end
