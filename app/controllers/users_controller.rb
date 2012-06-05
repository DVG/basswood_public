class UsersController < ApplicationController
  filter_access_to [:edit, :update, :show], :attribute_check => true
  filter_access_to :index
  layout 'profile', :except => [:show, :index]
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if current_user.admin?
      if @user.update_attributes(params[:user], :as => :admin)
        redirect_to root_path
      else
        render 'edit'
      end
    else
      if @user.update_attributes(params[:user])
        redirect_to root_path
      else
        render 'edit'
      end
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def index
    @users = User.all
  end
end
