# app/jobs/enemy_aggression_job.rb
class EnemyAggressionJob
  include Sidekiq::Worker

  def perform(enemy_id)
    enemy = Enemy.find(enemy_id)
    return if enemy.aggression_level.zero? || !enemy.alive?

    target = select_target(enemy)
    return unless target

    current_combat = Combat.create!(enemy: enemy, status: Combat::PENDING)
    current_combat.add_participant(enemy)
    current_combat.add_participant(target)
    current_combat.start_combat
    current_combat.execute_combat
  end

  private

  def select_target(enemy)
    enemy.room.characters.sample
  end
end
