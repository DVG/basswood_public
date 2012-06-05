require 'spec_helper'

describe "Users" do
  context "User editing their own profile" do
    before :each do
      role = FactoryGirl.create(:role, name: 'registered')
      @user = FactoryGirl.create(:user, role: role, full_name: 'Don Draper')
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      click_button 'Sign in'
    end
    it 'allows user to update their name' do
      visit edit_user_path(@user)
      fill_in 'user_full_name', with: 'Pete Campbell'
      click_button 'Update'
      @user.reload
      @user.full_name.should eq 'Pete Campbell'
      page.should have_content 'Pete Campbell'
    end
    it 'allows a user to update their email' do
      visit edit_user_path(@user)
      fill_in 'user_email', with: 'something@gmail.com'
      click_button 'Update'
      @user.reload
      @user.email.should eq 'something@gmail.com'
      visit edit_user_path(@user)
      find('#user_email').value.should eq 'something@gmail.com'
    end
    it 'allows a user to edit their bio' do
      visit edit_user_path(@user)
      fill_in 'user_bio', with: 'Hello World!'
      click_button 'Update'
      @user.reload
      @user.bio.should eq 'Hello World!'
      visit user_path(@user)
      page.should have_content 'Hello World!'
    end
    it 'allows a user to assign a favorite workout' do
      visit edit_user_path(@user)
      fill_in 'user_favorite_workout', with: 'Fran'
      click_button 'Update'
      @user.reload
      @user.favorite_workout.should eq 'Fran'
      visit user_path(@user)
      page.should have_content 'Fran'
    end
    it 'does not show a role selection for a regular user' do
      visit edit_user_path(@user)
      page.should_not have_select "user_role_id"
    end
    it 'allows a user to update their password' do
      visit edit_user_path(@user)
      click_link 'Change My Password'
      fill_in 'user_current_password', :with => @user.password
      fill_in 'user_password', :with => 'mynewawesomepassword'
      fill_in 'user_password_confirmation', :with => 'mynewawesomepassword'
      click_button 'Update'
      page.should have_content 'You updated your account successfully'
    end
    it 'allows a user to set their hide_me status' do
      visit edit_user_path(@user)
      check 'user_hide_me'
      click_button 'Update'
      @user.reload
      @user.hide_me.should be_true
      visit users_path
      page.should_not have_selector "tr#user_#{@user.id}"
    end
  end
  context 'Admin editing a user' do
    before :each do
      @user = FactoryGirl.create(:user)
      @admin = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'admin'))
      visit new_user_session_path
      fill_in 'user[email]', with: @admin.email
      fill_in 'user[password]', with: @admin.password
      click_button 'Sign in'
    end
    it 'show a select list for role when an admin is editing a user' do
      visit edit_user_path(@user)
      page.should have_select "user_role_id", with_options: ['Registered', 'Trainer', 'Admin']
    end
    it 'updates the role of the user' do
      visit edit_user_path(@user)
      select('Admin', :from => 'user_role_id')
      click_button 'Update'
    end
  end
  context 'User trying to edit another user' do
    before :each do
      role = FactoryGirl.create(:role, name: 'registered')
      @user = FactoryGirl.create(:user, role: role, full_name: 'Don Draper')
      @other_user = FactoryGirl.create(:user, role: role)
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      click_button 'Sign in'
    end
    it 'Does not allow another user to access the edit page' do
      visit edit_user_path(@other_user)
      page.should have_content 'Sorry, you not allowed to access that page.'
      page.should_not have_select 'user_email'
      page.should_not have_select 'user_full_name'
    end
  end
  context 'Showing a user profile' do
    before :each do
      @user = FactoryGirl.create(:user)
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      click_button 'Sign in'
    end
    it 'Shows the user profile with their non-private data' do
      visit user_path(@user)
      page.should have_content @user.full_name
    end
  end
  context 'Avatars' do
    before :each do
      @user = FactoryGirl.create(:user)
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      click_button 'Sign in'
      @images_dir = File.dirname(__FILE__)+'/../support/images/'
    end
    it 'Allows an upload of an avatar of file type jpg less than 5mb' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'jpg.jpg')
      click_button 'Update'
      @user.reload
      @user.avatar.file?.should be_true
    end
    it 'Allows an upload of an avatar of file type png less than 5mb' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'png.png')
      click_button 'Update'
      @user.reload
      @user.avatar.file?.should be_true
    end
    it 'Allows an upload of an avatar of file type gif less than 5mb' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'gif.gif')
      click_button 'Update'
      @user.reload
      @user.avatar.file?.should be_true
    end
    it 'Does not allow a non-image file to be uploaded as an avatar' do
      visit edit_user_path(@user)
      attach_file('user_avatar', File.dirname(__FILE__)+'/users_spec.rb')
      click_button 'Update'
      page.should have_content "Avatar must be an image"
      @user.avatar.file?.should be_false
    end
    it 'Goes not allow an image greater than 5mb to be uploaded as an avatar' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'10mb.jpg')
      click_button 'Update'
      page.should have_content "Avatar must be less than 5 megabytes in size"
      @user.avatar.file?.should be_false
    end
    it 'Should show the image on the user profile page' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'jpg.jpg')
      click_button 'Update'
      visit user_path(@user)
      page.should have_selector('img#avatar')
    end
    it 'should not show the avatar if no image has been uploaded' do
      visit user_path(@user)
      page.should_not have_selector('img#avatar')
      visit edit_user_path(@user)
      attach_file('user_avatar', File.dirname(__FILE__)+'/users_spec.rb')
      click_button 'Update'
      visit user_path(@user)
      page.should_not have_selector('img#avatar')
    end
    it 'shows a small user avatar in the nav bar for a user with an avatar' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'jpg.jpg')
      click_button 'Update'
      page.should have_selector('img#nav_avatar')
    end
    it 'does not show the nav avatar for a user without a avatar' do
      visit root_path
      page.should_not have_selector('img#nav_avatar')
    end
    it 'shows the current avatar for a user with an avatar' do
      visit edit_user_path(@user)
      attach_file('user_avatar', @images_dir+'jpg.jpg')
      click_button 'Update'
      visit edit_user_path(@user)
      page.should have_selector('img#avatar')
      page.should have_selector('img#nav_avatar')
    end
    it 'does not show an avatar on the edit profile page for a user without an avatar' do
      visit edit_user_path(@user)
      page.should_not have_selector('img#avatar')
      page.should_not have_selector('img#nav_avatar')
    end
  end
  
  describe "Member List" do
    context 'registered user' do
      before :each do
        role = FactoryGirl.create(:role)
        @users = []
        5.times { @users << FactoryGirl.create(:user, role: role) }
        @user = @users.first
        @images_dir = File.dirname(__FILE__)+'/../support/images/'
        visit new_user_session_path
        fill_in 'user[email]', with: @user.email
        fill_in 'user[password]', with: @user.password
        click_button 'Sign in'
      end
    
      it 'Displays the link to the member list in the navbar' do
        visit root_path
        within "#navbar" do
          page.should have_link 'Members'
        end
      end
      it 'Shows a table of the registered users, admins and trainers' do
        visit users_path
        page.should have_selector('table#memberlist')
      end
      it 'links the users name to their profile' do
        visit users_path
        within "#user_#{@user.id}" do
          page.should have_link @user.full_name
        end
      end
      it 'displays a users avatar if one exists' do
        visit edit_user_path(@user)
        attach_file('user_avatar', @images_dir+'jpg.jpg')
        click_button 'Update'
        visit users_path
        within "#user_#{@user.id}" do
          page.should have_selector('img#memberlist_avatar')
        end
      end
      it 'shows the number of workouts the user has been involved in' do
        3.times do
          @user.workouts << FactoryGirl.create(:workout)
        end
        visit users_path
        within "#user_#{@user.id}" do
          page.should have_content "3"
        end
      end
      it 'displays how long the user has been a gym member' do
        visit users_path
        within "#user_#{@user.id}" do
          page.should have_content time_ago_in_words(@user.created_at.to_date)
        end
      end
      # TODO: Implement pagination sometime. While this will eventually matter, hopefully, the gym has well under
      # 50 members right now, so let's not fuss about a feature that won't have any value
      #it 'paginates the page at 50 users
      it 'orders the users by registration date' do
        @users.sort! { |a,b| a.created_at <=> b.created_at }
      end
      it 'allows registered users to view the member list' do
        visit users_path
        current_path.should eq users_path
        page.should_not have_content "Sorry, you not allowed to access that page."
      end
    end
    context 'guest' do
      it 'does not allow guests to view the member list' do
        visit users_path
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end
    end # end guest context
    context 'trainer' do
      before :each do
        @trainer = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'trainer'))
        visit new_user_session_path
        fill_in 'user[email]', with: @trainer.email
        fill_in 'user[password]', with: @trainer.password
        click_button 'Sign in'
      end
      it 'allows trainers to view the member list' do
        visit users_path
        current_path.should eq users_path
        page.should_not have_content "Sorry, you not allowed to access that page."
      end
    end #end trainer context
    context 'admin' do
      before :each do
        @admin = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'admin'))
        visit new_user_session_path
        fill_in 'user[email]', with: @admin.email
        fill_in 'user[password]', with: @admin.password
        click_button 'Sign in'
      end
      it 'allows admins to view the member list' do
        visit users_path
        current_path.should eq users_path
        page.should_not have_content "Sorry, you not allowed to access that page."  
      end
    end
    context 'Hide private profiles for non-admins and non-trainers' do
      before :each do
        registered_role = FactoryGirl.create(:role, name: 'registered')
        trainer_role = FactoryGirl.create(:role, name: 'trainer')
        admin_role = FactoryGirl.create(:role, name: 'admin')
        @public_user = FactoryGirl.create(:user, role: registered_role, hide_me: false)
        @private_user = FactoryGirl.create(:user, role: registered_role, hide_me: true)
        @trainer = FactoryGirl.create(:user, role: trainer_role)
        @admin = FactoryGirl.create(:user, role: admin_role)
      end
      context 'registered user' do
        before :each do
          visit new_user_session_path
          fill_in 'user[email]', with: @public_user.email
          fill_in 'user[password]', with: @public_user.password
          click_button 'Sign in'
        end
        it 'does not display rows for a user who has elected not to be shown on the members page' do
          visit users_path
          page.should have_selector "tr#user_#{@public_user.id}"
          page.should have_selector "tr#user_#{@admin.id}"
          page.should have_selector "tr#user_#{@trainer.id}"
          page.should_not have_selector "tr#user_#{@private_user.id}"
        end #end it
      end #end context
      context 'admin' do
        before :each do
          visit new_user_session_path
          fill_in 'user[email]', with: @admin.email
          fill_in 'user[password]', with: @admin.password
          click_button 'Sign in'
        end
        it 'shows all the users regardless of hide me status to admins' do
          visit users_path
          page.should have_selector "tr#user_#{@public_user.id}"
          page.should have_selector "tr#user_#{@admin.id}"
          page.should have_selector "tr#user_#{@trainer.id}"
          page.should have_selector "tr#user_#{@private_user.id}"
        end # end it
      end # end context
      context 'trainer' do
        before :each do
          visit new_user_session_path
          fill_in 'user[email]', with: @trainer.email
          fill_in 'user[password]', with: @trainer.password
          click_button 'Sign in'
        end
        it 'shows all the users regardless of hide me status to trainers' do
          visit users_path
          page.should have_selector "tr#user_#{@public_user.id}"
          page.should have_selector "tr#user_#{@admin.id}"
          page.should have_selector "tr#user_#{@trainer.id}"
          page.should have_selector "tr#user_#{@private_user.id}"
        end # end it
      end
    end
  end # end decribe
  
end