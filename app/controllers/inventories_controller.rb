class InventoriesController < ApplicationController
  def equip
    @character = Character.find(params[:character_id])
    @item = Equipment.find(params[:item_id])

    result = @character.equip_item(@item)
    render json: { message: result }
  end

  def unequip
    @character = Character.find(params[:character_id])
    @item = Equipment.find(params[:item_id])

    result = @character.unequip_item(@item)
    render json: { message: result }
  end

  def list
    @character = Character.find(params[:character_id])
    inventory_list = @character.inventory_list
    render json: { inventory: inventory_list }
  end
end
