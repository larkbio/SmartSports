Rails.application.routes.draw do
  get 'errors/general' => "errors#general"
  get 'errors/unauthorized' => "errors#unauthorized"

  use_doorkeeper
  namespace :api do
    namespace :v1 do
      resources :users do
        resources :measurements
        resources :activities
        resources :diets
        resources :medications
        resources :lifestyles
        resources :genetics
        resources :labresults
        resources :notifications
        resources :sensor_measurements
        resources :custom_forms do
          resources :custom_form_elements
        end
      end
      resources :medication_types
      resources :food_types
      resources :activity_types
      resources :lifestyle_types
      resources :genetics_types
      resources :labresult_types
      get 'profile' => 'profile#show'
      put 'profile' => 'profile#update'
      post 'profile_image' => 'profile#profile_image'
      post 'reset_password' => 'password_resets#create'
    end
  end

  get 'form_element' => "form_element#show"

  resources :notifications
  resources :medication_types
  resources :food_types
  resources :activity_types
  resources :lifestyle_types
  resources :genetics_types
  resources :labresult_types
  resources :click_records
  resources :custom_forms do
    resources :custom_form_elements
  end
  resources :users do
    resources :summaries
    resources :activities
    resources :measurements
    resources :medications
    resources :notifications
    resources :friendships
    resources :outline
    resources :lifestyles
    resources :diets
    resources :medications
    resources :genetics
    resources :labresults
    resources :sensor_measurements
    resources :profile
    resources :custom_forms do
      resources :custom_form_elements
    end
    resources :connections
    get 'analysis_data' => 'analysis_data#index'
    post 'upload'
    post 'uploadAv'
  end

  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    #get 'password_resets/create'
    #get 'password_resets/edit'
    #get 'password_resets/update'
    put '/password_resets/:id/edit' => 'password_resets#update'
    resources :password_resets

    get 'pages/main'
    get 'pages/dashboard'
    get 'pages/diet'
    get 'pages/exercise'
    get 'pages/health'
    get 'pages/medication'
    get 'pages/lifestyle'
    get 'pages/genetics'
    get 'pages/customforms'
    get 'pages/analytics'
    get 'pages/profile'
    get 'pages/admin'
    get 'pages/admin_doctors'
    get 'pages/md_patients'
    get 'pages/md_customforms'
    get 'pages/md_statistics'
    get 'pages/labresult'
    get 'pages/explore'
    get 'pages/customforms'
    get 'pages/traffic'

    get 'pages/profile'
    get 'pages/connections'

    get 'pages/signin'
    get 'pages/signup'
    get 'pages/reset_password'

    get 'profile/edit'
    post 'profile/set_default_lang'

  end

  # resources :summaries
  # resources :notifications
  # resources :measurements
  # resources :friendships

  get 'auth/moves/callback' => 'connections#movescb'
  get 'auth/withings/callback' => 'connections#withingscb'
  get 'auth/fitbit/callback' => 'connections#fitbitcb'
  get 'auth/shine/callback' => 'connections#misfitcb'
  get 'auth/google_oauth2/callback' => 'connections#googlecb'
  get 'auth/failure' => 'connections#failed'

  # get 'pages/reset_password'
  # get 'pages/signin'
  get 'login',  to: redirect("/#{I18n.locale}/pages/signin")
  get 'signup', to: redirect("/#{I18n.locale}/pages/signup")
  post 'logout' => 'sessions#signout', :as => :logout

  resources :sessions


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root :to => "pages#main"
  #handles invalid locale
  #get '/*locale/*path', to: redirect("/#{I18n.default_locale}/%{path}")
  # handles /pages/... without locale
  get 'pages/:path', to: redirect("/#{I18n.default_locale}/pages/%{path}"), constraints: lambda { |req| !req.path.starts_with? "/#{I18n.default_locale}/" }
  # handles /
  get '', to: redirect("/#{I18n.locale}/pages/dashboard")
end
