FactoryBot.define do
  factory :character_skill do
    association :character
    association :skill
    level { 1 }
  end
end