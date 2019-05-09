local function dist(from, to)
  if not from.x then
    from = { x = from[1], y = from[2] }
  end

  if not to.x then
    to = { x = to[1], y = to[2] }
  end

  return math.sqrt( ((from.x - to.x)^2) + ((from.y - to.y)^2) )
end



return dist