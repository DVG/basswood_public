require 'spec_helper'

describe "Workouts" do

  context 'admin user' do

    before :each do
      admin_role = FactoryGirl.create(:role, name: 'admin')
      trainer_role = FactoryGirl.create(:role, name: 'trainer')
      user = FactoryGirl.create(:user, role: admin_role, password: 'secret')
      trainer = FactoryGirl.create(:user, role: trainer_role)
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Sign in'
    end

    describe 'Create Workouts' do
      it 'Creates a new workout and displays the workout\'s page', js: true  do
        visit workouts_path
        expect {
          click_link "New Workout"
          fill_in 'workout_name', with: 'Workout!'
          page.execute_script %Q{ $('#workout_show_date').trigger("focus") } 
          page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") }
          select('6', from: 'workout_time_4i')
          select('15', from: 'workout_time_5i')
          fill_in 'workout_maximum_size', with: '10'
          click_button 'Create Workout'
        }.to change(Workout,:count).by(1)
        page.should have_content 'Workout!'
      end

      it 'has a default value of 10 for capacity' do
        visit workouts_path
        click_link "New Workout"
        find('#workout_maximum_size').value.should eq '10'
      end

      it 'quick-adds a workout in the morning' do
        sunday = Date.today.beginning_of_week(:sunday)
        visit workouts_path
        within "#day_#{sunday.strftime('%Y-%m-%d')}" do
          click_link 'Quick Add'
          click_link 'Morning Workout'
        end
        workout = Workout.last
        find("#workout_#{workout.id}").should have_content 'Morning Workout!'
        find("#workout_#{workout.id}").should have_content '6:00 am'
        find("#workout_#{workout.id}").should have_link 'Edit'
        find("#workout_#{workout.id}").should have_link 'Cancel'
      end

      it 'quick-adds a workout at noon' do
        sunday = Date.today.beginning_of_week(:sunday)
        visit workouts_path
        within "#day_#{sunday.strftime('%Y-%m-%d')}" do
          click_link 'Quick Add'
          click_link 'Noon Workout'
        end
        workout = Workout.last
        find("#workout_#{workout.id}").should have_content 'Noon Workout!'
        find("#workout_#{workout.id}").should have_content '12:00 pm'
        find("#workout_#{workout.id}").should have_link 'Edit'
        find("#workout_#{workout.id}").should have_link 'Cancel'
      end

      it 'quick-adds a workout in the evening' do
        sunday = Date.today.beginning_of_week(:sunday)
        visit workouts_path
        within "#day_#{sunday.strftime('%Y-%m-%d')}" do
          click_link 'Quick Add'
          click_link 'Evening Workout'
        end
        workout = Workout.last
        find("#workout_#{workout.id}").should have_content 'Evening Workout!'
        find("#workout_#{workout.id}").should have_content '6:15 pm'
        find("#workout_#{workout.id}").should have_link 'Edit'
        find("#workout_#{workout.id}").should have_link 'Cancel'
      end

      it 'takes a user to the week of the workout after quick-adding' do
        next_week = Date.today.next_week
        visit workouts_path
        click_link 'Next Week'
        within "#day_#{next_week.strftime('%Y-%m-%d')}" do
          click_link 'Quick Add'
          click_link 'Evening Workout'
        end
        (next_week.beginning_of_week(:sunday)..next_week.end_of_week(:sunday)).each do |day|
          page.should have_xpath("//tbody[@id='day_#{day.strftime('%Y-%m-%d')}']")
        end 
      end
    end
  
    describe 'Cancel Workout' do

      before :each do
        @workout = FactoryGirl.create(:workout, date: Date.today)
      end

      context 'Cancel from index view' do

        it "Removes the workout from the view", js: true do
          visit workouts_path
          within "#workout_#{@workout.id}" do
            click_link 'Cancel'
          end
          alert = page.driver.browser.switch_to.alert
          alert.accept
          find("#day_#{@workout.date.strftime('%Y-%m-%d')}").should_not have_selector "tbody#workout_#{@workout.id}"
        end
      end

      context 'Cancel from show view' do

        it "Doesn't show the workout on the index page", js: true do
          visit workouts_path
          click_link @workout.name
          click_link 'Cancel Workout'
          alert = page.driver.browser.switch_to.alert
          alert.accept
          page.should have_content 'The workout has been cancelled'
          find("#day_#{@workout.date.strftime('%Y-%m-%d')}").should_not have_selector "tbody#workout_#{@workout.id}"
        end
      end
    end
  
    describe 'Reschedule Workout' do

      before :each do
        #workout today at 6am
        @workout = FactoryGirl.create(:workout, date: Date.today, time: Time.new(Date.today.year, Date.today.month, Date.today.day, 6, nil, nil, 0))
      end

      context 'Edit from the homepage' do

        it "Shows the workout page with the new time" do
          visit workouts_path
          find("#workout_#{@workout.id}").should have_content '6:00 am'
          within "#workout_#{@workout.id}" do
            click_link 'Edit'
          end
          select('18', from: 'workout_time_4i')
          select('15', from: 'workout_time_5i')
          click_button 'Update Workout'
          page.should have_content '6:15 pm'
        end

        it 'shows the updated time on the homepage' do
          visit workouts_path
          within "#workout_#{@workout.id}" do
            click_link 'Edit'
          end
          select('18', from: 'workout_time_4i')
          select('15', from: 'workout_time_5i')
          click_button 'Update Workout'
          click_link 'Back'
          find("#workout_#{@workout.id}").should have_content '6:15 pm'
        end
      end

      context 'edit from the show page' do

        it 'shows new time on the showpage' do
          visit workout_path(@workout)
          page.should have_content '6:00 am'
          click_link 'Edit'
          select('18', from: 'workout_time_4i')
          select('15', from: 'workout_time_5i')
          click_button 'Update Workout'
          page.should have_content '6:15 pm'
        end

        it 'shows new time at index' do
          visit workout_path(@workout)
          page.should have_content '6:00 am'
          click_link 'Edit'
          select('18', from: 'workout_time_4i')
          select('15', from: 'workout_time_5i')
          click_button 'Update Workout'
          click_link 'Back'
          find("#workout_#{@workout.id}").should have_content '6:15 pm'
        end
      end
    end
  
    describe 'Pagination' do

      before :each do
        #workout today at 6am
        today = Date.today
        last_week = today.prev_week
        next_week = today.next_week
        @workout = FactoryGirl.create(:workout, date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
        @last_week_workout = FactoryGirl.create(:workout, date: last_week, time: Time.new(last_week.year, last_week.month, last_week.day, 6, nil, nil, 0))
        @next_week_workout = FactoryGirl.create(:workout, date: next_week, time: Time.new(next_week.year, next_week.month, next_week.day, 6, nil, nil, 0))
      end

      it 'Only shows last weeks workout when you pagiate to the previous week' do
        visit workouts_path
        page.should have_xpath("//tr[@id='workout_#{@workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@last_week_workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@next_week_workout.id}']")
        click_link 'Previous Week'
        page.should_not have_xpath("//tr[@id='workout_#{@workout.id}']")
        page.should have_xpath("//tr[@id='workout_#{@last_week_workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@next_week_workout.id}']")
      end

      it 'Shows next weeks workout after paginating to next week' do
        visit workouts_path
        page.should have_xpath("//tr[@id='workout_#{@workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@last_week_workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@next_week_workout.id}']")
        click_link 'Next Week'
        page.should_not have_xpath("//tr[@id='workout_#{@workout.id}']")
        page.should_not have_xpath("//tr[@id='workout_#{@last_week_workout.id}']")
        page.should have_xpath("//tr[@id='workout_#{@next_week_workout.id}']")
      end
    end
  end

  context 'Registered User' do

    before :each do
      user = FactoryGirl.create(:user)
      today = Date.today
      @workout = FactoryGirl.create(:workout, date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Sign in'
    end

    describe 'Index Page' do

      it 'Does not show user the Edit or Delete links on the index page' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should_not have_link 'Edit'
          page.should_not have_link 'Cancel'
        end
      end

      it 'Does not show quick-add actions for a registered user' do
        visit workouts_path
        (Date.today.beginning_of_week(:sunday)..Date.today.end_of_week(:sunday)).each do |day|
          within "##{day.strftime('day_%Y-%m-%d')}" do
            page.should_not have_link 'Quick Add'
            page.should_not have_link 'Morning'
            page.should_not have_link 'Noon'
            page.should_not have_link 'Evening'
          end
        end
      end

      it 'Does not show New button for a registered user' do
        visit workouts_path
        page.should_not have_link 'New Workout'
      end

      it 'Does not show Edit and Cancel buttons on show page' do
        visit workout_path(@workout)
        page.should_not have_link 'Edit'
        page.should_not have_link 'Cancel Workout'
      end

      it 'Does not allow the user to go directly to the new action' do
        visit new_workout_path
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end

      it 'Does not allow the user to go directly to the edit action' do
        visit edit_workout_path(@workout)
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end
    end
  end

  context 'Guest' do

    before :each do
      today = Date.today
      @workout = FactoryGirl.create(:workout, date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
    end

    describe 'Index Page' do

      it 'Does not show user the Edit or Delete links on the index page' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should_not have_link 'Edit'
          page.should_not have_link 'Cancel'
        end
      end

      it 'Does not show quick-add actions for a registered user' do
        visit workouts_path
        (Date.today.beginning_of_week(:sunday)..Date.today.end_of_week(:sunday)).each do |day|
          within "##{day.strftime('day_%Y-%m-%d')}" do
            page.should_not have_link 'Quick Add'
            page.should_not have_link 'Morning'
            page.should_not have_link 'Noon'
            page.should_not have_link 'Evening'
          end
        end
      end

      it 'Does not show New button for a registered user' do
        visit workouts_path
        page.should_not have_link 'New Workout'
      end

      it 'Does not show Edit and Cancel buttons on show page' do
        visit workout_path(@workout)
        page.should_not have_link 'Edit'
        page.should_not have_link 'Cancel Workout'
      end

      it 'Does not allow the user to go directly to the new action' do
        visit new_workout_path
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end

      it 'Does not allow the user to go directly to the edit action' do
        visit edit_workout_path(@workout)
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end
    end
  end

  describe 'joining a workout' do

    context 'registered user' do
      before :each do
        user = FactoryGirl.create(:user)
        today = Date.today
        @workout = FactoryGirl.create(:workout, maximum_size: 5, date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Sign in'
      end

      it 'Shows a join button for a workout' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_link 'Join In'
        end
      end

      it 'Adds user to workout when they click the join button' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          expect {click_link 'Join In'}.to change(@workout.users,:count).by(1)
        end
      end

      it 'changes the join button to a cancel button' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          click_link 'Join In'
        end
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_link 'Wuss Out'
        end
      end

      it 'cancelling removes the user from the workout' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          click_link 'Join In'
        end
        visit workouts_path
        within "#workout_#{@workout.id}" do
          expect { click_link 'Wuss Out'}.to change(@workout.users,:count).by(-1)
        end        
      end

      it 'Cancelling turns the cancel button back to a join button' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          click_link 'Join In'
        end
        visit workouts_path
        within "#workout_#{@workout.id}" do
          click_link 'Wuss Out'
        end
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_link 'Join'
          page.should_not have_link 'Wuss Out'
        end
      end

      it 'Shows the remaining count of slots in the workout' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_content '5'
          click_link 'Join In'
        end
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_content '4'
        end
      end
      
      it 'Shows the remaining count of slots increases when a user cancels' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          click_link 'Join In'
        end
        click_link 'Back'
        within "#workout_#{@workout.id}" do
          page.should have_content '4'
          click_link 'Wuss Out'
        end
        click_link 'Back'
        within "#workout_#{@workout.id}" do
          page.should have_content '5'  
        end
      end
    end
    context 'maximum users' do
      before :each do
        user = FactoryGirl.create(:user)
        today = Date.today
        @workout = FactoryGirl.create(:workout, maximum_size: 1, users: [FactoryGirl.create(:user, role: user.role)], date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Sign in'
      end

      it 'Disables the join button if the workout is at capacity' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          find_link('Join In')[:class].should include 'disabled'
          find_link('Join In')[:href].should eq ''
        end
      end
    end
    context 'No maximum capacity' do
      before :each do
        user = FactoryGirl.create(:user)
        today = Date.today
        @workout = FactoryGirl.create(:workout, maximum_size: 0, users: [FactoryGirl.create(:user, role: user.role)], date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Sign in'
      end
      it 'Displays Unlimited' do
        visit workouts_path
        within "#workout_#{@workout.id}" do
          page.should have_content 'Unlimited'
        end
      end
    end
  end
  
  describe 'Display participants on workouts show page' do
    before :each do
      @user = FactoryGirl.create(:user)
      today = Date.today
      @workout = FactoryGirl.create(:workout, users: [@user], date: today, time: Time.new(today.year, today.month, today.day, 6, nil, nil, 0))
      visit new_user_session_path
      fill_in 'user[email]', with: @user.email
      fill_in 'user[password]', with: @user.password
      click_button 'Sign in'
    end
    it 'shows a table of users' do
      visit workout_path(@workout)
      page.should have_selector('tr', :id => "user_#{@user.id}")
    end
  end
  
  describe 'Multiple trainers' do
    context 'Trainer' do
      before :each do
        trainer_role = FactoryGirl.create(:role, name: 'trainer')
        @trainer = FactoryGirl.create(:user, role: trainer_role)
        @my_workout = FactoryGirl.create(:workout, trainer: @trainer)
        @another_workout = FactoryGirl.create(:workout, trainer: FactoryGirl.create(:user, role: trainer_role))
        visit new_user_session_path
        fill_in 'user[email]', with: @trainer.email
        fill_in 'user[password]', with: @trainer.password
        click_button 'Sign in'
      end
      it 'does not show a join button for a trainers own workout' do
        visit workouts_path
        within "#workout_#{@my_workout.id}" do
          page.should_not have_link 'Join In'
          page.should_not have_link 'Wuss Out'
        end
      end
      it 'shows a join button for other trainers workouts' do
        visit workouts_path
        within "#workout_#{@another_workout.id}" do
          page.should have_link 'Join In'
          page.should_not have_link 'Wuss Out'
        end
      end
      it 'allows a trainer to join another trainers workout' do
        visit workouts_path
        within "#workout_#{@another_workout.id}" do
          click_link 'Join In'
        end
        page.should have_selector('tr', :id => "user_#{@trainer.id}")
        click_link 'Back'
        within "#workout_#{@another_workout.id}" do
          page.should_not have_link 'Join In'
          page.should have_link 'Wuss Out'
        end
      end
      it 'allows a trainer to cancel out of another trainers workout' do
        visit workouts_path
        within "#workout_#{@another_workout.id}" do
          click_link 'Join In'
        end
        page.should have_xpath("//table/tbody[@id='participant_body']/tr[@id='user_#{@trainer.id}']")
        click_link 'Back'
        within "#workout_#{@another_workout.id}" do
          page.should_not have_link 'Join In'
          page.should have_link 'Wuss Out'
          click_link 'Wuss Out'
        end
        page.should_not have_xpath("//table/tbody[@id='participant_body']/tr[@id='user_#{@trainer.id}']")
      end
      it 'does not allow a trainer to edit another trainers workout' do
        visit edit_workout_path(@another_workout)
        current_path.should eq root_path
        page.should have_content "Sorry, you not allowed to access that page."
      end
    end
    context 'admin' do
      before :each do
        trainer_role = FactoryGirl.create(:role, name: 'trainer')
        @first_trainer = FactoryGirl.create(:user, role: trainer_role, full_name: "Arnold Schwartz")
        @trainer = FactoryGirl.create(:user, role: trainer_role, full_name: "Pete Campbell")
        admin_role = FactoryGirl.create(:role, name: 'admin')
        @admin = FactoryGirl.create(:user, role: admin_role, full_name: "Don Draper")
        visit new_user_session_path
        fill_in 'user[email]', with: @admin.email
        fill_in 'user[password]', with: @admin.password
        click_button 'Sign in'
      end
      it 'shows a picklist of trainers for an admin creating a workout' do
        visit workouts_path
        click_link 'New Workout'
        page.should have_select('workout_trainer_id')
      end
      it 'shows the currently logged in admin as the default trainer', js: true do
        visit workouts_path
        click_link 'New Workout'
        page.should have_select('workout_trainer_id', selected: 'Don Draper', :with_options => ['Arnold Schwartz', 'Don Draper', 'Pete Campbell'])
      end
      it 'allows an admin to change the trainer on any workout' do
        workout = FactoryGirl.create(:workout, trainer: @trainer)
        visit workouts_path
        within "#workout_#{workout.id}" do
          click_link 'Edit'
        end
        select('Don Draper', from: 'workout_trainer_id')
        click_button 'Update Workout'
      end
      it 'includes only trainers in the select list for an admin' do
        workout = FactoryGirl.create(:workout, trainer: @trainer)
        regular_user = FactoryGirl.create(:user)
        visit workouts_path
        within "#workout_#{workout.id}" do
          click_link 'Edit'
        end
        page.should have_select('workout_trainer_id', :with_options => [@first_trainer.full_name, @trainer.full_name])
      end
    end
  end
end
