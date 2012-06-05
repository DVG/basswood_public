require 'spec_helper'

describe User do
  it 'Returns the role for an admin user as an array containing one symbol' do
    role = FactoryGirl.create(:role, name: 'admin')
    user = FactoryGirl.create(:user, role: role)
    user.role_symbols.should eq [:admin]
  end
  it 'Returns the role for a registred user as an array containing one symbol' do
    user = FactoryGirl.create(:user)
    user.role_symbols.should eq [:registered]
  end
  it 'needs to have a unique email' do
    first_admin = FactoryGirl.create(:user, email: 'admin@admin.com')
    FactoryGirl.build(:user, role: first_admin.role, email: first_admin.email).should_not be_valid
  end
  it 'returns true if the user is an admin' do
    admin = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'admin'))
    admin.admin?.should be_true
  end
  it 'returns false for admin? if the user is a trainer' do
    trainer = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'trainer'))
    trainer.admin?.should be_false
  end
  it 'returns true for trainer? if the user is a trainer' do
    trainer = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'trainer'))
    trainer.trainer?.should be_true
  end
  it 'returns false for trainer? if the user is a normal user' do
    registered = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'registered'))
    registered.trainer?.should be_false
  end
  it 'returns false for trainer? if the user is an admin' do
    admin = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'admin'))
    admin.trainer?.should be_false
  end
  it 'returns false if the user is a registered user' do
    registered = FactoryGirl.create(:user, role: FactoryGirl.create(:role, name: 'registered'))
    registered.admin?.should be_false
  end
  it 'can be a member of several workouts' do
    user = FactoryGirl.create(:user)
    workout_one = FactoryGirl.create(:workout, :users => [user])
    workout_two = FactoryGirl.create(:workout, :users => [user])
    user.workouts.should eq [workout_one, workout_two]
  end
  it 'has a full name for the user' do
    user = FactoryGirl.create(:user, :full_name => 'Bradley Temple')
    user.full_name.should eq 'Bradley Temple'
  end
  it 'has a favorite workout for the user' do
    user = FactoryGirl.create(:user, :favorite_workout => 'Fran')
    user.favorite_workout.should eq 'Fran'
  end
  it 'returns a list of users with the Trainer role' do
    trainer_role = FactoryGirl.create(:role, name: 'trainer')
    admin_role = FactoryGirl.create(:role, name: 'admin')
    trainer_one = FactoryGirl.create(:user, role: trainer_role)
    trainer_two = FactoryGirl.create(:user, role: trainer_role)
    admin = FactoryGirl.create(:user, role: admin_role)
    regular_user = FactoryGirl.create(:user)
    User.trainers.should eq [trainer_one, trainer_two, admin]
  end
end
