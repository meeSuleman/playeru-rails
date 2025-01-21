Rails.application.routes.draw do
  # User Management routes
  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, defaults: { format: :json }, path: '', path_names: {
                                                                  sign_in: 'login',
                                                                  sign_out: 'logout',
                                                                  registration: 'signup'
                                                                },
                         controllers: {
                           sessions: 'api/v1/users/sessions',
                           registrations: 'api/v1/users/registrations',
                           passwords: 'api/v1/users/passwords'
                         }
    end
  end

  # API Routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :dashboards, only: [:index] 
      resources :courses, only: [:show]
      resource :confirmations, only: [] do
        post :validate_otp, to: 'confirmations#validate_otp'
        post :resend_otp, to: 'confirmations#resend_otp'
      end
      resources :users, only: [] do
        collection do
          put :update_profile, to: 'users#update_profile'
          get :fetch_profile, to: 'users#fetch_profile'
          post :contact_support, to: 'users#contact_support'
          post :add_cart, to: 'users#add_cart'
          delete :remove_cart, to: 'users#remove_cart'
        end
      end
      resource :password_resets, only: [] do
        post :generate_otp, to: 'password_resets#generate_otp'
        post :reset_password, to: 'password_resets#reset_password'
      end
      resources :training_modules, only: [] do
        member do
          post :completion, to: 'training_modules#completion'
          post :save_assesment, to: 'training_modules#save_assesment'
          patch :mark_favorite, to: 'training_modules#mark_favorite'
          post :upload_assessment_video, to: 'training_modules#upload_assessment_video'
        end
        collection do
          get :full_library, to: 'training_modules#full_library'
          get :fetch_favorites, to: 'training_modules#fetch_favorites'
        end
      end
      resources :sections, only: [:show] do
        collection do
          post :skip_beginner, to: 'sections#skip_beginner'
        end
      end
      resources :addresses, only: [:create, :index]
    end
  end
end
