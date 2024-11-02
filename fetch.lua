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

local CL = component.list()
local info = computer.getDeviceInfo() -- remove if it lags it too much

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

function disk() -- fastfetch calls everything disks in my experience so why should i worry about filesystem bullshit
  local primaryFS = component.getPrimary("filesystem")
  local FSspacetotal = {primaryFS.spaceTotal()}
  local FSspaceused = {primaryFS.spaceUsed()}
  local perDisk = {math.floor(primaryFS.spaceUsed() / primaryFS.spaceTotal() * 100)}
  for address, type in CL do
    if type == "filesystem" then
      local fs = component.proxy(address)
      table.insert(FSspacetotal, fs.spaceTotal())
      table.insert(FSspaceused , fs.spaceUsed())
      table.insert(perDisk, math.floor(fs.spaceUsed() / fs.spaceTotal() * 100)) -- funny little CODING ERROR!!!!!!
    end
  end

  for i = #FSspacetotal, 1, -1 do -- reverse magic and probably shouldn't print 1 if there's only 1 of them but who the fuck cares lol
    term.setCursor(CurStartX + 12, CurStartY + writePos)
    gpu.setForeground(0xFFFF00)
    io.write("Filesystem (" .. #FSspacetotal - i + 1 .. ")")
    gpu.setForeground(0xFFFFFF)
    io.write(": " .. convertBytes(FSspaceused[i]) .. " / " .. convertBytes(FSspacetotal[i]) .. " (")
    
    if perDisk[i] < 50 then
      gpu.setForeground(0x008000)
      io.write(perDisk[i])
    elseif perDisk[i] > 50 and perDisk[i] < 80 then
      gpu.setForeground(0xFFFF00)
      io.write(perDisk[i])
    else
      gpu.setForeground(0x800000)
      io.write(perDisk[i])
    end
    io.write("%")
    gpu.setForeground(0xFFFFFF)
    io.write(")")
      
    writePos = writePos + 1
  end
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
  gpu.setBackground(0x000000)
end

local cpu = ""

local gpuN = "Integrated Graphics"

local host = ""

function getData() -- i honestly dont see any reason to add device.vendor to the products, if you find any reason to add them then inform me with a github issue or something https://github.com/axunaattori/OpenComputerFetch/
  for uuid, device in pairs(info) do
    if device.class == "processor" then
      local cpuName = (device.product or "unknown CPU")
      local cpuHz = device.clock
      
      if cpuHz then
        cpuHz = cpuHz .. " Hz"
      else
        cpuHz = "unknown"
      end
      
      cpu = cpuName .. " @ " .. cpuHz
    end
    if device.class == "system" then 
      host = (device.product or "unknown product")
    end
    if device.class == "display" then
      gpuN = (device.product or "Integrated Graphics")
    end
  end
end

function cpuP()
  term.setCursor(CurStartX + 12, CurStartY+writePos)
  gpu.setForeground(0xFFFF00)
  io.write("CPU")
  gpu.setForeground(0xFFFFFF)
  io.write(": " .. cpu)

  writePos = writePos + 1
end

function hostP()
  term.setCursor(CurStartX + 12, CurStartY + writePos)
  gpu.setForeground(0xFFFF00)
  io.write("Host")
  gpu.setForeground(0xFFFFFF)
  io.write(": " .. host)

  writePos = writePos + 1
end

function gpuP()
  term.setCursor(CurStartX + 12, CurStartY + writePos)
  gpu.setForeground(0xFFFF00)
  io.write("GPU")
  gpu.setForeground(0xFFFFFF)
  io.write(": " .. gpuN)
  
  writePos = writePos + 1
end

function getPFS()

end

CurStartX, CurStartY = term.getCursor()

getData()

printlogo()

hostP()

uptime()

screen()

memory()

cpuP()

gpuP()

disk()

colorTest()
