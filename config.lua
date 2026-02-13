Config = {}

-- Aposta
Config.MinBet = 1000
Config.MaxBet = 50000
Config.RequireSameBet = true

-- Itens
Config.MoneyItem  = "dollar"
Config.TicketItem = "raceticket"

-- Checkpoints
Config.CheckpointRadius = 7.0

-- Regras: saiu do carro / não é motorista => perde NA HORA
Config.RequireVehicle = true
Config.RequireDriver  = true
Config.InstantForfeitOnLeave = true

-- Visual: fumaça dupla
Config.Smoke = {
  asset = "core",
  fx = "exp_grd_grenade_smoke",
  scale = 1.2,
  zOffset = 0.2
}

-- Fila / anti-spam
Config.QueueExpire = 60          -- expira a “procura oponente”
Config.MaxQueuePerRace = 20      -- máximo na fila por círculo
Config.CommandCooldown = 2       -- segundos (anti spam)

-- ✅ Corridas fixas: CADA ITEM = UM CÍRCULO = UMA CORRIDA
-- Dica: duplique e ajuste circle + checkpoints. Coloque 10 no total.
Config.Races = {
  {
    id = "c1",
    name = "Racha 01",
    circle = { center = vec3(512.72, -641.24, 24.15), radius = 35.0 },
    checkpoints = {
      { left = vec3(498.41,-724.38,24.25),  center = vec3(506.0,-724.45,24.29),  right = vec3(513.6,-724.51,24.33) },
      { left = vec3(482.24,-817.27,24.99),  center = vec3(481.97,-824.87,24.97), right = vec3(481.7,-832.46,24.96) },
      { left = vec3(398.70,-835.81,28.80),  center = vec3(406.25,-836.73,28.72), right = vec3(413.79,-837.65,28.64) }
    }
  },

  -- EXEMPLOS VAZIOS (preencha circle+checkpoints). Deixe 10 no total.
  { id="c2", name="Racha 02", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c3", name="Racha 03", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c4", name="Racha 04", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c5", name="Racha 05", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c6", name="Racha 06", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c7", name="Racha 07", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c8", name="Racha 08", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c9", name="Racha 09", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} },
  { id="c10",name="Racha 10", circle={ center=vec3(0.0,0.0,0.0), radius=30.0 }, checkpoints={} }
}
