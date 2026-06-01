local Module = {
  Name = "novax.fps_unlocker",
  Kind = "feature",
  Path = "novax-fps-unlocker/init.lua",
  Category = "visual",
  RuntimeLoop = "visual.fps_unlocker",
  StateKeys = { "FPSUnlocker" },
}

local started = false

local function apply(enabled)
  if typeof(setfpscap) == "function" then
    pcall(setfpscap, enabled and 240 or 60)
    return true
  end
  return false
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

  if type(runtime.RegisterVisualEffect) == "function" then
    runtime.RegisterVisualEffect("FPSUnlocker", apply)
  end

  if type(runtime.AddCleanup) == "function" then
    runtime.AddCleanup(Module.RuntimeLoop, function()
      apply(false)
      started = false
      if type(runtime.RegisterVisualEffect) == "function" then
        runtime.RegisterVisualEffect("FPSUnlocker", nil)
      end
    end)
  end

  local state = runtime.State
  apply(not state or state.FPSUnlocker ~= false)
  return true
end

return Module
