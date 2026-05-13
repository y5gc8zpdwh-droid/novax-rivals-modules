local Module = {Name = "movement.speed", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartSpeedLoop()
end

return Module
