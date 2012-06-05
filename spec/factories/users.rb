# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :email do |n|
      "email#{n}@factory.com"
    end
  factory :user do
    email
    password "foobar"
    password_confirmation { |u| u.password }
    role
    full_name 'Bob Dole'
    bio 'I pick things up and put them down'
    favorite_workout 'AMRAP Deadlifts'
    avatar nil
    hide_me false
    factory :trainer do
      role Role.find_or_create_by_name 'trainer'
    end
  end
end
