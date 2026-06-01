-- NovaX Bootstrap Loader
-- Role: load UI library, attach UI extensions, then start the GUI loader.

local ctx = ...
if type(ctx) ~= "table" then
  error("NovaX bootstrap: context missing")
end

local repos = ctx.Repos or {}
local loadRepo = ctx.LoadRepo
if type(loadRepo) ~= "function" then
  error("NovaX bootstrap: LoadRepo missing")
end
local assertBootActive = type(ctx.AssertBootActive) == "function" and ctx.AssertBootActive or function() end
local isBootActive = type(ctx.IsBootActive) == "function" and ctx.IsBootActive or function()
  return true
end

local globals = (getgenv and getgenv()) or nil
assertBootActive()
if globals and isBootActive() then
  globals.NX_BOOT_STAGE = "bootstrap"
end

local ui = loadRepo(repos.UI, "NovaPremiumUI.lua", ctx)
assertBootActive()
if type(ui) ~= "table" or type(ui.CreateWindow) ~= "function" then
  error("NovaX bootstrap: novax-ui/NovaPremiumUI.lua did not return UI")
end

ctx.UI = ui
ctx.NovaPremiumUI = ui
if globals and isBootActive() then
  globals.NovaPremiumUI = ui
end

local configManager = loadRepo(repos.UI, "config_manager.lua", ctx)
assertBootActive()
if type(configManager) == "table" and type(configManager.Start) == "function" then
  configManager.Start({
    Runtime = {
      GetUI = function()
        return ui
      end,
    },
  })
end

assertBootActive()
if globals and isBootActive() then
  globals.NX_BOOT_STAGE = "gui"
end

local guiLoader = loadRepo(repos.GUI, "init.lua", ctx)
assertBootActive()
if type(guiLoader) == "table" and type(guiLoader.Start) == "function" then
  return guiLoader.Start(ctx)
end

return guiLoader
