Wayground::Application.routes.draw do
  # USERS
  get "signup" => "users#new", :as => :signup
  post "signup" => "users#create"
  get "account/confirm/:confirmation_code" => "users#confirm", :as => :confirm_account
  resource :account, :controller => 'users', :except => [:index, :new, :create, :destroy]
  get 'profile/:id' => 'users#profile', :as => :profile
  # SESSIONS
  get "signin" => "sessions#new", :as => :signin
  post "signin" => "sessions#create"
  get "signout" => "sessions#delete", :as => :signout
  delete "signout" => "sessions#destroy"
  # OAUTH
  match "auth/:provider/callback" => "sessions#oauth_callback"
  # AUTHORITIES
  resources :authorities do
    get 'delete', :on => :member
  end
  # SETTINGS
  resources :settings do
    get 'initialize_defaults', :on => :collection
    get 'delete', :on => :member
  end

  # CONTENT
  resources :paths do
    get 'delete', :on => :member
  end
  resources :pages do
    member do
      get 'delete'
      delete 'delete' => 'pages#destroy'
    end
    resources :versions, :except => [:new, :create, :edit, :update, :destroy]
  end
  resources :documents do
    member do
      get 'delete'
      delete 'delete' => 'documents#destroy'
    end
  end
  get 'download/:id/*filename' => 'documents#download', :as => :download
  resources :events do
    member do
      get 'approve'
      post 'approve' => 'events#set_approved'
      get 'delete'
      delete 'delete' => 'events#destroy'
      get 'merge'
      post 'merge' => 'events#perform_merge'
    end
    resources :external_links do
      member do
        get 'delete'
        delete 'delete' => 'external_links#destroy'
      end
    end
    resources :versions, :except => [:new, :create, :edit, :update, :destroy]
  end
  resources :sources do
    member do
      get 'delete'
      get 'processor'
      post 'processor' => 'sources#runprocessor'
    end
  end

  # PROJECTS
  resources :projects do
    member do
      get 'delete'
      delete 'delete' => 'projects#destroy'
    end
  end
  get 'project/*projecturl' => 'projects#show', :as => :project_name

  root :to => "paths#sitepath", :via => :get, :defaults => { :url => '/' }
  get '*url' => "paths#sitepath"
end
