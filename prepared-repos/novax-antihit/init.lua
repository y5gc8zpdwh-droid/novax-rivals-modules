local Module = {
  Name = "novax.antihit",
  Kind = "feature",
  Path = "novax-antihit/init.lua",
  Category = "misc",
  RuntimeLoop = "misc.antihit",
  StateKeys = { "AntiHit", "AntiHitMode", "AntiHitSpeed", "AntiHitExperimental", "AntiHitHitboxMode", "AntiHitHitboxScale" },
}

local started = false
local antiHitPose = { char = nil, neck = nil, waist = nil }
local hitboxOriginal = setmetatable({}, { __mode = "k" })
local lastHitboxAt = 0
local lastHitboxChar = nil
local lastHitboxMode = nil
local lastHitboxScale = nil

local HITBOX_PARTS = {
  Head = true,
  UpperTorso = true,
  LowerTorso = true,
  Torso = true,
  HumanoidRootPart = true,
  ["Left Arm"] = true,
  ["Right Arm"] = true,
  ["Left Leg"] = true,
  ["Right Leg"] = true,
  LeftUpperArm = true,
  LeftLowerArm = true,
  LeftHand = true,
  RightUpperArm = true,
  RightLowerArm = true,
  RightHand = true,
  LeftUpperLeg = true,
  LeftLowerLeg = true,
  LeftFoot = true,
  RightUpperLeg = true,
  RightLowerLeg = true,
  RightFoot = true,
}

local function restorePose()
  pcall(function()
    if antiHitPose.neck and antiHitPose.neck.Parent then
      antiHitPose.neck.Transform = CFrame.new()
    end
    if antiHitPose.waist and antiHitPose.waist.Parent then
      antiHitPose.waist.Transform = CFrame.new()
    end
  end)
  antiHitPose = { char = nil, neck = nil, waist = nil }
end

local function restoreHitbox()
  for part, original in pairs(hitboxOriginal) do
    if part and part.Parent and original then
      pcall(function()
        part.Size = original.Size
        part.CanTouch = original.CanTouch
        part.Massless = original.Massless
      end)
    end
  end
  hitboxOriginal = setmetatable({}, { __mode = "k" })
  lastHitboxAt = 0
  lastHitboxChar = nil
  lastHitboxMode = nil
  lastHitboxScale = nil
end

local function getJoints(runtime)
  local char = runtime.GetChar()
  if not char then
    return nil
  end
  if antiHitPose.char == char then
    return antiHitPose
  end

  restorePose()
  local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
  local head = char:FindFirstChild("Head")
  antiHitPose = { char = char, neck = nil, waist = nil }
  if head then
    antiHitPose.neck = head:FindFirstChild("Neck")
  end
  if not antiHitPose.neck and torso then
    antiHitPose.neck = torso:FindFirstChild("Neck")
  end
  if torso then
    antiHitPose.waist = torso:FindFirstChild("Waist")
  end
  return antiHitPose
end

local function applyHitbox(runtime, state)
  local mode = tostring(state.AntiHitHitboxMode or "Off")
  if mode == "Off" then
    restoreHitbox()
    return
  end

  local char = runtime.GetChar()
  if not char then
    restoreHitbox()
    return
  end

  local scale = math.clamp(runtime.SafeNum(state.AntiHitHitboxScale) / 100, 0.25, 1)
  for _, part in ipairs(char:GetChildren()) do
    if part:IsA("BasePart") and HITBOX_PARTS[part.Name] then
      local original = hitboxOriginal[part]
      if not original then
        original = { Size = part.Size, CanTouch = part.CanTouch, Massless = part.Massless }
        hitboxOriginal[part] = original
      end

      local size = original.Size
      if mode == "Compact Body" then
        size = Vector3.new(math.max(0.35, original.Size.X * scale), math.max(0.35, original.Size.Y * scale), math.max(0.35, original.Size.Z * scale))
      elseif mode == "Flat Body" then
        size = Vector3.new(math.max(0.35, original.Size.X * scale), math.max(0.25, original.Size.Y * scale * 0.45), math.max(0.35, original.Size.Z * scale))
      elseif mode == "Thin Body" then
        size =
          Vector3.new(math.max(0.25, original.Size.X * scale * 0.35), math.max(0.35, original.Size.Y * scale), math.max(0.25, original.Size.Z * scale * 0.35))
      end

      pcall(function()
        part.Size = size
        part.CanTouch = false
        part.Massless = true
      end)
    end
  end
end

local function applyHitboxTracked(runtime, state, now)
  local mode = tostring(state.AntiHitHitboxMode or "Off")
  local char = runtime.GetChar()
  local scale = math.clamp(runtime.SafeNum(state.AntiHitHitboxScale), 25, 100)
  if mode == "Off" or not char then
    restoreHitbox()
    return
  end

  now = now or tick()
  if char ~= lastHitboxChar or mode ~= lastHitboxMode or math.abs(scale - runtime.SafeNum(lastHitboxScale)) >= 0.5 or now - lastHitboxAt > 0.35 then
    lastHitboxChar = char
    lastHitboxMode = mode
    lastHitboxScale = scale
    lastHitboxAt = now
    applyHitbox(runtime, state)
  end
end

local function applyLobbyPose(runtime, state, t, mode)
  local joints = getJoints(runtime)
  if not joints then
    return
  end

  local yaw = math.sin(t * 3.1) * 1.4
  local pitch = math.cos(t * 2.7) * 0.8
  local roll = math.sin(t * 3.5) * 0.9
  if mode == "Head Orbit" or state.AntiHitExperimental then
    yaw = yaw + t * 1.6
    roll = roll + math.cos(t * 5) * 0.55
  elseif mode == "Vector Chaos" then
    yaw = yaw + math.sin(t * 6.2) * 1.2
    pitch = pitch + math.cos(t * 4.9) * 0.8
  end

  if joints.neck and joints.neck:IsA("Motor6D") then
    joints.neck.Transform = CFrame.Angles(pitch, yaw, roll)
  end
  if joints.waist and joints.waist:IsA("Motor6D") then
    joints.waist.Transform = CFrame.Angles(pitch * 0.2, -yaw * 0.25, 0)
  end
end

local function restore(runtime)
  restorePose()
  restoreHitbox()
  local hum = runtime.GetHumanoid()
  if hum then
    hum.AutoRotate = true
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
  local runService = runtime.Services and runtime.Services.RunService
  if not state or not runService or type(runtime.AddConnection) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      restore(runtime)
      started = false
    end)
  end

  local wasActive = false
  runtime.AddConnection(
    Module.RuntimeLoop,
    runService.Heartbeat:Connect(function()
      if not runtime.IsRunning() then
        return
      end
      if state.AntiHit ~= true then
        if wasActive then
          wasActive = false
          restore(runtime)
        end
        return
      end

      local root = runtime.GetRoot()
      local hum = runtime.GetHumanoid()
      if not root or not hum or (state.FlyEnabled and state.FlyToggle) then
        wasActive = false
        restore(runtime)
        return
      end

      wasActive = true
      local nowTick = tick()
      local t = nowTick * math.clamp(runtime.SafeNum(state.AntiHitSpeed), 0.4, 12)
      local mode = tostring(state.AntiHitMode or "Adaptive Jitter")
      if runtime.IsRoundStarted() then
        restorePose()
        applyHitboxTracked(runtime, state, nowTick)
        hum.AutoRotate = false
        local yaw = t * (mode == "Orbital Drift" and 5.4 or 7.2)
        local pitch = math.sin(t * 3.4) * (state.AntiHitExperimental and 1.4 or 0.85)
        local roll = math.cos(t * 4.1) * (mode == "Vector Chaos" and 1.4 or 0.85)
        if mode == "Head Orbit" then
          pitch = pitch + math.pi
        end
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(pitch, yaw, roll)
      else
        restoreHitbox()
        hum.AutoRotate = true
        applyLobbyPose(runtime, state, t, mode)
      end
    end)
  )

  return true
end

return Module
