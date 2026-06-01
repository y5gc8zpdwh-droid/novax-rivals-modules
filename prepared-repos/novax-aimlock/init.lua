local Module = {
  Name = "novax.aimlock",
  Kind = "feature",
  Path = "novax-aimlock/init.lua",
  Category = "combat",
  RuntimeLoop = "combat.aimlock",
  StateKeys = { "AimLock", "AimLockStrength", "AimLockFOV", "AimLockMaxDist", "AimLockRequireRMB", "AimLockVisibleCheck" },
}

local started = false
local runtime
local state
local targetPlayer
local targetPart
local lastLockPos

local function safeNum(v)
  if runtime and type(runtime.SafeNum) == "function" then
    return runtime.SafeNum(v)
  end
  return tonumber(v) or 0
end

local function resetAimLockRuntime()
  targetPlayer = nil
  targetPart = nil
  lastLockPos = nil
end

local function getHeadPoint(player)
  local char = player and player.Character
  if not char then
    return nil, nil
  end
  local head = char:FindFirstChild("Head")
  if not head or not head:IsA("BasePart") then
    return nil, nil
  end
  return head, head.Position
end

local function isTargetValid(player, retain, aimCenter)
  local camera = runtime and runtime.GetCamera and runtime.GetCamera()
  local localPlayer = runtime and runtime.GetLocalPlayer and runtime.GetLocalPlayer()
  if not player or player == localPlayer or not camera then
    return false, nil, nil
  end
  if not runtime.IsAlive(player) or not runtime.IsEnemy(player, state.AimTeamCheck) then
    return false, nil, nil
  end

  local head, headPos = getHeadPoint(player)
  if not head or not headPos then
    return false, nil, nil
  end

  local myRoot = runtime.GetRoot()
  local maxDist = math.max(50, safeNum(state.AimLockMaxDist))
  if myRoot and (headPos - myRoot.Position).Magnitude > maxDist * (retain and 1.18 or 1) then
    return false, nil, nil
  end

  local lookDir = headPos - camera.CFrame.Position
  if lookDir.Magnitude < 0.001 or camera.CFrame.LookVector:Dot(lookDir.Unit) < 0.18 then
    return false, nil, nil
  end

  local sp, onScreen = runtime.WorldToScreen(headPos)
  if not onScreen then
    return false, nil, nil
  end

  local center = aimCenter or runtime.GetAimScreenCenter()
  local fov = math.max(20, safeNum(state.AimLockFOV))
  if (sp - center).Magnitude > fov * (retain and 1.28 or 1) then
    return false, nil, nil
  end

  if state.AimLockVisibleCheck == true and not runtime.IsVisibleCached(head) then
    return false, nil, nil
  end

  return true, head, headPos
end

local function findTarget(aimCenter)
  if state.AimLockVisibleCheck == true then
    runtime.ResetVisibilityCache()
  end

  local players = runtime.UpdateCache()
  local center = aimCenter or runtime.GetAimScreenCenter()
  local myRoot = runtime.GetRoot()
  local maxDist = math.max(50, safeNum(state.AimLockMaxDist))
  local fov = math.max(20, safeNum(state.AimLockFOV))
  local bestPlayer, bestPart, bestPos, bestScore = nil, nil, nil, math.huge

  for _, player in ipairs(players or {}) do
    local ok, head, headPos = isTargetValid(player, false, center)
    if ok and head and headPos then
      local sp = runtime.WorldToScreen(headPos)
      local screenDist = (sp - center).Magnitude
      local worldDist = myRoot and (headPos - myRoot.Position).Magnitude or 0
      local score = screenDist + (worldDist / math.max(1, maxDist)) * math.min(fov * 0.18, 28)
      if score < bestScore then
        bestPlayer, bestPart, bestPos, bestScore = player, head, headPos, score
      end
    end
  end

  return bestPlayer, bestPart, bestPos
end

local function stepAimLock(headPos)
  local camera = runtime and runtime.GetCamera and runtime.GetCamera()
  if not camera or typeof(headPos) ~= "Vector3" then
    return false
  end

  local origin = camera.CFrame.Position
  local dir = headPos - origin
  if dir.Magnitude < 0.001 then
    return false
  end

  local strength = math.clamp(safeNum(state.AimLockStrength), 1, 100)
  local alpha = strength >= 98 and 1 or math.clamp((strength / 100) ^ 0.42, 0.18, 0.96)
  local lockPos = headPos

  if lastLockPos then
    local jump = (headPos - lastLockPos).Magnitude
    if jump > 0.001 and jump < 8 and alpha < 1 then
      lockPos = lastLockPos:Lerp(headPos, math.clamp(alpha + 0.22, 0.35, 1))
    end
  end

  lastLockPos = lockPos
  local targetCF = CFrame.new(origin, lockPos)
  if alpha >= 0.995 then
    camera.CFrame = targetCF
  else
    camera.CFrame = camera.CFrame:Lerp(targetCF, alpha)
  end

  return true
end

local function runFrame()
  local camera = runtime.GetCamera()
  if not runtime.IsRunning() or not camera then
    resetAimLockRuntime()
    return
  end

  if state.AimLock ~= true or not runtime.IsCombatFeatureAllowed("AimLock") then
    resetAimLockRuntime()
    return
  end

  if runtime.IsNovaXGuiHoverBlocking() then
    resetAimLockRuntime()
    return
  end

  local input = runtime.Services and runtime.Services.UserInputService
  if state.AimLockRequireRMB == true and input and not input:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    resetAimLockRuntime()
    return
  end

  if not runtime.IsAimCenterGateOpen() then
    resetAimLockRuntime()
    return
  end

  local aimCenter = runtime.GetAimScreenCenter()
  local ok, part, headPos = isTargetValid(targetPlayer, true, aimCenter)
  if not ok then
    targetPlayer, targetPart = findTarget(aimCenter)
    part = targetPart
    if targetPlayer then
      local valid
      valid, part, headPos = isTargetValid(targetPlayer, false, aimCenter)
      if not valid then
        resetAimLockRuntime()
        return
      end
      targetPart = part
    end
  end

  if not targetPlayer or not part or not headPos then
    resetAimLockRuntime()
    return
  end

  targetPart = part
  stepAimLock(headPos)
end

function Module.Start(ctx)
  runtime = ctx and ctx.Runtime
  if type(runtime) ~= "table" then
    error(Module.Name .. ": missing runtime")
  end
  if type(runtime.AddRenderStep) ~= "function" then
    error(Module.Name .. ": missing runtime entry AddRenderStep")
  end

  state = runtime.State
  if type(state) ~= "table" then
    error(Module.Name .. ": missing runtime state")
  end

  if started then
    return true
  end
  started = true
  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, resetAimLockRuntime)
  end
  runtime.AddRenderStep("combat.aimlock", Enum.RenderPriority.Camera.Value + 2, runFrame)
  return true
end

return Module
