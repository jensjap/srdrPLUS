require 'sidekiq/web'

Rails.application.routes.draw do
  resources :searches, only: [:new, :create]

  devise_for :admins
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  authenticate :admin do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    mount Searchjoy::Engine, at: "searchjoy"
    mount Sidekiq::Web => '/sidekiq'
  end

  apipie
  namespace :api do
    namespace :v1 do
      resources :timepoint_names, only: [:index]
      resources :projects, shallow: true do
        resources :assignments do
          get 'screen', on: :member
          get 'history', on: :member
        end
        resources :citations, only: [:index] do
          collection do
            get 'labeled'
            get 'unlabeled'
          end
        end
        resources :extractions, only: [:index]
        resources :extraction_forms_projects do
          resources :extraction_forms_projects_sections, only: [:index, :show] do
            resources :type1s, only: [:index]
          end
        end
      end
    end
  end

  resources :assignments do
    get 'screen', on: :member
  end
  resources :authors
  resources :citations, only: [:new, :create, :edit, :update, :destroy, :show]
  resources :journals
  resources :keywords
  resources :labels
  resources :tasks
  resources :records, only: [:update]
  resources :comparisons
  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :extractions_extraction_forms_projects_sections_type1s, only: [] do
    get 'get_results_populations', on: :member
  end
  post '/projects/:id/undo', to: 'projects#undo', as: :undo
  resources :projects, concerns: :paginatable, shallow: true do
    post 'export', on: :member
    resources :citations, only: [:index] do
      collection do
        get 'labeled'
        get 'unlabeled'
      end
    end
    resources :extractions do
      get 'work', on: :member
      resources :extractions_extraction_forms_projects_sections do
        resources :extractions_extraction_forms_projects_sections_question_row_column_fields, only: [:update]
        resources :extractions_extraction_forms_projects_sections_type1s, only: [:edit, :update, :destroy] do
          member do
            get 'edit_timepoints'
            get 'edit_populations'
          end
          resources :extractions_extraction_forms_projects_sections_type1_rows, only: [:create] do
            resources :extractions_extraction_forms_projects_sections_type1_row_columns, only: [:create] do
              resources :result_statistic_sections, only: [:edit, :update] do
                post 'add_comparison', on: :member
              end
            end
          end
        end
      end
    end
    resources :extraction_forms_projects, only: [:create, :edit, :update, :destroy] do
      get 'build', on: :member
      resources :extraction_forms_projects_sections, only: [:new, :create, :edit, :update, :destroy] do
        member do
          get 'preview'
          post 'add_quality_dimension'
        end
        get 'preview', on: :member
        resources :questions, only: [:new, :create, :edit, :update, :destroy] do
          member do
            patch 'toggle_dependency'
            post  'add_column'
            post  'add_row'
            get   'dependencies'
          end
          resources :question_rows, only: [:destroy] do
            resources :question_row_columns, only: [] do
              resources :question_row_columns_question_row_column_options, only: [:destroy]
              member do
                get 'answer_choices'
                delete 'destroy_entire_column'
              end
              resources :question_row_column_fields, only: [] do
                resources :question_row_column_fields_question_row_column_field_options, only: [:destroy]
              end
            end
          end
        end
        resources :type1s, only: [:new, :create, :edit, :update, :destroy]
        delete 'dissociate_type1'
      end
    end
    resources :key_questions_projects, only: [:create, :edit, :update, :destroy]

    collection do
      get 'filter'
    end
  end

  root to: 'static_pages#home'

  get  'about'  => 'static_pages#about'
  get  'help'   => 'static_pages#help'
  #!!! Remove the views for this later
  get  'search' => 'static_pages#search'
  #post 'search' => 'static_pages#search'

  resource  :profile, only: [:show, :edit, :update]
  resources :degrees, only: [:index]
  resources :organizations, only: [:index]
  resources :sections, only: [:index]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

