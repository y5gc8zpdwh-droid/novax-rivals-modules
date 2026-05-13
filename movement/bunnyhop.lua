local Module = {Name = "movement.bunnyhop", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartBunnyHopLoop()
end

return Module
