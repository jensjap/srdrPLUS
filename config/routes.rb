Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :projects, shallow: true do
        resources :extractions, only: [:index]
        resources :extraction_forms_projects do
          resources :extraction_forms_projects_sections, only: [:index, :show] do
            resources :type1s, only: [:index]
          end
        end
      end
    end
  end

  resources :assignments
  resources :authors
  resources :citations
  resources :journals
  resources :keywords
  resources :labels
  resources :tasks

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :projects, concerns: :paginatable, shallow: true do
    resources :extractions do
      get 'work', on: :member
      resources :extractions_extraction_forms_projects_sections do
        resources :extractions_extraction_forms_projects_sections_type1s, only: [:edit, :destroy]
      end
    end
    resources :extraction_forms_projects, only: [:create, :edit, :update, :destroy] do
      get 'build', on: :member
      resources :extraction_forms_projects_sections, only: [:new, :create, :edit, :update, :destroy] do
        get 'preview', on: :member
        resources :questions, only: [:new, :create, :edit, :update, :destroy] do
          patch 'toggle_dependency', on: :member
          post  'add_column', on: :member
          post  'add_row', on: :member
          get   'dependencies', on: :member
          resources :question_rows, only: [:destroy] do
            resources :question_row_columns, only: [] do
              get 'answer_choices', on: :member
              delete 'destroy_entire_column', on: :member
              resources :question_row_column_fields, only: [] do
                resources :question_row_column_fields_question_row_column_field_options, only: [:destroy]
              end
            end
          end
        end
        resources :type1s, only: [:new, :create, :edit, :update, :destroy] do
        end
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

  resources :citations
  resources :tasks
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

