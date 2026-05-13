local Module = {Name = "misc.control_spoof", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartControlSpoofLoop()
end

return Module
