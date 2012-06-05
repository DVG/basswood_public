require 'spec_helper'

describe UsersController do
  describe 'get #edit' do
    login_user
    it 'assigns the selected user to the @user variable' do
      get :edit, id: @user
      assigns(:user).should eq @user
    end
  end
  
  describe 'put #update' do
    login_user
    it 'updates the user record' do
      put :update, id: @user, user: FactoryGirl.attributes_for(:user, full_name: 'Tywin Lannister')
      @user.reload
      @user.full_name.should eq 'Tywin Lannister'
    end
  end
  describe 'put #update role' do
    context 'user' do
      login_user
      # Security Test to verify a normal user cannot simply PUT with extra variables into the request to update 
      # themselves to have the admin role
      it 'does not update the role for a normal user' do
        put :update, id: @user, user: FactoryGirl.attributes_for(:user, role: FactoryGirl.create(:role, name: 'admin'))
        @user.role.reload
        #puts @user.role.name
        @user.role.should eq Role.find_by_name('registered')
      end
    end
    context 'admin' do
      login_admin
      it 'updates the role' do
        user = FactoryGirl.create(:user)
        attributes = FactoryGirl.attributes_for(:user, role: @user.role)
        attributes[:role_id] = @user.role.id
        put :update, id: user, user: attributes
        user.reload
        user.role.should eq Role.find_by_name('admin')
      end
    end
  end
end
