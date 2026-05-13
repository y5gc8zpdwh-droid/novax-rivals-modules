local Module = {Name = "combat.autoaim", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartAutoAimLoop()
end

return Module
