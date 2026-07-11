FactoryBot.define do
  factory :store do
    name { "テストカフェ" }
    image_url { "https://example.com/image.jpg" }
    smoking { false }
  end
end
