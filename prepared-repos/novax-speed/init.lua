local Module = {
  Name = "novax.speed",
  Kind = "feature",
  Path = "novax-speed/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.speed",
  StateKeys = { "SpeedEnabled", "SpeedValue" },
}

local started = false
local speedVelocity

local function clearSpeed()
  if speedVelocity then
    pcall(function()
      speedVelocity:Destroy()
    end)
  end
  speedVelocity = nil
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
    runtime.AddCleanup(Module.RuntimeLoop, clearSpeed)
  end

  runtime.AddConnection(
    Module.RuntimeLoop,
    runService.Heartbeat:Connect(function()
      if not runtime.IsRunning() then
        return
      end
      if state.SpeedEnabled ~= true then
        clearSpeed()
        return
      end

      local root = runtime.GetRoot()
      local hum = runtime.GetHumanoid()
      if root and hum and hum.MoveDirection.Magnitude > 0.1 then
        if not speedVelocity or not speedVelocity.Parent then
          speedVelocity = Instance.new("BodyVelocity")
          speedVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
          speedVelocity.Parent = root
        end
        speedVelocity.Velocity = hum.MoveDirection * runtime.SafeNum(state.SpeedValue)
      else
        clearSpeed()
      end
    end)
  )

  return true
end

return Module
