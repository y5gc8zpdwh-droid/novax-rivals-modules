local Module = {
  Name = "novax.name_changer",
  Kind = "feature",
  Path = "novax-name-changer/init.lua",
  Category = "misc",
  RuntimeLoop = "utility.name_changer",
  StateKeys = { "StreamerNameChanger", "StreamerName" },
}

local started = false
local textOriginal = setmetatable({}, { __mode = "k" })
local textConnections = setmetatable({}, { __mode = "k" })
local applying = false

local TEXT_CLASSES = {
  TextLabel = true,
  TextButton = true,
  TextBox = true,
}

local function escapeLuaPattern(value)
  return tostring(value or ""):gsub("([^%w])", "%%%1")
end

local function cleanName(value)
  local text = tostring(value or "")
  text = text:gsub("[%c\r\n\t]", " ")
  text = text:gsub("%s+", " ")
  text = text:gsub("^%s+", ""):gsub("%s+$", "")
  if #text > 32 then
    text = text:sub(1, 32)
  end
  return text
end

local function rawDisplayName(player)
  if not player then
    return ""
  end
  return tostring(player.DisplayName or player.Name or "")
end

local function rawUsername(player)
  if not player then
    return ""
  end
  return tostring(player.Name or "")
end

local function isActive(state)
  local alias = cleanName(state.StreamerName)
  return state.StreamerNameChanger == true and alias ~= "", alias
end

local function getDisplayName(runtime, state, player)
  local active, alias = isActive(state)
  if active and player == runtime.GetLocalPlayer() then
    return alias
  end
  return rawDisplayName(player)
end

local function getUsername(runtime, state, player)
  local active, alias = isActive(state)
  if active and player == runtime.GetLocalPlayer() then
    return alias
  end
  return rawUsername(player)
end

local function getLabel(runtime, state, player)
  local display = getDisplayName(runtime, state, player)
  local username = getUsername(runtime, state, player)
  if username == "" or string.lower(display) == string.lower(username) then
    return display ~= "" and display or username
  end
  return string.format("%s  (@%s)", display, username)
end

local function replaceLocalPlayerNameTokens(runtime, text, alias)
  local localPlayer = runtime.GetLocalPlayer()
  local out = tostring(text or "")
  if not localPlayer or not alias or alias == "" then
    return out
  end

  local username = tostring(localPlayer.Name or "")
  local displayName = tostring(localPlayer.DisplayName or "")
  if username ~= "" then
    out = out:gsub(escapeLuaPattern(username), alias)
  end
  if displayName ~= "" and displayName ~= username then
    out = out:gsub(escapeLuaPattern(displayName), alias)
  end
  return out
end

local function isTextObject(obj)
  return typeof(obj) == "Instance" and TEXT_CLASSES[obj.ClassName] == true
end

local applyTextObject
applyTextObject = function(runtime, state, obj, forceRestore)
  if not isTextObject(obj) then
    return
  end

  if not textConnections[obj] then
    local ok, conn = pcall(function()
      return obj:GetPropertyChangedSignal("Text"):Connect(function()
        if applying then
          return
        end
        textOriginal[obj] = obj.Text
        task.defer(function()
          if obj and obj.Parent then
            applyTextObject(runtime, state, obj, false)
          end
        end)
      end)
    end)
    if ok and conn then
      textConnections[obj] = conn
    end
  end

  local active, alias = isActive(state)
  if forceRestore or not active then
    local original = textOriginal[obj]
    if original ~= nil and obj.Parent then
      applying = true
      pcall(function()
        obj.Text = original
      end)
      applying = false
    end
    textOriginal[obj] = nil
    return
  end

  local baseText = textOriginal[obj] or obj.Text
  local replaced = replaceLocalPlayerNameTokens(runtime, baseText, alias)
  if replaced ~= baseText then
    textOriginal[obj] = baseText
    if obj.Text ~= replaced then
      applying = true
      pcall(function()
        obj.Text = replaced
      end)
      applying = false
    end
  end
end

local function scanRoot(runtime, state, root, forceRestore)
  if typeof(root) ~= "Instance" then
    return
  end

  local seen = 0
  for _, obj in ipairs(root:GetDescendants()) do
    if isTextObject(obj) then
      applyTextObject(runtime, state, obj, forceRestore == true)
      seen = seen + 1
      if seen % 250 == 0 then
        task.wait()
      end
    end
  end
end

local function refreshText(runtime, state, forceRestore)
  if forceRestore ~= true and not isActive(state) then
    return
  end

  task.spawn(function()
    local roots = {}
    local localPlayer = runtime.GetLocalPlayer()
    local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
      roots[#roots + 1] = playerGui
    end
    local okCore, coreGui = pcall(function()
      return game:GetService("CoreGui")
    end)
    if okCore and coreGui then
      roots[#roots + 1] = coreGui
    end
    if localPlayer and localPlayer.Character then
      roots[#roots + 1] = localPlayer.Character
    end

    for _, root in ipairs(roots) do
      pcall(scanRoot, runtime, state, root, forceRestore == true)
    end
  end)
end

local function clearText(runtime, state)
  for obj in pairs(textOriginal) do
    pcall(applyTextObject, runtime, state, obj, true)
  end
  for obj, conn in pairs(textConnections) do
    pcall(function()
      conn:Disconnect()
    end)
    textConnections[obj] = nil
  end
  textOriginal = setmetatable({}, { __mode = "k" })
end

local function setStreamerName(runtime, state, value)
  local clean = cleanName(value)
  local wasActive = state.StreamerNameChanger == true
  state.StreamerName = clean
  state.StreamerNameChanger = clean ~= ""
  refreshText(runtime, state, not state.StreamerNameChanger and wasActive)
  if type(runtime.RefreshTeleportDropdown) == "function" then
    runtime.RefreshTeleportDropdown()
  end
  return clean
end

local function watchRoot(runtime, state, name, root)
  if typeof(root) ~= "Instance" then
    return
  end
  local ok, conn = pcall(function()
    return root.DescendantAdded:Connect(function(obj)
      if isTextObject(obj) then
        task.defer(function()
          applyTextObject(runtime, state, obj, false)
        end)
      end
    end)
  end)
  if ok and conn then
    runtime.AddConnection("streamer_name." .. tostring(name), conn)
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
  if not state then
    error(Module.Name .. ": missing runtime state")
  end

  if type(runtime.RegisterNameChangerApi) == "function" then
    runtime.RegisterNameChangerApi({
      CleanName = cleanName,
      SetStreamerName = function(value)
        return setStreamerName(runtime, state, value)
      end,
      RefreshText = function(forceRestore)
        return refreshText(runtime, state, forceRestore)
      end,
      ApplyTextObject = function(obj, forceRestore)
        return applyTextObject(runtime, state, obj, forceRestore)
      end,
      Clear = function()
        return clearText(runtime, state)
      end,
      GetDisplayName = function(player)
        return getDisplayName(runtime, state, player)
      end,
      GetUsername = function(player)
        return getUsername(runtime, state, player)
      end,
      GetLabel = function(player)
        return getLabel(runtime, state, player)
      end,
    })
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      clearText(runtime, state)
      started = false
      if type(runtime.RegisterNameChangerApi) == "function" then
        runtime.RegisterNameChangerApi(nil)
      end
    end)
  end

  local localPlayer = runtime.GetLocalPlayer()
  local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
  watchRoot(runtime, state, "playergui", playerGui)
  if localPlayer then
    runtime.AddConnection(
      "streamer_name.playergui_watch",
      localPlayer.ChildAdded:Connect(function(child)
        if child and child:IsA("PlayerGui") then
          watchRoot(runtime, state, "playergui", child)
          refreshText(runtime, state, false)
        end
      end)
    )
    watchRoot(runtime, state, "character", localPlayer.Character)
    runtime.AddConnection(
      "streamer_name.character_watch",
      localPlayer.CharacterAdded:Connect(function(char)
        watchRoot(runtime, state, "character", char)
        refreshText(runtime, state, false)
      end)
    )
  end

  local okCore, coreGui = pcall(function()
    return game:GetService("CoreGui")
  end)
  if okCore then
    watchRoot(runtime, state, "coregui", coreGui)
  end

  if state.StreamerNameChanger == true and tostring(state.StreamerName or "") ~= "" then
    refreshText(runtime, state, false)
  end
  return true
end

return Module
