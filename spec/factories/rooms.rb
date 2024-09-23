# spec/factories/rooms.rb
FactoryBot.define do
  factory :room do
    name { "Test Room" }
    description { "This is a test room" }
  end
end