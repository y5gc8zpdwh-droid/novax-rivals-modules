local Module = {Name = "combat.silent_aim", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartSilentAimHook()
end

return Module
