FactoryBot.define do
  factory :seat do
    association :store
    seat_number { "A-1" }
    seat_type { "テーブル席" }
    capacity { 4 }
    price_per_hour { 880 }
  end
end
