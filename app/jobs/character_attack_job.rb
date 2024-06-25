class CharacterAttackJob < ApplicationJob
    queue_as :default
  
    def perform(character_id, enemy_id)
      character = Character.find(character_id)
      enemy = Enemy.find(enemy_id)
      combat = character.current_combat
  
      if combat && combat.ongoing?
        damage = character.calculate_damage_against(enemy)
        enemy.receive_damage(damage, character)
        CharacterAttackJob.perform_in(character.attack_speed.seconds, character.id, enemy.id) if enemy.alive?
      end
    end
  end
  