--[[ 
    FishLib v3.1 🐟
    Full Mobile UI Framework
    Author: Prospect
]]

local FishLib = {}
FishLib.Version = "3.1.0"

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- THEMES
local Themes = {
    Ocean = {
        BG = Color3.fromRGB(10,20,35),
        Side = Color3.fromRGB(12,30,55),
        Button = Color3.fromRGB(25,55,90),
        Accent = Color3.fromRGB(0,170,200),
        Text = Color3.fromRGB(240,250,255)
    },
    Dark = {
        BG = Color3.fromRGB(20,20,20),
        Side = Color3.fromRGB(30,30,30),
        Button = Color3.fromRGB(45,45,45),
        Accent = Color3.fromRGB(200,200,200),
        Text = Color3.fromRGB(255,255,255)
    }
}

-- CONFIG
local ConfigFolder = "FishLib"
local ConfigFile = ConfigFolder .. "/" .. game.PlaceId .. ".json"
local Config = {}

local function saveConfig()
    if writefile then
        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end
end

local function loadConfig()
    if readfile and isfile(ConfigFile) then
        Config = HttpService:JSONDecode(readfile(ConfigFile))
    end
end

loadConfig()

-- UTILS
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

-- NOTIFICATIONS
local function notify(gui, text)
    local n = create("TextLabel", {
        Size = UDim2.fromScale(0.6, 0.08),
        Position = UDim2.fromScale(0.2, 1),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.25,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,14),Parent=n})

    tween(n, TweenInfo.new(.35, Enum.EasingStyle.Quad), {
        Position = UDim2.fromScale(0.2, 0.88)
    })

    task.delay(2.5, function()
        tween(n, TweenInfo.new(.35), {
            TextTransparency = 1,
            BackgroundTransparency = 1
        })
        task.wait(.4)
        n:Destroy()
    end)
end

-- WINDOW
function FishLib:CreateWindow(cfg)
    local Theme = Themes[cfg.Theme or "Ocean"]

    local Gui = create("ScreenGui", {
        Name = "FishLibUI",
        ResetOnSpawn = false,
        Parent = Player:WaitForChild("PlayerGui")
    })

    -- BLUR
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = Lighting

    -- FLOATING OPEN BUTTON
    local OpenBtn = create("TextButton", {
        Size = UDim2.fromOffset(56,56),
        Position = UDim2.fromScale(0.03,0.5),
        BackgroundColor3 = Theme.Accent,
        Text = "🐟",
        TextSize = 26,
        Parent = Gui
    })
    create("UICorner",{CornerRadius=UDim.new(1,0),Parent=OpenBtn})

    -- MAIN WINDOW
    local Main = create("Frame", {
        Size = UDim2.fromScale(0.85,0.75),
        Position = UDim2.fromScale(0.075,0.12),
        BackgroundColor3 = Theme.BG,
        Visible = false,
        Parent = Gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,18),Parent=Main})

    -- TITLE
    create("TextLabel", {
        Size = UDim2.new(1,0,0,50),
        Text = cfg.Title .. " 🐟",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        TextColor3 = Theme.Text,
        Parent = Main
    })

    -- CREDITS
    create("TextLabel", {
        Size = UDim2.new(1,0,0,22),
        Position = UDim2.new(0,0,1,-22),
        Text = cfg.Credits or "",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Parent = Main
    })

    -- OPEN / CLOSE
    local opened = false
    OpenBtn.Activated:Connect(function()
        opened = not opened
        Main.Visible = opened
        tween(Blur, TweenInfo.new(.3), {Size = opened and 20 or 0})
    end)

    -- KEYBIND
    local Keybind = Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Keybind then
            opened = not opened
            Main.Visible = opened
            tween(Blur, TweenInfo.new(.3), {Size = opened and 20 or 0})
        end
    end)

    -- SIDE BAR
    local Side = create("Frame", {
        Size = UDim2.new(0,70,1,0),
        BackgroundColor3 = Theme.Side,
        Parent = Main
    })

    local SideLayout = create("UIListLayout", {
        Padding = UDim.new(0,10),
        HorizontalAlignment = Center,
        Parent = Side
    })

    -- PAGES
    local Pages = create("Frame", {
        Size = UDim2.new(1,-80,1,-70),
        Position = UDim2.new(0,75,0,55),
        BackgroundTransparency = 1,
        Parent = Main
    })

    notify(Gui, "Welcome "..Player.Name.." 🐟")

    local Window = {}

    function Window:SetKeybind(key)
        Keybind = key
    end

    function Window:SetTheme(name)
        local t = Themes[name]
        if not t then return end
        Theme = t
        Main.BackgroundColor3 = t.BG
        Side.BackgroundColor3 = t.Side
    end

    function Window:Notify(text)
        notify(Gui, text)
    end

    function Window:AddTab(tab)
        local Page = create("ScrollingFrame", {
            Size = UDim2.fromScale(1,1),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarImageTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local Layout = create("UIListLayout", {
            Padding = UDim.new(0,12),
            Parent = Page
        })

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
        end)

        local TabBtn = create("ImageButton", {
            Size = UDim2.fromOffset(46,46),
            Image = tab.Icon,
            BackgroundColor3 = Theme.Button,
            Parent = Side
        })
        create("UICorner",{CornerRadius=UDim.new(1,0),Parent=TabBtn})

        TabBtn.Activated:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            Page.Visible = true
        end)

        local TabObj = {}

        function TabObj:AddButton(cfg)
            local b = create("TextButton", {
                Size = UDim2.new(1,0,0,50),
                Text = "  "..cfg.Text,
                BackgroundColor3 = Theme.Button,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Left,
                Parent = Page
            })
            create("UICorner",{CornerRadius=UDim.new(0,12),Parent=b})

            b.Activated:Connect(function()
                tween(b,TweenInfo.new(.15),{BackgroundColor3=Theme.Accent})
                task.delay(.15,function()
                    tween(b,TweenInfo.new(.15),{BackgroundColor3=Theme.Button})
                end)
                cfg.Callback()
            end)
        end

        function TabObj:AddToggle(cfg)
            Config[cfg.Text] = Config[cfg.Text] or false
            local state = Config[cfg.Text]

            local t = create("TextButton", {
                Size = UDim2.new(1,0,0,50),
                Text = cfg.Text .. (state and " : ON" or " : OFF"),
                BackgroundColor3 = Theme.Button,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                Parent = Page
            })
            create("UICorner",{CornerRadius=UDim.new(0,12),Parent=t})

            t.Activated:Connect(function()
                state = not state
                Config[cfg.Text] = state
                saveConfig()
                t.Text = cfg.Text .. (state and " : ON" or " : OFF")
                cfg.Callback(state)
            end)
        end

        function TabObj:AddSlider(cfg)
            Config[cfg.Text] = Config[cfg.Text] or cfg.Min
            local value = Config[cfg.Text]

            local holder = create("Frame",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Parent=Page})
            create("TextLabel",{Size=UDim2.new(1,0,0,20),Text=cfg.Text,TextColor3=Theme.Text,BackgroundTransparency=1,Parent=holder})

            local bar = create("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,35),BackgroundColor3=Theme.Button,Parent=holder})
            create("UICorner",{CornerRadius=UDim.new(1,0),Parent=bar})

            local fill = create("Frame",{Size=UDim2.new((value-cfg.Min)/(cfg.Max-cfg.Min),0,1,0),BackgroundColor3=Theme.Accent,Parent=bar})
            create("UICorner",{CornerRadius=UDim.new(1,0),Parent=fill})

            cfg.Callback(value)

            bar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    local x=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                    x=math.clamp(x,0,1)
                    value = math.floor(cfg.Min + (cfg.Max-cfg.Min)*x)
                    Config[cfg.Text]=value
                    saveConfig()
                    fill.Size=UDim2.new(x,0,1,0)
                    cfg.Callback(value)
                end
            end)
        end

        return TabObj
    end

    return Window
end

return FishLib
