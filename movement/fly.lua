local Module = {Name = "movement.fly", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartFlyLoop()
end

return Module
