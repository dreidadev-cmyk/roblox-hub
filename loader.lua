--[[ loader.lua — dreidadev-cmyk ]]
local BASE = "https://raw.githubusercontent.com/dreidadev-cmyk/REPO/main/"

local ok, err = pcall(function()
    local main = loadstring(game:HttpGet(BASE .. "src/main.lua"))()
end)

if not ok then
    warn("[loader] failed: " .. tostring(err))
end
