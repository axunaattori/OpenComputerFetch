local computer = require("computer")
local component = require("component")
local screen = component.screen
local gpu = component.gpu
local fs = component.filesystem
 
local uptime = computer.uptime()
local w, h = gpu.getResolution()
local w2, h2 = gpu.maxResolution()
local wb, hb = screen.getAspectRatio()
 
local getscreen = gpu.getScreen()
 
-- local table1 = computer.getDeviceInfo()
 
-- times
 
local timeUnits = {
    {unit = " days", value = 60 * 60 * 24},
    {unit = " hours", value = 60 * 60},
    {unit = " mins", value = 60},
    {unit = " secs", value = 1}
}
 
-- getMemory
local maxmem = computer.totalMemory()
local freemem = computer.freeMemory()
local usedmem = maxmem - freemem
local permem = math.floor(usedmem/maxmem*100)
 
--hard drive
local used = fs.spaceUsed()
local total = fs.spaceTotal()
local perdrive = math.floor(used/total*100)
 
local info = computer.getDeviceInfo()
 
-- "Borrowed" code
for k, v in pairs(info) do
    if v.class == "processor" then
        _ProcessorName = --[[v.vendor.." "..]]v.product
 
        if v.clock == nil or v.clock == "" then else
            v.clock = v.clock:match"[^+]*"
 
            _ProcessorClock    = v.clock.."Hz"
        end
    end
end
 
function convertTime(time)
      local timeString = ""
    for _, timeUnit in ipairs(timeUnits) do
        local unitValue = math.floor(time / timeUnit.value)
        if unitValue > 0 then
            timeString = timeString .. unitValue .. timeUnit.unit .. ", "
            time = time % timeUnit.value
        end
    end
    return string.sub(timeString, 1, -3)
end
 
function formatBytes(bytes)
  local units = {'Bytes', 'KiB', 'MiB', 'GiB'}
    local unitIndex = 1
 
    while bytes >= 1024 and unitIndex < #units do
        bytes = bytes / 1024
        unitIndex = unitIndex + 1
    end
 
    return string.format("%.2f %s", bytes, units[unitIndex])
end
 
function fetch()
  gpu.setForeground(0xF9F178)
  io.write("Uptime: ")
  gpu.setForeground(0xFFFFFF)
  print(convertTime(uptime))
  gpu.setForeground(0xF9F178)
  io.write("Display: ")
  gpu.setForeground(0xFFFFFF)
  print(w .. "x" .. h .. " (Usable: " .. w2 .. "x" .. h2 .. ") (In-World: " .. wb .. "x" .. hb .. ")")
  gpu.setForeground(0xF9F178)
  io.write("CPU: ")
  gpu.setForeground(0xFFFFFF)
  print(_ProcessorName .. " @ " .. _ProcessorClock)
  gpu.setForeground(0xF9F178)
  io.write("Memory: ")
  gpu.setForeground(0xFFFFFF)
  print(formatBytes(usedmem) .. " / " .. formatBytes(maxmem) .. " (" .. permem .. "%)")
  --remember to add later
  --print("Disk (Main): " .. formatBytes(used) .. " / " .. formatBytes(total) .. " (" .. perdrive .. "%)")
end
 
fetch()
