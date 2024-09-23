FactoryBot.define do
  factory :enemy do
    sequence(:name) { |n| "Enemy #{n}" }
    health { 100 }
    attack_points { 10 }
    defense { 5 }
    speed { 10 }
    aggression_level { 5 }
    alive { true }
    association :room
  end
end