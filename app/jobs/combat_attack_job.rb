class CombatAttackJob < ApplicationJob
  queue_as :default

  def perform(combat_id, attacker_id)
    combat = Combat.find(combat_id)
    attacker = combat.combat_participants.find_by(participant_id: attacker_id)&.participant

    return unless attacker && attacker.health > 0

    if attacker.is_a?(Character)
      defender = combat.combat_participants.find { |cp| cp.participant.is_a?(Enemy) }&.participant
    else
      defender = combat.combat_participants.find { |cp| cp.participant.is_a?(Character) }&.participant
    end

    return unless defender && defender.health > 0

    Rails.logger.debug { "CombatAttackJob: Performing attack by #{attacker.name} on #{defender.name}" }

    combat.perform_attack(attacker, defender)
  end
end
