local Module = {
  Name = "novax.misc_loader",
  Kind = "category-loader",
  Category = "misc",
  Features = {
    { Name = "ControlSpoof", RepoKey = "ControlSpoof" },
    { Name = "Configs", RepoKey = "Configs", AutoStart = true },
    { Name = "NameChanger", RepoKey = "NameChanger" },
    { Name = "Teleport", RepoKey = "Teleport" },
    { Name = "BeggerFarm", RepoKey = "BeggerFarm" },
    { Name = "Backstab", RepoKey = "Backstab" },
    { Name = "NamesOrbit", RepoKey = "NamesOrbit" },
    { Name = "AntiHit", RepoKey = "AntiHit" },
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
