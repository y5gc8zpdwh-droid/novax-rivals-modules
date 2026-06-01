local Module = {
  Name = "novax.names_orbit",
  Kind = "feature",
  Path = "novax-names-orbit/init.lua",
  Category = "misc",
  RuntimeLoop = "utility.namesorbit",
  StateKeys = { "NamesOrbit", "NamesOrbitInterval" },
}

local started = false
local busy = false
local nextShotAt = 0

local function getPlayerRoot(player)
  local char = player and player.Character
  if not char then
    return nil
  end
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function getPlayerPart(player, partName)
  local char = player and player.Character
  if not char then
    return nil
  end
  local wanted = char:FindFirstChild(tostring(partName or "Head"))
  if wanted and wanted:IsA("BasePart") then
    return wanted
  end
  return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
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

local function waitForSpawnProtectionGone(runtime, player, maxWait)
  local deadline = tick() + math.clamp(runtime.SafeNum(maxWait), 0.5, 10)
  while runtime.IsRunning() and runtime.IsAlive(player) and hasSpawnProtection(player) do
    if tick() >= deadline then
      return false
    end
    task.wait(0.08)
  end
  return runtime.IsAlive(player) and not hasSpawnProtection(player)
end

local function getRandomizedReturnCFrame(originCF, lookAtPos, radius)
  if not originCF then
    return nil
  end

  local basePos = originCF.Position
  local r = math.max(2, tonumber(radius) or 6)
  local theta = math.rad(math.random(0, 359))
  local dist = math.random(math.floor(r * 55), math.floor(r * 100)) / 100
  local offset = Vector3.new(math.cos(theta) * dist, 0, math.sin(theta) * dist)
  local pos = basePos + offset
  if lookAtPos then
    return CFrame.new(pos, lookAtPos)
  end
  return CFrame.new(pos) * (originCF - originCF.Position)
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
  return math.max(0.08, runtime.SafeNum(state.NamesOrbitInterval) / 1000)
end

local function doNamesOrbitShot(runtime, targetPlayer)
  local targetRoot = getPlayerRoot(targetPlayer)
  local myRoot = runtime.GetRoot and runtime.GetRoot() or nil
  if not targetRoot or not myRoot then
    return false, "missing_root"
  end
  if hasSpawnProtection(targetPlayer) then
    return false, "protected"
  end

  local head = getPlayerPart(targetPlayer, "Head") or targetRoot
  if not head or not head.Parent then
    return false, "missing_head"
  end

  local camera = runtime.GetCamera and runtime.GetCamera() or nil
  local originCF = myRoot.CFrame
  local originCameraCF = camera and camera.CFrame or nil
  local returnCF = getRandomizedReturnCFrame(originCF, head.Position, 7)
  local ok = false

  local face = targetRoot.CFrame.LookVector
  local insidePos = targetRoot.Position + (face * 0.35) + Vector3.new(0, 0.35, 0)
  myRoot.CFrame = CFrame.new(insidePos, head.Position)
  if camera then
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
  end
  runtime.RightClick()
  task.wait(0.024)
  ok = runtime.Click(0.04) == true
  task.wait(ok and 0.085 or 0.04)

  restoreOrigin(runtime, returnCF or originCF, originCameraCF)
  return ok, ok and "shot" or "no_click"
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

  runtime.AddCleanup(Module.RuntimeLoop, function()
    busy = false
    nextShotAt = 0
    started = false
  end)

  task.spawn(function()
    while runtime.IsRunning() do
      local sleepFor = 0.025
      if state.NamesOrbit and runtime.IsCombatFeatureAllowed("NamesOrbit") and not busy and tick() >= nextShotAt then
        local target = getTargetPlayer(runtime, state)
        if target then
          busy = true
          if hasSpawnProtection(target) then
            waitForSpawnProtectionGone(runtime, target, 4)
          end
          doNamesOrbitShot(runtime, target)
          nextShotAt = tick() + getInterval(runtime, state)
          busy = false
        else
          sleepFor = 0.1
        end
      elseif not state.NamesOrbit or not runtime.IsCombatFeatureAllowed("NamesOrbit") then
        nextShotAt = 0
        sleepFor = 0.18
      end
      task.wait(sleepFor)
    end
  end)

  return true
end

return Module
