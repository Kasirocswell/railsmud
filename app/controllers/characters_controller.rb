class CharactersController < ApplicationController
  before_action :set_character, only: [:show, :look, :move, :pick_up, :drop, :equip, :unequip, :use_item, :show_inventory, :examine, :list_skills, :list_abilities, :destroy]

  # GET /characters
  def index
    @characters = Character.all
    render json: @characters.as_json(include: :inventory)
  end

 # GET /characters/:id
def show
  render json: @character.as_json(include: { current_room: { include: [:enemies, :items] }, inventory: { include: :items }, abilities: { only: [:name, :description, :level] } })
end


   # POST /characters
  def create
    @character = Character.new(character_params)
    @character.current_room = Room.first # Assign a default room if needed

    attributes = params[:attributes]
    @character.strength = attributes[:strength]
    @character.dexterity = attributes[:dexterity]
    @character.constitution = attributes[:constitution]
    @character.intelligence = attributes[:intelligence]
    @character.wisdom = attributes[:wisdom]
    @character.charisma = attributes[:charisma]
    @character.luck = attributes[:luck]
    @character.speed = attributes[:speed]

    if @character.save
      Skill.all.each do |skill|
        CharacterSkill.create!(character: @character, skill: skill, level: 1)
      end
      render json: @character.as_json(include: { inventory: { include: :items }, character_skills: { include: :skill } }), status: :created
    else
      render json: { errors: @character.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("Error creating character: #{e.message}")
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  # DELETE /characters/:id
  def destroy
    @character.destroy
    head :no_content
  end

  # POST /characters/:id/look
  def look
    directions = {
      north: @character.current_room&.north.present?,
      south: @character.current_room&.south.present?,
      east: @character.current_room&.east.present?,
      west: @character.current_room&.west.present?
    }

    render json: {
      room_description: @character.current_room&.description || "No description available",
      enemies: @character.current_room&.enemies&.pluck(:name) || [],
      loot: @character.current_room&.items&.pluck(:name) || [],
      directions: directions
    }
  end

  # POST /characters/:id/move/:direction
  def move
    direction = params[:direction]
    new_room = case direction
               when 'north' then @character.current_room&.north
               when 'south' then @character.current_room&.south
               when 'east' then @character.current_room&.east
               when 'west' then @character.current_room&.west
               end

    if new_room
      @character.update!(current_room: new_room)
      render json: {
        message: "Moved #{direction}",
        character: @character.as_json(include: { current_room: { include: [:enemies, :items] } })
      }
    else
      render json: { error: 'Invalid direction or no room in that direction' }, status: :unprocessable_entity
    end
  end

  def pick_up
    item = @character.current_room.items.find(params[:item_id])
    unless @character.inventory
      puts "Creating inventory for character #{@character.id}"
      @character.create_inventory!
    end
    @inventory = @character.inventory
  
    if item.slot.present?
      puts "Item slot: #{item.slot}"
      item.update!(room_id: nil, inventory_id: @inventory.id)
      render json: {
        message: "Picked up #{item.name}",
        character: @character.as_json(include: { inventory: { include: :items } })
      }
    else
      puts "Item slot is missing"
      render json: { error: 'Item slot is missing' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "Error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /characters/:id/drop/:item_id
  def drop
    item = @character.inventory.items.find(params[:item_id])
    item.update!(inventory_id: nil, room_id: @character.current_room.id)
    render json: {
      message: "Dropped #{item.name}",
      character: @character.as_json(include: { inventory: { include: :items } })
    }
  end

  # POST /characters/:id/equip_item/:item_id
  def equip
    item = @character.inventory.items.find(params[:item_id])
    message = @character.inventory.equip(item)
    render json: {
      message: message,
      character: @character.as_json(include: { inventory: { include: :items } })
    }
  end

  # POST /characters/:id/unequip_item/:item_id
  def unequip
    item = @character.inventory.items.find(params[:item_id])
    message = @character.inventory.unequip(item)
    render json: {
      message: message,
      character: @character.as_json(include: { inventory: { include: :items } })
    }
  end

  # POST /characters/:id/use/:item_id
  def use_item
    item = @character.inventory.items.find_by(id: params[:item_id])
    if item
      puts "Item found: #{item.name}, type: #{item.item_type}"
      if item.item_type == 'usable'
        message = item.use_item(@character)
        render json: {
          message: message,
          character: @character.as_json(include: { inventory: { include: :items } })
        }
      else
        render json: { error: 'This item cannot be used' }, status: :unprocessable_entity
      end
    else
      puts "Item not found in inventory"
      render json: { error: 'Invalid target for use command' }, status: :unprocessable_entity
    end
  end

  # POST /characters/:id/examine/:item_id
  def examine
    if @character.inventory
      item = @character.inventory.items.find_by(id: params[:item_id])
      if item
        render json: { message: item.description }
      else
        render json: { error: 'Item not found in inventory' }, status: :not_found
      end
    else
      render json: { error: 'Inventory not found' }, status: :unprocessable_entity
    end
  end

  # GET /characters/:id/inventory
  def show_inventory
    equipped_items = @character.inventory.items.where(equipped: true)
    inventory_items = @character.inventory.items.where(equipped: false)
    render json: {
      equipped_items: equipped_items,
      inventory_items: inventory_items,
      character: @character.as_json(include: { inventory: { include: :items } })
    }
  end

  # GET /characters/:id/skills
  def list_skills
    skills = @character.character_skills.map do |character_skill|
      {
        name: character_skill.skill.name,
        level: character_skill.level
      }
    end

    render json: { skills: skills }
  rescue StandardError => e
    puts "Error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /characters/:id/abilities
  def list_abilities
    abilities = @character.abilities.map do |ability|
      {
        name: ability.name,
        description: ability.description,
        level: ability.level
      }
    end

    render json: { abilities: abilities }
  rescue StandardError => e
    puts "Error: #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_character
    @character = Character.find(params[:id])
  end

  def character_params
    params.require(:character).permit(:name, :race, :character_class, :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :luck, :speed, :action_points)
  end

  def assign_starting_abilities(character)
    starting_abilities = {
      "Human" => [{ name: "Human Resilience", description: "Increase luck by 10 for a short period." }],
      "Soldier" => [{ name: "Power Strike", description: "A powerful attack that deals extra damage." }]
    }

    character_abilities = starting_abilities[character.race] + starting_abilities[character.character_class]

    character_abilities.each do |ability|
      Ability.create!(character: character, name: ability[:name], description: ability[:description], level: 1)
    end
  end
end
