Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'  # end

  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  devise_for :accounts, only: :omniauth_callbacks, controllers: {omniauth_callbacks: 'accounts/omniauth_callbacks'}
  scope "(:locale)" do
    root to: 'dashboard#index'
    resources :personas, only: [:index]

    resources :user_passwords, path: 'user/password'

    get '/get_states', to: 'csc#get_states', as: :get_states
    get '/get_cities', to: 'csc#get_cities', ad: :get_cities

    get 'dashboard/index'
    get 'not_found', to: 'errors#not_found'

    resource :dashboard, controller: 'dashboard' do
      collection do
        get :active
        get :draft
        get :finished
      end
    end


    devise_for :accounts, controllers: { registrations: 'accounts/registrations' }, skip: :omniauth_callbacks

    resources :users, path: 'account/users'
    get 'accept_invitation/:id', to: "users#accept_invitation", as: :accept_invitation

    resources :account_settings, except: [:new, :index, :create, :edit, :update, :destroy] do
      member do
        delete :delete_image_attachment
      end
      collection do
        post :overview_update
        post :settings_update
        post :new_billing_email
        post :update_billing_email
      end
    end

    get 'dashboard/settings'

    match '/account_settings', to: 'account_settings#settings', via: :get
    resources :users do
      member do
        put :update_user
        get :resend_invitation
      end
    end

    scope 'account', as: 'account' do
      resources :users
    end

    scope 'account_settings', as: 'account_settings' do
      resources :users
    end
 
    resources :groups, except: [:show] do
      collection do
        get :choose_template
        get :choose_template_tab
        get :industry_themes
        get :destroy_template
      end

      resources :surveys, controller: 'groups/surveys' do
        member do
          get :results
        end

        collection do
          get :all
          get :finished
          get :active
          get :draft
        end
      end
    end

    resources :customized_personas do
      collection do
        get :export_pdf
      end
    end

    resources :reports do
      resources :surveys, controller: 'reports/surveys' do
        member do
          get :results
          get :respondent_with_answers
          get :export_pdf
          get :export_summary_pdf
        end

        collection do
          get :all
          get :finished
          get :active
        end
      end

      collection do
        get :disable_public_link
        get :generate_public_link
      end
    end
    
    resources :results do
      resources :surveys, controller: 'results/surveys' do
        member do
          get :results
          get :respondent_with_answers
          get :export_pdf
          get :export_summary_pdf
        end

        collection do
          get :all
          get :finished
          get :active
        end
      end

      collection do
        get :disable_public_link
        get :generate_public_link
      end
    end

    get 'persona_display_type/:display_type_id', to: 'persona_display_types#display_type', as: :persona_display_type

    get 'survey/:survey_token', to: 'survey_submissions#start', as: :public_survey
    post 'survey/continue', to: 'survey_submissions#continue', as: :public_survey_continue
    get 'survey/submit', to: 'survey_submissions#new', as: :public_survey_new

    get 'survey/:survey_token/:encr_mail_id', to: 'survey_submissions#start', as: :encr_mail_survey_open

    post 'survey/screen', to: 'survey_submissions#screen_submit', as: :public_survey_screen

    resources :survey_submissions, except: [:index]

    resources :surveys, controller: 'surveys' do
      member do
        get :success
        get :preview_survey
        get :preview_survey_branching
        get :save_as_a_template
        post :save_as_a_template_create
        get :respondent_with_answers
        get :disable_or_enable_shared_link
      end

      collection do
        get :new_group
        post :create_group

        get :clone
        post :clone_submit

        get :move
        post :move_submit

        get :duplicate
        post :duplicate_submit
      end

      resources :steps, controller: 'surveys/steps'

      resources :categories_surveys, controller: 'surveys/categories_surveys' do
        collection do
          get :new_list_modal
          post :create_list

          get :new_recipient_modal
          post :create_recipient

          get :add_block_modal

          get :remove_custom_block

          get :clone_block_modal
          post :clone_block

          get :save_as_block_modal
          post :save_as_block_submit

          get :edit_block_modal
          patch :edit_block

          get :delete_question

          get :new_question
          post :new_question_submit

          get :duplicate_question

          get :edit_question
          patch :update_question

          get :get_group_by_question_types_templates

          get :reset
        end
      end
    end

    resources :lists do
      resources :recipients
    end


    match '/admin', to: 'admin#dashboard', via: :get
    namespace :admin do

      resources :accounts do
        collection do
          get :activate_or_disable
          get :okta_enable
          get :okta_disable
          post :add_trial_submit
        end
        member do
          get :reinstate
        end
      end

      resources :industries

      resources :template_themes do
        member do
          get :preview
          
          get :clone_template_modal 
          post :clone_template
        end

        resources :steps, controller: 'template_themes/steps' do
          collection do
            get :preview_survey
          end
        end

        resources :template_categories, controller: 'template_themes/categories_template_themes' do
          collection do
            get :preview_survey

            get :add_block_modal

            get :clone_block_modal
            post :clone_block

            get :edit_block_modal
            patch :edit_block

            get :delete_question
            get :edit_question
            patch :update_question

            get :get_group_by_question_types_templates

            get :reset
          end
        end

      end

      resources :categories, path: 'block-templates' do
        member do
          get :preview

          get :clone_block_modal
          post :clone_block
        end
        resources :questions, controller: 'categories/questions'
      end

      resources :label_templates do
        collection do
          get :get_group_by_question_types_templates
          get :get_template_description
        end
      end

    end
  end

end
