local Module = {
  Name = "novax.antivoid",
  Kind = "feature",
  Path = "novax-antivoid/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.antivoid",
  StateKeys = { "AntiVoid" },
}

local started = false
local nextRescueAt = 0

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
      if not runtime.IsRunning() or state.AntiVoid ~= true then
        return
      end
      local root = runtime.GetRoot()
      if not root then
        return
      end

      local killY = workspace.FallenPartsDestroyHeight
      local now = tick()
      if typeof(killY) == "number" and root.Position.Y <= killY + 35 and now >= nextRescueAt then
        nextRescueAt = now + 0.35
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
        root.CFrame = CFrame.new(root.Position.X, math.max(killY + 145, 45), root.Position.Z)
      end
    end)
  )

  return true
end

return Module
