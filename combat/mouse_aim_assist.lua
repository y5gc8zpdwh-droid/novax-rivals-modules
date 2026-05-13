local Module = {Name = "combat.mouse_aim_assist", Kind = "feature"}

function Module.Start(ctx)
  return ctx.Runtime.StartMouseAimAssistLoop()
end

return Module
