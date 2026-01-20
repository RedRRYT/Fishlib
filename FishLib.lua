-- FishLib v5.1 🐟
-- Mobile-Only Clean UI
local FishLib = {}
FishLib.Version = "5.1.0"

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- Themes
local Themes = {
    Ocean = {
        BG = Color3.fromRGB(20,25,35),
        Side = Color3.fromRGB(25,35,50),
        Button = Color3.fromRGB(35,60,95),
        Accent = Color3.fromRGB(0,145,190),
        Text = Color3.fromRGB(240,245,255)
    },
    Dark = {
        BG = Color3.fromRGB(20,20,20),
        Side = Color3.fromRGB(30,30,30),
        Button = Color3.fromRGB(50,50,50),
        Accent = Color3.fromRGB(180,180,180),
        Text = Color3.fromRGB(255,255,255)
    }
}

-- Config
local pathFolder = "FishLib"
local pathFile = pathFolder.."/"..game.PlaceId..".json"
local Config = {}
if readfile and isfile(pathFile) then
    Config = HttpService:JSONDecode(readfile(pathFile))
end

local function saveConfig()
    if writefile then
        if not isfolder(pathFolder) then makefolder(pathFolder) end
        writefile(pathFile, HttpService:JSONEncode(Config))
    end
end

-- Utility
local function create(class,props)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    return o
end

local function notify(gui,text)
    local n = create("TextLabel",{
        Size = UDim2.new(0.8,0,0.1,0),
        Position = UDim2.new(0.1,0,0.8,0),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.3,
        Text = text,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham,
        TextSize = 18,
        Parent = gui
    })
    create("UICorner",{Parent=n})
    task.delay(2,function() n:Destroy() end)
end

-- Create Window
function FishLib:CreateWindow(cfg)
    local Theme = Themes[cfg.Theme or "Ocean"]

    local gui = create("ScreenGui",{Parent=Player.PlayerGui,ResetOnSpawn=false})

    -- Main Frame
    local main = create("Frame",{
        Size=UDim2.new(0.9,0,0.9,0),
        Position=UDim2.new(0.05,0,0.05,0),
        BackgroundColor3=Theme.BG,
        Parent=gui
    })
    create("UICorner",{Parent=main})

    -- Header
    local header = create("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundColor3=Theme.Side,
        Parent=main
    })
    create("UICorner",{Parent=header})

    local title = create("TextLabel",{
        Size=UDim2.new(0.8,0,1,0),
        Position=UDim2.new(0.05,0,0,0),
        Text=cfg.Title or "Menu",
        TextColor3=Theme.Text,
        Font=Enum.Font.GothamBold,
        TextSize=24,
        BackgroundTransparency=1,
        Parent=header
    })

    local credits = create("TextLabel",{
        Size=UDim2.new(0.8,0,1,0),
        Position=UDim2.new(0.05,0,1,-30),
        Text=cfg.Credits or "",
        TextColor3=Theme.Text,
        Font=Enum.Font.Gotham,
        TextSize=14,
        BackgroundTransparency=1,
        Parent=header
    })

    -- Close Button
    local closeBtn = create("TextButton",{
        Text="✖",
        Size=UDim2.new(0,40,0,40),
        Position=UDim2.new(1,-45,0,10),
        BackgroundColor3=Theme.Side,
        TextColor3=Theme.Text,
        Font=Enum.Font.GothamBold,
        TextSize=20,
        Parent=header
    })
    create("UICorner",{Parent=closeBtn})
    closeBtn.Activated:Connect(function() main.Visible=false end)

    -- Side Tab List
    local side = create("Frame",{
        Size=UDim2.new(0.3,0,1,0),
        Position=UDim2.new(0,0,0,60),
        BackgroundColor3=Theme.Side,
        Parent=main
    })
    create("UIListLayout",{Padding=UDim.new(0,10),Parent=side})

    -- Pages container
    local pages = create("Frame",{
        Size=UDim2.new(0.7,0,1,0),
        Position=UDim2.new(0.3,0,0,60),
        BackgroundTransparency=1,
        Parent=main
    })

    notify(gui,"Welcome "..Player.Name.." 🐟")

    local WindowObj = {}

    function WindowObj:SetTheme(name)
        Theme = Themes[name] or Theme
        main.BackgroundColor3=Theme.BG
        side.BackgroundColor3=Theme.Side
    end

    function WindowObj:Notify(text)
        notify(gui,text)
    end

    function WindowObj:AddTab(tab)
        local page = create("Frame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Visible=false,
            Parent=pages
        })

        local btn = create("TextButton",{
            Text=tab.Name,
            Size=UDim2.new(1,0,0,50),
            BackgroundColor3=Theme.Button,
            TextColor3=Theme.Text,
            Font=Enum.Font.Gotham,
            TextSize=18,
            Parent=side
        })
        create("UICorner",{Parent=btn})

        btn.Activated:Connect(function()
            for _,c in ipairs(pages:GetChildren()) do
                if c:IsA("Frame") then c.Visible=false end
            end
            page.Visible=true
        end)

        local TabObj = {}

        function TabObj:AddButton(cfg)
            local b = create("TextButton",{
                Text=cfg.Text,
                Size=UDim2.new(0.9,0,0,50),
                Position=UDim2.new(0.05,0,0,0),
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.Gotham,
                TextSize=18,
                Parent=page
            })
            create("UICorner",{Parent=b})
            b.Activated:Connect(function()
                cfg.Callback()
            end)
        end

        function TabObj:AddToggle(cfg)
            Config[cfg.Text] = Config[cfg.Text] or false
            local state = Config[cfg.Text]
            local t = create("TextButton",{
                Text=cfg.Text.." : "..(state and "ON" or "OFF"),
                Size=UDim2.new(0.9,0,0,50),
                Position=UDim2.new(0.05,0,0,0),
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.Gotham,
                TextSize=18,
                Parent=page
            })
            create("UICorner",{Parent=t})
            t.Activated:Connect(function()
                state = not state
                Config[cfg.Text]=state
                saveConfig()
                t.Text = cfg.Text.." : "..(state and "ON" or "OFF")
                cfg.Callback(state)
            end)
        end

        return TabObj
    end

    return WindowObj
end

return FishLib
