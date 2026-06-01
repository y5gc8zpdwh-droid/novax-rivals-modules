local Module = {
  Name = "novax.fly",
  Kind = "feature",
  Path = "novax-fly/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.fly",
  StateKeys = { "FlyEnabled", "FlySpeed", "FlyToggle" },
}

local started = false
local flyVelocity
local flyGyro
local flyActive = false

local function stopFly(runtime)
  if flyVelocity then
    pcall(function()
      flyVelocity:Destroy()
    end)
  end
  if flyGyro then
    pcall(function()
      flyGyro:Destroy()
    end)
  end
  flyVelocity, flyGyro, flyActive = nil, nil, false
  local hum = runtime and runtime.GetHumanoid and runtime.GetHumanoid()
  if hum then
    pcall(function()
      hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
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
  local services = runtime.Services or {}
  local runService = services.RunService
  local input = services.UserInputService
  if not state or not runService or not input or type(runtime.AddConnection) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      stopFly(runtime)
    end)
  end

  runtime.AddConnection(
    Module.RuntimeLoop,
    runService.Heartbeat:Connect(function()
      if not runtime.IsRunning() then
        return
      end
      if not (state.FlyEnabled and state.FlyToggle) then
        if flyActive or flyVelocity or flyGyro then
          stopFly(runtime)
        end
        return
      end

      local root = runtime.GetRoot()
      local hum = runtime.GetHumanoid()
      local camera = runtime.GetCamera()
      if not root or not hum or not camera then
        stopFly(runtime)
        return
      end

      if not flyActive then
        flyActive = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        flyVelocity.Parent = root
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        flyGyro.Parent = root
      end

      local dir = Vector3.zero
      if input:IsKeyDown(Enum.KeyCode.W) then
        dir = dir + camera.CFrame.LookVector
      end
      if input:IsKeyDown(Enum.KeyCode.S) then
        dir = dir - camera.CFrame.LookVector
      end
      if input:IsKeyDown(Enum.KeyCode.A) then
        dir = dir - camera.CFrame.RightVector
      end
      if input:IsKeyDown(Enum.KeyCode.D) then
        dir = dir + camera.CFrame.RightVector
      end
      if input:IsKeyDown(Enum.KeyCode.Space) then
        dir = dir + Vector3.new(0, 1, 0)
      end
      if input:IsKeyDown(Enum.KeyCode.LeftShift) then
        dir = dir - Vector3.new(0, 1, 0)
      end

      flyVelocity.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * runtime.SafeNum(state.FlySpeed)
      flyGyro.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
    end)
  )

  return true
end

return Module
