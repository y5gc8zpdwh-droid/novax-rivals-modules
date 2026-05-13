local Module = {Name = "movement.antivoid", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartAntiVoidLoop()
end

return Module
