require 'rails_helper'

RSpec.describe Npc, type: :model do
  let(:npc) { create(:npc, name: "Friendly NPC") }
  let(:character) { create(:character, name: "Adventurer") }
  let(:room) { create(:room) }

  describe 'associations' do
    it { should belong_to(:room) }
  end

  describe 'validations' do
    it { should validate_presence_of(:room) }
  end

  describe '#interact' do
    it 'returns a greeting message' do
      expect(npc.interact(character)).to eq("The NPC Friendly NPC greets Adventurer.")
    end
  end

  describe '#assign_quest' do
    it 'returns a quest assignment message' do
      expect(npc.assign_quest(character)).to eq("NPC Friendly NPC assigns a quest to Adventurer.")
    end
  end

  describe 'room association' do
    it 'is always associated with a room' do
      expect(npc.room).to be_present
    end

    it 'can be moved to a different room' do
      original_room = npc.room
      new_room = create(:room)
      expect { npc.update!(room: new_room) }.not_to raise_error
      expect(npc.room).to eq(new_room)
      expect(npc.room).not_to eq(original_room)
    end

    it 'cannot be created without a room' do
      expect { Npc.create!(name: "Roomless NPC") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'cannot have its room set to nil' do
      expect { npc.update!(room: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end