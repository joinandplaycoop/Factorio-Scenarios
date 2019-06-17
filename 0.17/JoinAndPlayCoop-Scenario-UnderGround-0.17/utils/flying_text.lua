local function flying_text(message, target)

  target.surface.create_entity({	
    name = "flying-text",
    text = message,
    position = target.position
  })
end

return flying_text