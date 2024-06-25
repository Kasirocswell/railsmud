App.game = App.cable.subscriptions.create("GameChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    console.log(data.message);
    // Update the UI based on the data received
  },

  move: function(character_id, direction) {
    this.perform('move', { character_id: character_id, direction: direction });
  },

  attack: function(character_id, enemy_id) {
    this.perform('attack', { character_id: character_id, enemy_id: enemy_id });
  },

  use_ability: function(character_id, ability_id, target_id, enemy_id) {
    this.perform('use_ability', { character_id: character_id, ability_id: ability_id, target_id: target_id, enemy_id: enemy_id });
  }
});
