require 'spec_helper'

# The workouts controller is the primary function of the site. The Controller will allow admin users to 
# schedule, move and reschedule workouts.
describe WorkoutsController do
  
  # The index action of the workouts controller will render a weekly view of the workout schedule.
  describe 'GET #index' do
    
    # The admin role should not have any special effect on the index action
    context 'admin' do
      login_admin
      
      # When no date is given, the index action will use the current week.
      context 'no date give' do
        
        # The @workouts instance variable will contain the list of workouts scoped to this week and grouped
        # by date.
        it 'populates an array of workouts this week grouped by date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.today.beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.today)
          saturday_workout = FactoryGirl.create(:workout, date: Date.today.end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.today.next_week(:sunday))
          prev_week_workout = FactoryGirl.create(:workout, date: Date.today.prev_week(:sunday).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          get :index
          assigns(:workouts).should eq this_week_workouts
        end
        
        # The range of dates in @week should be for the current sunday to saturday week.
        it 'populates a range of dates this week' do
          get :index
          assigns(:week).should eq (Date.today.beginning_of_week(:sunday)..Date.today.end_of_week(:sunday))
        end
        
        # The index template should be rendered for the index action
        it 'renders the :index view' do
          get :index
          response.should render_template :index
        end
      end
      
      # When a date is given, the scope of the workouts will be for the sunday to saturday week containing the given date
      context 'date given' do
        
        # @workouts should show the workouts contained in the given date's week
        it 'populates an array of workouts for the week of the given date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31))
          saturday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).next_week)
          prev_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          get :index, date: '2012-12-31'
          assigns(:workouts).should eq this_week_workouts
        end
        
        # The range of dates should be the (Sunday..Saturday) week for the given date
        it 'populates a range of dates for the week of the given date' do
          get :index, date: '2012-12-31'
          assigns(:week).should eq (Date.new(2012,12,31).beginning_of_week(:sunday)..Date.new(2012,12,31).end_of_week(:sunday))
        end
        
        # should still render the index template
        it 'renders the :index view' do
          get :index, date: '2012-12-31'
          response.should render_template :index
        end
      end
    end
    
    context 'registered' do
      login_user
      context 'no date give' do
        it 'populates an array of workouts this week grouped by date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.today.beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.today)
          saturday_workout = FactoryGirl.create(:workout, date: Date.today.end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.today.next_week(:sunday))
          prev_week_workout = FactoryGirl.create(:workout, date: Date.today.prev_week(:sunday).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          get :index
          assigns(:workouts).should eq this_week_workouts
        end
        it 'populates a range of dates this week' do
          get :index
          assigns(:week).should eq (Date.today.beginning_of_week(:sunday)..Date.today.end_of_week(:sunday))
        end
        it 'renders the :index view' do
          get :index
          response.should render_template :index
        end
      end
      context 'date given' do
        it 'populates an array of workouts for the week of the given date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31))
          saturday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).next_week)
          prev_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          #get workouts_date_path('2012-12-31')
          get :index, date: '2012-12-31'
          assigns(:workouts).should eq this_week_workouts
        end
        it 'populates a range of dates for the week of the given date' do
          get :index, date: '2012-12-31'
          assigns(:week).should eq (Date.new(2012,12,31).beginning_of_week(:sunday)..Date.new(2012,12,31).end_of_week(:sunday))
        end
        it 'renders the :index view' do
          get :index, date: '2012-12-31'
          response.should render_template :index
        end
      end
    end
    context 'guest' do
      context 'no date give' do
        it 'populates an array of workouts this week grouped by date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.today.beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.today)
          saturday_workout = FactoryGirl.create(:workout, date: Date.today.end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.today.next_week(:sunday))
          prev_week_workout = FactoryGirl.create(:workout, date: Date.today.prev_week(:sunday).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          get :index
          assigns(:workouts).should eq this_week_workouts
        end
        it 'populates a range of dates this week' do
          get :index
          assigns(:week).should eq (Date.today.beginning_of_week(:sunday)..Date.today.end_of_week(:sunday))
        end
        it 'renders the :index view' do
          get :index
          response.should render_template :index
        end
      end
      context 'date given' do
        it 'populates an array of workouts for the week of the given date' do
          sunday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).beginning_of_week(:sunday))
          today_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31))
          saturday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).end_of_week(:sunday))
          next_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).next_week)
          prev_week_workout = FactoryGirl.create(:workout, date: Date.new(2012, 12, 31).prev_week)
          this_week_workouts = [sunday_workout, today_workout, saturday_workout].group_by(&:date)
          #get workouts_date_path('2012-12-31')
          get :index, date: '2012-12-31'
          assigns(:workouts).should eq this_week_workouts
        end
        it 'populates a range of dates for the week of the given date' do
          get :index, date: '2012-12-31'
          assigns(:week).should eq (Date.new(2012,12,31).beginning_of_week(:sunday)..Date.new(2012,12,31).end_of_week(:sunday))
        end
        it 'renders the :index view' do
          get :index, date: '2012-12-31'
          response.should render_template :index
        end
      end
    end
  end
  
  describe 'GET #show' do
    context 'admin' do
      login_admin
      it 'assigns the requested workout to @workout' do
        workout = FactoryGirl.create(:workout)
        get :show, id: workout
        assigns(:workout).should eq workout
      end
      it 'renders the :show view' do
        get :show, id: FactoryGirl.create(:workout)
        response.should render_template :show
      end
    end
    context 'registered user' do
      login_user
      it 'assigns the requested workout to @workout' do
        workout = FactoryGirl.create(:workout)
        get :show, id: workout
        assigns(:workout).should eq workout
      end
      it 'renders the :show view' do
        get :show, id: FactoryGirl.create(:workout)
        response.should render_template :show
      end
    end
    context 'guest' do
      it 'assigns the requested workout to @workout' do
        workout = FactoryGirl.create(:workout)
        get :show, id: workout
        assigns(:workout).should eq workout
      end
      it 'renders the :show view' do
        get :show, id: FactoryGirl.create(:workout)
        response.should render_template :show
      end
    end
  end
  
  describe 'GET #new' do
    context 'admin' do
      login_admin
      it 'assigns a new workout to @workout' do
        get :new
        assigns(:workout).should be_a_new(Workout)
      end
      it 'has a default value of 10 for capacity' do
        get :new
        assigns(:workout).maximum_size.should eq 10
      end
      it 'renders the :new view' do
        get :new
        response.should render_template :new
      end
    end
    context 'registered user' do
      login_user
      it 'redirects non-admin user to the home page' do
        get :new
        response.should redirect_to root_path
      end
    end
    context 'guest' do
      it 'redirects non-admin user to the home page' do
        get :new
        response.should redirect_to root_path
      end
    end
  end
  
  describe 'GET #edit' do
    context 'admin' do
      login_admin
      it 'assigns the requested workout to @workout' do
        workout = FactoryGirl.create(:workout)
        get :edit, id: workout
        assigns(:workout).should eq workout
      end
      it 'renders the :edit view' do
        get :edit, id: FactoryGirl.create(:workout)
        response.should render_template :edit
      end
    end
    context 'registered user' do
      login_user
      it 'redirects non-admin user to the home page' do
        workout = FactoryGirl.create(:workout)
        get :edit, id: workout
        response.should redirect_to root_path
      end
    end
    context 'guest' do
      it 'redirects non-admin user to the home page' do
        workout = FactoryGirl.create(:workout)
        get :edit, id: workout
        response.should redirect_to root_path
      end
    end
  end
  
  describe 'POST #create' do
    context 'admin' do
      login_admin
      context 'with valid attributes' do
        it 'saves the new workout to the database' do
          trainer_role = FactoryGirl.create(:role, name: 'trainer')
          trainer = FactoryGirl.create(:user, role: trainer_role)
          expect { post(:create, workout: FactoryGirl.build(:workout, trainer: trainer).attributes)}.to change(Workout, :count).by(1)
        end
        it 'redirects to the workout show view' do
          trainer_role = FactoryGirl.create(:role, name: 'trainer')
          trainer = FactoryGirl.create(:user, role: trainer_role)
          post(:create, workout: FactoryGirl.build(:workout, trainer: trainer).attributes)
          response.should redirect_to Workout.last
        end
      end
      context 'with invalid attributes' do 
        it 'does not save the workout in the database' do
          expect { post :create, workout: FactoryGirl.attributes_for(:invalid_workout)}.to_not change(Workout, :count)
        end
        it 'rerenders the new template' do
          post :create, workout: FactoryGirl.attributes_for(:invalid_workout)
          response.should render_template :new
        end
      end
    end
    context 'registered user' do 
      login_user
      context 'valid attributes' do
        it 'should not affect the workout count' do
          expect { post :create, workout: FactoryGirl.attributes_for(:workout)}.to_not change(Workout, :count)
        end
        it 'should take the user to the root path' do
          post :create, workout: FactoryGirl.attributes_for(:workout)
          response.should redirect_to root_path       
        end
      end
      context 'with invalid attributes' do
        it 'should not affect the workout count' do
          expect { post :create, workout: FactoryGirl.attributes_for(:invalid_workout)}.to_not change(Workout, :count)
        end
        it 'should take the user to the root path' do
          post :create, workout: FactoryGirl.attributes_for(:invalid_workout)
          response.should redirect_to root_path       
        end
      end
    end
    context 'guest' do
      context 'valid attributes' do
        it 'should not affect the workout count' do
          expect { post :create, workout: FactoryGirl.attributes_for(:workout)}.to_not change(Workout, :count)
        end
        it 'should take the user to the root path' do
          post :create, workout: FactoryGirl.attributes_for(:workout)
          response.should redirect_to root_path       
        end
      end
      context 'with invalid attributes' do
        it 'should not affect the workout count' do
          expect { post :create, workout: FactoryGirl.attributes_for(:invalid_workout)}.to_not change(Workout, :count)
        end
        it 'should take the user to the root path' do
          post :create, workout: FactoryGirl.attributes_for(:invalid_workout)
          response.should redirect_to root_path       
        end
      end
    end
  end
  
  describe 'PUT #update' do
    before :each do
      #workout on May 01, 2012 at noon
      @workout = FactoryGirl.create(:workout, name: 'Test Workout', date: Date.new(2012, 05, 01), time: Time.new(2012, 05, 01, 12))
    end
    context 'admin' do
      login_admin
      context 'with valid attributes' do
        it 'saves the changed workout name to the database' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout, name: 'Changed Workout')
          @workout.reload
          @workout.name.should eq 'Changed Workout'
        end
        it 'redirects to the updated workout' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout)
          response.should redirect_to @workout
        end
      end
      context 'with invalid attributes' do 
        it 'locates the requested workout' do
          put :update, id: @workout, contact: FactoryGirl.attributes_for(:invalid_workout)
        end
        it 'does not save the contact in the database' do
          put :update, id: @workout, contact: FactoryGirl.attributes_for(:workout, name: 'Changed Workout', date: nil)
          @workout.reload
          @workout.name.should_not eq 'Changed Workout'
          @workout.date.should eq Date.new(2012, 05, 01)
        end
        it 'rerenders the :edit template' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:invalid_workout)
          response.should render_template :edit
        end
      end
    end
    context 'registered user' do
      login_user
      context 'with valid attributes' do
        it 'should not change the Workout' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout, name: 'Changed Workout')
          @workout.reload
          @workout.name.should eq 'Test Workout'
        end
        it 'should redirect the user to the root path' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout, name: 'Changed Workout')
          response.should redirect_to root_path
        end
      end
      context 'with invalid attributes' do
        it 'should not change the Workout' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:invalid_workout, name: 'Changed Workout')
          @workout.reload
          @workout.name.should eq 'Test Workout'
        end
        it 'should redirect the user to the root path' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:invalid_workout, name: 'Changed Workout')
          response.should redirect_to root_path
        end
      end
    end
    context 'guest' do
      context 'with valid attributes' do
        it 'should not change the Workout' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout, name: 'Changed Workout')
          @workout.reload
          @workout.name.should eq 'Test Workout'
        end
        it 'should redirect the user to the root path' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:workout, name: 'Changed Workout')
          response.should redirect_to root_path
        end
      end
      context 'with invalid attributes' do
        it 'should not change the Workout' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:invalid_workout, name: 'Changed Workout')
          @workout.reload
          @workout.name.should eq 'Test Workout'
        end
        it 'should redirect the user to the root path' do
          put :update, id: @workout, workout: FactoryGirl.attributes_for(:invalid_workout, name: 'Changed Workout')
          response.should redirect_to root_path
        end
      end
    end
  end
  
  describe 'DELETE #destroy' do
    before :each do
      @workout = FactoryGirl.create(:workout)
    end
    context 'admin' do
      login_admin
      it 'deletes the workout' do
        expect {delete :destroy, {:id => @workout}}.to change(Workout, :count).by(-1)
      end
    
      it 'takes the user to the index page' do
        delete :destroy, id: @workout
        response.should redirect_to workouts_path
      end
    end
    context 'registered user' do
      login_user
      it 'does not effect the workout count' do
        expect {delete :destroy, {:id => @workout}}.to_not change(Workout, :count)
      end
      it 'redirects to the root path' do
        delete :destroy, {:id => @workout}
        response.should redirect_to root_path
      end
    end
    context 'guest' do
      it 'does not effect the workout count' do
        expect {delete :destroy, {:id => @workout}}.to_not change(Workout, :count)
      end
      it 'redirects to the root path' do
        delete :destroy, {:id => @workout}
        response.should redirect_to root_path
      end
    end
  end
  
  describe 'POST #join' do
    context 'maximum not reached' do
      login_user
      it 'lets a user join when the maximum_size has not been reached' do
        workout = FactoryGirl.create(:workout, maximum_size: 1)
        expect { post :join, {id: workout}}.to change(workout.users, :count).by(1)
      end
    end
    context 'maximum reached' do
      login_user
      it 'does not let a user join when maximum_size has been reached' do 
        workout = FactoryGirl.create(:workout, maximum_size: 1, users: [FactoryGirl.create(:user, role: Role.find_by_name("registered"))])
        expect { post :join, {id: workout}}.to_not change(workout.users, :count)
      end
    end
    context 'Unlimited Workout' do
      login_user
      it 'lets a user join when maxmium_size is 0 (unlimited)' do
        workout = FactoryGirl.create(:workout, maximum_size: 0, users: [FactoryGirl.create(:user, role: Role.find_by_name("registered"))])
        expect { post :join, {id: workout}}.to change(workout.users, :count).by(1)
      end
    end
    context 'Multiple trainers' do
      context 'trainer' do
      login_trainer
        it 'Allows a trainer to join another trainer\'s workout' do
          workout = FactoryGirl.create(:workout, trainer: FactoryGirl.create(:user, role: Role.find_by_name('trainer')))
          expect { post :join, {id: workout}}.to change(workout.users, :count).by(1)
        end
        it 'Does not allow a trainer to join his own workout' do
          workout = FactoryGirl.create(:workout, trainer: @user )
          expect { post :join, {id: workout}}.to_not change(workout.users, :count)
        end
      end
      context 'admin' do
        login_admin
        it 'Allows an admin to join another trainers workout' do
          role = FactoryGirl.create(:role, name: 'trainer')
          workout = FactoryGirl.create(:workout, trainer: FactoryGirl.create(:user, role: role))
          expect { post :join, {id: workout}}.to change(workout.users, :count).by(1)
        end
      end
    end
  end
  
  describe 'POST #quick_add' do
    context 'admin' do
      login_admin
      context 'morning' do
        it 'creates a workout at 6am' do
          post :quick_add, date: '2012-05-01', timeslot: 'morning'
          assigns(:workout).time.should eq Time.new(2012, 5, 1, 6, nil, nil,0)
        end
        it 'creates a workout on the specified date' do
          post :quick_add, date: '2012-05-01', timeslot: 'morning'
          assigns(:workout).date.should eq Date.new(2012,5,1)
        end
        it 'render the index template' do
          post :quick_add, date: '2012-05-01', timeslot: 'morning'
          response.should redirect_to '/workouts/week/2012-05-01'
        end
      end
      context 'noon' do
        it 'creates a workout at 12pm of the selected day' do
          post :quick_add, date: '2012-05-01', timeslot: 'noon'
          assigns(:workout).time.should eq Time.new(2012, 5, 1, 12, nil, nil,0)
        end
        it 'creates a workout on the specified date' do
          post :quick_add, date: '2012-05-01', timeslot: 'noon'
          assigns(:workout).date.should eq Date.new(2012,5,1)
        end
        it 'redirects to the workouts index view' do
           post :quick_add, date: '2012-05-01', timeslot: 'noon'
           response.should redirect_to '/workouts/week/2012-05-01'
        end
      end
      context 'evening' do
        it 'creates a workout at 6:15 pm of the selected day' do
          post :quick_add, date: '2012-05-01', timeslot: 'evening'
          assigns(:workout).time.should eq Time.new(2012, 5, 1, 18, 15, nil,0)
        end
        it 'creates a workout on the specified date' do
          post :quick_add, date: '2012-05-01', timeslot: 'evening'
          assigns(:workout).date.should eq Date.new(2012,5,1)
        end
        it 'redirects to the workouts index view' do
          post :quick_add, date: '2012-05-01', timeslot: 'evening'
           response.should redirect_to '/workouts/week/2012-05-01'
        end
      end
    end
    context 'registered user' do
      login_user
      context 'morning' do
        it 'should not change the workout count' do
          expect {post :quick_add, date: '2012-05-01', timeslot: 'evening'}.to_not change(Workout, :count)
        end
        it 'should redirect the user to the root url' do
          post :quick_add, date: '2012-05-01', timeslot: 'evening'
          response.should redirect_to root_path
        end
      end
      context 'noon' do
        it 'should not change the workout count' do
          expect {post :quick_add, date: '2012-05-01', timeslot: 'noon'}.to_not change(Workout, :count)
        end
        it 'should redirect the user to the root url' do
          post :quick_add, date: '2012-05-01', timeslot: 'noon'
          response.should redirect_to root_path
        end
      end
      context 'evening' do
        it 'should not change the workout count' do
          expect {post :quick_add, date: '2012-05-01', timeslot: 'evening'}.to_not change(Workout, :count)
        end
        it 'should redirect the user to the root url' do
          post :quick_add, date: '2012-05-01', timeslot: 'evening'
          response.should redirect_to root_path
        end
      end
    end
    context 'guest' do
      it 'should not change the workout count' do
        expect {post :quick_add, date: '2012-05-01', timeslot: 'evening'}.to_not change(Workout, :count)
      end
      it 'should redirect the user to the root url' do
        post :quick_add, date: '2012-05-01', timeslot: 'evening'
        response.should redirect_to root_path
      end
    end
    context 'noon' do
      it 'should not change the workout count' do
        expect {post :quick_add, date: '2012-05-01', timeslot: 'noon'}.to_not change(Workout, :count)
      end
      it 'should redirect the user to the root url' do
        post :quick_add, date: '2012-05-01', timeslot: 'noon'
        response.should redirect_to root_path
      end
    end
    context 'evening' do
      it 'should not change the workout count' do
        expect {post :quick_add, date: '2012-05-01', timeslot: 'evening'}.to_not change(Workout, :count)
      end
      it 'should redirect the user to the root url' do
        post :quick_add, date: '2012-05-01', timeslot: 'evening'
        response.should redirect_to root_path
      end
    end
  end
end