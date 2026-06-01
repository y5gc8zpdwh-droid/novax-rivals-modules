-- NovaX GUI Loader
-- Role: create the runtime/GUI, then register category feature specs.

local Module = {
  Name = "novax.gui",
  Kind = "gui-loader",
  CategoryLoaders = {
    { Name = "combat", RepoKey = "CombatLoader" },
    { Name = "visual", RepoKey = "VisualLoader" },
    { Name = "movement", RepoKey = "MovementLoader" },
    { Name = "misc", RepoKey = "MiscLoader" },
  },
}

local started = false

local function startLoadedModule(ctx, repo, path)
  local module = ctx.LoadRepo(repo, path or "init.lua", ctx)
  if type(module) == "table" and type(module.Start) == "function" then
    return module.Start(ctx), module
  end
  return module, module
end

function Module.Start(ctx)
  if started then
    return ctx and ctx.Runtime or true
  end
  started = true

  if type(ctx) ~= "table" then
    error(Module.Name .. ": context missing")
  end
  if type(ctx.LoadRepo) ~= "function" then
    error(Module.Name .. ": LoadRepo missing")
  end
  local assertBootActive = type(ctx.AssertBootActive) == "function" and ctx.AssertBootActive or function() end
  local isBootActive = type(ctx.IsBootActive) == "function" and ctx.IsBootActive or function()
    return true
  end

  local globals = (getgenv and getgenv()) or nil
  assertBootActive()
  if globals and isBootActive() then
    globals.NX_BOOT_STAGE = "runtime"
  end

  local runtime = ctx.LoadRepo(ctx.Repos.GUI, "runtime.lua", ctx)
  assertBootActive()
  if type(runtime) ~= "table" then
    error(Module.Name .. ": runtime.lua did not return runtime table")
  end
  ctx.Runtime = runtime

  local startedLoaders = {}
  local failedLoaders = {}

  for _, spec in ipairs(Module.CategoryLoaders) do
    assertBootActive()
    local repo = ctx.Repos and ctx.Repos[spec.RepoKey]
    if repo then
      local ok, result = pcall(startLoadedModule, ctx, repo, "init.lua")
      if ok and result ~= false then
        startedLoaders[#startedLoaders + 1] = spec.Name
      else
        failedLoaders[#failedLoaders + 1] = {
          Name = spec.Name,
          Error = tostring(result),
        }
        if runtime.Warn then
          runtime.Warn("NovaX gui: failed to start " .. tostring(spec.Name) .. " loader -> " .. tostring(result))
        end
      end
    end
  end

  if runtime.NotifyLoaded then
    runtime.NotifyLoaded()
  end

  return {
    Runtime = runtime,
    StartedLoaders = startedLoaders,
    FailedLoaders = failedLoaders,
  }
end

return Module
