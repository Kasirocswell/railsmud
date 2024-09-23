# spec/factories/combat_logs.rb
FactoryBot.define do
  factory :combat_log do
    log_entry { "Character attacks enemy" }
    association :combat
    association :character
    association :enemy
    association :attacker, factory: :character
  end
end