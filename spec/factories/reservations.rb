FactoryBot.define do
  factory :reservation do
    association :user
    association :seat
    start_time { 1.day.from_now }
    num_people { 2 }
    phone_number { "09012345678" }
    status { :reserved }
  end
end
