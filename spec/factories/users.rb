FactoryBot.define do
  factory :user do
    name { Faker::Lorem.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    confirmed_at { Time.current }
  end
end
