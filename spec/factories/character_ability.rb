FactoryBot.define do
  factory :character_ability do
    association :character
    association :ability
  end
end