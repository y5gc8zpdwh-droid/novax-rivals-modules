local Module = {
  Name = "novax.teleport",
  Kind = "feature",
  Path = "novax-teleport/init.lua",
  Category = "misc",
  RuntimeLoop = "misc.teleport",
  StateKeys = { "TPPlayer", "TPDistance" },
}

local started = false

local function getPlayerRoot(player)
  local char = player and player.Character
  if not char then
    return nil
  end
  return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function playerLabel(runtime, player)
  if runtime and type(runtime.GetClientPlayerLabel) == "function" then
    return runtime.GetClientPlayerLabel(player)
  end
  if not player then
    return ""
  end
  local displayName = tostring(player.DisplayName or player.Name or "")
  local userName = tostring(player.Name or "")
  if displayName ~= "" and displayName ~= userName then
    return displayName .. " @" .. userName
  end
  return userName
end

local function displayName(runtime, player)
  if runtime and type(runtime.GetClientPlayerDisplayName) == "function" then
    return runtime.GetClientPlayerDisplayName(player)
  end
  return tostring(player and (player.DisplayName or player.Name) or "")
end

local function userName(runtime, player)
  if runtime and type(runtime.GetClientPlayerUsername) == "function" then
    return runtime.GetClientPlayerUsername(player)
  end
  return tostring(player and player.Name or "")
end

local function findPlayerByName(runtime, name)
  local services = runtime.Services
  local players = services and services.Players
  if not players or not name or name == "" or name == "None" then
    return nil
  end

  local raw = tostring(name)
  local extractedUser = raw:match("@([%w_]+)")
  local needle = string.lower(extractedUser or raw)
  local localPlayer = runtime.GetLocalPlayer()

  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
      local playerName = string.lower(tostring(player.Name or ""))
      local playerDisplay = string.lower(tostring(player.DisplayName or ""))
      local label = string.lower(playerLabel(runtime, player))
      if
        playerName == needle
        or playerDisplay == needle
        or label == needle
        or string.sub(playerName, 1, #needle) == needle
        or string.sub(playerDisplay, 1, #needle) == needle
      then
        return player
      end
    end
  end

  return nil
end

local function getSelectablePlayers(runtime)
  local services = runtime.Services
  local players = services and services.Players
  if not players then
    return { "None" }
  end

  local localPlayer = runtime.GetLocalPlayer()
  local list = {}
  for _, player in ipairs(players:GetPlayers()) do
    if player ~= localPlayer then
      list[#list + 1] = playerLabel(runtime, player)
    end
  end
  table.sort(list)
  if #list == 0 then
    list[1] = "None"
  end
  return list
end

local function setTarget(runtime, state, value)
  if type(value) == "table" then
    value = value[1]
  end
  if not value or value == "None" then
    state.TPPlayer = ""
    return ""
  end

  local matched = findPlayerByName(runtime, value)
  if matched then
    state.TPPlayer = matched.Name
  else
    state.TPPlayer = tostring(value)
  end
  return state.TPPlayer
end

local function refreshDropdown(runtime, state, dropdown)
  if not dropdown then
    return false
  end
  local options = getSelectablePlayers(runtime)

  pcall(function()
    if dropdown.Refresh then
      dropdown:Refresh(options)
    elseif dropdown.SetOptions then
      dropdown:SetOptions(options)
    end

    local selected = findPlayerByName(runtime, state.TPPlayer)
    local selectedLabel = selected and playerLabel(runtime, selected) or "None"
    if dropdown.Set then
      dropdown:Set(selectedLabel)
    end
  end)

  if not findPlayerByName(runtime, state.TPPlayer) then
    if options[1] ~= "None" then
      setTarget(runtime, state, options[1])
    else
      state.TPPlayer = ""
    end
  end
  return true
end

local function teleportToTargetRoot(runtime, state, targetRoot, behind)
  local myRoot = runtime.GetRoot()
  if not myRoot or not targetRoot then
    return false
  end

  local dist = math.max(1.5, runtime.SafeNum(state.TPDistance))
  local offset = behind and -(targetRoot.CFrame.LookVector * dist) or (targetRoot.CFrame.RightVector * dist)
  local dest = targetRoot.Position + offset
  myRoot.CFrame = CFrame.new(dest, targetRoot.Position)
  return true
end

local function teleportNearSelected(runtime, state, behind)
  local targetPlayer = findPlayerByName(runtime, state.TPPlayer)
  if not targetPlayer then
    runtime.Notify("TP", "Waehle zuerst einen Spieler", 2)
    return false
  end

  local targetRoot = getPlayerRoot(targetPlayer)
  if not targetRoot then
    runtime.Notify("TP", "Target hat keinen Root", 2)
    return false
  end

  runtime.RightClick()
  task.wait(0.02)
  local ok = teleportToTargetRoot(runtime, state, targetRoot, behind == true)
  if ok then
    runtime.Notify("TP", string.format("Zu %s (@%s) teleportiert", displayName(runtime, targetPlayer), userName(runtime, targetPlayer)), 1.5)
  end
  return ok
end

local function teleportUpSelected(runtime, state)
  local targetPlayer = findPlayerByName(runtime, state.TPPlayer)
  if not targetPlayer then
    runtime.Notify("TP", "Waehle zuerst einen Spieler", 2)
    return false
  end

  local targetRoot = getPlayerRoot(targetPlayer)
  if not targetRoot then
    runtime.Notify("TP", "Target hat keinen Root", 2)
    return false
  end

  local myRoot = runtime.GetRoot()
  if not myRoot then
    runtime.Notify("TP", "Eigener Root fehlt", 2)
    return false
  end

  local upDist = math.max(4, runtime.SafeNum(state.TPDistance) + 3)
  local upPos = targetRoot.Position + Vector3.new(0, upDist, 0)
  myRoot.CFrame = CFrame.new(upPos, targetRoot.Position)
  runtime.Notify("TP", string.format("Ueber %s (@%s) teleportiert", displayName(runtime, targetPlayer), userName(runtime, targetPlayer)), 1.5)
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

  if type(runtime.RegisterTeleportApi) == "function" then
    runtime.RegisterTeleportApi({
      GetSelectablePlayers = function()
        return getSelectablePlayers(runtime)
      end,
      SetTarget = function(value)
        return setTarget(runtime, state, value)
      end,
      RefreshDropdown = function(dropdown)
        return refreshDropdown(runtime, state, dropdown)
      end,
      TeleportNear = function(behind)
        return teleportNearSelected(runtime, state, behind)
      end,
      TeleportUp = function()
        return teleportUpSelected(runtime, state)
      end,
    })
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      started = false
      if type(runtime.RegisterTeleportApi) == "function" then
        runtime.RegisterTeleportApi(nil)
      end
    end)
  end

  return true
end

return Module
