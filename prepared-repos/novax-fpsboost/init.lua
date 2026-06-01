local Module = {
  Name = "novax.fpsboost",
  Kind = "feature",
  Path = "novax-fpsboost/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.fpsboost",
  StateKeys = { "FPSBoost" },
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
  local lightingDefaults = {
    GlobalShadows = lighting.GlobalShadows,
  }
  local terrainDefaults = nil

  local function apply(enabled)
    pcall(function()
      lighting.GlobalShadows = enabled and false or lightingDefaults.GlobalShadows
      if settings and settings().Rendering then
        settings().Rendering.QualityLevel = enabled and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
      end

      local terrain = workspace:FindFirstChildOfClass("Terrain")
      if terrain then
        if not terrainDefaults then
          terrainDefaults = {
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency,
          }
        end

        terrain.WaterWaveSize = enabled and 0 or terrainDefaults.WaterWaveSize
        terrain.WaterWaveSpeed = enabled and 0 or terrainDefaults.WaterWaveSpeed
        terrain.WaterReflectance = enabled and 0 or terrainDefaults.WaterReflectance
        terrain.WaterTransparency = enabled and 1 or terrainDefaults.WaterTransparency
      end
    end)
    return true
  end

  if type(runtime.RegisterVisualEffect) == "function" then
    runtime.RegisterVisualEffect("FPSBoost", apply)
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      apply(false)
      started = false
      if type(runtime.RegisterVisualEffect) == "function" then
        runtime.RegisterVisualEffect("FPSBoost", nil)
      end
    end)
  end

  apply(state.FPSBoost == true)
  return true
end

return Module
