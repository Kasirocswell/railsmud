FactoryBot.define do
  factory :skill do
    sequence(:name) { |n| "Skill #{n}" }
    description { "This is a test skill" }
  end
end