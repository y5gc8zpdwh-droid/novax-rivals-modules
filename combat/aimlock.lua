local Module = {Name = "combat.aimlock", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartAimLockLoop()
end

return Module
