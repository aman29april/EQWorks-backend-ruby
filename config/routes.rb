Rails.application.routes.draw do
  namespace :api do
    resources :events, only: %i[index create]
  end
end
