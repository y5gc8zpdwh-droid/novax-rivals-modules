local Module = {
  Name = "novax.bunnyhop",
  Kind = "feature",
  Path = "novax-bunnyhop/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.bunnyhop",
  StateKeys = { "BunnyHop" },
}

local started = false

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

  runtime.AddConnection(
    Module.RuntimeLoop,
    runService.Heartbeat:Connect(function()
      if not runtime.IsRunning() or state.BunnyHop ~= true then
        return
      end
      local hum = runtime.GetHumanoid()
      if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
      end
    end)
  )

  return true
end

return Module
