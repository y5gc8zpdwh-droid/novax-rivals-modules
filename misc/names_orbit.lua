local Module = {Name = "misc.names_orbit", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartNamesOrbitLoop()
end

return Module
