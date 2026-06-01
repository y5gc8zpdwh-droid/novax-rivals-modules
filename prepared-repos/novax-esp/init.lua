local Module = {
  Name = "novax.esp",
  Kind = "feature",
  Path = "novax-esp/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.esp",
  StateKeys = {
    "ESPEnabled",
    "ESPEnemy",
    "ESPTeam",
    "ESPHighlight",
    "ESPName",
    "ESPHealth",
    "ESPDistance",
    "ESPBox",
    "ESPSkeleton",
    "ESPBoxScale",
    "ESPMaxDistance",
    "ESPDrawingMode",
  },
}

local started = false
local drawingReady = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"
local drawingRecords = {}
local liteRecords = {}
local liteGui = nil
local activeMode = nil
local wasRendered = false
local frameId = 0
local lastLiteCleanAt = 0

local ENEMY_COLOR = Color3.fromRGB(255, 50, 50)
local TEAM_COLOR = Color3.fromRGB(0, 145, 255)
local TEXT_COLOR = Color3.fromRGB(215, 220, 230)
local HP_BG_COLOR = Color3.fromRGB(20, 20, 20)
local OUTLINE_COLOR = Color3.new(1, 1, 1)
local HEALTH_COLORS = {}

local BOX_KEYS = { "L1", "L2", "L3", "L4" }
local SKELETON_KEYS = { "S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10", "S11", "S12", "S13", "S14" }
local DRAW_KEYS = {
  "Name",
  "Health",
  "Distance",
  "L1",
  "L2",
  "L3",
  "L4",
  "HPBG",
  "HP",
  "S1",
  "S2",
  "S3",
  "S4",
  "S5",
  "S6",
  "S7",
  "S8",
  "S9",
  "S10",
  "S11",
  "S12",
  "S13",
  "S14",
}
local DRAW_TYPES = {
  Name = "Text",
  Health = "Text",
  Distance = "Text",
  L1 = "Line",
  L2 = "Line",
  L3 = "Line",
  L4 = "Line",
  HPBG = "Line",
  HP = "Line",
}
for _, key in ipairs(SKELETON_KEYS) do
  DRAW_TYPES[key] = "Line"
end

local SKELETON_BONES = {
  { { "Head" }, { "UpperTorso", "Torso", "HumanoidRootPart" } },
  { { "UpperTorso", "Torso" }, { "LowerTorso", "HumanoidRootPart" } },
  { { "UpperTorso", "Torso" }, { "LeftUpperArm", "Left Arm" } },
  { { "LeftUpperArm", "Left Arm" }, { "LeftLowerArm", "LeftHand", "Left Arm" } },
  { { "LeftLowerArm", "Left Arm" }, { "LeftHand", "Left Arm" } },
  { { "UpperTorso", "Torso" }, { "RightUpperArm", "Right Arm" } },
  { { "RightUpperArm", "Right Arm" }, { "RightLowerArm", "RightHand", "Right Arm" } },
  { { "RightLowerArm", "Right Arm" }, { "RightHand", "Right Arm" } },
  { { "LowerTorso", "Torso", "HumanoidRootPart" }, { "LeftUpperLeg", "Left Leg" } },
  { { "LeftUpperLeg", "Left Leg" }, { "LeftLowerLeg", "LeftFoot", "Left Leg" } },
  { { "LeftLowerLeg", "Left Leg" }, { "LeftFoot", "Left Leg" } },
  { { "LowerTorso", "Torso", "HumanoidRootPart" }, { "RightUpperLeg", "Right Leg" } },
  { { "RightUpperLeg", "Right Leg" }, { "RightLowerLeg", "RightFoot", "Right Leg" } },
  { { "RightLowerLeg", "Right Leg" }, { "RightFoot", "Right Leg" } },
}

local function getDisplayName(runtime, player)
  if runtime and type(runtime.GetClientPlayerDisplayName) == "function" then
    return runtime.GetClientPlayerDisplayName(player)
  end
  return tostring(player and (player.DisplayName or player.Name) or "")
end

local function getHealthColor(ratio)
  local percent = math.clamp(math.floor(((tonumber(ratio) or 0) * 100) + 0.5), 0, 100)
  local color = HEALTH_COLORS[percent]
  if not color then
    local normalized = percent / 100
    color = Color3.fromRGB(math.floor(255 * (1 - normalized)), math.floor(255 * normalized), 45)
    HEALTH_COLORS[percent] = color
  end
  return color
end

local function getPart(char, names)
  if not char then
    return nil
  end
  for _, name in ipairs(names) do
    local part = char:FindFirstChild(name)
    if part and part:IsA("BasePart") then
      return part
    end
  end
  return nil
end

local function getCharacterData(player)
  local char = player and player.Character
  if not char then
    return nil
  end
  local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
  local hum = char:FindFirstChildOfClass("Humanoid")
  local head = char:FindFirstChild("Head")
  return char, root, hum, head
end

local function hideDrawingRecord(record)
  if not record then
    return
  end
  for _, key in ipairs(DRAW_KEYS) do
    local obj = record[key]
    if obj then
      obj.Visible = false
    end
  end
end

local function destroyDrawingRecord(player)
  local record = drawingRecords[player]
  if not record then
    return
  end
  for _, key in ipairs(DRAW_KEYS) do
    local obj = record[key]
    if obj then
      pcall(function()
        obj:Remove()
      end)
    end
  end
  if record.Highlight then
    pcall(function()
      record.Highlight:Destroy()
    end)
  end
  drawingRecords[player] = nil
end

local function destroyLiteRecord(player)
  local record = liteRecords[player]
  if not record then
    return
  end
  if record.Billboard then
    pcall(function()
      record.Billboard:Destroy()
    end)
  end
  if record.Highlight then
    pcall(function()
      record.Highlight:Destroy()
    end)
  end
  liteRecords[player] = nil
end

local function cleanAll()
  for player in pairs(drawingRecords) do
    destroyDrawingRecord(player)
  end
  for player in pairs(liteRecords) do
    destroyLiteRecord(player)
  end
  if liteGui then
    pcall(function()
      liteGui:Destroy()
    end)
    liteGui = nil
  end
  activeMode = nil
  wasRendered = false
end

local function configureDrawing(key, obj)
  if not obj then
    return
  end
  obj.Visible = false
  if obj.Thickness ~= nil then
    obj.Thickness = (key == "HPBG" or key == "HP") and 3 or (string.sub(key, 1, 1) == "S" and 1 or 2)
  end
  if key == "HPBG" and obj.Color ~= nil then
    obj.Color = HP_BG_COLOR
  end
  if key == "Name" or key == "Health" or key == "Distance" then
    obj.Center = true
    obj.Outline = true
    obj.Font = 2
    obj.Size = (key == "Name") and 13 or 11
  end
end

local function ensureDrawing(record, key)
  if not drawingReady or not record then
    return nil
  end
  if record[key] then
    return record[key]
  end
  local drawType = DRAW_TYPES[key]
  if not drawType then
    return nil
  end
  local ok, obj = pcall(function()
    return Drawing.new(drawType)
  end)
  if not ok or not obj then
    drawingReady = false
    return nil
  end
  configureDrawing(key, obj)
  record[key] = obj
  return obj
end

local function ensureDrawingRecord(player)
  local record = drawingRecords[player]
  if record then
    return record
  end
  record = { SkeletonPairs = {}, SkeletonScannedAt = 0 }
  drawingRecords[player] = record
  return record
end

local function setDrawingBox(record, x1, y1, x2, y2, color)
  local l1 = ensureDrawing(record, "L1")
  local l2 = ensureDrawing(record, "L2")
  local l3 = ensureDrawing(record, "L3")
  local l4 = ensureDrawing(record, "L4")
  if not l1 or not l2 or not l3 or not l4 then
    return false
  end
  l1.From, l1.To = Vector2.new(x1, y1), Vector2.new(x2, y1)
  l2.From, l2.To = Vector2.new(x2, y1), Vector2.new(x2, y2)
  l3.From, l3.To = Vector2.new(x2, y2), Vector2.new(x1, y2)
  l4.From, l4.To = Vector2.new(x1, y2), Vector2.new(x1, y1)
  for _, key in ipairs(BOX_KEYS) do
    local line = record[key]
    line.Color = color
    line.Visible = true
  end
  return true
end

local function hideDrawingKeys(record, keys)
  for _, key in ipairs(keys) do
    local obj = record and record[key]
    if obj then
      obj.Visible = false
    end
  end
end

local function screenBounds(camera, root, head, widthFactor)
  if not camera or not root then
    return nil
  end
  head = (head and head.Parent and head) or root
  local headPos, headOn = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.55, 0))
  local rootPos, rootOn = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.6, 0))
  if not headOn or not rootOn then
    return nil
  end
  local height = math.abs(rootPos.Y - headPos.Y)
  if height < 10 then
    return nil
  end
  widthFactor = math.clamp(tonumber(widthFactor) or 0.45, 0.3, 0.7)
  local halfW = math.max(6, height * widthFactor)
  local centerX = headPos.X
  local topY = math.min(headPos.Y, rootPos.Y)
  return centerX - halfW, topY, centerX + halfW, topY + height
end

local function refreshSkeletonPairs(record, char)
  local now = tick()
  if record.SkeletonChar == char and now - (record.SkeletonScannedAt or 0) < 1.25 then
    return record.SkeletonPairs
  end
  local pairsOut = record.SkeletonPairs or {}
  for index = 1, #SKELETON_BONES do
    local bone = SKELETON_BONES[index]
    pairsOut[index] = {
      getPart(char, bone[1]),
      getPart(char, bone[2]),
    }
  end
  record.SkeletonChar = char
  record.SkeletonPairs = pairsOut
  record.SkeletonScannedAt = now
  return pairsOut
end

local function setSkeleton(record, camera, char, color)
  local pairsOut = refreshSkeletonPairs(record, char)
  for index, key in ipairs(SKELETON_KEYS) do
    local line = ensureDrawing(record, key)
    local pair = pairsOut[index]
    local aPart = pair and pair[1]
    local bPart = pair and pair[2]
    if line and aPart and bPart and aPart ~= bPart then
      local a, aOn = camera:WorldToViewportPoint(aPart.Position)
      local b, bOn = camera:WorldToViewportPoint(bPart.Position)
      if aOn and bOn then
        line.From = Vector2.new(a.X, a.Y)
        line.To = Vector2.new(b.X, b.Y)
        line.Color = color
        line.Visible = true
      else
        line.Visible = false
      end
    elseif line then
      line.Visible = false
    end
  end
end

local function ensureHighlight(record, char)
  local highlight = record.Highlight
  if highlight and highlight.Parent then
    return highlight
  end
  highlight = Instance.new("Highlight")
  highlight.Name = "NX_ESP_HL"
  highlight.Archivable = false
  highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  highlight.OutlineTransparency = 0
  highlight.FillTransparency = 0.76
  highlight.Parent = char
  record.Highlight = highlight
  return highlight
end

local function setHighlight(record, char, color, enabled, fill)
  local highlight = record.Highlight
  if enabled then
    highlight = ensureHighlight(record, char)
    highlight.Adornee = char
    highlight.FillColor = color
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.FillTransparency = fill and 0.76 or 1
    highlight.Enabled = true
  elseif highlight and highlight.Parent then
    highlight.Enabled = false
  end
end

local function updateDrawingPlayer(runtime, player, snap)
  local localPlayer = runtime.GetLocalPlayer()
  if not player or player == localPlayer then
    return false
  end
  local char, root, hum, head = getCharacterData(player)
  if not char or not root or not hum or hum.Health <= 0 then
    destroyDrawingRecord(player)
    return false
  end

  local enemy = runtime.IsEnemy(player, true)
  if not ((enemy and snap.showEnemy) or ((not enemy) and snap.showTeam)) then
    local old = drawingRecords[player]
    if old then
      hideDrawingRecord(old)
      setHighlight(old, char, TEAM_COLOR, false, false)
    end
    return false
  end

  local delta = snap.cameraPos - root.Position
  local distSq = delta:Dot(delta)
  if snap.maxDist > 0 and distSq > snap.maxDistSq then
    local old = drawingRecords[player]
    if old then
      hideDrawingRecord(old)
      setHighlight(old, char, TEAM_COLOR, false, false)
    end
    return false
  end

  local dist = math.sqrt(distSq)
  local detailLimit = snap.maxDist > 0 and math.min(snap.maxDist * 0.52, 420) or 420
  local textLimit = snap.maxDist > 0 and math.min(snap.maxDist * 0.72, 650) or 650
  local showHealth = snap.showHealth and dist <= detailLimit
  local showSkeleton = snap.showSkeleton and dist <= detailLimit
  local showName = snap.showName and dist <= textLimit
  local showDistance = snap.showDistance
  local showBox = snap.showBox

  local wantsDrawing = showName or showHealth or showDistance or showBox or showSkeleton
  local record = ensureDrawingRecord(player)
  local color = enemy and ENEMY_COLOR or TEAM_COLOR
  setHighlight(record, char, color, snap.showHighlight == true, true)
  if not wantsDrawing then
    hideDrawingRecord(record)
    return true
  end

  local x1, y1, x2, y2 = screenBounds(snap.camera, root, head, snap.boxWidthFactor)
  if not x1 then
    hideDrawingRecord(record)
    return false
  end

  if showBox then
    setDrawingBox(record, x1, y1, x2, y2, color)
  else
    hideDrawingKeys(record, BOX_KEYS)
  end

  if showSkeleton then
    setSkeleton(record, snap.camera, char, color)
  else
    hideDrawingKeys(record, SKELETON_KEYS)
  end

  if showName then
    local obj = ensureDrawing(record, "Name")
    if obj then
      obj.Text = getDisplayName(runtime, player)
      obj.Position = Vector2.new((x1 + x2) * 0.5, y1 - 16)
      obj.Color = color
      obj.Visible = true
    end
  elseif record.Name then
    record.Name.Visible = false
  end

  if showHealth then
    local health = ensureDrawing(record, "Health")
    local hpBg = ensureDrawing(record, "HPBG")
    local hp = ensureDrawing(record, "HP")
    if health and hpBg and hp then
      local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
      local hpColor = getHealthColor(ratio)
      health.Text = tostring(math.floor(hum.Health + 0.5))
      health.Position = Vector2.new((x1 + x2) * 0.5, y1 - 4)
      health.Color = hpColor
      health.Visible = true
      hpBg.From = Vector2.new(x1 - 6, y1)
      hpBg.To = Vector2.new(x1 - 6, y2)
      hp.From = Vector2.new(x1 - 6, y2)
      hp.To = Vector2.new(x1 - 6, y2 - ((y2 - y1) * ratio))
      hpBg.Visible = true
      hp.Visible = true
      hp.Color = hpColor
    end
  else
    hideDrawingKeys(record, { "Health", "HPBG", "HP" })
  end

  if showDistance then
    local obj = ensureDrawing(record, "Distance")
    if obj then
      obj.Text = tostring(math.floor(dist + 0.5)) .. "m"
      obj.Position = Vector2.new((x1 + x2) * 0.5, y2 + 3)
      obj.Color = TEXT_COLOR
      obj.Visible = true
    end
  elseif record.Distance then
    record.Distance.Visible = false
  end

  return true
end

local function getLiteParent(runtime)
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
  local ok, coreGui = pcall(function()
    return game:GetService("CoreGui")
  end)
  return ok and coreGui or nil
end

local function ensureLiteGui(runtime)
  if liteGui and liteGui.Parent then
    return liteGui
  end
  local parent = getLiteParent(runtime)
  if not parent then
    return nil
  end
  local gui = Instance.new("ScreenGui")
  gui.Name = "NX_LITE_ESP"
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.DisplayOrder = 8
  local ok = pcall(function()
    gui.Parent = parent
  end)
  if not ok or not gui.Parent then
    pcall(function()
      gui:Destroy()
    end)
    return nil
  end
  liteGui = gui
  return gui
end

local function setLiteText(label, text, color, visible)
  if not label then
    return
  end
  label.Visible = visible == true
  if label.Visible then
    label.Text = tostring(text or "")
    if color then
      label.TextColor3 = color
    end
  end
end

local function ensureLiteRecord(runtime, player)
  local gui = ensureLiteGui(runtime)
  local localPlayer = runtime.GetLocalPlayer()
  if not gui or not player or player == localPlayer then
    return nil
  end
  local record = liteRecords[player]
  if record and record.Billboard and record.Billboard.Parent and record.Highlight and record.Highlight.Parent then
    return record
  end
  destroyLiteRecord(player)

  record = {}
  local billboard = Instance.new("BillboardGui")
  billboard.Name = "NX_LITE_ESP_TAG"
  billboard.AlwaysOnTop = true
  billboard.LightInfluence = 0
  billboard.Size = UDim2.new(0, 150, 0, 54)
  billboard.StudsOffset = Vector3.new(0, 2.8, 0)
  billboard.Enabled = false
  billboard.Parent = gui

  local frame = Instance.new("Frame")
  frame.BackgroundTransparency = 1
  frame.Size = UDim2.new(1, 0, 1, 0)
  frame.Parent = billboard

  local layout = Instance.new("UIListLayout")
  layout.FillDirection = Enum.FillDirection.Vertical
  layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
  layout.VerticalAlignment = Enum.VerticalAlignment.Center
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.Parent = frame

  local function label(name, size, order)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.BackgroundTransparency = 1
    item.Size = UDim2.new(1, 0, 0, size + 3)
    item.Font = Enum.Font.GothamBold
    item.TextSize = size
    item.TextStrokeTransparency = 0.28
    item.TextStrokeColor3 = Color3.new(0, 0, 0)
    item.TextColor3 = TEXT_COLOR
    item.Text = ""
    item.Visible = false
    item.LayoutOrder = order
    item.Parent = frame
    return item
  end

  record.Billboard = billboard
  record.NameLabel = label("Name", 12, 1)
  record.HealthLabel = label("Health", 11, 2)
  record.DistanceLabel = label("Distance", 10, 3)
  record.SkeletonLabel = label("Skeleton", 10, 4)

  local highlight = Instance.new("Highlight")
  highlight.Name = "NX_LITE_ESP_HL"
  highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  highlight.Enabled = false
  highlight.FillTransparency = 1
  highlight.OutlineTransparency = 0
  highlight.OutlineColor = OUTLINE_COLOR
  highlight.Parent = gui
  record.Highlight = highlight

  liteRecords[player] = record
  return record
end

local function hideLiteRecord(player)
  local record = liteRecords[player]
  if not record then
    return
  end
  if record.Billboard then
    record.Billboard.Enabled = false
  end
  if record.Highlight then
    record.Highlight.Enabled = false
  end
end

local function updateLitePlayer(runtime, player, snap)
  local localPlayer = runtime.GetLocalPlayer()
  if not player or player == localPlayer then
    return false
  end
  local char, root, hum, head = getCharacterData(player)
  if not char or not root or not hum or hum.Health <= 0 then
    hideLiteRecord(player)
    return false
  end
  local enemy = runtime.IsEnemy(player, true)
  if not ((enemy and snap.showEnemy) or ((not enemy) and snap.showTeam)) then
    hideLiteRecord(player)
    return false
  end
  local delta = snap.cameraPos - root.Position
  local distSq = delta:Dot(delta)
  if snap.maxDist > 0 and distSq > snap.maxDistSq then
    hideLiteRecord(player)
    return false
  end

  local dist = math.sqrt(distSq)
  local detailLimit = snap.maxDist > 0 and math.min(snap.maxDist * 0.52, 420) or 420
  local textLimit = snap.maxDist > 0 and math.min(snap.maxDist * 0.72, 650) or 650
  local showName = snap.showName and dist <= textLimit
  local showHealth = snap.showHealth and dist <= detailLimit
  local showSkeleton = snap.showSkeleton and dist <= math.min(detailLimit, 300)
  local showDistance = snap.showDistance

  local record = ensureLiteRecord(runtime, player)
  if not record then
    return false
  end
  local color = enemy and ENEMY_COLOR or TEAM_COLOR
  local targetAdornee = (head and head.Parent and head) or root
  record.Billboard.Adornee = targetAdornee
  record.Billboard.Enabled = showName or showHealth or showDistance or showSkeleton
  record.Highlight.Adornee = char
  record.Highlight.OutlineColor = color
  record.Highlight.FillColor = color
  record.Highlight.FillTransparency = snap.showHighlight and 0.76 or 1
  record.Highlight.OutlineTransparency = (snap.showBox or snap.showHighlight) and 0 or 1
  record.Highlight.Enabled = snap.showBox or snap.showHighlight

  setLiteText(record.NameLabel, getDisplayName(runtime, player), color, showName)
  if showHealth then
    local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    setLiteText(record.HealthLabel, tostring(math.floor(hum.Health + 0.5)) .. " HP", getHealthColor(ratio), true)
  else
    setLiteText(record.HealthLabel, "", nil, false)
  end
  setLiteText(record.DistanceLabel, tostring(math.floor(dist + 0.5)) .. "m", TEXT_COLOR, showDistance)
  setLiteText(record.SkeletonLabel, "+", color, showSkeleton)
  return true
end

local function buildSnapshot(runtime, state, camera, frame)
  local maxDist = math.max(0, runtime.SafeNum(state.ESPMaxDistance))
  return {
    camera = camera,
    cameraPos = camera.CFrame.Position,
    maxDist = maxDist,
    maxDistSq = maxDist * maxDist,
    boxWidthFactor = math.clamp(runtime.SafeNum(state.ESPBoxScale) / 100, 0.3, 0.7),
    showEnemy = state.ESPEnemy == true,
    showTeam = state.ESPTeam == true,
    showHighlight = state.ESPHighlight == true,
    showName = state.ESPName == true,
    showHealth = state.ESPHealth == true,
    showDistance = state.ESPDistance == true,
    showBox = state.ESPBox == true,
    showSkeleton = state.ESPSkeleton == true and runtime.IsRoundStarted(),
    frameId = frame,
  }
end

local function runESPFrame(runtime, state, mode, frame)
  local camera = runtime.GetCamera()
  if not runtime.IsRunning() or not camera then
    return false
  end
  local snap = buildSnapshot(runtime, state, camera, frame)
  if not snap.showEnemy and not snap.showTeam then
    return false
  end

  local now = tick()
  if mode == "lite" and now - lastLiteCleanAt > 10 then
    lastLiteCleanAt = now
    for player in pairs(liteRecords) do
      if not player.Parent then
        destroyLiteRecord(player)
      end
    end
  end

  local players = runtime.UpdateCache() or {}
  for _, player in ipairs(players) do
    if mode == "drawing" then
      updateDrawingPlayer(runtime, player, snap)
    else
      updateLitePlayer(runtime, player, snap)
    end
  end
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
  local players = runtime.Services and runtime.Services.Players
  if not state or not players then
    error(Module.Name .. ": missing runtime state/services")
  end

  if type(runtime.RegisterESPApi) == "function" then
    runtime.RegisterESPApi({
      CleanAll = cleanAll,
    })
  end

  runtime.AddConnection(
    "visual.esp.remove",
    players.PlayerRemoving:Connect(function(player)
      destroyDrawingRecord(player)
      destroyLiteRecord(player)
    end)
  )

  runtime.AddRenderStep(Module.RuntimeLoop, Enum.RenderPriority.Last.Value + 100, function()
    if not runtime.IsRunning() then
      return
    end
    if state.ESPEnabled ~= true then
      if activeMode ~= nil or wasRendered then
        cleanAll()
      end
      return
    end

    local mode = (state.ESPDrawingMode == true and drawingReady) and "drawing" or "lite"
    if activeMode ~= mode then
      cleanAll()
      activeMode = mode
    end

    frameId = frameId + 1
    if runESPFrame(runtime, state, mode, frameId) then
      wasRendered = true
    elseif wasRendered then
      cleanAll()
    end
  end)

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      cleanAll()
      started = false
      if type(runtime.RegisterESPApi) == "function" then
        runtime.RegisterESPApi(nil)
      end
    end)
  end

  return true
end

return Module
