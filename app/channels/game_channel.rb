class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def move(data)
    character = Character.find(data['character_id'])
    direction = data['direction']
    result = character.move(direction)
    ActionCable.server.broadcast 'game_channel', message: result, character_id: character.id, current_room: character.current_room.name
  end

  def attack(data)
    character = Character.find(data['character_id'])
    enemy = Enemy.find(data['enemy_id'])
    result = character.attack(enemy)
    ActionCable.server.broadcast 'game_channel', message: result, character_id: character.id, enemy_id: enemy.id
  end

  def use_ability(data)
    character = Character.find(data['character_id'])
    ability = Ability.find(data['ability_id'])
    target = Character.find(data['target_id']) if data['target_id'].present?
    target = Enemy.find(data['enemy_id']) if data['enemy_id'].present?
    result = character.use_ability(ability, target)
    ActionCable.server.broadcast 'game_channel', message: result, character_id: character.id, target_id: target.id
  end
end
