FactoryBot.define do
  factory :npc do
    sequence(:name) { |n| "NPC #{n}" }
    description { "A friendly NPC" }
    association :room, factory: :room, strategy: :build
  end
end