-- NovaX Complete Script (Optimized for Xeno)
-- Combined NovaPremiumUI Library and Main Script
-- version: library-backed standalone

local __NX_GLOBAL = (getgenv and getgenv()) or nil
if __NX_GLOBAL and (__NX_GLOBAL.NX_XENO == true or __NX_GLOBAL.NX_XENO_LOADING == true or type(__NX_GLOBAL.NX_CLEANUP) == "function") then
  local __NX_EXISTING_GUI = __NX_GLOBAL.NX_UI_GUI
  local __NX_EXISTING_ROOT = __NX_GLOBAL.NX_UI_ROOT
  local __NX_HAS_VISIBLE_GUI = false
  pcall(function()
    __NX_HAS_VISIBLE_GUI =
      typeof(__NX_EXISTING_GUI) == "Instance"
      and __NX_EXISTING_GUI.Parent ~= nil
      and __NX_EXISTING_GUI.Enabled ~= false
      and (
        typeof(__NX_EXISTING_ROOT) ~= "Instance"
        or (__NX_EXISTING_ROOT.Parent ~= nil and __NX_EXISTING_ROOT.Visible ~= false)
      )
  end)
  if __NX_GLOBAL.NX_GUI_READY == true and __NX_HAS_VISIBLE_GUI then
    return {
      Stopped = true,
      Reason = "already_running",
    }
  end
  pcall(function()
    if type(__NX_GLOBAL.NX_CLEANUP) == "function" then
      __NX_GLOBAL.NX_CLEANUP()
    elseif typeof(__NX_EXISTING_GUI) == "Instance" and __NX_EXISTING_GUI.Parent then
      __NX_EXISTING_GUI:Destroy()
    end
  end)
  __NX_GLOBAL.NX_XENO = nil
  __NX_GLOBAL.NX_XENO_LOADING = nil
  __NX_GLOBAL.NX_CLEANUP = nil
  __NX_GLOBAL.NX_GUI_READY = nil
  __NX_GLOBAL.NX_UI_WINDOW = nil
  __NX_GLOBAL.NX_UI_GUI = nil
  __NX_GLOBAL.NX_UI_ROOT = nil
end
if __NX_GLOBAL then
  __NX_GLOBAL.NX_XENO_LOADING = true
  __NX_GLOBAL.NX_GUI_READY = false
  __NX_GLOBAL.NX_UI_WINDOW = nil
  __NX_GLOBAL.NX_UI_GUI = nil
  __NX_GLOBAL.NX_UI_ROOT = nil
end

-- =============== NOVA PREMIUM UI LIBRARY ===============
local NovaPremiumUI = (function()
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

    function tab:CreatePlayerSearch(cfg)
      cfg = cfg or {}
      local opts = cfg.Options or {"None"}
      local current = cfg.CurrentOption
      if type(current) == "table" then current = current[1] end
      current = tostring(current or opts[1] or "None")
      local placeholder = tostring(cfg.PlaceholderText or "Search player...")
      local maxListHeight = math.clamp(tonumber(cfg.ListHeight) or 198, 120, 280)

      local holder = make("Frame", {
        Name = "NovaPlayerSearchHolder",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 60,
        Parent = p,
      })

      local row, glow = makeControlBase(p, theme, 42)
      row.Name = "NovaPlayerSearchRow"
      row.Parent = holder
      row.ZIndex = 61

      local btn = make("TextButton", {
        Size = UDim2.new(1, -14, 1, 0),
        Position = UDim2.new(0, 7, 0, 0),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 62,
        Parent = row,
      })

      local lbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -72, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        Font = theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = theme.Colors.Text,
        ZIndex = 63,
        Parent = btn,
      })

      local searchPill = make("TextLabel", {
        BackgroundColor3 = theme.Colors.Input,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -24, 0.5, 0),
        Size = UDim2.new(0, 44, 0, 20),
        Font = theme.Font,
        TextSize = 10,
        TextColor3 = theme.Colors.TextDim,
        Text = "Find",
        ZIndex = 63,
        Parent = btn,
      })
      corner(searchPill, math.max(6, theme.Radius - 6))
      stroke(searchPill, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.55)

      local arrow = make("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        Font = theme.Font,
        TextSize = 14,
        TextColor3 = theme.Colors.TextDim,
        Text = ">",
        ZIndex = 63,
        Parent = btn,
      })

      local panel = make("Frame", {
        Name = "NovaPlayerSearchPanel",
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.new(0, 4, 0, 48),
        BackgroundColor3 = theme.Colors.Input,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 88,
        Parent = holder,
      })
      corner(panel, theme.Radius - 2)
      stroke(panel, theme.Colors.Stroke, 1, 0.45)

      local searchBox = make("TextBox", {
        Name = "NovaPlayerSearchBox",
        Size = UDim2.new(1, -12, 0, 30),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundColor3 = theme.Colors.Surface,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = theme.Font,
        TextSize = 12,
        TextColor3 = theme.Colors.Text,
        PlaceholderText = placeholder,
        PlaceholderColor3 = theme.Colors.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "",
        ZIndex = 90,
        Parent = panel,
      })
      corner(searchBox, theme.Radius - 4)
      stroke(searchBox, theme.Colors.StrokeSoft or theme.Colors.Stroke, 1, 0.5)
      make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        Parent = searchBox,
      })

      local listFrame = make("ScrollingFrame", {
        Name = "NovaPlayerSearchList",
        Size = UDim2.new(1, -12, 1, -44),
        Position = UDim2.new(0, 6, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Colors.Accent2 or theme.Colors.Accent,
        ScrollBarImageTransparency = 0.45,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        CanvasPosition = Vector2.new(0, 0),
        ZIndex = 89,
        Parent = panel,
      })
      pcall(function()
        listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
      end)
      local listLayout = make("UIListLayout", {Padding = UDim.new(0, 4), Parent = listFrame})
      attachSmoothScroll(listFrame, theme, bindConnection)

      local opened = false
      local itemButtons = {}
      local filtered = {}

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

      local function updateLabel()
        lbl.Text = string.format("%s: %s", tostring(cfg.Name or "Player"), tostring(current or "None"))
      end

      local function clearItems()
        for _, item in ipairs(itemButtons) do
          if item and item.Parent then
            item:Destroy()
          end
        end
        itemButtons = {}
      end

      local function setValue(v, fireCallback)
        if type(v) == "table" then
          v = v[1]
        end
        current = tostring(v or "None")
        updateLabel()
        if fireCallback then
          safeCallback(cfg.Callback, current)
        end
      end

      local function rebuildFiltered()
        clearItems()
        filtered = {}
        local q = string.lower(tostring(searchBox.Text or ""))
        for _, opt in ipairs(opts) do
          local label = tostring(opt)
          if q == "" or string.find(string.lower(label), q, 1, true) then
            filtered[#filtered + 1] = label
          end
        end
        if #filtered == 0 then
          filtered[1] = "None"
        end

        for _, val in ipairs(filtered) do
          local active = tostring(val) == tostring(current)
          local item = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = active and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            AutoButtonColor = false,
            Font = theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = active and theme.Colors.Text or theme.Colors.TextDim,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = "  " .. val,
            ZIndex = 91,
            Parent = listFrame,
          })
          corner(item, theme.Radius - 4)
          item.MouseEnter:Connect(function()
            tween(item, theme.Anim.Fast, {BackgroundColor3 = theme.Colors.Hover or theme.Colors.Surface2, TextColor3 = theme.Colors.Text})
          end)
          item.MouseLeave:Connect(function()
            local isActive = tostring(val) == tostring(current)
            tween(item, theme.Anim.Fast, {
              BackgroundColor3 = isActive and (theme.Colors.Active or theme.Colors.Surface3) or theme.Colors.Surface,
              TextColor3 = isActive and theme.Colors.Text or theme.Colors.TextDim,
            })
          end)
          item.MouseButton1Down:Connect(function()
            setValue(val, true)
            opened = false
            tween(panel, theme.Anim.Normal, {Size = UDim2.new(1, -8, 0, 0)})
            tween(arrow, theme.Anim.Fast, {Rotation = 0})
            tween(glow, theme.Anim.Fast, {BackgroundTransparency = 0.93})
            holder.Size = UDim2.new(1, 0, 0, 42)
            task.delay(theme.Anim.Normal + 0.03, function()
              if not opened and panel and panel.Parent then
                panel.Visible = false
              end
            end)
          end)
          itemButtons[#itemButtons + 1] = item
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(listLayout.AbsoluteContentSize.Y + 6, (#filtered * 34) + 6))
      end

      local function setOpened(v)
        opened = v == true
        panel.Visible = true
        if opened then
          searchBox.Text = ""
          listFrame.CanvasPosition = Vector2.new(0, 0)
          rebuildFiltered()
          task.defer(function()
            pcall(function() searchBox:CaptureFocus() end)
          end)
        end
        local contentHeight = math.max(78, math.min(maxListHeight, 46 + (#filtered * 34)))
        local h = opened and contentHeight or 0
        holder.Size = UDim2.new(1, 0, 0, 42 + (opened and h + 6 or 0))
        tween(panel, theme.Anim.Normal, {Size = UDim2.new(1, -8, 0, h)})
        tween(arrow, theme.Anim.Fast, {Rotation = opened and 90 or 0})
        tween(glow, theme.Anim.Fast, {BackgroundTransparency = opened and 0.84 or 0.93})
        tween(searchPill, theme.Anim.Fast, {BackgroundTransparency = opened and 0.02 or 0.08})
        if not opened then
          pcall(function() searchBox:ReleaseFocus() end)
          task.delay(theme.Anim.Normal + 0.03, function()
            if not opened and panel and panel.Parent then
              panel.Visible = false
            end
          end)
        end
      end

      bindConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if opened then
          rebuildFiltered()
        end
      end))
      bindConnection(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
      end))
      btn.MouseButton1Down:Connect(function()
        addRipple(btn, theme)
        setOpened(not opened)
      end)

      opts = normalizeOptions(opts)
      updateLabel()
      rebuildFiltered()
      setOpened(false)

      local ctrl = {
        Frame = holder,
        _token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current))),
        SetVisible = function(_, v) holder.Visible = v end,
        Set = function(self, v)
          setValue(v, false)
          rebuildFiltered()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetValue = function(self, v)
          setValue(v, false)
          rebuildFiltered()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        Refresh = function(self, newOpts)
          opts = normalizeOptions(newOpts)
          rebuildFiltered()
          self._token = string.lower(string.format("%s %s", tostring(cfg.Name or ""), tostring(current)))
        end,
        SetOptions = function(self, newOpts)
          opts = normalizeOptions(newOpts)
          rebuildFiltered()
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
end)()

if getgenv then
  getgenv().NovaPremiumUI = NovaPremiumUI
end

-- =============== NOVAX MAIN SCRIPT ===============

-- XENO EXECUTOR CHECK
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.2)

local NX_DEBUG = false
local NX_SHOW_NOTIFICATIONS = true
local NX_SUPPRESS_CONSOLE = true
local function nxShouldSuppressConsole(...)
  if not NX_SUPPRESS_CONSOLE then
    return false
  end
  local parts = {}
  for i = 1, select("#", ...) do
    parts[i] = tostring(select(i, ...))
  end
  local msg = table.concat(parts, " ")
  if msg:find("[NovaX]", 1, true) or msg:find("[NovaPremiumUI]", 1, true) then
    return true
  end
  return msg:find("Infinite yield possible", 1, true) ~= nil
    and msg:find("WaitForChild(\"Waist\")", 1, true) ~= nil
end
pcall(function()
  local gv = getgenv and getgenv()
  if not gv or gv.NX_WARN_FILTER_ACTIVE then
    return
  end
  gv.NX_WARN_FILTER_ACTIVE = true
  gv.NX_ORIGINAL_WARN = gv.NX_ORIGINAL_WARN or warn
  if typeof(hookfunction) == "function" and typeof(newcclosure) == "function" then
    hookfunction(warn, newcclosure(function(...)
      if nxShouldSuppressConsole(...) then
        return nil
      end
      return gv.NX_ORIGINAL_WARN(...)
    end))
  else
    warn = function(...)
      if nxShouldSuppressConsole(...) then
        return nil
      end
      return gv.NX_ORIGINAL_WARN(...)
    end
  end
end)
function nxWarn(...)
  if NX_DEBUG then
    warn(...)
  end
end
local cleanup
local setupESP
local cleanAllESP = function() end
local clearAimTargetHighlight = function() end
local restoreDeviceSpoof = function() end
local applyDeviceSpoof = function() return false end
local restoreSoftSpoof = function() end
local applySoftSpoof = function() return true end
local applyReplicationControlSpoof = function() return false end
local restoreAntiHitPose = function() end
local restoreAntiHitHitbox = function() end
local aimTarget
local aimLockedPlayer
local aimLockLostSince
local autoAimTarget
local autoAimLockedPlayer
local autoAimSmoothedPos
local autoAimPredictedPos
local autoAimLastPart
local autoAimLastRawPos
local autoAimVelocity
local autoAimLostSince
local autoAimReleaseUntil
local autoAimManualBreakUntil
local autoAimBreakScore
local autoAimMixedUseHead
local autoAimMixedNextSwitch
local autoAimMixedBlend
local mouseAssistTarget
local mouseAssistLockedPlayer
local mouseAssistLostSince
local mouseAssistSmoothedPos
local rageTarget
local rageLockedPlayer
local rageNextShotAt
local rageMixedUseHead
local rageMixedNextSwitch
local rageMixedBlend
local restoreRageWeaponLock = function() end
local lockEquippedToolToPosition = function() return false end
local mouseStepState
local mouseRemainderState
local mouseMoveSignByMode
local mouseDirectionProbe
local aimLockMouseState
local aimLockMouseRemainder
local aimLockMouseSign
local aimLockDirectionProbe
local injectedMouseDelta
local injectedMouseAt
local controlSpoofRemote
local lastControlSpoofMode
local lastControlSpoofAt
local antiVoidNextAt
local setFB, setNF, setFPS, setFPSBoost, setupGrabber
local UI_WINDOW = nil

if getgenv then
  local gv = getgenv()
  gv.NX_XENO_LOADING = nil
  gv.NX_XENO = true
  gv.NX_CLEANUP = function()
    if cleanup then cleanup() end
  end
end

math.randomseed(tick() * 1000)

--  SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = nil
pcall(function()
  VirtualInputManager = game:GetService("VirtualInputManager")
end)
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local debugLib = type(debug) == "table" and debug or nil
local debugGetUpvalue = debugLib and rawget(debugLib, "getupvalue") or nil
local SUPPORT = {
  MetaHook = (getrawmetatable and setreadonly and newcclosure and getnamecallmethod) ~= nil,
  HookFunction = (hookfunction ~= nil),
  GetConnections = (getconnections ~= nil),
  Debug = debugGetUpvalue ~= nil,
}

-- Character-Basisdaten werden lazy abgefragt. Die GUI darf dadurch nie blockieren.

local V3, CF = Vector3.new, CFrame.new
local clamp, floor, huge = math.clamp, math.floor, math.huge
local V0, UP = Vector3.zero, V3(0, 1, 0)
local MF = V3(1, 1, 1) * 9e4

--  XENO-SAFE FUNCTIONS

function safeNum(v)
  if v == nil then return 0 end
  return tonumber(v) or 0
end

function notify(title, msg, dur)
  if not NX_SHOW_NOTIFICATIONS then
    return false
  end
  local duration = tonumber(dur)
  if not duration or duration <= 0 then
    duration = 6
  elseif duration < 5 then
    duration = 5
  end
  
  task.spawn(function()
    pcall(function()
      StarterGui:SetCore("SendNotification", {
        Title = tostring(title),
        Text = tostring(msg),
        Duration = duration
      })
    end)
  end)
  return true
end

local lastLeftClickAt, lastRightClickAt = 0, 0
local MAX_TRIGGER_CPS = 500
local MIN_SHOT_INTERVAL = 1 / MAX_TRIGGER_CPS
local MIN_RIGHT_CLICK_INTERVAL = 0.25

function activateEquippedTool()
  local char = LocalPlayer and LocalPlayer.Character
  local tool = char and char:FindFirstChildOfClass("Tool")
  if not tool then
    return false
  end
  return pcall(function()
    tool:Activate()
  end)
end

function sendMouseButton(button, interval)
  local now = tick()
  if button == 0 then
    if now - lastLeftClickAt < interval then
      return false
    end
    lastLeftClickAt = now
  else
    if now - lastRightClickAt < interval then
      return false
    end
    lastRightClickAt = now
  end

  if not VirtualInputManager or typeof(VirtualInputManager.SendMouseButtonEvent) ~= "function" then
    return button == 0 and activateEquippedTool() or false
  end

  local x, y = 0, 0
  pcall(function()
    local pos = UserInputService:GetMouseLocation()
    x, y = pos.X, pos.Y
  end)

  local ok = pcall(function()
    VirtualInputManager:SendMouseButtonEvent(x, y, button, true, game, 0)
    task.wait(math.clamp((tonumber(interval) or MIN_SHOT_INTERVAL) * 0.35, 0.001, 0.01))
    VirtualInputManager:SendMouseButtonEvent(x, y, button, false, game, 0)
  end)
  if ok then
    return true
  end
  return button == 0 and activateEquippedTool() or false
end

function click(interval)
  return sendMouseButton(0, interval or MIN_SHOT_INTERVAL)
end

function safeHook(setupFunc, featureName)
  if not setupFunc then return false end
  
  local ok, result = pcall(setupFunc)
  if not ok then
    nxWarn("[NovaX] " .. tostring(featureName) .. " failed -> disabled")
    return false
  end
  
  if result == false then
    nxWarn("[NovaX] " .. tostring(featureName) .. " not supported -> skipped")
    return false
  end
  
  return true
end

--  CONTROL
local RUNNING = true
local CONNECTIONS = {}

function addConnection(name, conn)
  if not conn then return end
  if CONNECTIONS[name] then
    pcall(function() CONNECTIONS[name]:Disconnect() end)
  end
  CONNECTIONS[name] = conn
end

addConnection("camera", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
  while RUNNING and not workspace.CurrentCamera do
    task.wait()
  end
  Camera = workspace.CurrentCamera
end))

cleanup = function()
  RUNNING = false
  aimTarget = nil
  aimLockedPlayer = nil
  aimLockLostSince = 0
  autoAimTarget = nil
  autoAimLockedPlayer = nil
  autoAimSmoothedPos = nil
  autoAimPredictedPos = nil
  autoAimLastPart = nil
  autoAimLastRawPos = nil
  autoAimVelocity = Vector3.zero
  autoAimLostSince = 0
  autoAimReleaseUntil = 0
  autoAimManualBreakUntil = 0
  autoAimBreakScore = 0
  autoAimMixedUseHead = true
  autoAimMixedNextSwitch = 0
  autoAimMixedBlend = 0
  mouseAssistTarget = nil
  mouseAssistLockedPlayer = nil
  mouseAssistLostSince = 0
  mouseAssistSmoothedPos = nil
  rageTarget = nil
  rageLockedPlayer = nil
  rageNextShotAt = 0
  restoreRageWeaponLock()
  rageMixedUseHead = true
  rageMixedNextSwitch = 0
  rageMixedBlend = 0
  aimLockMouseState = Vector2.new(0, 0)
  aimLockMouseRemainder = Vector2.new(0, 0)
  aimLockMouseSign = 1
  aimLockDirectionProbe = nil
  pcall(function()
    if mouseStepState then
      mouseStepState.auto = Vector2.new(0, 0)
      mouseStepState.lock = Vector2.new(0, 0)
      mouseStepState.rage = Vector2.new(0, 0)
      mouseStepState.assist = Vector2.new(0, 0)
    end
    if mouseRemainderState then
      mouseRemainderState.auto = Vector2.new(0, 0)
      mouseRemainderState.lock = Vector2.new(0, 0)
      mouseRemainderState.rage = Vector2.new(0, 0)
      mouseRemainderState.assist = Vector2.new(0, 0)
    end
    if mouseMoveSignByMode then
      mouseMoveSignByMode.auto = 1
      mouseMoveSignByMode.lock = 1
      mouseMoveSignByMode.rage = 1
      mouseMoveSignByMode.assist = 1
    end
    if mouseDirectionProbe then
      for _, key in ipairs({"auto", "lock", "rage", "assist"}) do
        if mouseDirectionProbe[key] then
          mouseDirectionProbe[key].error = nil
          mouseDirectionProbe[key].at = 0
          mouseDirectionProbe[key].bad = 0
        end
      end
    end
    injectedMouseDelta = Vector2.new(0, 0)
    injectedMouseAt = 0
    controlSpoofRemote = nil
    lastControlSpoofMode = "MouseKeyboard"
    lastControlSpoofAt = 0
    antiVoidNextAt = 0
  end)
  pcall(cleanAllESP)
  pcall(clearAimTargetHighlight)
  pcall(restoreDeviceSpoof)
  pcall(function()
    if setFB then setFB(false) end
  end)
  pcall(function()
    if setNF then setNF(false) end
  end)
  pcall(function()
    if setFPS then setFPS(false) end
  end)
  pcall(function()
    if setFPSBoost then setFPSBoost(false) end
  end)
  pcall(restoreAntiHitPose)
  pcall(restoreAntiHitHitbox)
  pcall(function()
    if UI_WINDOW and UI_WINDOW.Destroy then
      UI_WINDOW:Destroy()
    end
    UI_WINDOW = nil
  end)
  for _, conn in pairs(CONNECTIONS) do
    pcall(function() conn:Disconnect() end)
  end
  CONNECTIONS = {}
  
  pcall(function()
    if getgenv then
      local gv = getgenv()
      if gv.NX_FOV then
        pcall(function() gv.NX_FOV:Remove() end)
        gv.NX_FOV = nil
      end
      if gv.NX_FOV_GUI then
        pcall(function() gv.NX_FOV_GUI:Destroy() end)
        gv.NX_FOV_GUI = nil
      end
      gv.NX_STATE = nil
      gv.NX_HOOKED = nil
      gv.NX_XENO_LOADING = nil
      gv.NX_XENO = nil
      gv.NX_CLEANUP = nil
      gv.NX_GUI_READY = nil
      gv.NX_UI_WINDOW = nil
      gv.NX_UI_GUI = nil
      gv.NX_UI_ROOT = nil
    end
  end)
end

if getgenv then
  getgenv().NX_CLEANUP = cleanup
end

--  STATE
local STATE = {
  AimLock = false,
  AimLockPart = "Head",
  AimLockStrength = 100,
  SilentAim = false,
  SilentAimMode = "No Hook",
  SilentAimFOVOnly = true,
  SilentAimAutoShoot = false,
  SilentAimAutoShootCPS = 8,
  NoHookMode = "ULTRA",
  AutoAim = false,
  RageBot = false,
  RageTargetPart = "Head",
  RageVisibilityCheck = false,
  RageLockStrength = 100,
  RageAutoShoot = false,
  RageRequireADS = false,
  RageCPS = 8,
  RageShootFOV = 7,
  AimFOV = 150,
  AimMaxDist = 300,
  AutoAimStrengthADS = 100,
  AutoAimStrengthHip = 100,
  AutoAimTargetPart = "Head",
  AutoAimPrediction = 100,
  AutoAimVisibleCheck = false,
  AimTeamCheck = true,
  AimFOVCircle = true,
  AimFOVHidden = false,
  AimFOVColor = "White",
  AimRequireCenter = true,
  AimMouseAssist = true,
  AimMouseAssistStrength = 100,
  AimLockRequireRMB = false,
  AutoAimRequireRMB = false,
  
  TriggerEnabled = false,
  TriggerDelay = 0,
  TriggerCPS = 8,
  TriggerTarget = "Head",
  TriggerTeamCheck = true,
  TriggerRequireCenter = true,
  TriggerVisibleCheck = true,
  
  HitboxExpander = false,
  HitboxSize = 10,
  
  ESPEnabled = false,
  ESPTeam = false,
  ESPEnemy = true,
  ESPHighlight = false,
  ESPName = true,
  ESPHealth = false,
  ESPDistance = false,
  ESPBox = true,
  ESPSkeleton = false,
  ESPBoxScale = 40,
  ESPMaxDistance = 500,
  ESPUpdateFPS = 12,
  
  SpeedEnabled = false,
  SpeedValue = 40,
  FlyEnabled = false,
  FlySpeed = 50,
  FlyToggle = false,
  InfJump = false,
  InfJumpHeight = 36,
  NoClip = false,
  BunnyHop = false,
  
  NoSpread = false,
  Wallbang = false,
  
  FullBright = false,
  NoFog = false,
  FPSUnlocker = true,
  FPSBoost = false,
  MobileSpoof = false,
  ConsoleSpoof = false,
  VRSpoof = false,
  SoftMobileSpoof = false,
  SoftConsoleSpoof = false,
  SoftVRSpoof = false,
  
  TPPlayer = "",
  TPDistance = 4,
  NamesOrbit = false,
  NamesOrbitInterval = 180,
  AutoBackstab = false,
  AutoBackstabInterval = 180,
  AutoBackstabRandomize = true,
  AutoBackstabRandomMin = 90,
  AutoBackstabRandomMax = 260,
  
  BeggerFarm = false,
  AntiHit = false,
  AntiHitMode = "Adaptive Jitter",
  AntiHitSpeed = 2.2,
  AntiHitExperimental = false,
  AntiHitHitboxMode = "Off",
  AntiHitHitboxScale = 60,
  AntiVoid = true,
  
  BindToggleGUI = "K",
  BindFly = "X",
  BindAimLock = "None",
  BindAutoAim = "None",
  BindRageBot = "None",
  BindTrigger = "None",
  BindESP = "None",
  BindBeggerFarm = "None",
  BindAutoBackstab = "None",
  BindNamesOrbit = "None",
  BindApplyControlMode = "None",
  
  AimMouseAssistSmooth = 1,
}

if getgenv then
  getgenv().NX_STATE = STATE
end

local BIND_KEYS = {
  "BindToggleGUI",
  "BindFly",
  "BindAimLock",
  "BindAutoAim",
  "BindRageBot",
  "BindTrigger",
  "BindESP",
  "BindBeggerFarm",
  "BindAutoBackstab",
  "BindNamesOrbit",
  "BindApplyControlMode",
}

function normalizeSingleLetterBind(value)
  local raw = tostring(value or "None")
  if raw == "" or raw == "None" then
    return "None"
  end
  local first = raw:match("^[A-Za-z]")
  return first and first:upper() or "None"
end

function normalizeAllBinds()
  for _, key in ipairs(BIND_KEYS) do
    STATE[key] = normalizeSingleLetterBind(STATE[key])
  end
end

local CONFIG_FOLDER = "NovaXConfigs"
local CONFIG_BASE_PATH = nil

if getgenv then
  if type(getgenv().NX_CONFIG_PATH) == "string" and getgenv().NX_CONFIG_PATH ~= "" then
    CONFIG_BASE_PATH = getgenv().NX_CONFIG_PATH
  end
  getgenv().NX_SetConfigPath = function(p)
    CONFIG_BASE_PATH = p and tostring(p) or nil
  end
end

local function getConfigDir()
  local dir = CONFIG_BASE_PATH and CONFIG_BASE_PATH ~= "" and tostring(CONFIG_BASE_PATH) or CONFIG_FOLDER
  dir = dir:gsub("\\", "/")
  dir = dir:gsub("/+$", "")
  return dir
end

function ensureConfigFolder()
  local dir = getConfigDir()
  if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
    if not isfolder(dir) then
      pcall(function()
        makefolder(dir)
      end)
    end
  end
end

function sanitizeConfigName(name)
  local raw = tostring(name or "default")
  local clean = raw:gsub("[^%w_%-%s]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "_")
  if clean == "" then
    clean = "default"
  end
  return clean
end

function getConfigPath(name)
  local clean = sanitizeConfigName(name)
  return string.format("%s/%s.json", getConfigDir(), clean), clean
end

function snapshotState()
  local data = {}
  for k, v in pairs(STATE) do
    local t = type(v)
    if t == "boolean" or t == "number" or t == "string" then
      data[k] = v
    end
  end
  return data
end

function saveConfig(name)
  ensureConfigFolder()
  if typeof(writefile) ~= "function" then
    return false, "writefile nicht verfuegbar"
  end
  
  local path, clean = getConfigPath(name)
  local payload = snapshotState()
  local ok, err = pcall(function()
    writefile(path, HttpService:JSONEncode(payload))
  end)
  if not ok then
    return false, tostring(err)
  end
  return true, clean
end

function loadConfig(name)
  ensureConfigFolder()
  if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
    return false, "readfile/isfile nicht verfuegbar"
  end
  
  local path, clean = getConfigPath(name)
  if not isfile(path) then
    return false, "Config nicht gefunden"
  end
  
  local ok, parsed = pcall(function()
    return HttpService:JSONDecode(readfile(path))
  end)
  if not ok or type(parsed) ~= "table" then
    return false, "Config konnte nicht gelesen werden"
  end
  
  for k, v in pairs(parsed) do
    if STATE[k] ~= nil and type(STATE[k]) == type(v) then
      STATE[k] = v
    end
  end
  
  -- Configs sollen keine Features zwangsweise blockieren. Nur No-Hook bleibt auf ULTRA normalisiert.
  STATE.NoHookMode = "ULTRA"
  STATE.AimTeamCheck = true
  STATE.AimRequireCenter = true
  STATE.TriggerTeamCheck = true
  STATE.TriggerRequireCenter = true
  STATE.TriggerVisibleCheck = true
  STATE.RageVisibilityCheck = false
  STATE.FPSUnlocker = true
  STATE.InfJumpHeight = math.clamp(safeNum(STATE.InfJumpHeight), 28, 80)
  STATE.AimLockStrength = 100
  STATE.AimMouseAssistStrength = math.max(80, safeNum(STATE.AimMouseAssistStrength))
  STATE.RageCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.RageCPS)))
  STATE.TriggerCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.TriggerCPS)))
  normalizeAllBinds()
  if STATE.VRSpoof then
    STATE.MobileSpoof = false
    STATE.ConsoleSpoof = false
  elseif STATE.ConsoleSpoof then
    STATE.MobileSpoof = false
  end
  if tostring(STATE.AntiHitMode) == "Anti Spin" then
    STATE.AntiHitMode = "Adaptive Jitter"
  end
  
  return true, clean
end

function deleteConfig(name)
  ensureConfigFolder()
  if typeof(delfile) ~= "function" then
    return false, "delfile nicht verfuegbar"
  end
  local path, clean = getConfigPath(name)
  if typeof(isfile) == "function" and not isfile(path) then
    return true, clean
  end
  local ok, err = pcall(function()
    delfile(path)
  end)
  if not ok then
    return false, tostring(err)
  end
  return true, clean
end

function renameConfig(oldName, newName)
  ensureConfigFolder()
  if typeof(readfile) ~= "function" or typeof(writefile) ~= "function" then
    return false, "readfile/writefile nicht verfuegbar"
  end
  local oldPath, oldClean = getConfigPath(oldName)
  local newPath, newClean = getConfigPath(newName)
  if oldClean == newClean then
    return true, newClean
  end
  if typeof(isfile) == "function" and not isfile(oldPath) then
    return false, "Config nicht gefunden"
  end
  if typeof(isfile) == "function" and isfile(newPath) then
    return false, "Config Name existiert schon"
  end
  local okRead, data = pcall(function()
    return readfile(oldPath)
  end)
  if not okRead then
    return false, tostring(data)
  end
  local okWrite, writeErr = pcall(function()
    writefile(newPath, data)
  end)
  if not okWrite then
    return false, tostring(writeErr)
  end
  if typeof(delfile) == "function" then
    pcall(function()
      delfile(oldPath)
    end)
  end
  return true, newClean
end

function listConfigNames()
  ensureConfigFolder()
  local names = {}
  local dir = getConfigDir()
  if typeof(listfiles) ~= "function" or typeof(isfolder) ~= "function" or not isfolder(dir) then
    return names
  end

  local ok, files = pcall(function()
    return listfiles(dir)
  end)
  if not ok or type(files) ~= "table" then
    return names
  end
  
  for index = 1, #files do
    local f = files[index]
    local s = tostring(f)
    local name = s:match("([^/\\]+)%.json$")
    if name and name ~= "" then
      table.insert(names, name)
    end
  end
  table.sort(names)
  return names
end

ensureConfigFolder()

if not SUPPORT.MetaHook and tostring(STATE.SilentAimMode or "No Hook") == "Hook" then
  nxWarn("[NovaX] Meta-Hook fehlt: Silent/Wallbang kann je nach Executor ohne Wirkung bleiben")
end

--  GAME HELPERS (XENO-SAFE!)
function getChar()
  if not LocalPlayer then return nil end
  return LocalPlayer.Character
end

function getRoot()
  local char = getChar()
  if not char then return nil end
  -- WICHTIG: FindFirstChild statt WaitForChild!
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function getHumanoid()
  local char = getChar()
  if not char then return nil end
  return char:FindFirstChildOfClass("Humanoid")
end

function getTool()
  local char = getChar()
  if not char then return nil end
  return char:FindFirstChildOfClass("Tool")
end

local function normalizeWeaponName(value)
  local name = string.lower(tostring(value or ""))
  name = name:gsub("[_%-%[%]%(%)]+", " ")
  name = name:gsub("%s+", " ")
  name = name:gsub("^%s+", ""):gsub("%s+$", "")
  return name
end

function isStrafeSightWeaponEquipped()
  local tool = getTool()
  if not tool then
    return false
  end

  local name = normalizeWeaponName(tool.Name)
  if name == "ar" or name == "assault" or name == "assault rifle" or name == "uzi" then
    return true
  end

  if name:find("assault", 1, true) and not name:find("sniper", 1, true) then
    return true
  end

  if name:match("^ar%d+") then
    return true
  end

  local compact = name:gsub("%s+", "")
  if compact == "burstrifle" or compact == "bursrifle" or compact == "energypistol" or compact == "energypistols" or compact == "ernergypistol" or compact == "ernergypistols" then
    return true
  end

  local padded = " " .. name .. " "
  for _, token in ipairs({
    " ar ",
    " burst ",
    " burst rifle ",
    " burs ",
    " burs rifle ",
    " schrot ",
    " schrotflinte ",
    " flinte ",
    " shotgun ",
    " pistol ",
    " pistols ",
    " spray ",
    " revolver ",
    " uzi ",
    " energy pistol ",
    " energy pistols ",
    " ernergy pistol ",
    " ernergy pistols ",
  }) do
    if padded:find(token, 1, true) then
      return true
    end
  end

  return false
end

function getStrafeSightCenterOffset()
  if not Camera or not isStrafeSightWeaponEquipped() then
    return Vector2.new(0, 0), false
  end
  if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    return Vector2.new(0, 0), false
  end

  local side = 0
  local hum = getHumanoid()
  if hum and hum.MoveDirection and hum.MoveDirection.Magnitude > 0.04 then
    side = hum.MoveDirection:Dot(Camera.CFrame.RightVector)
  end

  if math.abs(side) < 0.05 then
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then side = side - 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then side = side + 1 end
  end

  side = math.clamp(side, -1, 1)
  if math.abs(side) < 0.05 then
    return Vector2.new(0, 0), false
  end

  local root = getRoot()
  local lateralSpeed = 16
  if root and root.AssemblyLinearVelocity then
    local vel = root.AssemblyLinearVelocity
    lateralSpeed = math.abs(vel:Dot(Camera.CFrame.RightVector))
  elseif hum then
    lateralSpeed = safeNum(hum.WalkSpeed)
  end

  local amount = math.clamp(3.0 + lateralSpeed * 0.34, 3.0, 13.5)
  return Vector2.new(-side * amount, 0), true
end

local strafeSightSmoothedOffset = Vector2.new(0, 0)
local strafeSightLastUpdate = 0

function getAimScreenCenter(rawCenter)
  if not Camera then
    return Vector2.new(0, 0), false
  end

  local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
  if rawCenter == true then
    return center, false, Vector2.new(0, 0)
  end

  local offset, active = getStrafeSightCenterOffset()
  local now = tick()
  local dt = strafeSightLastUpdate > 0 and math.clamp(now - strafeSightLastUpdate, 1 / 240, 1 / 12) or (1 / 60)
  strafeSightLastUpdate = now

  local alpha = math.clamp(dt * (active and 10 or 7), 0.08, active and 0.35 or 0.28)
  strafeSightSmoothedOffset = strafeSightSmoothedOffset:Lerp(offset, alpha)
  if not active and strafeSightSmoothedOffset.Magnitude < 0.05 then
    strafeSightSmoothedOffset = Vector2.new(0, 0)
  end

  local smoothedActive = active or strafeSightSmoothedOffset.Magnitude > 0.05
  return center + strafeSightSmoothedOffset, smoothedActive, strafeSightSmoothedOffset
end

function getCharacterRoot(char)
  if not char then return nil end
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function getPlayerRoot(player)
  if not player or not player.Character then return nil end
  return getCharacterRoot(player.Character)
end

function getPreferredPartFromPlayer(player, mode)
  if not player then return nil end
  local char = player.Character
  if not char then return nil end
  
  local head = char:FindFirstChild("Head")
  local upperTorso = char:FindFirstChild("UpperTorso")
  local lowerTorso = char:FindFirstChild("LowerTorso")
  local classicTorso = char:FindFirstChild("Torso")
  local torso = upperTorso or classicTorso or lowerTorso
  local root = char:FindFirstChild("HumanoidRootPart") or torso
  local selected = tostring(mode or "Head")
  
  if selected == "Torso" or selected == "UpperTorso" or selected == "LowerTorso" then
    return torso or root or head
  end
  
  if selected == "HumanoidRootPart" or selected == "Root" then
    return root or torso or head
  end

  if selected == "Mixed" then
    return head or torso or root
  end
  
  return head or torso or root
end

function getHeadCenterFromPlayer(player, fallbackPart)
  local char = player and player.Character
  local head = char and char:FindFirstChild("Head")
  if head and head:IsA("BasePart") then
    return head, head.Position
  end
  if fallbackPart and fallbackPart:IsA("BasePart") then
    return fallbackPart, fallbackPart.Position
  end
  return nil, nil
end

local rageWeaponGrips = setmetatable({}, {__mode = "k"})

restoreRageWeaponLock = function()
  for tool, originalGrip in pairs(rageWeaponGrips) do
    if tool and tool.Parent and originalGrip then
      pcall(function()
        tool.Grip = originalGrip
      end)
    end
  end
  rageWeaponGrips = setmetatable({}, {__mode = "k"})
end

lockEquippedToolToPosition = function(targetPos, strength)
  local tool = getTool()
  if not tool or typeof(targetPos) ~= "Vector3" then
    return false
  end
  
  local root = getRoot()
  local handle = tool:FindFirstChild("Handle")
  local refCF = root and root.CFrame or (handle and handle.CFrame)
  local origin = handle and handle.Position or (root and root.Position)
  if not refCF or not origin then
    return false
  end
  
  local dir = targetPos - origin
  if dir.Magnitude < 0.05 then
    return false
  end
  
  local applied = false
  local ok = pcall(function()
    if rageWeaponGrips[tool] == nil then
      rageWeaponGrips[tool] = tool.Grip
    end
    
    local originalGrip = rageWeaponGrips[tool]
    local localDir = refCF:VectorToObjectSpace(dir.Unit)
    if localDir.Magnitude < 0.05 then
      return
    end
    
    local targetGrip = CFrame.lookAt(originalGrip.Position, originalGrip.Position + localDir.Unit, UP)
    local alpha = math.clamp(0.22 + (math.clamp(safeNum(strength), 0, 1) * 0.78), 0.22, 1)
    tool.Grip = originalGrip:Lerp(targetGrip, alpha)
    applied = true
  end)
  
  return ok and applied
end

local teamResolverCache = {
  checkedAt = 0,
  mode = "none",
  key = nil,
  getter = nil,
  printed = false,
}

local TEAM_KEYWORDS = {"team", "faction", "side", "squad", "alliance", "allegiance", "camp", "clan"}
local STATIC_TEAM_KEYS = {"Team", "TeamId", "TeamID", "TeamIndex", "TeamName", "Faction", "Side", "Squad", "Alliance", "Allegiance", "Camp", "Clan"}

function nameLooksTeamLike(name)
  local lower = string.lower(tostring(name or ""))
  if lower == "" then
    return false
  end
  for _, kw in ipairs(TEAM_KEYWORDS) do
    if string.find(lower, kw, 1, true) then
      return true
    end
  end
  return false
end

function normalizeTeamToken(value)
  if value == nil then
    return nil
  end
  
  local t = typeof(value)
  if t == "string" then
    local s = string.lower(tostring(value)):gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" or s == "none" or s == "nil" or s == "neutral" or s == "unknown" then
      return nil
    end
    return s
  end
  
  if t == "number" then
    if value == 0 then
      return nil
    end
    return string.format("%.3f", value)
  end
  
  if t == "boolean" then
    return value and "true" or "false"
  end
  
  if t == "BrickColor" or t == "Color3" then
    return tostring(value)
  end
  
  if t == "Instance" then
    return tostring(value:GetFullName())
  end
  
  return tostring(value)
end

function collectTeamStats(tokenGetter)
  local tokenCounts = {}
  local covered = 0
  local localToken = nil
  
  for _, p in ipairs(Players:GetPlayers()) do
    local token = tokenGetter(p)
    if token then
      covered = covered + 1
      tokenCounts[token] = (tokenCounts[token] or 0) + 1
      if p == LocalPlayer then
        localToken = token
      end
    end
  end
  
  local uniqueCount = 0
  local maxCount = 0
  for _, count in pairs(tokenCounts) do
    uniqueCount = uniqueCount + 1
    if count > maxCount then
      maxCount = count
    end
  end
  
  local localCount = localToken and (tokenCounts[localToken] or 0) or 0
  return {
    covered = covered,
    uniqueCount = uniqueCount,
    maxCount = maxCount,
    localToken = localToken,
    localCount = localCount,
  }
end

function teamStatsScore(stats)
  if not stats.localToken then
    return -huge
  end
  if stats.covered < 2 then
    return -huge
  end
  if stats.uniqueCount < 2 then
    return -huge
  end
  if stats.localCount <= 1 and stats.uniqueCount >= stats.covered then
    return -huge
  end
  
  local score = 0
  score = score + (stats.covered * 9)
  score = score + (stats.localCount * 14)
  score = score + math.min(stats.maxCount, 12)
  score = score - (stats.uniqueCount * 2)
  return score
end

function listTeamLikeNamesFromAttributes(getAttributesFn)
  local out = {}
  local seen = {}
  
  local function addName(name)
    if not name or name == "" or seen[name] then return end
    if not nameLooksTeamLike(name) then return end
    seen[name] = true
    table.insert(out, name)
  end
  
  for _, n in ipairs(STATIC_TEAM_KEYS) do
    addName(n)
  end
  
  for _, p in ipairs(Players:GetPlayers()) do
    local attrs = {}
    pcall(function()
      attrs = getAttributesFn(p) or {}
    end)
    for attrName in pairs(attrs) do
      addName(attrName)
    end
  end
  
  return out
end

function listTeamLikeValueNames(getRootFn)
  local out = {}
  local seen = {}
  
  local function addName(name)
    if not name or name == "" or seen[name] then return end
    if not nameLooksTeamLike(name) then return end
    seen[name] = true
    table.insert(out, name)
  end
  
  for _, n in ipairs(STATIC_TEAM_KEYS) do
    addName(n)
  end
  
  for _, p in ipairs(Players:GetPlayers()) do
    local root = getRootFn(p)
    if root then
      for _, child in ipairs(root:GetDescendants()) do
        if child:IsA("ValueBase") then
          addName(child.Name)
        end
      end
    end
  end
  
  return out
end

function resolveTeamSource()
  local now = tick()
  if now - teamResolverCache.checkedAt < 12 and teamResolverCache.getter ~= nil then
    return teamResolverCache.mode, teamResolverCache.key, teamResolverCache.getter
  end
  
  teamResolverCache.checkedAt = now
  teamResolverCache.mode = "none"
  teamResolverCache.key = nil
  teamResolverCache.getter = nil
  
  local candidates = {}
  local function addCandidate(mode, key, getter)
    local stats = collectTeamStats(getter)
    local score = teamStatsScore(stats)
    if score > -huge then
      table.insert(candidates, {
        mode = mode,
        key = key,
        getter = getter,
        score = score,
      })
    end
  end
  
  addCandidate("player_team", nil, function(p)
    return normalizeTeamToken(p and p.Team)
  end)
  
  addCandidate("player_teamcolor", nil, function(p)
    return normalizeTeamToken(p and p.TeamColor)
  end)
  
  local playerAttrNames = listTeamLikeNamesFromAttributes(function(p)
    return p and p:GetAttributes() or {}
  end)
  for _, attrName in ipairs(playerAttrNames) do
    addCandidate("player_attr", attrName, function(p)
      if not p then return nil end
      return normalizeTeamToken(p:GetAttribute(attrName))
    end)
  end
  
  local charAttrNames = listTeamLikeNamesFromAttributes(function(p)
    local c = p and p.Character
    return c and c:GetAttributes() or {}
  end)
  for _, attrName in ipairs(charAttrNames) do
    addCandidate("char_attr", attrName, function(p)
      local c = p and p.Character
      if not c then return nil end
      return normalizeTeamToken(c:GetAttribute(attrName))
    end)
  end
  
  table.sort(candidates, function(a, b)
    return a.score > b.score
  end)
  
  local best = candidates[1]
  if best then
    teamResolverCache.mode = best.mode
    teamResolverCache.key = best.key
    teamResolverCache.getter = best.getter
  else
    teamResolverCache.mode = "none"
    teamResolverCache.key = nil
    teamResolverCache.getter = nil
  end
  
  return teamResolverCache.mode, teamResolverCache.key, teamResolverCache.getter
end

local teamColorCache = {checkedAt = 0, value = false}
function hasUsefulTeamColors()
  local now = tick()
  if now - teamColorCache.checkedAt < 4 then
    return teamColorCache.value
  end
  local stats = collectTeamStats(function(p)
    return normalizeTeamToken(p and p.TeamColor)
  end)
  teamColorCache.checkedAt = now
  teamColorCache.value = (stats.uniqueCount >= 2 and stats.localToken ~= nil)
  return teamColorCache.value
end

function getTeamToken(player)
  if not player then
    return nil
  end
  
  local mode, key, getter = resolveTeamSource()
  if getter then
    local token = getter(player)
    if token then
      local prefix = tostring(mode or "team")
      if key then
        prefix = prefix .. ":" .. tostring(key)
      end
      return prefix .. ":" .. token
    end
  end
  
  return nil
end

function isSameTeam(playerA, playerB)
  if not playerA or not playerB then
    return false
  end
  
  if playerA == playerB then
    return true
  end
  
  if not playerA.Parent or not playerB.Parent then
    return false
  end
  
  local teamA = playerA.Team
  local teamB = playerB.Team
  if teamA ~= nil and teamB ~= nil then
    return teamA == teamB
  end
  
  local colorA = normalizeTeamToken(playerA.TeamColor)
  local colorB = normalizeTeamToken(playerB.TeamColor)
  if colorA and colorB and hasUsefulTeamColors() then
    return colorA == colorB
  end
  
  local quickAttrKeys = {"TeamID", "TeamId", "Team", "Faction", "Side", "Squad"}
  for _, key in ipairs(quickAttrKeys) do
    local aTok = nil
    local bTok = nil
    pcall(function()
      aTok = normalizeTeamToken(playerA:GetAttribute(key))
      bTok = normalizeTeamToken(playerB:GetAttribute(key))
    end)
    if aTok and bTok then
      return aTok == bTok
    end
    pcall(function()
      local aChar = playerA.Character
      local bChar = playerB.Character
      if aChar and bChar then
        aTok = normalizeTeamToken(aChar:GetAttribute(key))
        bTok = normalizeTeamToken(bChar:GetAttribute(key))
      end
    end)
    if aTok and bTok then
      return aTok == bTok
    end
  end

  local tokenA = getTeamToken(playerA)
  local tokenB = getTeamToken(playerB)
  if tokenA and tokenB then
    return tokenA == tokenB
  end
  
  return false
end

function getPlayerLabel(p)
  local display = tostring(p.DisplayName or p.Name)
  local username = tostring(p.Name)
  if string.lower(display) == string.lower(username) then
    return username
  end
  return string.format("%s  (@%s)", display, username)
end

function getSelectablePlayers()
  local list = {}
  for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
      table.insert(list, getPlayerLabel(p))
    end
  end
  table.sort(list)
  if #list == 0 then
    table.insert(list, "None")
  end
  return list
end

function findPlayerByName(name)
  if not name or name == "" or name == "None" then return nil end
  local raw = tostring(name)
  local extractedUser = raw:match("@([%w_]+)")
  local n = string.lower(extractedUser or raw)
  
  for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
      local pn = string.lower(p.Name)
      local pd = string.lower(p.DisplayName or "")
      local label = string.lower(string.format("%s  (@%s)", p.DisplayName or p.Name, p.Name))
      if pn == n or pd == n or label == n or string.sub(pn, 1, #n) == n or string.sub(pd, 1, #n) == n then
        return p
      end
    end
  end
  
  return nil
end

function getNearestEnemyPlayer()
  local myRoot = getRoot()
  if not myRoot then return nil end
  
  local nearest, nearestDist = nil, huge
  for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
      if not (STATE.AimTeamCheck and isSameTeam(p, LocalPlayer)) then
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
          local root = getPlayerRoot(p)
          if root then
            local d = (root.Position - myRoot.Position).Magnitude
            if d < nearestDist then
              nearestDist = d
              nearest = p
            end
          end
        end
      end
    end
  end
  
  return nearest
end

function rightClick()
  return sendMouseButton(1, MIN_RIGHT_CLICK_INTERVAL)
end

function teleportToTargetRoot(targetRoot, behind)
  local myRoot = getRoot()
  if not myRoot or not targetRoot then return false end
  
  local dist = math.max(1.5, safeNum(STATE.TPDistance))
  local offset
  if behind then
    offset = -(targetRoot.CFrame.LookVector * dist)
  else
    offset = targetRoot.CFrame.RightVector * dist
  end
  
  local dest = targetRoot.Position + offset
  myRoot.CFrame = CFrame.new(dest, targetRoot.Position)
  return true
end

function isEnemy(player, teamCheck)
  if not player or player == LocalPlayer then return false end
  
  if teamCheck == false then
    return true
  end
  
  if isSameTeam(player, LocalPlayer) then
    return false
  end
  
  return true
end

function isAlive(player)
  if not player then return false end
  if not player.Character then return false end
  local hum = player.Character:FindFirstChildOfClass("Humanoid")
  if not hum then return false end
  return hum.Health > 0
end

function worldToScreen(pos)
  if not Camera or not Camera.WorldToViewportPoint or not pos then
    return Vector2.new(0, 0), false
  end
  
  local success, sp, os = pcall(function()
    local s, o = Camera:WorldToViewportPoint(pos)
    return s, o
  end)
  
  if not success then return Vector2.new(0, 0), false end
  return Vector2.new(sp.X, sp.Y), os
end

function isMouseNearCenter(threshold)
  if not Camera then return false end
  
  if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
    return true
  end

  local ok, mousePos = pcall(function()
    return UserInputService:GetMouseLocation()
  end)
  
  if not ok or not mousePos then
    return true
  end
  
  local inset = Vector2.new(0, 0)
  pcall(function()
    if GuiService and GuiService.GetGuiInset then
      local tl = GuiService:GetGuiInset()
      if typeof(tl) == "Vector2" then
        inset = tl
      end
    end
  end)
  
  local center = getAimScreenCenter()
  local tol = threshold or 60
  local m = Vector2.new(mousePos.X, mousePos.Y) - inset
  return (m - center).Magnitude <= tol
end

function isAimCenterGateOpen()
  if not STATE.AimRequireCenter then
    return true
  end
  if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
    return true
  end
  return isMouseNearCenter(130)
end

function bindNameToKeyCode(name)
  if not name or name == "" or name == "None" then
    return nil
  end
  
  local keyName = tostring(name):sub(1, 1):upper()
  if #tostring(name) ~= 1 or not keyName:match("^[A-Z]$") then
    return nil
  end
  return Enum.KeyCode[keyName]
end

function inputMatchesBind(input, bindName)
  local bind = bindNameToKeyCode(bindName)
  if not bind then return false end
  
  if typeof(bind) == "EnumItem" and bind.EnumType == Enum.KeyCode then
    return input.KeyCode == bind
  end
  
  if typeof(bind) == "EnumItem" and bind.EnumType == Enum.UserInputType then
    return input.UserInputType == bind
  end
  
  return false
end

local roundStateCache = {
  value = true,
  checkedAt = 0,
}

function isRoundStarted()
  local now = tick()
  if now - roundStateCache.checkedAt < 0.25 then
    return roundStateCache.value
  end
  
  roundStateCache.checkedAt = now
  
  local hum = getHumanoid()
  if not hum or hum.Health <= 0 then
    roundStateCache.value = false
    return false
  end
  
  local boolNames = {"InRound", "RoundStarted", "RoundActive", "MatchStarted", "InMatch", "GameStarted"}
  for _, rootObj in ipairs({workspace, ReplicatedStorage}) do
    if rootObj then
      for _, n in ipairs(boolNames) do
        local ok, obj = pcall(function()
          return rootObj:FindFirstChild(n, true)
        end)
        if ok and obj then
          if obj:IsA("BoolValue") then
            roundStateCache.value = obj.Value == true
            return roundStateCache.value
          elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
            roundStateCache.value = obj.Value > 0
            return roundStateCache.value
          elseif obj:IsA("StringValue") then
            local s = string.lower(tostring(obj.Value))
            if s:find("lobby") or s:find("intermission") or s:find("waiting") then
              roundStateCache.value = false
              return false
            end
            if s:find("round") or s:find("match") or s:find("playing") or s:find("fight") then
              roundStateCache.value = true
              return true
            end
          end
        end
      end
    end
  end
  
  local tool = getTool()
  local lockLike = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or UserInputService.MouseIconEnabled == false)
  if tool and lockLike then
    roundStateCache.value = true
    return true
  end
  
  if lockLike and getRoot() ~= nil then
    roundStateCache.value = true
    return true
  end
  
  roundStateCache.value = false
  return false
end

--  PLAYER CACHE
local cachedPlayers = {}
local lastUpdate = 0

function updateCache()
  local now = tick()
  if now - lastUpdate < 0.3 then return end
  
  local success, result = pcall(function()
    return Players:GetPlayers()
  end)
  
  if success and result then
    cachedPlayers = result
  end
  
  lastUpdate = now
end

--  VISIBILITY
function isVisible(part)
  if not part or not part.Parent or not Camera then return false end
  
  local success, result = pcall(function()
    local origin = Camera.CFrame.Position
    local diff = part.Position - origin
    local dist = diff.Magnitude
    if dist == 0 then return true end
    local dir = diff.Unit
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    if LocalPlayer and LocalPlayer.Character then
      table.insert(exclude, LocalPlayer.Character)
    end
    if Camera then
      table.insert(exclude, Camera)
    end
    params.FilterDescendantsInstances = exclude
    
    local rayResult = workspace:Raycast(origin, dir * dist, params)
    
    if not rayResult then return true end
    return rayResult.Instance == part or rayResult.Instance:IsDescendantOf(part.Parent)
  end)
  
  return success and result or false
end

local visCache = {}
local visCacheTime = 0

function isVisibleCached(part)
  if not part then return false end
  
  local now = tick()
  if now - visCacheTime > 0.1 then
    visCache = {}
    visCacheTime = now
  end
  
  if visCache[part] ~= nil then
    return visCache[part]
  end
  
  local result = isVisible(part)
  visCache[part] = result
  return result
end

function getClosest(fov, teamCheck, maxDist, checkVis, forceHead, preferredPart, rawCenter)
  updateCache()
  
  if #cachedPlayers == 0 then return nil end
  
  if not Camera then return nil end
  
  local ok, best = pcall(function()
    local closest, bestDist = nil, huge
    local center = getAimScreenCenter(rawCenter == true)
    local myRoot = getRoot()
    local activeState = (getgenv and getgenv().NX_STATE) or STATE
    local aimPart = forceHead and "Head" or preferredPart or (activeState.AimLockPart or "Head")
    
    for _, player in ipairs(cachedPlayers) do
      if player and player ~= LocalPlayer then
        local char = player.Character
        if char and isEnemy(player, teamCheck) then
          local hum = char:FindFirstChildOfClass("Humanoid")
          if hum and hum.Health > 0 then
            local head
            if forceHead then
              head = char:FindFirstChild("Head") or getPreferredPartFromPlayer(player, "Head")
            else
              head = getPreferredPartFromPlayer(player, aimPart) or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
            end
            if head then
              if head and myRoot and maxDist then
                local dist3d = (head.Position - myRoot.Position).Magnitude
                if dist3d > safeNum(maxDist) then
                  head = nil
                end
              end
              
              if head then
                local lookDir = head.Position - Camera.CFrame.Position
                if lookDir.Magnitude > 0.001 then
                  local dot = Camera.CFrame.LookVector:Dot(lookDir.Unit)
                  if dot < 0.35 then
                    head = nil
                  end
                end
              end
              
              if head then
                local sp, os = worldToScreen(head.Position)
                if os then
                  local dist = (sp - center).Magnitude
                  
                  if dist <= safeNum(fov) and dist < bestDist then
                    if not checkVis or isVisibleCached(head) then
                      bestDist = dist
                      closest = head
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    
    return closest
  end)
  
  return ok and best or nil
end

--  AIM LOCK
aimTarget = nil
aimLockedPlayer = nil
aimLockLostSince = 0
autoAimTarget = nil
autoAimLockedPlayer = nil
autoAimSmoothedPos = nil
autoAimPredictedPos = nil
autoAimLastPart = nil
autoAimLastRawPos = nil
autoAimVelocity = Vector3.zero
autoAimLostSince = 0
autoAimReleaseUntil = 0
autoAimManualBreakUntil = 0
autoAimBreakScore = 0
autoAimMixedUseHead = true
autoAimMixedNextSwitch = 0
autoAimMixedBlend = 0
mouseAssistTarget = nil
mouseAssistLockedPlayer = nil
mouseAssistLostSince = 0
mouseAssistSmoothedPos = nil
rageTarget = nil
rageLockedPlayer = nil
rageNextShotAt = 0
rageMixedUseHead = true
rageMixedNextSwitch = 0
rageMixedBlend = 0
local updateFOV = function() end
local aimTargetHighlight = nil

clearAimTargetHighlight = function()
  if aimTargetHighlight then
    pcall(function()
      aimTargetHighlight:Destroy()
    end)
    aimTargetHighlight = nil
  end
end

function setAimTargetHighlight(targetPart)
  if not targetPart or not targetPart.Parent then
    clearAimTargetHighlight()
    return
  end
  
  if aimTargetHighlight and aimTargetHighlight.Parent == targetPart then
    return
  end
  
  clearAimTargetHighlight()
  
  local hl = Instance.new("Highlight")
  hl.Name = "NX_AIM_TARGET"
  hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  hl.FillColor = Color3.fromRGB(255, 0, 0)
  hl.OutlineColor = Color3.fromRGB(255, 255, 0)
  hl.FillTransparency = 0.15
  hl.OutlineTransparency = 0
  hl.Adornee = targetPart
  hl.Parent = targetPart
  aimTargetHighlight = hl
end

mouseStepState = {
  auto = Vector2.new(0, 0),
  lock = Vector2.new(0, 0),
  rage = Vector2.new(0, 0),
  assist = Vector2.new(0, 0),
}
mouseRemainderState = {
  auto = Vector2.new(0, 0),
  lock = Vector2.new(0, 0),
  rage = Vector2.new(0, 0),
  assist = Vector2.new(0, 0),
}
mouseMoveSignByMode = {
  auto = 1,
  lock = 1,
  rage = 1,
  assist = 1,
}
mouseDirectionProbe = {
  auto = {error = nil, at = 0, bad = 0},
  lock = {error = nil, at = 0, bad = 0},
  rage = {error = nil, at = 0, bad = 0},
  assist = {error = nil, at = 0, bad = 0},
}
aimLockMouseState = Vector2.new(0, 0)
aimLockMouseRemainder = Vector2.new(0, 0)
aimLockMouseSign = 1
aimLockDirectionProbe = {
  error = nil,
  at = 0,
  bad = 0,
}
injectedMouseDelta = Vector2.new(0, 0)
injectedMouseAt = 0
controlSpoofRemote = nil
lastControlSpoofMode = "MouseKeyboard"
lastControlSpoofAt = 0
antiVoidNextAt = 0

function normalizeMouseModeKey(mode)
  if mode == "assist" or mode == "mouseassist" then
    return "assist"
  end
  if mode == "rage" then
    return "rage"
  end
  if mode == "lock" or mode == "hardlock" or mode == "preciselock" then
    return "lock"
  end
  return "auto"
end

function resetMouseModeState(mode, resetSign)
  local key = normalizeMouseModeKey(mode)
  if mouseStepState then
    mouseStepState[key] = Vector2.new(0, 0)
  end
  if mouseRemainderState then
    mouseRemainderState[key] = Vector2.new(0, 0)
  end
  if mouseDirectionProbe and mouseDirectionProbe[key] then
    mouseDirectionProbe[key].error = nil
    mouseDirectionProbe[key].at = 0
    mouseDirectionProbe[key].bad = 0
  end
  if resetSign and mouseMoveSignByMode then
    mouseMoveSignByMode[key] = 1
  end
end

function updateMouseDirectionProbe(mode, currentError)
  local key = normalizeMouseModeKey(mode)
  local probe = mouseDirectionProbe and mouseDirectionProbe[key]
  if not probe or not probe.error or typeof(currentError) ~= "Vector2" then
    return
  end
  
  local now = tick()
  local previous = probe.error
  if now - safeNum(probe.at) > 0.18 or previous.Magnitude < 10 then
    probe.error = nil
    return
  end
  
  local oldMag = previous.Magnitude
  local newMag = currentError.Magnitude
  if newMag > oldMag + math.max(4, oldMag * 0.1) then
    probe.bad = safeNum(probe.bad) + 1
    local requiredBad = key == "rage" and 4 or 5
    if probe.bad >= requiredBad then
      if key ~= "lock" and mouseMoveSignByMode then
        mouseMoveSignByMode[key] = (mouseMoveSignByMode[key] == -1) and 1 or -1
      end
      resetMouseModeState(key, false)
    end
  elseif newMag < oldMag - 1 then
    probe.bad = math.max(0, safeNum(probe.bad) - 1)
  end
  
  probe.error = nil
end

function rememberMouseDirectionProbe(mode, currentError)
  if typeof(currentError) ~= "Vector2" or currentError.Magnitude < 12 then
    return
  end
  local key = normalizeMouseModeKey(mode)
  if not mouseDirectionProbe then
    mouseDirectionProbe = {}
  end
  mouseDirectionProbe[key] = mouseDirectionProbe[key] or {error = nil, at = 0, bad = 0}
  mouseDirectionProbe[key].error = currentError
  mouseDirectionProbe[key].at = tick()
end

function updateAimLockDirectionProbe(currentError)
  if not aimLockDirectionProbe or not aimLockDirectionProbe.error or typeof(currentError) ~= "Vector2" then
    return
  end
  
  local now = tick()
  local previous = aimLockDirectionProbe.error
  if now - safeNum(aimLockDirectionProbe.at) > 0.16 or previous.Magnitude < 8 then
    aimLockDirectionProbe.error = nil
    return
  end
  
  local oldMag = previous.Magnitude
  local newMag = currentError.Magnitude
  if newMag > oldMag + math.max(3, oldMag * 0.08) then
    aimLockDirectionProbe.bad = safeNum(aimLockDirectionProbe.bad) + 1
    if aimLockDirectionProbe.bad >= 2 then
      aimLockMouseState = Vector2.new(0, 0)
      aimLockMouseRemainder = Vector2.new(0, 0)
      aimLockDirectionProbe.bad = 0
      aimLockDirectionProbe.error = nil
    end
  elseif newMag < oldMag - 1 then
    aimLockDirectionProbe.bad = math.max(0, safeNum(aimLockDirectionProbe.bad) - 1)
  end
  
  aimLockDirectionProbe.error = nil
end

function rememberAimLockDirectionProbe(currentError)
  if typeof(currentError) ~= "Vector2" or currentError.Magnitude < 8 then
    return
  end
  if not aimLockDirectionProbe then
    aimLockDirectionProbe = {error = nil, at = 0, bad = 0}
  end
  aimLockDirectionProbe.error = currentError
  aimLockDirectionProbe.at = tick()
end

function hasMouseAssistBackend()
  if typeof(mousemoverel) == "function" then
    return true
  end
  if typeof(mousemoveabs) == "function" then
    return true
  end
  if typeof(mousemovedelta) == "function" then
    return true
  end
  if VirtualInputManager and typeof(VirtualInputManager.SendMouseMoveDelta) == "function" then
    return true
  end
  if VirtualInputManager and typeof(VirtualInputManager.SendMouseMoveEvent) == "function" then
    return true
  end
  return false
end

function sendMouseDeltaWithSign(dx, dy, signValue)
  local x = tonumber(dx) or 0
  local y = tonumber(dy) or 0
  local sign = (signValue == -1) and -1 or 1
  x = x * sign
  y = y * sign
  if math.abs(x) < 0.05 and math.abs(y) < 0.05 then
    return false
  end
  
  if math.abs(x) < 1 and x ~= 0 then
    x = x > 0 and 1 or -1
  end
  if math.abs(y) < 1 and y ~= 0 then
    y = y > 0 and 1 or -1
  end
  
  x = math.floor(x + (x >= 0 and 0.5 or -0.5))
  y = math.floor(y + (y >= 0 and 0.5 or -0.5))
  
  local function markInjected()
    injectedMouseDelta = Vector2.new(x, y)
    injectedMouseAt = tick()
  end
  
  if typeof(mousemoverel) == "function" then
    local ok = pcall(function()
      mousemoverel(x, y)
    end)
    if ok then
      markInjected()
      return true
    end
  end
  
  if typeof(mousemovedelta) == "function" then
    local ok = pcall(function()
      mousemovedelta(x, y)
    end)
    if ok then
      markInjected()
      return true
    end
  end
  
  if typeof(mousemoveabs) == "function" then
    local ok = pcall(function()
      local mp = UserInputService:GetMouseLocation()
      mousemoveabs(mp.X + x, mp.Y + y)
    end)
    if ok then
      markInjected()
      return true
    end
  end
  
  if VirtualInputManager and typeof(VirtualInputManager.SendMouseMoveDelta) == "function" then
    local ok = pcall(function()
      VirtualInputManager:SendMouseMoveDelta(x, y)
    end)
    if ok then
      markInjected()
      return true
    end
  end
  
  if VirtualInputManager and typeof(VirtualInputManager.SendMouseMoveEvent) == "function" then
    local ok = pcall(function()
      local mp = UserInputService:GetMouseLocation()
      VirtualInputManager:SendMouseMoveEvent(mp.X + x, mp.Y + y, game)
    end)
    if ok then
      markInjected()
      return true
    end
  end
  
  return false
end

function sendMouseDelta(dx, dy)
  return sendMouseDeltaForMode(dx, dy, "auto")
end

function sendMouseDeltaForMode(dx, dy, mode)
  local key = normalizeMouseModeKey(mode)
  local sign = (mouseMoveSignByMode and mouseMoveSignByMode[key] == -1) and -1 or 1
  local current = mouseRemainderState and mouseRemainderState[key] or Vector2.new(0, 0)
  current = current + Vector2.new((tonumber(dx) or 0) * sign, (tonumber(dy) or 0) * sign)
  
  local x = current.X >= 0 and math.floor(current.X) or math.ceil(current.X)
  local y = current.Y >= 0 and math.floor(current.Y) or math.ceil(current.Y)
  if mouseRemainderState then
    mouseRemainderState[key] = current - Vector2.new(x, y)
  end
  if x == 0 and y == 0 then
    return true, false
  end
  
  local ok = sendMouseDeltaWithSign(x, y, 1)
  if not ok and mouseRemainderState then
    mouseRemainderState[key] = (mouseRemainderState[key] or Vector2.new(0, 0)) + Vector2.new(x, y)
  end
  return ok, ok
end

function aimCameraAt(targetPos, alpha)
  if not Camera or typeof(targetPos) ~= "Vector3" then
    return false
  end
  local origin = Camera.CFrame.Position
  local dir = targetPos - origin
  if dir.Magnitude < 0.001 then
    return false
  end
  local targetCF = CFrame.new(origin, targetPos)
  local a = math.clamp(tonumber(alpha) or 1, 0.01, 1)
  if a >= 0.995 then
    Camera.CFrame = targetCF
  else
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, a)
  end
  return true
end

function mouseAimStep(targetPos, smooth, mode, speedFactor)
  if not Camera or not targetPos then return false end
  local moduleDriven = mode == "auto" or mode == "rage" or mode == "hardlock" or mode == "preciselock"
  if STATE.AimMouseAssist ~= true and not moduleDriven then
    resetMouseModeState(mode, false)
    return false
  end
  if not hasMouseAssistBackend() then
    return false
  end
  
  local sp, onScreen = worldToScreen(targetPos)
  if not onScreen then return false end
  
  local hardLock = mode == "hardlock"
  local preciseLock = mode == "preciselock"
  local center, arSightCompActive = getAimScreenCenter(hardLock or preciseLock)
  local delta = sp - center
  local key = normalizeMouseModeKey(mode)
  updateMouseDirectionProbe(key, delta)
  local isAuto = (key == "auto")
  local isAssist = (key == "assist")
  local isRage = (key == "rage")
  local isLock = (key == "lock")
  local autoSpeedFactor = (isAuto or isAssist) and math.clamp(tonumber(speedFactor) or 1, 1, isAuto and 1.65 or 1.25) or 1
  local prev = mouseStepState[key] or Vector2.new(0, 0)
  local userSmooth = math.clamp(safeNum(STATE.AimMouseAssistSmooth), 0.01, 1)
  local assistStrength = math.clamp(safeNum(STATE.AimMouseAssistStrength) / 100, 0.05, 1)
  local deadzone = (hardLock or preciseLock) and 0 or ((isAuto or isAssist) and math.max(isAssist and 0.5 or 0.28, (isAssist and 1 or 0.7) / autoSpeedFactor) or 1.25)
  if isLock and not hardLock and not preciseLock then
    deadzone = math.min(deadzone, 0.5)
  end
  if arSightCompActive and not hardLock and not preciseLock then
    deadzone = math.min(deadzone, (isAuto or isAssist) and 0.24 or 0.65)
  end
  if delta.Magnitude < deadzone then
    local decay = arSightCompActive and 0.82 or (isAuto and 0.72 or 0.52)
    mouseStepState[key] = prev:Lerp(Vector2.new(0, 0), decay)
    return true
  end
  if isAuto or isAssist then
    local softRadius = isAssist
      and math.clamp(42 - (assistStrength * 2) + ((1 - userSmooth) * 8), 30, 52)
      or math.clamp(36 - (assistStrength * 3) + ((1 - userSmooth) * 7), 26, 44)
    if delta.Magnitude < softRadius then
      local zone = math.clamp((delta.Magnitude - deadzone) / math.max(1, softRadius - deadzone), 0, 1)
      local scaled = delta * (zone ^ 1.35)
      if scaled.Magnitude < 0.08 then
        mouseStepState[key] = prev:Lerp(Vector2.new(0, 0), 0.48)
        return true
      end
      delta = scaled
    end
  end
  
  if hardLock then
    mouseStepState[key] = delta
    local ok, emitted = sendMouseDeltaForMode(delta.X, delta.Y, key)
    if ok then
      if emitted then
        rememberMouseDirectionProbe(key, delta)
      end
      return true
    end
    return false
  end
  
  local s = math.clamp(safeNum(smooth), 1, 36)
  if isAuto then
    s = s * (0.82 + (1 - userSmooth) * 1.15)
  elseif isAssist then
    s = s * (1.0 + (1 - userSmooth) * 1.35)
  else
    s = s * (0.68 + (1 - userSmooth) * 1.3)
  end
  if isLock then
    s = s * (preciseLock and 0.38 or 0.58)
  end
  if arSightCompActive then
    s = s * ((isAuto or isAssist) and 0.72 or 0.56)
  end
  
  local scaleDiv = isAuto and 175 or (isAssist and 190 or (isRage and 135 or 150))
  local minScale = (isAuto or isAssist) and 0.18 or 0.2
  local scale = math.clamp(delta.Magnitude / scaleDiv, minScale, 1)
  local maxStep = (isAuto and (10.5 * math.min(autoSpeedFactor, 1.45)) or (isAssist and (7.5 * math.min(autoSpeedFactor, 1.2)) or (isRage and 38 or 34))) * (0.55 + assistStrength * 0.45)
  if isLock then
    maxStep = maxStep * (preciseLock and 1.95 or 1.55)
  end
  if arSightCompActive then
    maxStep = maxStep * 1.45
  end
  local desiredRaw = Vector2.new(
    math.clamp((delta.X / s) * scale * assistStrength, -maxStep, maxStep),
    math.clamp((delta.Y / s) * scale * assistStrength, -maxStep, maxStep)
  )
  
  local accelLimit = (isAuto and 3.8 or (isAssist and 2.8 or (isRage and 10.5 or 8.4))) * ((isAuto or isAssist) and math.min(autoSpeedFactor, 1.35) or 1)
  if isLock then
    accelLimit = accelLimit * (preciseLock and 2.15 or 1.65)
  end
  if arSightCompActive then
    accelLimit = accelLimit * 1.6
  end
  local deltaStep = desiredRaw - prev
  local desired = desiredRaw
  if deltaStep.Magnitude > accelLimit then
    desired = prev + (deltaStep.Unit * accelLimit)
  end
  
  local blend = isAuto and math.clamp(0.26 + ((autoSpeedFactor - 1) * 0.06), 0.26, 0.36) or (isAssist and 0.28 or (isRage and 0.58 or 0.42))
  if isLock then
    blend = math.min(preciseLock and 0.86 or 0.68, blend + (preciseLock and 0.3 or 0.16))
  end
  if arSightCompActive then
    blend = math.min(0.72, blend + 0.14)
  end
  local filtered = prev:Lerp(desired, blend)
  if isLock and filtered.Magnitude > 0 and filtered:Dot(delta) < 0 then
    filtered = desired
  end
  if isLock and filtered.Magnitude > delta.Magnitude then
    filtered = delta
  end
  if (isAuto or isAssist) and filtered.Magnitude < 0.05 then
    filtered = Vector2.new(0, 0)
  end
  mouseStepState[key] = filtered
  
  local ok, emitted = sendMouseDeltaForMode(filtered.X, filtered.Y, key)
  if ok then
    if emitted then
      rememberMouseDirectionProbe(key, delta)
    end
    return true
  end
  return false
end

function sendAimLockMouseDelta(dx, dy)
  aimLockMouseRemainder = (aimLockMouseRemainder or Vector2.new(0, 0)) + Vector2.new(tonumber(dx) or 0, tonumber(dy) or 0)
  
  local rx, ry = aimLockMouseRemainder.X, aimLockMouseRemainder.Y
  local x = rx >= 0 and math.floor(rx) or math.ceil(rx)
  local y = ry >= 0 and math.floor(ry) or math.ceil(ry)
  
  if x == 0 and y == 0 then
    return true, false
  end
  
  aimLockMouseRemainder = aimLockMouseRemainder - Vector2.new(x, y)
  aimLockMouseSign = 1
  local ok = sendMouseDeltaWithSign(x, y, 1)
  if not ok then
    aimLockMouseRemainder = aimLockMouseRemainder + Vector2.new(x, y)
  end
  return ok, ok
end

function aimLockMouseStep(targetPos)
  if not Camera or not targetPos then
    aimLockMouseState = Vector2.new(0, 0)
    aimLockMouseRemainder = Vector2.new(0, 0)
    return false
  end

  if aimCameraAt(targetPos, 1) then
    aimLockMouseState = Vector2.new(0, 0)
    aimLockMouseRemainder = Vector2.new(0, 0)
    if aimLockDirectionProbe then
      aimLockDirectionProbe.error = nil
      aimLockDirectionProbe.at = 0
      aimLockDirectionProbe.bad = 0
    end
    return true
  end
  
  local sp, onScreen = worldToScreen(targetPos)
  if not onScreen then
    aimLockMouseState = Vector2.new(0, 0)
    aimLockMouseRemainder = Vector2.new(0, 0)
    return false
  end
  
  local center = getAimScreenCenter(true)
  local delta = sp - center
  updateAimLockDirectionProbe(delta)
  
  if delta.Magnitude < 0.01 then
    aimLockMouseState = Vector2.new(0, 0)
    aimLockMouseRemainder = Vector2.new(0, 0)
    return true
  end
  
  local maxStep = math.clamp(delta.Magnitude, 1, 62)
  local desired = delta
  if desired.Magnitude > maxStep then
    desired = desired.Unit * maxStep
  end
  
  local prev = aimLockMouseState or Vector2.new(0, 0)
  local filtered = prev:Lerp(desired, 0.74)
  if filtered.Magnitude > 0 and filtered:Dot(delta) < 0 then
    filtered = desired
  end
  if filtered.Magnitude > delta.Magnitude then
    filtered = delta
  end
  if filtered.Magnitude < 0.05 then
    aimLockMouseState = Vector2.new(0, 0)
    aimLockMouseRemainder = Vector2.new(0, 0)
    return true
  end
  
  aimLockMouseState = filtered
  local ok, emitted = sendAimLockMouseDelta(filtered.X, filtered.Y)
  if ok then
    if emitted then
      rememberAimLockDirectionProbe(delta)
    end
    return true
  end
  return false
end

function autoAimMouseStep(targetPos, smooth, speedFactor)
  return mouseAimStep(targetPos, smooth, "auto", speedFactor)
end

function rageAimMouseStep(targetPos, smooth)
  return mouseAimStep(targetPos, smooth, "rage", 1)
end

function getManualMouseDelta()
  local ok, d = pcall(function()
    return UserInputService:GetMouseDelta()
  end)
  if not ok or not d then
    return Vector2.new(0, 0)
  end
  
  local raw = Vector2.new(d.X, d.Y)
  local age = tick() - injectedMouseAt
  if age >= 0 and age <= 0.09 then
    local fade = 1 - (age / 0.09)
    raw = raw - (injectedMouseDelta * fade)
  end
  
  if raw.Magnitude < 0.08 then
    return Vector2.new(0, 0)
  end
  return raw
end

function getAutoAimPartFromTarget(t, noSwitch, deltaTime)
  if not t or not t.Parent then return nil, nil, nil, nil end
  
  local char = t.Parent
  local head = char:FindFirstChild("Head")
  local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
  local headPart = head or torso or t
  local torsoPart = torso or head or t
  
  local mode = tostring(STATE.AutoAimTargetPart or "Head")
  if mode == "Torso" then
    return torsoPart, torsoPart.Position, headPart, torsoPart
  end
  
  if mode == "Mixed" then
    local useVisibility = STATE.AutoAimVisibleCheck == true
    local now = tick()
    local headVisible = useVisibility and (headPart and isVisibleCached(headPart) or false) or true
    local torsoVisible = useVisibility and (torsoPart and isVisibleCached(torsoPart) or false) or true
    
    if useVisibility and headVisible and not torsoVisible then
      autoAimMixedUseHead = true
      autoAimMixedNextSwitch = now + 0.55
    elseif useVisibility and torsoVisible and not headVisible then
      autoAimMixedUseHead = false
      autoAimMixedNextSwitch = now + 0.55
    elseif (not noSwitch) and now >= autoAimMixedNextSwitch then
      autoAimMixedUseHead = not autoAimMixedUseHead
      autoAimMixedNextSwitch = now + (useVisibility and 0.62 or 0.72)
    end
    
    local targetBlend = autoAimMixedUseHead and 0 or 1
    local dt = math.clamp(deltaTime or (1 / 60), 1 / 240, 1 / 15)
    local blendAlpha = useVisibility and math.clamp(dt * 7, 0.04, 0.22) or math.clamp(dt * 4.8, 0.03, 0.14)
    autoAimMixedBlend = autoAimMixedBlend + (targetBlend - autoAimMixedBlend) * blendAlpha
    
    local mixedPos = headPart.Position:Lerp(torsoPart.Position, autoAimMixedBlend)
    local chosenPart = (autoAimMixedBlend < 0.5) and headPart or torsoPart
    return chosenPart, mixedPos, headPart, torsoPart
  end
  
  return headPart, headPart.Position, headPart, torsoPart
end

function isAutoAimTargetValid(t)
  if not t or not t.Parent or not Camera then
    return false
  end
  
  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end
  
  local part, aimPos, headPart, torsoPart = getAutoAimPartFromTarget(t, true)
  if not part or not aimPos then
    return false
  end
  
  if STATE.AutoAimVisibleCheck then
    local mode = tostring(STATE.AutoAimTargetPart or "Head")
    if mode == "Mixed" then
      local headVisible = headPart and isVisibleCached(headPart) or false
      local torsoVisible = torsoPart and isVisibleCached(torsoPart) or false
      if not headVisible and not torsoVisible then
        return false
      end
    else
      if not isVisibleCached(part) then
        return false
      end
    end
  end
  
  local sp, onScreen = worldToScreen(aimPos)
  if not onScreen then
    return false
  end
  
  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 then
    local dist3d = (aimPos - myRoot.Position).Magnitude
    if dist3d > safeNum(STATE.AimMaxDist) * 1.15 then
      return false
    end
  end
  
  local center = getAimScreenCenter()
  local dist2d = (sp - center).Magnitude
  if dist2d > safeNum(STATE.AimFOV) * 1.55 then
    return false
  end
  
  return true
end

function isAimLockTargetValid(t)
  if not t or not t.Parent or not Camera then
    return false
  end
  
  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end
  
  local lockPart = getPreferredPartFromPlayer(player, STATE.AimLockPart) or t
  if not lockPart or not lockPart.Parent then
    return false
  end
  
  local sp, onScreen = worldToScreen(lockPart.Position)
  if not onScreen then
    return false
  end
  
  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 then
    local dist3d = (lockPart.Position - myRoot.Position).Magnitude
    if dist3d > safeNum(STATE.AimMaxDist) * 1.15 then
      return false
    end
  end
  
  local center = getAimScreenCenter(true)
  if (sp - center).Magnitude > safeNum(STATE.AimFOV) * 1.15 then
    return false
  end

  return true, lockPart, player
end

function getAimLockPartAndPosition(player, fallbackPart)
  if not player or not player.Character then
    return nil, nil
  end
  
  local selected = tostring(STATE.AimLockPart or "Head")
  local lockPart = getPreferredPartFromPlayer(player, selected) or fallbackPart
  if not lockPart or not lockPart.Parent or not lockPart:IsA("BasePart") then
    return nil, nil
  end
  
  if selected == "Head" or selected == "Mixed" then
    local headPart, headPos = getHeadCenterFromPlayer(player, lockPart)
    if headPart and headPos then
      return headPart, headPos
    end
  end
  
  return lockPart, lockPart.Position
end

function isAimLockPlayerValid(player)
  if not player or player == LocalPlayer or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end
  
  local part, pos = getAimLockPartAndPosition(player, aimTarget)
  if not part or not pos then
    return false
  end
  
  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 and (pos - myRoot.Position).Magnitude > safeNum(STATE.AimMaxDist) * 1.15 then
    return false
  end
  
  local lookDir = pos - Camera.CFrame.Position
  if lookDir.Magnitude > 0.001 and Camera.CFrame.LookVector:Dot(lookDir.Unit) < 0.35 then
    return false
  end
  
  local sp, onScreen = worldToScreen(pos)
  if not onScreen then
    return false
  end
  
  local center = getAimScreenCenter(true)
  return (sp - center).Magnitude <= safeNum(STATE.AimFOV) * 1.35
end

function isAimLockRetainPlayerValid(player)
  if not player or player == LocalPlayer or not Camera or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end

  local part, pos = getAimLockPartAndPosition(player, aimTarget)
  if not part or not pos then
    return false
  end

  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 and (pos - myRoot.Position).Magnitude > safeNum(STATE.AimMaxDist) * 1.35 then
    return false
  end

  local lookDir = pos - Camera.CFrame.Position
  if lookDir.Magnitude > 0.001 and Camera.CFrame.LookVector:Dot(lookDir.Unit) < -0.15 then
    return false
  end

  return true
end

function isAutoAimRetainTargetValid(t)
  if not t or not t.Parent or not Camera then
    return false
  end

  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end

  local part, aimPos, headPart, torsoPart = getAutoAimPartFromTarget(t, true)
  if not part or not aimPos then
    return false
  end

  if STATE.AutoAimVisibleCheck then
    local mode = tostring(STATE.AutoAimTargetPart or "Head")
    if mode == "Mixed" then
      if not ((headPart and isVisibleCached(headPart)) or (torsoPart and isVisibleCached(torsoPart))) then
        return false
      end
    elseif not isVisibleCached(part) then
      return false
    end
  end

  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 and (aimPos - myRoot.Position).Magnitude > safeNum(STATE.AimMaxDist) * 1.35 then
    return false
  end

  local lookDir = aimPos - Camera.CFrame.Position
  if lookDir.Magnitude > 0.001 and Camera.CFrame.LookVector:Dot(lookDir.Unit) < -0.1 then
    return false
  end

  return true
end

function findAimLockTarget()
  updateCache()
  if not Camera or #cachedPlayers == 0 then
    return nil, nil
  end
  
  local ok, bestPart, bestPlayer = pcall(function()
    local center = getAimScreenCenter(true)
    local myRoot = getRoot()
    local maxDist = safeNum(STATE.AimMaxDist)
    local fov = safeNum(STATE.AimFOV)
    local closestPart, closestPlayer, bestDist = nil, nil, huge
    
    for _, player in ipairs(cachedPlayers) do
      if player and player ~= LocalPlayer and isAlive(player) and isEnemy(player, STATE.AimTeamCheck) then
        local part, pos = getAimLockPartAndPosition(player)
        if part and pos then
          local withinRange = true
          if myRoot and maxDist > 0 and (pos - myRoot.Position).Magnitude > maxDist then
            withinRange = false
          end
          
          if withinRange then
            local lookDir = pos - Camera.CFrame.Position
            if lookDir.Magnitude > 0.001 and Camera.CFrame.LookVector:Dot(lookDir.Unit) < 0.35 then
              withinRange = false
            end
          end
          
          if withinRange then
            local sp, onScreen = worldToScreen(pos)
            if onScreen then
              local dist = (sp - center).Magnitude
              if dist <= fov and dist < bestDist then
                closestPart = part
                closestPlayer = player
                bestDist = dist
              end
            end
          end
        end
      end
    end
    
    return closestPart, closestPlayer
  end)
  
  if ok then
    return bestPart, bestPlayer
  end
  return nil, nil
end

function getRagePartFromTarget(t, noSwitch, deltaTime)
  if not t or not t.Parent then return nil, nil, nil, nil end
  
  local char = t.Parent
  local head = char:FindFirstChild("Head")
  local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
  local headPart = head or torso or t
  local torsoPart = torso or head or t
  
  local mode = tostring(STATE.RageTargetPart or "Head")
  if mode == "Torso" then
    return torsoPart, torsoPart.Position, headPart, torsoPart
  end
  
  if mode == "Mixed" then
    local now = tick()
    if (not noSwitch) and now >= rageMixedNextSwitch then
      rageMixedUseHead = not rageMixedUseHead
      rageMixedNextSwitch = now + 0.42
    end
    
    local targetBlend = rageMixedUseHead and 0 or 1
    local dt = math.clamp(deltaTime or (1 / 60), 1 / 240, 1 / 15)
    local blendAlpha = math.clamp(dt * 9.5, 0.08, 0.34)
    rageMixedBlend = rageMixedBlend + (targetBlend - rageMixedBlend) * blendAlpha
    
    local mixedPos = headPart.Position:Lerp(torsoPart.Position, rageMixedBlend)
    local chosenPart = (rageMixedBlend < 0.5) and headPart or torsoPart
    return chosenPart, mixedPos, headPart, torsoPart
  end
  
  return headPart, headPart.Position, headPart, torsoPart
end

function isRageShotVisible(part)
  if not part or not part.Parent then
    return false
  end
  return true
end

function isRageAutoShootVisible(part)
  if not part or not part.Parent then
    return false
  end
  return isVisibleCached(part) == true
end

function isRageTargetValid(t)
  if not t or not t.Parent or not Camera then
    return false
  end
  
  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end
  
  local part, aimPos = getRagePartFromTarget(t, true)
  if not part or not aimPos then
    return false
  end
  
  return true
end

function isRageRetainTargetValid(t)
  if not t or not t.Parent or not Camera then
    return false
  end

  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end

  local part, aimPos = getRagePartFromTarget(t, true)
  if not part or not aimPos then
    return false
  end

  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 and (aimPos - myRoot.Position).Magnitude > safeNum(STATE.AimMaxDist) * 1.35 then
    return false
  end

  return true
end

function getMouseAssistPartAndPosition(t)
  if not t or not t.Parent then
    return nil, nil, nil
  end

  local player = Players:GetPlayerFromCharacter(t.Parent)
  if not player then
    return nil, nil, nil
  end

  local part = getPreferredPartFromPlayer(player, "Head") or t
  if not part or not part.Parent or not part:IsA("BasePart") then
    return nil, nil, nil
  end

  local headPart, headPos = getHeadCenterFromPlayer(player, part)
  if headPart and headPos then
    return headPart, headPos, player
  end

  return part, part.Position, player
end

function isMouseAssistTargetValid(t, retain)
  if not t or not t.Parent or not Camera then
    return false
  end

  local part, pos, player = getMouseAssistPartAndPosition(t)
  if not part or not pos or not player or not isAlive(player) or not isEnemy(player, STATE.AimTeamCheck) then
    return false
  end

  local myRoot = getRoot()
  if myRoot and safeNum(STATE.AimMaxDist) > 0 and (pos - myRoot.Position).Magnitude > safeNum(STATE.AimMaxDist) * (retain and 1.3 or 1.1) then
    return false
  end

  local sp, onScreen = worldToScreen(pos)
  if not onScreen then
    return retain == true
  end

  local center = getAimScreenCenter()
  local limit = safeNum(STATE.AimFOV) * (retain and 1.9 or 1.15)
  return (sp - center).Magnitude <= limit
end

function setupCombat()
  addConnection("combat", RunService.RenderStepped:Connect(function(deltaTime)
    STATE.AimTeamCheck = true
    STATE.AimRequireCenter = true
    STATE.TriggerTeamCheck = true
    STATE.TriggerRequireCenter = true
    STATE.TriggerVisibleCheck = true
    STATE.RageVisibilityCheck = false
    STATE.AimLockStrength = 100
    local aimModeCount = (STATE.AimLock and 1 or 0) + (STATE.AutoAim and 1 or 0) + (STATE.RageBot and 1 or 0)
    if aimModeCount > 1 and enforceAimModeExclusivity then
      enforceAimModeExclusivity()
    end

    if not RUNNING or not Camera then
      aimTarget = nil
      aimLockedPlayer = nil
      autoAimTarget = nil
      autoAimLockedPlayer = nil
      autoAimSmoothedPos = nil
      autoAimPredictedPos = nil
      autoAimLastPart = nil
      autoAimLastRawPos = nil
      autoAimVelocity = Vector3.zero
      autoAimLostSince = 0
      autoAimManualBreakUntil = 0
      autoAimBreakScore = 0
      rageTarget = nil
      rageLockedPlayer = nil
      rageNextShotAt = 0
      restoreRageWeaponLock()
      resetMouseModeState("auto", true)
      resetMouseModeState("lock", true)
      resetMouseModeState("rage", true)
      return
    end

    updateFOV()
    
    if not isRoundStarted() then
      aimTarget = nil
      aimLockedPlayer = nil
      autoAimTarget = nil
      autoAimLockedPlayer = nil
      autoAimSmoothedPos = nil
      autoAimPredictedPos = nil
      autoAimLastPart = nil
      autoAimLastRawPos = nil
      autoAimVelocity = Vector3.zero
      autoAimLostSince = 0
      autoAimReleaseUntil = 0
      autoAimManualBreakUntil = 0
      autoAimBreakScore = 0
      rageTarget = nil
      rageLockedPlayer = nil
      rageNextShotAt = 0
      restoreRageWeaponLock()
      clearAimTargetHighlight()
      resetMouseModeState("auto", true)
      resetMouseModeState("lock", true)
      resetMouseModeState("rage", true)
      return
    end

    if STATE.SilentAim and not STATE.AimLock and not STATE.AutoAim and not STATE.RageBot then
      if aimTarget or aimLockedPlayer or autoAimTarget or autoAimLockedPlayer or rageTarget or rageLockedPlayer then
        aimTarget = nil
        aimLockedPlayer = nil
        autoAimTarget = nil
        autoAimLockedPlayer = nil
        autoAimSmoothedPos = nil
        autoAimPredictedPos = nil
        autoAimLastPart = nil
        autoAimLastRawPos = nil
        autoAimVelocity = Vector3.zero
        autoAimLostSince = 0
        autoAimReleaseUntil = 0
        autoAimManualBreakUntil = 0
        autoAimBreakScore = 0
        rageTarget = nil
        rageLockedPlayer = nil
        rageNextShotAt = 0
        restoreRageWeaponLock()
        clearAimTargetHighlight()
      end
      return
    end

    local centerOk = isAimCenterGateOpen()
    local hasActiveTarget = (STATE.AutoAim and autoAimTarget and autoAimTarget.Parent) or (STATE.RageBot and rageTarget and rageTarget.Parent)
    
    if not centerOk and not hasActiveTarget and not STATE.AimLock then
      aimTarget = nil
      aimLockedPlayer = nil
      autoAimTarget = nil
      autoAimLockedPlayer = nil
      autoAimSmoothedPos = nil
      autoAimPredictedPos = nil
      autoAimLastPart = nil
      autoAimLastRawPos = nil
      autoAimVelocity = Vector3.zero
      autoAimLostSince = 0
      autoAimReleaseUntil = tick() + 0.06
      autoAimManualBreakUntil = tick() + 0.08
      autoAimBreakScore = 0
      clearAimTargetHighlight()
      if not STATE.RageBot then
        rageTarget = nil
        rageLockedPlayer = nil
        rageNextShotAt = 0
        restoreRageWeaponLock()
      end
      return
    end
    
    pcall(function()
      if STATE.RageBot then
        aimTarget = nil
        autoAimTarget = nil
        autoAimSmoothedPos = nil
        autoAimPredictedPos = nil
        autoAimLastPart = nil
        autoAimLastRawPos = nil
        autoAimVelocity = Vector3.zero
        autoAimLostSince = 0
        autoAimBreakScore = 0
        clearAimTargetHighlight()
        
        local now = tick()
        local rageRmbDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local rageAimAllowed = (not STATE.RageRequireADS) or rageRmbDown
        if not rageAimAllowed then
          rageTarget = nil
          rageLockedPlayer = nil
          rageNextShotAt = 0
          restoreRageWeaponLock()
          return
        end
        
        if rageLockedPlayer and not isAlive(rageLockedPlayer) then
          rageLockedPlayer = nil
          rageTarget = nil
        end
        
        if rageTarget and not isRageRetainTargetValid(rageTarget) then
          rageTarget = nil
        end
        
        if (not rageTarget) and rageLockedPlayer then
          rageTarget = getPreferredPartFromPlayer(rageLockedPlayer, STATE.RageTargetPart)
        end
        
        if not rageTarget then
          if not centerOk then
            rageNextShotAt = 0
            restoreRageWeaponLock()
            return
          end
          local preferredPart = nil
          local rageMode = tostring(STATE.RageTargetPart or "Head")
          if rageMode == "Head" then
            preferredPart = "Head"
          elseif rageMode == "Torso" then
            preferredPart = "UpperTorso"
          elseif rageMode == "Mixed" then
            rageMixedUseHead = true
            rageMixedBlend = 0
            rageMixedNextSwitch = now + 0.32
            preferredPart = "Head"
          end
          
          rageTarget = getClosest(
            STATE.AimFOV,
            STATE.AimTeamCheck,
            STATE.AimMaxDist,
            false,
            false,
            preferredPart
          )
          rageLockedPlayer = rageTarget and Players:GetPlayerFromCharacter(rageTarget.Parent) or nil
        end
        
        if rageTarget then
          local targetPart, targetBasePos = getRagePartFromTarget(rageTarget, false, deltaTime)
          if not targetPart or not targetBasePos then
            rageTarget = nil
            if not rageLockedPlayer or not isAlive(rageLockedPlayer) then
              rageLockedPlayer = nil
            end
            rageNextShotAt = 0
            return
          end
          
          if not rageLockedPlayer then
            rageLockedPlayer = Players:GetPlayerFromCharacter(targetPart.Parent)
          end
          
          if not isRageShotVisible(targetPart) then
            rageTarget = nil
            rageNextShotAt = 0
            restoreRageWeaponLock()
            return
          end
          
          local targetPos = targetBasePos
          
          local lockStrength = math.clamp(safeNum(STATE.RageLockStrength), 1, 100) / 100
          local useMouse = hasMouseAssistBackend()
          local weaponLocked = false
          
          if useMouse then
            local smooth = math.clamp(9.5 - (lockStrength * 8.4), 1.01, 9.5)
            rageAimMouseStep(targetPos, smooth)
          else
            rageNextShotAt = 0
            restoreRageWeaponLock()
            return
          end
          
          local shouldShoot = STATE.RageAutoShoot and ((not STATE.RageRequireADS) or rageRmbDown) and isRageAutoShootVisible(targetPart)
          
          if shouldShoot and now >= rageNextShotAt then
            local cps = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.RageCPS)))
            local interval = 1 / cps
            if weaponLocked then
              click(interval)
            else
              local sp, os = worldToScreen(targetPos)
              if os then
                local center = getAimScreenCenter()
                local shootRadius = math.max(2, safeNum(STATE.RageShootFOV))
                if (sp - center).Magnitude <= shootRadius then
                  click(interval)
                end
              end
            end
            
            rageNextShotAt = now + interval
          end
          
          return
        else
          rageNextShotAt = 0
          restoreRageWeaponLock()
        end
      else
        rageTarget = nil
        rageLockedPlayer = nil
        rageNextShotAt = 0
        restoreRageWeaponLock()
      end
      
      if STATE.AimLock then
        -- AimLock is handled by its own loop and never uses AutoAim smoothing.
        return
      elseif STATE.AutoAim then
        if STATE.AutoAimRequireRMB and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
          if mouseStepState then
            mouseStepState.auto = mouseStepState.auto:Lerp(Vector2.new(0, 0), 0.65)
          end
          return
        end

        clearAimTargetHighlight()
        local now = tick()
        if now < autoAimReleaseUntil then
          autoAimReleaseUntil = 0
        end
        if now < autoAimManualBreakUntil then
          autoAimManualBreakUntil = 0
        end
        
        if autoAimLockedPlayer and not isAlive(autoAimLockedPlayer) then
          autoAimLockedPlayer = nil
          autoAimTarget = nil
        end
        
        if autoAimTarget and not isAutoAimRetainTargetValid(autoAimTarget) then
          if autoAimLostSince == 0 then
            autoAimLostSince = now
          end
          if now - autoAimLostSince > 0.38 then
            autoAimTarget = nil
            autoAimLockedPlayer = nil
            autoAimSmoothedPos = nil
            autoAimPredictedPos = nil
            autoAimLastPart = nil
            autoAimLastRawPos = nil
            autoAimVelocity = Vector3.zero
            autoAimLostSince = 0
            autoAimReleaseUntil = 0
            autoAimBreakScore = 0
            mouseStepState.auto = mouseStepState.auto:Lerp(Vector2.new(0, 0), 0.24)
            return
          end
        else
          autoAimLostSince = 0
        end
        
        if not autoAimTarget then
          if autoAimLockedPlayer then
            autoAimTarget = getPreferredPartFromPlayer(autoAimLockedPlayer, STATE.AutoAimTargetPart)
          end
        end
        
        if not autoAimTarget then
          if not centerOk then
            if mouseStepState then
              mouseStepState.auto = mouseStepState.auto:Lerp(Vector2.new(0, 0), 0.65)
            end
            return
          end
          local preferredPart = nil
          local mode = tostring(STATE.AutoAimTargetPart or "Head")
          if mode == "Head" then
            preferredPart = "Head"
          elseif mode == "Torso" then
            preferredPart = "UpperTorso"
          elseif mode == "Mixed" then
            autoAimMixedUseHead = true
            autoAimMixedBlend = 0
            autoAimMixedNextSwitch = tick() + 0.48
            preferredPart = "Head"
          end
          
          autoAimTarget = getClosest(
            STATE.AimFOV,
            STATE.AimTeamCheck,
            STATE.AimMaxDist,
            STATE.AutoAimVisibleCheck,
            false,
            preferredPart
          )
          autoAimLockedPlayer = autoAimTarget and Players:GetPlayerFromCharacter(autoAimTarget.Parent) or nil
          autoAimSmoothedPos = nil
          autoAimPredictedPos = nil
          autoAimLastPart = nil
          autoAimLastRawPos = nil
          autoAimVelocity = Vector3.zero
        end
        
        local autoTarget = autoAimTarget
        if autoTarget then
          local targetPart, targetPos = getAutoAimPartFromTarget(autoTarget, false, deltaTime)
          if not targetPart or not targetPos then
            autoAimTarget = nil
            autoAimLockedPlayer = nil
            autoAimSmoothedPos = nil
            autoAimPredictedPos = nil
            autoAimLastPart = nil
            autoAimLastRawPos = nil
            autoAimVelocity = Vector3.zero
            return
          end
          local _, onScreen = worldToScreen(targetPos)
          if not onScreen then
            autoAimBreakScore = math.max(0, autoAimBreakScore - 0.08)
            return
          end

          if autoAimLastPart ~= targetPart then
            if tostring(STATE.AutoAimTargetPart or "Head") ~= "Mixed" then
              autoAimSmoothedPos = nil
              autoAimPredictedPos = nil
            end
            autoAimLastPart = targetPart
          end

          local dt = math.clamp(deltaTime or (1 / 60), 1 / 240, 1 / 15)
          local rawVelocity = Vector3.zero
          if autoAimLastRawPos then
            rawVelocity = (targetPos - autoAimLastRawPos) / dt
          end
          local partVelocity = targetPart.AssemblyLinearVelocity
          if typeof(partVelocity) == "Vector3" and partVelocity.Magnitude > rawVelocity.Magnitude then
            rawVelocity = partVelocity
          end
          autoAimLastRawPos = targetPos
          if rawVelocity.Magnitude > 260 then
            rawVelocity = rawVelocity.Unit * 260
          end
          local velocityAlpha = math.clamp(dt * 8, 0.08, 0.24)
          autoAimVelocity = (autoAimVelocity or Vector3.zero):Lerp(rawVelocity, velocityAlpha)
          local targetSpeed = math.min(autoAimVelocity.Magnitude, 220)
          local autoAimSpeedFactor = math.clamp(1 + (targetSpeed / 180), 1, 1.55)

          if autoAimSmoothedPos == nil then
            autoAimSmoothedPos = targetPos
            autoAimPredictedPos = nil
          else
            local posAlpha
            if tostring(STATE.AutoAimTargetPart or "Head") == "Mixed" then
              posAlpha = math.clamp(dt * (7.5 + targetSpeed * 0.028), 0.1, 0.34)
            else
              posAlpha = math.clamp(dt * (8.5 + targetSpeed * 0.03), 0.11, 0.38)
            end
            autoAimSmoothedPos = autoAimSmoothedPos:Lerp(targetPos, posAlpha)
          end

          local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
          local modeStrength = isAiming and safeNum(STATE.AutoAimStrengthADS) or safeNum(STATE.AutoAimStrengthHip)
          if modeStrength <= 0 then
            return
          end

          local strength = math.clamp(modeStrength, 1, 100) / 100
          local curve = strength ^ 1.45
          local hum = getHumanoid()
          local moveMag = hum and hum.MoveDirection and hum.MoveDirection.Magnitude or 0
          local movePenalty = math.clamp(moveMag * 0.08, 0, 0.08)
          local adjustedStrength = math.clamp(curve - movePenalty, 0, 1)

          local predictionScale = math.clamp(safeNum(STATE.AutoAimPrediction) / 100, 0, 1)
          local leadTime = math.clamp(0.018 + (targetSpeed * 0.00022), 0.018, 0.065) * adjustedStrength * predictionScale
          local rawBlend = math.clamp(0.22 + adjustedStrength * 0.28, 0.22, 0.48)
          local predictedTarget = autoAimSmoothedPos:Lerp(targetPos, rawBlend) + (autoAimVelocity * leadTime)
          local leadDelta = predictedTarget - targetPos
          local maxLead = 2.5 + (targetSpeed * 0.012)
          if leadDelta.Magnitude > maxLead then
            predictedTarget = targetPos + (leadDelta.Unit * maxLead)
          end
          if autoAimPredictedPos == nil then
            autoAimPredictedPos = predictedTarget
          else
            local predictAlpha = math.clamp(dt * (8 + adjustedStrength * 4), 0.12, 0.34)
            autoAimPredictedPos = autoAimPredictedPos:Lerp(predictedTarget, predictAlpha)
          end
          local targetForAim = autoAimPredictedPos
          
          local _, targetScreenVisible = worldToScreen(targetForAim)
          if targetScreenVisible and modeStrength < 85 then
            local manualDelta = getManualMouseDelta()
            local manualMag = manualDelta.Magnitude

            local manualThreshold
            if modeStrength >= 100 then
              manualThreshold = 8.5
            else
              manualThreshold = 3.0 + math.clamp((100 - modeStrength) * 0.018, 0, 1.8)
            end
            if manualMag > manualThreshold then
              autoAimBreakScore = math.min(2.5, autoAimBreakScore + 0.18)
              mouseStepState.auto = mouseStepState.auto:Lerp(Vector2.new(0, 0), 0.16)
            else
              autoAimBreakScore = math.max(0, autoAimBreakScore - 0.22)
            end
          elseif not targetScreenVisible then
            autoAimBreakScore = math.max(0, autoAimBreakScore - 0.12)
          end

          local useMouse = hasMouseAssistBackend()
          if useMouse then
            local smooth = math.clamp(8.5 - (adjustedStrength * 3.0) - ((autoAimSpeedFactor - 1) * 0.4), 4.0, 8.5)
            if modeStrength >= 100 then
              smooth = math.max(3.6, 4.8 - ((autoAimSpeedFactor - 1) * 0.25))
            end
            autoAimMouseStep(targetForAim, smooth, autoAimSpeedFactor)
          else
            return
          end
          
        else
          autoAimTarget = nil
          autoAimLockedPlayer = nil
          autoAimSmoothedPos = nil
          autoAimPredictedPos = nil
          autoAimLastPart = nil
          autoAimLastRawPos = nil
          autoAimVelocity = Vector3.zero
          autoAimBreakScore = math.max(0, autoAimBreakScore - 0.2)
        end
      else
        aimTarget = nil
        aimLockedPlayer = nil
        autoAimTarget = nil
        autoAimLockedPlayer = nil
        autoAimSmoothedPos = nil
        autoAimPredictedPos = nil
        autoAimLastPart = nil
        autoAimLastRawPos = nil
        autoAimVelocity = Vector3.zero
        autoAimLostSince = 0
        autoAimBreakScore = 0
        autoAimManualBreakUntil = 0
        rageLockedPlayer = nil
        clearAimTargetHighlight()
      end
    end)
  end))
end

function setupAimLockLoop()
  addConnection("combat.aimlock", RunService.RenderStepped:Connect(function(deltaTime)
    STATE.AimTeamCheck = true
    STATE.AimRequireCenter = true
    STATE.AimLockStrength = 100
    
    if not RUNNING or not Camera then
      resetAimLockRuntime()
      return
    end
    
    if not STATE.AimLock then
      if aimTarget or aimLockedPlayer then
        resetAimLockRuntime()
      end
      return
    end
    
    if not isRoundStarted() then
      resetAimLockRuntime()
      return
    end
    
    if STATE.AimLockRequireRMB and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
      aimLockMouseState = (aimLockMouseState or Vector2.new(0, 0)):Lerp(Vector2.new(0, 0), 0.72)
      aimLockMouseRemainder = Vector2.new(0, 0)
      if aimLockDirectionProbe then
        aimLockDirectionProbe.error = nil
        aimLockDirectionProbe.at = 0
        aimLockDirectionProbe.bad = 0
      end
      clearAimTargetHighlight()
      return
    end
    
    local now = tick()
    
    if aimLockedPlayer and not isAimLockRetainPlayerValid(aimLockedPlayer) then
      if aimLockLostSince == 0 then
        aimLockLostSince = now
      end
      if now - aimLockLostSince > 0.65 then
        resetAimLockRuntime()
        return
      end
    else
      aimLockLostSince = 0
    end
    
    if not aimLockedPlayer then
      aimTarget, aimLockedPlayer = findAimLockTarget()
      aimLockLostSince = 0
    end
    
    if not aimLockedPlayer then
      aimTarget = nil
      aimLockMouseState = (aimLockMouseState or Vector2.new(0, 0)):Lerp(Vector2.new(0, 0), 0.72)
      aimLockMouseRemainder = Vector2.new(0, 0)
      clearAimTargetHighlight()
      return
    end
    
    local lockPart, targetPos = getAimLockPartAndPosition(aimLockedPlayer, aimTarget)
    if not lockPart or not targetPos then
      resetAimLockRuntime()
      return
    end
    
    aimTarget = lockPart
    setAimTargetHighlight(lockPart)
    aimLockMouseStep(targetPos)
  end))
end

function setupMouseAimAssistLoop()
  addConnection("combat.mouseassist", RunService.RenderStepped:Connect(function(deltaTime)
    STATE.AimTeamCheck = true
    if not RUNNING or not Camera then
      resetMouseAssistRuntime()
      return
    end

    if STATE.AimMouseAssist ~= true or STATE.AimLock or STATE.AutoAim or STATE.RageBot or not isRoundStarted() then
      resetMouseAssistRuntime()
      return
    end

    if not isAimCenterGateOpen() then
      mouseStepState.assist = (mouseStepState.assist or Vector2.new(0, 0)):Lerp(Vector2.new(0, 0), 0.55)
      mouseAssistLostSince = 0
      return
    end

    local now = tick()
    if mouseAssistLockedPlayer and not isAlive(mouseAssistLockedPlayer) then
      resetMouseAssistRuntime()
    end

    if mouseAssistTarget and not isMouseAssistTargetValid(mouseAssistTarget, true) then
      if mouseAssistLostSince == 0 then
        mouseAssistLostSince = now
      end
      if now - mouseAssistLostSince > 0.45 then
        resetMouseAssistRuntime()
      end
    else
      mouseAssistLostSince = 0
    end

    if not mouseAssistTarget then
      mouseAssistTarget = getClosest(
        STATE.AimFOV,
        STATE.AimTeamCheck,
        STATE.AimMaxDist,
        false,
        false,
        "Head"
      )
      local _, _, player = getMouseAssistPartAndPosition(mouseAssistTarget)
      mouseAssistLockedPlayer = player
      mouseAssistSmoothedPos = nil
    end

    if not mouseAssistTarget then
      mouseStepState.assist = (mouseStepState.assist or Vector2.new(0, 0)):Lerp(Vector2.new(0, 0), 0.45)
      return
    end

    local part, targetPos, player = getMouseAssistPartAndPosition(mouseAssistTarget)
    if not part or not targetPos or not player then
      resetMouseAssistRuntime()
      return
    end

    mouseAssistLockedPlayer = player
    local dt = math.clamp(deltaTime or (1 / 60), 1 / 240, 1 / 15)
    if mouseAssistSmoothedPos == nil then
      mouseAssistSmoothedPos = targetPos
    else
      local alpha = math.clamp(dt * 8.5, 0.08, 0.3)
      mouseAssistSmoothedPos = mouseAssistSmoothedPos:Lerp(targetPos, alpha)
    end

    local strength = math.clamp(safeNum(STATE.AimMouseAssistStrength) / 100, 0.05, 1)
    local smooth = math.clamp(13 - (strength * 6.5), 5.5, 13)
    if hasMouseAssistBackend() then
      mouseAimStep(mouseAssistSmoothedPos, smooth, "assist", 1)
    else
      aimCameraAt(mouseAssistSmoothedPos, math.clamp(0.035 + (strength * 0.055), 0.035, 0.09))
    end
  end))
end

--  TRIGGER BOT
local nextTriggerShotAt = 0
local triggerRayParams = RaycastParams.new()
triggerRayParams.FilterType = Enum.RaycastFilterType.Exclude

function updateTriggerParams()
  local exclude = {workspace.Terrain}
  local char = getChar()
  if char then
    table.insert(exclude, char)
  end
  triggerRayParams.FilterDescendantsInstances = exclude
end

function triggerCheckCenter()
  if not Camera then return false end
  updateTriggerParams()
  local vp = Camera.ViewportSize
  local teamCheck = STATE.TriggerTeamCheck == true
  local center = getAimScreenCenter(true)
  local mode = tostring(STATE.TriggerTarget or "Head")
  
  local function getPlayerFromHitPart(part)
    if not part then return nil end
    local model = part:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    return Players:GetPlayerFromCharacter(model)
  end

  local function getTriggerPart(char)
    if not char then return nil end
    if mode == "Torso" then
      return char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    end
    if mode == "Any Visible Body" then
      return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    end
    return char:FindFirstChild("Head")
  end

  local function hitPartAllowed(player, hitPart)
    if not player or not hitPart or not player.Character then
      return false
    end
    if not isEnemy(player, teamCheck) or not isAlive(player) then
      return false
    end
    if not hitPart:IsDescendantOf(player.Character) then
      return false
    end
    if mode == "Any Visible Body" then
      return hitPart:IsA("BasePart")
    end
    local wanted = getTriggerPart(player.Character)
    if not wanted then return false end
    if hitPart == wanted then
      return true
    end
    if hitPart:IsDescendantOf(wanted) then
      return true
    end
    return tostring(hitPart.Name) == tostring(wanted.Name)
  end
  
  local function isPartInTriggerAssist(part, pos)
    if not part or not part.Parent or not pos then return false end
    local player = Players:GetPlayerFromCharacter(part.Parent)
    if not player or not isEnemy(player, teamCheck) or not isAlive(player) then
      return false
    end
    
    if STATE.TriggerVisibleCheck ~= false and not isVisibleCached(part) then
      return false
    end
    
    local vel = part.AssemblyLinearVelocity or part.Velocity or V0
    local leadTime = math.clamp(vel.Magnitude / 2500, 0.0, 0.045)
    local predictedPos = pos + (vel * leadTime)
    local sp, onScreen = worldToScreen(predictedPos)
    if not onScreen then
      return false
    end
    
    local speedBoost = math.clamp(vel.Magnitude / 70, 0, 8)
    local baseRadius = mode == "Head" and 7 or (mode == "Torso" and 10 or 13)
    local assistBoost = (STATE.AutoAim or STATE.AimLock or STATE.RageBot) and 3.5 or 0
    local radius = baseRadius + speedBoost + assistBoost
    return (sp - center).Magnitude <= radius
  end
  
  if STATE.AutoAim and autoAimTarget then
    local part, pos = getAutoAimPartFromTarget(autoAimTarget, true, 1 / 60)
    if mode ~= "Any Visible Body" and part and part.Parent then
      part = getTriggerPart(part.Parent) or part
      pos = part.Position
    end
    if isPartInTriggerAssist(part, pos) then
      return true
    end
  end
  
  if STATE.AimLock and aimTarget and aimTarget.Parent then
    local lockPart = getTriggerPart(aimTarget.Parent) or aimTarget
    if isPartInTriggerAssist(lockPart, lockPart.Position) then
      return true
    end
  end
  
  if STATE.RageBot and rageTarget then
    local part, pos = getRagePartFromTarget(rageTarget, true, 1 / 60)
    if mode ~= "Any Visible Body" and part and part.Parent then
      part = getTriggerPart(part.Parent) or part
      pos = part.Position
    end
    if isPartInTriggerAssist(part, pos) then
      return true
    end
  end
  
  local spread = mode == "Head" and 1 or (mode == "Torso" and 2 or 3)
  
  for _, offset in ipairs({
    Vector2.new(center.X, center.Y),
    Vector2.new(center.X - spread, center.Y),
    Vector2.new(center.X + spread, center.Y),
    Vector2.new(center.X, center.Y - spread),
    Vector2.new(center.X, center.Y + spread),
    Vector2.new(center.X - spread, center.Y - spread),
    Vector2.new(center.X + spread, center.Y - spread),
    Vector2.new(center.X - spread, center.Y + spread),
    Vector2.new(center.X + spread, center.Y + spread),
  }) do
    local ray = Camera:ViewportPointToRay(offset.X, offset.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1200, triggerRayParams)
    if result and result.Instance then
      local player = getPlayerFromHitPart(result.Instance)
      if hitPartAllowed(player, result.Instance) then
        return true
      end
    end
  end

  updateCache()
  local fallbackRadius = mode == "Head" and 8 or (mode == "Torso" and 12 or 16)
  for _, player in ipairs(cachedPlayers) do
    if player and player ~= LocalPlayer and isEnemy(player, teamCheck) and isAlive(player) then
      local char = player.Character
      local part = getTriggerPart(char)
      if part and part:IsA("BasePart") then
        local vel = part.AssemblyLinearVelocity or part.Velocity or V0
        local predicted = part.Position + (vel * math.clamp(vel.Magnitude / 2800, 0, 0.04))
        local sp, onScreen = worldToScreen(predicted)
        if onScreen and (sp - center).Magnitude <= fallbackRadius then
          if STATE.TriggerVisibleCheck == false or isVisibleCached(part) then
            return true
          end
        end
      end
    end
  end
  
  return false
end

function setupTrigger()
  updateTriggerParams()
  
  task.spawn(function()
    while RUNNING do
      STATE.TriggerVisibleCheck = true
      if STATE.TriggerEnabled then
        pcall(function()
          if STATE.RageBot and STATE.RageAutoShoot then
            return
          end
          
          local hasAimAssistTarget = (STATE.AutoAim and autoAimTarget ~= nil) or (STATE.AimLock and aimTarget ~= nil) or (STATE.RageBot and rageTarget ~= nil)
          local triggerCenterOpen = true
          if (not hasAimAssistTarget) and (not triggerCenterOpen) then
            return
          end
          
          local now = tick()
          if now >= nextTriggerShotAt then
            if triggerCheckCenter() then
              local delayMs = math.max(0, safeNum(STATE.TriggerDelay))
              if delayMs > 0 then
                task.wait(delayMs / 1000)
              end
              
              local cps = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.TriggerCPS)))
              local interval = 1 / cps
              local fired = click(interval)
              if fired then
                nextTriggerShotAt = tick() + interval
              else
                nextTriggerShotAt = tick() + 0.05
              end
            end
          end
        end)
        
        local cps = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.TriggerCPS)))
        task.wait(math.clamp((1 / cps) * 0.5, 0.001, 0.01))
      else
        nextTriggerShotAt = 0
        task.wait(0.1)
      end
    end
  end)
end

--  TELEPORT + AUTO BACKSTAB
local tpDropdownRef = nil
local backstabBusy = false
local nextBackstabAt = 0
local namesOrbitBusy = false
local nextNamesOrbitAt = 0

function setTPPlayer(value)
  if type(value) == "table" then
    value = value[1]
  end
  if not value or value == "None" then
    STATE.TPPlayer = ""
    return
  end
  local matched = findPlayerByName(value)
  if matched then
    STATE.TPPlayer = matched.Name
  else
    STATE.TPPlayer = tostring(value)
  end
end

function getBackstabTargetPlayer()
  local selected = findPlayerByName(STATE.TPPlayer)
  if selected and selected ~= LocalPlayer and isAlive(selected) and isEnemy(selected, STATE.AimTeamCheck) then
    return selected
  end
  return getNearestEnemyPlayer()
end

function refreshTPDropdown()
  if not tpDropdownRef then return end
  
  local options = getSelectablePlayers()
  pcall(function()
    if tpDropdownRef.Refresh then
      tpDropdownRef:Refresh(options)
    elseif tpDropdownRef.SetOptions then
      tpDropdownRef:SetOptions(options)
    end
    
    local selected = findPlayerByName(STATE.TPPlayer)
    local selectedLabel = selected and getPlayerLabel(selected) or "None"
    if tpDropdownRef.Set then
      tpDropdownRef:Set(selectedLabel)
    end
  end)
  
  if not findPlayerByName(STATE.TPPlayer) then
    if options[1] ~= "None" then
      setTPPlayer(options[1])
    else
      STATE.TPPlayer = ""
    end
  end
end

function teleportNearSelected(behind)
  local targetPlayer = findPlayerByName(STATE.TPPlayer)
  if not targetPlayer then
    notify("TP", "Waehle zuerst einen Spieler", 2)
    return false
  end
  
  local targetRoot = getPlayerRoot(targetPlayer)
  if not targetRoot then
    notify("TP", "Target hat keinen Root", 2)
    return false
  end
  
  rightClick()
  task.wait(0.02)
  local ok = teleportToTargetRoot(targetRoot, behind == true)
  if ok then
    notify("TP", string.format("Zu %s (@%s) teleportiert", tostring(targetPlayer.DisplayName or targetPlayer.Name), tostring(targetPlayer.Name)), 1.5)
  end
  return ok
end

function teleportUpSelected()
  local targetPlayer = findPlayerByName(STATE.TPPlayer)
  if not targetPlayer then
    notify("TP", "Waehle zuerst einen Spieler", 2)
    return false
  end

  local targetRoot = getPlayerRoot(targetPlayer)
  if not targetRoot then
    notify("TP", "Target hat keinen Root", 2)
    return false
  end

  local myRoot = getRoot()
  if not myRoot then
    notify("TP", "Eigener Root fehlt", 2)
    return false
  end

  local upDist = math.max(4, safeNum(STATE.TPDistance) + 3)
  local upPos = targetRoot.Position + Vector3.new(0, upDist, 0)
  pcall(function()
    myRoot.CFrame = CFrame.new(upPos, targetRoot.Position)
  end)
  notify("TP", string.format("Ueber %s (@%s) teleportiert", tostring(targetPlayer.DisplayName or targetPlayer.Name), tostring(targetPlayer.Name)), 1.5)
  return true
end

function followBehindTargetBriefly(targetRoot, durationSec)
  if not targetRoot or not targetRoot.Parent then return end
  local myRoot = getRoot()
  if not myRoot then return end
  
  local duration = math.clamp(safeNum(durationSec), 0.1, 2)
  local endAt = tick() + duration
  while RUNNING and tick() < endAt do
    if not myRoot.Parent or not targetRoot.Parent then
      break
    end
    local behindDist = math.max(2, safeNum(STATE.TPDistance))
    local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * behindDist
    myRoot.CFrame = CFrame.new(behindPos, targetRoot.Position)
    task.wait(0.03)
  end
end

function getPlayerHumanoid(player)
  local char = player and player.Character
  return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function hasSpawnProtection(player)
  local char = player and player.Character
  if not char then return false end
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

function waitForSpawnProtectionGone(player, maxWait, requireAuto)
  local deadline = tick() + math.clamp(safeNum(maxWait), 0.5, 10)
  while RUNNING and (requireAuto ~= true or STATE.AutoBackstab) and isAlive(player) and hasSpawnProtection(player) do
    if tick() >= deadline then
      return false
    end
    task.wait(0.08)
  end
  return (requireAuto ~= true or STATE.AutoBackstab) and isAlive(player) and not hasSpawnProtection(player)
end

function getBackAimPosition(targetRoot)
  if not targetRoot then return nil end
  return targetRoot.Position - (targetRoot.CFrame.LookVector * 0.9) + Vector3.new(0, 0.75, 0)
end

function aimAtTargetBack(targetRoot)
  local myRoot = getRoot()
  local aimPos = getBackAimPosition(targetRoot)
  if not myRoot or not targetRoot or not aimPos then return false end
  local behindDist = math.max(2, safeNum(STATE.TPDistance))
  local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * behindDist
  myRoot.CFrame = CFrame.new(behindPos, aimPos)
  if Camera then
    pcall(function()
      Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimPos)
    end)
  end
  return true
end

function fireBegAction()
  local remotes = ReplicatedStorage:FindFirstChild("Remotes")
  local misc = remotes and remotes:FindFirstChild("Misc")
  local dialogAction = misc and misc:FindFirstChild("DialogAction")
  if dialogAction and dialogAction:IsA("RemoteEvent") then
    pcall(function()
      dialogAction:FireServer("beg")
    end)
    return true
  end
  return false
end

function setupBeggerFarm()
  task.spawn(function()
    while RUNNING do
      if STATE.BeggerFarm then
        fireBegAction()
        task.wait(0.15)
      else
        task.wait(0.35)
      end
    end
  end)
end

function normalizeControlModeName(mode)
  local m = tostring(mode or "MouseKeyboard")
  if m == "Touch" or m == "Gamepad" or m == "MouseKeyboard" or m == "VR" then return m end
  m = string.lower(m)
  if m == "mobile" then return "Touch" end
  if m == "console" or m == "controller" then return "Gamepad" end
  if m == "vr" then return "VR" end
  return "MouseKeyboard"
end
function getSelectedControlMode()
  if STATE.VRSpoof then return "VR" end
  if STATE.ConsoleSpoof then return "Gamepad" end
  if STATE.MobileSpoof then return "Touch" end
  return "MouseKeyboard"
end
function getSetControlsRemote()
  if controlSpoofRemote and controlSpoofRemote.Parent then return controlSpoofRemote end
  local remotes = ReplicatedStorage:FindFirstChild("Remotes")
  local replication = remotes and remotes:FindFirstChild("Replication")
  local fighter = replication and replication:FindFirstChild("Fighter")
  local remote = fighter and fighter:FindFirstChild("SetControls")
  if remote and remote:IsA("RemoteEvent") then controlSpoofRemote = remote; return remote end
  controlSpoofRemote = nil; return nil
end
applyReplicationControlSpoof = function(modeOverride, forceSend)
  local mode = normalizeControlModeName(modeOverride or getSelectedControlMode())
  local remote = getSetControlsRemote(); if not remote then return false end
  if not forceSend and lastControlSpoofMode == mode and (tick() - (lastControlSpoofAt or 0)) < 0.35 then return true end
  local ok = pcall(function() remote:FireServer(mode) end)
  if ok then lastControlSpoofMode = mode; lastControlSpoofAt = tick() end
  return ok
end
restoreSoftSpoof = function()
  STATE.SoftMobileSpoof, STATE.SoftConsoleSpoof, STATE.SoftVRSpoof = false, false, false
  if getgenv then local gv = getgenv(); gv.NX_DEVICE_MOBILE=nil; gv.NX_DEVICE_CONSOLE=nil; gv.NX_DEVICE_VR=nil end
  applyReplicationControlSpoof("MouseKeyboard", true)
end
applySoftSpoof = function()
  if not STATE.MobileSpoof and not STATE.ConsoleSpoof and not STATE.VRSpoof then restoreSoftSpoof(); return true end
  if getgenv then local gv = getgenv(); gv.NX_DEVICE_MOBILE=STATE.MobileSpoof; gv.NX_DEVICE_CONSOLE=STATE.ConsoleSpoof; gv.NX_DEVICE_VR=STATE.VRSpoof end
  return applyReplicationControlSpoof(nil, true)
end
restoreDeviceSpoof = function() restoreSoftSpoof() end
applyDeviceSpoof = function() return applySoftSpoof() end
function setupControlModeSpoof()
  task.spawn(function() while RUNNING do if STATE.MobileSpoof or STATE.ConsoleSpoof or STATE.VRSpoof then applyDeviceSpoof() end; task.wait(1) end end)
end

local FOV_COLOR_PRESETS = {
  White = Color3.fromRGB(235, 245, 255),
  Blue = Color3.fromRGB(84, 146, 255),
  Cyan = Color3.fromRGB(70, 225, 255),
  Green = Color3.fromRGB(80, 255, 145),
  Yellow = Color3.fromRGB(255, 220, 80),
  Red = Color3.fromRGB(255, 70, 70),
  Pink = Color3.fromRGB(255, 95, 190),
}

function getFOVColor()
  return FOV_COLOR_PRESETS[tostring(STATE.AimFOVColor or "White")] or FOV_COLOR_PRESETS.White
end

local fovGui, fovFrame, fovStroke = nil, nil, nil
local function getFOVGuiParent()
  if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
      return hui
    end
  end
  local okCore, coreGui = pcall(function()
    return game:GetService("CoreGui")
  end)
  if okCore and coreGui then
    return coreGui
  end
  local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
  return playerGui
end
local function ensureFOVGui()
  if fovFrame and fovFrame.Parent and fovStroke then
    return true
  end
  local parent = getFOVGuiParent()
  if not parent then
    return false
  end
  
  fovGui = Instance.new("ScreenGui")
  fovGui.Name = "NX_FOV_UI"
  fovGui.ResetOnSpawn = false
  fovGui.IgnoreGuiInset = true
  fovGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  fovGui.DisplayOrder = 5
  local okParent = pcall(function()
    fovGui.Parent = parent
  end)
  if (not okParent or not fovGui.Parent) and LocalPlayer then
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
      pcall(function()
        fovGui.Parent = playerGui
      end)
    end
  end
  if not fovGui.Parent then
    return false
  end
  
  fovFrame = Instance.new("Frame")
  fovFrame.Name = "Circle"
  fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
  fovFrame.BackgroundTransparency = 1
  fovFrame.BorderSizePixel = 0
  fovFrame.ZIndex = 1
  fovFrame.Visible = false
  fovFrame.Parent = fovGui
  
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(1, 0)
  corner.Parent = fovFrame
  
  fovStroke = Instance.new("UIStroke")
  fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  fovStroke.Thickness = 2
  fovStroke.Transparency = 0
  fovStroke.Parent = fovFrame
  
  if getgenv then
    getgenv().NX_FOV_GUI = fovGui
  end
  return true
end
updateFOV = function()
  if not Camera then return end
  pcall(function()
    local visible = STATE.AimFOVCircle == true and STATE.AimFOVHidden ~= true
    local radius = safeNum(STATE.AimFOV)
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local color = getFOVColor()
    
    if ensureFOVGui() then
      fovFrame.Visible = visible
      if visible then
        fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
        fovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        fovStroke.Color = color
      end
    end
  end)
end

local lightingDefaults = {
  Brightness = Lighting.Brightness,
  Ambient = Lighting.Ambient,
  OutdoorAmbient = Lighting.OutdoorAmbient,
  FogEnd = Lighting.FogEnd,
  GlobalShadows = Lighting.GlobalShadows,
}
local terrainDefaults = nil

setFB = function(enabled)
  pcall(function()
    if enabled then
      Lighting.Brightness = 2.5
      Lighting.Ambient = Color3.new(1, 1, 1)
      Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
      Lighting.Brightness = lightingDefaults.Brightness
      Lighting.Ambient = lightingDefaults.Ambient
      Lighting.OutdoorAmbient = lightingDefaults.OutdoorAmbient
    end
  end)
end

setNF = function(enabled)
  pcall(function()
    Lighting.FogEnd = enabled and 1e9 or lightingDefaults.FogEnd
  end)
end

setFPS = function(enabled)
  if typeof(setfpscap) == "function" then
    pcall(setfpscap, enabled and 240 or 60)
  end
end

setFPSBoost = function(enabled)
  pcall(function()
    Lighting.GlobalShadows = not enabled and lightingDefaults.GlobalShadows or false
    if settings and settings().Rendering then
      settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
      if not terrainDefaults then
        terrainDefaults = {
          WaterWaveSize = terrain.WaterWaveSize,
          WaterWaveSpeed = terrain.WaterWaveSpeed,
          WaterReflectance = terrain.WaterReflectance,
          WaterTransparency = terrain.WaterTransparency,
        }
      end
      terrain.WaterWaveSize = enabled and 0 or terrainDefaults.WaterWaveSize
      terrain.WaterWaveSpeed = enabled and 0 or terrainDefaults.WaterWaveSpeed
      terrain.WaterReflectance = enabled and 0 or terrainDefaults.WaterReflectance
      terrain.WaterTransparency = enabled and 1 or terrainDefaults.WaterTransparency
    end
  end)
end

local silentAimShotBusy = false
local silentAimCachedTarget = nil
local silentAimCachedAt = 0

local function isSilentAimTargetAlive(targetPart)
  if not targetPart or not targetPart.Parent then
    return false
  end
  local player = Players:GetPlayerFromCharacter(targetPart.Parent)
  if not player or not isAlive(player) then
    return false
  end
  local hum = targetPart.Parent:FindFirstChildOfClass("Humanoid")
  return hum ~= nil and hum.Health > 0
end

local function isSilentAimTargetInFOV(targetPart)
  if STATE.SilentAimFOVOnly ~= true then
    return true, 0
  end
  if not targetPart or not Camera then
    return false, huge
  end

  local sp, onScreen = worldToScreen(targetPart.Position)
  if not onScreen then
    return false, huge
  end

  local center = getAimScreenCenter()
  local distance2d = (sp - center).Magnitude
  return distance2d <= safeNum(STATE.AimFOV), distance2d
end

local function isSilentAimTargetVisible(targetPart)
  if not targetPart or not targetPart.Parent then
    return false
  end
  return isVisibleCached(targetPart) == true
end

local function getSilentAimTarget(requireVisible)
  local myRoot = getRoot()
  if not myRoot then
    return nil
  end

  local now = tick()
  if silentAimCachedTarget and now - silentAimCachedAt <= 0.08 and isSilentAimTargetAlive(silentAimCachedTarget) then
    local cachedPlayer = Players:GetPlayerFromCharacter(silentAimCachedTarget.Parent)
    local cachedInFOV = isSilentAimTargetInFOV(silentAimCachedTarget)
    local cachedVisible = (not requireVisible) or isSilentAimTargetVisible(silentAimCachedTarget)
    if cachedPlayer and isEnemy(cachedPlayer, STATE.AimTeamCheck) and cachedInFOV and cachedVisible then
      return silentAimCachedTarget
    end
  end

  updateCache()

  local bestTarget, bestScore = nil, huge
  for _, player in ipairs(cachedPlayers) do
    if player ~= LocalPlayer and isAlive(player) and isEnemy(player, STATE.AimTeamCheck) then
      local targetPart = getPreferredPartFromPlayer(player, "Head") or getPlayerRoot(player)
      if targetPart and isSilentAimTargetAlive(targetPart) then
        local inFOV, screenDistance = isSilentAimTargetInFOV(targetPart)
        local visibleOk = (not requireVisible) or isSilentAimTargetVisible(targetPart)
        if inFOV and visibleOk then
          local worldDistance = (myRoot.Position - targetPart.Position).Magnitude
          local score = STATE.SilentAimFOVOnly == true and screenDistance or worldDistance
          if score < bestScore then
            bestTarget, bestScore = targetPart, score
          end
        end
      end
    end
  end

  silentAimCachedTarget = bestTarget
  silentAimCachedAt = now
  return bestTarget
end

local function fireSilentAimTool()
  local fired = false
  local tool = getTool()
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
    fired = click(MIN_SHOT_INTERVAL)
  end

  return fired
end

local function silentAimShot(requireVisible)
  if silentAimShotBusy or not STATE.SilentAim then
    return false
  end
  if not isRoundStarted() then
    silentAimCachedTarget = nil
    silentAimCachedAt = 0
    return false
  end

  silentAimShotBusy = true
  local target = getSilentAimTarget(requireVisible)
  if not target or not isSilentAimTargetAlive(target) or not Camera then
    silentAimShotBusy = false
    return false
  end
  if requireVisible and not isSilentAimTargetVisible(target) then
    silentAimShotBusy = false
    return false
  end

  local oldCF = Camera.CFrame
  local ok = pcall(function()
    Camera.CFrame = CFrame.new(oldCF.Position, target.Position)
    task.wait(0.005)
    local stillInFOV = isSilentAimTargetInFOV(target)
    local visibleOk = (not requireVisible) or isSilentAimTargetVisible(target)
    if STATE.SilentAim and isRoundStarted() and isSilentAimTargetAlive(target) and stillInFOV and visibleOk then
      fireSilentAimTool()
    end
    task.wait(0.005)
  end)
  pcall(function()
    if Camera then
      Camera.CFrame = oldCF
    end
  end)
  silentAimShotBusy = false
  return ok
end

setupGrabber = function()
  local nextSilentAutoShotAt = 0
  addConnection("silent_aim_click", UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
      return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      task.spawn(silentAimShot)
    end
  end))
  task.spawn(function()
    while RUNNING do
      if STATE.SilentAim and STATE.SilentAimAutoShoot and isRoundStarted() then
        local now = tick()
        if now >= nextSilentAutoShotAt then
          local cps = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(STATE.SilentAimAutoShootCPS)))
          local interval = 1 / cps
          local fired = silentAimShot(true)
          nextSilentAutoShotAt = tick() + (fired and interval or 0.035)
        end
        task.wait(0.01)
      else
        nextSilentAutoShotAt = 0
        task.wait(0.05)
      end
    end
  end)
  return true
end

do
local espObjs, espHighlights, espState, espPlayerConnections = {}, {}, {}, {}
local drawingReady = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"
local ESP_SKELETON_KEYS = {"S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10", "S11", "S12", "S13", "S14"}
local ESP_BASE_DRAW_KEYS = {"Name", "Health", "Distance", "L1", "L2", "L3", "L4", "HPBG", "HP"}
local ESP_DRAW_KEYS = {}
for _, key in ipairs(ESP_BASE_DRAW_KEYS) do
  table.insert(ESP_DRAW_KEYS, key)
end
for _, key in ipairs(ESP_SKELETON_KEYS) do
  table.insert(ESP_DRAW_KEYS, key)
end
local ESP_TEXT_KEYS = {"Name", "Health", "Distance"}
local ESP_BOX_KEYS = {"L1", "L2", "L3", "L4"}
local ESP_DRAW_TYPES = {
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
local ESP_MIN_INTERVAL = 1 / 24
local ESP_BUSY_INTERVAL = 1 / 10
local ESP_HEAVY_INTERVAL = 1 / 8
local ESP_CRITICAL_INTERVAL = 1 / 6
local ESP_ENEMY_COLOR = Color3.fromRGB(255, 50, 50)
local ESP_TEAM_COLOR = Color3.fromRGB(0, 145, 255)
local ESP_TEXT_COLOR = Color3.fromRGB(215, 220, 230)
local ESP_HP_BG_COLOR = Color3.fromRGB(20, 20, 20)
local ESP_OUTLINE_COLOR = Color3.new(1, 1, 1)
local ESP_HEALTH_COLORS = {}
local function clearESPTable(tbl)
  if table.clear then
    table.clear(tbl)
    return
  end
  for k in pairs(tbl) do
    tbl[k] = nil
  end
end
function getHealthColor(ratio)
  local percent = math.clamp(math.floor(((tonumber(ratio) or 0) * 100) + 0.5), 0, 100)
  local color = ESP_HEALTH_COLORS[percent]
  if not color then
    local normalized = percent / 100
    color = Color3.fromRGB(math.floor(255 * (1 - normalized)), math.floor(255 * normalized), 45)
    ESP_HEALTH_COLORS[percent] = color
  end
  return color, percent
end
function hideESP(esp, player)
  if not esp then
    return
  end
  local meta = player and espState[player]
  if meta and meta.hidden then
    return
  end
  for _, key in ipairs(ESP_DRAW_KEYS) do
    local obj = esp[key]
    if obj then
      pcall(function()
        if obj.Visible then
          obj.Visible = false
        end
      end)
    end
  end
  if meta then
    meta.hidden = true
    meta.boxVisible = false
    meta.nameVisible = false
    meta.healthVisible = false
    meta.distanceVisible = false
    meta.healthBarVisible = false
    meta.skeletonVisible = false
  end
end
function setHighlightEnabled(player, enabled)
  local hl = espHighlights[player]
  if not hl then
    return
  end
  if not hl.Parent then
    espHighlights[player] = nil
    return
  end
  local shouldEnable = enabled == true
  local meta = player and espState[player]
  pcall(function()
    if hl.Enabled ~= shouldEnable then
      hl.Enabled = shouldEnable
    end
  end)
  if meta then
    meta.hlEnabled = shouldEnable
  end
end
local function clearESPHighlights()
  for player, hl in pairs(espHighlights) do
    if hl then
      pcall(function() hl:Destroy() end)
    end
    espHighlights[player] = nil
    local meta = espState[player]
    if meta then
      meta.hlEnabled = false
      meta.hlChar = nil
    end
  end
end
local function invalidateESPCharacterCache(player, destroyHighlight)
  if not player then
    return
  end
  local meta = espState[player] or {}
  espState[player] = meta
  meta.char = nil
  meta.root = nil
  meta.head = nil
  meta.hum = nil
  meta.skeletonChar = nil
  meta.skeletonPairs = nil
  meta.skeletonScannedAt = 0
  meta.hlChar = nil
  if destroyHighlight and espHighlights[player] then
    pcall(function() espHighlights[player]:Destroy() end)
    espHighlights[player] = nil
    meta.hlEnabled = false
  end
end
local function getESPCharacterData(player)
  if not player or player == LocalPlayer then
    return nil
  end
  local char = player.Character
  if not char then
    return nil
  end
  local meta = espState[player] or {}
  espState[player] = meta
  local needsScan = meta.char ~= char
    or not meta.root
    or not meta.root.Parent
    or not meta.hum
    or not meta.hum.Parent
  if needsScan then
    meta.char = char
    meta.root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    meta.head = char:FindFirstChild("Head") or meta.root
    meta.hum = char:FindFirstChildOfClass("Humanoid")
    meta.skeletonChar = nil
    meta.skeletonPairs = nil
    meta.skeletonScannedAt = 0
  elseif not meta.head or not meta.head.Parent then
    meta.head = char:FindFirstChild("Head") or meta.root
  end
  if not meta.root or not meta.hum then
    return nil
  end
  return char, meta.root, meta.hum, meta.head, meta
end
function cleanESP(player)
  if espPlayerConnections[player] then
    for _, conn in pairs(espPlayerConnections[player]) do
      pcall(function() conn:Disconnect() end)
    end
    espPlayerConnections[player] = nil
  end
  if espObjs[player] then for _, key in ipairs(ESP_DRAW_KEYS) do local obj = espObjs[player][key]; if obj then pcall(function() obj:Remove() end) end end; espObjs[player]=nil end
  if espHighlights[player] then pcall(function() espHighlights[player]:Destroy() end); espHighlights[player]=nil end
  espState[player] = nil
end

local function configureESPObject(key, obj)
  if not obj then return end
  pcall(function()
    obj.Visible = false
    if obj.Thickness ~= nil then
      obj.Thickness = (key == "HPBG" or key == "HP") and 3 or (string.sub(key, 1, 1) == "S" and 1 or 2)
    end
    if key == "HPBG" and obj.Color ~= nil then
      obj.Color = ESP_HP_BG_COLOR
    end
    if key == "Name" or key == "Health" or key == "Distance" then
      obj.Center = true
      obj.Outline = true
      obj.Font = 2
      obj.Size = (key == "Name") and 13 or 11
    end
  end)
end

local function ensureESPDrawing(esp, key)
  if not drawingReady or not esp then
    return nil
  end
  if esp[key] then
    return esp[key]
  end
  local drawType = ESP_DRAW_TYPES[key]
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
  configureESPObject(key, obj)
  esp[key] = obj
  return obj
end

cleanAllESP = function()
  local seen = {}
  for p in pairs(espObjs) do seen[p] = true end
  for p in pairs(espHighlights) do seen[p] = true end
  for p in pairs(espPlayerConnections) do seen[p] = true end
  for p in pairs(seen) do cleanESP(p) end
  espObjs, espHighlights, espState, espPlayerConnections = {}, {}, {}, {}
end
function createESPHighlight(player, char)
  if not player or player == LocalPlayer or not char then
    return nil
  end
  local hl = espHighlights[player]
  if hl and hl.Parent == char then
    return hl
  end
  if hl then
    pcall(function() hl:Destroy() end)
    espHighlights[player] = nil
  end
  
  local ok, newHl = pcall(function()
    local created = Instance.new("Highlight")
    created.Name = "NX_ESP_HL"
    created.Archivable = false
    created.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    created.OutlineTransparency = 0
    created.FillTransparency = 0.72
    created.FillColor = ESP_ENEMY_COLOR
    created.OutlineColor = ESP_OUTLINE_COLOR
    created.Adornee = char
    created.Enabled = false
    created.Parent = char
    return created
  end)
  
  if ok and newHl then
    espHighlights[player] = newHl
    return newHl
  end
  return nil
end
function trackESPPlayer(player)
  if not player or player == LocalPlayer or espPlayerConnections[player] then
    return
  end
  espPlayerConnections[player] = {
    character = player.CharacterAdded:Connect(function()
      hideESP(espObjs[player], player)
      invalidateESPCharacterCache(player, true)
    end)
  }
  invalidateESPCharacterCache(player, false)
end
addConnection("esp_add", Players.PlayerAdded:Connect(trackESPPlayer))
addConnection("esp_remove", Players.PlayerRemoving:Connect(cleanESP))
for _, player in ipairs(Players:GetPlayers()) do
  trackESPPlayer(player)
end
function ensureHL(player, char, enemy, enabled)
  if not player or not char then
    return nil
  end
  if enabled ~= true then
    local meta = espState[player]
    local hl = espHighlights[player]
    if hl and hl.Parent then
      pcall(function()
        if hl.Enabled then
          hl.Enabled = false
        end
      end)
    end
    if meta then
      meta.hlEnabled = false
    end
    return hl
  end
  local hl = espHighlights[player]
  if not hl or not hl.Parent or hl.Parent ~= char then
    hl = createESPHighlight(player, char)
  end
  if not hl then
    return nil
  end
  local fillColor = enemy and ESP_ENEMY_COLOR or ESP_TEAM_COLOR
  local shouldEnable = enabled == true
  local meta = espState[player] or {}
  espState[player] = meta
  if meta.hlChar == char and meta.hlEnemy == enemy and meta.hlEnabled == shouldEnable then
    return hl
  end
  pcall(function()
    if hl.Adornee ~= char then hl.Adornee = char end
    if hl.FillColor ~= fillColor then hl.FillColor = fillColor end
    if hl.OutlineColor ~= ESP_OUTLINE_COLOR then hl.OutlineColor = ESP_OUTLINE_COLOR end
    if hl.Enabled ~= shouldEnable then hl.Enabled = shouldEnable end
  end)
  meta.hlChar = char
  meta.hlEnemy = enemy
  meta.hlEnabled = shouldEnable
  return hl
end
function createESP(player)
  if not drawingReady then return nil end
  if espObjs[player] then return espObjs[player] end
  local esp = {}
  espObjs[player]=esp
  espState[player] = espState[player] or {hidden = true}
  return esp
end
function ensureSkeletonLines(esp)
  if not drawingReady or not esp then
    return false
  end
  if esp._skeletonReady then
    return true
  end
  if esp._skeletonFailedAt and tick() - esp._skeletonFailedAt < 1 then
    return false
  end
  local ok = pcall(function()
    for _, key in ipairs(ESP_SKELETON_KEYS) do
      if not esp[key] then
        local line = Drawing.new("Line")
        configureESPObject(key, line)
        esp[key] = line
      end
    end
  end)
  if not ok then
    for _, key in ipairs(ESP_SKELETON_KEYS) do
      local obj = esp[key]
      if obj then
        pcall(function() obj:Remove() end)
      end
      esp[key] = nil
    end
    esp._skeletonFailedAt = tick()
    return false
  end
  esp._skeletonReady = true
  return true
end
function screenBounds(char, root, widthFactor, head)
  if not char or not root or not root.Parent or not Camera then
    return nil
  end
  head = (head and head.Parent and head) or root
  local headPos, headOn = Camera:WorldToViewportPoint(head.Position + V3(0, 0.55, 0))
  local rootPos, rootOn = Camera:WorldToViewportPoint(root.Position - V3(0, 2.6, 0))
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
  local bottomY = topY + height
  
  return centerX - halfW, topY, centerX + halfW, bottomY
end
function setBox(esp,x1,y1,x2,y2,color)
  local l1 = ensureESPDrawing(esp, "L1")
  local l2 = ensureESPDrawing(esp, "L2")
  local l3 = ensureESPDrawing(esp, "L3")
  local l4 = ensureESPDrawing(esp, "L4")
  if not l1 or not l2 or not l3 or not l4 then
    return false
  end
  l1.From,l1.To=Vector2.new(x1,y1),Vector2.new(x2,y1); l2.From,l2.To=Vector2.new(x2,y1),Vector2.new(x2,y2); l3.From,l3.To=Vector2.new(x2,y2),Vector2.new(x1,y2); l4.From,l4.To=Vector2.new(x1,y2),Vector2.new(x1,y1)
  for _, k in ipairs(ESP_BOX_KEYS) do
    local line = esp[k]
    if line.Color ~= color then line.Color = color end
    if not line.Visible then line.Visible = true end
  end
  return true
end
function hideBox(esp)
  for _, k in ipairs(ESP_BOX_KEYS) do
    local line = esp[k]
    if line and line.Visible then
      line.Visible = false
    end
  end
end
function hideSkeleton(esp)
  if not esp then return end
  for _, key in ipairs(ESP_SKELETON_KEYS) do
    local line = esp[key]
    if line and line.Visible then
      line.Visible = false
    end
  end
end

local ESP_SKELETON_BONES = {
  {{"Head"}, {"UpperTorso", "Torso", "HumanoidRootPart"}},
  {{"UpperTorso", "Torso"}, {"LowerTorso", "HumanoidRootPart"}},
  {{"UpperTorso", "Torso"}, {"LeftUpperArm", "Left Arm"}},
  {{"LeftUpperArm", "Left Arm"}, {"LeftLowerArm", "LeftHand", "Left Arm"}},
  {{"LeftLowerArm", "Left Arm"}, {"LeftHand", "Left Arm"}},
  {{"UpperTorso", "Torso"}, {"RightUpperArm", "Right Arm"}},
  {{"RightUpperArm", "Right Arm"}, {"RightLowerArm", "RightHand", "Right Arm"}},
  {{"RightLowerArm", "Right Arm"}, {"RightHand", "Right Arm"}},
  {{"LowerTorso", "Torso", "HumanoidRootPart"}, {"LeftUpperLeg", "Left Leg"}},
  {{"LeftUpperLeg", "Left Leg"}, {"LeftLowerLeg", "LeftFoot", "Left Leg"}},
  {{"LeftLowerLeg", "Left Leg"}, {"LeftFoot", "Left Leg"}},
  {{"LowerTorso", "Torso", "HumanoidRootPart"}, {"RightUpperLeg", "Right Leg"}},
  {{"RightUpperLeg", "Right Leg"}, {"RightLowerLeg", "RightFoot", "Right Leg"}},
  {{"RightLowerLeg", "Right Leg"}, {"RightFoot", "Right Leg"}},
}

local function findCharacterPart(char, names)
  if not char then return nil end
  for _, name in ipairs(names) do
    local part = char:FindFirstChild(name)
    if part and part:IsA("BasePart") then
      return part
    end
  end
  return nil
end

local function getSkeletonPairs(meta, char)
  if not meta or not char then
    return nil
  end
  local now = tick()
  if meta.skeletonChar == char and meta.skeletonPairs and now - (meta.skeletonScannedAt or 0) < 1.25 then
    return meta.skeletonPairs
  end
  local skeletonPairs = meta.skeletonPairs or {}
  clearESPTable(skeletonPairs)
  for index, bone in ipairs(ESP_SKELETON_BONES) do
    skeletonPairs[index] = {
      findCharacterPart(char, bone[1]),
      findCharacterPart(char, bone[2]),
    }
  end
  meta.skeletonChar = char
  meta.skeletonPairs = skeletonPairs
  meta.skeletonScannedAt = now
  return skeletonPairs
end

local function espWorldToScreen(pos)
  if not Camera or not pos then
    return Vector2.new(0, 0), false
  end
  local sp, onScreen = Camera:WorldToViewportPoint(pos)
  return Vector2.new(sp.X, sp.Y), onScreen
end

function setSkeleton(esp, char, color, meta)
  if not ensureSkeletonLines(esp) then
    return
  end
  local skeletonPairs = getSkeletonPairs(meta, char)
  if not skeletonPairs then
    hideSkeleton(esp)
    return
  end
  local used = 0
  for index = 1, #ESP_SKELETON_KEYS do
    local line = esp[ESP_SKELETON_KEYS[index]]
    local pair = skeletonPairs[index]
    local partA = pair and pair[1]
    local partB = pair and pair[2]
    if line and partA and partB and partA ~= partB then
      local a, aOn = espWorldToScreen(partA.Position)
      local b, bOn = espWorldToScreen(partB.Position)
      if aOn and bOn then
        line.From = a
        line.To = b
        if line.Color ~= color then line.Color = color end
        if not line.Visible then line.Visible = true end
        used = index
      elseif line.Visible then
        line.Visible = false
      end
    elseif line and line.Visible then
      line.Visible = false
    end
  end
  for index = used + 1, #ESP_SKELETON_KEYS do
    local line = esp[ESP_SKELETON_KEYS[index]]
    if line and line.Visible then
      line.Visible = false
    end
  end
end

function updateESPPlayer(p, cameraPos, maxDist, boxWidthFactor, showEnemy, showTeam, showHighlight, showName, showHealth, showDistance, showBox, showSkeleton)
  if not p or p == LocalPlayer then
    return
  end
  local char, root, hum, head, meta = getESPCharacterData(p)
  local enemy = isEnemy(p, true)
  local show = char and ((enemy and showEnemy) or ((not enemy) and showTeam))
  if not show then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end
  
  if not root or not hum or hum.Health <= 0 then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end
  
  local delta = cameraPos - root.Position
  local distSq = delta:Dot(delta)
  if maxDist > 0 and distSq > (maxDist * maxDist) then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end
  
  local wantsDrawing = showName or showHealth or showDistance or showBox or showSkeleton
  local x1, y1, x2, y2 = nil, nil, nil, nil
  if drawingReady and wantsDrawing then
    x1, y1, x2, y2 = screenBounds(char, root, boxWidthFactor, head)
    if not x1 then
      hideESP(espObjs[p], p)
      setHighlightEnabled(p, false)
      return
    end
  elseif not wantsDrawing then
    hideESP(espObjs[p], p)
  end
  
  ensureHL(p, char, enemy, showHighlight == true)
  if not drawingReady or not wantsDrawing then
    return
  end
  
  local esp = createESP(p)
  if not esp then
    return
  end
  
  meta.hidden = false
  local color = enemy and ESP_ENEMY_COLOR or ESP_TEAM_COLOR
  
  if showBox then
    meta.boxVisible = setBox(esp, x1, y1, x2, y2, color) == true
  elseif meta.boxVisible ~= false then
    hideBox(esp)
    meta.boxVisible = false
  end
  
  if showSkeleton then
    setSkeleton(esp, char, color, meta)
    meta.skeletonVisible = true
  elseif meta.skeletonVisible ~= false then
    hideSkeleton(esp)
    meta.skeletonVisible = false
  end
  
  if showName then
    local nameObj = ensureESPDrawing(esp, "Name")
    if not nameObj then return end
    local nameText = tostring(p.DisplayName or p.Name)
    if meta.nameText ~= nameText then
      nameObj.Text = nameText
      meta.nameText = nameText
    end
    nameObj.Position = Vector2.new((x1 + x2) * 0.5, y1 - 16)
    if meta.nameColor ~= color then
      nameObj.Color = color
      meta.nameColor = color
    end
    if meta.nameVisible ~= true then
      nameObj.Visible = true
      meta.nameVisible = true
    end
  elseif meta.nameVisible ~= false and esp.Name then
    esp.Name.Visible = false
    meta.nameVisible = false
  end
  
  local ratio = 0
  local hpColor = ESP_TEXT_COLOR
  if showHealth then
    local healthObj = ensureESPDrawing(esp, "Health")
    local hpBg = ensureESPDrawing(esp, "HPBG")
    local hp = ensureESPDrawing(esp, "HP")
    if not healthObj or not hpBg or not hp then return end
    ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    hpColor = getHealthColor(ratio)
    local healthValue = math.clamp(math.floor((tonumber(hum.Health) or 0) + 0.5), 0, 150)
    local healthText = tostring(healthValue)
    if meta.healthText ~= healthText then
      healthObj.Text = healthText
      meta.healthText = healthText
    end
    healthObj.Position = Vector2.new((x1 + x2) * 0.5, y1 - 4)
    if meta.healthColor ~= hpColor then
      healthObj.Color = hpColor
      hp.Color = hpColor
      meta.healthColor = hpColor
    end
    if meta.healthVisible ~= true then
      healthObj.Visible = true
      meta.healthVisible = true
    end
    
    hpBg.From = Vector2.new(x1 - 6, y1)
    hpBg.To = Vector2.new(x1 - 6, y2)
    hp.From = Vector2.new(x1 - 6, y2)
    hp.To = Vector2.new(x1 - 6, y2 - ((y2 - y1) * ratio))
    if meta.healthBarVisible ~= true then
      hpBg.Visible = true
      hp.Visible = true
      meta.healthBarVisible = true
    end
  else
    if meta.healthVisible ~= false and esp.Health then
      esp.Health.Visible = false
      meta.healthVisible = false
    end
    if meta.healthBarVisible ~= false and (esp.HPBG or esp.HP) then
      if esp.HPBG then esp.HPBG.Visible = false end
      if esp.HP then esp.HP.Visible = false end
      meta.healthBarVisible = false
    end
  end
  
  if showDistance then
    local distanceObj = ensureESPDrawing(esp, "Distance")
    if not distanceObj then return end
    local dist = math.sqrt(distSq)
    local distanceText = tostring(math.floor(dist + 0.5)) .. "m"
    if meta.distanceText ~= distanceText then
      distanceObj.Text = distanceText
      meta.distanceText = distanceText
    end
    distanceObj.Position = Vector2.new((x1 + x2) * 0.5, y2 + 3)
    if meta.distanceColor ~= ESP_TEXT_COLOR then
      distanceObj.Color = ESP_TEXT_COLOR
      meta.distanceColor = ESP_TEXT_COLOR
    end
    if meta.distanceVisible ~= true then
      distanceObj.Visible = true
      meta.distanceVisible = true
    end
  elseif meta.distanceVisible ~= false and esp.Distance then
    esp.Distance.Visible = false
    meta.distanceVisible = false
  end
end

function updateESPBoxOnly(p, cameraPos, maxDist, boxWidthFactor, showEnemy, showTeam, showBox)
  if not drawingReady or not showBox or not p or p == LocalPlayer then
    return
  end

  local char, root, hum, head = getESPCharacterData(p)
  local enemy = isEnemy(p, true)
  local show = char and ((enemy and showEnemy) or ((not enemy) and showTeam))
  if not show then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  if not root or not hum or hum.Health <= 0 then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  local delta = cameraPos - root.Position
  local distSq = delta:Dot(delta)
  if maxDist > 0 and distSq > (maxDist * maxDist) then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  local x1, y1, x2, y2 = screenBounds(char, root, boxWidthFactor, head)
  if not x1 then
    local esp = espObjs[p]
    if esp then
      hideBox(esp)
    end
    return
  end

  local esp = createESP(p)
  if not esp then
    return
  end

  local meta = espState[p] or {}
  espState[p] = meta
  meta.hidden = false
  meta.boxVisible = setBox(esp, x1, y1, x2, y2, enemy and ESP_ENEMY_COLOR or ESP_TEAM_COLOR) == true
end

setupESP = function()
  local last=0
  local wasEnabled=false
  local cursor=1
  local activeESPPlayers={}
  local activeESPSet={}
  local lastActiveScan=0
  local noTargetsHidden=false
  local highlightWasEnabled=false
  local function clearReusableTable(tbl)
    if table.clear then
      table.clear(tbl)
      return
    end
    for k in pairs(tbl) do
      tbl[k] = nil
    end
  end
  local espSignal = RunService.RenderStepped or RunService.Heartbeat
  addConnection("esp", espSignal:Connect(function()
    if not RUNNING or not Camera then return end
    local now = tick()
    if not STATE.ESPEnabled then
      if wasEnabled then
        for p, esp in pairs(espObjs) do
          hideESP(esp, p)
        end
        for p in pairs(espHighlights) do
          setHighlightEnabled(p, false)
        end
        clearESPHighlights()
        wasEnabled = false
        highlightWasEnabled = false
        cursor = 1
        noTargetsHidden = false
        clearReusableTable(activeESPPlayers)
        clearReusableTable(activeESPSet)
        lastActiveScan = 0
      end
      return
    end
    
    local showEnemy = STATE.ESPEnemy == true
    local showTeam = STATE.ESPTeam == true
    local showHighlight = STATE.ESPHighlight == true
    local showName = STATE.ESPName == true
    local showHealth = STATE.ESPHealth == true
    local showDistance = STATE.ESPDistance == true
    local showBox = STATE.ESPBox == true
    local showSkeleton = STATE.ESPSkeleton == true
    local heavyShowSkeleton = showSkeleton and isRoundStarted()
    local cameraPos = Camera.CFrame.Position
    local maxDist = math.max(0, safeNum(STATE.ESPMaxDistance))
    local scanMaxDist = maxDist * 1.08
    local scanMaxDistSq = scanMaxDist * scanMaxDist
    wasEnabled = true
    if highlightWasEnabled ~= showHighlight then
      highlightWasEnabled = showHighlight
      if not showHighlight then
        clearESPHighlights()
      end
    end

    local currentCount = #activeESPPlayers
    local updateFps = math.clamp(safeNum(STATE.ESPUpdateFPS), 5, 24)
    local frameInterval = math.max(1 / updateFps, ESP_MIN_INTERVAL)
    if heavyShowSkeleton then
      frameInterval = math.max(frameInterval, currentCount > 16 and ESP_CRITICAL_INTERVAL or ESP_HEAVY_INTERVAL)
    elseif currentCount > 24 then
      frameInterval = math.max(frameInterval, ESP_BUSY_INTERVAL)
    end
    if now - last < frameInterval then
      return
    end
    last = now

    if not showEnemy and not showTeam then
      if not noTargetsHidden then
        for p, esp in pairs(espObjs) do
          hideESP(esp, p)
        end
        for p in pairs(espHighlights) do
          setHighlightEnabled(p, false)
        end
        if not showHighlight then
          clearESPHighlights()
        end
        noTargetsHidden = true
      end
      return
    end

    local scanInterval = #cachedPlayers > 32 and 0.45 or #cachedPlayers > 16 and 0.34 or 0.24
    if now - lastActiveScan > scanInterval then
      lastActiveScan = now
      updateCache()
      clearReusableTable(activeESPPlayers)
      clearReusableTable(activeESPSet)
      for _, p in ipairs(cachedPlayers) do
        if p and p ~= LocalPlayer then
          local char, root, hum = getESPCharacterData(p)
          if hum and hum.Health > 0 and root then
            local enemy = isEnemy(p, true)
            local delta = cameraPos - root.Position
            local distOk = maxDist <= 0 or delta:Dot(delta) <= scanMaxDistSq
            if distOk and ((enemy and showEnemy) or ((not enemy) and showTeam)) then
              activeESPPlayers[#activeESPPlayers + 1] = p
              activeESPSet[p] = true
            end
          end
        end
      end
      for p, esp in pairs(espObjs) do
        if not activeESPSet[p] then
          hideESP(esp, p)
          setHighlightEnabled(p, false)
        end
      end
      for p in pairs(espHighlights) do
        if not activeESPSet[p] then
          setHighlightEnabled(p, false)
        end
      end
    end

    local playerCount = #activeESPPlayers
    if playerCount <= 0 then
      if not noTargetsHidden then
        for p, esp in pairs(espObjs) do
          hideESP(esp, p)
        end
        for p in pairs(espHighlights) do
          setHighlightEnabled(p, false)
        end
        noTargetsHidden = true
      end
      return
    end
    noTargetsHidden = false

    local boxWidthFactor = math.clamp(safeNum(STATE.ESPBoxScale) / 100, 0.3, 0.7)
    
    local budget = playerCount
    if playerCount > 28 then
      budget = math.max(2, math.ceil(playerCount * (heavyShowSkeleton and 0.08 or 0.16)))
    elseif playerCount > 16 then
      budget = math.max(2, math.ceil(playerCount * (heavyShowSkeleton and 0.12 or 0.24)))
    elseif playerCount > 8 then
      budget = math.max(2, math.ceil(playerCount * (heavyShowSkeleton and 0.18 or 0.36)))
    end
    
    for _ = 1, budget do
      if cursor > playerCount then
        cursor = 1
      end
      local p = activeESPPlayers[cursor]
      cursor = cursor + 1
      local ok = pcall(updateESPPlayer, p, cameraPos, maxDist, boxWidthFactor, showEnemy, showTeam, showHighlight, showName, showHealth, showDistance, showBox, heavyShowSkeleton)
      if not ok and p then
        hideESP(espObjs[p], p)
        setHighlightEnabled(p, false)
      end
    end
  end))
end

local function hideAllESPRework()
  for p, esp in pairs(espObjs) do
    hideESP(esp, p)
  end
  for p in pairs(espHighlights) do
    setHighlightEnabled(p, false)
  end
end

local function updateESPPlayerRework(p, snapshot)
  if not p or p == LocalPlayer then
    return
  end

  local char, root, hum, head, meta = getESPCharacterData(p)
  if not char or not root or not hum or hum.Health <= 0 then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  local enemy = isEnemy(p, true)
  if not ((enemy and snapshot.showEnemy) or ((not enemy) and snapshot.showTeam)) then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  local delta = snapshot.cameraPos - root.Position
  local distSq = delta:Dot(delta)
  if snapshot.maxDist > 0 and distSq > snapshot.maxDistSq then
    hideESP(espObjs[p], p)
    setHighlightEnabled(p, false)
    return
  end

  ensureHL(p, char, enemy, snapshot.showHighlight == true)

  if not drawingReady or not snapshot.wantsDrawing then
    hideESP(espObjs[p], p)
    return
  end

  local x1, y1, x2, y2 = screenBounds(char, root, snapshot.boxWidthFactor, head)
  if not x1 then
    hideESP(espObjs[p], p)
    return
  end

  local esp = createESP(p)
  if not esp then
    return
  end

  meta.hidden = false
  local color = enemy and ESP_ENEMY_COLOR or ESP_TEAM_COLOR
  local centerX = (x1 + x2) * 0.5

  if snapshot.showBox then
    meta.boxVisible = setBox(esp, x1, y1, x2, y2, color) == true
  elseif meta.boxVisible ~= false then
    hideBox(esp)
    meta.boxVisible = false
  end

  if snapshot.showSkeleton and snapshot.allowSkeleton then
    if not meta.nextSkeletonAt or snapshot.now >= meta.nextSkeletonAt then
      setSkeleton(esp, char, color, meta)
      meta.nextSkeletonAt = snapshot.now + snapshot.skeletonInterval
      meta.skeletonVisible = true
    end
  elseif meta.skeletonVisible ~= false then
    hideSkeleton(esp)
    meta.skeletonVisible = false
  end

  if snapshot.showName then
    local nameObj = ensureESPDrawing(esp, "Name")
    if nameObj then
      local text = tostring(p.DisplayName or p.Name)
      if meta.nameText ~= text then
        nameObj.Text = text
        meta.nameText = text
      end
      nameObj.Position = Vector2.new(centerX, y1 - 16)
      if meta.nameColor ~= color then
        nameObj.Color = color
        meta.nameColor = color
      end
      if meta.nameVisible ~= true then
        nameObj.Visible = true
        meta.nameVisible = true
      end
    end
  elseif meta.nameVisible ~= false and esp.Name then
    esp.Name.Visible = false
    meta.nameVisible = false
  end

  if snapshot.showHealth then
    local healthObj = ensureESPDrawing(esp, "Health")
    local hpBg = ensureESPDrawing(esp, "HPBG")
    local hp = ensureESPDrawing(esp, "HP")
    if healthObj and hpBg and hp then
      local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
      local hpColor = getHealthColor(ratio)
      local healthText = tostring(math.clamp(math.floor((tonumber(hum.Health) or 0) + 0.5), 0, 150))
      if meta.healthText ~= healthText then
        healthObj.Text = healthText
        meta.healthText = healthText
      end
      healthObj.Position = Vector2.new(centerX, y1 - 4)
      if meta.healthColor ~= hpColor then
        healthObj.Color = hpColor
        hp.Color = hpColor
        meta.healthColor = hpColor
      end
      hpBg.From = Vector2.new(x1 - 6, y1)
      hpBg.To = Vector2.new(x1 - 6, y2)
      hp.From = Vector2.new(x1 - 6, y2)
      hp.To = Vector2.new(x1 - 6, y2 - ((y2 - y1) * ratio))
      if meta.healthVisible ~= true then
        healthObj.Visible = true
        meta.healthVisible = true
      end
      if meta.healthBarVisible ~= true then
        hpBg.Visible = true
        hp.Visible = true
        meta.healthBarVisible = true
      end
    end
  else
    if meta.healthVisible ~= false and esp.Health then
      esp.Health.Visible = false
      meta.healthVisible = false
    end
    if meta.healthBarVisible ~= false and (esp.HPBG or esp.HP) then
      if esp.HPBG then esp.HPBG.Visible = false end
      if esp.HP then esp.HP.Visible = false end
      meta.healthBarVisible = false
    end
  end

  if snapshot.showDistance then
    local distanceObj = ensureESPDrawing(esp, "Distance")
    if distanceObj then
      local distanceText = tostring(math.floor(math.sqrt(distSq) + 0.5)) .. "m"
      if meta.distanceText ~= distanceText then
        distanceObj.Text = distanceText
        meta.distanceText = distanceText
      end
      distanceObj.Position = Vector2.new(centerX, y2 + 3)
      if meta.distanceColor ~= ESP_TEXT_COLOR then
        distanceObj.Color = ESP_TEXT_COLOR
        meta.distanceColor = ESP_TEXT_COLOR
      end
      if meta.distanceVisible ~= true then
        distanceObj.Visible = true
        meta.distanceVisible = true
      end
    end
  elseif meta.distanceVisible ~= false and esp.Distance then
    esp.Distance.Visible = false
    meta.distanceVisible = false
  end
end

setupESP = function()
  task.spawn(function()
    local wasEnabled = false
    local cursor = 1
    local lastScan = 0
    local activePlayers = {}
    local activeSet = {}
    local function clearTable(tbl)
      if table.clear then
        table.clear(tbl)
      else
        for k in pairs(tbl) do
          tbl[k] = nil
        end
      end
    end

    while RUNNING do
      if not Camera then
        task.wait(0.2)
      elseif STATE.ESPEnabled ~= true then
        if wasEnabled then
          hideAllESPRework()
          clearESPHighlights()
          clearTable(activePlayers)
          clearTable(activeSet)
          wasEnabled = false
          cursor = 1
        end
        task.wait(0.16)
      else
        local now = tick()
        local showEnemy = STATE.ESPEnemy == true
        local showTeam = STATE.ESPTeam == true
        local showHighlight = STATE.ESPHighlight == true
        local showName = STATE.ESPName == true
        local showHealth = STATE.ESPHealth == true
        local showDistance = STATE.ESPDistance == true
        local showBox = STATE.ESPBox == true
        local showSkeleton = STATE.ESPSkeleton == true and isRoundStarted()
        local wantsDrawing = showName or showHealth or showDistance or showBox or showSkeleton
        local maxDist = math.max(0, safeNum(STATE.ESPMaxDistance))
        local maxDistSq = maxDist * maxDist
        local cameraPos = Camera.CFrame.Position
        wasEnabled = true

        if not showEnemy and not showTeam then
          hideAllESPRework()
          task.wait(0.2)
          continue
        end

        if now - lastScan >= 0.42 then
          lastScan = now
          updateCache()
          clearTable(activePlayers)
          clearTable(activeSet)
          for _, p in ipairs(cachedPlayers) do
            if p and p ~= LocalPlayer then
              local char, root, hum = getESPCharacterData(p)
              if char and root and hum and hum.Health > 0 then
                local enemy = isEnemy(p, true)
                if (enemy and showEnemy) or ((not enemy) and showTeam) then
                  local delta = cameraPos - root.Position
                  local distSq = delta:Dot(delta)
                  if maxDist <= 0 or distSq <= maxDistSq then
                    activePlayers[#activePlayers + 1] = {Player = p, DistSq = distSq}
                    activeSet[p] = true
                  end
                end
              end
            end
          end
          table.sort(activePlayers, function(a, b)
            return (a.DistSq or huge) < (b.DistSq or huge)
          end)
          local maxActive = showSkeleton and 14 or 24
          for index = #activePlayers, maxActive + 1, -1 do
            local item = activePlayers[index]
            if item then
              activeSet[item.Player] = nil
            end
            activePlayers[index] = nil
          end
          for p, esp in pairs(espObjs) do
            if not activeSet[p] then
              hideESP(esp, p)
              setHighlightEnabled(p, false)
            end
          end
          for p in pairs(espHighlights) do
            if not activeSet[p] then
              setHighlightEnabled(p, false)
            end
          end
          if cursor > #activePlayers then
            cursor = 1
          end
        end

        local total = #activePlayers
        if total <= 0 then
          task.wait(0.18)
          continue
        end

        local updateFps = math.clamp(safeNum(STATE.ESPUpdateFPS), 5, 18)
        local budget = showSkeleton and 1 or math.clamp(math.ceil(total / 5), 2, 5)
        if total <= 6 and not showSkeleton then
          budget = total
        end

        local snapshot = {
          now = now,
          cameraPos = cameraPos,
          maxDist = maxDist,
          maxDistSq = maxDistSq,
          boxWidthFactor = math.clamp(safeNum(STATE.ESPBoxScale) / 100, 0.3, 0.7),
          showEnemy = showEnemy,
          showTeam = showTeam,
          showHighlight = showHighlight,
          showName = showName,
          showHealth = showHealth,
          showDistance = showDistance,
          showBox = showBox,
          showSkeleton = showSkeleton,
          allowSkeleton = showSkeleton and total <= 14,
          skeletonInterval = total > 8 and 0.42 or 0.3,
          wantsDrawing = wantsDrawing,
        }

        for _ = 1, budget do
          if cursor > total then
            cursor = 1
          end
          local item = activePlayers[cursor]
          cursor = cursor + 1
          if item and item.Player then
            local ok = pcall(updateESPPlayerRework, item.Player, snapshot)
            if not ok then
              hideESP(espObjs[item.Player], item.Player)
              setHighlightEnabled(item.Player, false)
            end
          end
        end

        task.wait(math.max(1 / updateFps, showSkeleton and 0.09 or 0.045))
      end
    end
  end)
end
end
local speedBV, flyBV, flyBG, flyActive = nil,nil,nil,false
local noClipOriginal = {}
local noClipChar = nil
local noClipParts = {}
local noClipLastScanAt = 0
local antiHitPose = {char=nil, neck=nil, waist=nil}
local antiHitHitboxOriginal = setmetatable({}, {__mode = "k"})
local antiHitLastHitboxAt = 0
local antiHitLastHitboxChar = nil
local antiHitLastHitboxMode = nil
local antiHitLastHitboxScale = nil
local lastInfJumpAt = 0
function clearSpeed() if speedBV then pcall(function() speedBV:Destroy() end) end; speedBV=nil end
function stopFly() if flyBV then pcall(function() flyBV:Destroy() end) end; if flyBG then pcall(function() flyBG:Destroy() end) end; flyBV,flyBG,flyActive=nil,nil,false; local hum=getHumanoid(); if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end) end end
function restoreNoClip()
  for part,old in pairs(noClipOriginal) do
    if part and part.Parent then
      pcall(function() part.CanCollide=old end)
    end
  end
  noClipOriginal = {}
  noClipChar = nil
  noClipParts = {}
  noClipLastScanAt = 0
end
function refreshNoClipParts(char)
  noClipChar = char
  noClipLastScanAt = tick()
  noClipParts = {}
  if not char then return end
  for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
      noClipParts[#noClipParts + 1] = part
      if noClipOriginal[part] == nil then
        noClipOriginal[part] = part.CanCollide
      end
    end
  end
end
function applyNoClip()
  local char = getChar()
  if not char then return end
  local now = tick()
  if char ~= noClipChar or now - noClipLastScanAt > 0.35 then
    refreshNoClipParts(char)
  end
  for index = #noClipParts, 1, -1 do
    local part = noClipParts[index]
    if part and part.Parent then
      if part.CanCollide ~= false then
        part.CanCollide = false
      end
    else
      table.remove(noClipParts, index)
    end
  end
end
restoreAntiHitPose = function() pcall(function() if antiHitPose.neck and antiHitPose.neck.Parent then antiHitPose.neck.Transform=CFrame.new() end; if antiHitPose.waist and antiHitPose.waist.Parent then antiHitPose.waist.Transform=CFrame.new() end end); antiHitPose={char=nil,neck=nil,waist=nil} end
restoreAntiHitHitbox = function()
  for part, original in pairs(antiHitHitboxOriginal) do
    if part and part.Parent and original then
      pcall(function()
        part.Size = original.Size
        part.CanTouch = original.CanTouch
        part.Massless = original.Massless
      end)
    end
  end
  antiHitHitboxOriginal = setmetatable({}, {__mode = "k"})
  antiHitLastHitboxAt = 0
  antiHitLastHitboxChar = nil
  antiHitLastHitboxMode = nil
  antiHitLastHitboxScale = nil
end
local antiHitHitboxParts = {
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
function applyAntiHitHitbox()
  local mode = tostring(STATE.AntiHitHitboxMode or "Off")
  if mode == "Off" then
    restoreAntiHitHitbox()
    return
  end
  local char = getChar()
  if not char then
    restoreAntiHitHitbox()
    return
  end
  local scale = math.clamp(safeNum(STATE.AntiHitHitboxScale) / 100, 0.25, 1)
  for _, part in ipairs(char:GetChildren()) do
    if part:IsA("BasePart") and antiHitHitboxParts[part.Name] then
      local original = antiHitHitboxOriginal[part]
      if not original then
        original = {Size = part.Size, CanTouch = part.CanTouch, Massless = part.Massless}
        antiHitHitboxOriginal[part] = original
      end
      local size = original.Size
      if mode == "Compact Body" then
        size = Vector3.new(math.max(0.35, original.Size.X * scale), math.max(0.35, original.Size.Y * scale), math.max(0.35, original.Size.Z * scale))
      elseif mode == "Flat Body" then
        size = Vector3.new(math.max(0.35, original.Size.X * scale), math.max(0.25, original.Size.Y * scale * 0.45), math.max(0.35, original.Size.Z * scale))
      elseif mode == "Thin Body" then
        size = Vector3.new(math.max(0.25, original.Size.X * scale * 0.35), math.max(0.35, original.Size.Y * scale), math.max(0.25, original.Size.Z * scale * 0.35))
      end
      pcall(function()
        part.Size = size
        part.CanTouch = false
        part.Massless = true
      end)
    end
  end
end
function applyAntiHitHitboxThrottled(now)
  local mode = tostring(STATE.AntiHitHitboxMode or "Off")
  local char = getChar()
  local scale = math.clamp(safeNum(STATE.AntiHitHitboxScale), 25, 100)
  if mode == "Off" or not char then
    restoreAntiHitHitbox()
    return
  end
  now = now or tick()
  if char ~= antiHitLastHitboxChar
    or mode ~= antiHitLastHitboxMode
    or math.abs(scale - safeNum(antiHitLastHitboxScale)) >= 0.5
    or now - antiHitLastHitboxAt > 0.35
  then
    antiHitLastHitboxChar = char
    antiHitLastHitboxMode = mode
    antiHitLastHitboxScale = scale
    antiHitLastHitboxAt = now
    applyAntiHitHitbox()
  end
end
function getAntiHitJoints()
  local char=getChar(); if not char then return nil end; if antiHitPose.char==char then return antiHitPose end; restoreAntiHitPose()
  local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"); local head=char:FindFirstChild("Head"); antiHitPose={char=char,neck=nil,waist=nil}
  if head then antiHitPose.neck=head:FindFirstChild("Neck") end; if (not antiHitPose.neck) and torso then antiHitPose.neck=torso:FindFirstChild("Neck") end; if torso then antiHitPose.waist=torso:FindFirstChild("Waist") end
  return antiHitPose
end
function applyLobbyAntiHit(t,mode)
  local j=getAntiHitJoints(); if not j then return end; local yaw=math.sin(t*3.1)*1.4; local pitch=math.cos(t*2.7)*0.8; local roll=math.sin(t*3.5)*0.9
  if mode=="Head Orbit" or STATE.AntiHitExperimental then yaw=yaw+t*1.6; roll=roll+math.cos(t*5)*0.55 elseif mode=="Vector Chaos" then yaw=yaw+math.sin(t*6.2)*1.2; pitch=pitch+math.cos(t*4.9)*0.8 end
  if j.neck and j.neck:IsA("Motor6D") then j.neck.Transform=CFrame.Angles(pitch,yaw,roll) end; if j.waist and j.waist:IsA("Motor6D") then j.waist.Transform=CFrame.Angles(pitch*0.2,-yaw*0.25,0) end
end
function setupMovement()
  addConnection("move", RunService.Heartbeat:Connect(function()
    if not RUNNING then return end
    pcall(function()
      local root,hum=getRoot(),getHumanoid()
      if STATE.SpeedEnabled and root and hum and hum.MoveDirection.Magnitude>0.1 then if not speedBV or not speedBV.Parent then speedBV=Instance.new("BodyVelocity"); speedBV.MaxForce=V3(1e5,0,1e5); speedBV.Parent=root end; speedBV.Velocity=hum.MoveDirection*safeNum(STATE.SpeedValue) else clearSpeed() end
      if STATE.FlyEnabled and STATE.FlyToggle and root and hum and Camera then
        if not flyActive then flyActive=true; hum:ChangeState(Enum.HumanoidStateType.Physics); flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=MF; flyBV.Parent=root; flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=MF; flyBG.Parent=root end
        local dir=V0; if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+Camera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-Camera.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-Camera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+Camera.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+UP end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-UP end
        flyBV.Velocity=(dir.Magnitude>0 and dir.Unit or V0)*safeNum(STATE.FlySpeed); flyBG.CFrame=CF(root.Position,root.Position+Camera.CFrame.LookVector)
      else if flyActive or flyBV or flyBG then stopFly() end end
      if STATE.NoClip then applyNoClip() else restoreNoClip() end
      if STATE.AntiVoid and root then local killY=workspace.FallenPartsDestroyHeight; if typeof(killY)=="number" and root.Position.Y<=killY+35 and tick()>=(antiVoidNextAt or 0) then antiVoidNextAt=tick()+0.35; root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z); root.CFrame=CFrame.new(root.Position.X,math.max(killY+145,45),root.Position.Z) end end
      if STATE.AntiHit and root and hum and not (STATE.FlyEnabled and STATE.FlyToggle) then
        local nowTick=tick()
        local t=nowTick*math.clamp(safeNum(STATE.AntiHitSpeed),0.4,12)
        local mode=tostring(STATE.AntiHitMode or "Adaptive Jitter")
        if isRoundStarted() then
          restoreAntiHitPose()
          applyAntiHitHitboxThrottled(nowTick)
          hum.AutoRotate=false
          local yaw=t*(mode=="Orbital Drift" and 5.4 or 7.2)
          local pitch=math.sin(t*3.4)*(STATE.AntiHitExperimental and 1.4 or 0.85)
          local roll=math.cos(t*4.1)*(mode=="Vector Chaos" and 1.4 or 0.85)
          if mode=="Head Orbit" then pitch=pitch+math.pi end
          root.CFrame=CFrame.new(root.Position)*CFrame.Angles(pitch,yaw,roll)
        else
          restoreAntiHitHitbox()
          hum.AutoRotate=true
          applyLobbyAntiHit(t,mode)
        end
      else
        restoreAntiHitPose()
        restoreAntiHitHitbox()
        if hum then hum.AutoRotate=true end
      end
      if STATE.BunnyHop and hum and hum.MoveDirection.Magnitude>0 and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
  end))
end
function getInfJumpVelocity(hum)
  local configured = math.clamp(safeNum(STATE.InfJumpHeight), 28, 80)
  if hum and hum.UseJumpPower == false then
    return math.max(28, configured)
  end
  return configured
end
function performInfJump()
  if not RUNNING or not STATE.InfJump then return end
  local now = tick()
  if now - lastInfJumpAt < 0.12 then return end
  lastInfJumpAt = now
  pcall(function()
    local hum, root = getHumanoid(), getRoot()
    if not hum or hum.Health <= 0 then return end
    local jumpVelocity = getInfJumpVelocity(hum)
    hum.Jump = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    if root then
      local v = root.AssemblyLinearVelocity
      root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, jumpVelocity), v.Z)
    end
  end)
end
function setupInfJump()
  addConnection("jump_request", UserInputService.JumpRequest:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    performInfJump()
  end))
  addConnection("jump_space", UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
      performInfJump()
    end
  end))
end
backstabBusy,nextBackstabAt=false,0
function getBackstabInterval()
  local interval = math.max(0.08, safeNum(STATE.AutoBackstabInterval) / 1000)
  if STATE.AutoBackstabRandomize then
    local mn = math.max(50, math.min(safeNum(STATE.AutoBackstabRandomMin), safeNum(STATE.AutoBackstabRandomMax)))
    local mx = math.max(mn, safeNum(STATE.AutoBackstabRandomMax))
    interval = math.random(math.floor(mn), math.floor(mx)) / 1000
  end
  return interval
end
function restoreBackstabOrigin(originCF, originCameraCF)
  local myRoot = getRoot()
  if myRoot and originCF then
    pcall(function()
      myRoot.CFrame = originCF
    end)
  end
  if Camera and originCameraCF then
    pcall(function()
      Camera.CFrame = originCameraCF
    end)
  end
end
function doBackstab(targetPlayer)
  local targetRoot = getPlayerRoot(targetPlayer)
  local myRoot = getRoot()
  if not targetRoot or not myRoot then return false, 0 end
  if hasSpawnProtection(targetPlayer) then return false, 0, "protected" end
  local originCF = myRoot.CFrame
  local originCameraCF = Camera and Camera.CFrame or nil
  local hum = getPlayerHumanoid(targetPlayer)
  local startHealth = hum and hum.Health or 0
  local hit, damage = false, 0
  local ok = false
  pcall(function()
    ok = aimAtTargetBack(targetRoot)
  end)
  if ok then
    task.wait(0.025)
    rightClick()
    local deadline = tick() + 1.15
    while RUNNING and targetRoot.Parent and tick() < deadline do
      aimAtTargetBack(targetRoot)
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
      task.wait(0.03)
    end
  end
  restoreBackstabOrigin(originCF, originCameraCF)
  return hit, damage
end

function getNamesOrbitInterval()
  return math.max(0.08, safeNum(STATE.NamesOrbitInterval) / 1000)
end

function doNamesOrbitShot(targetPlayer)
  local targetRoot = getPlayerRoot(targetPlayer)
  local myRoot = getRoot()
  if not targetRoot or not myRoot then return false, "missing_root" end
  if hasSpawnProtection(targetPlayer) then return false, "protected" end

  local head = getPreferredPartFromPlayer(targetPlayer, "Head") or targetRoot
  if not head or not head.Parent then return false, "missing_head" end

  local originCF = myRoot.CFrame
  local originCameraCF = Camera and Camera.CFrame or nil
  local ok = false

  pcall(function()
    local face = targetRoot.CFrame.LookVector
    local insidePos = targetRoot.Position + (face * 0.35) + Vector3.new(0, 0.35, 0)
    myRoot.CFrame = CFrame.new(insidePos, head.Position)
    if Camera then
      Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
    end
    rightClick()
    task.wait(0.018)
    ok = click(0.04) == true
    task.wait(0.035)
  end)

  restoreBackstabOrigin(originCF, originCameraCF)
  return ok, ok and "shot" or "no_click"
end

function setupNamesOrbit()
  task.spawn(function()
    while RUNNING do
      if STATE.NamesOrbit and isRoundStarted() and not namesOrbitBusy and tick() >= nextNamesOrbitAt then
        local target = getBackstabTargetPlayer()
        if target then
          namesOrbitBusy = true
          if hasSpawnProtection(target) then
            waitForSpawnProtectionGone(target, 4, false)
          end
          doNamesOrbitShot(target)
          nextNamesOrbitAt = tick() + getNamesOrbitInterval()
          namesOrbitBusy = false
        end
      end
      task.wait(0.025)
    end
  end)
end

function setupAutoBackstab()
  task.spawn(function()
    while RUNNING do
      if STATE.AutoBackstab and isRoundStarted() and not backstabBusy and tick() >= nextBackstabAt then
        local target = getBackstabTargetPlayer()
        if target then
          if hasSpawnProtection(target) then
            waitForSpawnProtectionGone(target, 6, true)
          else
            backstabBusy = true
            doBackstab(target)
            nextBackstabAt = tick() + getBackstabInterval()
            backstabBusy = false
          end
        end
      end
      task.wait(0.04)
    end
  end)
end
function backstabOnce()
  if not isRoundStarted() then
    notify("Backstab", "Warte bis die Runde gestartet ist", 2)
    return
  end
  local target = getBackstabTargetPlayer()
  if not target then
    notify("Backstab", "Kein gueltiges Ziel", 2)
    return
  end
  task.spawn(function()
    if waitForSpawnProtectionGone(target, 6, false) then
      doBackstab(target)
    end
  end)
end
GUI_READY=false
stateControlRefs={}
aimLockToggleRef,autoAimToggleRef,rageToggleRef,silentToggleRef=nil,nil,nil,nil
combatModeSyncing=false
featureNoticeAt = {}
featureUnavailable = function(name, reason)
  local key = tostring(name or "Feature") .. ":" .. tostring(reason or "")
  local now = tick()
  if featureNoticeAt[key] and now - featureNoticeAt[key] < 7 then
    return
  end
  featureNoticeAt[key] = now
  nxWarn("[NovaX] " .. tostring(name or "Feature") .. ": " .. tostring(reason or "nicht verfuegbar"))
end
function hasSilentHookSupport()
  return SUPPORT.MetaHook and typeof(hookmetamethod) == "function"
end
function setControlFromState(control,value) if control then pcall(function() if control.Set then control:Set(value) elseif control.SetValue then control:SetValue(value) end end) end end
function bindStateControl(key,control,sync) if not key or not control then return control end; stateControlRefs[key]=stateControlRefs[key] or {}; table.insert(stateControlRefs[key],{control=control,sync=sync}); return control end
function syncStateControlsFromState() for key,refs in pairs(stateControlRefs) do for _,entry in ipairs(refs) do if entry.sync then pcall(entry.sync,STATE[key],entry.control) else setControlFromState(entry.control,STATE[key]) end end end end
function setToggleValue(ref,value) if ref and ref.Set then pcall(function() ref:Set(value) end) end end
function resetAimLockRuntime()
  aimTarget, aimLockedPlayer = nil, nil
  aimLockLostSince = 0
  aimLockMouseState = Vector2.new(0, 0)
  aimLockMouseRemainder = Vector2.new(0, 0)
  aimLockMouseSign = 1
  if aimLockDirectionProbe then
    aimLockDirectionProbe.error = nil
    aimLockDirectionProbe.at = 0
    aimLockDirectionProbe.bad = 0
  end
  resetMouseModeState("lock", true)
  clearAimTargetHighlight()
end

function resetAutoAimRuntime()
  autoAimTarget, autoAimLockedPlayer, autoAimSmoothedPos, autoAimLastPart = nil, nil, nil, nil
  autoAimPredictedPos = nil
  autoAimLastRawPos = nil
  autoAimVelocity = Vector3.zero
  autoAimLostSince, autoAimReleaseUntil, autoAimManualBreakUntil, autoAimBreakScore = 0, 0, 0, 0
  autoAimMixedUseHead, autoAimMixedNextSwitch, autoAimMixedBlend = true, tick() + 0.2, 0
  resetMouseModeState("auto", true)
end

function resetMouseAssistRuntime()
  mouseAssistTarget = nil
  mouseAssistLockedPlayer = nil
  mouseAssistLostSince = 0
  mouseAssistSmoothedPos = nil
  resetMouseModeState("assist", true)
end

function resetRageRuntime()
  rageTarget, rageLockedPlayer, rageNextShotAt = nil, nil, 0
  rageMixedUseHead, rageMixedNextSwitch, rageMixedBlend = true, 0, 0
  resetMouseModeState("rage", true)
  restoreRageWeaponLock()
end
function resetSilentAimRuntime() silentAimCachedTarget=nil; silentAimCachedAt=0 end
function enforceNoHookMode()
  STATE.NoHookMode = "ULTRA"
end
function enforceAlwaysOnChecks()
  STATE.AimTeamCheck = true
  STATE.AimRequireCenter = true
  STATE.TriggerTeamCheck = true
  STATE.TriggerRequireCenter = true
  STATE.TriggerVisibleCheck = true
  STATE.RageVisibilityCheck = false
  STATE.FPSUnlocker = true
  STATE.InfJumpHeight = math.clamp(safeNum(STATE.InfJumpHeight), 28, 80)
end
function enforceAimModeExclusivity(preferredMode)
  local active = preferredMode
  if active == "SilentAim" then
    active = nil
  end
  if not active then
    if STATE.RageBot then
      active = "RageBot"
    elseif STATE.AimLock then
      active = "AimLock"
    elseif STATE.AutoAim then
      active = "AutoAim"
    end
  end
  STATE.AimLock = active == "AimLock"
  STATE.AutoAim = active == "AutoAim"
  STATE.RageBot = active == "RageBot"
  if active ~= "AimLock" then resetAimLockRuntime() end
  if active ~= "AutoAim" then resetAutoAimRuntime() end
  if active ~= "RageBot" then resetRageRuntime() end
end
function setSilentAimEnabled(enabled)
  STATE.SilentAim = enabled == true
  resetSilentAimRuntime()
  setToggleValue(silentToggleRef, STATE.SilentAim)
end
function applyExclusiveMode(modeName,enabled)
  if combatModeSyncing then return end; combatModeSyncing=true
  if modeName=="SilentAim" then
    setSilentAimEnabled(enabled)
  elseif enabled then
    if modeName=="AimLock" then
      resetAimLockRuntime()
    elseif modeName=="AutoAim" then
      resetAutoAimRuntime()
    elseif modeName=="RageBot" then
      resetRageRuntime()
    end
    enforceAimModeExclusivity(modeName)
  else
    if modeName=="AimLock" then
      STATE.AimLock=false
      resetAimLockRuntime()
    elseif modeName=="AutoAim" then
      STATE.AutoAim=false
      resetAutoAimRuntime()
    elseif modeName=="RageBot" then
      STATE.RageBot=false
      resetRageRuntime()
    end
  end
  setToggleValue(aimLockToggleRef,STATE.AimLock); setToggleValue(autoAimToggleRef,STATE.AutoAim); setToggleValue(rageToggleRef,STATE.RageBot); setToggleValue(silentToggleRef,STATE.SilentAim); combatModeSyncing=false
end
-- NovaX nutzt bewusst nur die echte NovaPremiumUI-Library.
-- Die alte Mini-Fallback-GUI wurde entfernt, weil sie die moderne Lib-API nicht exakt abbildet.
local function loadNovaUI()
  if type(NovaPremiumUI) == "table" and type(NovaPremiumUI.CreateWindow) == "function" then
    if getgenv then
      getgenv().NovaPremiumUI = NovaPremiumUI
    end
    return NovaPremiumUI
  end
  
  if getgenv and type(getgenv().NovaPremiumUI) == "table" and type(getgenv().NovaPremiumUI.CreateWindow) == "function" then
    return getgenv().NovaPremiumUI
  end

  local loadErrors = {}

  local loader = typeof(loadstring) == "function" and loadstring or nil
  if typeof(readfile) == "function" and loader then
    local candidates = {
      "NovaPremiumUI.lua",
      "./NovaPremiumUI.lua",
      "novax/NovaPremiumUI.lua",
      "side_project_blueui/NovaPremiumUI.lua",
      "C:/Users/User/OneDrive/Neuer Ordner 1/NovaPremiumUI.lua",
      "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\NovaPremiumUI.lua",
    }
    
    for _, path in ipairs(candidates) do
      local okRead, src = pcall(function()
        return readfile(path)
      end)
      if okRead and type(src) == "string" and src ~= "" then
        src = src:gsub("^\239\187\191", "")
        local okLoad, chunk = pcall(function()
          return loader(src)
        end)
        if okLoad and type(chunk) == "function" then
          local okRun, lib = pcall(chunk)
          if okRun and type(lib) == "table" and type(lib.CreateWindow) == "function" then
            if getgenv then
              getgenv().NovaPremiumUI = lib
            end
            return lib
          else
            table.insert(loadErrors, path .. " run: " .. tostring(lib))
          end
        else
          table.insert(loadErrors, path .. " load: " .. tostring(chunk))
        end
      elseif okRead then
        table.insert(loadErrors, path .. " leer")
      end
    end
  else
    table.insert(loadErrors, "readfile/loadstring nicht verfuegbar")
  end

  return nil, table.concat(loadErrors, " | ")
end

local GUI_BOOT_ERROR = nil
local Rayfield = nil
local Win = nil
local function NX_BootGUI()
  local uiLoadError, _winError
  Rayfield, uiLoadError = loadNovaUI()
  Win = nil
  GUI_READY = false
  
  if Rayfield and type(Rayfield.CreateWindow) == "function" then
    GUI_READY, _winError = pcall(function()
      Win = Rayfield:CreateWindow({
        Name = "NovaX",
        Title = "NovaX",
        LoadingTitle = "NovaX",
        LoadingSubtitle = "Xeno",
        Subtitle = "Xeno control panel",
        LogoRingImage = {
          "novax_logo_ring_transparent.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/novax_logo_ring_transparent.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\novax_logo_ring_transparent.png",
        },
        LogoImage = {
          "novax_logo_transparent.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/novax_logo_transparent.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\novax_logo_transparent.png",
          "download.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/download.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\download.png",
          "NovaX_Logo.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/NovaX_Logo.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\NovaX_Logo.png",
          "C:/Users/User/Downloads/NovaX Logo.png",
          "C:\\Users\\User\\Downloads\\NovaX Logo.png",
        },
        ShowWelcome = false,
        ConfigurationSaving = {Enabled = false},
        KeySystem = false,
      })
    end)
  else
    _winError = uiLoadError or "NovaPremiumUI missing"
  end
  GUI_BOOT_ERROR = _winError
  
  GUI_READY = GUI_READY and Win ~= nil
  if GUI_READY then
    UI_WINDOW = Win
  end
  if getgenv then
    local gv = getgenv()
    gv.NX_GUI_READY = GUI_READY == true
    if GUI_READY and Win then
      gv.NX_UI_WINDOW = Win
      gv.NX_UI_GUI = Win.Gui
      gv.NX_UI_ROOT = Win.Root
    else
      gv.NX_UI_WINDOW = nil
      gv.NX_UI_GUI = nil
      gv.NX_UI_ROOT = nil
    end
  end
end

NX_BootGUI()

featureUnavailable = function(name, reason)
  local title = tostring(name or "Feature") .. " nicht verfuegbar"
  local content = tostring(reason or "Diese Funktion wird von diesem Executor nicht unterstuetzt.")
  local key = title .. ":" .. content
  local now = tick()
  if featureNoticeAt[key] and now - featureNoticeAt[key] < 7 then
    return
  end
  featureNoticeAt[key] = now
  nxWarn("[NovaX] " .. title .. ": " .. content)
end

if not GUI_READY then
  nxWarn("[NovaX] NovaPremiumUI konnte die GUI nicht erstellen: " .. tostring(GUI_BOOT_ERROR))
  notify("NovaX", "GUI konnte nicht geladen werden. NovaPremiumUI.lua pruefen.", 6)
end

function createExpandableToggleControl(tab, cfg)
  if tab and tab.CreateExpandableToggle then
    return tab:CreateExpandableToggle(cfg)
  end
  return tab:CreateToggle(cfg)
end

function createNestedSliderControl(parent, fallback, cfg)
  if parent and parent.CreateSlider then
    return parent:CreateSlider(cfg)
  end
  return fallback:CreateSlider(cfg)
end

function createOptionPickerControl(parent, cfg)
  if parent and parent.CreateOptionPicker then
    return parent:CreateOptionPicker(cfg)
  end
  if parent and parent.CreateDropdown then
    return parent:CreateDropdown(cfg)
  end
  return nil
end

local TARGET_PART_OPTIONS_FULL = {"Kopf", "Koerper", "Mitte", "Gemischt"}
local TARGET_PART_OPTIONS_BODY = {"Kopf", "Koerper", "Gemischt"}
local TARGET_PART_LABEL_TO_VALUE = {
  Kopf = "Head",
  Head = "Head",
  Koerper = "Torso",
  Body = "Torso",
  Torso = "Torso",
  UpperTorso = "Torso",
  LowerTorso = "Torso",
  Mitte = "HumanoidRootPart",
  Center = "HumanoidRootPart",
  Root = "HumanoidRootPart",
  HumanoidRootPart = "HumanoidRootPart",
  Gemischt = "Mixed",
  Mixed = "Mixed",
}
local TARGET_PART_VALUE_TO_LABEL = {
  Head = "Kopf",
  Torso = "Koerper",
  UpperTorso = "Koerper",
  LowerTorso = "Koerper",
  HumanoidRootPart = "Mitte",
  Root = "Mitte",
  Mixed = "Gemischt",
}

local function targetPartToLabel(value)
  return TARGET_PART_VALUE_TO_LABEL[tostring(value or "Head")] or "Kopf"
end

local function targetPartFromLabel(value, allowCenter)
  local selected = TARGET_PART_LABEL_TO_VALUE[tostring(type(value) == "table" and value[1] or value or "Head")] or "Head"
  if selected == "HumanoidRootPart" and not allowCenter then
    return "Torso"
  end
  return selected
end

local function NX_BuildGUI()
if not GUI_READY then
  return
end

  local CT = Win:CreateTab("Combat", 4483345998)
  CT:CreateSection("AimLock")
  
  do
    local c = createExpandableToggleControl(CT, {
        Name = "AimLock",
        CurrentValue = STATE.AimLock,
        Expanded = false,
        Callback = function(v)
          applyExclusiveMode("AimLock", v)
        end,
      })
    aimLockToggleRef = bindStateControl("AimLock", c)
    bindStateControl("AimLockRequireRMB", c:CreateToggle({
      Name = "Nur Bei RMB",
      CurrentValue = STATE.AimLockRequireRMB,
      Callback = function(v)
        STATE.AimLockRequireRMB = v
      end,
    }))
    bindStateControl(
      "AimLockPart",
      createOptionPickerControl(c, {
        Name = "Zielbereich",
        Options = TARGET_PART_OPTIONS_FULL,
        Columns = 2,
        CurrentOption = {targetPartToLabel(STATE.AimLockPart)},
        Callback = function(v)
          STATE.AimLockPart = targetPartFromLabel(v, true)
          resetAimLockRuntime()
        end,
      }),
      function(v, o)
        setControlFromState(o, targetPartToLabel(v))
      end
    )
    bindStateControl("AimMaxDist", c:CreateSlider({
      Name = "Max Distance",
      Range = {50, 2000},
      Increment = 25,
      CurrentValue = STATE.AimMaxDist,
      Callback = function(v)
        STATE.AimMaxDist = v
        resetAimLockRuntime()
        resetAutoAimRuntime()
        resetRageRuntime()
      end,
    }))
  end
  
  do
    local c = createExpandableToggleControl(CT, {
        Name = "Auto Aim",
        CurrentValue = STATE.AutoAim,
        Expanded = false,
        Callback = function(v)
          applyExclusiveMode("AutoAim", v)
        end,
      })
    autoAimToggleRef = bindStateControl("AutoAim", c)
    bindStateControl(
      "AutoAimTargetPart",
      createOptionPickerControl(c, {
        Name = "Zielbereich",
        Options = TARGET_PART_OPTIONS_BODY,
        Columns = 3,
        CurrentOption = {targetPartToLabel(STATE.AutoAimTargetPart)},
        Callback = function(v)
          STATE.AutoAimTargetPart = targetPartFromLabel(v, false)
          resetAutoAimRuntime()
        end,
      }),
      function(v, o)
        setControlFromState(o, targetPartToLabel(v))
      end
    )
    bindStateControl("AutoAimVisibleCheck", c:CreateToggle({
      Name = "Visibility Check",
      CurrentValue = STATE.AutoAimVisibleCheck,
      Callback = function(v)
        STATE.AutoAimVisibleCheck = v
        resetAutoAimRuntime()
      end,
    }))
    bindStateControl("AutoAimRequireRMB", c:CreateToggle({
      Name = "Nur Bei RMB",
      CurrentValue = STATE.AutoAimRequireRMB,
      Callback = function(v)
        STATE.AutoAimRequireRMB = v
      end,
    }))
    bindStateControl("AutoAimStrengthADS", c:CreateSlider({
      Name = "ADS Strength",
      Range = {0, 100},
      Increment = 1,
      CurrentValue = STATE.AutoAimStrengthADS,
      Callback = function(v)
        STATE.AutoAimStrengthADS = v
      end,
    }))
    bindStateControl("AutoAimStrengthHip", c:CreateSlider({
      Name = "Hipfire Strength",
      Range = {0, 100},
      Increment = 1,
      CurrentValue = STATE.AutoAimStrengthHip,
      Callback = function(v)
        STATE.AutoAimStrengthHip = v
      end,
    }))
    bindStateControl("AutoAimPrediction", c:CreateSlider({
      Name = "Prediction",
      Range = {0, 100},
      Increment = 1,
      CurrentValue = STATE.AutoAimPrediction,
      Callback = function(v)
        STATE.AutoAimPrediction = math.clamp(safeNum(v), 0, 100)
      end,
    }))
  end
    do
    local c
    c = createExpandableToggleControl(CT, {
        Name = "Mouse Aim Assist",
        CurrentValue = STATE.AimMouseAssist,
        Expanded = false,
        Callback = function(v)
          STATE.AimMouseAssist = v == true
          if not STATE.AimMouseAssist then
            resetMouseAssistRuntime()
            resetMouseModeState("auto", true)
            resetMouseModeState("lock", true)
            resetMouseModeState("rage", true)
            injectedMouseDelta = Vector2.new(0, 0)
            injectedMouseAt = 0
          end
        end,
      })
    bindStateControl("AimMouseAssist", c)
    bindStateControl(
      "AimMouseAssistSmooth",
      c:CreateSlider({
        Name = "Smoothness",
        Range = {1, 100},
        Increment = 1,
        CurrentValue = math.floor(STATE.AimMouseAssistSmooth * 100 + 0.5),
        Callback = function(v)
          STATE.AimMouseAssistSmooth = math.clamp(safeNum(v) / 100, 0.01, 1)
        end,
      }),
      function(v, o)
        setControlFromState(o, math.floor(math.clamp(safeNum(v), 0.01, 1) * 100 + 0.5))
      end
    )
    bindStateControl("AimMouseAssistStrength", c:CreateSlider({
      Name = "Strength",
      Range = {5, 100},
      Increment = 1,
      CurrentValue = STATE.AimMouseAssistStrength,
      Callback = function(v)
        STATE.AimMouseAssistStrength = v
      end,
    }))
  end
  
  CT:CreateSection("Other")
  do
    local c = createExpandableToggleControl(CT, {
        Name = "Rage Bot",
        CurrentValue = STATE.RageBot,
        Expanded = false,
        Callback = function(v)
          applyExclusiveMode("RageBot", v)
        end,
      })
    rageToggleRef = bindStateControl("RageBot", c)
    bindStateControl(
      "RageTargetPart",
      createOptionPickerControl(c, {
        Name = "Zielbereich",
        Options = TARGET_PART_OPTIONS_BODY,
        Columns = 3,
        CurrentOption = {targetPartToLabel(STATE.RageTargetPart)},
        Callback = function(v)
          STATE.RageTargetPart = targetPartFromLabel(v, false)
          resetRageRuntime()
        end,
      }),
      function(v, o)
        setControlFromState(o, targetPartToLabel(v))
      end
    )
    bindStateControl("RageLockStrength", c:CreateSlider({
      Name = "Lock Strength",
      Range = {1, 100},
      Increment = 1,
      CurrentValue = STATE.RageLockStrength,
      Callback = function(v)
        STATE.RageLockStrength = v
      end,
    }))
    bindStateControl("RageAutoShoot", c:CreateToggle({
      Name = "Auto Shoot",
      CurrentValue = STATE.RageAutoShoot,
      Callback = function(v)
        STATE.RageAutoShoot = v
      end,
    }))
    bindStateControl("RageRequireADS", c:CreateToggle({
      Name = "Aim RMB",
      CurrentValue = STATE.RageRequireADS,
      Callback = function(v)
        STATE.RageRequireADS = v
      end,
    }))
    bindStateControl("RageCPS", c:CreateSlider({
      Name = "Shoot CPS",
      Range = {1, MAX_TRIGGER_CPS},
      Increment = 1,
      CurrentValue = math.min(MAX_TRIGGER_CPS, math.max(1, STATE.RageCPS)),
      Callback = function(v)
        STATE.RageCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(v)))
      end,
    }))
    bindStateControl("RageShootFOV", c:CreateSlider({
      Name = "Shoot Radius",
      Range = {2, 30},
      Increment = 1,
      CurrentValue = STATE.RageShootFOV,
      Callback = function(v)
        STATE.RageShootFOV = v
      end,
    }))
  end
  
  CT:CreateSection("Trigger")
  do
    local c = createExpandableToggleControl(CT, {
        Name = "Trigger Bot",
        CurrentValue = STATE.TriggerEnabled,
        Expanded = false,
        Callback = function(v)
          STATE.TriggerEnabled = v
        end,
      })
    bindStateControl("TriggerEnabled", c)
    bindStateControl(
      "TriggerTarget",
      c:CreateDropdown({
        Name = "Target",
        Options = {"Head", "Torso", "Any Visible Body"},
        CurrentOption = {STATE.TriggerTarget},
        Callback = function(v)
          STATE.TriggerTarget = type(v) == "table" and v[1] or tostring(v)
        end,
      }),
      function(v, o)
        setControlFromState(o, tostring(v or "Head"))
      end
    )
    bindStateControl("TriggerDelay", c:CreateSlider({
      Name = "Delay ms",
      Range = {0, 250},
      Increment = 5,
      CurrentValue = STATE.TriggerDelay,
      Callback = function(v)
        STATE.TriggerDelay = v
      end,
    }))
    bindStateControl("TriggerCPS", c:CreateSlider({
      Name = "CPS",
      Range = {1, MAX_TRIGGER_CPS},
      Increment = 1,
      CurrentValue = math.min(MAX_TRIGGER_CPS, math.max(1, STATE.TriggerCPS)),
      Callback = function(v)
        STATE.TriggerCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(v)))
      end,
    }))
  end
  

  do
    local c = createExpandableToggleControl(CT, {
        Name = "FOV",
        CurrentValue = STATE.AimFOVCircle,
        Expanded = false,
        Callback = function(v)
          STATE.AimFOVCircle = v
        end,
      })
    bindStateControl("AimFOVCircle", c)
    bindStateControl("AimFOV", c:CreateSlider({
      Name = "Radius",
      Range = {20, 500},
      Increment = 10,
      CurrentValue = STATE.AimFOV,
      Callback = function(v)
        STATE.AimFOV = v
        resetSilentAimRuntime()
        updateFOV()
      end,
    }))
    bindStateControl("AimFOVHidden", c:CreateToggle({
      Name = "Hide FOV",
      CurrentValue = STATE.AimFOVHidden,
      Callback = function(v)
        STATE.AimFOVHidden = v
        updateFOV()
      end,
    }))
    bindStateControl(
      "AimFOVColor",
      c:CreateDropdown({
        Name = "Color",
        Options = {"White", "Blue", "Cyan", "Green", "Yellow", "Red", "Pink"},
        CurrentOption = {STATE.AimFOVColor},
        Callback = function(v)
          STATE.AimFOVColor = type(v) == "table" and v[1] or tostring(v)
          updateFOV()
        end,
      }),
      function(v, o)
        setControlFromState(o, tostring(v or "White"))
      end
    )
  end
  
  do
    local c = createExpandableToggleControl(CT, {
        Name = "Silent Aim",
        CurrentValue = STATE.SilentAim,
        Expanded = false,
        Callback = function(v)
          applyExclusiveMode("SilentAim", v)
        end,
      })
    silentToggleRef = bindStateControl("SilentAim", c)
    bindStateControl("SilentAimFOVOnly", c:CreateToggle({
      Name = "Nur Im FOV",
      CurrentValue = STATE.SilentAimFOVOnly,
      Callback = function(v)
        STATE.SilentAimFOVOnly = v
        resetSilentAimRuntime()
      end,
    }))
    bindStateControl("SilentAimAutoShoot", c:CreateToggle({
      Name = "Auto Shoot Visible",
      CurrentValue = STATE.SilentAimAutoShoot,
      Callback = function(v)
        STATE.SilentAimAutoShoot = v
        resetSilentAimRuntime()
      end,
    }))
    bindStateControl("SilentAimAutoShootCPS", c:CreateSlider({
      Name = "Auto Shoot CPS",
      Range = {1, MAX_TRIGGER_CPS},
      Increment = 1,
      CurrentValue = math.min(MAX_TRIGGER_CPS, math.max(1, STATE.SilentAimAutoShootCPS)),
      Callback = function(v)
        STATE.SilentAimAutoShootCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(v)))
      end,
    }))
    bindStateControl(
      "SilentAimMode",
      c:CreateDropdown({
        Name = "Mode",
        Options = {"No Hook"},
        CurrentOption = {STATE.SilentAimMode},
        Callback = function()
          STATE.SilentAimMode = "No Hook"
          enforceNoHookMode()
          syncStateControlsFromState()
        end,
      }),
      function(v, o)
        setControlFromState(o, "No Hook")
      end
    )
  end
  
  local ET = Win:CreateTab("ESP", 4483345998)
  for _, item in ipairs({
    {"ESPEnabled", "ESP"},
    {"ESPEnemy", "Enemy"},
    {"ESPTeam", "Team"},
    {"ESPHighlight", "Highlights"},
    {"ESPName", "Names"},
    {"ESPHealth", "Health"},
    {"ESPDistance", "Distance"},
    {"ESPBox", "Boxes"},
    {"ESPSkeleton", "Skeleton"},
  }) do
    bindStateControl(item[1], ET:CreateToggle({
      Name = item[2],
      CurrentValue = STATE[item[1]],
      Callback = function(v)
        STATE[item[1]] = v
      end,
    }))
  end
  bindStateControl("ESPBoxScale", ET:CreateSlider({
    Name = "Box Scale",
    Range = {30, 70},
    Increment = 1,
    CurrentValue = STATE.ESPBoxScale,
    Callback = function(v)
      STATE.ESPBoxScale = v
    end,
  }))
  bindStateControl("ESPMaxDistance", ET:CreateSlider({
    Name = "Max Distance",
    Range = {50, 2000},
    Increment = 25,
    CurrentValue = STATE.ESPMaxDistance,
    Callback = function(v)
      STATE.ESPMaxDistance = v
    end,
  }))
  bindStateControl("ESPUpdateFPS", ET:CreateSlider({
    Name = "Update FPS",
    Range = {5, 18},
    Increment = 1,
    CurrentValue = STATE.ESPUpdateFPS,
    Callback = function(v)
      STATE.ESPUpdateFPS = math.clamp(safeNum(v), 5, 18)
    end,
  }))
  
  local MT = Win:CreateTab("Movement", 4483345998)
  do
    local c = createExpandableToggleControl(MT, {
        Name = "Speed",
        CurrentValue = STATE.SpeedEnabled,
        Expanded = false,
        Callback = function(v)
          STATE.SpeedEnabled = v
        end,
      })
    bindStateControl("SpeedEnabled", c)
    local speedSlider = createNestedSliderControl(c, MT, {
      Name = "Speed Value",
      Range = {16, 200},
      Increment = 1,
      CurrentValue = STATE.SpeedValue,
      Callback = function(v)
        STATE.SpeedValue = v
      end,
    })
    bindStateControl("SpeedValue", speedSlider)
  end
  
  do
    local c = createExpandableToggleControl(MT, {
        Name = "Fly",
        CurrentValue = STATE.FlyEnabled,
        Expanded = false,
        Callback = function(v)
          STATE.FlyEnabled = v
          if not v then
            STATE.FlyToggle = false
            stopFly()
          end
        end,
      })
    bindStateControl("FlyEnabled", c)
    local flySpeedSlider = createNestedSliderControl(c, MT, {
      Name = "Fly Speed",
      Range = {16, 200},
      Increment = 1,
      CurrentValue = STATE.FlySpeed,
      Callback = function(v)
        STATE.FlySpeed = v
      end,
    })
    bindStateControl("FlySpeed", flySpeedSlider)
  end
  
  do
    local c = createExpandableToggleControl(MT, {
        Name = "Anti Hit",
        CurrentValue = STATE.AntiHit,
        Expanded = false,
        Callback = function(v)
          STATE.AntiHit = v
        end,
      })
    bindStateControl("AntiHit", c)
    bindStateControl(
      "AntiHitMode",
      c:CreateDropdown({
        Name = "Mode",
        Options = {"Adaptive Jitter", "Orbital Drift", "Head Orbit", "Vector Chaos"},
        CurrentOption = {STATE.AntiHitMode},
        Callback = function(v)
          STATE.AntiHitMode = type(v) == "table" and v[1] or tostring(v)
        end,
      }),
      function(v, o)
        setControlFromState(o, tostring(v or "Adaptive Jitter"))
      end
    )
    bindStateControl(
      "AntiHitSpeed",
      c:CreateSlider({
        Name = "Speed",
        Range = {4, 120},
        Increment = 1,
        CurrentValue = math.floor(STATE.AntiHitSpeed * 10 + 0.5),
        Callback = function(v)
          STATE.AntiHitSpeed = math.clamp(safeNum(v) / 10, 0.4, 12)
        end,
      }),
      function(v, o)
        setControlFromState(o, math.floor(math.clamp(safeNum(v), 0.4, 12) * 10 + 0.5))
      end
    )
    bindStateControl("AntiHitExperimental", c:CreateToggle({
      Name = "Experimental Pose Layer",
      CurrentValue = STATE.AntiHitExperimental,
      Callback = function(v)
        STATE.AntiHitExperimental = v
      end,
    }))
    bindStateControl(
      "AntiHitHitboxMode",
      c:CreateDropdown({
        Name = "Hitbox Mode",
        Options = {"Off", "Compact Body", "Flat Body", "Thin Body"},
        CurrentOption = {STATE.AntiHitHitboxMode},
        Callback = function(v)
          STATE.AntiHitHitboxMode = type(v) == "table" and v[1] or tostring(v)
          restoreAntiHitHitbox()
        end,
      }),
      function(v, o)
        setControlFromState(o, tostring(v or "Off"))
      end
    )
    bindStateControl("AntiHitHitboxScale", c:CreateSlider({
      Name = "Hitbox Scale",
      Range = {25, 100},
      Increment = 1,
      CurrentValue = STATE.AntiHitHitboxScale,
      Callback = function(v)
        STATE.AntiHitHitboxScale = math.clamp(safeNum(v), 25, 100)
        restoreAntiHitHitbox()
      end,
    }))
    bindStateControl("AntiVoid", c:CreateToggle({
      Name = "Anti Void",
      CurrentValue = STATE.AntiVoid,
      Callback = function(v)
        STATE.AntiVoid = v
      end,
    }))
  end
  
  do
    local c = createExpandableToggleControl(MT, {
        Name = "Inf Jump",
        CurrentValue = STATE.InfJump,
        Expanded = false,
        Callback = function(v)
          STATE.InfJump = v
        end,
      })
    bindStateControl("InfJump", c)
    local jumpControls = (c and c.CreateSlider) and c or MT
    bindStateControl("BunnyHop", jumpControls:CreateToggle({
      Name = "Bunny Hop",
      CurrentValue = STATE.BunnyHop,
      Callback = function(v)
        STATE.BunnyHop = v
      end,
    }))
    bindStateControl("InfJumpHeight", jumpControls:CreateSlider({
      Name = "Jump Height",
      Range = {28, 80},
      Increment = 1,
      CurrentValue = STATE.InfJumpHeight,
      Callback = function(v)
        STATE.InfJumpHeight = math.clamp(safeNum(v), 28, 80)
      end,
    }))
  end
  bindStateControl("NoClip", MT:CreateToggle({
    Name = "NoClip",
    CurrentValue = STATE.NoClip,
    Callback = function(v)
      STATE.NoClip = v
    end,
  }))
  
  local TT = Win:CreateTab("TP/Backstab", 4483345998)
  do
    local c = createExpandableToggleControl(TT, {
        Name = "Auto Backstab",
        CurrentValue = STATE.AutoBackstab,
        Expanded = false,
        Callback = function(v)
          STATE.AutoBackstab = v
        end,
      })
    bindStateControl("AutoBackstab", c)
    bindStateControl("AutoBackstabInterval", c:CreateSlider({
      Name = "Interval ms",
      Range = {80, 1000},
      Increment = 10,
      CurrentValue = STATE.AutoBackstabInterval,
      Callback = function(v)
        STATE.AutoBackstabInterval = v
      end,
    }))
    bindStateControl("AutoBackstabRandomize", c:CreateToggle({
      Name = "Randomize",
      CurrentValue = STATE.AutoBackstabRandomize,
      Callback = function(v)
        STATE.AutoBackstabRandomize = v
      end,
    }))
    bindStateControl("AutoBackstabRandomMin", c:CreateSlider({
      Name = "Random Min",
      Range = {50, 1000},
      Increment = 10,
      CurrentValue = STATE.AutoBackstabRandomMin,
      Callback = function(v)
        STATE.AutoBackstabRandomMin = v
      end,
    }))
    bindStateControl("AutoBackstabRandomMax", c:CreateSlider({
      Name = "Random Max",
      Range = {50, 1500},
      Increment = 10,
      CurrentValue = STATE.AutoBackstabRandomMax,
      Callback = function(v)
        STATE.AutoBackstabRandomMax = v
      end,
    }))
  end

  do
    local c = createExpandableToggleControl(TT, {
        Name = "Names Orbit",
        CurrentValue = STATE.NamesOrbit,
        Expanded = false,
        Callback = function(v)
          STATE.NamesOrbit = v
        end,
      })
    bindStateControl("NamesOrbit", c)
    bindStateControl("NamesOrbitInterval", c:CreateSlider({
      Name = "Interval ms",
      Range = {80, 800},
      Increment = 10,
      CurrentValue = STATE.NamesOrbitInterval,
      Callback = function(v)
        STATE.NamesOrbitInterval = v
      end,
    }))
  end
  
  local createPlayerSelector = TT.CreatePlayerSearch or TT.CreateDropdown
  tpDropdownRef = bindStateControl(
    "TPPlayer",
    createPlayerSelector(TT, {
      Name = "Target Player",
      Options = getSelectablePlayers(),
      CurrentOption = {"None"},
      PlaceholderText = "Search player...",
      ListHeight = 220,
      Callback = setTPPlayer,
    }),
    function(v, o)
      setControlFromState(o, v and v ~= "" and v or "None")
    end
  )
  TT.OnShow = function()
    refreshTPDropdown()
  end
  bindStateControl("TPDistance", TT:CreateSlider({
    Name = "TP Distance",
    Range = {2, 20},
    Increment = 1,
    CurrentValue = STATE.TPDistance,
    Callback = function(v)
      STATE.TPDistance = v
    end,
  }))
  TT:CreateButton({
    Name = "TP Near Selected",
    Callback = function()
      teleportNearSelected(false)
    end,
  })
  TT:CreateButton({
    Name = "TP Behind Selected",
    Callback = function()
      teleportNearSelected(true)
    end,
  })
  TT:CreateButton({
    Name = "TP Up Selected",
    Callback = teleportUpSelected,
  })
  TT:CreateButton({Name = "Backstab Once", Callback = backstabOnce})
  
  local VT = Win:CreateTab("Visual", 4483345998)
  bindStateControl("FullBright", VT:CreateToggle({
    Name = "FullBright",
    CurrentValue = STATE.FullBright,
    Callback = function(v)
      STATE.FullBright = v
      setFB(v)
    end,
  }))
  bindStateControl("NoFog", VT:CreateToggle({
    Name = "No Fog",
    CurrentValue = STATE.NoFog,
    Callback = function(v)
      STATE.NoFog = v
      setNF(v)
    end,
  }))
  bindStateControl("FPSBoost", VT:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = STATE.FPSBoost,
    Callback = function(v)
      STATE.FPSBoost = v
      setFPSBoost(v)
    end,
  }))
  
  local MST = Win:CreateTab("Misc", 4483345998)
  bindStateControl("BeggerFarm", MST:CreateToggle({
    Name = "Begger Farm",
    CurrentValue = STATE.BeggerFarm,
    Callback = function(v)
      STATE.BeggerFarm = v
    end,
  }))
  
  local spoofRefs = {}
  local function setSpoofRef(ref, value)
    if ref and ref.Set then
      pcall(function()
        ref:Set(value)
      end)
    end
  end
  local function syncSpoofs()
    setSpoofRef(spoofRefs["MobileSpoof"], STATE.MobileSpoof)
    setSpoofRef(spoofRefs["ConsoleSpoof"], STATE.ConsoleSpoof)
    setSpoofRef(spoofRefs["VRSpoof"], STATE.VRSpoof)
  end
  local function setSpoof(key, value)
    STATE.MobileSpoof = false
    STATE.ConsoleSpoof = false
    STATE.VRSpoof = false
    if value then
      STATE[key] = true
    end
    syncSpoofs()
    applyDeviceSpoof()
  end
  
  spoofRefs.MobileSpoof = bindStateControl("MobileSpoof", MST:CreateToggle({
    Name = "Mobile Spoof",
    CurrentValue = STATE.MobileSpoof,
    Callback = function(v)
      setSpoof("MobileSpoof", v)
    end,
  }))
  spoofRefs.ConsoleSpoof = bindStateControl("ConsoleSpoof", MST:CreateToggle({
    Name = "Console Spoof",
    CurrentValue = STATE.ConsoleSpoof,
    Callback = function(v)
      setSpoof("ConsoleSpoof", v)
    end,
  }))
  spoofRefs.VRSpoof = bindStateControl("VRSpoof", MST:CreateToggle({
    Name = "VR Spoof",
    CurrentValue = STATE.VRSpoof,
    Callback = function(v)
      setSpoof("VRSpoof", v)
    end,
  }))
  
  MST:CreateButton({
    Name = "Reset Device Spoof",
    Callback = function()
      STATE.MobileSpoof = false
      STATE.ConsoleSpoof = false
      STATE.VRSpoof = false
      restoreDeviceSpoof()
      syncSpoofs()
    end,
  })
  
  local BT = Win:CreateTab("Binds", 4483345998)
  local function makeBind(label, key)
    if BT.CreateKeybind then
      bindStateControl(key, BT:CreateKeybind({
        Name = label,
        CurrentKeybind = STATE[key],
        Callback = function(v)
          STATE[key] = normalizeSingleLetterBind(v)
        end,
      }))
    else
      BT:CreateButton({
        Name = label .. " Set",
        Callback = function()
          notify("Bind", "NovaPremiumUI fuer Keybinds nutzen", 2)
        end,
      })
    end
  end
  for _, b in ipairs({
    {"Toggle GUI", "BindToggleGUI"},
    {"Fly Toggle", "BindFly"},
    {"Toggle AimLock", "BindAimLock"},
    {"Toggle AutoAim", "BindAutoAim"},
    {"Toggle RageBot", "BindRageBot"},
    {"Toggle Trigger", "BindTrigger"},
    {"Toggle ESP", "BindESP"},
    {"Toggle Begger Farm", "BindBeggerFarm"},
    {"Toggle Auto Backstab", "BindAutoBackstab"},
    {"Toggle Names Orbit", "BindNamesOrbit"},
    {"Apply Control Mode", "BindApplyControlMode"},
  }) do
    makeBind(b[1], b[2])
  end
  
  local function syncAfterConfigLoad()
    enforceNoHookMode()
    enforceAlwaysOnChecks()
    STATE.AimLockPart = targetPartFromLabel(STATE.AimLockPart, true)
    STATE.AutoAimTargetPart = targetPartFromLabel(STATE.AutoAimTargetPart, false)
    STATE.RageTargetPart = targetPartFromLabel(STATE.RageTargetPart, false)
    normalizeAllBinds()
    enforceAimModeExclusivity()
    setFB(STATE.FullBright)
    setNF(STATE.NoFog)
    STATE.FPSUnlocker = true
    setFPS(true)
    setFPSBoost(STATE.FPSBoost)
    applyDeviceSpoof()
    syncStateControlsFromState()
    refreshTPDropdown()
  end
  
  if Rayfield.CreateConfigManager then
    Rayfield:CreateConfigManager(Win, STATE, {
      Folder = CONFIG_FOLDER,
      DefaultName = "default",
      TabName = "Configs",
      Sync = syncAfterConfigLoad,
    })
  end
  
  addConnection("input", UserInputService.InputBegan:Connect(function(i, gp)
    if gp then
      return
    end
    if inputMatchesBind(i, STATE.BindToggleGUI) and Win.Toggle then
      Win:Toggle()
    end
    if inputMatchesBind(i, STATE.BindFly) and STATE.FlyEnabled then
      STATE.FlyToggle = not STATE.FlyToggle
      if not STATE.FlyToggle then
        stopFly()
      end
    end
    if inputMatchesBind(i, STATE.BindAimLock) then
      applyExclusiveMode("AimLock", not STATE.AimLock)
    end
    if inputMatchesBind(i, STATE.BindAutoAim) then
      applyExclusiveMode("AutoAim", not STATE.AutoAim)
    end
    if inputMatchesBind(i, STATE.BindRageBot) then
      applyExclusiveMode("RageBot", not STATE.RageBot)
    end
    if inputMatchesBind(i, STATE.BindTrigger) then
      STATE.TriggerEnabled = not STATE.TriggerEnabled
      syncStateControlsFromState()
    end
    if inputMatchesBind(i, STATE.BindESP) then
      STATE.ESPEnabled = not STATE.ESPEnabled
      syncStateControlsFromState()
    end
    if inputMatchesBind(i, STATE.BindBeggerFarm) then
      STATE.BeggerFarm = not STATE.BeggerFarm
      syncStateControlsFromState()
    end
    if inputMatchesBind(i, STATE.BindAutoBackstab) then
      STATE.AutoBackstab = not STATE.AutoBackstab
      syncStateControlsFromState()
    end
    if inputMatchesBind(i, STATE.BindNamesOrbit) then
      STATE.NamesOrbit = not STATE.NamesOrbit
      syncStateControlsFromState()
    end
    if inputMatchesBind(i, STATE.BindApplyControlMode) then
      applyDeviceSpoof()
    end
  end))
  
  syncStateControlsFromState()
  refreshTPDropdown()
end

local NX_BUILD_OK, NX_BUILD_ERR = pcall(NX_BuildGUI)
if not NX_BUILD_OK then
  nxWarn("[NovaX] GUI Build Fehler: " .. tostring(NX_BUILD_ERR))
  notify("NovaX", "GUI Build Fehler: " .. tostring(NX_BUILD_ERR), 6)
  pcall(function()
    if Win and Win.Gui then Win.Gui.Enabled = true end
    if Win and Win.Shell then Win.Shell.Visible = true end
    if Win and Win.Root then
      Win.Root.Visible = true
      Win.Root.BackgroundTransparency = 0
    end
  end)
end
function scheduleLoad(label, delay, fn)
  task.defer(function()
    if delay and delay > 0 then
      task.wait(delay)
    end
    if type(fn) ~= "function" then
      return
    end
    local ok, err = pcall(fn)
    if not ok then
      nxWarn("[NovaX] load step failed: " .. tostring(label) .. " -> " .. tostring(err))
    end
  end)
end

task.wait(0.18)

scheduleLoad("core.device", 0.02, function()
  applyDeviceSpoof()
  STATE.FPSUnlocker = true
  setFPS(true)
  setFPSBoost(STATE.FPSBoost)
end)
scheduleLoad("combat.scheduler", 0.08, setupCombat)
scheduleLoad("combat.aimlock", 0.10, setupAimLockLoop)
scheduleLoad("combat.mouseassist", 0.12, setupMouseAimAssistLoop)
scheduleLoad("combat.trigger", 0.14, setupTrigger)
scheduleLoad("utility.begger", 0.20, setupBeggerFarm)
scheduleLoad("utility.controlmode", 0.24, setupControlModeSpoof)
scheduleLoad("utility.backstab", 0.28, setupAutoBackstab)
scheduleLoad("utility.namesorbit", 0.30, setupNamesOrbit)
scheduleLoad("visual.esp", 0.34, setupESP)
scheduleLoad("movement", 0.40, setupMovement)
scheduleLoad("movement.infjump", 0.44, setupInfJump)
scheduleLoad("silent.hook", 0.58, function()
  if tostring(STATE.SilentAimMode or "No Hook") == "No Hook" then
    safeHook(setupGrabber, "Silent Aim No Hook")
    return
  end
  if hasSilentHookSupport() then
    safeHook(setupGrabber, "Silent Aim Hook")
  else
    featureUnavailable("Silent Aim Hook", "hookmetamethod/newcclosure/getnamecallmethod fehlen in diesem Executor; Toggle bleibt trotzdem unveraendert.")
  end
end)

notify("NovaX", "Loaded Successfully!", 3)
if GUI_READY then
  notify("GUI Bind", "Toggle: " .. tostring(STATE.BindToggleGUI or "K"), 2)
else
  notify("NovaX", "Features laufen, GUI-Lib fehlt/fehlerhaft", 3)
end

