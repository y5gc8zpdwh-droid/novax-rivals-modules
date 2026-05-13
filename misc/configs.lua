local Module = {Name = "misc.configs", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartConfigManager()
end

return Module
