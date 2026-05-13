local Module = {Name = "misc.backstab", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartAutoBackstabLoop()
end

return Module
