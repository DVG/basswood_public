Basswood::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users, :only => [:edit, :update, :show, :index]
  root :to => "workouts#index"
  resources :workouts do
    collection do
      post 'quick_add'
    end
    member do
      post 'join'
      post 'cancel'
    end
  end
  match "workouts/week/(:date)" => "workouts#index", 
      :constraints => { :date => /\d{4}-\d{2}-\d{2}/ },
      :as => "workouts_date"
end
