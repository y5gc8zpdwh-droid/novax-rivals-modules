local Module = {
  Name = "novax.visual_loader",
  Kind = "category-loader",
  Category = "visual",
  Features = {
    { Name = "FullBright", RepoKey = "FullBright" },
    { Name = "NoFog", RepoKey = "NoFog" },
    { Name = "FPSUnlocker", RepoKey = "FPSUnlocker" },
    { Name = "FPSBoost", RepoKey = "FPSBoost" },
    { Name = "ESP", RepoKey = "ESP" },
    { Name = "FOV", RepoKey = "FOV" },
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
