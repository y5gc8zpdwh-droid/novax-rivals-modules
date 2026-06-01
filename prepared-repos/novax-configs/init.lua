local Module = {
  Name = "novax.configs",
  Kind = "feature",
  Path = "novax-configs/init.lua",
  Category = "misc",
  RuntimeLoop = "ui.configs",
  StateKeys = { "ConfigProfile" },
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

  local ui = runtime.GetUI and runtime.GetUI()
  local window = runtime.GetWindow and runtime.GetWindow()
  if not runtime.IsGUIReady() or type(ui) ~= "table" or not window then
    return false
  end
  if type(ui.CreateConfigManager) ~= "function" then
    if type(runtime.FeatureUnavailable) == "function" then
      runtime.FeatureUnavailable("Profile", "Profil-Manager-Modul wurde nicht geladen.")
    end
    return false
  end

  return ui:CreateConfigManager(window, runtime.State, {
    Folder = runtime.GetConfigFolder(),
    DefaultName = "default",
    TabName = "Profile",
    Sync = function()
      runtime.SyncAfterConfigLoad()
    end,
  })
end

return Module
