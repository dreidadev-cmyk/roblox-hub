--[[ src/scripts/universal.lua — ESP + Aimbot, universal ]]
local Universal = {}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local lp         = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local cfg = {
    -- esp
    esp_enabled = false,
    esp_box     = true,
    esp_name    = true,
    esp_health  = true,
    esp_team    = false,
    esp_maxdist = 500,

    -- aimbot
    aim_enabled = false,
    aim_key     = Enum.UserInputType.MouseButton2,
    aim_fov     = 150,
    aim_smooth  = 0.25,
    aim_maxdist = 500,
    aim_team    = false,
    aim_visible = true,
    aim_part    = "Head",
}

-- ============================================================
-- ESP
-- ============================================================
local espCache = {}

local function newDraw(cls, props)
    local d = Drawing.new(cls)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function espCreate(player)
    if espCache[player] then return end
    espCache[player] = {
        box    = newDraw("Square", {Thickness = 1, Color = Color3.fromRGB(255, 80, 80), Filled = false}),
        fill   = newDraw("Square", {Thickness = 0, Color = Color3.fromRGB(255, 80, 80), Filled = true, Transparency = 0.85}),
        name   = newDraw("Text",   {Size = 14, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255)}),
        health = newDraw("Text",   {Size = 12, Center = true, Outline = true, Color = Color3.fromRGB(120,255,120)}),
    }
end

local function espRemove(player)
    local c = espCache[player]
    if not c then return end
    for _, d in pairs(c) do d:Remove() end
    espCache[player] = nil
end

local function espRender()
    if not cfg.esp_enabled then
        if next(espCache) then
            for p in pairs(espCache) do espRemove(p) end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        local c    = espCache[player]

        if not (hrp and hum and head and hum.Health > 0) then
            if c then for _, d in pairs(c) do d.Visible = false end end
            continue
        end

        if not c then espCreate(player); c = espCache[player] end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        local skip = dist > cfg.esp_maxdist
        if cfg.esp_team and player.Team == lp.Team then skip = true end

        local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if skip or not onScreen then
            for _, d in pairs(c) do d.Visible = false end
            continue
        end

        local topPos = head.Position + Vector3.new(0, 0.5, 0)
        local botPos = hrp.Position - Vector3.new(0, 3, 0)
        local topScr = Camera:WorldToViewportPoint(topPos)
        local botScr = Camera:WorldToViewportPoint(botPos)
        if topScr.Z < 0 or botScr.Z < 0 then
            for _, d in pairs(c) do d.Visible = false end
            continue
        end

        local height = math.abs(botScr.Y - topScr.Y)
        local width  = height * 0.55
        local x      = topScr.X - width / 2
        local y      = topScr.Y

        c.box.Visible = cfg.esp_box
        if cfg.esp_box then
            c.box.Size     = Vector2.new(width, height)
            c.box.Position = Vector2.new(x, y)
            c.fill.Size    = Vector2.new(width, height)
            c.fill.Position= Vector2.new(x, y)
            c.fill.Visible = true
        else
            c.fill.Visible = false
        end

        c.name.Visible    = cfg.esp_name
        c.name.Text       = player.Name
        c.name.Position   = Vector2.new(topScr.X, y - 18)

        c.health.Visible  = cfg.esp_health
        c.health.Text     = ("%d HP | %dm"):format(math.floor(hum.Health), math.floor(dist))
        c.health.Position = Vector2.new(topScr.X, y + height + 4)

        local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local col = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 80)
        c.box.Color  = col
        c.fill.Color = col
    end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 1
fovCircle.NumSides     = 64
fovCircle.Radius       = cfg.aim_fov
fovCircle.Filled       = false
fovCircle.Visible      = false
fovCircle.Color        = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.6

local holding = false

local function screenCenter()
    local vp = Camera.ViewportSize
    return Vector2.new(vp.X / 2, vp.Y / 2)
end

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local dir    = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {lp.Character, part.Parent}
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

local function getTarget()
    local center = screenCenter()
    local best, bestDist = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if cfg.aim_team and player.Team == lp.Team then continue end

        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.Health > 0) then continue end

        local part = char:FindFirstChild(cfg.aim_part)
        if not part then continue end

        local dist3 = (Camera.CFrame.Position - part.Position).Magnitude
        if dist3 > cfg.aim_maxdist then continue end
        if cfg.aim_visible and not isVisible(part) then continue end

        local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen or screen.Z < 0 then continue end

        local distPx = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if distPx > cfg.aim_fov then continue end

        if distPx < bestDist then
            bestDist = distPx
            best     = part
        end
    end

    return best
end

local function aimAt(part)
    local goal = CFrame.lookAt(Camera.CFrame.Position, part.Position)
    if cfg.aim_smooth >= 1 then
        Camera.CFrame = goal
    else
        Camera.CFrame = Camera.CFrame:Lerp(goal, cfg.aim_smooth)
    end
end

-- ============================================================
-- INIT
-- ============================================================
function Universal:Init(hub, ui)
    -- ESP toggles
    ui:Toggle("ESP",              "esp_enabled", false)
    ui:Toggle("ESP Boxes",        "esp_box",     true)
    ui:Toggle("ESP Names",        "esp_name",    true)
    ui:Toggle("ESP Health",       "esp_health",  true)
    ui:Toggle("ESP Team Check",   "esp_team",    false)

    -- Aimbot toggles
    ui:Toggle("Aimbot",              "aim_enabled", false)
    ui:Toggle("Aimbot Team Check",   "aim_team",    false)
    ui:Toggle("Aimbot Visible Only", "aim_visible", true)

    -- player add/remove
    Players.PlayerAdded:Connect(espCreate)
    Players.PlayerRemoving:Connect(espRemove)

    -- aim key hold
    UserInput.Started:Connect(function(input)
        if input.UserInputType == cfg.aim_key then holding = true end
    end)
    UserInput.Ended:Connect(function(input)
        if input.UserInputType == cfg.aim_key then holding = false end
    end)

    -- main loop
    RunService.RenderStepped:Connect(function()
        -- sync flags → cfg
        cfg.esp_enabled = hub.Flags.esp_enabled
        cfg.esp_box     = hub.Flags.esp_box
        cfg.esp_name    = hub.Flags.esp_name
        cfg.esp_health  = hub.Flags.esp_health
        cfg.esp_team    = hub.Flags.esp_team

        cfg.aim_enabled = hub.Flags.aim_enabled
        cfg.aim_team    = hub.Flags.aim_team
        cfg.aim_visible = hub.Flags.aim_visible

        espRender()

        fovCircle.Position = screenCenter()
        fovCircle.Radius   = cfg.aim_fov
        fovCircle.Visible  = cfg.aim_enabled

        if cfg.aim_enabled and holding then
            local target = getTarget()
            if target then aimAt(target) end
        end
    end)
end

return Universal
