local Module = {Name = "misc.antihit", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartAntiHitLoop()
end

return Module
