require 'sidekiq/web'

Rails.application.routes.draw do
  # Maintenance Routes
  ################################
  # get 'maintenance', to: 'static_pages#about'
  # get '/' => redirect('/maintenance')
  # get '*path' => redirect('/maintenance')
  # put '/' => redirect('/maintenance')
  # put '*path' => redirect('/maintenance')
  # post '/' => redirect('/maintenance')
  # post '*path' => redirect('/maintenance')
  # delete '/' => redirect('/maintenance')
  # delete '*path' => redirect('/maintenance')
  ################################

  get 'public_data', to: 'public_data#show'

  resources :publishings, only: %i[new create destroy]
  post 'publishings/:id/approve', to: 'publishings#approve', as: 'publishings_approve'
  post 'publishings/:id/rescind_approval', to: 'publishings#rescind_approval', as: 'rescind_approval'

  resources :project_report_links, only: %i[index view] do
    get 'new_query_form'
    post 'options_form'
  end

  resources :searches, only: [:index]
  resources :funding_sources, only: [:index]
  resources :sd_picods_types, only: [:index]
  resources :key_question_types, only: [:index]
  resources :sd_search_databases, only: [:index]
  resources :key_questions, only: [:index]
  resources :sd_key_questions, only: [:index] do
    get 'destroy_with_picodts', on: :member
  end
  resources :sd_meta_data_queries, only: %i[create update destroy]
  resources :review_types, only: [:index]
  resources :data_analysis_levels, only: [:index]

  devise_for :admins
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  devise_scope :user do
    post '/users/api_key_reset' => 'users/registrations#api_key_reset'
  end

  authenticate :admin do
    mount Searchjoy::Engine, at: 'searchjoy'
    mount Sidekiq::Web => '/sidekiq'
  end

  apipie
  namespace :api do
    namespace :v1 do
      resources :evidence_variables, only: %i[index show]

      resources :keywords, only: [:index]
      resources :users, only: [:index]
      resources :keywords, only: [:index]
      resources :timepoint_names, only: [:index]

      resources :citations, only: [:index] do
        collection do
          get 'titles'
          get 'project_citations_query'
        end
      end

      resources :projects, shallow: true do
        resources :citations, only: [:index] do
        end
        resources :extractions, only: [:index]
        resources :extraction_forms_projects do
          resources :extraction_forms_projects_sections, only: %i[index show] do
            post 'toggle_hiding', to: 'extraction_forms_projects_sections#toggle_hiding'
            resources :type1s, only: [:index]
          end
        end
      end
      resources :orderings do
        collection do
          patch 'update_positions'
        end
      end
    end # END namespace :v1 do

    namespace :v2 do
      resources :mesh_descriptors, only: [:index]
      resources :evidence_variables, only: %i[index show]
      get :public_projects, to: 'projects#public_projects'
      resources :projects, shallow: true do
        member do
          post :import_citations_fhir_json
        end
      end # END resources :projects, shallow: true do

      resources :extractions, only: [:show]
      resources :extraction_forms_projects_sections, only: [:show]
      resources :key_questions, only: [:show]
      resources :questions, only: [:show]
    end # END namespace :v2 do

    namespace :v3 do
      resources :projects, shallow: true, only: [:show] do
        resources :citations, only: %i[index show]
        resources :key_questions, only: %i[index show]
        resources :extractions, only: %i[index show]
      end
      resources :extraction_forms_projects, shallow: true, only: [] do
        resources :extraction_forms_projects_sections, only: %i[index show]
      end
    end # END namespace :v3 do
  end # END namespace :api do

  resources :comparisons
  resources :journals
  resources :keywords
  resources :records, only: [:update]
  resources :statusings, only: [:update]

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :extractions_extraction_forms_projects_sections_type1s, only: [] do
    get 'get_results_populations', on: :member
  end

  resources :pictures, only: [:create] do
    delete :delete_image_attachment, on: :member
  end

  resources :sd_meta_data, only: [] do
    get 'preview'
    post 'section_update'
    post 'mapping_update'
  end

  get 'sd_key_questions/:id/fuzzy_match', to: 'sd_key_questions#fuzzy_match'

  resources :abstract_screenings, shallow: true, only: [] do
    resources :abstract_screenings_tags_users
    resources :abstract_screenings_reasons_users
  end

  resources :fulltext_screenings, shallow: true, only: [] do
    resources :fulltext_screenings_tags_users
    resources :fulltext_screenings_reasons_users
  end

  resources :abstract_screening_results, only: %i[show update]
  resources :fulltext_screening_results, only: %i[show update]
  resources :data_audits, only: %i[index update]
  resources :projects, concerns: :paginatable, shallow: true do
    get 'citation_lifecycle_management', to: 'abstract_screenings#citation_lifecycle_management'
    get 'kpis', to: 'abstract_screenings#kpis'
    post 'export_screening_data', to: 'abstract_screenings#export_screening_data'

    resources :abstract_screenings do
      get 'screen', to: 'abstract_screenings#screen'
      post 'update_word_weight', to: 'abstract_screenings#update_word_weight'
    end
    resources :fulltext_screenings do
      get 'screen', to: 'fulltext_screenings#screen'
    end

    resources :screening_forms

    resource :data_audit, only: [:create]
    resources :sd_meta_data

    member do
      get 'confirm_deletion'
      post 'import_csv'
      post 'import_ris'
      post 'import_endnote'
      post 'import_pubmed'
      post 'dedupe_citations'
      post 'create_citation_screening_extraction_form'
      post 'create_full_text_screening_extraction_form'
    end

    resources :citations do
    end

    resources :extractions do
      collection do
        get 'comparison_tool'
        get 'consolidate'
        get 'edit_type1_across_extractions'
      end

      member do
        get 'work'
        get 'reassign_extraction'
        put 'update_kqp_selections'
        get 'change_outcome_in_results_section', constraints: { format: 'js' }
      end

      resources :extractions_extraction_forms_projects_sections do
        resources :extractions_extraction_forms_projects_sections_question_row_column_fields, only: [:update]
        resources :extractions_extraction_forms_projects_sections_type1s, only: %i[edit update destroy] do
          member do
            get 'edit_timepoints'
            get 'edit_populations'
          end

          resources :extractions_extraction_forms_projects_sections_type1_rows, only: [:create] do
            resources :extractions_extraction_forms_projects_sections_type1_row_columns, only: [:create] do
              resources :result_statistic_sections, only: %i[edit update] do
                member do
                  post 'add_comparison'
                  delete 'remove_comparison'
                  get 'consolidate'
                  get 'manage_measures', constraints: { format: 'js' }
                end
              end
            end
          end
        end
      end
    end
    resources :extraction_forms_projects, only: %i[create edit update destroy] do
      get 'build', on: :member
      resources :extraction_forms_projects_sections, only: %i[new create edit update destroy] do
        resources :extraction_forms_projects_sections_type1s, only: %i[edit update]

        member do
          post 'add_quality_dimension'
        end

        resources :questions, only: %i[new create edit update destroy] do
          member do
            patch 'toggle_dependency'
            post 'add_column'
            post 'add_row'
            get 'dependencies'
            post 'duplicate'
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
        resources :type1s, only: %i[new create edit update destroy]
        delete 'dissociate_type1'
      end
    end
    resources :key_questions_projects, only: %i[create edit update destroy]

    collection do
      get 'filter'
    end

    member do
      post 'export'
      post 'export_citation_labels'
      post 'export_to_gdrive'
      get  'export_assignments_and_mappings'
      post 'import_assignments_and_mappings'
      post 'simple_import'
    end

    resources :imports, only: %i[index new show]
  end

  post 'imports/:id/start', to: 'imports#start'

  root to: 'static_pages#home'

  get 'about' => 'static_pages#about'
  get 'citing' => 'static_pages#citing'
  get 'contact' => 'static_pages#contact'
  get 'help' => 'static_pages#help'
  get 'usage' => 'static_pages#usage'
  get 'blog' => 'static_pages#blog'
  get 'resources' => 'static_pages#resources'
  get 'published_projects' => 'static_pages#published_projects'

  resource :profile, only: %i[show edit update]
  resources :degrees, only: [:index]
  resources :organizations, only: [:index]
  resources :sections, only: [:index]
  resources :imports, only: [:create]

  resources :screening_forms, only: [] do
    resources :sf_questions, shallow: true
  end

  resources :sf_questions, only: [] do
    resources :sf_rows, shallow: true
    resources :sf_columns, shallow: true
  end
  resources :sf_cells do
    resources :sf_options, shallow: true
    resources :sf_abstract_records, only: %i[create destroy], shallow: true
    resources :sf_fulltext_records, only: %i[create destroy], shallow: true
  end

  get '/sf_options/:id/existing_data_check' => 'sf_options#existing_data_check'

  resources :abstract_screening_results, only: [] do
    resources :sf_abstract_records, only: [:index]
  end

  resources :fulltext_screening_results, only: [] do
    resources :sf_fulltext_records, only: [:index]
  end

  resources :screening_qualifications, only: %i[create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
