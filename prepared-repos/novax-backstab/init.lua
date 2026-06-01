local Module = {
  Name = "novax.backstab",
  Kind = "feature",
  Path = "novax-backstab/init.lua",
  Category = "misc",
  RuntimeLoop = "utility.backstab",
  StateKeys = { "AutoBackstab", "AutoBackstabInterval", "AutoBackstabRandomize", "AutoBackstabRandomMin", "AutoBackstabRandomMax" },
}

local started = false
local busy = false
local nextBackstabAt = 0

local function notify(runtime, title, text, duration)
  if runtime and type(runtime.Notify) == "function" then
    runtime.Notify(title, text, duration)
  end
end

local function getPlayerRoot(player)
  local char = player and player.Character
  if not char then
    return nil
  end
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function getPlayerHumanoid(player)
  local char = player and player.Character
  return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function findPlayerByName(runtime, name)
  if not runtime or not runtime.Services then
    return nil
  end
  if not name or name == "" or name == "None" then
    return nil
  end

  local raw = tostring(name)
  local extractedUser = raw:match("@([%w_]+)")
  local needle = string.lower(extractedUser or raw)
  local players = runtime.Services.Players
  local localPlayer = runtime.GetLocalPlayer and runtime.GetLocalPlayer() or nil

  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
      local userName = string.lower(tostring(player.Name or ""))
      local displayName = string.lower(tostring(player.DisplayName or ""))
      if userName == needle or displayName == needle then
        return player
      end
    end
  end

  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
      local userName = string.lower(tostring(player.Name or ""))
      local displayName = string.lower(tostring(player.DisplayName or ""))
      if userName:find(needle, 1, true) or displayName:find(needle, 1, true) then
        return player
      end
    end
  end

  return nil
end

local function getNearestEnemyPlayer(runtime, state)
  local root = runtime.GetRoot and runtime.GetRoot() or nil
  local players = runtime.Services and runtime.Services.Players
  if not root or not players then
    return nil
  end

  local localPlayer = runtime.GetLocalPlayer and runtime.GetLocalPlayer() or nil
  local nearest, nearestDist = nil, math.huge
  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer and runtime.IsAlive(player) and runtime.IsEnemy(player, state.AimTeamCheck) then
      local targetRoot = getPlayerRoot(player)
      if targetRoot then
        local dist = (root.Position - targetRoot.Position).Magnitude
        if dist < nearestDist then
          nearest = player
          nearestDist = dist
        end
      end
    end
  end
  return nearest
end

local function getTargetPlayer(runtime, state)
  local selected = findPlayerByName(runtime, state.TPPlayer)
  local localPlayer = runtime.GetLocalPlayer and runtime.GetLocalPlayer() or nil
  if selected and selected ~= localPlayer and runtime.IsAlive(selected) and runtime.IsEnemy(selected, state.AimTeamCheck) then
    return selected
  end
  return getNearestEnemyPlayer(runtime, state)
end

local function hasSpawnProtection(player)
  local char = player and player.Character
  if not char then
    return false
  end
  if char:FindFirstChildOfClass("ForceField") then
    return true
  end

  for _, obj in ipairs(char:GetDescendants()) do
    if obj:IsA("ForceField") then
      return true
    end
    local name = string.lower(tostring(obj.Name or ""))
    local protectedName = name:find("spawn", 1, true) or name:find("bubble", 1, true) or name:find("shield", 1, true) or name:find("protect", 1, true)
    if protectedName and (obj:IsA("BasePart") or obj:IsA("Highlight") or obj:IsA("SelectionBox") or obj:IsA("BillboardGui")) then
      return true
    end
  end

  return false
end

local function waitForSpawnProtectionGone(runtime, state, player, maxWait, requireAuto)
  local deadline = tick() + math.clamp(runtime.SafeNum(maxWait), 0.5, 10)
  while runtime.IsRunning() and (requireAuto ~= true or state.AutoBackstab) and runtime.IsAlive(player) and hasSpawnProtection(player) do
    if tick() >= deadline then
      return false
    end
    task.wait(0.08)
  end

  return (requireAuto ~= true or state.AutoBackstab) and runtime.IsAlive(player) and not hasSpawnProtection(player)
end

local function getBackAimPosition(targetRoot)
  if not targetRoot then
    return nil
  end
  return targetRoot.Position - (targetRoot.CFrame.LookVector * 0.9) + Vector3.new(0, 0.75, 0)
end

local function aimAtTargetBack(runtime, state, targetRoot)
  local myRoot = runtime.GetRoot and runtime.GetRoot() or nil
  local camera = runtime.GetCamera and runtime.GetCamera() or nil
  local aimPos = getBackAimPosition(targetRoot)
  if not myRoot or not targetRoot or not aimPos then
    return false
  end

  local behindDist = math.max(2, runtime.SafeNum(state.TPDistance))
  local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * behindDist
  myRoot.CFrame = CFrame.new(behindPos, aimPos)
  if camera then
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, aimPos)
  end
  return true
end

local function restoreOrigin(runtime, originCF, originCameraCF)
  local myRoot = runtime.GetRoot and runtime.GetRoot() or nil
  local camera = runtime.GetCamera and runtime.GetCamera() or nil
  if myRoot and originCF then
    myRoot.CFrame = originCF
  end
  if camera and originCameraCF then
    camera.CFrame = originCameraCF
  end
end

local function getInterval(runtime, state)
  local interval = math.max(0.08, runtime.SafeNum(state.AutoBackstabInterval) / 1000)
  if state.AutoBackstabRandomize then
    local minMs = math.max(50, math.min(runtime.SafeNum(state.AutoBackstabRandomMin), runtime.SafeNum(state.AutoBackstabRandomMax)))
    local maxMs = math.max(minMs, runtime.SafeNum(state.AutoBackstabRandomMax))
    interval = math.random(math.floor(minMs), math.floor(maxMs)) / 1000
  end
  return interval
end

local function doBackstab(runtime, state, targetPlayer)
  local targetRoot = getPlayerRoot(targetPlayer)
  local myRoot = runtime.GetRoot and runtime.GetRoot() or nil
  if not targetRoot or not myRoot then
    return false, 0, "missing_root"
  end
  if hasSpawnProtection(targetPlayer) then
    return false, 0, "protected"
  end

  local camera = runtime.GetCamera and runtime.GetCamera() or nil
  local originCF = myRoot.CFrame
  local originCameraCF = camera and camera.CFrame or nil
  local hum = getPlayerHumanoid(targetPlayer)
  local startHealth = hum and hum.Health or 0
  local hit, damage = false, 0

  if aimAtTargetBack(runtime, state, targetRoot) then
    task.wait(0.012)
    runtime.RightClick()
    task.wait(0.018)
    runtime.Click(0.035)

    local deadline = tick() + 0.42
    while runtime.IsRunning() and targetRoot.Parent and tick() < deadline do
      aimAtTargetBack(runtime, state, targetRoot)
      hum = getPlayerHumanoid(targetPlayer)
      if not hum or hum.Health <= 0 then
        hit = true
        damage = math.max(damage, startHealth)
        break
      end
      damage = math.max(damage, startHealth - hum.Health)
      if damage >= 50 then
        hit = true
        break
      end
      task.wait(0.018)
    end
  end

  restoreOrigin(runtime, originCF, originCameraCF)
  return hit, damage
end

local function backstabOnce(runtime, state)
  if not runtime.IsCombatFeatureAllowed("AutoBackstab") then
    notify(runtime, "Backstab", "Warte bis die Runde gestartet ist", 2)
    return false
  end

  local target = getTargetPlayer(runtime, state)
  if not target then
    notify(runtime, "Backstab", "Kein gueltiges Ziel", 2)
    return false
  end

  task.spawn(function()
    if waitForSpawnProtectionGone(runtime, state, target, 6, false) then
      doBackstab(runtime, state, target)
    end
  end)
  return true
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
  if not state then
    error(Module.Name .. ": missing runtime state")
  end

  if type(runtime.RegisterBackstabApi) == "function" then
    runtime.RegisterBackstabApi({
      BackstabOnce = function()
        return backstabOnce(runtime, state)
      end,
    })
  end

  runtime.AddCleanup(Module.RuntimeLoop, function()
    busy = false
    nextBackstabAt = 0
    started = false
    if type(runtime.RegisterBackstabApi) == "function" then
      runtime.RegisterBackstabApi(nil)
    end
  end)

  task.spawn(function()
    while runtime.IsRunning() do
      local sleepFor = 0.04
      if state.AutoBackstab and runtime.IsCombatFeatureAllowed("AutoBackstab") and not busy and tick() >= nextBackstabAt then
        local target = getTargetPlayer(runtime, state)
        if target then
          if hasSpawnProtection(target) then
            waitForSpawnProtectionGone(runtime, state, target, 6, true)
          else
            busy = true
            doBackstab(runtime, state, target)
            nextBackstabAt = tick() + getInterval(runtime, state)
            busy = false
          end
        else
          sleepFor = 0.12
        end
      elseif not state.AutoBackstab or not runtime.IsCombatFeatureAllowed("AutoBackstab") then
        nextBackstabAt = 0
        sleepFor = 0.18
      end
      task.wait(sleepFor)
    end
  end)

  return true
end

return Module
