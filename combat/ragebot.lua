local Module = {Name = "combat.ragebot", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartRageBotLoop()
end

return Module
