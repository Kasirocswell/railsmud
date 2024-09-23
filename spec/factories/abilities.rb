FactoryBot.define do
  factory :ability do
    sequence(:name) { |n| "Ability #{n}" }
    description { "This is a test ability" }
    level { 1 }
  end
end