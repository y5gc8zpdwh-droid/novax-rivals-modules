local Module = {Name = "core.scheduler", Kind = "core"}

function Module.Start(ctx)
  ctx.Runtime.StartCoreDevice()
  return ctx.Runtime.StartCombatSupervisorLoop()
end

return Module
