FactoryGirl.define do
  factory :role do
    name "registered"
    factory :admin_role do
      name "admin"
    end
  end
end
