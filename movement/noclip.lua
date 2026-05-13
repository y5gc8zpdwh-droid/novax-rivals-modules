local Module = {Name = "movement.noclip", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartNoClipLoop()
end

return Module
