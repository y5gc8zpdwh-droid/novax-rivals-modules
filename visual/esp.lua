local Module = {Name = "visual.esp", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartESPLoop()
end

return Module
