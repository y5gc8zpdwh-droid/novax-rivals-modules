local Module = {
  Name = "novax.noclip",
  Kind = "feature",
  Path = "novax-noclip/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.noclip",
  StateKeys = { "NoClip" },
}

local started = false
local originalCollide = {}
local trackedChar
local descendantConn

local function restoreNoClip()
  if descendantConn then
    pcall(function()
      descendantConn:Disconnect()
    end)
    descendantConn = nil
  end
  for part, oldValue in pairs(originalCollide) do
    if part and part.Parent then
      pcall(function()
        part.CanCollide = oldValue
      end)
    end
  end
  originalCollide = {}
  trackedChar = nil
end

local function setPartNoClip(part)
  if not part or not part:IsA("BasePart") then
    return
  end
  if originalCollide[part] == nil then
    originalCollide[part] = part.CanCollide
  end
  part.CanCollide = false
end

local function trackCharacter(char)
  if not char then
    restoreNoClip()
    return
  end
  if trackedChar == char then
    return
  end
  restoreNoClip()
  trackedChar = char
  for _, part in ipairs(char:GetDescendants()) do
    setPartNoClip(part)
  end
  descendantConn = char.DescendantAdded:Connect(setPartNoClip)
end

local function enforceTrackedParts()
  for part in pairs(originalCollide) do
    if part and part.Parent then
      if part.CanCollide ~= false then
        part.CanCollide = false
      end
    else
      originalCollide[part] = nil
    end
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
    runtime.AddCleanup(Module.RuntimeLoop, restoreNoClip)
  end

  runtime.AddConnection(
    Module.RuntimeLoop,
    runService.Heartbeat:Connect(function()
      if not runtime.IsRunning() then
        return
      end
      if state.NoClip ~= true then
        if trackedChar or next(originalCollide) ~= nil then
          restoreNoClip()
        end
        return
      end
      trackCharacter(runtime.GetChar())
      enforceTrackedParts()
    end)
  )

  return true
end

return Module
