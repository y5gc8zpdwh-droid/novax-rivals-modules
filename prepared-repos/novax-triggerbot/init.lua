local Module = {
  Name = "novax.triggerbot",
  Kind = "feature",
  Path = "novax-triggerbot/init.lua",
  Category = "combat",
  RuntimeLoop = "combat.trigger",
  StateKeys = { "TriggerEnabled", "TriggerDelay", "TriggerCPS", "TriggerTeamCheck", "TriggerVisibleCheck" },
}

local started = false
local nextShotAt = 0
local delayedShotAt = 0
local rayParams = RaycastParams.new()
local lastParamChar = nil

rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function reset()
  nextShotAt = 0
  delayedShotAt = 0
end

local function updateRayParams(runtime)
  local char = runtime.GetChar and runtime.GetChar()
  if char == lastParamChar then
    return
  end

  local exclude = { workspace.Terrain }
  if char then
    exclude[#exclude + 1] = char
  end
  rayParams.FilterDescendantsInstances = exclude
  lastParamChar = char
end

local function getPlayerFromPart(runtime, part)
  local players = runtime.Services and runtime.Services.Players
  if not players then
    return nil
  end

  local current = part
  while current do
    if current:IsA("Model") then
      local player = players:GetPlayerFromCharacter(current)
      if player then
        return player
      end
    end
    current = current.Parent
  end
  return nil
end

local function isHitAllowed(runtime, state, player, hitPart)
  if not player or not hitPart or not player.Character then
    return false
  end
  if not hitPart:IsA("BasePart") or not hitPart:IsDescendantOf(player.Character) then
    return false
  end
  return runtime.IsEnemy(player, state.TriggerTeamCheck == true) and runtime.IsAlive(player)
end

local function checkCenter(runtime, state)
  local camera = runtime.GetCamera()
  if not camera then
    return false
  end

  updateRayParams(runtime)
  local requireVisible = state.TriggerVisibleCheck ~= false
  if requireVisible then
    runtime.ResetVisibilityCache()
  end

  local center = runtime.GetAimScreenCenter(true)
  local ray = camera:ViewportPointToRay(center.X, center.Y)
  local result = workspace:Raycast(ray.Origin, ray.Direction * 1200, rayParams)
  if result and result.Instance then
    local player = getPlayerFromPart(runtime, result.Instance)
    if isHitAllowed(runtime, state, player, result.Instance) then
      return true
    end
  end

  return false
end

local function runFrame(runtime, state)
  if not runtime.IsRunning() or state.TriggerEnabled ~= true then
    reset()
    return
  end

  if not runtime.IsCombatFeatureAllowed("TriggerBot") then
    reset()
    return
  end

  if runtime.IsNovaXGuiHoverBlocking() then
    runtime.PauseCombatForGuiHover()
    reset()
    return
  end

  state.TriggerVisibleCheck = true
  local now = tick()
  if checkCenter(runtime, state) ~= true then
    delayedShotAt = 0
    return
  end

  local delayMs = math.max(0, runtime.SafeNum(state.TriggerDelay))
  if delayMs > 0 then
    if delayedShotAt == 0 then
      delayedShotAt = now + (delayMs / 1000)
      return
    end
    if now < delayedShotAt then
      return
    end
  else
    delayedShotAt = 0
  end

  if now >= nextShotAt then
    local cps = math.min(runtime.MaxTriggerCPS or 500, math.max(1, runtime.SafeNum(state.TriggerCPS)))
    local interval = 1 / cps
    if runtime.Click(interval) then
      nextShotAt = math.max(now, nextShotAt) + interval
    else
      nextShotAt = now + 0.02
    end
  end
end

function Module.Start(ctx)
  local runtime = ctx and ctx.Runtime
  if type(runtime) ~= "table" then
    error(Module.Name .. ": missing runtime")
  end
  if started then
    return true
  end
  started = true

  local state = runtime.State
  if not state or type(runtime.AddRenderStep) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, reset)
  end

  runtime.AddRenderStep(Module.RuntimeLoop, Enum.RenderPriority.Last.Value + 2, function()
    runFrame(runtime, state)
  end)

  return true
end

return Module
