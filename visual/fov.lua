local Module = {Name = "visual.fov", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartFOVLoop()
end

return Module
