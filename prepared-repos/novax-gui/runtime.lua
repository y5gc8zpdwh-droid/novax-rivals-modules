-- NovaX Runtime Core (Optimized for Xeno)
-- UI is loaded by init.lua from ui/NovaPremiumUI.lua.
-- version: modular runtime

-- NovaPremiumUI is loaded by init.lua from ui/NovaPremiumUI.lua.
local __NX_CONTEXT = ...
if type(__NX_CONTEXT) ~= "table" then
  __NX_CONTEXT = {}
end
local __NX_GLOBAL = (getgenv and getgenv()) or nil
local __NX_BOOT_ID = __NX_CONTEXT.BootId
local function __nxBootActive()
  return not __NX_GLOBAL or not __NX_BOOT_ID or __NX_GLOBAL.NX_BOOT_ID == __NX_BOOT_ID
end

if not __nxBootActive() then
  return {
    Stopped = true,
    Reason = "superseded",
  }
end

if __NX_GLOBAL and __nxBootActive() then
  __NX_GLOBAL.NX_XENO_LOADING = true
  __NX_GLOBAL.NX_GUI_READY = false
  __NX_GLOBAL.NX_UI_WINDOW = nil
  __NX_GLOBAL.NX_UI_GUI = nil
  __NX_GLOBAL.NX_UI_ROOT = nil
end

local NovaPremiumUI = __NX_CONTEXT.NovaPremiumUI or __NX_CONTEXT.UI
if not NovaPremiumUI and getgenv then
  NovaPremiumUI = getgenv().NovaPremiumUI
end

-- =============== NOVAX MAIN SCRIPT ===============

-- XENO EXECUTOR CHECK
if not game:IsLoaded() then
  game.Loaded:Wait()
end
task.wait(0.2)

local NX_SHOW_NOTIFICATIONS = true
function nxWarn(...)
  warn(...)
end
local cleanup
local controlSpoofApi = nil
local backstabApi = nil
local espApi = nil
local teleportApi = nil
local nameChangerApi = nil
local cleanAllESP = function()
  return espApi and espApi.CleanAll and espApi.CleanAll() or false
end
local clearStreamerNameTextPatches = function()
  return nameChangerApi and nameChangerApi.Clear and nameChangerApi.Clear() or false
end
local restoreDeviceSpoof = function()
  return controlSpoofApi and controlSpoofApi.Restore and controlSpoofApi.Restore() or false
end
local applyDeviceSpoof = function()
  return controlSpoofApi and controlSpoofApi.Apply and controlSpoofApi.Apply() or false
end
local visualEffectHandlers = {}
local function applyVisualEffect(name, enabled)
  local handler = visualEffectHandlers[name]
  if type(handler) == "function" then
    return handler(enabled)
  end
  return false
end
local setFB = function(enabled)
  return applyVisualEffect("FullBright", enabled)
end
local setNF = function(enabled)
  return applyVisualEffect("NoFog", enabled)
end
local setFPS = function(enabled)
  return applyVisualEffect("FPSUnlocker", enabled)
end
local setFPSBoost = function(enabled)
  return applyVisualEffect("FPSBoost", enabled)
end
local UI_WINDOW = nil
local ensureFeatureLoaded = function()
  return false
end
local registerLazyFeatures = function()
  return {}
end
local NXRuntime = nil

if getgenv and __nxBootActive() then
  local gv = getgenv()
  if __NX_BOOT_ID then
    gv.NX_BOOT_ID = __NX_BOOT_ID
  end
  gv.NX_XENO_LOADING = nil
  gv.NX_XENO = true
  gv.NX_CLEANUP = function()
    if cleanup then
      cleanup()
    end
  end
end

math.randomseed(tick() * 1000)

--  SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = nil
pcall(function()
  VirtualInputManager = game:GetService("VirtualInputManager")
end)
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Character-Basisdaten werden lazy abgefragt. Die GUI darf dadurch nie blockieren.

local huge = math.huge

--  XENO-SAFE FUNCTIONS

function safeNum(v)
  if v == nil then
    return 0
  end
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
        Duration = duration,
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

--  CONTROL
local RUNNING = true
local CONNECTIONS = {}
local CLEANUP_HOOKS = {}

function addConnection(name, conn)
  if not conn then
    return
  end
  if CONNECTIONS[name] then
    pcall(function()
      CONNECTIONS[name]:Disconnect()
    end)
  end
  CONNECTIONS[name] = conn
end

function addCleanup(name, fn)
  if not name or type(fn) ~= "function" then
    return
  end
  CLEANUP_HOOKS[tostring(name)] = fn
end

function addRenderStep(name, priority, callback)
  if type(callback) ~= "function" then
    return
  end
  local bindName = "NX_" .. tostring(name):gsub("[^%w_]", "_")
  pcall(function()
    RunService:UnbindFromRenderStep(bindName)
  end)
  RunService:BindToRenderStep(bindName, priority or Enum.RenderPriority.Last.Value, callback)
  addConnection(name, {
    Disconnect = function()
      pcall(function()
        RunService:UnbindFromRenderStep(bindName)
      end)
    end,
  })
end

addConnection(
  "camera",
  workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    while RUNNING and not workspace.CurrentCamera do
      task.wait()
    end
    Camera = workspace.CurrentCamera
  end)
)

cleanup = function()
  RUNNING = false
  for _, fn in pairs(CLEANUP_HOOKS) do
    pcall(fn)
  end
  CLEANUP_HOOKS = {}
  pcall(cleanAllESP)
  pcall(restoreDeviceSpoof)
  pcall(function()
    if setFB then
      setFB(false)
    end
  end)
  pcall(function()
    if setNF then
      setNF(false)
    end
  end)
  pcall(function()
    if setFPS then
      setFPS(false)
    end
  end)
  pcall(function()
    if setFPSBoost then
      setFPSBoost(false)
    end
  end)
  pcall(clearStreamerNameTextPatches)
  pcall(function()
    if UI_WINDOW and UI_WINDOW.Destroy then
      UI_WINDOW:Destroy()
    end
    UI_WINDOW = nil
  end)
  for _, conn in pairs(CONNECTIONS) do
    pcall(function()
      conn:Disconnect()
    end)
  end
  CONNECTIONS = {}

  pcall(function()
    if getgenv then
      local gv = getgenv()
      if __nxBootActive() then
        if gv.NX_FOV then
          pcall(function()
            gv.NX_FOV:Remove()
          end)
          gv.NX_FOV = nil
        end
        if gv.NX_FOV_GUI then
          pcall(function()
            gv.NX_FOV_GUI:Destroy()
          end)
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
        gv.NX_RUNTIME = nil
        gv.NX_BOOT_STAGE = nil
        gv.NX_BOOT_ERROR = nil
        gv.NX_BOOT_ID = nil
      end
    end
  end)
end

if getgenv and __nxBootActive() then
  getgenv().NX_CLEANUP = cleanup
end

--  STATE
local STATE = {
  AimLock = false,
  AimLockStrength = 86,
  AimLockFOV = 150,
  AimLockMaxDist = 300,
  AimLockRequireRMB = false,
  AimLockVisibleCheck = false,

  SilentAim = false,
  SilentAimMode = "No Hook",
  SilentAimFOVOnly = false,
  SilentAimAutoShoot = false,
  SilentAimAutoShootCPS = 8,
  NoHookMode = "ULTRA",
  AimFOV = 150,
  AimTeamCheck = true,
  AimFOVCircle = true,
  AimFOVHidden = false,
  AimFOVColor = "White",
  ReactiveFOV = false,
  AimRequireCenter = true,

  TriggerEnabled = false,
  TriggerDelay = 0,
  TriggerCPS = 8,
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
  ESPUpdateFPS = 30,
  ESPMaxPlayers = 16,
  ESPDrawingMode = false,

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
  StreamerNameChanger = false,
  StreamerName = "",

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
  BindTrigger = "None",
  BindESP = "None",
  BindBeggerFarm = "None",
  BindAutoBackstab = "None",
  BindNamesOrbit = "None",
  BindApplyControlMode = "None",
}

if getgenv and __nxBootActive() then
  getgenv().NX_STATE = STATE
end

local BIND_KEYS = {
  "BindToggleGUI",
  "BindFly",
  "BindAimLock",
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

function cleanStreamerName(value)
  if nameChangerApi and type(nameChangerApi.CleanName) == "function" then
    return nameChangerApi.CleanName(value)
  end
  return tostring(value or "")
end

function getClientPlayerDisplayName(player)
  if nameChangerApi and type(nameChangerApi.GetDisplayName) == "function" then
    return nameChangerApi.GetDisplayName(player)
  end
  if not player then
    return ""
  end
  return tostring(player.DisplayName or player.Name or "")
end

function getClientPlayerUsername(player)
  if nameChangerApi and type(nameChangerApi.GetUsername) == "function" then
    return nameChangerApi.GetUsername(player)
  end
  if not player then
    return ""
  end
  return tostring(player.Name or "")
end

function getClientPlayerLabel(player)
  if nameChangerApi and type(nameChangerApi.GetLabel) == "function" then
    return nameChangerApi.GetLabel(player)
  end
  local display = getClientPlayerDisplayName(player)
  local username = getClientPlayerUsername(player)
  if username == "" or string.lower(display) == string.lower(username) then
    return display ~= "" and display or username
  end
  return string.format("%s  (@%s)", display, username)
end

function setStreamerName(value)
  local clean = cleanStreamerName(value)
  if clean ~= "" then
    ensureFeatureLoaded("NameChanger")
  end
  if nameChangerApi and type(nameChangerApi.SetStreamerName) == "function" then
    return nameChangerApi.SetStreamerName(clean)
  end
  STATE.StreamerName = clean
  STATE.StreamerNameChanger = clean ~= ""
  return clean
end

local CONFIG_FOLDER = "NovaXConfigs"
local CONFIG_BASE_PATH = nil

if getgenv and __nxBootActive() then
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

--  GAME HELPERS (XENO-SAFE!)
function getChar()
  if not LocalPlayer then
    return nil
  end
  return LocalPlayer.Character
end

function getRoot()
  local char = getChar()
  if not char then
    return nil
  end
  -- WICHTIG: FindFirstChild statt WaitForChild!
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function getHumanoid()
  local char = getChar()
  if not char then
    return nil
  end
  return char:FindFirstChildOfClass("Humanoid")
end

function getTool()
  local char = getChar()
  if not char then
    return nil
  end
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
  if
    compact == "burstrifle"
    or compact == "bursrifle"
    or compact == "energypistol"
    or compact == "energypistols"
    or compact == "ernergypistol"
    or compact == "ernergypistols"
  then
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
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
      side = side - 1
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
      side = side + 1
    end
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

local teamResolverCache = {
  checkedAt = 0,
  mode = "none",
  key = nil,
  getter = nil,
  printed = false,
}

local TEAM_KEYWORDS = { "team", "faction", "side", "squad", "alliance", "allegiance", "camp", "clan" }
local STATIC_TEAM_KEYS = { "Team", "TeamId", "TeamID", "TeamIndex", "TeamName", "Faction", "Side", "Squad", "Alliance", "Allegiance", "Camp", "Clan" }

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
    if not name or name == "" or seen[name] then
      return
    end
    if not nameLooksTeamLike(name) then
      return
    end
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
      if not p then
        return nil
      end
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
      if not c then
        return nil
      end
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

local teamColorCache = { checkedAt = 0, value = false }
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

  local quickAttrKeys = { "TeamID", "TeamId", "Team", "Faction", "Side", "Squad" }
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

function getSelectablePlayers()
  if teleportApi and type(teleportApi.GetSelectablePlayers) == "function" then
    return teleportApi.GetSelectablePlayers()
  end
  return { "None" }
end

function rightClick()
  return sendMouseButton(1, MIN_RIGHT_CLICK_INTERVAL)
end

function isEnemy(player, teamCheck)
  if not player or player == LocalPlayer then
    return false
  end

  if teamCheck == false then
    return true
  end

  if isSameTeam(player, LocalPlayer) then
    return false
  end

  return true
end

function isAlive(player)
  if not player then
    return false
  end
  if not player.Character then
    return false
  end
  local hum = player.Character:FindFirstChildOfClass("Humanoid")
  if not hum then
    return false
  end
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

  if not success then
    return Vector2.new(0, 0), false
  end
  return Vector2.new(sp.X, sp.Y), os
end

function isMouseNearCenter(threshold)
  if not Camera then
    return false
  end

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
  if UserInputService:GetFocusedTextBox() then
    return false
  end
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
  if not bind then
    return false
  end

  if typeof(bind) == "EnumItem" and bind.EnumType == Enum.KeyCode then
    return input.KeyCode == bind
  end

  if typeof(bind) == "EnumItem" and bind.EnumType == Enum.UserInputType then
    return input.UserInputType == bind
  end

  return false
end

local roundStateCache = {
  value = false,
  checkedAt = 0,
  source = nil,
  sourceName = nil,
  confidence = "none",
  nextDeepScanAt = 0,
}

local NX_ROUND_STATE_NAMES = { "InRound", "RoundStarted", "RoundActive", "MatchStarted", "InMatch", "GameStarted" }
local NX_ROUND_STATE_CONTAINERS = { "GameState", "RoundState", "MatchState", "State", "Values", "ReplicatedValues", "Status" }
local NX_FEATURE_POLICY = {
  CombatOnly = {
    AimLock = true,
    TriggerBot = true,
    SilentAim = true,
    SilentAimAutoShoot = true,
    AutoBackstab = true,
    NamesOrbit = true,
  },
  LobbyAllowed = {
    UI = true,
    Configs = true,
    ESP = true,
    FOV = true,
    Movement = true,
    Spoof = true,
    BeggerFarm = true,
  },
}

function readRoundStateObject(obj)
  if not obj then
    return nil
  end

  if obj:IsA("BoolValue") then
    return obj.Value == true, "state"
  elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
    return obj.Value > 0, "state"
  elseif obj:IsA("StringValue") then
    local s = string.lower(tostring(obj.Value))
    if
      s:find("lobby")
      or s:find("intermission")
      or s:find("waiting")
      or s:find("queue")
      or s:find("matchmak")
      or s:find("menu")
      or s:find("voting")
      or s:find("select")
      or s:find("ended")
      or s:find("result")
    then
      return false, "state"
    end
    if s:find("round") or s:find("inmatch") or s:find("playing") or s:find("fight") or s:find("active") or s:find("started") then
      return true, "state"
    end
  end

  return nil
end

function scanRoundStateRootShallow(rootObj)
  if not rootObj then
    return nil, nil
  end

  for _, name in ipairs(NX_ROUND_STATE_NAMES) do
    local obj = rootObj:FindFirstChild(name)
    local value, confidence = readRoundStateObject(obj)
    if value ~= nil then
      return obj, value, confidence
    end
  end

  for _, containerName in ipairs(NX_ROUND_STATE_CONTAINERS) do
    local container = rootObj:FindFirstChild(containerName)
    if container then
      for _, name in ipairs(NX_ROUND_STATE_NAMES) do
        local obj = container:FindFirstChild(name)
        local value, confidence = readRoundStateObject(obj)
        if value ~= nil then
          return obj, value, confidence
        end
      end
    end
  end

  return nil, nil
end

function scanRoundStateRootDeep(rootObj)
  if not rootObj then
    return nil, nil
  end

  for _, name in ipairs(NX_ROUND_STATE_NAMES) do
    local ok, obj = pcall(function()
      return rootObj:FindFirstChild(name, true)
    end)
    if ok and obj then
      local value, confidence = readRoundStateObject(obj)
      if value ~= nil then
        return obj, value, confidence
      end
    end
  end

  return nil, nil
end

function resolveRoundStateSource(now)
  local source = roundStateCache.source
  if source and source.Parent then
    local value, confidence = readRoundStateObject(source)
    if value ~= nil then
      return source, value, confidence
    end
  end

  roundStateCache.source = nil
  roundStateCache.sourceName = nil
  roundStateCache.confidence = "none"

  local sourceObj, value, confidence = scanRoundStateRootShallow(ReplicatedStorage)
  if not sourceObj then
    sourceObj, value, confidence = scanRoundStateRootShallow(workspace)
  end

  if not sourceObj and now >= (roundStateCache.nextDeepScanAt or 0) then
    roundStateCache.nextDeepScanAt = now + 5
    sourceObj, value, confidence = scanRoundStateRootDeep(ReplicatedStorage)
    if not sourceObj then
      sourceObj, value, confidence = scanRoundStateRootDeep(workspace)
    end
  end

  if sourceObj and value ~= nil then
    roundStateCache.source = sourceObj
    roundStateCache.sourceName = sourceObj.Name
    roundStateCache.confidence = confidence or "state"
    return sourceObj, value, roundStateCache.confidence
  end

  return nil, nil
end

function isRoundStarted()
  local now = tick()
  if now - roundStateCache.checkedAt < 0.12 then
    return roundStateCache.value
  end

  roundStateCache.checkedAt = now

  local hum = getHumanoid()
  if not hum or hum.Health <= 0 then
    roundStateCache.value = false
    roundStateCache.confidence = "none"
    return false
  end

  local source, sourceValue, confidence = resolveRoundStateSource(now)
  if source and sourceValue ~= nil then
    roundStateCache.value = sourceValue == true
    roundStateCache.confidence = confidence or "state"
    return roundStateCache.value
  end

  roundStateCache.value = false
  roundStateCache.confidence = "none"
  return false
end

function getRoundStateInfo()
  local active = isRoundStarted()
  return active, roundStateCache.confidence or "none", roundStateCache.sourceName
end

function isCombatFeatureAllowed(featureName)
  local policy = NX_FEATURE_POLICY
  local combatOnly = policy and policy.CombatOnly
  if combatOnly and combatOnly[tostring(featureName or "")] then
    return isRoundStarted() == true
  end
  return true
end

--  PLAYER CACHE
local cachedPlayers = {}
local function clearPlayerCacheTables()
  if table.clear then
    table.clear(cachedPlayers)
    return
  end
  for key in pairs(cachedPlayers) do
    cachedPlayers[key] = nil
  end
end

local function rebuildPlayerCache()
  clearPlayerCacheTables()
  local success, result = pcall(function()
    return Players:GetPlayers()
  end)

  if success and type(result) == "table" then
    for _, player in ipairs(result) do
      cachedPlayers[#cachedPlayers + 1] = player
    end
  end
end

function updateCache()
  if #cachedPlayers == 0 then
    rebuildPlayerCache()
  end
  return cachedPlayers
end

addConnection(
  "cache_player_added",
  Players.PlayerAdded:Connect(function(player)
    if player then
      for _, cached in ipairs(cachedPlayers) do
        if cached == player then
          return
        end
      end
      cachedPlayers[#cachedPlayers + 1] = player
    end
  end)
)

addConnection(
  "cache_player_removed",
  Players.PlayerRemoving:Connect(function(player)
    if player then
      for index = #cachedPlayers, 1, -1 do
        if cachedPlayers[index] == player then
          table.remove(cachedPlayers, index)
          break
        end
      end
    end
  end)
)

rebuildPlayerCache()

--  VISIBILITY
function isVisible(part)
  if not part or not part.Parent or not Camera then
    return false
  end

  local success, result = pcall(function()
    local origin = Camera.CFrame.Position
    local diff = part.Position - origin
    local dist = diff.Magnitude
    if dist == 0 then
      return true
    end
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

    if not rayResult then
      return true
    end
    return rayResult.Instance == part or rayResult.Instance:IsDescendantOf(part.Parent)
  end)

  return success and result or false
end

local visCache = {}

function resetVisibilityCache()
  if table.clear then
    table.clear(visCache)
  else
    visCache = {}
  end
end

function isVisibleCached(part)
  if not part then
    return false
  end

  if visCache[part] ~= nil then
    return visCache[part]
  end

  local result = isVisible(part)
  visCache[part] = result
  return result
end

--  COMBAT TARGETING
local silentAimResetHook = nil
local updateFOV = function() end
local function registerFOVUpdater(callback)
  updateFOV = type(callback) == "function" and callback or function() end
end

--  TELEPORT + AUTO BACKSTAB
local tpDropdownRef = nil

function setTPPlayer(value)
  ensureFeatureLoaded("Teleport")
  if teleportApi and type(teleportApi.SetTarget) == "function" then
    return teleportApi.SetTarget(value)
  end
  STATE.TPPlayer = type(value) == "table" and tostring(value[1] or "") or tostring(value or "")
  if STATE.TPPlayer == "None" then
    STATE.TPPlayer = ""
  end
  return STATE.TPPlayer
end

function refreshTPDropdown()
  if not tpDropdownRef then
    return
  end
  if teleportApi and type(teleportApi.RefreshDropdown) == "function" then
    return teleportApi.RefreshDropdown(tpDropdownRef)
  end
  return false
end

function teleportNearSelected(behind)
  ensureFeatureLoaded("Teleport")
  if teleportApi and type(teleportApi.TeleportNear) == "function" then
    return teleportApi.TeleportNear(behind)
  end
  notify("TP", "Teleport-Modul ist noch nicht bereit", 2)
  return false
end

function teleportUpSelected()
  ensureFeatureLoaded("Teleport")
  if teleportApi and type(teleportApi.TeleportUp) == "function" then
    return teleportApi.TeleportUp()
  end
  notify("TP", "Teleport-Modul ist noch nicht bereit", 2)
  return false
end

function backstabOnce()
  ensureFeatureLoaded("Backstab")
  if backstabApi and type(backstabApi.BackstabOnce) == "function" then
    return backstabApi.BackstabOnce()
  end
  notify("Backstab", "Backstab-Modul ist noch nicht bereit", 2)
  return false
end
local GUI_READY = false
local stateControlRefs = {}
local aimLockToggleRef, silentToggleRef = nil, nil
local combatModeSyncing = false
local featureNoticeAt = {}
local featureUnavailable
featureUnavailable = function(name, reason)
  local key = tostring(name or "Feature") .. ":" .. tostring(reason or "")
  local now = tick()
  if featureNoticeAt[key] and now - featureNoticeAt[key] < 7 then
    return
  end
  featureNoticeAt[key] = now
  nxWarn("[NovaX] " .. tostring(name or "Feature") .. ": " .. tostring(reason or "nicht verfuegbar"))
end

local lazyFeatureSpecs = {}
local lazyFeatureStatus = {}

local function lazyFeatureKey(value)
  return tostring(value or ""):gsub("%s+", ""):gsub("[^%w_%-]", ""):lower()
end

local function storeLazyFeatureAlias(spec, alias)
  local key = lazyFeatureKey(alias)
  if key ~= "" then
    lazyFeatureSpecs[key] = spec
  end
end

registerLazyFeatures = function(category, features)
  local registered = {}
  if type(features) ~= "table" then
    return registered
  end

  for _, rawSpec in ipairs(features) do
    if type(rawSpec) == "table" then
      local name = tostring(rawSpec.Name or rawSpec.RepoKey or "")
      local repoKey = tostring(rawSpec.RepoKey or name)
      if name ~= "" and repoKey ~= "" then
        local spec = table.clone(rawSpec)
        spec.Name = name
        spec.RepoKey = repoKey
        spec.Category = tostring(rawSpec.Category or category or "unknown")
        spec.Path = tostring(rawSpec.Path or "init.lua")
        storeLazyFeatureAlias(spec, name)
        storeLazyFeatureAlias(spec, repoKey)
        registered[#registered + 1] = name
        if spec.AutoStart == true then
          task.defer(function()
            ensureFeatureLoaded(name)
          end)
        end
      end
    end
  end

  return registered
end

ensureFeatureLoaded = function(name)
  local key = lazyFeatureKey(name)
  local spec = lazyFeatureSpecs[key]
  if not spec then
    featureUnavailable(name, "Feature ist noch nicht im Lazy-Loader registriert.")
    return false
  end

  local statusKey = lazyFeatureKey(spec.Name)
  local status = lazyFeatureStatus[statusKey]
  if status == "started" then
    return true
  end
  if status == "starting" then
    return true
  end

  if not __nxBootActive() then
    return false
  end
  if type(__NX_CONTEXT.LoadRepo) ~= "function" or type(__NX_CONTEXT.Repos) ~= "table" then
    featureUnavailable(spec.Name, "Loader-Kontext fehlt.")
    return false
  end

  local repo = __NX_CONTEXT.Repos[spec.RepoKey]
  if not repo then
    featureUnavailable(spec.Name, "Repo fehlt: " .. tostring(spec.RepoKey))
    return false
  end

  lazyFeatureStatus[statusKey] = "starting"
  __NX_CONTEXT.Runtime = NXRuntime or __NX_CONTEXT.Runtime
  local ok, result = pcall(function()
    if type(__NX_CONTEXT.AssertBootActive) == "function" then
      __NX_CONTEXT.AssertBootActive()
    end
    local feature = __NX_CONTEXT.LoadRepo(repo, spec.Path or "init.lua", __NX_CONTEXT)
    if type(__NX_CONTEXT.AssertBootActive) == "function" then
      __NX_CONTEXT.AssertBootActive()
    end
    if type(feature) == "table" and type(feature.Start) == "function" then
      return feature.Start(__NX_CONTEXT)
    end
    return feature ~= false
  end)

  if ok and result ~= false then
    lazyFeatureStatus[statusKey] = "started"
    return true
  end

  lazyFeatureStatus[statusKey] = nil
  featureUnavailable(spec.Name, tostring(result))
  return false
end

local function ensureFeatureForToggle(featureName, enabled, stateKey)
  if enabled ~= true then
    return true
  end
  local ok = ensureFeatureLoaded(featureName)
  if not ok and stateKey and STATE[stateKey] ~= nil then
    STATE[stateKey] = false
  end
  return ok
end

local function ensureFeaturesForCurrentState()
  ensureFeatureForToggle("AimLock", STATE.AimLock, "AimLock")
  ensureFeatureForToggle("TriggerBot", STATE.TriggerEnabled, "TriggerEnabled")
  ensureFeatureForToggle("SilentAim", STATE.SilentAim, "SilentAim")
  ensureFeatureForToggle("FOV", STATE.AimFOVCircle == true and STATE.AimFOVHidden ~= true)
  ensureFeatureForToggle("ESP", STATE.ESPEnabled, "ESPEnabled")
  ensureFeatureForToggle("Speed", STATE.SpeedEnabled, "SpeedEnabled")
  ensureFeatureForToggle("Fly", STATE.FlyEnabled, "FlyEnabled")
  ensureFeatureForToggle("NoClip", STATE.NoClip, "NoClip")
  ensureFeatureForToggle("InfJump", STATE.InfJump, "InfJump")
  ensureFeatureForToggle("BunnyHop", STATE.BunnyHop, "BunnyHop")
  ensureFeatureForToggle("AntiVoid", STATE.AntiVoid, "AntiVoid")
  ensureFeatureForToggle("AntiHit", STATE.AntiHit, "AntiHit")
  ensureFeatureForToggle("FullBright", STATE.FullBright, "FullBright")
  ensureFeatureForToggle("NoFog", STATE.NoFog, "NoFog")
  ensureFeatureForToggle("FPSUnlocker", STATE.FPSUnlocker, "FPSUnlocker")
  ensureFeatureForToggle("FPSBoost", STATE.FPSBoost, "FPSBoost")
  ensureFeatureForToggle("ControlSpoof", STATE.MobileSpoof or STATE.ConsoleSpoof or STATE.VRSpoof)
  ensureFeatureForToggle("NameChanger", STATE.StreamerNameChanger or tostring(STATE.StreamerName or "") ~= "")
  ensureFeatureForToggle("BeggerFarm", STATE.BeggerFarm, "BeggerFarm")
  ensureFeatureForToggle("Backstab", STATE.AutoBackstab, "AutoBackstab")
  ensureFeatureForToggle("NamesOrbit", STATE.NamesOrbit, "NamesOrbit")
end

local function setControlFromState(control, value)
  if control then
    pcall(function()
      if control.Set then
        control:Set(value)
      elseif control.SetValue then
        control:SetValue(value)
      end
    end)
  end
end
local function bindStateControl(key, control, sync)
  if not key or not control then
    return control
  end
  stateControlRefs[key] = stateControlRefs[key] or {}
  table.insert(stateControlRefs[key], { control = control, sync = sync })
  return control
end
local function syncStateControlsFromState()
  for key, refs in pairs(stateControlRefs) do
    for _, entry in ipairs(refs) do
      if entry.sync then
        pcall(entry.sync, STATE[key], entry.control)
      else
        setControlFromState(entry.control, STATE[key])
      end
    end
  end
end
local function setToggleValue(ref, value)
  if ref and ref.Set then
    pcall(function()
      ref:Set(value)
    end)
  end
end
local function setLazyFeatureToggle(featureName, stateKey, enabled)
  local active = enabled == true
  if active and not ensureFeatureLoaded(featureName) then
    active = false
  end
  STATE[stateKey] = active
  if active ~= (enabled == true) then
    task.defer(syncStateControlsFromState)
  end
  return active
end
local function ensureLazyFeatureWhen(featureName, condition)
  if condition == true then
    return ensureFeatureLoaded(featureName)
  end
  return true
end
local function ensureFOVWhenVisible()
  return ensureLazyFeatureWhen("FOV", STATE.AimFOVCircle == true and STATE.AimFOVHidden ~= true)
end
function resetSilentAimRuntime()
  if type(silentAimResetHook) == "function" then
    pcall(silentAimResetHook)
  end
end
function enforceNoHookMode()
  STATE.NoHookMode = "ULTRA"
end
function enforceAlwaysOnChecks()
  STATE.AimTeamCheck = true
  STATE.AimRequireCenter = true
  STATE.TriggerTeamCheck = true
  STATE.TriggerRequireCenter = true
  STATE.TriggerVisibleCheck = true
  STATE.FPSUnlocker = true
  STATE.InfJumpHeight = math.clamp(safeNum(STATE.InfJumpHeight), 28, 80)
end
function setSilentAimEnabled(enabled)
  setLazyFeatureToggle("SilentAim", "SilentAim", enabled)
  resetSilentAimRuntime()
  setToggleValue(silentToggleRef, STATE.SilentAim)
end
function applyExclusiveMode(modeName, enabled)
  if combatModeSyncing then
    return
  end
  combatModeSyncing = true
  local ok, err = pcall(function()
    if modeName == "SilentAim" then
      setSilentAimEnabled(enabled)
    end
  end)
  if not ok then
    nxWarn("[NovaX] Combat mode switch failed: " .. tostring(modeName) .. " -> " .. tostring(err))
  end
  setToggleValue(silentToggleRef, STATE.SilentAim)
  combatModeSyncing = false
end

function setAimLockEnabled(enabled)
  setLazyFeatureToggle("AimLock", "AimLock", enabled)
  setToggleValue(aimLockToggleRef, STATE.AimLock)
end

-- NovaX nutzt bewusst nur die echte NovaPremiumUI-Library.
-- Die alte Mini-Fallback-GUI wurde entfernt, weil sie die moderne Lib-API nicht exakt abbildet.
local function loadNovaUI()
  if type(NovaPremiumUI) == "table" and type(NovaPremiumUI.CreateWindow) == "function" then
    if getgenv and __nxBootActive() then
      getgenv().NovaPremiumUI = NovaPremiumUI
    end
    return NovaPremiumUI
  end

  if getgenv and type(getgenv().NovaPremiumUI) == "table" and type(getgenv().NovaPremiumUI.CreateWindow) == "function" then
    return getgenv().NovaPremiumUI
  end

  return nil, "NovaPremiumUI nicht verfuegbar"
end

local GUI_BOOT_ERROR = nil
local Rayfield = nil
local Win = nil
local guiHoverBlockUntil = 0

local function pointInGuiObject(guiObject, point)
  if not guiObject or not guiObject.Parent then
    return false
  end
  if guiObject:IsA("GuiObject") and guiObject.Visible == false then
    return false
  end
  local pos = guiObject.AbsolutePosition
  local size = guiObject.AbsoluteSize
  return point.X >= pos.X and point.Y >= pos.Y and point.X <= pos.X + size.X and point.Y <= pos.Y + size.Y
end

function isNovaXGuiHoverBlocking()
  if UserInputService:GetFocusedTextBox() then
    return true
  end
  if not Win or not Win.Gui or Win.Gui.Enabled == false then
    return false
  end

  local okMouse, mousePos = pcall(function()
    return UserInputService:GetMouseLocation()
  end)
  if not okMouse or not mousePos then
    return false
  end

  local point = Vector2.new(mousePos.X, mousePos.Y)
  local overGui = false
  pcall(function()
    if GuiService and GuiService.GetGuiObjectsAtPosition then
      for _, obj in ipairs(GuiService:GetGuiObjectsAtPosition(point.X, point.Y)) do
        if obj and obj:IsDescendantOf(Win.Gui) then
          overGui = true
          break
        end
      end
    end
  end)

  if not overGui and Win.Shell then
    local isOpen = true
    pcall(function()
      if Win.IsOpen then
        isOpen = Win:IsOpen()
      end
    end)
    overGui = isOpen and pointInGuiObject(Win.Shell, point)
  end

  local now = tick()
  if overGui then
    guiHoverBlockUntil = now + 0.1
    return true
  end
  return now < guiHoverBlockUntil
end

function pauseCombatForGuiHover()
  return true
end

local function NX_BootGUI()
  local uiLoadError, _winError
  Rayfield, uiLoadError = loadNovaUI()
  Win = nil
  GUI_READY = false

  if Rayfield and type(Rayfield.CreateWindow) == "function" then
    if getgenv and __nxBootActive() then
      getgenv().NX_BOOT_STAGE = "CreateWindow"
    end
    GUI_READY, _winError = pcall(function()
      Win = Rayfield:CreateWindow({
        Name = "NovaX",
        Title = "NovaX",
        LoadingTitle = "NovaX",
        LoadingSubtitle = "Xeno",
        Subtitle = "Xeno control panel",
        LogoRingImage = {
          "_assets/novax_logo_ring_transparent.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/_assets/novax_logo_ring_transparent.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\_assets\\novax_logo_ring_transparent.png",
          "https://raw.githubusercontent.com/y5gc8zpdwh-droid/novax-rivals-assets/main/novax_logo_ring_transparent.png",
        },
        LogoImage = {
          "_assets/novax_logo_transparent.png",
          "C:/Users/User/OneDrive/Neuer Ordner 1/_assets/novax_logo_transparent.png",
          "C:\\Users\\User\\OneDrive\\Neuer Ordner 1\\_assets\\novax_logo_transparent.png",
          "https://raw.githubusercontent.com/y5gc8zpdwh-droid/novax-rivals-assets/main/novax_logo_transparent.png",
        },
        ShowWelcome = false,
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
        SettingsInputs = {
          {
            Key = "StreamerName",
            Label = "Name Changer",
            Placeholder = LocalPlayer and tostring(LocalPlayer.Name or "Streamer") or "Streamer",
            Value = STATE.StreamerName,
            Callback = function(value)
              setStreamerName(value)
            end,
          },
        },
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
  if getgenv and __nxBootActive() then
    local gv = getgenv()
    gv.NX_BOOT_STAGE = GUI_READY and "GUI_READY" or "GUI_FAILED"
    if GUI_READY then
      gv.NX_BOOT_ERROR = nil
    else
      gv.NX_BOOT_ERROR = tostring(GUI_BOOT_ERROR or "unknown")
    end
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

local NX_CONFIG_SYNC = nil

local function NX_BuildGUI()
  if not GUI_READY then
    return
  end

  local CT = Win:CreateTab("Kampf", 4483345998)

  CT:CreateSection("AimLock")
  do
    local c = createExpandableToggleControl(CT, {
      Name = "AimLock",
      CurrentValue = STATE.AimLock,
      Expanded = false,
      Callback = function(v)
        setAimLockEnabled(v)
      end,
    })
    aimLockToggleRef = bindStateControl("AimLock", c)
    bindStateControl(
      "AimLockRequireRMB",
      c:CreateToggle({
        Name = "Nur mit Rechtsklick",
        CurrentValue = STATE.AimLockRequireRMB,
        Callback = function(v)
          STATE.AimLockRequireRMB = v == true
        end,
      })
    )
    bindStateControl(
      "AimLockStrength",
      c:CreateSlider({
        Name = "Lock-Staerke",
        Range = { 1, 100 },
        Increment = 1,
        CurrentValue = STATE.AimLockStrength,
        Callback = function(v)
          STATE.AimLockStrength = math.clamp(safeNum(v), 1, 100)
        end,
      })
    )
    bindStateControl(
      "AimLockFOV",
      c:CreateSlider({
        Name = "Ziel-FOV",
        Range = { 20, 500 },
        Increment = 5,
        CurrentValue = STATE.AimLockFOV,
        Callback = function(v)
          STATE.AimLockFOV = math.clamp(safeNum(v), 20, 500)
        end,
      })
    )
    bindStateControl(
      "AimLockMaxDist",
      c:CreateSlider({
        Name = "Max. Distanz",
        Range = { 50, 2000 },
        Increment = 25,
        CurrentValue = STATE.AimLockMaxDist,
        Callback = function(v)
          STATE.AimLockMaxDist = math.clamp(safeNum(v), 50, 2000)
        end,
      })
    )
    bindStateControl(
      "AimLockVisibleCheck",
      c:CreateToggle({
        Name = "Sichtpruefung",
        CurrentValue = STATE.AimLockVisibleCheck,
        Callback = function(v)
          STATE.AimLockVisibleCheck = v == true
        end,
      })
    )
  end

  CT:CreateSection("Trigger")
  do
    local c = createExpandableToggleControl(CT, {
      Name = "Triggerbot",
      CurrentValue = STATE.TriggerEnabled,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("TriggerBot", "TriggerEnabled", v)
      end,
    })
    bindStateControl("TriggerEnabled", c)
    bindStateControl(
      "TriggerDelay",
      c:CreateSlider({
        Name = "Verzoegerung ms",
        Range = { 0, 250 },
        Increment = 5,
        CurrentValue = STATE.TriggerDelay,
        Callback = function(v)
          STATE.TriggerDelay = v
        end,
      })
    )
    bindStateControl(
      "TriggerCPS",
      c:CreateSlider({
        Name = "CPS",
        Range = { 1, MAX_TRIGGER_CPS },
        Increment = 1,
        CurrentValue = math.min(MAX_TRIGGER_CPS, math.max(1, STATE.TriggerCPS)),
        Callback = function(v)
          STATE.TriggerCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(v)))
        end,
      })
    )
  end

  do
    local c = createExpandableToggleControl(CT, {
      Name = "FOV",
      CurrentValue = STATE.AimFOVCircle,
      Expanded = false,
      Callback = function(v)
        STATE.AimFOVCircle = v == true
        ensureFOVWhenVisible()
        updateFOV()
      end,
    })
    bindStateControl("AimFOVCircle", c)
    bindStateControl(
      "AimFOV",
      c:CreateSlider({
        Name = "Radius",
        Range = { 20, 500 },
        Increment = 10,
        CurrentValue = STATE.AimFOV,
        Callback = function(v)
          STATE.AimFOV = v
          resetSilentAimRuntime()
          ensureFOVWhenVisible()
          updateFOV()
        end,
      })
    )
    bindStateControl(
      "AimFOVHidden",
      c:CreateToggle({
        Name = "FOV ausblenden",
        CurrentValue = STATE.AimFOVHidden,
        Callback = function(v)
          STATE.AimFOVHidden = v == true
          ensureFOVWhenVisible()
          updateFOV()
        end,
      })
    )
    bindStateControl(
      "ReactiveFOV",
      c:CreateToggle({
        Name = "Reaktiver FOV",
        CurrentValue = STATE.ReactiveFOV,
        Callback = function(v)
          STATE.ReactiveFOV = v == true
          ensureFOVWhenVisible()
          updateFOV()
        end,
      })
    )
    bindStateControl(
      "AimFOVColor",
      c:CreateOptionPicker({
        Name = "Farbe",
        Options = { "White", "Blue", "Cyan", "Green", "Yellow", "Red", "Pink" },
        Columns = 4,
        CurrentOption = { STATE.AimFOVColor },
        Callback = function(v)
          STATE.AimFOVColor = type(v) == "table" and v[1] or tostring(v)
          ensureFOVWhenVisible()
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
    bindStateControl(
      "SilentAimFOVOnly",
      c:CreateToggle({
        Name = "Nur im FOV",
        CurrentValue = STATE.SilentAimFOVOnly,
        Callback = function(v)
          STATE.SilentAimFOVOnly = v
          resetSilentAimRuntime()
        end,
      })
    )
    bindStateControl(
      "SilentAimAutoShoot",
      c:CreateToggle({
        Name = "Auto-Schuss bei Sicht",
        CurrentValue = STATE.SilentAimAutoShoot,
        Callback = function(v)
          STATE.SilentAimAutoShoot = v
          resetSilentAimRuntime()
        end,
      })
    )
    bindStateControl(
      "SilentAimAutoShootCPS",
      c:CreateSlider({
        Name = "Auto-Schuss CPS",
        Range = { 1, MAX_TRIGGER_CPS },
        Increment = 1,
        CurrentValue = math.min(MAX_TRIGGER_CPS, math.max(1, STATE.SilentAimAutoShootCPS)),
        Callback = function(v)
          STATE.SilentAimAutoShootCPS = math.min(MAX_TRIGGER_CPS, math.max(1, safeNum(v)))
        end,
      })
    )
    bindStateControl(
      "SilentAimMode",
      c:CreateOptionPicker({
        Name = "Modus",
        Options = { "No Hook" },
        Columns = 1,
        CurrentOption = { STATE.SilentAimMode },
        Callback = function()
          STATE.SilentAimMode = "No Hook"
          enforceNoHookMode()
          syncStateControlsFromState()
        end,
      }),
      function(_v, o)
        setControlFromState(o, "No Hook")
      end
    )
  end

  local ET = Win:CreateTab("ESP", 4483345998)
  for _, item in ipairs({
    { "ESPEnabled", "ESP" },
    { "ESPEnemy", "Gegner" },
    { "ESPTeam", "Team" },
    { "ESPHighlight", "Highlight" },
    { "ESPName", "Namen" },
    { "ESPHealth", "Leben" },
    { "ESPDistance", "Distanz" },
    { "ESPBox", "Boxen" },
    { "ESPSkeleton", "Skelett" },
  }) do
    bindStateControl(
      item[1],
      ET:CreateToggle({
        Name = item[2],
        CurrentValue = STATE[item[1]],
        Callback = function(v)
          if item[1] == "ESPEnabled" then
            setLazyFeatureToggle("ESP", "ESPEnabled", v)
          else
            STATE[item[1]] = v == true
            ensureLazyFeatureWhen("ESP", STATE.ESPEnabled == true)
          end
          if (item[1] == "ESPEnabled" or item[1] == "ESPHighlight") and STATE[item[1]] ~= true then
            cleanAllESP()
          end
        end,
      })
    )
  end
  bindStateControl(
    "ESPBoxScale",
    ET:CreateSlider({
      Name = "Box-Groesse",
      Range = { 30, 70 },
      Increment = 1,
      CurrentValue = STATE.ESPBoxScale,
      Callback = function(v)
        STATE.ESPBoxScale = v
      end,
    })
  )
  bindStateControl(
    "ESPMaxDistance",
    ET:CreateSlider({
      Name = "Max. Distanz",
      Range = { 50, 2000 },
      Increment = 25,
      CurrentValue = STATE.ESPMaxDistance,
      Callback = function(v)
        STATE.ESPMaxDistance = v
      end,
    })
  )

  local MT = Win:CreateTab("Bewegung", 4483345998)
  do
    local c = createExpandableToggleControl(MT, {
      Name = "Geschwindigkeit",
      CurrentValue = STATE.SpeedEnabled,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("Speed", "SpeedEnabled", v)
      end,
    })
    bindStateControl("SpeedEnabled", c)
    local speedSlider = createNestedSliderControl(c, MT, {
      Name = "Speed-Wert",
      Range = { 16, 200 },
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
      Name = "Fliegen",
      CurrentValue = STATE.FlyEnabled,
      Expanded = false,
      Callback = function(v)
        local active = setLazyFeatureToggle("Fly", "FlyEnabled", v)
        if not active then
          STATE.FlyToggle = false
        end
      end,
    })
    bindStateControl("FlyEnabled", c)
    local flySpeedSlider = createNestedSliderControl(c, MT, {
      Name = "Flugtempo",
      Range = { 16, 200 },
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
      Name = "Anti-Hit",
      CurrentValue = STATE.AntiHit,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("AntiHit", "AntiHit", v)
      end,
    })
    bindStateControl("AntiHit", c)
    bindStateControl(
      "AntiHitMode",
      c:CreateOptionPicker({
        Name = "Modus",
        Options = { "Adaptive Jitter", "Orbital Drift", "Head Orbit", "Vector Chaos" },
        Columns = 2,
        CurrentOption = { STATE.AntiHitMode },
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
        Name = "Geschwindigkeit",
        Range = { 4, 120 },
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
    bindStateControl(
      "AntiHitExperimental",
      c:CreateToggle({
        Name = "Experimentelle Pose",
        CurrentValue = STATE.AntiHitExperimental,
        Callback = function(v)
          STATE.AntiHitExperimental = v
        end,
      })
    )
    bindStateControl(
      "AntiHitHitboxMode",
      c:CreateOptionPicker({
        Name = "Hitbox-Modus",
        Options = { "Off", "Compact Body", "Flat Body", "Thin Body" },
        Columns = 2,
        CurrentOption = { STATE.AntiHitHitboxMode },
        Callback = function(v)
          STATE.AntiHitHitboxMode = type(v) == "table" and v[1] or tostring(v)
        end,
      }),
      function(v, o)
        setControlFromState(o, tostring(v or "Off"))
      end
    )
    bindStateControl(
      "AntiHitHitboxScale",
      c:CreateSlider({
        Name = "Hitbox-Groesse",
        Range = { 25, 100 },
        Increment = 1,
        CurrentValue = STATE.AntiHitHitboxScale,
        Callback = function(v)
          STATE.AntiHitHitboxScale = math.clamp(safeNum(v), 25, 100)
        end,
      })
    )
    bindStateControl(
      "AntiVoid",
      c:CreateToggle({
        Name = "Anti-Void",
        CurrentValue = STATE.AntiVoid,
        Callback = function(v)
          setLazyFeatureToggle("AntiVoid", "AntiVoid", v)
        end,
      })
    )
  end

  do
    local c = createExpandableToggleControl(MT, {
      Name = "Infinite Jump",
      CurrentValue = STATE.InfJump,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("InfJump", "InfJump", v)
      end,
    })
    bindStateControl("InfJump", c)
    local jumpControls = (c and c.CreateSlider) and c or MT
    bindStateControl(
      "BunnyHop",
      jumpControls:CreateToggle({
        Name = "Bunny Hop",
        CurrentValue = STATE.BunnyHop,
        Callback = function(v)
          setLazyFeatureToggle("BunnyHop", "BunnyHop", v)
        end,
      })
    )
    bindStateControl(
      "InfJumpHeight",
      jumpControls:CreateSlider({
        Name = "Sprunghoehe",
        Range = { 28, 80 },
        Increment = 1,
        CurrentValue = STATE.InfJumpHeight,
        Callback = function(v)
          STATE.InfJumpHeight = math.clamp(safeNum(v), 28, 80)
        end,
      })
    )
  end
  bindStateControl(
    "NoClip",
    MT:CreateToggle({
      Name = "NoClip",
      CurrentValue = STATE.NoClip,
      Callback = function(v)
        setLazyFeatureToggle("NoClip", "NoClip", v)
      end,
    })
  )

  local TT = Win:CreateTab("Teleport", 4483345998)
  do
    local c = createExpandableToggleControl(TT, {
      Name = "Auto-Backstab",
      CurrentValue = STATE.AutoBackstab,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("Backstab", "AutoBackstab", v)
      end,
    })
    bindStateControl("AutoBackstab", c)
    bindStateControl(
      "AutoBackstabInterval",
      c:CreateSlider({
        Name = "Intervall ms",
        Range = { 80, 1000 },
        Increment = 10,
        CurrentValue = STATE.AutoBackstabInterval,
        Callback = function(v)
          STATE.AutoBackstabInterval = v
        end,
      })
    )
    bindStateControl(
      "AutoBackstabRandomize",
      c:CreateToggle({
        Name = "Zufall",
        CurrentValue = STATE.AutoBackstabRandomize,
        Callback = function(v)
          STATE.AutoBackstabRandomize = v
        end,
      })
    )
    bindStateControl(
      "AutoBackstabRandomMin",
      c:CreateSlider({
        Name = "Zufall Min",
        Range = { 50, 1000 },
        Increment = 10,
        CurrentValue = STATE.AutoBackstabRandomMin,
        Callback = function(v)
          STATE.AutoBackstabRandomMin = v
        end,
      })
    )
    bindStateControl(
      "AutoBackstabRandomMax",
      c:CreateSlider({
        Name = "Zufall Max",
        Range = { 50, 1500 },
        Increment = 10,
        CurrentValue = STATE.AutoBackstabRandomMax,
        Callback = function(v)
          STATE.AutoBackstabRandomMax = v
        end,
      })
    )
  end

  do
    local c = createExpandableToggleControl(TT, {
      Name = "Namens-Orbit",
      CurrentValue = STATE.NamesOrbit,
      Expanded = false,
      Callback = function(v)
        setLazyFeatureToggle("NamesOrbit", "NamesOrbit", v)
      end,
    })
    bindStateControl("NamesOrbit", c)
    bindStateControl(
      "NamesOrbitInterval",
      c:CreateSlider({
        Name = "Intervall ms",
        Range = { 80, 800 },
        Increment = 10,
        CurrentValue = STATE.NamesOrbitInterval,
        Callback = function(v)
          STATE.NamesOrbitInterval = v
        end,
      })
    )
  end

  local createPlayerSelector = TT.CreatePlayerSearch
  tpDropdownRef = bindStateControl(
    "TPPlayer",
    createPlayerSelector(TT, {
      Name = "Zielspieler",
      Options = getSelectablePlayers(),
      CurrentOption = { "None" },
      PlaceholderText = "Spieler suchen...",
      ListHeight = 220,
      Callback = setTPPlayer,
    }),
    function(v, o)
      setControlFromState(o, v and v ~= "" and v or "None")
    end
  )
  TT.OnShow = function()
    ensureFeatureLoaded("Teleport")
    refreshTPDropdown()
  end
  bindStateControl(
    "TPDistance",
    TT:CreateSlider({
      Name = "TP-Distanz",
      Range = { 2, 20 },
      Increment = 1,
      CurrentValue = STATE.TPDistance,
      Callback = function(v)
        STATE.TPDistance = v
      end,
    })
  )
  TT:CreateButton({
    Name = "Zum Spieler",
    Callback = function()
      teleportNearSelected(false)
    end,
  })
  TT:CreateButton({
    Name = "Hinter Spieler",
    Callback = function()
      teleportNearSelected(true)
    end,
  })
  TT:CreateButton({
    Name = "Ueber Spieler",
    Callback = teleportUpSelected,
  })
  TT:CreateButton({ Name = "Backstab einmal", Callback = backstabOnce })

  local VT = Win:CreateTab("Sicht", 4483345998)
  bindStateControl(
    "FullBright",
    VT:CreateToggle({
      Name = "FullBright",
      CurrentValue = STATE.FullBright,
      Callback = function(v)
        local active = setLazyFeatureToggle("FullBright", "FullBright", v)
        setFB(active)
      end,
    })
  )
  bindStateControl(
    "NoFog",
    VT:CreateToggle({
      Name = "Kein Nebel",
      CurrentValue = STATE.NoFog,
      Callback = function(v)
        local active = setLazyFeatureToggle("NoFog", "NoFog", v)
        setNF(active)
      end,
    })
  )
  bindStateControl(
    "FPSBoost",
    VT:CreateToggle({
      Name = "FPS-Boost",
      CurrentValue = STATE.FPSBoost,
      Callback = function(v)
        local active = setLazyFeatureToggle("FPSBoost", "FPSBoost", v)
        setFPSBoost(active)
      end,
    })
  )

  local MST = Win:CreateTab("Extras", 4483345998)
  bindStateControl(
    "BeggerFarm",
    MST:CreateToggle({
      Name = "Begger Farm",
      CurrentValue = STATE.BeggerFarm,
      Callback = function(v)
        setLazyFeatureToggle("BeggerFarm", "BeggerFarm", v)
      end,
    })
  )

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
      if not ensureFeatureLoaded("ControlSpoof") then
        syncSpoofs()
        return
      end
      STATE[key] = true
    end
    syncSpoofs()
    applyDeviceSpoof()
  end

  spoofRefs.MobileSpoof = bindStateControl(
    "MobileSpoof",
    MST:CreateToggle({
      Name = "Mobile-Modus",
      CurrentValue = STATE.MobileSpoof,
      Callback = function(v)
        setSpoof("MobileSpoof", v)
      end,
    })
  )
  spoofRefs.ConsoleSpoof = bindStateControl(
    "ConsoleSpoof",
    MST:CreateToggle({
      Name = "Console-Modus",
      CurrentValue = STATE.ConsoleSpoof,
      Callback = function(v)
        setSpoof("ConsoleSpoof", v)
      end,
    })
  )
  spoofRefs.VRSpoof = bindStateControl(
    "VRSpoof",
    MST:CreateToggle({
      Name = "VR-Modus",
      CurrentValue = STATE.VRSpoof,
      Callback = function(v)
        setSpoof("VRSpoof", v)
      end,
    })
  )

  MST:CreateButton({
    Name = "Device-Modus zuruecksetzen",
    Callback = function()
      STATE.MobileSpoof = false
      STATE.ConsoleSpoof = false
      STATE.VRSpoof = false
      restoreDeviceSpoof()
      syncSpoofs()
    end,
  })

  local BT = Win:CreateTab("Tasten", 4483345998)
  local function makeBind(label, key)
    if BT.CreateKeybind then
      bindStateControl(
        key,
        BT:CreateKeybind({
          Name = label,
          CurrentKeybind = STATE[key],
          Callback = function(v)
            STATE[key] = normalizeSingleLetterBind(v)
          end,
        })
      )
    else
      BT:CreateButton({
        Name = label .. " einstellen",
        Callback = function()
          notify("Bind", "Bitte die Tasten-Seite nutzen", 2)
        end,
      })
    end
  end
  for _, b in ipairs({
    { "GUI anzeigen", "BindToggleGUI" },
    { "Fly umschalten", "BindFly" },
    { "AimLock umschalten", "BindAimLock" },
    { "Triggerbot umschalten", "BindTrigger" },
    { "ESP umschalten", "BindESP" },
    { "Begger Farm umschalten", "BindBeggerFarm" },
    { "Auto-Backstab umschalten", "BindAutoBackstab" },
    { "Namens-Orbit umschalten", "BindNamesOrbit" },
    { "Device-Modus anwenden", "BindApplyControlMode" },
  }) do
    makeBind(b[1], b[2])
  end

  NX_CONFIG_SYNC = function()
    enforceNoHookMode()
    enforceAlwaysOnChecks()
    normalizeAllBinds()
    ensureFeaturesForCurrentState()
    setFB(STATE.FullBright)
    setNF(STATE.NoFog)
    STATE.FPSUnlocker = true
    ensureFeatureLoaded("FPSUnlocker")
    setFPS(true)
    setFPSBoost(STATE.FPSBoost)
    applyDeviceSpoof()
    setStreamerName(STATE.StreamerName)
    if Win and type(Win.SetSettingsInput) == "function" then
      pcall(function()
        Win:SetSettingsInput("StreamerName", STATE.StreamerName)
      end)
    end
    syncStateControlsFromState()
    refreshTPDropdown()
  end

  addConnection(
    "input",
    UserInputService.InputBegan:Connect(function(i, gp)
      if gp then
        return
      end
      if inputMatchesBind(i, STATE.BindToggleGUI) and Win.Toggle then
        Win:Toggle()
      end
      if inputMatchesBind(i, STATE.BindFly) and STATE.FlyEnabled then
        if ensureFeatureLoaded("Fly") then
          STATE.FlyToggle = not STATE.FlyToggle
        else
          STATE.FlyEnabled = false
        end
      end
      if inputMatchesBind(i, STATE.BindAimLock) then
        setAimLockEnabled(not STATE.AimLock)
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindTrigger) then
        setLazyFeatureToggle("TriggerBot", "TriggerEnabled", not STATE.TriggerEnabled)
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindESP) then
        setLazyFeatureToggle("ESP", "ESPEnabled", not STATE.ESPEnabled)
        if not STATE.ESPEnabled then
          cleanAllESP()
        end
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindBeggerFarm) then
        setLazyFeatureToggle("BeggerFarm", "BeggerFarm", not STATE.BeggerFarm)
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindAutoBackstab) then
        setLazyFeatureToggle("Backstab", "AutoBackstab", not STATE.AutoBackstab)
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindNamesOrbit) then
        setLazyFeatureToggle("NamesOrbit", "NamesOrbit", not STATE.NamesOrbit)
        syncStateControlsFromState()
      end
      if inputMatchesBind(i, STATE.BindApplyControlMode) then
        ensureFeatureLoaded("ControlSpoof")
        applyDeviceSpoof()
      end
    end)
  )

  syncStateControlsFromState()
  refreshTPDropdown()
end

local NX_BUILD_OK, NX_BUILD_ERR = pcall(NX_BuildGUI)
if not NX_BUILD_OK then
  nxWarn("[NovaX] GUI Build Fehler: " .. tostring(NX_BUILD_ERR))
  notify("NovaX", "GUI Build Fehler: " .. tostring(NX_BUILD_ERR), 6)
  pcall(function()
    if Win and Win.Gui then
      Win.Gui.Enabled = true
    end
    if Win and Win.Shell then
      Win.Shell.Visible = true
    end
    if Win and Win.Root then
      Win.Root.Visible = true
      Win.Root.BackgroundTransparency = 0
    end
  end)
end
-- =============== NOVAX RAW MODULE RUNTIME API ===============
NXRuntime = {
  State = STATE,
  Warn = nxWarn,
  Services = {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    ReplicatedStorage = ReplicatedStorage,
  },
  SafeNum = safeNum,
  AddConnection = addConnection,
  AddCleanup = addCleanup,
  AddRenderStep = addRenderStep,
  RegisterFOVUpdater = registerFOVUpdater,
  RegisterSilentAimReset = function(callback)
    silentAimResetHook = type(callback) == "function" and callback or nil
  end,
  RegisterControlSpoofApi = function(api)
    controlSpoofApi = type(api) == "table" and api or nil
  end,
  RegisterBackstabApi = function(api)
    backstabApi = type(api) == "table" and api or nil
  end,
  RegisterESPApi = function(api)
    espApi = type(api) == "table" and api or nil
  end,
  RegisterTeleportApi = function(api)
    teleportApi = type(api) == "table" and api or nil
    if teleportApi and type(refreshTPDropdown) == "function" then
      pcall(refreshTPDropdown)
    end
  end,
  RegisterNameChangerApi = function(api)
    nameChangerApi = type(api) == "table" and api or nil
    if type(refreshTPDropdown) == "function" then
      pcall(refreshTPDropdown)
    end
  end,
  RegisterVisualEffect = function(name, callback)
    local key = tostring(name or "")
    if key == "" then
      return false
    end
    visualEffectHandlers[key] = type(callback) == "function" and callback or nil
    return true
  end,
  IsRunning = function()
    return RUNNING == true and __nxBootActive()
  end,
  GetCamera = function()
    return Camera
  end,
  GetLocalPlayer = function()
    return LocalPlayer
  end,
  GetChar = getChar,
  GetHumanoid = getHumanoid,
  GetRoot = getRoot,
  UpdateFOV = function()
    return updateFOV()
  end,
  RegisterLazyFeatures = registerLazyFeatures,
  EnsureFeatureLoaded = ensureFeatureLoaded,
  IsFeatureLoaded = function(name)
    local spec = lazyFeatureSpecs[lazyFeatureKey(name)]
    return spec ~= nil and lazyFeatureStatus[lazyFeatureKey(spec.Name)] == "started"
  end,
  GetLazyFeatureStatus = function()
    local out = {}
    for _, spec in pairs(lazyFeatureSpecs) do
      local name = tostring(spec.Name or "")
      if name ~= "" then
        out[name] = lazyFeatureStatus[lazyFeatureKey(name)] or "registered"
      end
    end
    return out
  end,
  Notify = notify,
  ApplyDeviceSpoof = applyDeviceSpoof,
  SetFPS = setFPS,
  SetFPSBoost = setFPSBoost,
  IsRoundStarted = isRoundStarted,
  UpdateCache = updateCache,
  IsAlive = isAlive,
  IsEnemy = isEnemy,
  WorldToScreen = worldToScreen,
  GetAimScreenCenter = getAimScreenCenter,
  IsCombatFeatureAllowed = isCombatFeatureAllowed,
  GetRoundStateInfo = getRoundStateInfo,
  IsNovaXGuiHoverBlocking = isNovaXGuiHoverBlocking,
  IsAimCenterGateOpen = isAimCenterGateOpen,
  PauseCombatForGuiHover = pauseCombatForGuiHover,
  ResetVisibilityCache = resetVisibilityCache,
  IsVisibleCached = isVisibleCached,
  Click = click,
  RightClick = rightClick,
  MaxTriggerCPS = MAX_TRIGGER_CPS,
  GetUI = function()
    return Rayfield
  end,
  GetWindow = function()
    return Win
  end,
  IsGUIReady = function()
    return GUI_READY == true
  end,
  GetConfigFolder = function()
    return getConfigDir()
  end,
  SyncAfterConfigLoad = function()
    if type(NX_CONFIG_SYNC) == "function" then
      return NX_CONFIG_SYNC()
    end
    return nil
  end,
  FeatureUnavailable = featureUnavailable,
  GetClientPlayerDisplayName = getClientPlayerDisplayName,
  GetClientPlayerUsername = getClientPlayerUsername,
  GetClientPlayerLabel = getClientPlayerLabel,
  RefreshTeleportDropdown = function()
    return refreshTPDropdown()
  end,
  CleanAllESP = function()
    return cleanAllESP()
  end,
  NotifyLoaded = function()
    ensureFeaturesForCurrentState()
    syncStateControlsFromState()
    notify("NovaX", "Bereit fuer Rivals", 3)
    if GUI_READY then
      notify("Tasten", "GUI: " .. tostring(STATE.BindToggleGUI or "K"), 2)
    else
      notify("NovaX", "Features laufen, GUI-Lib fehlt/fehlerhaft", 3)
    end
  end,
}

if getgenv and __nxBootActive() then
  getgenv().NX_RUNTIME = NXRuntime
end

return NXRuntime
