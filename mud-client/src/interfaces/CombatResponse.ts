// src/interfaces/CombatResponse.ts
export interface CombatResponse {
    message: string;
    combat: {
      id: number;
      enemy_id: number;
      status: string;
      created_at: string;
      updated_at: string;
    };
    combat_logs: CombatLog[];
  }
  
  export interface CombatLog {
    id: number;
    combat_id: number;
    character_id: number | null;
    enemy_id: number | null;
    log_entry: string;
    created_at: string;
  }
  