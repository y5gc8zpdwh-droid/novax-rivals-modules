local Module = {Name = "movement.infjump", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartInfJumpLoop()
end

return Module
