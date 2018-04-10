Rails.application.routes.draw do
  apipie
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
  resources :records, only: [:update]

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :extractions_extraction_forms_projects_sections_type1s, only: [] do
    get 'get_results_subgroups', on: :member
  end
  post '/projects/:id/undo', to: 'projects#undo', as: :undo
  resources :projects, concerns: :paginatable, shallow: true do
    resources :extractions do
      get 'work', on: :member
      resources :extractions_extraction_forms_projects_sections do
        resources :extractions_extraction_forms_projects_sections_type1s, only: [:edit, :update, :destroy] do
          member do
            get 'edit_timepoints'
            get 'edit_populations'
          end
          resources :extractions_extraction_forms_projects_sections_type1_rows, only: [:create] do
            resources :extractions_extraction_forms_projects_sections_type1_row_columns, only: [:create] do
              resources :result_statistic_sections, only: [:edit, :update]
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
        resources :questions, only: [:new, :create, :edit, :update, :destroy] do
          member do
            patch 'toggle_dependency'
            post  'add_column'
            post  'add_row'
            get   'dependencies'
          end
          resources :question_rows, only: [:destroy] do
            resources :question_row_columns, only: [] do
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

