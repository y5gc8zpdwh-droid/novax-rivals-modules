local ctx = ...
ctx = type(ctx) == "table" and ctx or {}

local manifest = ctx.Manifest or {}
local loadRemote = ctx.Load
if type(loadRemote) ~= "function" then
  error("NovaX init: ctx.Load missing")
end

local loaded = {}
local started = {}

local function loadModule(path)
  if loaded[path] ~= nil then
    return loaded[path]
  end
  local value = loadRemote(path, ctx)
  loaded[path] = value == nil and true or value
  return loaded[path]
end

local runtime = loadModule("core/runtime.lua")
if type(runtime) ~= "table" then
  error("NovaX init: core/runtime.lua did not return runtime table")
end

ctx.Runtime = runtime

for _, path in ipairs(manifest.Modules or {}) do
  if path ~= "core/runtime.lua" then
    local ok, moduleOrErr = pcall(loadModule, path)
    if not ok then
      error("NovaX init: failed to load " .. tostring(path) .. " -> " .. tostring(moduleOrErr))
    end
    local module = moduleOrErr
    if type(module) == "table" and type(module.Start) == "function" then
      local okStart, err = pcall(module.Start, ctx)
      if not okStart then
        error("NovaX init: failed to start " .. tostring(path) .. " -> " .. tostring(err))
      end
      started[#started + 1] = path
    end
  end
end

if runtime.NotifyLoaded then
  runtime.NotifyLoaded()
end

return {
  Runtime = runtime,
  Loaded = loaded,
  Started = started,
}
