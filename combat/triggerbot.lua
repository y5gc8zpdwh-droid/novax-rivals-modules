local Module = {Name = "combat.triggerbot", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartTriggerLoop()
end

return Module
