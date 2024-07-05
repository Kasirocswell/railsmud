# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_24_215625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abilities", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", default: 1, null: false
  end

  create_table "character_abilities", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "ability_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ability_id"], name: "index_character_abilities_on_ability_id"
    t.index ["character_id"], name: "index_character_abilities_on_character_id"
  end

  create_table "character_skills", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "skill_id", null: false
    t.integer "level", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_skills_on_character_id"
    t.index ["skill_id"], name: "index_character_skills_on_skill_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "race"
    t.string "character_class"
    t.string "subclass"
    t.integer "level", default: 1
    t.integer "health"
    t.integer "action_points"
    t.integer "strength"
    t.integer "intelligence"
    t.integer "dexterity"
    t.integer "speed"
    t.integer "constitution"
    t.integer "charisma"
    t.integer "luck"
    t.integer "wisdom"
    t.text "inventory"
    t.integer "credits"
    t.integer "xp"
    t.integer "xp_until_next_level"
    t.integer "current_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "combat_logs", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "enemy_id", null: false
    t.text "log_entry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "combat_id"
    t.string "attacker_type", null: false
    t.bigint "attacker_id", null: false
    t.index ["attacker_type", "attacker_id"], name: "index_combat_logs_on_attacker"
    t.index ["character_id"], name: "index_combat_logs_on_character_id"
    t.index ["combat_id"], name: "index_combat_logs_on_combat_id"
    t.index ["enemy_id"], name: "index_combat_logs_on_enemy_id"
  end

  create_table "combat_participants", force: :cascade do |t|
    t.bigint "combat_id", null: false
    t.string "participant_type", null: false
    t.bigint "participant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["combat_id"], name: "index_combat_participants_on_combat_id"
    t.index ["participant_type", "participant_id"], name: "index_combat_participants_on_participant"
  end

  create_table "combats", force: :cascade do |t|
    t.bigint "enemy_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enemy_id"], name: "index_combats_on_enemy_id"
  end

  create_table "enemies", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "health"
    t.integer "attack_points"
    t.bigint "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "aggression_level", default: 0
    t.integer "speed", default: 5
    t.integer "defense"
    t.index ["room_id"], name: "index_enemies_on_room_id"
  end

  create_table "equipments", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slot"
    t.bigint "inventory_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_equipments_on_inventory_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_inventories_on_character_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "slot", default: "misc"
    t.integer "item_type", null: false
    t.integer "damage", default: 0
    t.string "effect", default: ""
    t.integer "defense", default: 0
    t.string "effect_description", default: ""
    t.integer "speed_bonus", default: 0
    t.string "rarity", default: "common"
    t.text "description", null: false
    t.integer "inventory_id"
    t.bigint "room_id"
    t.boolean "equipped", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_items_on_inventory_id"
    t.index ["room_id"], name: "index_items_on_room_id"
  end

  create_table "npcs", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_npcs_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "north_id"
    t.integer "south_id"
    t.integer "east_id"
    t.integer "west_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  add_foreign_key "character_abilities", "abilities"
  add_foreign_key "character_abilities", "characters"
  add_foreign_key "character_skills", "characters"
  add_foreign_key "character_skills", "skills"
  add_foreign_key "characters", "rooms", column: "current_room_id"
  add_foreign_key "combat_logs", "characters"
  add_foreign_key "combat_logs", "combats"
  add_foreign_key "combat_logs", "enemies"
  add_foreign_key "combat_participants", "combats"
  add_foreign_key "combats", "enemies"
  add_foreign_key "enemies", "rooms"
  add_foreign_key "equipments", "inventories"
  add_foreign_key "inventories", "characters"
  add_foreign_key "items", "inventories"
  add_foreign_key "items", "rooms"
  add_foreign_key "npcs", "rooms"
end
