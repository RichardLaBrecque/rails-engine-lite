# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/merchants/find', to: 'search#find'
      get '/items/find_all', to: 'search#find_all'
      get '/merchants/most_items', to: 'search#most_items'
      get '/revenue', to: 'search#total_revenue'
      resources :merchants, only: %i[index show] do
        resources :items, only: [:index], controller: :merchant_items
      end
      resources :items, only: %i[index show create destroy update] do
        resources :merchant, only: [:index], controller: :item_merchant
      end
      namespace :revenue do
        resources :merchants, only: [:index, :show]
        resources :items, only: [:index]
      end
    end
  end
end
