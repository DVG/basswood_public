module ControllerMacros
  def login_admin
    before(:each) do
      role = FactoryGirl.create(:role, :name => 'admin')
      user = FactoryGirl.create(:user, :role => role)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
      @user = user
    end
  end

  def login_user(user=nil)
    before(:each) do
      if user.nil? 
        user = FactoryGirl.create(:user)
      end
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
      @user = user
    end
  end
  
  def login_trainer
    before(:each) do
      role = FactoryGirl.create(:role, :name => 'trainer')
      user = FactoryGirl.create(:user, :role => role)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
      @user = user
    end
  end
end