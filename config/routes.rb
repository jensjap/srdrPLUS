Rails.application.routes.draw do
  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :projects, concerns: :paginatable, shallow: true do
    resources :extraction_forms_projects, only: [:create, :edit, :update, :destroy] do
      get 'build', on: :member
      resources :extraction_forms_projects_sections, only: [:new, :create, :edit, :update, :destroy] do
        resources :questions, only: [:new, :create, :edit, :destroy]
      end
    end
    resources :key_questions_projects, only: [:create, :edit, :update, :destroy]

    collection do
      get 'filter'
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: 'static_pages#home'

  get  'about'  => 'static_pages#about'
  get  'help'   => 'static_pages#help'
  get  'search' => 'static_pages#search'
  post 'search' => 'static_pages#search'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  resource  :profile, only: [:show, :edit, :update]
  resources :degrees, only: [:index]
  resources :organizations, only: [:index]
  resources :sections, only: [:index]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

