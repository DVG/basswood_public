FactoryGirl.define do
  factory :workout do
    name 'Workout'
    date Date.today
    time Time.now
    users []
    maximum_size 10
    trainer
    factory :invalid_workout do
      date nil
    end
  end
end