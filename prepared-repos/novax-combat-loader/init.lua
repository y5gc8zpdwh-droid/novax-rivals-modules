local Module = {
  Name = "novax.combat_loader",
  Kind = "category-loader",
  Category = "combat",
  Features = {
    { Name = "AimLock", RepoKey = "AimLock" },
    { Name = "TriggerBot", RepoKey = "TriggerBot" },
    { Name = "SilentAim", RepoKey = "SilentAim" },
  },
}

local started = false

function Module.Start(ctx)
  if started then
    return true
  end
  started = true
  if type(ctx) ~= "table" or type(ctx.LoadRepo) ~= "function" then
    error(Module.Name .. ": loader context missing")
  end

  local repo = ctx.Repos and ctx.Repos.FeatureLoader
  if not repo then
    error(Module.Name .. ": missing FeatureLoader repo")
  end

  local loader = ctx.LoadRepo(repo, "init.lua", ctx)
  if type(loader) == "table" and type(loader.Start) == "function" then
    return loader.Start(ctx, {
      Category = Module.Category,
      Features = Module.Features,
    })
  end
  return loader ~= false
end

return Module
