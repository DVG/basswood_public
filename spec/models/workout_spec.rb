require 'spec_helper'

describe Workout do
  it "is invalid without a name" do
    FactoryGirl.build(:workout, name: nil).should_not be_valid
  end
  it "is invalid without a date" do
    FactoryGirl.build(:workout, date: nil).should_not be_valid
  end
  it "is invalid without a maximum size" do
    FactoryGirl.build(:workout, maximum_size: nil).should_not be_valid
  end
  it 'is invalid with a negative number for maximum size' do
    FactoryGirl.build(:workout, maximum_size: -1).should_not be_valid
  end
  it 'is invalid with a non-numeric maximum size' do
    FactoryGirl.build(:workout, maximum_size: 'Hello').should_not be_valid
  end
  it "is valid with a show_date in the format MM/DD/YYYY" do
    FactoryGirl.build(:workout, show_date: '01/01/2012').should be_valid
  end
  it "is invalid without a time" do
    FactoryGirl.build(:workout, time: nil).should_not be_valid
  end
  it 'should have a trainer' do
    FactoryGirl.build(:workout).trainer.should_not be_nil
  end
  it 'should be invalid without a trainer' do
    FactoryGirl.build(:workout, trainer: nil).should_not be_valid
  end
  it "adds a user to the workout when the workout is not at capacity" do
    first_user = FactoryGirl.create(:user)
    second_user = FactoryGirl.create(:user, role: first_user.role)
    workout = FactoryGirl.create(:workout, users: [first_user], maximum_size: 2)
    workout.join_workout(second_user)
    workout.users.size.should eq 2
  end
  it 'does not add a user to the workout if maximum size has been reached' do
    first_user = FactoryGirl.create(:user)
    second_user = FactoryGirl.create(:user, role: first_user.role)
    workout = FactoryGirl.create(:workout, users: [first_user], maximum_size: 1)
    workout.join_workout(second_user)
    workout.users.size.should eq 1
  end
  it 'allows a user to be added to the workout if the workout is an unlimited workout' do
    first_user = FactoryGirl.create(:user)
    second_user = FactoryGirl.create(:user, role: first_user.role)
    workout = FactoryGirl.create(:workout, users: [first_user], maximum_size: 0)
    workout.join_workout(second_user)
    workout.users.size.should eq 2
  end
  it 'returns the number of slots remaining' do
    user = FactoryGirl.create(:user)
    workout = FactoryGirl.create(:workout, users: [user], maximum_size: 5)
    workout.slots_remaining.should eq 4
  end
  it 'returns slots remaining as nil for a workout with unlimited slots' do
    user = FactoryGirl.create(:user)
    workout = FactoryGirl.create(:workout, users: [user], maximum_size: 0)
    workout.slots_remaining.should be_nil
  end
  it 'can have multiple users' do
    first_user = FactoryGirl.create(:user)
    second_user = FactoryGirl.create(:user, role: first_user.role)
    workout = FactoryGirl.create(:workout, users: [first_user, second_user])
    workout.users.should eq [first_user, second_user]
  end
  it 'returns the limit of users for a given workout' do
    workout = FactoryGirl.create(:workout, maximum_size: 20)
    workout.maximum_size.should eq 20
  end
  it 'returns false if maximum size has not been reached' do
    user = FactoryGirl.create(:user)
    workout = FactoryGirl.create(:workout, users: [user], maximum_size: 20)
    workout.at_capacity?.should be_false
  end
  it 'returns true if maximum size has been reached' do
    user = FactoryGirl.create(:user)
    workout = FactoryGirl.create(:workout, users: [user], maximum_size: 1)
    workout.at_capacity?.should be_true
  end
  # Maximum Size of means an unlimited capacity
  it 'always returns false if maximum_size is 0' do
    FactoryGirl.create(:workout, maximum_size: 0).at_capacity?.should be_false
  end
  describe "Return workouts for the week of a given date" do
    before :each do
      @start_date = Date.new(2012, 5, 6) # Sunday May 5, 2012
      #range should be between Sunday May 5, 2012 and Saturday May 12, 2012
      @sunday_workout = FactoryGirl.create(:workout, date: @start_date)
      @wednesday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 5, 9))
      @saturday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 5, 12))
      @next_sunday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 5, 13))
      @prev_saturday_workout = FactoryGirl.create(:workout, date: Date.new(2012, 5, 4))
      @this_weeks_workouts = [@sunday_workout, @wednesday_workout, @saturday_workout]
      @not_this_weeks_workouts = [@next_sunday_workout, @prev_saturday_workout]
    end
    context "matching dates" do
      it "returns all the workouts in a sunday to saturday week for a given date" do  
        Workout.for_week_starting(@start_date).should eq @this_weeks_workouts
      end
    end
    context "non-matching dates" do
      it "will not return workouts outside the given date's week" do
         Workout.for_week_starting(@start_date).should_not include @not_this_weeks_workouts
      end
    end
  end
  it "returns the date of a workout in the format MM/DD/YYYY" do
    workout = FactoryGirl.build(:workout)
    workout.show_date.should eq workout.date.strftime('%m/%d/%Y')
  end
  context 'Multiple Trainers' do
    before :each do
      role = FactoryGirl.create(:role, name: 'trainer')
      @trainer_one = FactoryGirl.create(:user, role: role)
      @trainer_two = FactoryGirl.create(:user, role: role)
      @workout = FactoryGirl.create(:workout, trainer: @trainer_one)
    end
    it 'Allows a second trainer to join a workout' do 
      @workout.join_workout(@trainer_two)
      @workout.users.size.should eq 1
    end
    it 'Does not allow a trainer to join his own workout' do
      @workout.join_workout(@trainer_one)
      @workout.users.size.should eq 0
    end
    it 'Allows an admin to join any workout they don\'t own' do
      admin_role = FactoryGirl.create(:role, name: 'admin')
      admin = FactoryGirl.create(:user, role: admin_role)
      @workout.join_workout(admin)
      @workout.users.size.should eq 1
    end
  end
end