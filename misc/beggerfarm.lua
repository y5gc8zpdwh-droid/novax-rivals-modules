local Module = {Name = "misc.beggerfarm", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartBeggerFarmLoop()
end

return Module
