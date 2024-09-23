require 'rails_helper'

RSpec.describe Enemy, type: :model do
  let(:enemy) { create(:enemy) }
  let(:room) { create(:room) }
  let(:character) { create(:character) }
  let(:combat) { create(:combat, enemy: enemy, status: :ongoing) }

  describe 'associations' do
    it { should belong_to(:room) }
    it { should have_many(:combat_participants) }
    it { should have_many(:combats) }
    it { should have_many(:combat_logs) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:health).only_integer }
    it { should validate_numericality_of(:attack_points).only_integer }
    it { should validate_numericality_of(:defense).only_integer.allow_nil }
    it { should validate_numericality_of(:aggression_level).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(10) }
  end

  describe 'callbacks' do
    it 'schedules aggression check after create' do
      expect(EnemyAggressionJob).to receive(:perform_in)
      create(:enemy, aggression_level: 5)
    end

    it 'does not schedule aggression check if aggression level is zero' do
      expect(EnemyAggressionJob).not_to receive(:perform_in)
      create(:enemy, aggression_level: 0)
    end
  end

  describe '#attack' do
    before do
      allow(enemy).to receive(:current_combat).and_return(combat)
      create(:combat_participant, combat: combat, participant: character)
    end

    it 'deals damage to the target' do
      allow(enemy).to receive(:calculate_damage_against).and_return(10)
      expect { enemy.attack(character) }.to change { character.health }.by(-10)
    end

    it 'creates combat logs' do
      allow(enemy).to receive(:calculate_damage_against).and_return(10)
      expect { enemy.attack(character) }.to change { CombatLog.count }.by(1)
    end

    context 'when the target is defeated' do
      it 'calls the die method on the target' do
        allow(enemy).to receive(:calculate_damage_against).and_return(character.health)
        expect(character).to receive(:die)
        enemy.attack(character)
      end
    end
  end

  describe '#attack_speed' do
    it 'calculates attack speed based on speed attribute' do
      enemy.update(speed: 20)
      expect(enemy.attack_speed).to be_within(0.01).of(4)
    end

    it 'ensures a minimum attack speed' do
      enemy.update(speed: 100)
      expect(enemy.attack_speed).to eq(0.5)
    end
  end

  describe '#total_defense' do
    it 'calculates total defense' do
      enemy.update(defense: 5)
      expect(enemy.total_defense).to eq(15) # base_defense (10) + defense (5)
    end
  end

  describe '#receive_damage' do
    let(:combat) { create(:combat, enemy: enemy, status: :ongoing) }
    let(:character) { create(:character) }

    before do
      allow(enemy).to receive(:current_combat).and_return(combat)
      create(:combat_participant, combat: combat, participant: character)
    end

    it 'reduces health and returns a log entry when not defeated' do
      enemy.update(health: 20)
      expect { enemy.receive_damage(10, character) }.to change { enemy.health }.by(-10)
      expect(enemy.receive_damage(5, character)).to include("received 5 damage")
    end

    it 'sets health to 0 and returns a defeated log entry when health drops to 0 or below' do
      enemy.update(health: 5)
      log_entry = enemy.receive_damage(10, character)
      expect(enemy.health).to eq(0)
      expect(log_entry).to include("has been defeated")
    end

    it 'creates a combat log with correct attacker' do
      expect { enemy.receive_damage(10, character) }.to change { CombatLog.count }.by(1)
      expect(CombatLog.last.attacker).to eq(character)
    end
  end

  describe '#die' do
    before do
      allow(enemy).to receive(:current_combat).and_return(combat)
      create(:combat_participant, combat: combat, participant: character)
    end

    it 'marks the enemy as not alive, creates a combat log, and completes the combat' do
      enemy.update(alive: true, health: 10)

      # Mock the broadcast_append_to method to avoid ActionCable errors in test
      allow_any_instance_of(CombatLog).to receive(:broadcast_append_to)

      expect { enemy.die }.to change { enemy.reload.alive? }.from(true).to(false)
      expect(enemy.health).to eq(0)
      expect(CombatLog.last).to be_present
      expect(CombatLog.last.log_entry).to include("has been defeated")
      expect(combat.reload.status).to eq('completed')
    end

    it 'sets the attacker to the enemy itself if no character is present' do
      combat.combat_participants.destroy_all
      enemy.die
      expect(CombatLog.last.attacker).to eq(enemy)
    end
  end

  describe '#calculate_damage_against' do
    it 'calculates damage based on attack and defense' do
      enemy.update(attack_points: 15)
      allow(character).to receive(:total_defense).and_return(5)
      expect(enemy.calculate_damage_against(character)).to eq(10)
    end

    it 'returns 0 if defense is higher than attack' do
      enemy.update(attack_points: 5)
      allow(character).to receive(:total_defense).and_return(10)
      expect(enemy.calculate_damage_against(character)).to eq(0)
    end
  end

  describe '#alive?' do
    it 'returns true when health is above 0' do
      enemy.update(health: 1)
      expect(enemy).to be_alive
    end

    it 'returns false when health is 0' do
      enemy.update(health: 0)
      expect(enemy).not_to be_alive
    end
  end

  describe '#current_combat' do
    it 'returns the last ongoing combat' do
      completed_combat = create(:combat, enemy: enemy, status: :completed)
      ongoing_combat = create(:combat, enemy: enemy, status: :ongoing)
      expect(enemy.current_combat).to eq(ongoing_combat)
      expect(enemy.current_combat).not_to eq(completed_combat)
    end
  end

  describe '#total_attack' do
    it 'returns the attack_points' do
      enemy.update(attack_points: 20)
      expect(enemy.total_attack).to eq(20)
    end
  end
end