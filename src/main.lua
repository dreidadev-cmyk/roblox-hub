--[[ src/main.lua ]]
local BASE = "https://raw.githubusercontent.com/dreidadev-cmyk/roblox-hub/main/"

local Hub = {
    Version = "0.1.0",
    Modules = {},
    Flags   = {},
}

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

local UI = Hub:Load("src/ui.lua")
UI:Init(Hub)

-- everything lives here now
local Universal = Hub:Load("src/scripts/universal.lua")
Universal:Init(Hub, UI)

_G.DreiHub = Hub
return Hub
