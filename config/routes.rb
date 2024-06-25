Rails.application.routes.draw do
  resources :characters, only: [:index, :show, :create, :destroy] do
    member do
      post 'move/:direction', to: 'characters#move'
      post 'attack/:enemy_id', to: 'combats#create'
      post 'activate_ability/:ability_id/target_enemy/:enemy_id', to: 'abilities#activate'
      post 'look', to: 'characters#look'
      post 'pick_up/:item_id', to: 'characters#pick_up'
      post 'drop/:item_id', to: 'characters#drop'
      post 'equip_item/:item_id', to: 'characters#equip'
      post 'unequip_item/:item_id', to: 'characters#unequip'
      post 'use/:item_id', to: 'characters#use_item'
      post 'examine/:item_id', to: 'characters#examine'
      get 'inventory', to: 'characters#show_inventory'
      get 'skills', to: 'characters#list_skills'
      get 'combat_logs', to: 'combat_logs#index'
    end
  end

  resources :enemies

  # NPC interactions
  post 'characters/:character_id/interact_with_npc/:npc_id', to: 'npc_interactions#interact', as: 'interact_with_npc'
  post 'characters/:character_id/npc_assign_quest/:npc_id', to: 'npc_interactions#assign_quest', as: 'npc_assign_quest'

  # Combat actions
  post 'characters/:character_id/attack_enemy/:enemy_id', to: 'combats#attack', as: 'attack_enemy'

  # Status check
  get 'characters/:character_id/status', to: 'status#check', as: 'character_status'

  # Combat logs
  get 'characters/:character_id/combat_logs', to: 'combat_logs#index', as: 'character_combat_logs'

  # Ability actions
  post 'characters/:character_id/use_ability/:ability_id/target/:target_id', to: 'abilities#use_on_character', as: 'use_ability_on_character'
  post 'characters/:character_id/use_ability/:ability_id/target_enemy/:enemy_id', to: 'abilities#use_on_enemy', as: 'use_ability_on_enemy'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "characters#index"
end
