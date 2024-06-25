class EnemyAggressionJob
    include Sidekiq::Worker
  
    def perform(enemy_id)
      enemy = Enemy.find(enemy_id)
      return if enemy.aggression_level.zero?
  
      target = select_target(enemy)
      enemy.attack(target) if target
    end
  
    private
  
    def select_target(enemy)
      # Logic to select the target based on enemy's aggression behavior
      # For simplicity, let's select a random character in the room
      enemy.room.characters.sample
    end
  end
  