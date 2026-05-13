-- NovaPremiumUI.lua
-- Single-file modern Roblox GUI library (premium app-style).

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

if not game:IsLoaded() then
  game.Loaded:Wait()
end

local UI = {}
UI.__index = UI
UI.Debug = false

function UI.SetDebug(self, maybeVal)
  local v = maybeVal
  if type(self) == "boolean" and maybeVal == nil then
    v = self
  end
  UI.Debug = v and true or false
  if UI.Debug then warn("[NovaPremiumUI][debug] Debug enabled") end
end

UI.DefaultTheme = {
  Font = Enum.Font.Gotham,
  Radius = 10,
  WindowSize = Vector2.new(900, 590),
  LogoImage = {
    "novax_logo_transparent.png",
    "C:/Users/User/OneDrive/Neuer Ordner 1/novax_logo_transparent.png",
    "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\novax_logo_transparent.png",
    "download.png",
    "NovaX_Logo.png",
    "C:/Users/User/OneDrive/Neuer Ordner 1/download.png",
    "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\download.png",
  },
  LogoRingImage = {
    "novax_logo_ring_transparent.png",
    "C:/Users/User/OneDrive/Neuer Ordner 1/novax_logo_ring_transparent.png",
    "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\novax_logo_ring_transparent.png",
  },
  LogoRectOffset = nil,
  LogoRectSize = nil,
  Blur = {
    Enabled = true,
    Size = 4,
  },
  Colors = {
    BgA = Color3.fromRGB(10, 11, 14),
    BgB = Color3.fromRGB(15, 17, 22),
    Surface = Color3.fromRGB(19, 22, 28),
    SurfaceGlass = Color3.fromRGB(22, 25, 32),
    ExpandableSurface = Color3.fromRGB(25, 29, 37),
    ExpandableSurfaceOpen = Color3.fromRGB(31, 36, 46),
    ExpandableTitle = Color3.fromRGB(23, 27, 34),
    ExpandableTitleOpen = Color3.fromRGB(34, 40, 51),
    NestedSurface = Color3.fromRGB(14, 17, 22),
    NestedSurface2 = Color3.fromRGB(22, 26, 33),
    NestedStroke = Color3.fromRGB(50, 57, 69),
    Surface2 = Color3.fromRGB(25, 29, 37),
    Surface3 = Color3.fromRGB(33, 38, 48),
    Sidebar = Color3.fromRGB(14, 16, 21),
    Sidebar2 = Color3.fromRGB(19, 22, 28),
    Stroke = Color3.fromRGB(66, 74, 88),
    StrokeSoft = Color3.fromRGB(45, 52, 64),
    Text = Color3.fromRGB(232, 235, 240),
    TextDim = Color3.fromRGB(160, 168, 179),
    TextMuted = Color3.fromRGB(105, 114, 127),
    Accent = Color3.fromRGB(104, 119, 140),
    Accent2 = Color3.fromRGB(137, 149, 165),
    Accent3 = Color3.fromRGB(112, 123, 138),
    AccentSoft = Color3.fromRGB(34, 40, 51),
    Input = Color3.fromRGB(14, 17, 22),
    Hover = Color3.fromRGB(30, 35, 44),
    Active = Color3.fromRGB(39, 47, 60),
    Shadow = Color3.fromRGB(0, 0, 0),
  },
  Anim = {
    Fast = 0.12,
    Normal = 0.22,
    Slow = 0.42,
    Splash = 2.4,
  },
  Spacing = {
    XS = 4,
    SM = 8,
    MD = 12,
    LG = 16,
  },
}

local function copy(tbl)
  local out = {}
  for k, v in pairs(tbl) do
    out[k] = type(v) == "table" and copy(v) or v
  end
  return out
end

local function merge(base, override)
  local out = copy(base)
  if type(override) ~= "table" then
    return out
  end
  for k, v in pairs(override) do
    if type(v) == "table" and type(out[k]) == "table" then
      out[k] = merge(out[k], v)
    else
      out[k] = v
    end
  end
  return out
end

local function make(class, props)
  local inst = Instance.new(class)
  for k, v in pairs(props or {}) do
    local ok, err = pcall(function()
      inst[k] = v
    end)
    if not ok and UI.Debug then
      warn("[NovaPremiumUI][debug] Property failed:", tostring(class), tostring(k), tostring(err))
    end
  end
  if UI.Debug and not inst then
    warn("[NovaPremiumUI][debug] Instance.new returned nil for class:", tostring(class))
  end
  return inst
end

local function corner(parent, radius)
  return make("UICorner", {CornerRadius = UDim.new(0, radius), Parent = parent})
end

local function stroke(parent, color, thickness, transparency)
  return make("UIStroke", {
    Color = color,
    Thickness = thickness or 1,
    Transparency = transparency or 0,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = parent,
  })
end

local function gradient(parent, c0, c1, rotation)
  return make("UIGradient", {
    Rotation = rotation or 0,
    Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, c0),
      ColorSequenceKeypoint.new(1, c1),
    }),
    Parent = parent,
  })
end

local function cancelTween(tw)
  if tw then
    pcall(function() tw:Cancel() end)
  end
end

local activeTweens = setmetatable({}, {__mode = "k"})

local function tween(obj, t, props, style, dir)
  if not obj then return nil end
  cancelTween(activeTweens[obj])
  local ok, tw = pcall(function()
    return TweenService:Create(
      obj,
      TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
      props
    )
  end)
  if ok and tw then
    activeTweens[obj] = tw
    tw.Completed:Connect(function()
      if activeTweens[obj] == tw then
        activeTweens[obj] = nil
      end
    end)
    tw:Play()
    return tw
  end
  for k, v in pairs(props or {}) do
    pcall(function()
      obj[k] = v
    end)
  end
  if UI.Debug and not ok then
    warn("[NovaPremiumUI][debug] Tween failed:", tostring(tw))
  end
  return nil
end

local function addPadding(parent, x, y)
  return make("UIPadding", {
    PaddingLeft = UDim.new(0, x),
    PaddingRight = UDim.new(0, x),
    PaddingTop = UDim.new(0, y),
    PaddingBottom = UDim.new(0, y),
    Parent = parent,
  })
end

local function addHoverScale(target, theme, hoverScale, downScale)
  local scale = target:FindFirstChildOfClass("UIScale") or make("UIScale", {Scale = 1, Parent = target})
  target.MouseEnter:Connect(function()
    tween(scale, theme.Anim.Fast, {Scale = hoverScale or 1.015}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  end)
  target.MouseLeave:Connect(function()
    tween(scale, theme.Anim.Fast, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  end)
  target.MouseButton1Down:Connect(function()
    tween(scale, theme.Anim.Fast * 0.8, {Scale = downScale or 0.985}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  end)
  target.MouseButton1Up:Connect(function()
    tween(scale, theme.Anim.Fast, {Scale = hoverScale or 1.015}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  end)
  return scale
end

local function attachSmoothScroll(scroller, theme, trackConnection)
  if not scroller then
    return
  end
  local alreadyAttached = false
  pcall(function()
    alreadyAttached = scroller:GetAttribute("NovaSmoothScroll") == true
  end)
  if alreadyAttached then
    return
  end
  pcall(function() scroller:SetAttribute("NovaSmoothScroll", true) end)
  pcall(function() scroller.ScrollBarImageColor3 = theme.Colors.Accent3 or theme.Colors.Accent end)
  pcall(function() scroller.ScrollBarImageTransparency = 0.45 end)
  pcall(function()
    if Enum.ElasticBehavior and Enum.ElasticBehavior.Always then
      scroller.ElasticBehavior = Enum.ElasticBehavior.Always
    end
  end)

  local targetY = 0
  local activeTween
  local conn = scroller.InputChanged:Connect(function(input)
    pcall(function()
      if input.UserInputType ~= Enum.UserInputType.MouseWheel then
        return
      end
      local canvasY = scroller.AbsoluteCanvasSize and scroller.AbsoluteCanvasSize.Y or scroller.CanvasSize.Y.Offset
      local windowY = scroller.AbsoluteWindowSize and scroller.AbsoluteWindowSize.Y or scroller.AbsoluteSize.Y
      local maxY = math.max(0, canvasY - windowY)
      targetY = math.clamp(scroller.CanvasPosition.Y - (input.Position.Z * 54), 0, maxY)
      cancelTween(activeTween)
      activeTween = tween(
        scroller,
        theme.Anim.Normal,
        {CanvasPosition = Vector2.new(scroller.CanvasPosition.X, targetY)},
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
      )
    end)
  end)
  if trackConnection then
    trackConnection(conn)
  end
end

local function safeCallback(callback, ...)
  if type(callback) ~= "function" then
    return
  end
  local ok, err = pcall(callback, ...)
  if not ok and UI.Debug then
    warn("[NovaPremiumUI][debug] Callback failed:", tostring(err))
  end
end

local function resolveAssetSource(source)
  local function resolveOne(value)
    if type(value) ~= "string" or value == "" then
      return nil
    end
    
    if value:match("^rbxasset") or value:match("^http") then
      return value
    end
    
    if typeof(getcustomasset) == "function" then
      local ok, asset = pcall(getcustomasset, value)
      if ok and type(asset) == "string" and asset ~= "" then
        return asset
      end
    end
    
    if typeof(getsynasset) == "function" then
      local ok, asset = pcall(getsynasset, value)
      if ok and type(asset) == "string" and asset ~= "" then
        return asset
      end
    end
    
    return nil
  end
  
  if type(source) == "table" then
    for _, value in ipairs(source) do
      local asset = resolveOne(value)
      if asset then
        return asset
      end
    end
    return nil
  end
  
  return resolveOne(source)
end

local function createNovaMark(parent, theme, size, imageSource, rectOffset, rectSize)
  local hasImage = imageSource ~= nil
  local badge = make("Frame", {
    Size = UDim2.new(0, size, 0, size),
    BackgroundColor3 = theme.Colors.Input,
    BorderSizePixel = 0,
    BackgroundTransparency = hasImage and 1 or 0,
    ClipsDescendants = not hasImage,
    Parent = parent,
  })
  if not hasImage then
    corner(badge, math.max(10, math.floor(size * 0.28)))
    stroke(badge, theme.Colors.Stroke, 1, 0.22)
    gradient(badge, theme.Colors.AccentSoft, theme.Colors.Input, 38)
  end
  
  if imageSource then
    local img = make("ImageLabel", {
      BackgroundTransparency = 1,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(1, 0, 1, 0),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Image = imageSource,
      ImageTransparency = 0,
      ScaleType = Enum.ScaleType.Fit,
      Parent = badge,
    })
    if typeof(rectOffset) == "Vector2" and typeof(rectSize) == "Vector2" then
      img.ImageRectOffset = rectOffset
      img.ImageRectSize = rectSize
    end
  else
    local mark = make("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -10, 1, -10),
      Position = UDim2.new(0, 5, 0, 5),
      Parent = badge,
    })
    local leftLoop = make("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0.58, 0, 0.42, 0),
      Position = UDim2.new(0.03, 0, 0.29, 0),
      Rotation = -18,
      Parent = mark,
    })
    corner(leftLoop, 999)
    stroke(leftLoop, theme.Colors.Accent2 or theme.Colors.Accent, math.max(2, math.floor(size * 0.05)), 0.04)
    local rightLoop = make("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0.58, 0, 0.42, 0),
      Position = UDim2.new(0.39, 0, 0.29, 0),
      Rotation = 18,
      Parent = mark,
    })
    corner(rightLoop, 999)
    stroke(rightLoop, theme.Colors.Accent, math.max(2, math.floor(size * 0.05)), 0.02)
    make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0.58, 0, 0.48, 0),
      Position = UDim2.new(0.2, 0, 0.27, 0),
      Font = Enum.Font.GothamBold,
      TextSize = math.max(10, math.floor(size * 0.25)),
      Text = "</>",
      TextColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      Parent = mark,
    })
    local diamond = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, math.max(8, math.floor(size * 0.22)), 0, math.max(8, math.floor(size * 0.22))),
      Position = UDim2.new(0.72, 0, 0.72, 0),
      Rotation = 15,
      BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      BackgroundTransparency = 0.04,
      BorderSizePixel = 0,
      Parent = mark,
    })
    corner(diamond, math.max(2, math.floor(size * 0.05)))
    local hole = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0.36, 0, 0.36, 0),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      BackgroundColor3 = theme.Colors.Input,
      BorderSizePixel = 0,
      Parent = diamond,
    })
    corner(hole, math.max(1, math.floor(size * 0.03)))
  end
  
  return badge
end

local function getLocalPlayerSafe(maxWait)
  local lp = LocalPlayer or Players.LocalPlayer
  if lp then
    LocalPlayer = lp
    return lp
  end
  local deadline = tick() + (tonumber(maxWait) or 6)
  while tick() < deadline do
    task.wait(0.05)
    lp = Players.LocalPlayer
    if lp then
      LocalPlayer = lp
      return lp
    end
  end
  return nil
end

local function getPlayerGuiSafe(lp, maxWait)
  if not lp then return nil end
  local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
  if pg then return pg end
  local deadline = tick() + (tonumber(maxWait) or 6)
  while tick() < deadline do
    task.wait(0.05)
    pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
    if pg then
      return pg
    end
  end
  return nil
end

local function waitForGameReady(maxWait)
  if not game:IsLoaded() then
    game.Loaded:Wait()
  end
  local lp = getLocalPlayerSafe(maxWait or 8)
  if lp then
    getPlayerGuiSafe(lp, maxWait or 8)
  end
  return lp
end

local function buildGuiParents()
  local list = {}
  local seen = {}
  local function addParent(inst)
    if typeof(inst) ~= "Instance" then return end
    if seen[inst] then return end
    seen[inst] = true
    table.insert(list, inst)
  end
  
  -- Prefer executor UI container when available.
  if typeof(gethui) == "function" then
    local okHui, hui = pcall(gethui)
    if okHui then
      addParent(hui)
    end
  end
  
  addParent(CoreGui)
  
  local lp = getLocalPlayerSafe(4)
  addParent(getPlayerGuiSafe(lp, 4))
  
  return list
end

local function safeParent(gui, retrySeconds)
  local tries = math.max(1, math.floor(((tonumber(retrySeconds) or 2) / 0.1) + 0.5))
  for _ = 1, tries do
    for _, parentInst in ipairs(buildGuiParents()) do
      local ok = pcall(function()
        gui.Parent = parentInst
      end)
      if ok and gui.Parent == parentInst then
        if UI.Debug then
          warn("[NovaPremiumUI][debug] Parented to", parentInst:GetFullName())
        end
        return true
      end
    end
    task.wait(0.1)
  end
  return false
end

local function makeDraggable(handle, target, trackConnection, onMoved, onEnded)
  local dragging = false
  local dragStart, startPos

  local inputBeganConn = handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = target.Position
      local changedConn
      changedConn = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
          if type(onEnded) == "function" then
            pcall(onEnded, target.Position)
          end
          if changedConn then
            changedConn:Disconnect()
            changedConn = nil
          end
        end
      end)
    end
  end)
  if trackConnection then
    trackConnection(inputBeganConn)
  end

  local inputChangedConn = UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
      local d = input.Position - dragStart
      target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
      if type(onMoved) == "function" then
        pcall(onMoved, target.Position)
      end
    end
  end)
  if trackConnection then
    trackConnection(inputChangedConn)
  end
end

local function addRipple(btn, theme)
  local m = UserInputService:GetMouseLocation()
  local lx = m.X - btn.AbsolutePosition.X
  local ly = m.Y - btn.AbsolutePosition.Y

  local clip = btn:FindFirstChild("RippleClip")
  if not clip then
    clip = make("Frame", {
      Name = "RippleClip",
      BackgroundTransparency = 1,
      ClipsDescendants = true,
      Size = UDim2.new(1, 0, 1, 0),
      Parent = btn,
    })
    corner(clip, theme.Radius - 2)
  end

  local r = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, lx, 0, ly),
    Size = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    Parent = clip,
  })
  corner(r, 999)

  local maxS = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
  tween(r, theme.Anim.Normal, {Size = UDim2.new(0, maxS, 0, maxS), BackgroundTransparency = 1})
  task.delay(theme.Anim.Normal + 0.05, function()
    if r and r.Parent then r:Destroy() end
  end)
end

local NotifGui, NotifHolder

local function ensureNotifLayer(theme)
  if NotifGui and NotifGui.Parent and NotifHolder then
    return
  end
  NotifGui = make("ScreenGui", {
    Name = "NovaPremiumUI_Notifications",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  })
  local notifParentOk = safeParent(NotifGui)
  if UI.Debug then
    if notifParentOk and NotifGui.Parent then
      warn("[NovaPremiumUI][debug] Notification ScreenGui parent set to", NotifGui.Parent:GetFullName())
    else
      warn("[NovaPremiumUI][debug] Notification ScreenGui not parented; Parent is:", NotifGui.Parent)
    end
  end

  NotifHolder = make("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Size = UDim2.new(0, 340, 0, 320),
    Position = UDim2.new(1, -18, 1, -18),
    Parent = NotifGui,
  })
  make("UIListLayout", {
    Padding = UDim.new(0, 8),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotifHolder,
  })
end

local function makeControlBase(page, theme, h)
  local f = make("Frame", {
    Size = UDim2.new(1, 0, 0, h or 42),
    BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = page,
  })
  corner(f, theme.Radius - 3)
  stroke(f, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.52)
  gradient(f, theme.Colors.SurfaceGlass or theme.Colors.Surface, theme.Colors.Surface, 18)

  local glow = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = (f.ZIndex or 1),
    Parent = f,
  })
  corner(glow, theme.Radius)
  local highlight = make("Frame", {
    Size = UDim2.new(1, -18, 0, 1),
    Position = UDim2.new(0, 9, 0, 0),
    BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = f,
  })
  local _ = highlight
  return f, glow
end

local function normalizeRange(minValue, maxValue)
  local min = tonumber(minValue) or 0
  local max = tonumber(maxValue) or 100
  if max < min then
    min, max = max, min
  end
  return min, max
end

function UI:Notify(opts)
  opts = opts or {}
  local theme = self._theme or UI.DefaultTheme
  ensureNotifLayer(theme)

  local toast = make("Frame", {
    BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface2,
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundTransparency = 1,
    Parent = NotifHolder,
  })
  corner(toast, theme.Radius)
  stroke(toast, theme.Colors.Stroke, 1, 0.22)
  gradient(toast, theme.Colors.SurfaceGlass or theme.Colors.Surface2, theme.Colors.Input, 18)
  local toastScale = make("UIScale", {Scale = 0.97, Parent = toast})
  local strip = make("Frame", {
    Size = UDim2.new(0, 3, 1, -20),
    Position = UDim2.new(0, 8, 0, 9),
    BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
    BorderSizePixel = 0,
    Parent = toast,
  })
  corner(strip, 999)

  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.new(0, 18, 0, 8),
    Font = theme.Font,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Colors.Text,
    Text = tostring(opts.Title or "Notification"),
    Parent = toast,
  })

  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -28, 0, 40),
    Position = UDim2.new(0, 18, 0, 30),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextColor3 = theme.Colors.TextDim,
    Text = tostring(opts.Content or ""),
    Parent = toast,
  })
  
  local progressBack = make("Frame", {
    Size = UDim2.new(1, -28, 0, 2),
    Position = UDim2.new(0, 18, 1, -9),
    BackgroundColor3 = theme.Colors.StrokeSoft or theme.Colors.Stroke,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    Parent = toast,
  })
  corner(progressBack, 999)
  local progress = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
    BorderSizePixel = 0,
    Parent = progressBack,
  })
  corner(progress, 999)

  toast.AnchorPoint = Vector2.new(1, 0)
  toast.Position = UDim2.new(1, 30, 0, 0)
  local duration = tonumber(opts.Duration) or 6
  tween(toast, theme.Anim.Normal, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0.04}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  tween(toastScale, theme.Anim.Normal, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
  tween(progress, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
  task.delay(duration, function()
    if toast and toast.Parent then
      tween(toast, theme.Anim.Normal, {Position = UDim2.new(1, 36, 0, 0), BackgroundTransparency = 1})
      tween(toastScale, theme.Anim.Normal, {Scale = 0.98})
      task.delay(theme.Anim.Normal + 0.05, function()
        if toast and toast.Parent then toast:Destroy() end
      end)
    end
  end)
end

function UI:CreateWindow(opts)
  opts = opts or {}
  waitForGameReady(10)
  local theme = merge(UI.DefaultTheme, opts.Theme)
  local logoSource = resolveAssetSource(opts.LogoImage or theme.LogoImage)
  local logoRingSource = resolveAssetSource(opts.LogoRingImage or theme.LogoRingImage)
  local logoRectOffset = opts.LogoRectOffset or theme.LogoRectOffset
  local logoRectSize = opts.LogoRectSize or theme.LogoRectSize

  local window = setmetatable({_theme = theme, _tabs = {}, _activeTab = nil}, UI)
  window._connections = {}
  local function bindConnection(conn)
    if conn then
      table.insert(window._connections, conn)
    end
    return conn
  end

  local sz = opts.Size or theme.WindowSize
  local gui = make("ScreenGui", {
    Name = tostring(opts.Name or "NovaPremiumUI"),
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 9999,
    Enabled = true,
  })
  local parented = safeParent(gui, 2.5)
  if not parented or not gui.Parent then
    if UI.Debug then
      warn("[NovaPremiumUI][debug] Failed to parent ScreenGui")
      warn("[NovaPremiumUI][debug] gui.Parent is:", gui.Parent, "; LocalPlayer:", LocalPlayer)
    end
    task.spawn(function()
      local okRetry = safeParent(gui, 10)
      if not okRetry then
        if UI.Debug then warn("[NovaPremiumUI][debug] ScreenGui retry parent failed") end
      elseif UI.Debug and gui.Parent then
        warn("[NovaPremiumUI][debug] ScreenGui retry parent success:", gui.Parent:GetFullName())
      end
    end)
  else
    if UI.Debug then warn("[NovaPremiumUI][debug] ScreenGui parent set to", gui.Parent:GetFullName()) end
  end
  
  local islandGui = nil
  local blurEffect = nil
  local blurSize = tonumber(theme.Blur and theme.Blur.Size) or 0
  if opts.UseBlur ~= false and theme.Blur and theme.Blur.Enabled and blurSize > 0 then
    local okBlur, createdBlur = pcall(function()
      return make("BlurEffect", {
        Name = "NovaPremiumUI_Blur",
        Size = 0,
        Parent = Lighting,
      })
    end)
    if okBlur then
      blurEffect = createdBlur
      tween(blurEffect, theme.Anim.Slow, {Size = blurSize}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
  end

  local shell = make("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(0, sz.X, 0, sz.Y),
    Position = UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2),
    Parent = gui,
  })

  local shadow = make("Frame", {
    Size = UDim2.new(1, 18, 1, 18),
    Position = UDim2.new(0, -9, 0, 10),
    BackgroundColor3 = theme.Colors.Shadow,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0,
    Parent = shell,
  })
  corner(shadow, theme.Radius + 6)

  local root = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = theme.Colors.BgA,
    BackgroundTransparency = 0.01,
    BorderSizePixel = 0,
    Parent = shell,
  })
  local rootScale = make("UIScale", {Scale = 0.965, Parent = root})
  corner(root, theme.Radius + 2)
  local rootStroke = stroke(root, theme.Colors.Stroke, 1, 0.28)
  local rootGradient = gradient(root, theme.Colors.BgA, theme.Colors.BgB, 16)

  local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = theme.Colors.Sidebar,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    Parent = root,
  })
  corner(top, theme.Radius + 2)
  local topGradient = gradient(top, theme.Colors.Sidebar, theme.Colors.Sidebar2 or theme.Colors.BgB, 0)
  local topFill = make("Frame", {Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), BackgroundColor3 = theme.Colors.Sidebar2 or theme.Colors.Sidebar, BorderSizePixel = 0, Parent = top})
  local topDivider = make("Frame", {Size = UDim2.new(1, -32, 0, 1), Position = UDim2.new(0, 16, 1, -1), BackgroundColor3 = theme.Colors.StrokeSoft or theme.Colors.Stroke, BackgroundTransparency = 0.58, BorderSizePixel = 0, Parent = top})

  local logoBadge = createNovaMark(top, theme, 46, logoSource, logoRectOffset, logoRectSize)
  logoBadge.Position = UDim2.new(0, 16, 0, 12)

  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -280, 0, 28),
    Position = UDim2.new(0, 74, 0, 11),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Colors.Text,
    Text = tostring(opts.Title or opts.Name or "Nova Premium UI"),
    Parent = top,
  })
  
  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -318, 0, 18),
    Position = UDim2.new(0, 76, 0, 40),
    Font = theme.Font,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Colors.TextDim,
    Text = tostring(opts.Subtitle or opts.LoadingSubtitle or "Modern control surface"),
    Parent = top,
  })
  
  local statusPill = make("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Size = UDim2.new(0, 94, 0, 24),
    Position = UDim2.new(1, -88, 0.5, 0),
    BackgroundColor3 = theme.Colors.Input,
    BackgroundTransparency = 0.34,
    BorderSizePixel = 0,
    Parent = top,
  })
  corner(statusPill, 999)
  local statusStroke = stroke(statusPill, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.46)
  local statusGradient = gradient(statusPill, theme.Colors.Input, theme.Colors.SurfaceGlass or theme.Colors.Surface2, 0)
  local statusDot = make("Frame", {
    Size = UDim2.new(0, 6, 0, 6),
    Position = UDim2.new(0, 11, 0.5, -3),
    BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
    BorderSizePixel = 0,
    Parent = statusPill,
  })
  corner(statusDot, 999)
  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.new(0, 23, 0, 0),
    Font = theme.Font,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Colors.TextDim,
    Text = "Ready",
    Parent = statusPill,
  })
  
  local closeBtn = make("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = theme.Colors.Input,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Text = "X",
    TextColor3 = theme.Colors.Accent2 or theme.Colors.Text,
    AutoButtonColor = false,
    Parent = top,
  })
  corner(closeBtn, theme.Radius - 3)
  stroke(closeBtn, theme.Colors.Stroke, 1, 0.42)
  closeBtn.MouseEnter:Connect(function() tween(closeBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.AccentSoft or theme.Colors.Surface2}) end)
  closeBtn.MouseLeave:Connect(function() tween(closeBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Surface3 or theme.Colors.Surface2}) end)
  
  local settingsBtn = make("TextButton", {
    Name = "NovaSettingsButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -50, 0.5, 0),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = theme.Colors.Input,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Text = "...",
    TextColor3 = theme.Colors.Accent2 or theme.Colors.Text,
    AutoButtonColor = false,
    Parent = top,
  })
  corner(settingsBtn, theme.Radius - 3)
  local settingsBtnStroke = stroke(settingsBtn, theme.Colors.Stroke, 1, 0.42)
  settingsBtn.MouseEnter:Connect(function() tween(settingsBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2}) end)
  settingsBtn.MouseLeave:Connect(function() tween(settingsBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Input}) end)
  
  local island = make("Frame", {
    Name = "DragIsland",
    AnchorPoint = Vector2.new(0.5, 0),
    Size = UDim2.new(0, 138, 0, 3),
    Position = UDim2.new(0.5, 0, 1, 7),
    BackgroundColor3 = theme.Colors.AccentSoft or theme.Colors.Surface3,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    Parent = root,
  })
  corner(island, theme.Radius)
  local islandStroke = stroke(island, theme.Colors.Accent2 or theme.Colors.Accent, 1, 0.7)
  local islandGradient = gradient(island, theme.Colors.Accent, theme.Colors.Accent2 or theme.Colors.Accent, 0)
  local sidebar = make("Frame", {
    Size = UDim2.new(0, 190, 1, -94),
    Position = UDim2.new(0, 12, 0, 82),
    BackgroundColor3 = theme.Colors.Sidebar,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = root,
  })
  corner(sidebar, theme.Radius)
  local sidebarStroke = stroke(sidebar, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
  local sidebarGradient = gradient(sidebar, theme.Colors.Sidebar, theme.Colors.Sidebar2 or theme.Colors.BgB, 70)

  local tabList = make("ScrollingFrame", {
    Size = UDim2.new(1, -12, 1, -12),
    Position = UDim2.new(0, 6, 0, 6),
    BackgroundTransparency = 1,
    ScrollBarThickness = 3,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = sidebar,
  })
  attachSmoothScroll(tabList, theme, bindConnection)
  local tabLayout = make("UIListLayout", {Padding = UDim.new(0, 6), Parent = tabList})
  bindConnection(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
  end))

  local content = make("Frame", {
    Size = UDim2.new(1, -218, 1, -94),
    Position = UDim2.new(0, 206, 0, 82),
    BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Parent = root,
  })
  corner(content, theme.Radius)
  local contentStroke = stroke(content, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.46)
  local contentGradient = gradient(content, theme.Colors.Surface, theme.Colors.Input, 10)

  local search = make("TextBox", {
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundColor3 = theme.Colors.Input,
    BorderSizePixel = 0,
    Font = theme.Font,
    TextSize = 12,
    TextColor3 = theme.Colors.Text,
    PlaceholderColor3 = theme.Colors.TextDim,
    PlaceholderText = "Search...",
    Text = "",
    ClearTextOnFocus = false,
    Parent = content,
  })
  corner(search, theme.Radius - 2)
  local searchStroke = stroke(search, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
  search.Focused:Connect(function()
    tween(searchStroke, theme.Anim.Fast, {Transparency = 0.02, Color = theme.Colors.Accent2 or theme.Colors.Accent})
  end)
  search.FocusLost:Connect(function()
    tween(searchStroke, theme.Anim.Fast, {Transparency = 0.22, Color = theme.Colors.StrokeSoft or theme.Colors.Stroke})
  end)

  local pages = make("Frame", {
    Size = UDim2.new(1, -24, 1, -58),
    Position = UDim2.new(0, 12, 0, 50),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = content,
  })
  local pageTransition = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 650,
    Parent = pages,
  })
  local transitionToken = 0
  
  local function setGradientColors(g, a, b)
    if not g then return end
    pcall(function()
      g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b),
      })
    end)
  end
  
  local function colorClose(a, b)
    if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then return false end
    return math.abs(a.R - b.R) < 0.003 and math.abs(a.G - b.G) < 0.003 and math.abs(a.B - b.B) < 0.003
  end
  
  local function repaintTheme(oldColors)
    oldColors = oldColors or theme.Colors
    
    root.BackgroundColor3 = theme.Colors.BgA
    top.BackgroundColor3 = theme.Colors.Sidebar
    topFill.BackgroundColor3 = theme.Colors.Sidebar2 or theme.Colors.Sidebar
    topDivider.BackgroundColor3 = theme.Colors.StrokeSoft or theme.Colors.Stroke
    sidebar.BackgroundColor3 = theme.Colors.Sidebar
    content.BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface
    search.BackgroundColor3 = theme.Colors.Input
    statusPill.BackgroundColor3 = theme.Colors.Input
    statusDot.BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent
    closeBtn.BackgroundColor3 = theme.Colors.Input
    closeBtn.TextColor3 = theme.Colors.Accent2 or theme.Colors.Text
    settingsBtn.BackgroundColor3 = theme.Colors.Input
    settingsBtn.TextColor3 = theme.Colors.Accent2 or theme.Colors.Text
    island.BackgroundColor3 = theme.Colors.AccentSoft or theme.Colors.Surface3
    pageTransition.BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface
    
    rootStroke.Color = theme.Colors.Stroke
    statusStroke.Color = theme.Colors.StrokeSoft or theme.Colors.Stroke
    settingsBtnStroke.Color = theme.Colors.Stroke
    islandStroke.Color = theme.Colors.Accent2 or theme.Colors.Accent
    sidebarStroke.Color = theme.Colors.StrokeSoft or theme.Colors.Stroke
    contentStroke.Color = theme.Colors.StrokeSoft or theme.Colors.Stroke
    searchStroke.Color = theme.Colors.StrokeSoft or theme.Colors.Stroke
    
    setGradientColors(rootGradient, theme.Colors.BgA, theme.Colors.BgB)
    setGradientColors(topGradient, theme.Colors.Sidebar, theme.Colors.Sidebar2 or theme.Colors.BgB)
    setGradientColors(statusGradient, theme.Colors.Input, theme.Colors.SurfaceGlass or theme.Colors.Surface2)
    setGradientColors(islandGradient, theme.Colors.Accent, theme.Colors.Accent2 or theme.Colors.Accent)
    setGradientColors(sidebarGradient, theme.Colors.Sidebar, theme.Colors.Sidebar2 or theme.Colors.BgB)
    setGradientColors(contentGradient, theme.Colors.Surface, theme.Colors.Input)
    
    local colorMaps = {
      BackgroundColor3 = {
        {oldColors.Input, theme.Colors.Input},
        {oldColors.Surface, theme.Colors.Surface},
        {oldColors.SurfaceGlass, theme.Colors.SurfaceGlass or theme.Colors.Surface},
        {oldColors.Surface2, theme.Colors.Surface2},
        {oldColors.Surface3, theme.Colors.Surface3},
        {oldColors.Sidebar, theme.Colors.Sidebar},
        {oldColors.Sidebar2, theme.Colors.Sidebar2 or theme.Colors.Sidebar},
        {oldColors.Hover, theme.Colors.Hover or theme.Colors.Surface2},
        {oldColors.Active, theme.Colors.Active or theme.Colors.Surface3},
        {oldColors.Accent, theme.Colors.Accent},
        {oldColors.Accent2, theme.Colors.Accent2 or theme.Colors.Accent},
        {oldColors.Accent3, theme.Colors.Accent3 or theme.Colors.Accent},
        {oldColors.AccentSoft, theme.Colors.AccentSoft or theme.Colors.Surface3},
        {oldColors.ExpandableSurface, theme.Colors.ExpandableSurface or theme.Colors.SurfaceGlass},
        {oldColors.ExpandableSurfaceOpen, theme.Colors.ExpandableSurfaceOpen or theme.Colors.Surface2},
        {oldColors.ExpandableTitle, theme.Colors.ExpandableTitle or theme.Colors.Input},
        {oldColors.ExpandableTitleOpen, theme.Colors.ExpandableTitleOpen or theme.Colors.Active},
        {oldColors.NestedSurface, theme.Colors.NestedSurface or theme.Colors.Input},
        {oldColors.NestedSurface2, theme.Colors.NestedSurface2 or theme.Colors.Surface},
      },
      TextColor3 = {
        {oldColors.Text, theme.Colors.Text},
        {oldColors.TextDim, theme.Colors.TextDim},
        {oldColors.TextMuted, theme.Colors.TextMuted or theme.Colors.TextDim},
        {oldColors.Accent, theme.Colors.Accent},
        {oldColors.Accent2, theme.Colors.Accent2 or theme.Colors.Accent},
      },
      PlaceholderColor3 = {
        {oldColors.TextDim, theme.Colors.TextDim},
        {oldColors.TextMuted, theme.Colors.TextMuted or theme.Colors.TextDim},
      },
      Color = {
        {oldColors.Stroke, theme.Colors.Stroke},
        {oldColors.StrokeSoft, theme.Colors.StrokeSoft or theme.Colors.Stroke},
        {oldColors.NestedStroke, theme.Colors.NestedStroke or theme.Colors.StrokeSoft or theme.Colors.Stroke},
        {oldColors.Accent, theme.Colors.Accent},
        {oldColors.Accent2, theme.Colors.Accent2 or theme.Colors.Accent},
      },
    }
    
    for _, obj in ipairs(gui:GetDescendants()) do
      if obj:IsA("GuiObject") then
        local maps = colorMaps.BackgroundColor3
        for _, map in ipairs(maps) do
          if map[1] and map[2] and colorClose(obj.BackgroundColor3, map[1]) then
            pcall(function() obj.BackgroundColor3 = map[2] end)
            break
          end
        end
      end
      if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function() obj.Font = theme.Font end)
        for prop, maps in pairs({TextColor3 = colorMaps.TextColor3, PlaceholderColor3 = colorMaps.PlaceholderColor3}) do
          pcall(function()
            local current = obj[prop]
            for _, map in ipairs(maps) do
              if map[1] and map[2] and colorClose(current, map[1]) then
                obj[prop] = map[2]
                break
              end
            end
          end)
        end
      elseif obj:IsA("UIStroke") then
        for _, map in ipairs(colorMaps.Color) do
          if map[1] and map[2] and colorClose(obj.Color, map[1]) then
            pcall(function() obj.Color = map[2] end)
            break
          end
        end
      end
    end
  end
  
  function window:ApplyThemePatch(patch)
    if type(patch) ~= "table" then return end
    local oldColors = copy(theme.Colors)
    if type(patch.Colors) == "table" then
      for key, value in pairs(patch.Colors) do
        if typeof(value) == "Color3" then
          theme.Colors[key] = value
        end
      end
    end
    if typeof(patch.Font) == "EnumItem" then
      theme.Font = patch.Font
    end
    if type(patch.BlurSize) == "number" then
      theme.Blur = theme.Blur or {}
      theme.Blur.Size = math.clamp(patch.BlurSize, 0, 16)
      blurSize = theme.Blur.Size
      if blurEffect and blurEffect.Parent then
        tween(blurEffect, theme.Anim.Fast, {Size = blurSize})
      end
    end
    if type(patch.ShadowTransparency) == "number" then
      tween(shadow, theme.Anim.Fast, {BackgroundTransparency = math.clamp(patch.ShadowTransparency, 0, 1)})
    end
    repaintTheme(oldColors)
  end
  
  local settingsPanel = make("Frame", {
    Name = "NovaSettingsPanel",
    AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.new(0, 248, 0, 0),
    Position = UDim2.new(1, -14, 0, 76),
    BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface2,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 760,
    Parent = root,
  })
  corner(settingsPanel, theme.Radius)
  stroke(settingsPanel, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.3)
  gradient(settingsPanel, theme.Colors.Surface2, theme.Colors.Input, 20)
  local settingsScale = make("UIScale", {Scale = 0.97, Parent = settingsPanel})
  local settingsPadding = make("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    Parent = settingsPanel,
  })
  local _settingsPadding = settingsPadding
  local settingsLayout = make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    Parent = settingsPanel,
  })
  
  make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 22),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = theme.Colors.Text,
    Text = "Settings",
    ZIndex = 761,
    LayoutOrder = 1,
    Parent = settingsPanel,
  })
  
  local settingGroups = {}
  local activeSettingButtons = {}
  local function setGroupActive(groupKey, activeButton)
    local group = settingGroups[groupKey]
    if not group then return end
    activeSettingButtons[groupKey] = activeButton
    for _, button in ipairs(group) do
      local active = button == activeButton
      tween(button, theme.Anim.Fast, {
        BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Input,
        TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
      })
    end
  end
  
  local function settingRow(groupKey, label, options, onPick, order)
    make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 15),
      Font = theme.Font,
      TextSize = 11,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextColor3 = theme.Colors.TextDim,
      Text = tostring(label),
      ZIndex = 761,
      LayoutOrder = order,
      Parent = settingsPanel,
    })
    local row = make("Frame", {
      Size = UDim2.new(1, 0, 0, 30),
      BackgroundTransparency = 1,
      ZIndex = 761,
      LayoutOrder = order + 1,
      Parent = settingsPanel,
    })
    make("UIListLayout", {
      FillDirection = Enum.FillDirection.Horizontal,
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 6),
      Parent = row,
    })
    settingGroups[groupKey] = {}
    local count = math.max(1, #options)
    for index, option in ipairs(options) do
      local button = make("TextButton", {
        Size = UDim2.new(1 / count, -math.ceil((count - 1) * 6 / count), 1, 0),
        BackgroundColor3 = index == 1 and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Input,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = theme.Font,
        TextSize = 11,
        TextColor3 = index == 1 and theme.Colors.Text or theme.Colors.TextDim,
        Text = tostring(option.Label or option.Name or "Option"),
        ZIndex = 762,
        LayoutOrder = index,
        Parent = row,
      })
      corner(button, theme.Radius - 5)
      stroke(button, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
      table.insert(settingGroups[groupKey], button)
      if index == 1 then
        activeSettingButtons[groupKey] = button
      end
      bindConnection(button.MouseEnter:Connect(function()
        tween(button, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2})
      end))
      bindConnection(button.MouseLeave:Connect(function()
        local active = activeSettingButtons[groupKey] == button
        tween(button, theme.Anim.Fast, {BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Input})
      end))
      bindConnection(button.MouseButton1Click:Connect(function()
        setGroupActive(groupKey, button)
        tween(button, theme.Anim.Fast, {Size = UDim2.new(1 / count, -math.ceil((count - 1) * 6 / count), 1, -2)})
        task.delay(theme.Anim.Fast, function()
          if button and button.Parent then
            tween(button, theme.Anim.Fast, {Size = UDim2.new(1 / count, -math.ceil((count - 1) * 6 / count), 1, 0)})
          end
        end)
        safeCallback(onPick, option)
      end))
    end
  end
  
  settingRow("accent", "Accent", {
    {Label = "Slate", Colors = {Accent = Color3.fromRGB(104, 119, 140), Accent2 = Color3.fromRGB(137, 149, 165), Accent3 = Color3.fromRGB(112, 123, 138), AccentSoft = Color3.fromRGB(34, 40, 51), Stroke = Color3.fromRGB(66, 74, 88), Active = Color3.fromRGB(39, 47, 60), Hover = Color3.fromRGB(30, 35, 44)}},
    {Label = "Ash", Colors = {Accent = Color3.fromRGB(126, 134, 146), Accent2 = Color3.fromRGB(158, 166, 178), Accent3 = Color3.fromRGB(118, 127, 140), AccentSoft = Color3.fromRGB(38, 42, 50), Stroke = Color3.fromRGB(70, 76, 86), Active = Color3.fromRGB(44, 49, 59), Hover = Color3.fromRGB(32, 36, 43)}},
    {Label = "Bluegray", Colors = {Accent = Color3.fromRGB(92, 111, 137), Accent2 = Color3.fromRGB(124, 139, 158), Accent3 = Color3.fromRGB(104, 119, 140), AccentSoft = Color3.fromRGB(31, 39, 51), Stroke = Color3.fromRGB(58, 70, 88), Active = Color3.fromRGB(35, 45, 60), Hover = Color3.fromRGB(28, 34, 44)}},
  }, function(option)
    window:ApplyThemePatch({Colors = option.Colors})
  end, 10)
  
  settingRow("background", "Background", {
    {Label = "Graphite", Colors = {BgA = Color3.fromRGB(9, 10, 13), BgB = Color3.fromRGB(14, 16, 21), Surface = Color3.fromRGB(18, 21, 27), SurfaceGlass = Color3.fromRGB(20, 24, 31), Surface2 = Color3.fromRGB(23, 28, 36), Surface3 = Color3.fromRGB(30, 37, 48), Sidebar = Color3.fromRGB(14, 17, 22), Sidebar2 = Color3.fromRGB(18, 22, 29), Input = Color3.fromRGB(13, 16, 22), ExpandableSurface = Color3.fromRGB(23, 28, 36), ExpandableSurfaceOpen = Color3.fromRGB(28, 36, 47), ExpandableTitle = Color3.fromRGB(21, 25, 32), ExpandableTitleOpen = Color3.fromRGB(31, 42, 55), NestedSurface = Color3.fromRGB(13, 16, 21), NestedSurface2 = Color3.fromRGB(20, 24, 31), StrokeSoft = Color3.fromRGB(40, 48, 60), NestedStroke = Color3.fromRGB(43, 50, 62)}},
    {Label = "Carbon", Colors = {BgA = Color3.fromRGB(7, 8, 10), BgB = Color3.fromRGB(12, 13, 16), Surface = Color3.fromRGB(16, 18, 22), SurfaceGlass = Color3.fromRGB(18, 21, 26), Surface2 = Color3.fromRGB(20, 24, 30), Surface3 = Color3.fromRGB(27, 32, 40), Sidebar = Color3.fromRGB(12, 14, 18), Sidebar2 = Color3.fromRGB(16, 19, 24), Input = Color3.fromRGB(11, 13, 17), ExpandableSurface = Color3.fromRGB(21, 25, 32), ExpandableSurfaceOpen = Color3.fromRGB(26, 32, 41), ExpandableTitle = Color3.fromRGB(18, 22, 28), ExpandableTitleOpen = Color3.fromRGB(29, 37, 48), NestedSurface = Color3.fromRGB(10, 12, 16), NestedSurface2 = Color3.fromRGB(17, 20, 26), StrokeSoft = Color3.fromRGB(36, 42, 52), NestedStroke = Color3.fromRGB(39, 45, 55)}},
    {Label = "Neutral", Colors = {BgA = Color3.fromRGB(12, 12, 13), BgB = Color3.fromRGB(17, 18, 20), Surface = Color3.fromRGB(22, 23, 26), SurfaceGlass = Color3.fromRGB(24, 26, 30), Surface2 = Color3.fromRGB(28, 30, 34), Surface3 = Color3.fromRGB(36, 39, 45), Sidebar = Color3.fromRGB(16, 17, 20), Sidebar2 = Color3.fromRGB(21, 23, 27), Input = Color3.fromRGB(16, 17, 20), ExpandableSurface = Color3.fromRGB(28, 31, 36), ExpandableSurfaceOpen = Color3.fromRGB(36, 41, 48), ExpandableTitle = Color3.fromRGB(24, 27, 32), ExpandableTitleOpen = Color3.fromRGB(39, 45, 53), NestedSurface = Color3.fromRGB(15, 16, 19), NestedSurface2 = Color3.fromRGB(24, 26, 30), StrokeSoft = Color3.fromRGB(45, 50, 58), NestedStroke = Color3.fromRGB(48, 54, 63)}},
  }, function(option)
    window:ApplyThemePatch({Colors = option.Colors})
  end, 20)
  
  settingRow("glow", "Glow", {
    {Label = "Low", BlurSize = 2, ShadowTransparency = 0.86},
    {Label = "Mid", BlurSize = 4, ShadowTransparency = 0.8},
    {Label = "High", BlurSize = 7, ShadowTransparency = 0.72},
  }, function(option)
    window:ApplyThemePatch({BlurSize = option.BlurSize, ShadowTransparency = option.ShadowTransparency})
  end, 30)
  
  settingRow("font", "Font", {
    {Label = "Gotham", Font = Enum.Font.GothamMedium},
    {Label = "Mono", Font = Enum.Font.Code},
    {Label = "Soft", Font = Enum.Font.SourceSans},
  }, function(option)
    window:ApplyThemePatch({Font = option.Font})
  end, 40)
  
  local settingsOpen = false
  local settingsHeight = 292
  local function setSettingsOpen(open)
    settingsOpen = open and true or false
    if settingsOpen then
      settingsPanel.Visible = true
      settingsPanel.BackgroundTransparency = 1
      settingsScale.Scale = 0.97
    end
    tween(settingsPanel, theme.Anim.Normal, {
      Size = settingsOpen and UDim2.new(0, 248, 0, settingsHeight) or UDim2.new(0, 248, 0, 0),
      BackgroundTransparency = settingsOpen and 0.06 or 1,
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(settingsScale, theme.Anim.Normal, {Scale = settingsOpen and 1 or 0.97}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(settingsBtn, theme.Anim.Normal, {BackgroundTransparency = settingsOpen and 0.02 or 0.12}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    task.delay(theme.Anim.Normal + 0.04, function()
      if not settingsOpen and settingsPanel then
        settingsPanel.Visible = false
      end
    end)
  end
  
  function window:SetSettingsOpen(open)
    setSettingsOpen(open)
  end
  
  bindConnection(settingsBtn.MouseButton1Click:Connect(function()
    setSettingsOpen(not settingsOpen)
  end))

  function window:_Switch(tab)
    if self._activeTab == tab then
      if type(tab.OnShow) == "function" then
        task.defer(function()
          pcall(tab.OnShow, tab)
        end)
      end
      return
    end
    local prev = self._activeTab
    transitionToken = transitionToken + 1
    local localTransitionToken = transitionToken
    pageTransition.Visible = true
    pageTransition.BackgroundTransparency = 1
    tween(pageTransition, theme.Anim.Fast, {BackgroundTransparency = 0.68})
    task.delay(theme.Anim.Fast + 0.02, function()
      if localTransitionToken == transitionToken and pageTransition then
        tween(pageTransition, theme.Anim.Normal, {BackgroundTransparency = 1})
        task.delay(theme.Anim.Normal + 0.03, function()
          if localTransitionToken == transitionToken and pageTransition then
            pageTransition.Visible = false
          end
        end)
      end
    end)
    self._activeTab = tab
    if search and search.Text ~= "" then
      search.Text = ""
    end
    if prev and prev.Page and prev.Page.Visible then
      tween(prev.Page, theme.Anim.Normal, {Position = UDim2.new(0, -24, 0, 0)})
      if prev.PageScale then
        tween(prev.PageScale, theme.Anim.Normal, {Scale = 0.985}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      end
      task.delay(theme.Anim.Normal, function() if prev.Page then prev.Page.Visible = false end end)
    end
    tab.Page.Position = UDim2.new(0, 24, 0, 0)
    tab.Page.Visible = true
    if tab.PageScale then
      tab.PageScale.Scale = 0.985
      tween(tab.PageScale, theme.Anim.Normal, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    tween(tab.Page, theme.Anim.Normal, {Position = UDim2.new(0, 0, 0, 0)})
    for _, t in ipairs(self._tabs) do
      local active = t == tab
      tween(t.Button, theme.Anim.Fast, {
        BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Input,
        BackgroundTransparency = active and 0.08 or 0.36,
      })
      if t.Label then
        tween(t.Label, theme.Anim.Fast, {
          TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
        })
      end
      if t.Accent then
        tween(t.Accent, theme.Anim.Fast, {
          BackgroundTransparency = active and 0.05 or 0.82,
          Size = active and UDim2.new(0, 3, 0, 22) or UDim2.new(0, 2, 0, 12),
        })
      end
    end
    if type(tab.OnShow) == "function" then
      task.defer(function()
        pcall(tab.OnShow, tab)
      end)
    end
  end

  function window:_ApplySearch(q)
    q = string.lower(tostring(q or ""))
    for _, tab in ipairs(self._tabs) do
      local active = tab == self._activeTab
      for _, c in ipairs(tab.Controls) do
        if active and not c._nested then
          local token = tostring(c._token or "")
          local m = (q == "") or (string.find(token, q, 1, true) ~= nil)
          c:SetVisible(m)
        elseif not c._nested then
          c:SetVisible(true)
        end
      end
    end
  end

  bindConnection(search:GetPropertyChangedSignal("Text"):Connect(function()
    window:_ApplySearch(search.Text)
  end))

  function window:Confirm(opts)
    opts = opts or {}
    local title = tostring(opts.Title or "Confirm")
    local contentText = tostring(opts.Content or opts.Text or "Are you sure?")
    local confirmText = tostring(opts.ConfirmText or "Confirm")
    local cancelText = tostring(opts.CancelText or "Cancel")
    local done = false
    
    local overlay = make("Frame", {
      Name = "NovaConfirm",
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundColor3 = Color3.new(0, 0, 0),
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      ZIndex = 900,
      Parent = gui,
    })
    
    local card = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, 390, 0, 170),
      Position = UDim2.new(0.5, 0, 0.5, 10),
      BackgroundColor3 = theme.Colors.Surface2,
      BackgroundTransparency = 0.04,
      BorderSizePixel = 0,
      ZIndex = 901,
      Parent = overlay,
    })
    corner(card, theme.Radius)
    stroke(card, theme.Colors.Stroke, 1, 0.12)
    
    make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -32, 0, 28),
      Position = UDim2.new(0, 16, 0, 14),
      Font = Enum.Font.GothamBold,
      TextSize = 18,
      TextColor3 = theme.Colors.Text,
      TextXAlignment = Enum.TextXAlignment.Left,
      Text = title,
      ZIndex = 902,
      Parent = card,
    })
    
    make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -32, 0, 58),
      Position = UDim2.new(0, 16, 0, 48),
      Font = theme.Font,
      TextSize = 13,
      TextColor3 = theme.Colors.TextDim,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      TextWrapped = true,
      Text = contentText,
      ZIndex = 902,
      Parent = card,
    })
    
    local cancelBtn = make("TextButton", {
      Size = UDim2.new(0.5, -22, 0, 36),
      Position = UDim2.new(0, 16, 1, -52),
      BackgroundColor3 = theme.Colors.Input,
      BorderSizePixel = 0,
      AutoButtonColor = false,
      Font = theme.Font,
      TextSize = 13,
      TextColor3 = theme.Colors.Text,
      Text = cancelText,
      ZIndex = 902,
      Parent = card,
    })
    corner(cancelBtn, theme.Radius - 4)
    stroke(cancelBtn, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.28)
    
    local confirmBtn = make("TextButton", {
      Size = UDim2.new(0.5, -22, 0, 36),
      Position = UDim2.new(0.5, 6, 1, -52),
      BackgroundColor3 = theme.Colors.Accent,
      BorderSizePixel = 0,
      AutoButtonColor = false,
      Font = Enum.Font.GothamBold,
      TextSize = 13,
      TextColor3 = Color3.new(1, 1, 1),
      Text = confirmText,
      ZIndex = 902,
      Parent = card,
    })
    corner(confirmBtn, theme.Radius - 4)
    
    local function close(result)
      if done then return end
      done = true
      tween(overlay, theme.Anim.Fast, {BackgroundTransparency = 1})
      tween(card, theme.Anim.Fast, {Position = UDim2.new(0.5, 0, 0.5, 10), BackgroundTransparency = 1})
      task.delay(theme.Anim.Fast + 0.04, function()
        if overlay and overlay.Parent then
          overlay:Destroy()
        end
      end)
      if result then
        safeCallback(opts.ConfirmCallback)
      else
        safeCallback(opts.CancelCallback)
      end
      safeCallback(opts.Callback, result)
    end
    
    cancelBtn.MouseEnter:Connect(function() tween(cancelBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Surface}) end)
    cancelBtn.MouseLeave:Connect(function() tween(cancelBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Input}) end)
    confirmBtn.MouseEnter:Connect(function() tween(confirmBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent}) end)
    confirmBtn.MouseLeave:Connect(function() tween(confirmBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Accent}) end)
    cancelBtn.MouseButton1Click:Connect(function() close(false) end)
    confirmBtn.MouseButton1Click:Connect(function() close(true) end)
    
    tween(overlay, theme.Anim.Fast, {BackgroundTransparency = 0.45})
    tween(card, theme.Anim.Normal, {Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    return {
      Frame = overlay,
      Close = function(_, result)
        close(result == true)
      end,
    }
  end

  function window:CreateTab(name)
    local tab = {Name = tostring(name or ("Tab " .. tostring(#self._tabs + 1))), Controls = {}}
    local b = make("TextButton", {
      Size = UDim2.new(1, 0, 0, 34),
      BackgroundColor3 = theme.Colors.Input,
      BackgroundTransparency = 0.36,
      BorderSizePixel = 0,
      Text = "",
      TextXAlignment = Enum.TextXAlignment.Left,
      Font = theme.Font,
      TextSize = 12,
      TextColor3 = theme.Colors.TextDim,
      AutoButtonColor = false,
      Parent = tabList,
    })
    corner(b, theme.Radius - 2)
    stroke(b, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.64)
    gradient(b, theme.Colors.Input, theme.Colors.Surface, 0)
    local accent = make("Frame", {
      AnchorPoint = Vector2.new(0, 0.5),
      Size = UDim2.new(0, 2, 0, 12),
      Position = UDim2.new(0, 10, 0.5, 0),
      BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      BackgroundTransparency = 0.84,
      BorderSizePixel = 0,
      Parent = b,
    })
    corner(accent, 999)
    local tabLabel = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -38, 1, 0),
      Position = UDim2.new(0, 30, 0, 0),
      Font = theme.Font,
      TextSize = 12,
      Text = tab.Name,
      TextColor3 = theme.Colors.TextDim,
      TextXAlignment = Enum.TextXAlignment.Left,
      Parent = b,
    })
    b.MouseEnter:Connect(function()
      if window._activeTab ~= tab then
        tween(b, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2, BackgroundTransparency = 0.2})
      end
    end)
    b.MouseLeave:Connect(function()
      if window._activeTab ~= tab then
        tween(b, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Input, BackgroundTransparency = 0.36})
      end
    end)
    b.MouseButton1Down:Connect(function() addRipple(b, theme) end)
    b.MouseButton1Click:Connect(function() self:_Switch(tab) end)

    local p = make("ScrollingFrame", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      ScrollBarThickness = 3,
      CanvasSize = UDim2.new(0, 0, 0, 0),
      Visible = false,
      Parent = pages,
    })
    local pageScale = make("UIScale", {Scale = 1, Parent = p})
    attachSmoothScroll(p, theme, bindConnection)
    make("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), Parent = p})
      local layout = make("UIListLayout", {Padding = UDim.new(0, 7), Parent = p})
      bindConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 82)
      end))

      tab.Button = b
      tab.Page = p
      tab.PageScale = pageScale
      tab.Accent = accent
      tab.Label = tabLabel

    local function reg(ctrl)
      table.insert(tab.Controls, ctrl)
      return ctrl
    end
    
    local compactBindRow = nil
    local compactBindSlot = 0
    local compactBindVisible = setmetatable({}, {__mode = "k"})
    local function acquireCompactBindRow()
      if not compactBindRow or compactBindSlot >= 2 or not compactBindRow.Parent then
        compactBindRow = makeControlBase(p, theme, 44)
        compactBindSlot = 0
        compactBindVisible[compactBindRow] = {true, true}
        local divider = make("Frame", {
          AnchorPoint = Vector2.new(0.5, 0.5),
          Size = UDim2.new(0, 1, 1, -16),
          Position = UDim2.new(0.5, 0, 0.5, 0),
          BackgroundColor3 = theme.Colors.StrokeSoft or theme.Colors.Stroke,
          BackgroundTransparency = 0.32,
          BorderSizePixel = 0,
          Parent = compactBindRow,
        })
        local _divider = divider
      end
      compactBindSlot = compactBindSlot + 1
      return compactBindRow, compactBindSlot
    end
    
    local function setCompactBindVisible(row, slot, visible)
      local state = compactBindVisible[row]
      if not state then
        row.Visible = visible == true
        return
      end
      state[slot] = visible == true
      row.Visible = state[1] or state[2]
    end

    function tab:CreateSection(s)
      local f = make("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = theme.Colors.Input, BackgroundTransparency = 0.72, BorderSizePixel = 0, Parent = p})
      corner(f, theme.Radius - 5)
      stroke(f, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.78)
      gradient(f, theme.Colors.Input, theme.Colors.Surface, 0)
      local rail = make("Frame", {
        Size = UDim2.new(0, 3, 0, 14),
        Position = UDim2.new(0, 10, 0.5, -7),
        BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = f,
      })
      corner(rail, 999)
      make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 22, 0, 0), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = theme.Colors.TextMuted or theme.Colors.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(tostring(s or "Section")), Parent = f})
      return reg({Frame = f, _token = string.lower(tostring(s or "")), SetVisible = function(_, v) f.Visible = v end})
    end
    
    function tab:CreateLabel(textOrCfg)
      local text = type(textOrCfg) == "table" and textOrCfg.Text or textOrCfg
      local f = make("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = p})
      local lbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = theme.Font,
        TextSize = 13,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(text or ""),
        Parent = f,
      })
      return reg({
        Frame = f,
        _token = string.lower(tostring(text or "")),
        SetVisible = function(_, v) f.Visible = v end,
        Set = function(_, v) lbl.Text = tostring(v or "") end,
        SetValue = function(_, v) lbl.Text = tostring(v or "") end,
      })
    end
    
    function tab:CreateParagraph(cfg)
      cfg = cfg or {}
      local title = tostring(cfg.Title or cfg.Name or "Paragraph")
      local contentText = tostring(cfg.Content or cfg.Text or "")
      local f = makeControlBase(p, theme, 58)
      local titleLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 0, 20),
        Position = UDim2.new(0, 8, 0, 4),
        Font = theme.Font,
        TextSize = 13,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Parent = f,
      })
      local contentLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 0, 30),
        Position = UDim2.new(0, 8, 0, 24),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = contentText,
        Parent = f,
      })
      return reg({
        Frame = f,
        _token = string.lower(title .. " " .. contentText),
        SetVisible = function(_, v) f.Visible = v end,
        Set = function(_, v)
          contentLbl.Text = tostring(v or "")
        end,
        SetValue = function(_, v)
          contentLbl.Text = tostring(v or "")
        end,
        SetTitle = function(_, v)
          titleLbl.Text = tostring(v or "")
        end,
      })
    end

    function tab:CreateButton(cfg)
      cfg = cfg or {}
      local f, glow = makeControlBase(p, theme, 40)
      local btn = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 7, 0, 0), AutoButtonColor = false, Text = "  " .. tostring(cfg.Name or "Button"), TextXAlignment = Enum.TextXAlignment.Left, Font = theme.Font, TextSize = 13, TextColor3 = theme.Colors.Text, Parent = f})
      local dot = make("Frame", {Size = UDim2.new(0, 4, 0, 18), Position = UDim2.new(0, 8, 0.5, -9), BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent, BackgroundTransparency = 0.42, BorderSizePixel = 0, Parent = f})
      corner(dot, 999)
      local scale = make("UIScale", {Scale = 1, Parent = btn})
      btn.MouseEnter:Connect(function()
        tween(f, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2})
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.83})
        tween(dot, theme.Anim.Fast, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 4, 0, 24)})
      end)
      btn.MouseEnter:Connect(function() tween(scale, theme.Anim.Fast, {Scale = 1.015}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) end)
      btn.MouseLeave:Connect(function()
        tween(f, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface})
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.93})
        tween(dot, theme.Anim.Fast, {BackgroundTransparency = 0.42, Size = UDim2.new(0, 4, 0, 18)})
        tween(scale, theme.Anim.Fast, {Scale = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
      end)
      btn.MouseButton1Down:Connect(function() addRipple(btn, theme) end)
      btn.MouseButton1Click:Connect(function()
        if type(cfg.Callback) == "function" then
          task.spawn(function()
            safeCallback(cfg.Callback)
          end)
        end
      end)
      return reg({Frame = f, _token = string.lower(tostring(cfg.Name or "")), SetVisible = function(_, v) f.Visible = v end})
    end

    function tab:CreateToggle(cfg)
      cfg = cfg or {}
      local state = cfg.CurrentValue == true
      local f, glow = makeControlBase(p, theme, 42)
      local row = f
      make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -78, 1, 0), Position = UDim2.new(0, 12, 0, 0), Font = theme.Font, TextSize = 13, TextColor3 = theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(cfg.Name or "Toggle"), Parent = row})
      local sw = make("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 54, 0, 28), BackgroundColor3 = theme.Colors.Input, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row})
      corner(sw, 999)
      local swStroke = stroke(sw, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.34)
      gradient(sw, theme.Colors.Input, theme.Colors.Surface2, 0)
      local k = make("Frame", {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 3, 0.5, -11), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = sw})
      corner(k, 999)
      stroke(k, theme.Colors.Text, 1, 0.72)
      local kScale = make("UIScale", {Scale = 1, Parent = k})
      local function render(anim)
        local bg = state and theme.Colors.Accent or theme.Colors.Input
        local pos = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        local knobColor = state and Color3.new(1, 1, 1) or theme.Colors.TextDim
        if anim then
          tween(sw, theme.Anim.Fast, {BackgroundColor3 = bg})
          tween(swStroke, theme.Anim.Fast, {Color = state and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke), Transparency = state and 0.08 or 0.34})
          tween(k, theme.Anim.Fast, {Position = pos, BackgroundColor3 = knobColor}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
          tween(kScale, theme.Anim.Fast, {Scale = state and 1.04 or 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
          sw.BackgroundColor3 = bg
          swStroke.Color = state and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke)
          swStroke.Transparency = state and 0.08 or 0.34
          k.Position = pos
          k.BackgroundColor3 = knobColor
          kScale.Scale = state and 1.04 or 1
        end
      end
      sw.MouseEnter:Connect(function() tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.84}) end)
      sw.MouseLeave:Connect(function() tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.94}) end)
      sw.MouseButton1Click:Connect(function()
        state = not state
        render(true)
        safeCallback(cfg.Callback, state)
      end)
      render(false)
      return reg({
        Frame = row,
        _token = string.lower(tostring(cfg.Name or "")),
        SetVisible = function(_, v) row.Visible = v end,
        Set = function(_, v) state = v == true; render(true) end,
        SetValue = function(_, v) state = v == true; render(true) end,
        Get = function() return state end,
      })
    end
    
    function tab:CreateExpandableToggle(cfg)
      cfg = cfg or {}
      local name = tostring(cfg.Name or "Expandable")
      local enabled = cfg.CurrentValue == true
      local expanded = cfg.Expanded == true
      local children = {}
      local childHeights = {}
      local childTokens = {}
      local collapsedHeight = 44
      local childTopOffset = 50
      local childBottomPadding = 8
      local childGap = 6
      
      local f = makeControlBase(p, theme, collapsedHeight)
      f.BackgroundColor3 = theme.Colors.ExpandableSurface or theme.Colors.SurfaceGlass or theme.Colors.Surface
      f.BackgroundTransparency = 0
      local expandableStroke = f:FindFirstChildOfClass("UIStroke")
      if expandableStroke then
        expandableStroke.Color = theme.Colors.AccentSoft or theme.Colors.StrokeSoft or theme.Colors.Stroke
        expandableStroke.Transparency = 0.12
      end
      local expandableRail = make("Frame", {
        Name = "NovaExpandableRail",
        Size = UDim2.new(0, 4, 1, -12),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = theme.Colors.Accent3 or theme.Colors.Accent,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = (f.ZIndex or 1) + 2,
        Parent = f,
      })
      corner(expandableRail, 999)
      local expandableSheen = make("Frame", {
        Name = "NovaExpandableSheen",
        Size = UDim2.new(1, -82, 0, 2),
        Position = UDim2.new(0, 18, 0, 4),
        BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = (f.ZIndex or 1) + 1,
        Parent = f,
      })
      local titleBtn = make("TextButton", {
        Size = UDim2.new(1, -94, 0, 34),
        Position = UDim2.new(0, 16, 0, 5),
        BackgroundColor3 = theme.Colors.ExpandableTitle or theme.Colors.Input,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        TextColor3 = theme.Colors.Text,
        Font = theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
      })
      corner(titleBtn, theme.Radius - 4)
      stroke(titleBtn, theme.Colors.Stroke, 1, 0.22)
      
      local toggleBtn = make("TextButton", {
        Size = UDim2.new(0, 54, 0, 28),
        Position = UDim2.new(1, -61, 0, 8),
        BackgroundColor3 = theme.Colors.Input,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        TextColor3 = theme.Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Text = "",
        Parent = f,
      })
      corner(toggleBtn, 999)
      local toggleStroke = stroke(toggleBtn, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.34)
      gradient(toggleBtn, theme.Colors.Input, theme.Colors.Surface2, 0)
      local toggleKnob = make("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 3, 0.5, -11),
        BackgroundColor3 = theme.Colors.TextDim,
        BorderSizePixel = 0,
        Parent = toggleBtn,
      })
      corner(toggleKnob, 999)
      local toggleKnobScale = make("UIScale", {Scale = 1, Parent = toggleKnob})
      local childContainer = make("Frame", {
        Name = "NovaExpandableChildren",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 18, 0, childTopOffset),
        Size = UDim2.new(1, -30, 0, 0),
        Visible = false,
        ZIndex = (f.ZIndex or 1) + 3,
        Parent = f,
      })
      local childLayout = make("UIListLayout", {
        Padding = UDim.new(0, childGap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = childContainer,
      })
      
      local function getChildHeight(child)
        if childHeights[child] then
          return childHeights[child]
        end
        
        local frame = child and child.Frame
        local h = frame and frame.Size.Y.Offset or 42
        if h <= 1 then
          h = 42
        end
        childHeights[child] = h
        return h
      end

      local function getChildrenContentHeight()
        local total = 0
        local count = 0
        for _, child in ipairs(children) do
          local h = getChildHeight(child)
          if h > 0 then
            total = total + h
            count = count + 1
          end
        end
        if count > 1 then
          total = total + (childGap * (count - 1))
        end
        return total
      end

      local function updateExpandableHeight(instant)
        local contentHeight = getChildrenContentHeight()
        local hasChildren = contentHeight > 0
        local targetChildrenHeight = (expanded and hasChildren) and contentHeight or 0
        local targetFrameHeight = (expanded and hasChildren) and (childTopOffset + contentHeight + childBottomPadding) or collapsedHeight
        
        if expanded and hasChildren then
          childContainer.Visible = true
        end
        
        if instant then
          childContainer.Size = UDim2.new(1, -30, 0, targetChildrenHeight)
          f.Size = UDim2.new(1, 0, 0, targetFrameHeight)
          if not expanded then
            childContainer.Visible = false
          end
        else
          tween(childContainer, theme.Anim.Normal, {Size = UDim2.new(1, -30, 0, targetChildrenHeight)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          tween(f, theme.Anim.Normal, {Size = UDim2.new(1, 0, 0, targetFrameHeight)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          if not expanded then
            task.delay(theme.Anim.Normal + 0.03, function()
              if not expanded and childContainer and childContainer.Parent then
                childContainer.Visible = false
              end
            end)
          end
        end
      end
      
      local function setChildExpanded(child, visible, instant)
        local frame = child and child.Frame
        if not frame then
          pcall(function()
            if child and child.SetVisible then
              child:SetVisible(visible)
            end
          end)
          return
        end
        
        local currentHeight = frame.Size.Y.Offset
        if currentHeight > 1 then
          childHeights[child] = currentHeight
        end
        
        local targetHeight = getChildHeight(child)
        childTokens[child] = (childTokens[child] or 0) + 1
        local token = childTokens[child]
        frame.ClipsDescendants = frame.Name ~= "NovaDropdownHolder"
        
        if visible then
          frame.Visible = true
          frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight)
        else
          if instant then
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight)
            frame.Visible = false
          else
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight)
            task.delay(theme.Anim.Normal + 0.03, function()
              if childTokens[child] == token and frame and frame.Parent then
                frame.Visible = false
              end
            end)
          end
        end
        updateExpandableHeight(instant == true)
      end
      
      local function applyChildrenVisible(instant)
        local v = expanded
        for _, child in ipairs(children) do
          setChildExpanded(child, v, instant == true)
        end
      end
      
      local function styleNestedFrame(frame)
        if not frame then return end
        local noNestedRail = frame.Name == "NovaDropdownHolder" or frame.Name == "NovaDropdownRow" or frame.Name == "NovaDropdownList"
        local nestedSurface = theme.Colors.NestedSurface or theme.Colors.Input
        local nestedSurface2 = theme.Colors.NestedSurface2 or theme.Colors.Surface
        pcall(function()
          frame.BackgroundColor3 = nestedSurface
          frame.BackgroundTransparency = 0.06
        end)
        local existingStroke = frame:FindFirstChildOfClass("UIStroke")
        if existingStroke then
          pcall(function()
            existingStroke.Color = theme.Colors.NestedStroke or theme.Colors.StrokeSoft or theme.Colors.Stroke
            existingStroke.Transparency = 0.36
          end)
        end
        if not noNestedRail and not frame:FindFirstChildOfClass("ScrollingFrame") and not frame:FindFirstChild("NovaNestedRail") then
          local rail = make("Frame", {
            Name = "NovaNestedRail",
            Size = UDim2.new(0, 2, 1, -20),
            Position = UDim2.new(0, 7, 0, 10),
            BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
            BackgroundTransparency = 0.48,
            BorderSizePixel = 0,
            ZIndex = (frame.ZIndex or 1) + 1,
            Parent = frame,
          })
          corner(rail, 999)
        end
      end
      
      local function render()
        titleBtn.Text = string.format("  %s  %s", expanded and "v" or ">", name)
        local baseSurface = expanded
          and (theme.Colors.ExpandableSurfaceOpen or theme.Colors.ExpandableSurface or theme.Colors.Surface2)
          or (theme.Colors.ExpandableSurface or theme.Colors.SurfaceGlass or theme.Colors.Surface)
        local titleSurface = expanded
          and (theme.Colors.ExpandableTitleOpen or theme.Colors.Active or theme.Colors.Surface3)
          or (theme.Colors.ExpandableTitle or theme.Colors.Input)
        tween(f, theme.Anim.Fast, {
          BackgroundColor3 = baseSurface,
        })
        if expandableStroke then
          tween(expandableStroke, theme.Anim.Fast, {
            Color = expanded and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.AccentSoft or theme.Colors.StrokeSoft or theme.Colors.Stroke),
            Transparency = expanded and 0.04 or 0.12,
          })
        end
        tween(expandableRail, theme.Anim.Fast, {
          BackgroundTransparency = expanded and 0.02 or 0.12,
          Size = expanded and UDim2.new(0, 4, 1, -8) or UDim2.new(0, 4, 1, -12),
          Position = expanded and UDim2.new(0, 8, 0, 4) or UDim2.new(0, 8, 0, 6),
        })
        tween(expandableSheen, theme.Anim.Fast, {
          BackgroundTransparency = expanded and 0.42 or 0.64,
        })
        tween(titleBtn, theme.Anim.Fast, {
          BackgroundColor3 = titleSurface,
        })
        local bg = enabled and theme.Colors.Accent or theme.Colors.Input
        local pos = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        tween(toggleBtn, theme.Anim.Fast, {BackgroundColor3 = bg})
        tween(toggleStroke, theme.Anim.Fast, {Color = enabled and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke), Transparency = enabled and 0.08 or 0.34})
        tween(toggleKnob, theme.Anim.Fast, {Position = pos, BackgroundColor3 = enabled and Color3.new(1, 1, 1) or theme.Colors.TextDim}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(toggleKnobScale, theme.Anim.Fast, {Scale = enabled and 1.04 or 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
      end
      
      titleBtn.MouseEnter:Connect(function() tween(titleBtn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2}) end)
      titleBtn.MouseLeave:Connect(function()
        tween(titleBtn, theme.Anim.Fast, {
          BackgroundColor3 = expanded and (theme.Colors.ExpandableTitleOpen or theme.Colors.Active or theme.Colors.Surface3) or (theme.Colors.ExpandableTitle or theme.Colors.Input),
        })
      end)
      titleBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        render()
        applyChildrenVisible(false)
      end)
      toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        addRipple(toggleBtn, theme)
        render()
        safeCallback(cfg.Callback, enabled)
      end)
      
      local function prefixed(source)
        local out = {}
        for k, v in pairs(source or {}) do out[k] = v end
        out.Name = "   " .. tostring(out.Name or "Item")
        return out
      end
      
      local ctrl
      local function addChild(childCtrl)
        table.insert(children, childCtrl)
        if ctrl and childCtrl and childCtrl._token then
          ctrl._token = string.lower(tostring(ctrl._token or name) .. " " .. tostring(childCtrl._token or ""))
        end
        if childCtrl and childCtrl.Frame then
          pcall(function()
            childCtrl._nested = true
            childCtrl.Frame.Parent = childContainer
            childCtrl.Frame.LayoutOrder = #children
            childCtrl.Frame.Position = UDim2.new(0, 0, 0, 0)
            childCtrl.Frame.BackgroundColor3 = theme.Colors.NestedSurface or theme.Colors.Input
            childCtrl.Frame.BackgroundTransparency = 0.06
            childCtrl.Frame.Size = UDim2.new(1, 0, 0, childCtrl.Frame.Size.Y.Offset)
            childHeights[childCtrl] = math.max(1, childCtrl.Frame.Size.Y.Offset)
            styleNestedFrame(childCtrl.Frame)
            for _, item in ipairs(childCtrl.Frame:GetChildren()) do
              if item:IsA("Frame") and item.Name ~= "NovaNestedShade" and item.Name ~= "NovaNestedRail" then
                styleNestedFrame(item)
                break
              end
            end
          end)
          bindConnection(childCtrl.Frame:GetPropertyChangedSignal("Size"):Connect(function()
            local h = childCtrl.Frame.Size.Y.Offset
            if h > 1 then
              childHeights[childCtrl] = h
              if expanded then
                updateExpandableHeight(false)
              end
            end
          end))
        end
        setChildExpanded(childCtrl, expanded, true)
        return childCtrl
      end
      
      render()
      ctrl = reg({
        Frame = f,
        _token = string.lower(name),
        SetVisible = function(_, v)
          f.Visible = v
          if not v then
            for _, child in ipairs(children) do
              pcall(function() if child and child.SetVisible then child:SetVisible(false) end end)
            end
          else
            applyChildrenVisible(true)
          end
        end,
        Set = function(_, v)
          enabled = v == true
          render()
        end,
        SetValue = function(_, v)
          enabled = v == true
          render()
        end,
        Get = function() return enabled end,
        SetExpanded = function(_, v)
          expanded = v == true
          render()
          applyChildrenVisible(false)
        end,
        GetExpanded = function() return expanded end,
      })
      
      function ctrl:CreateToggle(subCfg) return addChild(tab:CreateToggle(prefixed(subCfg))) end
      function ctrl:CreateSlider(subCfg) return addChild(tab:CreateSlider(prefixed(subCfg))) end
      function ctrl:CreateDropdown(subCfg) return addChild(tab:CreateDropdown(prefixed(subCfg))) end
      function ctrl:CreateOptionPicker(subCfg)
        if tab.CreateOptionPicker then
          return addChild(tab:CreateOptionPicker(prefixed(subCfg)))
        end
        return addChild(tab:CreateDropdown(prefixed(subCfg)))
      end
      function ctrl:CreateInput(subCfg) return addChild(tab:CreateInput(prefixed(subCfg))) end
      function ctrl:CreateButton(subCfg) return addChild(tab:CreateButton(prefixed(subCfg))) end
      function ctrl:CreateKeybind(subCfg) return addChild(tab:CreateKeybind(prefixed(subCfg))) end
      function ctrl:CreateLabel(subCfg) return addChild(tab:CreateLabel(subCfg)) end
      function ctrl:CreateParagraph(subCfg) return addChild(tab:CreateParagraph(subCfg)) end
      
      applyChildrenVisible(true)
      return ctrl
    end

    function tab:CreateSlider(cfg)
      cfg = cfg or {}
      local rawMin = tonumber(cfg.Min) or (cfg.Range and cfg.Range[1]) or 0
      local rawMax = tonumber(cfg.Max) or (cfg.Range and cfg.Range[2]) or 100
      local min, max = normalizeRange(rawMin, rawMax)
      local inc = tonumber(cfg.Increment) or 1
      local val = math.clamp(tonumber(cfg.CurrentValue) or min, min, max)
      local f, glow = makeControlBase(p, theme, 56)
      local row = f
      local name = tostring(cfg.Name or "Slider")
      local suffix = cfg.Suffix and (" " .. tostring(cfg.Suffix)) or ""
      local l = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, -110, 0, 20), Position = UDim2.new(0, 10, 0, 4), Font = theme.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Colors.Text, Text = name, Parent = row})
      local vl = make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -108, 0, 4), Font = theme.Font, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.Colors.TextDim, Text = tostring(val), Parent = row})
      local bar = make("Frame", {Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 30), BackgroundColor3 = theme.Colors.Input, BorderSizePixel = 0, ClipsDescendants = true, Parent = row}); corner(bar, 999); stroke(bar, theme.Colors.Stroke, 1, 0.45)
      local fill = make("Frame", {Size = UDim2.new(0,0,1,0), BackgroundColor3 = theme.Colors.Accent, BorderSizePixel = 0, Parent = bar}); corner(fill, 999)
      gradient(fill, theme.Colors.Accent, theme.Colors.Accent2 or theme.Colors.Accent, 0)
      local knob = make("Frame", {AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,0,0.5,0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = bar}); corner(knob, 999)
      stroke(knob, theme.Colors.Accent2 or theme.Colors.Accent, 1, 0.2)
      local knobScale = make("UIScale", {Scale = 1, Parent = knob})
      local dragging = false
      local function snap(v) return inc <= 0 and v or math.floor(v / inc + 0.5) * inc end
      local function render(fromDrag)
        local pct = (max == min) and 0 or ((val - min) / (max - min))
        pct = math.clamp(pct, 0, 1)
        fill.Visible = pct > 0.002
        tween(fill, fromDrag and 0.06 or theme.Anim.Fast, {Size = UDim2.new(pct,0,1,0)})
        tween(knob, fromDrag and 0.06 or theme.Anim.Fast, {Position = UDim2.new(pct,(1 - (pct * 2)) * 7,0.5,0)})
        vl.Text = tostring(val) .. suffix
      end
      local function setByAlpha(a, drag)
        local nv = min + (max - min) * math.clamp(a,0,1)
        val = math.clamp(snap(nv), min, max)
        render(drag)
        safeCallback(cfg.Callback, val)
      end
      local function updateMouse()
        local px = UserInputService:GetMouseLocation().X
        setByAlpha((px - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), true)
      end
      bindConnection(bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
          dragging = true
          tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.82})
          tween(knobScale, theme.Anim.Fast, {Scale = 1.24}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
          updateMouse()
        end
      end))
      bindConnection(UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then updateMouse() end end))
      bindConnection(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
          dragging = false
          tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.94})
          tween(knobScale, theme.Anim.Fast, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
      end))
      setByAlpha((val - min) / math.max(1e-6, max - min), false)
      return reg({
        Frame = row,
        _token = string.lower(name),
        SetVisible = function(_, v) row.Visible = v end,
        Set = function(_, v) val = math.clamp(tonumber(v) or min, min, max); render(false) end,
        SetValue = function(_, v) val = math.clamp(tonumber(v) or min, min, max); render(false) end,
        Get = function() return val end,
      })
    end

    function tab:CreateDropdown(cfg)
      cfg = cfg or {}
      local opts = cfg.Options or {"None"}
      local current = cfg.CurrentOption
      if type(current) == "table" then current = current[1] end
      current = current or opts[1]

      local holder = make("Frame", {
        Name = "NovaDropdownHolder",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 55,
        Parent = p,
      })

      local row, glow = makeControlBase(p, theme, 42)
      row.Name = "NovaDropdownRow"
      row.Parent = holder
      row.ZIndex = 56

      local btn = make("TextButton", {
        Size = UDim2.new(1, -14, 1, 0),
        Position = UDim2.new(0, 7, 0, 0),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 57,
        Parent = row,
      })

      local lbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        Font = theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = theme.Colors.Text,
        ZIndex = 58,
        Parent = btn,
      })

      local arrow = make("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Font = theme.Font,
        TextSize = 14,
        TextColor3 = theme.Colors.TextDim,
        Text = ">",
        ZIndex = 58,
        Parent = btn,
      })

      local listFrame = make("ScrollingFrame", {
        Name = "NovaDropdownList",
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.new(0, 4, 0, 48),
        BackgroundColor3 = theme.Colors.Input,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
        ScrollBarImageTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        CanvasPosition = Vector2.new(0, 0),
        ZIndex = 80,
        Parent = holder,
      })
      pcall(function()
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
      end)
      corner(listFrame, theme.Radius - 2)
      stroke(listFrame, theme.Colors.Stroke, 1, 0.45)
      local listLayout = make("UIListLayout", {Padding = UDim.new(0, 4), Parent = listFrame})
      make("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = listFrame,
      })
      attachSmoothScroll(listFrame, theme, bindConnection)
      bindConnection(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
      end))

      local opened = false
      local itemButtons = {}
      local function updateLabel()
        lbl.Text = string.format("%s: %s", tostring(cfg.Name or "Dropdown"), tostring(current))
      end
      
      local function renderSelectedItems()
        for _, item in ipairs(itemButtons) do
          local active = tostring(item:GetAttribute("NovaValue")) == tostring(current)
          tween(item, theme.Anim.Fast, {
            BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Surface,
            TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
          })
        end
      end

      local function setOpened(v)
        opened = v == true
        arrow.Text = ">"
        listFrame.Visible = true
        if opened then
          listFrame.CanvasPosition = Vector2.new(0, 0)
        end
        local fullHeight = math.max(listLayout.AbsoluteContentSize.Y + 12, (#opts * 34) + 12)
        local h = opened and math.min(fullHeight, 186) or 0
        holder.Size = UDim2.new(1, 0, 0, 42 + (opened and h + 6 or 0))
        tween(listFrame, theme.Anim.Normal, {Size = UDim2.new(1, -8, 0, h)})
        tween(listFrame, theme.Anim.Fast, {ScrollBarImageTransparency = opened and 0.45 or 1})
        tween(arrow, theme.Anim.Fast, {Rotation = opened and 90 or 0})
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = opened and 0.84 or 0.93})
        if not opened then
          task.delay(theme.Anim.Normal + 0.03, function()
            if not opened and listFrame and listFrame.Parent then
              listFrame.Visible = false
            end
          end)
        end
      end

      local function setValue(v, fireCallback)
        if type(v) == "table" then
          v = v[1]
        end
        current = v
        updateLabel()
        renderSelectedItems()
        if fireCallback then
          safeCallback(cfg.Callback, v)
        end
      end
      
      local function clearItems()
        for _, btn in ipairs(itemButtons) do
          if btn and btn.Parent then
            btn:Destroy()
          end
        end
        itemButtons = {}
      end
      
      local function normalizeOptions(newOpts)
        local out = {}
        if type(newOpts) ~= "table" then
          out[1] = "None"
          return out
        end
        
        for _, opt in ipairs(newOpts) do
          out[#out + 1] = tostring(opt)
        end
        
        if #out == 0 then
          out[1] = "None"
        end
        return out
      end
      
      local function containsOption(val)
        local target = tostring(val)
        for _, opt in ipairs(opts) do
          if tostring(opt) == target then
            return true
          end
        end
        return false
      end
      
      local function rebuildItems()
        clearItems()
        for _, opt in ipairs(opts) do
          local val = tostring(opt)
          local item = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Colors.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            AutoButtonColor = false,
            Font = theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = theme.Colors.Text,
            Text = "  " .. val,
            ZIndex = 82,
            Parent = listFrame,
          })
          item:SetAttribute("NovaValue", val)
          corner(item, theme.Radius - 4)
          item.MouseEnter:Connect(function() tween(item, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2, TextColor3 = theme.Colors.Text}) end)
          item.MouseLeave:Connect(function() renderSelectedItems() end)
          item.MouseButton1Down:Connect(function()
            setValue(val, true)
            setOpened(false)
          end)
          table.insert(itemButtons, item)
        end
        renderSelectedItems()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(listLayout.AbsoluteContentSize.Y + 12, (#opts * 34) + 12))
      end
      
      local function refreshOptions(newOpts, keepCurrent)
        opts = normalizeOptions(newOpts)
        rebuildItems()
        
        local keep = keepCurrent == true and current ~= nil and containsOption(current)
        if keep then
          setValue(current, false)
        else
          setValue(opts[1], false)
        end
        
        if opened then
          setOpened(true)
        else
          setOpened(false)
        end
      end

      btn.MouseButton1Down:Connect(function()
        addRipple(btn, theme)
        setOpened(not opened)
      end)

      refreshOptions(opts, true)
      setOpened(false)

      local ctrl = {
        Frame = holder,
        _token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current))),
        SetVisible = function(_, v) holder.Visible = v end,
        Set = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetValue = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        Refresh = function(self, newOpts)
          refreshOptions(newOpts, true)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetOptions = function(self, newOpts)
          refreshOptions(newOpts, true)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        Get = function() return current end,
      }
      return reg(ctrl)
    end

    function tab:CreateOptionPicker(cfg)
      cfg = cfg or {}
      local function normalizeOptions(newOpts)
        local out = {}
        if type(newOpts) == "table" then
          for _, opt in ipairs(newOpts) do
            out[#out + 1] = tostring(opt)
          end
        end
        if #out == 0 then
          out[1] = "None"
        end
        return out
      end
      
      local opts = normalizeOptions(cfg.Options)
      local current = cfg.CurrentOption
      if type(current) == "table" then current = current[1] end
      current = tostring(current or opts[1])
      local columns = tonumber(cfg.Columns)
      if not columns then
        columns = (#opts <= 3) and #opts or 2
      end
      columns = math.clamp(columns, 1, 4)
      local rowCount = math.max(1, math.ceil(#opts / columns))
      local rowHeight = 22
      local gap = 5
      local collapsedHeight = 38
      local gridTop = 38
      local bottomPad = 8
      local opened = cfg.Opened == true or cfg.DefaultOpen == true
      local function getGridHeight()
        return (rowCount * rowHeight) + (math.max(0, rowCount - 1) * gap)
      end
      local function getExpandedHeight()
        return gridTop + getGridHeight() + bottomPad
      end
      local height = opened and getExpandedHeight() or collapsedHeight
      local f, glow = makeControlBase(p, theme, height)
      f.Name = "NovaOptionPicker"
      f.BackgroundColor3 = theme.Colors.NestedSurface2 or theme.Colors.SurfaceGlass or theme.Colors.Surface
      f.BackgroundTransparency = 0.04
      
      local title = make("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -130, 0, 28),
        Position = UDim2.new(0, 10, 0, 4),
        AutoButtonColor = false,
        Font = theme.Font,
        TextSize = 12,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = "",
        Parent = f,
      })
      local currentPill = make("TextButton", {
        BackgroundColor3 = theme.Colors.Input or theme.Colors.Surface,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -34, 0, 19),
        Size = UDim2.new(0, 78, 0, 20),
        Font = theme.Font,
        TextSize = 10,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tostring(current),
        Parent = f,
      })
      corner(currentPill, theme.Radius - 5)
      stroke(currentPill, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
      local arrow = make("TextButton", {
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0, 19),
        Size = UDim2.new(0, 16, 0, 16),
        Font = theme.Font,
        TextSize = 13,
        TextColor3 = theme.Colors.TextDim,
        Text = ">",
        Rotation = opened and 90 or 0,
        Parent = f,
      })
      
      local grid = make("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = opened,
        Size = UDim2.new(1, -20, 0, opened and getGridHeight() or 0),
        Position = UDim2.new(0, 10, 0, gridTop),
        Parent = f,
      })
      local gridLayout = make("UIGridLayout", {
        CellPadding = UDim2.new(0, gap, 0, gap),
        CellSize = UDim2.new(1 / columns, -math.ceil(((columns - 1) * gap) / columns), 0, rowHeight),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
      })
      
      local buttons = {}
      local buttonStrokes = {}
      local buttonMarks = {}
      local function render()
        title.Text = tostring(cfg.Name or "Options")
        currentPill.Text = tostring(current)
        for _, btn in ipairs(buttons) do
          local active = tostring(btn:GetAttribute("NovaValue")) == tostring(current)
          tween(btn, theme.Anim.Fast, {
            BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.AccentSoft or theme.Colors.Surface3) or (theme.Colors.Input or theme.Colors.Surface),
            TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
            BackgroundTransparency = active and 0.04 or 0.16,
          })
          local st = buttonStrokes[btn]
          if st then
            tween(st, theme.Anim.Fast, {
              Color = active and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke),
              Transparency = active and 0.1 or 0.55,
            })
          end
          local mark = buttonMarks[btn]
          if mark then
            tween(mark, theme.Anim.Fast, {
              BackgroundTransparency = 1,
              Size = UDim2.new(0, 0, 0, 0),
            })
          end
        end
      end
      local function setOpened(v, instant)
        opened = v == true
        local expandedHeight = getExpandedHeight()
        local targetHeight = opened and expandedHeight or collapsedHeight
        local targetGridHeight = opened and getGridHeight() or 0
        if opened then
          grid.Visible = true
        end
        if instant then
          f.Size = UDim2.new(1, 0, 0, targetHeight)
          grid.Size = UDim2.new(1, -20, 0, targetGridHeight)
          arrow.Rotation = opened and 90 or 0
          if not opened then
            grid.Visible = false
          end
        else
          tween(f, theme.Anim.Normal, {Size = UDim2.new(1, 0, 0, targetHeight)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          tween(grid, theme.Anim.Normal, {Size = UDim2.new(1, -20, 0, targetGridHeight)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          tween(arrow, theme.Anim.Fast, {Rotation = opened and 90 or 0})
          if not opened then
            task.delay(theme.Anim.Normal + 0.03, function()
              if not opened and grid and grid.Parent then
                grid.Visible = false
              end
            end)
          end
        end
      end
      
      local function setValue(v, fireCallback)
        current = tostring(type(v) == "table" and v[1] or v or opts[1])
        render()
        if fireCallback then
          safeCallback(cfg.Callback, current)
        end
      end
      
      local function clearButtons()
        for _, btn in ipairs(buttons) do
          if btn and btn.Parent then
            btn:Destroy()
          end
        end
        buttons = {}
        buttonStrokes = {}
        buttonMarks = {}
      end
      
      local function rebuild()
        clearButtons()
        rowCount = math.max(1, math.ceil(#opts / columns))
        height = opened and getExpandedHeight() or collapsedHeight
        f.Size = UDim2.new(1, 0, 0, height)
        grid.Visible = opened
        grid.Size = UDim2.new(1, -20, 0, opened and getGridHeight() or 0)
        gridLayout.CellSize = UDim2.new(1 / columns, -math.ceil(((columns - 1) * gap) / columns), 0, rowHeight)
        for index, opt in ipairs(opts) do
          local value = tostring(opt)
          local btn = make("TextButton", {
            Name = "NovaOptionButton_" .. value,
            BackgroundColor3 = theme.Colors.Input or theme.Colors.Surface,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            AutoButtonColor = false,
            Font = theme.Font,
            TextSize = 10,
            TextColor3 = theme.Colors.TextDim,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = value,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = index,
            Parent = grid,
          })
          btn:SetAttribute("NovaValue", value)
          corner(btn, math.max(6, theme.Radius - 7))
          make("UIPadding", {PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = btn})
          buttonMarks[btn] = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = btn,
          })
          corner(buttonMarks[btn], 999)
          buttonStrokes[btn] = stroke(btn, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.42)
          bindConnection(btn.MouseEnter:Connect(function()
            tween(btn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2, TextColor3 = theme.Colors.Text})
            tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.86})
          end))
          bindConnection(btn.MouseLeave:Connect(function()
            tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.94})
            render()
          end))
          bindConnection(btn.MouseButton1Click:Connect(function()
            addRipple(btn, theme)
            setValue(value, true)
            setOpened(false, false)
          end))
          buttons[#buttons + 1] = btn
        end
        if not current or current == "" then
          current = opts[1]
        end
        render()
        setOpened(opened, true)
      end
      
      bindConnection(title.MouseEnter:Connect(function()
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.86})
      end))
      bindConnection(title.MouseLeave:Connect(function()
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.94})
      end))
      bindConnection(title.MouseButton1Click:Connect(function()
        addRipple(title, theme)
        setOpened(not opened, false)
      end))
      bindConnection(currentPill.MouseButton1Down:Connect(function()
        addRipple(currentPill, theme)
        setOpened(not opened, false)
      end))
      bindConnection(arrow.MouseButton1Down:Connect(function()
        setOpened(not opened, false)
      end))
      
      rebuild()
      return reg({
        Frame = f,
        _token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current))),
        SetVisible = function(_, v) f.Visible = v end,
        Set = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetValue = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        Refresh = function(self, newOpts)
          opts = normalizeOptions(newOpts)
          if not table.find(opts, tostring(current)) then
            current = opts[1]
          end
          rebuild()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetOptions = function(self, newOpts)
          opts = normalizeOptions(newOpts)
          if not table.find(opts, tostring(current)) then
            current = opts[1]
          end
          rebuild()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetOpened = function(_, v) setOpened(v, false) end,
        GetOpened = function() return opened end,
        Get = function() return current end,
      })
    end

    function tab:CreateInput(cfg)
      cfg = cfg or {}
      local f = makeControlBase(p, theme, 46)
      local row = f
      local name = tostring(cfg.Name or "Input")
      local removeAfterFocusLost = cfg.RemoveTextAfterFocusLost == true
      make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0,120,1,0), Position = UDim2.new(0,10,0,0), Font = theme.Font, TextSize = 13, TextColor3 = theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, Text = name, Parent = row})
      local tb = make("TextBox", {Size = UDim2.new(1,-140,0,30), Position = UDim2.new(0,130,0.5,-15), BackgroundColor3 = theme.Colors.Input, BorderSizePixel = 0, Font = theme.Font, TextSize = 13, TextColor3 = theme.Colors.Text, PlaceholderColor3 = theme.Colors.TextDim, PlaceholderText = tostring(cfg.PlaceholderText or "Type..."), Text = tostring(cfg.CurrentValue or ""), ClearTextOnFocus = false, Parent = row})
      corner(tb, theme.Radius - 4)
      local tbStroke = stroke(tb, theme.Colors.Stroke, 1, 0.45)
      tb.Focused:Connect(function()
        tween(tb, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2})
        tween(tbStroke, theme.Anim.Fast, {Transparency = 0.08, Color = theme.Colors.Accent2 or theme.Colors.Accent})
      end)
      tb.FocusLost:Connect(function()
        tween(tb, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Input})
        tween(tbStroke, theme.Anim.Fast, {Transparency = 0.45, Color = theme.Colors.Stroke})
        safeCallback(cfg.Callback, tb.Text)
        if removeAfterFocusLost then
          tb.Text = ""
        end
      end)
      return reg({
        Frame = row,
        _token = string.lower(name),
        SetVisible = function(_, v) row.Visible = v end,
        Set = function(_, v) tb.Text = tostring(v or "") end,
        SetValue = function(_, v) tb.Text = tostring(v or "") end,
        Get = function() return tb.Text end,
      })
    end
    
    function tab:CreateActionGroup(cfg)
      cfg = cfg or {}
      local actions = cfg.Actions or cfg.Buttons or {}
      if type(actions) ~= "table" or #actions == 0 then
        actions = {{Name = tostring(cfg.Name or "Action"), Callback = cfg.Callback}}
      end
      local allBlue = cfg.AllBlue == true
      local count = math.clamp(#actions, 1, 4)
      local f, glow = makeControlBase(p, theme, 66)
      f.BackgroundColor3 = theme.Colors.ExpandableSurface or theme.Colors.SurfaceGlass or theme.Colors.Surface
      f.BackgroundTransparency = 0.01
      local fStroke = f:FindFirstChildOfClass("UIStroke")
      if fStroke then
        fStroke.Color = theme.Colors.AccentSoft or theme.Colors.StrokeSoft or theme.Colors.Stroke
        fStroke.Transparency = 0.16
      end
      
      make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = tostring(cfg.Name or "Actions"),
        Parent = f,
      })
      
      local row = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 29),
        Parent = f,
      })
      make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = row,
      })
      
      local buttons = {}
      for index, action in ipairs(actions) do
        local styleName = tostring(action.Style or action.Type or "")
        local isDanger = (not allBlue) and (styleName == "Danger" or styleName == "danger")
        local isPrimary = allBlue or styleName == "Primary" or styleName == "primary" or index == 1
        local btn = make("TextButton", {
          Size = UDim2.new(1 / count, -math.ceil((count - 1) * 6 / count), 1, 0),
          BackgroundColor3 = isDanger and Color3.fromRGB(92, 35, 55) or (isPrimary and theme.Colors.AccentSoft or theme.Colors.Input),
          BackgroundTransparency = isPrimary and 0.04 or 0.1,
          BorderSizePixel = 0,
          AutoButtonColor = false,
          Font = theme.Font,
          TextSize = 12,
          TextColor3 = theme.Colors.Text,
          Text = tostring(action.Name or action.Title or ("Action " .. tostring(index))),
          LayoutOrder = index,
          Parent = row,
        })
        corner(btn, theme.Radius - 5)
        stroke(btn, isDanger and Color3.fromRGB(170, 72, 105) or (theme.Colors.StrokeSoft or theme.Colors.Stroke), 1, 0.44)
        bindConnection(btn.MouseEnter:Connect(function()
          tween(btn, theme.Anim.Fast, {
            BackgroundColor3 = isDanger and Color3.fromRGB(120, 45, 72) or (theme.Colors.Hover or theme.Colors.Surface2),
          })
          tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.84})
        end))
        bindConnection(btn.MouseLeave:Connect(function()
          tween(btn, theme.Anim.Fast, {
            BackgroundColor3 = isDanger and Color3.fromRGB(92, 35, 55) or (isPrimary and theme.Colors.AccentSoft or theme.Colors.Input),
          })
          tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.93})
        end))
        bindConnection(btn.MouseButton1Click:Connect(function()
          addRipple(btn, theme)
          task.spawn(function()
            safeCallback(action.Callback)
          end)
        end))
        table.insert(buttons, btn)
      end
      
      return reg({
        Frame = f,
        Buttons = buttons,
        _token = string.lower(tostring(cfg.Name or "actions")),
        SetVisible = function(_, v) f.Visible = v end,
      })
    end

    function tab:CreateConfigList(cfg)
      cfg = cfg or {}
      local function normalizeOptions(newOpts)
        local out = {}
        if type(newOpts) == "table" then
          for _, opt in ipairs(newOpts) do
            local value = tostring(opt or "")
            if value ~= "" then
              out[#out + 1] = value
            end
          end
        end
        if #out == 0 then
          out[1] = tostring(cfg.EmptyText or cfg.DefaultName or "default")
        end
        return out
      end
      
      local opts = normalizeOptions(cfg.Options)
      local current = cfg.CurrentOption
      if type(current) == "table" then current = current[1] end
      current = tostring(current or opts[1])
      local listHeight = math.clamp(tonumber(cfg.ListHeight) or 232, 110, 320)
      local f, glow = makeControlBase(p, theme, listHeight + 44)
      f.Name = "NovaConfigList"
      f.BackgroundColor3 = theme.Colors.NestedSurface2 or theme.Colors.SurfaceGlass or theme.Colors.Surface
      f.BackgroundTransparency = 0.03
      
      local title = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -132, 0, 22),
        Position = UDim2.new(0, 10, 0, 7),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tostring(cfg.Name or "Saved Configs"),
        Parent = f,
      })
      local selectedPill = make("TextLabel", {
        BackgroundColor3 = theme.Colors.Input or theme.Colors.Surface,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 7),
        Size = UDim2.new(0, 112, 0, 22),
        Font = theme.Font,
        TextSize = 10,
        TextColor3 = theme.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Text = current,
        Parent = f,
      })
      corner(selectedPill, math.max(6, theme.Radius - 7))
      stroke(selectedPill, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.52)
      
      local listFrame = make("ScrollingFrame", {
        BackgroundColor3 = theme.Colors.Input or theme.Colors.Surface,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, listHeight),
        Position = UDim2.new(0, 10, 0, 36),
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = f,
      })
      corner(listFrame, math.max(6, theme.Radius - 6))
      stroke(listFrame, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.58)
      make("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = listFrame})
      local listLayout = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = listFrame,
      })
      attachSmoothScroll(listFrame, theme, bindConnection)
      bindConnection(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
      end))
      
      local buttons = {}
      local buttonMarks = {}
      local buttonStrokes = {}
      local function render()
        selectedPill.Text = tostring(current)
        for _, btn in ipairs(buttons) do
          local active = tostring(btn:GetAttribute("NovaValue")) == tostring(current)
          tween(btn, theme.Anim.Fast, {
            BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.AccentSoft or theme.Colors.Surface3) or (theme.Colors.SurfaceGlass or theme.Colors.Surface),
            BackgroundTransparency = active and 0.03 or 0.18,
            TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
          })
          if buttonStrokes[btn] then
            tween(buttonStrokes[btn], theme.Anim.Fast, {
              Color = active and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke),
              Transparency = active and 0.08 or 0.62,
            })
          end
          if buttonMarks[btn] then
            tween(buttonMarks[btn], theme.Anim.Fast, {
              BackgroundTransparency = 1,
              Size = UDim2.new(0, 0, 0, 0),
            })
          end
        end
      end
      local function setValue(v, fireCallback)
        current = tostring(type(v) == "table" and v[1] or v or opts[1])
        render()
        if fireCallback then
          safeCallback(cfg.Callback, current)
        end
      end
      local function rebuild()
        for _, btn in ipairs(buttons) do
          if btn and btn.Parent then
            btn:Destroy()
          end
        end
        buttons = {}
        buttonMarks = {}
        buttonStrokes = {}
        for index, opt in ipairs(opts) do
          local value = tostring(opt)
          local btn = make("TextButton", {
            Name = "NovaConfigItem_" .. value,
            BackgroundColor3 = theme.Colors.SurfaceGlass or theme.Colors.Surface,
            BackgroundTransparency = 0.18,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            AutoButtonColor = false,
            Size = UDim2.new(1, -2, 0, 26),
            Font = theme.Font,
            TextSize = 11,
            TextColor3 = theme.Colors.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = value,
            LayoutOrder = index,
            Parent = listFrame,
          })
          btn:SetAttribute("NovaValue", value)
          corner(btn, math.max(6, theme.Radius - 7))
          make("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = btn})
          buttonMarks[btn] = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = btn,
          })
          corner(buttonMarks[btn], 999)
          buttonStrokes[btn] = stroke(btn, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.62)
          bindConnection(btn.MouseEnter:Connect(function()
            if tostring(btn:GetAttribute("NovaValue")) ~= tostring(current) then
              tween(btn, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2, BackgroundTransparency = 0.08})
            end
            tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.88})
          end))
          bindConnection(btn.MouseLeave:Connect(function()
            render()
            tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.94})
          end))
          bindConnection(btn.MouseButton1Click:Connect(function()
            addRipple(btn, theme)
            setValue(value, true)
          end))
          buttons[#buttons + 1] = btn
        end
        render()
      end
      
      rebuild()
      return reg({
        Frame = f,
        _token = string.lower(string.format("%s %s", tostring(cfg.Name or "saved configs"), tostring(current))),
        SetVisible = function(_, v) f.Visible = v end,
        Set = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or "saved configs"), tostring(current)))
        end,
        SetValue = function(self, v)
          setValue(v, false)
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or "saved configs"), tostring(current)))
        end,
        Refresh = function(self, newOpts)
          opts = normalizeOptions(newOpts)
          if not table.find(opts, tostring(current)) then
            current = opts[1]
          end
          rebuild()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or "saved configs"), tostring(current)))
        end,
        SetOptions = function(self, newOpts)
          self:Refresh(newOpts)
        end,
        Get = function() return current end,
      })
    end

    function tab:CreateKeybind(cfg)
      cfg = cfg or {}
      local name = tostring(cfg.Name or "Keybind")
      local current = tostring(cfg.CurrentKeybind or "None")
      local pending = current
      
      local f, slot = acquireCompactBindRow()
      local glow = f:FindFirstChildWhichIsA("Frame")
      local xScale = slot == 1 and 0 or 0.5
      local xOffset = slot == 1 and 7 or 5
      local widthOffset = slot == 1 and -14 or -12
      local field = make("TextButton", {
        Size = UDim2.new(0.5, widthOffset, 1, -8),
        Position = UDim2.new(xScale, xOffset, 0, 4),
        BackgroundColor3 = theme.Colors.Input,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = theme.Font,
        TextSize = 13,
        TextColor3 = theme.Colors.Text,
        Text = "",
        Parent = f,
      })
      corner(field, theme.Radius - 4)
      local fieldStroke = stroke(field, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.34)
      local nameLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -94, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Font = theme.Font,
        TextSize = 13,
        TextColor3 = theme.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
        Parent = field,
      })
      local keyBadge = make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 72, 0, 24),
        Position = UDim2.new(1, -7, 0.5, 0),
        BackgroundColor3 = theme.Colors.Surface2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
        Parent = field,
      })
      corner(keyBadge, theme.Radius - 5)
      stroke(keyBadge, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
      
      local listening = false
      local function renderLabel()
        nameLabel.Text = listening and (name .. "  -  press key") or name
        keyBadge.Text = tostring(current)
        tween(field, theme.Anim.Fast, {
          BackgroundColor3 = listening and (theme.Colors.ExpandableTitleOpen or theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Input,
        })
        tween(fieldStroke, theme.Anim.Fast, {
          Color = listening and (theme.Colors.Accent2 or theme.Colors.Accent) or (theme.Colors.StrokeSoft or theme.Colors.Stroke),
          Transparency = listening and 0.06 or 0.34,
        })
      end
      
      local applyValue
      
      local function normalizeKeyName(value)
        local raw = tostring(value or "None")
        raw = raw:gsub("Enum.KeyCode.", ""):gsub("^%s+", ""):gsub("%s+$", "")
        if raw == "" then return "None" end
        raw = raw:match("^[^%s,;]+") or raw
        if raw == "None" then return raw end
        local first = raw:match("^[A-Za-z]") or ""
        first = first:upper()
        if first ~= "" and Enum.KeyCode[first] then return first end
        return "None"
      end
      
      applyValue = function(value)
        current = normalizeKeyName(value)
        pending = current
        listening = false
        renderLabel()
        safeCallback(cfg.Callback, current)
      end
      field.MouseEnter:Connect(function()
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.84})
      end)
      field.MouseLeave:Connect(function()
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = listening and 0.84 or 0.93})
      end)
      field.MouseButton1Click:Connect(function()
        addRipple(field, theme)
        listening = true
        pending = current
        renderLabel()
      end)
      
      bindConnection(UserInputService.InputBegan:Connect(function(input, gp)
        if not listening then return end
        local newName = nil
        if input.UserInputType == Enum.UserInputType.Keyboard then
          if input.KeyCode == Enum.KeyCode.Escape then
            listening = false
            renderLabel()
            return
          elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
            newName = "None"
          else
            local keyName = tostring(input.KeyCode.Name)
            if #keyName == 1 and keyName:match("^[A-Za-z]$") then
              newName = keyName
            end
          end
        end
        if newName then
          applyValue(newName)
        end
      end))
      
      renderLabel()
      return reg({
        Frame = f,
        _token = string.lower(name),
        SetVisible = function(_, v) setCompactBindVisible(f, slot, v) end,
        Set = function(_, v) current = normalizeKeyName(v); pending = current; listening = false; renderLabel() end,
        SetValue = function(_, v) current = normalizeKeyName(v); pending = current; listening = false; renderLabel() end,
        Get = function() return current end,
        Apply = function() applyValue(pending) end,
        Clear = function() applyValue("None") end,
      })
    end

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:_Switch(tab) end
    return tab
  end

  window.Gui = gui
  window.Root = root
  window.Shell = shell
  local openPos = UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2)
  local hiddenPos = UDim2.new(0.5, -sz.X / 2, 1, sz.Y + 80)
  local slidDown = false
  local animatingToggle = false
  local function setOpenPosition(pos)
    if slidDown or animatingToggle then return end
    openPos = pos
    hiddenPos = UDim2.new(openPos.X.Scale, openPos.X.Offset, 1, sz.Y + 80)
  end
  function window:Destroy()
    for _, conn in ipairs(self._connections or {}) do
      pcall(function() conn:Disconnect() end)
    end
    self._connections = {}
    if blurEffect and blurEffect.Parent then
      local closingBlur = blurEffect
      tween(closingBlur, theme.Anim.Fast, {Size = 0})
      task.delay(theme.Anim.Fast + 0.03, function()
        if closingBlur and closingBlur.Parent then
          closingBlur:Destroy()
        end
      end)
      blurEffect = nil
    end
    if gui and gui.Parent then gui:Destroy() end
    if islandGui and islandGui.Parent then islandGui:Destroy() end
  end
  function window:Toggle()
    slidDown = not slidDown
    self._slidDown = slidDown
    animatingToggle = true
    tween(shell, theme.Anim.Slow, {Position = slidDown and hiddenPos or openPos}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    if blurEffect and blurEffect.Parent then
      tween(blurEffect, theme.Anim.Slow, {Size = slidDown and 0 or blurSize}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    task.delay(theme.Anim.Slow + 0.03, function()
      animatingToggle = false
    end)
  end
  function window:IsOpen()
    return slidDown ~= true
  end
  function window:Notify(n) UI.Notify(self, n) end
  
  closeBtn.MouseButton1Click:Connect(function()
    window:Toggle()
  end)

  makeDraggable(top, shell, bindConnection, setOpenPosition, setOpenPosition)
  makeDraggable(island, shell, bindConnection, setOpenPosition, setOpenPosition)

  shell.Position = UDim2.new(0.5, -sz.X / 2, 0.5, -sz.Y / 2 + 38)
  root.BackgroundTransparency = 1
  rootScale.Scale = 0.94
  root.Visible = false
  shell.Visible = true
  
  local startupSettled = false
  local activeSplash = nil
  local function revealWindow(instant, clearSplash)
    startupSettled = true
    pcall(function() gui.Enabled = true end)
    shell.Visible = true
    root.Visible = true
    if instant then
      shell.Position = openPos
      root.BackgroundTransparency = 0
      rootScale.Scale = 1
    else
      tween(shell, theme.Anim.Slow, {Position = openPos}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
      tween(root, theme.Anim.Slow, {BackgroundTransparency = 0})
      tween(rootScale, theme.Anim.Slow, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    if clearSplash and activeSplash and activeSplash.Parent then
      activeSplash:Destroy()
      activeSplash = nil
    end
  end
  
  task.delay(5.6, function()
    if not startupSettled then
      revealWindow(true, true)
    end
  end)
  
  task.spawn(function()
    local okSplash = pcall(function()
    local splash = make("Frame", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundColor3 = theme.Colors.BgA,
      BackgroundTransparency = 0.02,
      BorderSizePixel = 0,
      Parent = gui,
    })
    activeSplash = splash
    local sgrad = make("UIGradient", {
      Rotation = 24,
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Colors.BgB),
        ColorSequenceKeypoint.new(0.55, theme.Colors.Input),
        ColorSequenceKeypoint.new(1, theme.Colors.BgA),
      }),
      Parent = splash,
    })
    splash.BackgroundTransparency = 1
    local flare = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, 0, 0, 2),
      Position = UDim2.new(0.5, 0, 0.5, 118),
      BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Parent = splash,
    })
    corner(flare, 999)
    local mark = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 152, 0, 152),
      Position = UDim2.new(0.5, 0, 0.5, -36),
      Parent = splash,
    })
    local markScale = make("UIScale", {Scale = 0.88, Parent = mark})
    local splashRingLogo = nil
    if logoRingSource then
      splashRingLogo = make("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0.58, 0, 0.58, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Image = logoRingSource,
        ImageTransparency = 1,
        Rotation = -10,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 18,
        Parent = mark,
      })
      if typeof(logoRectOffset) == "Vector2" and typeof(logoRectSize) == "Vector2" then
        splashRingLogo.ImageRectOffset = logoRectOffset
        splashRingLogo.ImageRectSize = logoRectSize
      end
    end
    local splashLogo = nil
    if logoSource then
      splashLogo = make("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0.86, 0, 0.86, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Image = logoSource,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 20,
        Parent = mark,
      })
      if typeof(logoRectOffset) == "Vector2" and typeof(logoRectSize) == "Vector2" then
        splashLogo.ImageRectOffset = logoRectOffset
        splashLogo.ImageRectSize = logoRectSize
      end
    end
    local outerRing = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 44, 0, 44),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Rotation = -38,
      Parent = mark,
    })
    corner(outerRing, 999)
    local outerStroke = stroke(outerRing, theme.Colors.Accent2 or theme.Colors.Accent, 10, 1)
    local innerRing = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 34, 0, 34),
      Position = UDim2.new(0.5, -6, 0.5, 2),
      Rotation = -30,
      Parent = mark,
    })
    corner(innerRing, 999)
    local innerStroke = stroke(innerRing, theme.Colors.Accent, 4, 1)
    local codeLeft = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 42, 0, 50),
      Position = UDim2.new(0.18, -12, 0.5, -25),
      Font = Enum.Font.GothamBold,
      TextSize = 42,
      Text = "<",
      TextColor3 = theme.Colors.Accent3 or theme.Colors.Accent,
      TextTransparency = 1,
      Parent = mark,
    })
    local codeSlash = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 34, 0, 70),
      Position = UDim2.new(0.5, -17, 0.5, -35),
      Font = Enum.Font.GothamBold,
      TextSize = 50,
      Text = "/",
      TextColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      TextTransparency = 1,
      Parent = mark,
    })
    local codeRight = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 42, 0, 50),
      Position = UDim2.new(0.82, -30, 0.5, -25),
      Font = Enum.Font.GothamBold,
      TextSize = 42,
      Text = ">",
      TextColor3 = theme.Colors.Accent3 or theme.Colors.Accent,
      TextTransparency = 1,
      Parent = mark,
    })
    local robloxSymbol = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, 34, 0, 34),
      Position = UDim2.new(0.72, 26, 0.72, 18),
      Rotation = 22,
      BackgroundColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Parent = mark,
    })
    corner(robloxSymbol, 7)
    local robloxHole = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, 12, 0, 12),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Rotation = 0,
      BackgroundColor3 = theme.Colors.BgA,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Parent = robloxSymbol,
    })
    corner(robloxHole, 2)
    local stext = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 50),
      Position = UDim2.new(0, 0, 0.5, 52),
      Font = Enum.Font.GothamBold,
      TextSize = 30,
      Text = tostring(opts.LoadingTitle or opts.Title or opts.Name or "NovaX"),
      TextColor3 = theme.Colors.Text,
      TextTransparency = 1,
      Parent = splash,
    })
    local subText = make("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 24),
      Position = UDim2.new(0, 0, 0.5, 90),
      Font = theme.Font,
      TextSize = 13,
      Text = tostring(opts.LoadingSubtitle or opts.Subtitle or "Loading interface"),
      TextColor3 = theme.Colors.TextDim,
      TextTransparency = 1,
      Parent = splash,
    })
    local symbolRow = make("Frame", {
      AnchorPoint = Vector2.new(0.5, 0),
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 132, 0, 10),
      Position = UDim2.new(0.5, 0, 0.5, 124),
      Parent = splash,
    })
    local progressBars = {}
    for i = 1, 5 do
      local bar = make("Frame", {
        Size = UDim2.new(0, 24, 0, 4),
        Position = UDim2.new(0, (i - 1) * 27, 0, 3),
        BackgroundColor3 = i == 3 and (theme.Colors.Accent2 or theme.Colors.Accent) or theme.Colors.Accent3 or theme.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = symbolRow,
      })
      corner(bar, 999)
      progressBars[i] = bar
    end
    outerRing.Visible = splashRingLogo == nil
    innerRing.Visible = splashLogo == nil and splashRingLogo == nil
    if splashLogo then
      codeLeft.Visible = false
      codeSlash.Visible = false
      codeRight.Visible = false
      robloxSymbol.Visible = false
      robloxHole.Visible = false
    end
    
    tween(splash, theme.Anim.Splash * 0.18, {BackgroundTransparency = 0.02})
    tween(sgrad, theme.Anim.Splash * 1.05, {Rotation = 38}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    tween(flare, theme.Anim.Splash * 0.34, {Size = UDim2.new(0, 230, 0, 2), BackgroundTransparency = 0.34}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(markScale, theme.Anim.Splash * 0.84, {Scale = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(stext, theme.Anim.Splash * 0.28, {TextTransparency = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    task.wait(theme.Anim.Splash * 0.2)
    if splashRingLogo then
      tween(splashRingLogo, theme.Anim.Splash * 0.68, {
        Size = UDim2.new(0.86, 0, 0.86, 0),
        ImageTransparency = 0,
        Rotation = 0,
      }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end
    tween(outerRing, theme.Anim.Splash * 0.78, {Size = UDim2.new(0, 132, 0, 132), Rotation = 4}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(innerRing, theme.Anim.Splash * 0.78, {Size = UDim2.new(0, 116, 0, 116), Rotation = 7}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(outerStroke, theme.Anim.Splash * 0.62, {Transparency = 0.04}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    tween(innerStroke, theme.Anim.Splash * 0.62, {Transparency = 0.22}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if splashLogo then
      task.delay(theme.Anim.Splash * 0.18, function()
        if splashLogo and splashLogo.Parent then
          tween(splashLogo, theme.Anim.Splash * 0.46, {ImageTransparency = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
      end)
    end
    tween(subText, theme.Anim.Splash * 0.28, {TextTransparency = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    task.wait(theme.Anim.Splash * 0.4)
    tween(codeLeft, theme.Anim.Splash * 0.3, {TextTransparency = 0, Position = UDim2.new(0.2, -12, 0.5, -25)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(codeSlash, theme.Anim.Splash * 0.34, {TextTransparency = 0}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(codeRight, theme.Anim.Splash * 0.3, {TextTransparency = 0, Position = UDim2.new(0.8, -30, 0.5, -25)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    task.wait(theme.Anim.Splash * 0.24)
    tween(robloxSymbol, theme.Anim.Splash * 0.3, {BackgroundTransparency = 0.05, Rotation = 14, Size = UDim2.new(0, 40, 0, 40)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(robloxHole, theme.Anim.Splash * 0.3, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    for i, bar in ipairs(progressBars) do
      task.delay((i - 1) * 0.035, function()
        if bar and bar.Parent then
          tween(bar, theme.Anim.Fast, {BackgroundTransparency = i == 3 and 0.1 or 0.45})
        end
      end)
    end
    task.wait(theme.Anim.Splash * 0.52)
    revealWindow(false, false)
    task.wait(theme.Anim.Splash * 0.06)
    tween(splash, theme.Anim.Splash * 0.45, {BackgroundTransparency = 1})
    tween(stext, theme.Anim.Splash * 0.45, {TextTransparency = 1})
    tween(subText, theme.Anim.Splash * 0.45, {TextTransparency = 1})
    tween(outerStroke, theme.Anim.Splash * 0.35, {Transparency = 1})
    tween(innerStroke, theme.Anim.Splash * 0.35, {Transparency = 1})
    tween(codeLeft, theme.Anim.Splash * 0.35, {TextTransparency = 1})
    tween(codeSlash, theme.Anim.Splash * 0.35, {TextTransparency = 1})
    tween(codeRight, theme.Anim.Splash * 0.35, {TextTransparency = 1})
    tween(robloxSymbol, theme.Anim.Splash * 0.35, {BackgroundTransparency = 1})
    tween(robloxHole, theme.Anim.Splash * 0.35, {BackgroundTransparency = 1})
    if splashRingLogo then
      tween(splashRingLogo, theme.Anim.Splash * 0.35, {ImageTransparency = 1})
    end
    if splashLogo then
      tween(splashLogo, theme.Anim.Splash * 0.35, {ImageTransparency = 1})
    end
    tween(flare, theme.Anim.Splash * 0.35, {BackgroundTransparency = 1})
    for _, bar in ipairs(progressBars) do
      tween(bar, theme.Anim.Splash * 0.35, {BackgroundTransparency = 1})
    end
    task.wait(theme.Anim.Splash * 0.45)
    if splash and splash.Parent then splash:Destroy() end
    if activeSplash == splash then activeSplash = nil end
    end)
    if not okSplash then
      revealWindow(false, true)
    end
  end)

  if opts.ShowWelcome == true then
    window:Notify({Title = tostring(opts.Title or "Nova Premium UI"), Content = "Initialized", Duration = 5})
  end

  if UI.Debug then
    warn("[NovaPremiumUI][debug] CreateWindow completed for:", tostring(opts.Name or "NovaPremiumUI"))
  end
  return window
end

function UI:CreateConfigManager(window, stateTable, opts)
  opts = opts or {}
  local folder = tostring(opts.Folder or "NovaConfigs")
  local defaultName = tostring(opts.DefaultName or "default")
  local sync = opts.Sync
  local tabName = tostring(opts.TabName or "Configs")
  local activeName = defaultName
  local selectedName = defaultName
  local configList
  local configInput
  local busy = false
  local refresh
  local hiddenDeleted = {}

  local function cleanName(name)
    local raw = tostring(name or defaultName)
    local clean = raw:gsub("[^%w_%-%s]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "_")
    return clean ~= "" and clean or defaultName
  end

  local function ensureFolder()
    if typeof(makefolder) == "function" and typeof(isfolder) == "function" and not isfolder(folder) then
      pcall(function() makefolder(folder) end)
    end
  end

  local function pathFor(name)
    return folder .. "/" .. cleanName(name) .. ".json"
  end

  local manager = {}
  
  local function notifyConfig(title, content)
    if window and window.Notify then
      window:Notify({Title = tostring(title or "Config"), Content = tostring(content or ""), Duration = 5})
    end
  end
  
  local function fileExists(name)
    return typeof(isfile) == "function" and isfile(pathFor(name))
  end
  
  local function uniqueName(base)
    local root = cleanName(base or "config")
    local used = {}
    for _, item in ipairs(manager:List()) do
      used[tostring(item)] = true
    end
    if not used[root] and not fileExists(root) then
      return root
    end
    for index = 1, 999 do
      local candidate = cleanName(root .. "_" .. tostring(index))
      if not used[candidate] and not fileExists(candidate) then
        return candidate
      end
    end
    return cleanName(root .. "_" .. tostring(math.floor(tick())))
  end

  function manager:List()
    ensureFolder()
    local out = {}
    if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(folder) then
      local ok, files = pcall(function() return listfiles(folder) end)
      if ok and type(files) == "table" then
        for index = 1, #files do
          local f = files[index]
          local n = tostring(f):match("([^/\\]+)%.json$")
          if n and not hiddenDeleted[n] then table.insert(out, n) end
        end
      end
    end
    table.sort(out)
    if #out == 0 then table.insert(out, defaultName) end
    return out
  end

  function manager:Save(name)
    ensureFolder()
    if typeof(writefile) ~= "function" then return false, "writefile unavailable" end
    local targetName = cleanName(name or activeName)
    local payload = {}
    for k, v in pairs(stateTable or {}) do
      local tv = type(v)
      if tv == "boolean" or tv == "number" or tv == "string" then
        payload[k] = v
      end
    end
    local ok, err = pcall(function()
      writefile(pathFor(targetName), HttpService:JSONEncode(payload))
    end)
    if ok then
      activeName = targetName
      selectedName = targetName
      hiddenDeleted[targetName] = nil
    end
    return ok, ok and targetName or tostring(err)
  end

  function manager:Load(name)
    ensureFolder()
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return false, "readfile/isfile unavailable" end
    local targetName = cleanName(name or activeName)
    local path = pathFor(targetName)
    if not isfile(path) then return false, "config missing" end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(data) ~= "table" then return false, "invalid config" end
    for k, v in pairs(data) do
      if stateTable and stateTable[k] ~= nil and type(stateTable[k]) == type(v) then
        stateTable[k] = v
      end
    end
    if type(sync) == "function" then pcall(sync, stateTable) end
    activeName = targetName
    selectedName = targetName
    return true, targetName
  end

  function manager:Delete(name)
    if typeof(delfile) ~= "function" then return false, "delfile unavailable" end
    local targetName = cleanName(name or activeName)
    local path = pathFor(targetName)
    if typeof(isfile) == "function" and not isfile(path) then
      hiddenDeleted[targetName] = true
      return true, targetName
    end
    local ok, err = pcall(function() delfile(path) end)
    if ok then
      hiddenDeleted[targetName] = true
    end
    if ok and activeName == targetName then
      activeName = defaultName
      selectedName = defaultName
    end
    return ok, ok and targetName or tostring(err)
  end
  
  function manager:Rename(oldName, newName)
    ensureFolder()
    if typeof(readfile) ~= "function" or typeof(writefile) ~= "function" then
      return false, "readfile/writefile unavailable"
    end
    local sourceName = cleanName(oldName or selectedName or activeName)
    local targetName = cleanName(newName or sourceName)
    if sourceName == targetName then
      activeName = targetName
      selectedName = targetName
      return true, targetName
    end
    local sourcePath = pathFor(sourceName)
    local targetPath = pathFor(targetName)
    if typeof(isfile) == "function" and not isfile(sourcePath) then
      return false, "source config missing"
    end
    if typeof(isfile) == "function" and isfile(targetPath) then
      return false, "target config exists"
    end
    local okRead, data = pcall(function() return readfile(sourcePath) end)
    if not okRead then
      return false, tostring(data)
    end
    local okWrite, writeErr = pcall(function() writefile(targetPath, data) end)
    if not okWrite then
      return false, tostring(writeErr)
    end
    if typeof(delfile) == "function" then
      pcall(function() delfile(sourcePath) end)
    end
    hiddenDeleted[sourceName] = true
    hiddenDeleted[targetName] = nil
    activeName = targetName
    selectedName = targetName
    return true, targetName
  end

  if window and window.CreateTab then
    local tab = window:CreateTab(tabName)
    configInput = tab:CreateInput({
      Name = "Config Name",
      CurrentValue = activeName,
      PlaceholderText = defaultName,
      Callback = function() end,
    })
    local listFactory = tab.CreateConfigList or tab.CreateOptionPicker or tab.CreateDropdown
    if listFactory then
      configList = listFactory(tab, {
        Name = "Saved Configs",
        Options = manager:List(),
        CurrentOption = {activeName},
        ListHeight = 232,
        DefaultName = defaultName,
        Callback = function(v)
          selectedName = cleanName(type(v) == "table" and v[1] or v)
          activeName = selectedName
          if configInput and configInput.Set then
            configInput:Set(selectedName)
          end
        end,
      })
    end
    local function currentInputName()
      if configInput and configInput.Get then
        local raw = tostring(configInput:Get() or "")
        if raw ~= "" then
          return cleanName(raw)
        end
      end
      return cleanName(activeName)
    end
    local function currentSelectedName()
      return cleanName(selectedName or activeName or currentInputName())
    end
    local function runConfigAction(action)
      if busy then return false end
      busy = true
      local ok, err = pcall(action)
      if not ok then
        if UI.Debug then warn("[NovaPremiumUI] Config action failed: " .. tostring(err)) end
        notifyConfig("Config Fehler", tostring(err))
      end
      busy = false
      return ok
    end
    local function confirmOverwrite(targetName, confirmed)
      if fileExists(targetName) and window and window.Confirm then
        window:Confirm({
          Title = "Config ersetzen",
          Content = "Es besteht bereits eine Config mit diesem Namen. Möchtest du sie ersetzen?",
          ConfirmText = "Ersetzen",
          CancelText = "Abbrechen",
          ConfirmCallback = confirmed,
        })
      else
        confirmed()
      end
    end
    refresh = function(selectName)
      if configList and configList.Refresh then
        local names = manager:List()
        local selected = cleanName(selectName or activeName)
        local exists = false
        for _, item in ipairs(names) do
          if tostring(item) == selected then
            exists = true
            break
          end
        end
        if not exists then
          selected = names[1] or defaultName
        end
        activeName = selected
        selectedName = selected
        configList:Refresh(names)
        if configList.Set then
          configList:Set(selected)
        end
        if configInput and configInput.Set then
          configInput:Set(selected)
        end
      elseif configInput and configInput.Set then
        configInput:Set(cleanName(selectName or activeName))
      end
    end
    tab.OnShow = function()
      refresh(selectedName or activeName)
    end
    local function saveCurrent()
      local targetName = currentInputName()
      local function doSave()
        runConfigAction(function()
          local ok, saved = manager:Save(targetName)
          notifyConfig(ok and "Config gespeichert" or "Config Fehler", ok and ("Gespeichert: " .. tostring(saved)) or tostring(saved))
          refresh(ok and saved or activeName)
        end)
      end
      if fileExists(targetName) then
        confirmOverwrite(targetName, doSave)
      else
        doSave()
      end
    end
    
    local function createNew()
      runConfigAction(function()
        local name = uniqueName("config")
        local ok, saved = manager:Save(name)
        notifyConfig(ok and "Config erstellt" or "Config Fehler", ok and ("Erstellt: " .. tostring(saved)) or tostring(saved))
        refresh(ok and saved or activeName)
      end)
    end
    
    local function loadSelected()
      runConfigAction(function()
        local ok, loaded = manager:Load(currentSelectedName())
        notifyConfig(ok and "Config geladen" or "Config Fehler", ok and ("Geladen: " .. tostring(loaded)) or tostring(loaded))
        refresh(ok and loaded or activeName)
      end)
    end
    
    local function deleteSelectedAction()
      local targetName = currentSelectedName()
      local function deleteSelected()
        runConfigAction(function()
          local ok, deleted = manager:Delete(targetName)
          notifyConfig(ok and "Config geloescht" or "Config Fehler", ok and ("Geloescht: " .. tostring(deleted)) or tostring(deleted))
          refresh()
        end)
      end
      if window and window.Confirm then
        window:Confirm({
          Title = "Config loeschen",
          Content = "Moechtest du wirklich Config \"" .. tostring(targetName) .. "\" loeschen?",
          ConfirmText = "Loeschen",
          CancelText = "Abbrechen",
          ConfirmCallback = deleteSelected,
        })
      else
        deleteSelected()
      end
    end
    
    if tab.CreateActionGroup then
      tab:CreateActionGroup({
        Name = "Config Actions",
        Actions = {
          {Name = "Save", Style = "Primary", Callback = saveCurrent},
          {Name = "New", Style = "Primary", Callback = createNew},
          {Name = "Load", Style = "Primary", Callback = loadSelected},
          {Name = "Delete", Style = "Primary", Callback = deleteSelectedAction},
        },
        AllBlue = true,
      })
    else
      tab:CreateButton({Name = "Save", Callback = saveCurrent})
      tab:CreateButton({Name = "New", Callback = createNew})
      tab:CreateButton({Name = "Load", Callback = loadSelected})
      tab:CreateButton({Name = "Delete", Callback = deleteSelectedAction})
    end
    refresh(activeName)
  end

  return manager
end

local exported = setmetatable({}, UI)

if getgenv then
  getgenv().NovaPremiumUI = exported
end

return exported
