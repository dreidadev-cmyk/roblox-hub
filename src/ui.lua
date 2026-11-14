--[[ src/ui.lua — minimal hub GUI, dependency-free ]]
local UI = {}

function UI:Init(hub)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local pg = lp:WaitForChild("PlayerGui")

    -- clean up old
    local old = pg:FindFirstChild("DreiHub")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DreiHub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = pg

    -- main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 300)
    frame.Position = UDim2.new(0.5, -210, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- title bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.BorderSizePixel = 0
    title.Text = "  DreiHub  v" .. hub.Version
    title.TextColor3 = Color3.fromRGB(230, 230, 240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

    -- content area (scroll)
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -50)
    content.Position = UDim2.new(0, 10, 0, 42)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = frame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    -- public helpers so features can build controls
    function UI:Toggle(label, flagName, default)
        hub.Flags[flagName] = default or false

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.BorderSizePixel = 0
        btn.Text = "  " .. label .. ":  " .. (hub.Flags[flagName] and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(220, 220, 230)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = content
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            hub.Flags[flagName] = not hub.Flags[flagName]
            btn.Text = "  " .. label .. ":  " .. (hub.Flags[flagName] and "ON" or "OFF")
            btn.BackgroundColor3 = hub.Flags[flagName]
                and Color3.fromRGB(50, 90, 60)
                or Color3.fromRGB(35, 35, 45)
        end)
        return btn
    end

    function UI:Button(label, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.BorderSizePixel = 0
        btn.Text = label
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Parent = content
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    -- close button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -34, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 200, 200)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.BorderSizePixel = 0
    close.Parent = title
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- demo button proving the loop works
    UI:Button("Ping → print", function()
        print("[DreiHub] alive, flags:", hub.Flags)
    end)

    return UI
end

return UI
