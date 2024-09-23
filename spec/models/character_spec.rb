require 'rails_helper'

RSpec.describe Character, type: :model do
  let(:character) { create(:character) }
  let(:room) { create(:room) }
  let(:item) { create(:item) }
  let(:enemy) { create(:enemy) }
  let(:combat) { create(:combat, :ongoing, enemy: enemy) }

  describe 'associations' do
    it { should belong_to(:current_room).class_name('Room').optional }
    it { should have_one(:inventory).dependent(:destroy) }
    it { should have_many(:character_abilities).dependent(:destroy) }
    it { should have_many(:abilities).through(:character_abilities) }
    it { should have_many(:character_skills).dependent(:destroy) }
    it { should have_many(:skills).through(:character_skills) }
    it { should have_many(:combat_participants).dependent(:destroy) }
    it { should have_many(:combats).through(:combat_participants) }
    it { should have_many(:combat_logs) }
  end

  describe 'callbacks' do
    it 'initializes attributes before create' do
      expect(character.health).to eq(100)
      expect(character.action_points).to eq(100)
      expect(character.credits).to eq(100)
      expect(character.xp).to eq(0)
      expect(character.level).to eq(1)
      expect(character.xp_until_next_level).to eq(1000)
    end

    it 'creates inventory after create' do
      expect(character.inventory).to be_present
    end

    it 'assigns starting skills after create' do
      expect(character.skills).not_to be_empty
    end

    it 'assigns starting abilities after create' do
      expect(character.abilities).not_to be_empty
    end
  end

  describe '#move' do
    before { character.update(current_room: room) }

    context 'when the direction is valid' do
      it 'moves the character to the new room' do
        new_room = create(:room)
        allow(room).to receive(:north).and_return(new_room)
        result = character.move('north')
        expect(character.current_room).to eq(new_room)
        expect(result).to eq("You moved north to #{new_room.name}.")
      end
    end

    context 'when the direction is invalid' do
      it 'does not move the character' do
        allow(room).to receive(:north).and_return(nil)
        result = character.move('north')
        expect(character.current_room).to eq(room)
        expect(result).to eq("You can't move north from here.")
      end
    end
  end

  describe '#inventory_list' do
    it 'returns a comma-separated list of item names' do
      item1 = create(:item, name: 'Sword')
      item2 = create(:item, name: 'Shield')
      character.inventory.items << [item1, item2]
      expect(character.inventory_list).to eq('Sword, Shield')
    end
  end

  describe '#pick_up' do
    before { character.update(current_room: room) }

    context 'when the item is in the room' do
      it 'adds the item to the character\'s inventory' do
        room.items << item
        result = character.pick_up(item)
        expect(character.inventory.items).to include(item)
        expect(result).to eq("You picked up the #{item.name}.")
      end
    end

    context 'when the item is not in the room' do
      it 'does not add the item to the inventory' do
        result = character.pick_up(item)
        expect(character.inventory.items).not_to include(item)
        expect(result).to eq("The item is not in this room.")
      end
    end
  end

  describe '#drop' do
    before do
      character.update(current_room: room)
      character.inventory.items << item
    end

    context 'when the character has the item' do
      it 'removes the item from the inventory and adds it to the room' do
        result = character.drop(item)
        expect(character.inventory.items).not_to include(item)
        expect(room.items).to include(item)
        expect(result).to eq("You dropped the #{item.name}.")
      end
    end

    context 'when the character does not have the item' do
      let(:other_item) { create(:item) }

      it 'does not change the inventory or room' do
        result = character.drop(other_item)
        expect(character.inventory.items).not_to include(other_item)
        expect(room.items).not_to include(other_item)
        expect(result).to eq("You don't have that item.")
      end
    end
  end

  describe '#equip_item' do
    let(:weapon) { create(:item, :weapon) }

    before { character.inventory.items << weapon }

    it 'equips the item' do
      result = character.equip_item(weapon)
      expect(weapon.reload.equipped).to be true
      expect(result).to eq("You equipped the #{weapon.name}.")
    end
  end

  describe '#unequip_item' do
    let(:weapon) { create(:item, :weapon, equipped: true) }

    before { character.inventory.items << weapon }

    it 'unequips the item' do
      result = character.unequip_item(weapon)
      expect(weapon.reload.equipped).to be false
      expect(result).to eq("You unequipped the #{weapon.name}.")
    end
  end

  describe '#total_attack' do
    it 'calculates total attack including weapon damage' do
      character.update(strength: 10)
      weapon = create(:item, :weapon, damage: 5, equipped: true)
      character.inventory.items << weapon
      expect(character.total_attack).to eq(15)
    end
  end

  describe '#total_defense' do
    it 'calculates total defense' do
      character.update(constitution: 5)
      expect(character.total_defense).to eq(15) # base_defense (10) + constitution (5)
    end
  end

  describe '#attack' do
    before do
      allow(character).to receive(:current_combat).and_return(combat)
      allow(enemy).to receive(:current_combat).and_return(combat)
    end

    it 'deals damage to the target' do
      allow(character).to receive(:calculate_damage_against).and_return(10)
      expect { character.attack(enemy) }.to change { enemy.health }.by(-10)
    end

    it 'creates a single combat log' do
      allow(character).to receive(:calculate_damage_against).and_return(10)
      expect { character.attack(enemy) }.to change { CombatLog.count }.by(1)
    end

    context 'when the target is defeated' do
      it 'calls the die method on the target' do
        allow(character).to receive(:calculate_damage_against).and_return(enemy.health)
        expect(enemy).to receive(:die)
        character.attack(enemy)
      end
    end
  end

  describe '#receive_damage' do
    it 'reduces health and returns a log entry' do
      expect { character.receive_damage(10, enemy) }.to change { character.health }.by(-10)
      expect(character.receive_damage(10, enemy)).to include("received 10 damage")
    end

    context 'when health drops to 0 or below' do
      it 'sets health to 0 and returns a defeated log entry' do
        character.update(health: 5)
        log_entry = character.receive_damage(10, enemy)
        expect(character.health).to eq(0)
        expect(log_entry).to include("has been defeated")
      end
    end
  end

  describe '#die' do
    it 'marks the character as not alive and returns a log entry' do
      expect { character.die }.to change { character.alive? }.from(true).to(false)
      expect(character.die).to include("has been defeated")
    end
  end

  describe '#attack_speed' do
    it 'calculates attack speed based on speed attribute' do
      character.update(speed: 20)
      expect(character.attack_speed).to be_within(0.01).of(4)
    end

    it 'ensures a minimum attack speed' do
      character.update(speed: 100)
      expect(character.attack_speed).to eq(0.5)
    end
  end

  describe '#calculate_damage_against' do
    it 'calculates damage based on attack and defense' do
      allow(character).to receive(:total_attack).and_return(15)
      allow(enemy).to receive(:total_defense).and_return(5)
      expect(character.calculate_damage_against(enemy)).to eq(10)
    end

    it 'returns 0 if defense is higher than attack' do
      allow(character).to receive(:total_attack).and_return(5)
      allow(enemy).to receive(:total_defense).and_return(10)
      expect(character.calculate_damage_against(enemy)).to eq(0)
    end
  end

  describe '#as_json' do
    it 'includes additional attributes' do
      json = character.as_json
      expect(json.keys).to include(:total_attack, :total_defense)
      expect(json[:skills]).to be_an(Array)
      expect(json[:abilities]).to be_an(Array)
    end
  end
end