local Module = {
  Name = "novax.silentaim",
  Kind = "feature",
  Path = "novax-silentaim/init.lua",
  Category = "combat",
  RuntimeLoop = "combat.silent",
  StateKeys = { "SilentAim", "SilentAimMode", "SilentAimFOVOnly", "SilentAimAutoShoot", "SilentAimAutoShootCPS" },
}

local started = false
local shotBusy = false
local cachedTarget = nil
local cachedAt = 0
local nextAutoShotAt = 0

local function reset()
  shotBusy = false
  cachedTarget = nil
  cachedAt = 0
  nextAutoShotAt = 0
end

local function getTool(runtime)
  local char = runtime.GetChar and runtime.GetChar()
  return char and char:FindFirstChildOfClass("Tool") or nil
end

local function getHead(player)
  local char = player and player.Character
  local head = char and char:FindFirstChild("Head")
  return head and head:IsA("BasePart") and head or nil
end

local function isTargetAlive(runtime, targetPart)
  if not targetPart or not targetPart.Parent then
    return false
  end
  local players = runtime.Services and runtime.Services.Players
  local player = players and players:GetPlayerFromCharacter(targetPart.Parent)
  if not player or not runtime.IsAlive(player) then
    return false
  end
  local hum = targetPart.Parent:FindFirstChildOfClass("Humanoid")
  return hum ~= nil and hum.Health > 0
end

local function isTargetInFOV(runtime, state, targetPart)
  if state.SilentAimFOVOnly ~= true then
    return true, 0
  end

  local camera = runtime.GetCamera()
  if not targetPart or not camera then
    return false, math.huge
  end

  local screenPos, onScreen = runtime.WorldToScreen(targetPart.Position)
  if not onScreen then
    return false, math.huge
  end

  local center = runtime.GetAimScreenCenter()
  local distance = (screenPos - center).Magnitude
  return distance <= runtime.SafeNum(state.AimFOV), distance
end

local function isTargetVisible(runtime, targetPart)
  if not targetPart or not targetPart.Parent then
    return false
  end
  return runtime.IsVisibleCached(targetPart) == true
end

local function getTarget(runtime, state, requireVisible)
  local myRoot = runtime.GetRoot()
  if not myRoot then
    return nil
  end

  local now = tick()
  local playersService = runtime.Services and runtime.Services.Players
  if requireVisible then
    runtime.ResetVisibilityCache()
  end

  if cachedTarget and now - cachedAt <= 0.08 and isTargetAlive(runtime, cachedTarget) then
    local player = playersService and playersService:GetPlayerFromCharacter(cachedTarget.Parent)
    local inFOV = isTargetInFOV(runtime, state, cachedTarget)
    local visible = (not requireVisible) or isTargetVisible(runtime, cachedTarget)
    if player and runtime.IsEnemy(player, state.AimTeamCheck) and inFOV and visible then
      return cachedTarget
    end
  end

  local bestTarget, bestScore = nil, math.huge
  for _, player in ipairs(runtime.UpdateCache() or {}) do
    if player ~= runtime.GetLocalPlayer() and runtime.IsAlive(player) and runtime.IsEnemy(player, state.AimTeamCheck) then
      local head = getHead(player)
      if head and isTargetAlive(runtime, head) then
        local inFOV, screenDistance = isTargetInFOV(runtime, state, head)
        local visible = (not requireVisible) or isTargetVisible(runtime, head)
        if inFOV and visible then
          local worldDistance = (myRoot.Position - head.Position).Magnitude
          local score = state.SilentAimFOVOnly == true and screenDistance or worldDistance
          if score < bestScore then
            bestTarget, bestScore = head, score
          end
        end
      end
    end
  end

  cachedTarget = bestTarget
  cachedAt = now
  return bestTarget
end

local function fireTool(runtime)
  local fired = false
  local tool = getTool(runtime)
  if tool then
    local activateRemote = tool:FindFirstChild("Activate")
    if activateRemote then
      local ok = pcall(function()
        activateRemote:FireServer()
      end)
      fired = fired or ok
    end

    local remote = tool:FindFirstChild("RemoteEvent")
    if remote then
      local ok = pcall(function()
        remote:FireServer()
      end)
      fired = fired or ok
    end

    if not fired then
      local ok = pcall(function()
        tool:Activate()
      end)
      fired = fired or ok
    end
  end

  if not fired then
    fired = runtime.Click(1 / (runtime.MaxTriggerCPS or 500))
  end
  return fired
end

local function silentAimShot(runtime, state, requireVisible)
  if shotBusy or state.SilentAim ~= true then
    return false
  end
  if runtime.IsNovaXGuiHoverBlocking() or not runtime.IsCombatFeatureAllowed("SilentAim") then
    reset()
    return false
  end

  local camera = runtime.GetCamera()
  local target = getTarget(runtime, state, requireVisible)
  if not camera or not target or not isTargetAlive(runtime, target) then
    return false
  end
  if requireVisible and not isTargetVisible(runtime, target) then
    return false
  end

  shotBusy = true
  local oldCF = camera.CFrame
  local ok = pcall(function()
    camera.CFrame = CFrame.new(oldCF.Position, target.Position)
    task.wait(0.005)
    local inFOV = isTargetInFOV(runtime, state, target)
    local visible = (not requireVisible) or isTargetVisible(runtime, target)
    if state.SilentAim and runtime.IsCombatFeatureAllowed("SilentAim") and isTargetAlive(runtime, target) and inFOV and visible then
      fireTool(runtime)
    end
    task.wait(0.005)
  end)
  pcall(function()
    local currentCamera = runtime.GetCamera()
    if currentCamera then
      currentCamera.CFrame = oldCF
    end
  end)
  shotBusy = false
  return ok
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
  local input = runtime.Services and runtime.Services.UserInputService
  if not state or not input or type(runtime.AddConnection) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  if type(runtime.RegisterSilentAimReset) == "function" then
    runtime.RegisterSilentAimReset(reset)
  end

  runtime.AddConnection(
    "combat.silent.click",
    input.InputBegan:Connect(function(keyInput, gameProcessed)
      if gameProcessed then
        return
      end
      if keyInput.UserInputType == Enum.UserInputType.MouseButton1 then
        task.spawn(function()
          silentAimShot(runtime, state, false)
        end)
      end
    end)
  )

  task.spawn(function()
    while runtime.IsRunning() do
      if state.SilentAim and state.SilentAimAutoShoot and runtime.IsCombatFeatureAllowed("SilentAimAutoShoot") then
        local now = tick()
        if now >= nextAutoShotAt then
          local cps = math.min(runtime.MaxTriggerCPS or 500, math.max(1, runtime.SafeNum(state.SilentAimAutoShootCPS)))
          local interval = 1 / cps
          local fired = silentAimShot(runtime, state, true)
          nextAutoShotAt = tick() + (fired and interval or 0.035)
        end
        task.wait(0.01)
      else
        nextAutoShotAt = 0
        task.wait(0.05)
      end
    end
  end)

  return true
end

return Module
