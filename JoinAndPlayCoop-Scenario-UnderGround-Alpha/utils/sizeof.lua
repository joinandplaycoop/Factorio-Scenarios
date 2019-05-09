local function sizeof(tbl)
  local len = 0
  for k, v in pairs(tbl) do
    len = len + 1
  end
  return len
end


return sizeof