local Module = {
  Name = "novax.fov",
  Kind = "feature",
  Path = "novax-fov/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.fov",
  StateKeys = { "AimFOVCircle", "AimFOV", "AimFOVHidden", "AimFOVColor", "ReactiveFOV" },
}

local started = false
local fovGui, fovFrame, fovStroke = nil, nil, nil
local reactiveOffset = Vector2.new(0, 0)

local COLORS = {
  White = Color3.fromRGB(235, 245, 255),
  Blue = Color3.fromRGB(84, 146, 255),
  Cyan = Color3.fromRGB(70, 225, 255),
  Green = Color3.fromRGB(80, 255, 145),
  Yellow = Color3.fromRGB(255, 220, 80),
  Red = Color3.fromRGB(255, 70, 70),
  Pink = Color3.fromRGB(255, 95, 190),
}

local function getColor(state)
  return COLORS[tostring(state.AimFOVColor or "White")] or COLORS.White
end

local function getGuiParent(runtime)
  if typeof(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
      return hui
    end
  end

  local localPlayer = runtime.GetLocalPlayer()
  local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
  if playerGui then
    return playerGui
  end

  local okCore, coreGui = pcall(function()
    return game:GetService("CoreGui")
  end)
  return okCore and coreGui or nil
end

local function ensureGui(runtime)
  if fovFrame and fovFrame.Parent and fovStroke then
    return true
  end

  local parent = getGuiParent(runtime)
  if not parent then
    return false
  end

  local gui = Instance.new("ScreenGui")
  gui.Name = "NX_FOV_UI"
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.DisplayOrder = 5

  local okParent = pcall(function()
    gui.Parent = parent
  end)
  if not okParent or not gui.Parent then
    pcall(function()
      gui:Destroy()
    end)
    return false
  end

  local frame = Instance.new("Frame")
  frame.Name = "Circle"
  frame.AnchorPoint = Vector2.new(0.5, 0.5)
  frame.BackgroundTransparency = 1
  frame.BorderSizePixel = 0
  frame.ZIndex = 1
  frame.Visible = false
  frame.Parent = gui

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(1, 0)
  corner.Parent = frame

  local line = Instance.new("UIStroke")
  line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  line.Thickness = 2
  line.Transparency = 0
  line.Parent = frame

  fovGui = gui
  fovFrame = frame
  fovStroke = line

  if getgenv then
    getgenv().NX_FOV_GUI = gui
  end
  return true
end

local function getHead(player)
  local char = player and player.Character
  local head = char and char:FindFirstChild("Head")
  return head and head:IsA("BasePart") and head or nil
end

local function getReactiveOffset(runtime, state, center, radius)
  local camera = runtime.GetCamera()
  if state.ReactiveFOV ~= true or not camera then
    reactiveOffset = reactiveOffset:Lerp(Vector2.new(0, 0), 0.32)
    return reactiveOffset
  end

  local players = runtime.UpdateCache()
  local localPlayer = runtime.GetLocalPlayer()
  local myRoot = runtime.GetRoot()
  local maxDist = math.max(50, runtime.SafeNum(state.AimLockMaxDist))
  local searchRadius = math.max(80, runtime.SafeNum(radius) * 1.45)
  local bestOffset, bestDist = nil, math.huge

  for _, player in ipairs(players or {}) do
    if player ~= localPlayer and runtime.IsEnemy(player, state.AimTeamCheck) and runtime.IsAlive(player) then
      local head = getHead(player)
      if head then
        local inRange = true
        if myRoot then
          inRange = (head.Position - myRoot.Position).Magnitude <= maxDist
        end
        if inRange then
          local screenPos, onScreen = runtime.WorldToScreen(head.Position)
          if onScreen then
            local offset = screenPos - center
            local dist = offset.Magnitude
            if dist <= searchRadius and dist < bestDist then
              bestOffset, bestDist = offset, dist
            end
          end
        end
      end
    end
  end

  local targetOffset = Vector2.new(0, 0)
  if bestOffset then
    local maxOffset = math.clamp(runtime.SafeNum(radius) * 0.32, 18, 90)
    targetOffset = bestOffset.Magnitude > maxOffset and bestOffset.Unit * maxOffset or bestOffset
  end

  reactiveOffset = reactiveOffset:Lerp(targetOffset, bestOffset and 0.28 or 0.34)
  if reactiveOffset.Magnitude < 0.2 then
    reactiveOffset = Vector2.new(0, 0)
  end
  return reactiveOffset
end

local function update(runtime, state)
  local camera = runtime.GetCamera()
  if not camera then
    return
  end

  local visible = state.AimFOVCircle == true and state.AimFOVHidden ~= true
  if not visible then
    if fovFrame and fovFrame.Parent and fovFrame.Visible then
      fovFrame.Visible = false
    end
    return
  end

  local radius = math.max(1, runtime.SafeNum(state.AimFOV))
  local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
  center = center + getReactiveOffset(runtime, state, center, radius)

  if ensureGui(runtime) then
    fovFrame.Visible = true
    fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    fovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    fovStroke.Color = getColor(state)
  end
end

local function cleanup()
  reactiveOffset = Vector2.new(0, 0)
  if fovGui then
    pcall(function()
      fovGui:Destroy()
    end)
  end
  fovGui, fovFrame, fovStroke = nil, nil, nil
  if getgenv then
    getgenv().NX_FOV_GUI = nil
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
  if not state or type(runtime.AddRenderStep) ~= "function" or type(runtime.RegisterFOVUpdater) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  runtime.RegisterFOVUpdater(function()
    update(runtime, state)
  end)

  runtime.AddRenderStep(Module.RuntimeLoop, Enum.RenderPriority.Last.Value + 1, function()
    if not runtime.IsRunning() then
      return
    end
    update(runtime, state)
  end)

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, cleanup)
  end

  return true
end

return Module
