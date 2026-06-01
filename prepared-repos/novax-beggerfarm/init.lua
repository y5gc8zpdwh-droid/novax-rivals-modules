local Module = {
  Name = "novax.beggerfarm",
  Kind = "feature",
  Path = "novax-beggerfarm/init.lua",
  Category = "misc",
  RuntimeLoop = "utility.begger",
  StateKeys = { "BeggerFarm" },
}

local started = false

local function fireBegAction(replica)
  local remotes = replica and replica:FindFirstChild("Remotes")
  local misc = remotes and remotes:FindFirstChild("Misc")
  local dialogAction = misc and misc:FindFirstChild("DialogAction")
  if dialogAction and dialogAction:IsA("RemoteEvent") then
    local ok = pcall(function()
      dialogAction:FireServer("beg")
    end)
    return ok
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

  local state = runtime.State
  local replica = runtime.Services and runtime.Services.ReplicatedStorage
  if not state or not replica then
    error(Module.Name .. ": missing runtime services")
  end

  task.spawn(function()
    while runtime.IsRunning() do
      if state.BeggerFarm == true then
        fireBegAction(replica)
        task.wait(0.15)
      else
        task.wait(0.35)
      end
    end
  end)

  return true
end

return Module
