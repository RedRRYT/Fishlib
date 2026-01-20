-- FishLib v4.1 🐟
-- Solara-style animated UI for Roblox
-- Author: Prospect

local FishLib = {}
FishLib.Version = "4.1.0"

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- Themes
local Themes = {
    Ocean = {
        BG = Color3.fromRGB(15,25,40),
        Side = Color3.fromRGB(20,40,65),
        Button = Color3.fromRGB(30,60,100),
        Accent = Color3.fromRGB(0,170,220),
        Text = Color3.fromRGB(235,245,255)
    },
    Dark = {
        BG = Color3.fromRGB(25,25,25),
        Side = Color3.fromRGB(40,40,40),
        Button = Color3.fromRGB(55,55,55),
        Accent = Color3.fromRGB(200,200,200),
        Text = Color3.fromRGB(255,255,255)
    }
}

-- Config
local ConfigFolder = "FishLib"
local ConfigFile = ConfigFolder .. "/" .. game.PlaceId .. ".json"
local Config = {}

if readfile and isfile(ConfigFile) then
    Config = HttpService:JSONDecode(readfile(ConfigFile))
end

local function saveConfig()
    if writefile then
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end
end

-- Utilities
local function create(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function notify(gui,text)
    local n = create("TextLabel",{
        Size=UDim2.fromScale(0.6,0.08),
        Position=UDim2.fromScale(0.2,1),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.3,
        Text=text,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=18,
        Parent=gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,14),Parent=n})
    tween(n,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromScale(0.2,0.88)})
    task.delay(2.5,function()
        tween(n,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{TextTransparency=1,BackgroundTransparency=1})
        task.wait(0.4)
        n:Destroy()
    end)
end

-- Drag support
local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function() dragging=false end)
end

-- Window
function FishLib:CreateWindow(cfg)
    local Theme = Themes[cfg.Theme or "Ocean"]

    local Gui = create("ScreenGui",{Parent=Player.PlayerGui,ResetOnSpawn=false})

    local Blur = Instance.new("BlurEffect",Lighting)
    Blur.Size = 0

    -- Floating button
    local OpenBtn = create("TextButton",{
        Size=UDim2.fromOffset(56,56),
        Position=UDim2.fromScale(0.03,0.5),
        BackgroundColor3=Theme.Accent,
        Text="🐟",
        TextSize=26,
        Parent=Gui
    })
    create("UICorner",{CornerRadius=UDim.new(1,0),Parent=OpenBtn})

    makeDraggable(OpenBtn,OpenBtn)

    -- Main frame
    local Main = create("Frame",{
        Size=UDim2.fromScale(0.85,0.75),
        Position=UDim2.fromScale(0.075,0.12),
        BackgroundColor3=Theme.BG,
        Visible=false,
        Parent=Gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,18),Parent=Main})

    -- Header
    local Header = create("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,Parent=Main})
    local Title = create("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        Text=cfg.Title.." 🐟",
        BackgroundTransparency=1,
        Font=Enum.Font.GothamBlack,
        TextSize=24,
        TextColor3=Theme.Text,
        Parent=Header
    })

    local Credits = create("TextLabel",{
        Size=UDim2.new(1,0,0,22),
        Position=UDim2.new(0,0,1,-22),
        Text=cfg.Credits or "",
        BackgroundTransparency=1,
        Font=Enum.Font.Gotham,
        TextSize=14,
        TextColor3=Theme.Text,
        Parent=Main
    })

    -- Open/close
    local opened = false
    local function toggleMenu()
        opened = not opened
        Main.Visible = true
        Main.Position = UDim2.fromScale(0.075,opened and -0.8 or 0.12)
        tween(Main,TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.fromScale(0.075,0.12)})
        tween(Blur,TweenInfo.new(0.4),{Size=opened and 20 or 0})
    end
    OpenBtn.Activated:Connect(toggleMenu)

    makeDraggable(Main,Header)

    -- Side bar
    local Side = create("Frame",{Size=UDim2.new(0,80,1,0),BackgroundColor3=Theme.Side,Parent=Main})
    create("UIListLayout",{Padding=UDim.new(0,10),HorizontalAlignment=Enum.HorizontalAlignment.Center,Parent=Side})

    -- Pages
    local Pages = create("Frame",{Size=UDim2.new(1,-90,1,-70),Position=UDim2.new(0,85,0,55),BackgroundTransparency=1,Parent=Main})

    notify(Gui,"Welcome "..Player.Name.." 🐟")

    local WindowObj = {}

    function WindowObj:SetKeybind(key)
        UIS.InputBegan:Connect(function(input,gp)
            if gp then return end
            if input.KeyCode==key then toggleMenu() end
        end)
    end

    function WindowObj:SetTheme(name)
        local t = Themes[name]
        if not t then return end
        Theme = t
        Main.BackgroundColor3 = Theme.BG
        Side.BackgroundColor3 = Theme.Side
    end

    function WindowObj:Notify(text)
        notify(Gui,text)
    end

    function WindowObj:AddTab(tab)
        local Page=create("ScrollingFrame",{
            Size=UDim2.fromScale(1,1),
            CanvasSize=UDim2.new(0,0,0,0),
            ScrollBarImageTransparency=1,
            Visible=false,
            Parent=Pages
        })
        local Layout=create("UIListLayout",{Padding=UDim.new(0,12),Parent=Page})
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize=UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+20)
        end)

        local TabBtn=create("TextButton",{
            Size=UDim2.fromOffset(60,60),
            Text=tab.Name,
            BackgroundColor3=Theme.Button,
            TextColor3=Theme.Text,
            Font=Enum.Font.GothamBold,
            TextSize=14,
            Parent=Side
        })
        create("UICorner",{CornerRadius=UDim.new(1,0),Parent=TabBtn})

        TabBtn.MouseEnter:Connect(function()
            tween(TabBtn,TweenInfo.new(0.2),{BackgroundColor3=Theme.Accent})
        end)
        TabBtn.MouseLeave:Connect(function()
            tween(TabBtn,TweenInfo.new(0.2),{BackgroundColor3=Theme.Button})
        end)

        TabBtn.Activated:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    tween(p,TweenInfo.new(0.3),{Position=UDim2.new(0,0,0,20), BackgroundTransparency=1})
                    p.Visible=false
                end
            end
            Page.Position = UDim2.new(0,0,0,20)
            Page.BackgroundTransparency = 1
            Page.Visible = true
            tween(Page,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0), BackgroundTransparency=0})
        end)

        local TabObj = {}

        function TabObj:AddButton(cfg)
            local b=create("TextButton",{
                Size=UDim2.new(1,0,0,50),
                Text="  "..cfg.Text,
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.GothamBold,
                TextSize=16,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=Page
            })
            create("UICorner",{CornerRadius=UDim.new(0,12),Parent=b})

            b.MouseEnter:Connect(function()
                tween(b,TweenInfo.new(0.2),{BackgroundColor3=Theme.Accent})
            end)
            b.MouseLeave:Connect(function()
                tween(b,TweenInfo.new(0.2),{BackgroundColor3=Theme.Button})
            end)

            b.Activated:Connect(function()
                tween(b,TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,45)})
                task.delay(0.1,function() tween(b,TweenInfo.new(0.1),{Size=UDim2.new(1,0,0,50)}) end)
                cfg.Callback()
            end)
        end

        function TabObj:AddToggle(cfg)
            Config[cfg.Text] = Config[cfg.Text] or false
            local state = Config[cfg.Text]

            local t=create("TextButton",{
                Size=UDim2.new(1,0,0,50),
                Text=cfg.Text..(state and " : ON" or " : OFF"),
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.GothamBold,
                TextSize=16,
                Parent=Page
            })
            create("UICorner",{CornerRadius=UDim.new(0,12),Parent=t})

            t.Activated:Connect(function()
                state = not state
                Config[cfg.Text] = state
                saveConfig()
                tween(t,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundColor3=Theme.Accent})
                task.delay(0.15,function() tween(t,TweenInfo.new(0.15),{BackgroundColor3=Theme.Button}) end)
                t.Text = cfg.Text..(state and " : ON" or " : OFF")
                cfg.Callback(state)
            end)
        end

        return TabObj
    end

    return WindowObj
end

return FishLib
