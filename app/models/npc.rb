class Npc < ApplicationRecord
  belongs_to :room, optional: true

  def interact(character)
    "The NPC #{name} greets #{character.name}."
  end

  def assign_quest(character)
    "NPC #{name} assigns a quest to #{character.name}."
  end
end

