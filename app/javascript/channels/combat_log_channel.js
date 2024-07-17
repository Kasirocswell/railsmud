import consumer from "./consumer"

const characterId = document.getElementById("character-id").value;

consumer.subscriptions.create({ channel: "CombatLogChannel", character_id: characterId }, {
  received(data) {
    console.log("Received combat log:", data)
    const combatLogsContainer = document.getElementById("combat-logs-container");
    const newLogEntry = document.createElement("div");
    newLogEntry.textContent = data.log_entry;
    combatLogsContainer.appendChild(newLogEntry);
  }
})

