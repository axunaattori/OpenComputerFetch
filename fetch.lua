--code by axunaattori
 
local component = require("component")
local computer = require("computer")
local term = require("term")
local gpu = component.gpu
local screen = component.screen
local fs = component.filesystem
 
local logo = {
"##########",
"#OPEN OS #",
"#        #",
"#        #",
"#        #",
"##########"
}
 
local byteUnits = {
"B",
"KiB",
"MiB",
"GiB",
"TiB",
"PiB",
"EiB",
"ZiB",
"YiB"
}
 
local ansiColors = {
0x000000,
0x800000,
0x008000,
0x808000,
0x000080,
0x800080,
0x008080,
0xc0c0c0,
0x808080,
0xFF0000,
0x00FF00,
0xFFFF00,
0x0000FF,
0xFF00FF,
0x00FFFF,
0xFFFFFF
}
 
local w, h = gpu.getResolution()
local w2, h2 = gpu.maxResolution()
local wb, hb = screen.getAspectRatio()
 
local writePos = 0
 
function printlogo()
  gpu.setForeground(0x808080)
  for i = 1, #logo do
    print(logo[i])    
  end
  gpu.fill(CurStartX+1, CurStartY+1, 8, 4, " ")
  gpu.setForeground(0xFFFFFF)
  term.setCursor(CurStartX+1, CurStartY+1)
  io.write("OPEN OS")
end
 
local min = 60
local hour = 60*60
local day = hour*24
 
function uptime()
  term.setCursor(CurStartX+12, CurStartY+writePos)
  gpu.setForeground(0xFFFF00)
  io.write("Uptime")
  gpu.setForeground(0xFFFFFF)
  io.write(": ")
 
  local days = math.floor(computer.uptime() / (60*60*24))
  local hours = math.floor((computer.uptime() % (60*60*24)) / (60*60))
  local mins = math.floor((computer.uptime() % (60*60)) / 60)
  local secs = math.floor(computer.uptime() % 60)
 
  local time = ""
 
  if days > 0 then
      time = time .. days .. " days, "
  end
  if hours > 0 then
      time = time .. hours .. " hours, "
  end
  if mins > 0 then
      time = time .. mins .. " minutes, "
  end
  if secs > 0 then
      time = time .. secs .. " seconds"
  end
 
  time = time:gsub(", $", "")
 
  print(time)
 
  writePos = writePos + 1
end
 
function convertBytes(bytes)
  local i = 1  
  while 1 < bytes do
    bytes = bytes / 1024
    i = i + 1
  end
  bytes = bytes * 1024 -- EASY FIX!!!
  return math.floor(bytes * 100 + 0.5) / 100 .. " " .. byteUnits[i - 1]
end
 
function memory()
  term.setCursor(CurStartX+12, CurStartY+writePos)
  gpu.setForeground(0xFFFF00)
  io.write("Memory")
  gpu.setForeground(0xFFFFFF)
  io.write(": ")
 
  local usedMem = convertBytes(computer.totalMemory() - computer.freeMemory())
  local totalMem = convertBytes(computer.totalMemory())
  local perMem = math.floor((computer.totalMemory() - computer.freeMemory()) / computer.totalMemory()*100) -- per short for percent
  
  io.write(usedMem .. " / " .. totalMem .. " (")
 
  if perMem < 50 then
    gpu.setForeground(0x008000)
    io.write(perMem)
  elseif perMem > 50 and perMem < 80 then
    gpu.setForeground(0xFFFF00)
    io.write(perMem)
  else
    gpu.setForeground(0x800000)
    io.write(perMem)
  end
  io.write("%")
  gpu.setForeground(0xFFFFFF)
  io.write(")")
 
  writePos = writePos + 1
end
 
function screen()
  term.setCursor(CurStartX+12, CurStartY+writePos)
  gpu.setForeground(0xFFFF00)
  io.write("Display")
  gpu.setForeground(0xFFFFFF)
  io.write(": " .. w .. "x" .. h .. " (max: " .. w2 .. "x" .. h2 .. ") " .. "(In-world: " .. wb .. "x" .. hb .. ")")
 
  writePos = writePos + 1
end
 
function disk()
  term.setCursor(CurStartX + 12, CurStartY + writePos)
  gpu.setForeground(0xFFFF00)
  io.write("Disk")
  gpu.setForeground(0xFFFFFF)
  io.write(": " .. convertBytes(fs.spaceUsed()) .. " / " .. convertBytes(fs.spaceTotal()) .. " (")
  
  local perDisk = math.floor(fs.spaceUsed() / fs.spaceTotal()*100)
 
  if perDisk < 50 then
    gpu.setForeground(0x008000)
    io.write(perDisk)
  elseif perDisk > 50 and perDisk < 80 then
    gpu.setForeground(0xFFFF00)
    io.write(perDisk)
  else
    gpu.setForeground(0x800000)
    io.write(perDisk)
  end
  io.write("%")
  gpu.setForeground(0xFFFFFF)
  io.write(")")
    
  writePos = writePos + 1
end
 
function colorTest()
  term.setCursor(CurStartX + 12, CurStartY + 1 + writePos)
 
  for i = 1, 8 do
    gpu.setBackground(ansiColors[i])
    io.write("   ")
  end
  term.setCursor(CurStartX + 12, CurStartY + 2 + writePos)
  for i = 1, 8 do
    gpu.setBackground(ansiColors[i + 8])
    io.write("   ")
  end
end
 
CurStartX, CurStartY = term.getCursor()
 
printlogo()
 
uptime()
 
screen()
 
memory()
 
disk()
 
colorTest()
