FactoryBot.define do
  factory :combat do
    association :enemy
    status { :ongoing }
  end

  factory :combat_participant do
    association :combat
    association :participant, factory: :character
  end
end