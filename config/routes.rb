Rails.application.routes.draw do

  resources :magazines do
    post 'suscribir', on: :member
    delete 'suscribir', to:'magazines#unsubscribe', on: :member
    get 'hilos', on: :member
  end
  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, only: [:show, :edit, :update] do
    post 'generarApiKey', on: :member
    get 'hilos', on: :member
    get 'comments', on: :member
    get 'boosts', on: :member
  end
  resources :hilos do
    post 'like', on: :member
    post 'dislike', on: :member
    post 'boost', on: :member
    resources :comments, only: [:create, :new, :destroy, :update] do
      post 'like', on: :member
      post 'dislike', on: :member
      post 'boost', on: :member
    end
    collection do
      get 'order'
      get 'filter'
    end
  end
  resources :comments, only: [:create, :destroy, :new, :edit, :update] do
    post 'like', on: :member
    post 'dislike', on: :member
    post 'boost', on: :member
  end
  get  '/search', to: 'search#index'
  resources :links, controller: 'hilos'

  root 'hilos#index'
end
