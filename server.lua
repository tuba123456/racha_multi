local Tunnel = module("vrp","lib/Tunnel")
local Proxy  = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local cRacha = Tunnel.getInterface("racha_multi")

-- Estado
local Queue = {}      -- Queue[raceIndex][passport] = { amount, time }
local ActiveBy = {}   -- ActiveBy[passport] = matchId
local Matches = {}    -- Matches[matchId] = { raceIndex, p1, p2, amount, pot, cp, active=true }
local LastCmd = {}    -- anti-spam

local function now() return os.time() end

local function notify(src, color, msg, t)
  TriggerClientEvent("Notify", src, color, msg, t or 8000)
end

local function dist(a,b)
  local dx=a.x-b.x; local dy=a.y-b.y; local dz=a.z-b.z
  return math.sqrt(dx*dx+dy*dy+dz*dz)
end

local function getCoords(source)
  return cRacha.GetCoords(source) -- {x,y,z}
end

local function findRaceIndexByCoord(c)
  if not c then return nil end
  for i, def in ipairs(Config.Races) do
    local z = def.circle
    if z and z.center and z.radius then
      local cc = { x = z.center.x, y = z.center.y, z = z.center.z }
      if dist(c, cc) <= z.radius then
        return i
      end
    end
  end
  return nil
end

local function hasItem(passport, item, amount)
  return (vRP.InventoryItemAmount(passport, item) or 0) >= (amount or 1)
end

local function takeItem(passport, item, amount)
  return vRP.TakeItem(passport, item, amount or 1, true)
end

local function giveItem(passport, item, amount)
  return vRP.GenerateItem(passport, item, amount or 1, true)
end

local function cleanupQueue()
  local t = now()
  for raceIndex, q in pairs(Queue) do
    for p, data in pairs(q) do
      if not data or (t - (data.time or t)) > (Config.QueueExpire or 60) then
        q[p] = nil
      end
    end
  end
end

local function queueCount(raceIndex)
  local c = 0
  if Queue[raceIndex] then
    for _ in pairs(Queue[raceIndex]) do c = c + 1 end
  end
  return c
end

local function stopMatchForBoth(matchId)
  local m = Matches[matchId]
  if not m then return end
  local s1 = vRP.Source(m.p1)
  local s2 = vRP.Source(m.p2)
  if s1 then TriggerClientEvent("racha_multi:Stop", s1, matchId) end
  if s2 then TriggerClientEvent("racha_multi:Stop", s2, matchId) end
end

local function finishMatch(matchId, winnerPassport, reason)
  local m = Matches[matchId]
  if not m or not m.active then return end
  m.active = false

  local loserPassport = (winnerPassport == m.p1) and m.p2 or m.p1
  local pot = m.pot

  giveItem(winnerPassport, Config.MoneyItem, pot)

  local sW = vRP.Source(winnerPassport)
  local sL = vRP.Source(loserPassport)

  if sW then notify(sW, "verde", ("[RACHA] Você venceu! Ganhou $%d. (%s)"):format(pot, reason or "finalizou"), 12000) end
  if sL then notify(sL, "vermelho", ("[RACHA] Você perdeu. Vencedor %d | Pote $%d. (%s)"):format(winnerPassport, pot, reason or "finalizou"), 12000) end

  stopMatchForBoth(matchId)

  ActiveBy[m.p1] = nil
  ActiveBy[m.p2] = nil
  Matches[matchId] = nil
end

local function startMatch(raceIndex, p1, p2, amount)
  local def = Config.Races[raceIndex]
  local s1 = vRP.Source(p1)
  local s2 = vRP.Source(p2)
  if not s1 or not s2 then return end

  -- Ainda no círculo?
  local c1 = getCoords(s1)
  local c2 = getCoords(s2)
  if findRaceIndexByCoord(c1) ~= raceIndex or findRaceIndexByCoord(c2) ~= raceIndex then
    notify(s1, "vermelho", "[RACHA] Um dos jogadores saiu do círculo. Tenta de novo.", 10000)
    notify(s2, "vermelho", "[RACHA] Um dos jogadores saiu do círculo. Tenta de novo.", 10000)
    return
  end

  -- Requisitos: $ e ticket
  if not hasItem(p1, Config.MoneyItem, amount) or not hasItem(p2, Config.MoneyItem, amount) then
    notify(s1, "vermelho", "[RACHA] Um dos jogadores não tem $ suficiente.", 10000)
    notify(s2, "vermelho", "[RACHA] Um dos jogadores não tem $ suficiente.", 10000)
    return
  end

  if not hasItem(p1, Config.TicketItem, 1) or not hasItem(p2, Config.TicketItem, 1) then
    notify(s1, "vermelho", "[RACHA] Um dos jogadores não tem Ticket de Corrida.", 10000)
    notify(s2, "vermelho", "[RACHA] Um dos jogadores não tem Ticket de Corrida.", 10000)
    return
  end

  if ActiveBy[p1] or ActiveBy[p2] then
    notify(s1, "vermelho", "[RACHA] Um dos jogadores já está em outra corrida.", 8000)
    notify(s2, "vermelho", "[RACHA] Um dos jogadores já está em outra corrida.", 8000)
    return
  end

  -- Desconta $ (escrow)
  if not takeItem(p1, Config.MoneyItem, amount) then return end
  if not takeItem(p2, Config.MoneyItem, amount) then
    giveItem(p1, Config.MoneyItem, amount)
    return
  end

  -- Consome ticket (1 por player)
  takeItem(p1, Config.TicketItem, 1)
  takeItem(p2, Config.TicketItem, 1)

  local matchId = ("%s_%d_%d_%d"):format(def.id or tostring(raceIndex), p1, p2, now())
  Matches[matchId] = {
    raceIndex = raceIndex,
    p1 = p1,
    p2 = p2,
    amount = amount,
    pot = amount * 2,
    cp = { [p1] = 1, [p2] = 1 },
    active = true
  }
  ActiveBy[p1] = matchId
  ActiveBy[p2] = matchId

  notify(s1, "verde", ("[RACHA] Match em %s! Valendo $%d (pote $%d)."):format(def.name, amount, amount*2), 12000)
  notify(s2, "verde", ("[RACHA] Match em %s! Valendo $%d (pote $%d)."):format(def.name, amount, amount*2), 12000)

  TriggerClientEvent("racha_multi:Start", s1, matchId, raceIndex, Config)
  TriggerClientEvent("racha_multi:Start", s2, matchId, raceIndex, Config)
end

-- Player: correr [valor]
RegisterCommand("correr", function(source, args)
  local p = vRP.Passport(source)
  if not p then return end

  cleanupQueue()

  -- anti-spam
  local t = now()
  if LastCmd[p] and (t - LastCmd[p]) < (Config.CommandCooldown or 2) then
    notify(source, "amarelo", "[RACHA] Calma aí… tenta de novo em 2s.", 4000)
    return
  end
  LastCmd[p] = t

  if ActiveBy[p] then
    notify(source, "vermelho", "[RACHA] Você já está em uma corrida.", 8000)
    return
  end

  local amount = math.floor(tonumber(args[1] or "0") or 0)
  if amount < Config.MinBet or amount > Config.MaxBet then
    notify(source, "vermelho", ("[RACHA] Valor inválido. Min $%d | Max $%d"):format(Config.MinBet, Config.MaxBet), 12000)
    return
  end

  local coords = getCoords(source)
  local raceIndex = findRaceIndexByCoord(coords)
  if not raceIndex then
    notify(source, "vermelho", "[RACHA] Entre em um círculo de racha para usar 'correr'.", 10000)
    return
  end

  local def = Config.Races[raceIndex]
  if not def.checkpoints or #def.checkpoints < 2 then
    notify(source, "vermelho", "[RACHA] Essa corrida não tem checkpoints suficientes no config.", 10000)
    return
  end

  Queue[raceIndex] = Queue[raceIndex] or {}

  -- limite fila
  if queueCount(raceIndex) >= (Config.MaxQueuePerRace or 20) and not Queue[raceIndex][p] then
    notify(source, "vermelho", "[RACHA] Esse círculo está lotado. Tenta outro.", 9000)
    return
  end

  Queue[raceIndex][p] = { amount = amount, time = now() }

  -- procurar oponente na mesma corrida/círculo
  local opponent = nil
  for op, data in pairs(Queue[raceIndex]) do
    if op ~= p and not ActiveBy[op] then
      local opSrc = vRP.Source(op)
      if opSrc then
        local opCoords = getCoords(opSrc)
        if findRaceIndexByCoord(opCoords) == raceIndex then
          if (not Config.RequireSameBet) or (data.amount == amount) then
            opponent = op
            break
          end
        end
      end
    end
  end

  if not opponent then
    notify(source, "amarelo", ("[RACHA] Aguardando oponente em %s... (Aposta $%d)"):format(def.name, amount), 10000)
    return
  end

  -- remove da fila os 2
  Queue[raceIndex][p] = nil
  Queue[raceIndex][opponent] = nil

  startMatch(raceIndex, p, opponent, amount)
end)

-- Passou checkpoint correto
RegisterNetEvent("racha_multi:Passed")
AddEventHandler("racha_multi:Passed", function(matchId, checkpointIndex)
  local source = source
  local p = vRP.Passport(source)
  if not p then return end

  local m = Matches[matchId]
  if not m or not m.active then return end
  if p ~= m.p1 and p ~= m.p2 then return end

  local expected = m.cp[p]
  if checkpointIndex ~= expected then return end

  m.cp[p] = expected + 1

  local total = #Config.Races[m.raceIndex].checkpoints
  if expected >= total then
    finishMatch(matchId, p, "completou a rota")
  end
end)

-- Desclassificação instantânea
RegisterNetEvent("racha_multi:Forfeit")
AddEventHandler("racha_multi:Forfeit", function(matchId, reason)
  local source = source
  local p = vRP.Passport(source)
  if not p then return end

  local m = Matches[matchId]
  if not m or not m.active then return end
  if p ~= m.p1 and p ~= m.p2 then return end
  if ActiveBy[p] ~= matchId then return end

  local winner = (p == m.p1) and m.p2 or m.p1
  finishMatch(matchId, winner, reason or "desclassificado")
end)

-- Desconectou => perde
AddEventHandler("Disconnect", function(Passport)
  if Passport and ActiveBy[Passport] then
    local matchId = ActiveBy[Passport]
    local m = Matches[matchId]
    if m and m.active then
      local winner = (Passport == m.p1) and m.p2 or m.p1
      finishMatch(matchId, winner, "desconectou")
    end
  end
end)
