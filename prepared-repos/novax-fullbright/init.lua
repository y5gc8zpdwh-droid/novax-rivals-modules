local Module = {
  Name = "novax.fullbright",
  Kind = "feature",
  Path = "novax-fullbright/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.fullbright",
  StateKeys = { "FullBright" },
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
  local defaults = {
    Brightness = lighting.Brightness,
    Ambient = lighting.Ambient,
    OutdoorAmbient = lighting.OutdoorAmbient,
  }

  local function apply(enabled)
    pcall(function()
      if enabled then
        lighting.Brightness = 2.5
        lighting.Ambient = Color3.new(1, 1, 1)
        lighting.OutdoorAmbient = Color3.new(1, 1, 1)
      else
        lighting.Brightness = defaults.Brightness
        lighting.Ambient = defaults.Ambient
        lighting.OutdoorAmbient = defaults.OutdoorAmbient
      end
    end)
    return true
  end

  if type(runtime.RegisterVisualEffect) == "function" then
    runtime.RegisterVisualEffect("FullBright", apply)
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      apply(false)
      started = false
      if type(runtime.RegisterVisualEffect) == "function" then
        runtime.RegisterVisualEffect("FullBright", nil)
      end
    end)
  end

  apply(state.FullBright == true)
  return true
end

return Module
