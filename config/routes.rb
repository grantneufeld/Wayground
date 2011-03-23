Wayground::Application.routes.draw do
	# USERS
	get "sign_up" => "users#new", :as => :sign_up
	post "sign_up" => "users#create"
	get "account/confirm/:confirmation_code" => "users#confirm", :as => :confirm_account
	resource :account, :controller => 'users', :except => [:index, :new, :create, :destroy]
	# SESSIONS
	get "sign_in" => "sessions#new", :as => :sign_in
	post "sign_in" => "sessions#create"
	get "sign_out" => "sessions#delete", :as => :sign_out
	delete "sign_out" => "sessions#destroy"
	# OAUTH
	match "/auth/:provider/callback" => "sessions#oauth_callback"

	root :to => "users#root"
end
