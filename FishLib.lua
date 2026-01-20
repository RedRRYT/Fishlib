-- FishLib 🐟
-- Mobile-Friendly Roblox UI Library
-- Author: Prospect

local FishLib = {}
FishLib.__index = FishLib

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Theme
local Theme = {
    Background = Color3.fromRGB(10, 20, 35),
    TopBar = Color3.fromRGB(15, 35, 60),
    Accent = Color3.fromRGB(0, 170, 200),
    Text = Color3.fromRGB(235, 245, 255),
    Button = Color3.fromRGB(20, 45, 75)
}

-- Utility
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Drag (Mouse + Touch)
local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Window
function FishLib:CreateWindow(title)
    local ScreenGui = create("ScreenGui", {
        Name = "FishLibUI",
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })

    local Main = create("Frame", {
        Size = UDim2.fromScale(0.9, 0.75),
        Position = UDim2.fromScale(0.05, 0.12),
        BackgroundColor3 = Theme.Background,
        Parent = ScreenGui
    })

    create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Main})

    -- Mobile scaling
    local Scale = create("UIScale", {
        Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 500, 0.85, 1),
        Parent = Main
    })

    local Top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.TopBar,
        Parent = Main
    })

    create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Top})

    local Title = create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = title .. " 🐟",
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Left,
        Parent = Top
    })

    makeDraggable(Main, Top)

    local Tabs = create("Frame", {
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local List = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = Tabs
    })

    local Window = {}

    function Window:CreateTab()
        local Tab = create("Frame", {
            Size = UDim2.new(1, 0, 0, 300),
            BackgroundTransparency = 1,
            Parent = Tabs
        })

        local Layout = create("UIListLayout", {
            Padding = UDim.new(0, 10),
            Parent = Tab
        })

        local TabObj = {}

        function TabObj:CreateButton(text, callback)
            local Btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 50),
                Text = text,
                BackgroundColor3 = Theme.Button,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                Parent = Tab
            })

            create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Btn})

            Btn.Activated:Connect(function()
                pcall(callback)
            end)
        end

        function TabObj:CreateToggle(text, callback)
            local State = false

            local Toggle = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 50),
                Text = text .. " : OFF",
                BackgroundColor3 = Theme.Button,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                Parent = Tab
            })

            create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Toggle})

            Toggle.Activated:Connect(function()
                State = not State
                Toggle.Text = text .. (State and " : ON" or " : OFF")
                pcall(callback, State)
            end)
        end

        return TabObj
    end

    return Window
end

return FishLib
