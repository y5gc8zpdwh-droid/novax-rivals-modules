local Module = {
  Name = "novax.infjump",
  Kind = "feature",
  Path = "novax-infjump/init.lua",
  Category = "movement",
  RuntimeLoop = "movement.infjump",
  StateKeys = { "InfJump", "InfJumpHeight" },
}

local started = false
local lastJumpAt = 0

local function getJumpVelocity(runtime, state, hum)
  local configured = math.clamp(runtime.SafeNum(state.InfJumpHeight), 28, 80)
  if hum and hum.UseJumpPower == false then
    return math.max(28, configured)
  end
  return configured
end

local function performInfJump(runtime, state)
  if not runtime.IsRunning() or state.InfJump ~= true then
    return
  end
  local now = tick()
  if now - lastJumpAt < 0.12 then
    return
  end
  lastJumpAt = now

  local hum = runtime.GetHumanoid()
  local root = runtime.GetRoot()
  if not hum or hum.Health <= 0 then
    return
  end

  local jumpVelocity = getJumpVelocity(runtime, state, hum)
  hum.Jump = true
  hum:ChangeState(Enum.HumanoidStateType.Jumping)
  if root then
    local v = root.AssemblyLinearVelocity
    root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, jumpVelocity), v.Z)
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
  local input = runtime.Services and runtime.Services.UserInputService
  if not state or not input or type(runtime.AddConnection) ~= "function" then
    error(Module.Name .. ": missing runtime services")
  end

  runtime.AddConnection(
    "movement.infjump.request",
    input.JumpRequest:Connect(function()
      if input:IsKeyDown(Enum.KeyCode.Space) then
        return
      end
      performInfJump(runtime, state)
    end)
  )
  runtime.AddConnection(
    "movement.infjump.space",
    input.InputBegan:Connect(function(keyInput, gameProcessed)
      if gameProcessed then
        return
      end
      if keyInput.KeyCode == Enum.KeyCode.Space then
        performInfJump(runtime, state)
      end
    end)
  )

  return true
end

return Module
