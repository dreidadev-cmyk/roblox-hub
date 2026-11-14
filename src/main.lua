--[[ src/main.lua ]]
local BASE = "https://raw.githubusercontent.com/dreidadev-cmyk/REPO/main/"

local Hub = {
    Version = "0.1.0",
    Modules = {},
    Flags   = {},   -- toggles live here
}

-- module loader
function Hub:Load(path)
    local src = game:HttpGet(BASE .. path)
    local chunk = loadstring(src)
    if not chunk then
        warn("[main] bad chunk: " .. path)
        return nil
    end
    local mod = chunk()
    self.Modules[path] = mod
    return mod
end

-- bring up the UI
local UI = Hub:Load("src/ui.lua")
UI:Init(Hub)

-- example wiring: a working toggle the UI can flip
Hub:Load("src/features/_example.lua") -- optional, drop features here later

_G.DreiHub = Hub
return Hub
