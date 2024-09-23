FactoryBot.define do
  factory :item do
    name { "Test Item" }
    description { "This is a test item" }
    item_type { :weapon }
    slot { "hand" }
    damage { 10 }
    defense { 0 }
    effect { "None" }
    effect_description { "No special effect" }
    speed_bonus { 0 }
    rarity { "common" }

    trait :weapon do
      item_type { :weapon }
      damage { 20 }
    end

    trait :armor do
      item_type { :armor }
      defense { 15 }
    end

    trait :usable do
      item_type { :usable }
      effect_description { "Heals 50 HP" }
    end
  end
end