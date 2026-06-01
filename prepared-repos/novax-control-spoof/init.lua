local Module = {
  Name = "novax.control_spoof",
  Kind = "feature",
  Path = "novax-control-spoof/init.lua",
  Category = "misc",
  RuntimeLoop = "utility.controlmode",
  StateKeys = { "MobileSpoof", "ConsoleSpoof", "VRSpoof" },
}

local started = false
local controlRemote = nil
local lastMode = "MouseKeyboard"
local lastSentAt = 0

local function normalizeMode(mode)
  local value = tostring(mode or "MouseKeyboard")
  if value == "Touch" or value == "Gamepad" or value == "MouseKeyboard" or value == "VR" then
    return value
  end

  value = string.lower(value)
  if value == "mobile" then
    return "Touch"
  end
  if value == "console" or value == "controller" then
    return "Gamepad"
  end
  if value == "vr" then
    return "VR"
  end
  return "MouseKeyboard"
end

local function selectedMode(state)
  if state.VRSpoof then
    return "VR"
  end
  if state.ConsoleSpoof then
    return "Gamepad"
  end
  if state.MobileSpoof then
    return "Touch"
  end
  return "MouseKeyboard"
end

local function getRemote(replica)
  if controlRemote and controlRemote.Parent then
    return controlRemote
  end

  local remotes = replica and replica:FindFirstChild("Remotes")
  local replication = remotes and remotes:FindFirstChild("Replication")
  local fighter = replication and replication:FindFirstChild("Fighter")
  local remote = fighter and fighter:FindFirstChild("SetControls")
  if remote and remote:IsA("RemoteEvent") then
    controlRemote = remote
    return remote
  end

  controlRemote = nil
  return nil
end

local function setGlobals(state)
  if not getgenv then
    return
  end

  local globals = getgenv()
  globals.NX_DEVICE_MOBILE = state.MobileSpoof == true
  globals.NX_DEVICE_CONSOLE = state.ConsoleSpoof == true
  globals.NX_DEVICE_VR = state.VRSpoof == true
end

local function clearGlobals()
  if not getgenv then
    return
  end

  local globals = getgenv()
  globals.NX_DEVICE_MOBILE = nil
  globals.NX_DEVICE_CONSOLE = nil
  globals.NX_DEVICE_VR = nil
end

local function fireMode(replica, modeOverride, forceSend)
  local mode = normalizeMode(modeOverride)
  local remote = getRemote(replica)
  if not remote then
    return false
  end

  local now = tick()
  if not forceSend and lastMode == mode and now - lastSentAt < 0.35 then
    return true
  end

  local ok = pcall(function()
    remote:FireServer(mode)
  end)
  if ok then
    lastMode = mode
    lastSentAt = now
  end
  return ok
end

local function restore(state, replica)
  state.SoftMobileSpoof = false
  state.SoftConsoleSpoof = false
  state.SoftVRSpoof = false
  clearGlobals()
  return fireMode(replica, "MouseKeyboard", true)
end

local function apply(state, replica)
  if not state.MobileSpoof and not state.ConsoleSpoof and not state.VRSpoof then
    return restore(state, replica)
  end

  setGlobals(state)
  return fireMode(replica, selectedMode(state), true)
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
  local replica = runtime.Services and runtime.Services.ReplicatedStorage
  if not state or not replica or type(runtime.RegisterControlSpoofApi) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  runtime.RegisterControlSpoofApi({
    Apply = function()
      return apply(state, replica)
    end,
    Restore = function()
      return restore(state, replica)
    end,
  })

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      restore(state, replica)
      runtime.RegisterControlSpoofApi(nil)
    end)
  end

  task.spawn(function()
    while runtime.IsRunning() do
      if state.MobileSpoof or state.ConsoleSpoof or state.VRSpoof then
        apply(state, replica)
      end
      task.wait(1)
    end
  end)

  return true
end

return Module
