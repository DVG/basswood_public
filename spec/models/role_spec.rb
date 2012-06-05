require 'spec_helper'

describe Role do
  it 'is invalid without a name' do
    FactoryGirl.build(:role, name: nil).should_not be_valid
  end
  it 'must have a unique name' do
    first_admin = FactoryGirl.create(:role, name: 'admin')
    FactoryGirl.build(:role, name: 'admin').should_not be_valid
  end
end
