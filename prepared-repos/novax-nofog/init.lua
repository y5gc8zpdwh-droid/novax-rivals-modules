local Module = {
  Name = "novax.nofog",
  Kind = "feature",
  Path = "novax-nofog/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.nofog",
  StateKeys = { "NoFog" },
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
  if not state then
    error(Module.Name .. ": missing runtime state")
  end

  local lighting = game:GetService("Lighting")
  local defaultFogEnd = lighting.FogEnd

  local function apply(enabled)
    pcall(function()
      lighting.FogEnd = enabled and 1e9 or defaultFogEnd
    end)
    return true
  end

  if type(runtime.RegisterVisualEffect) == "function" then
    runtime.RegisterVisualEffect("NoFog", apply)
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      apply(false)
      started = false
      if type(runtime.RegisterVisualEffect) == "function" then
        runtime.RegisterVisualEffect("NoFog", nil)
      end
    end)
  end

  apply(state.NoFog == true)
  return true
end

return Module
