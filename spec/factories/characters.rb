FactoryBot.define do
  factory :character do
    name { "John Doe" }
    race { "Human" }
    character_class { "Warrior" }
    strength { 10 }
    dexterity { 10 }
    constitution { 10 }
    intelligence { 10 }
    wisdom { 10 }
    charisma { 10 }
    luck { 10 }
    speed { 10 }
    health { 100 }
    action_points { 100 }
    credits { 100 }
    xp { 0 }
    level { 1 }
    xp_until_next_level { 1000 }
    association :current_room, factory: :room

    after(:create) do |character|
      create(:character_skill, character: character, skill: create(:skill))
      create(:character_ability, character: character, ability: create(:ability))
    end
  end
end