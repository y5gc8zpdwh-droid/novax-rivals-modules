local Module = {
  Name = "novax.feature_loader",
  Kind = "final-feature-loader",
}

local function getRuntime(ctx)
  return type(ctx) == "table" and ctx.Runtime or nil
end

local function warn(ctx, message)
  local runtime = getRuntime(ctx)
  if runtime and type(runtime.Warn) == "function" then
    runtime.Warn(message)
  end
end

function Module.Start(ctx, categorySpec)
  if type(ctx) ~= "table" or type(ctx.LoadRepo) ~= "function" then
    error(Module.Name .. ": loader context missing")
  end
  if type(categorySpec) ~= "table" then
    error(Module.Name .. ": category spec missing")
  end

  local category = tostring(categorySpec.Category or "unknown")
  local features = categorySpec.Features
  if type(features) ~= "table" then
    error(Module.Name .. ": feature list missing for " .. category)
  end

  local runtime = getRuntime(ctx)
  if not runtime or type(runtime.RegisterLazyFeatures) ~= "function" then
    error(Module.Name .. ": runtime lazy registry missing")
  end

  local ok, result = pcall(runtime.RegisterLazyFeatures, category, features)
  if not ok then
    warn(ctx, Module.Name .. ": failed to register " .. category .. " features -> " .. tostring(result))
    return {
      Category = category,
      Registered = {},
      Failed = { { Name = category, Error = tostring(result) } },
    }
  end

  return {
    Category = category,
    Registered = result,
    Failed = {},
  }
end

return Module
