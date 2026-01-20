-- FishLib v3 🐟
-- Full Mobile UI Library
-- Author: Prospect

local FishLib = {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
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

local function tween(o,t,p) TweenService:Create(o,t,p):Play() end
local function create(c,p) local o=Instance.new(c) for k,v in pairs(p)do o[k]=v end return o end

-- NOTIFY
local function notify(gui,text)
    local n = create("TextLabel",{
        Size=UDim2.fromScale(.6,.08),
        Position=UDim2.fromScale(.2,.9),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=.3,
        Text=text,
        TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,
        TextSize=18,
        Parent=gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,12),Parent=n})
    tween(n,TweenInfo.new(.3),{Position=UDim2.fromScale(.2,.82)})
    task.delay(2,function()
        tween(n,TweenInfo.new(.3),{TextTransparency=1,BackgroundTransparency=1})
        task.wait(.3)
        n:Destroy()
    end)
end

-- WINDOW
function FishLib:CreateWindow(cfg)
    local Theme = Themes[cfg.Theme or "Ocean"]

    local Gui = create("ScreenGui",{Parent=Player.PlayerGui,ResetOnSpawn=false})
    local Blur = Instance.new("BlurEffect",Lighting)
    Blur.Size = 0

    -- OPEN BTN
    local Open = create("TextButton",{
        Size=UDim2.fromOffset(55,55),
        Position=UDim2.fromScale(.03,.5),
        Text="🐟",
        TextSize=26,
        BackgroundColor3=Theme.Accent,
        Parent=Gui
    })
    create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Open})

    local Main = create("Frame",{
        Size=UDim2.fromScale(.85,.75),
        Position=UDim2.fromScale(.075,.12),
        BackgroundColor3=Theme.BG,
        Visible=false,
        Parent=Gui
    })
    create("UICorner",{CornerRadius=UDim.new(0,16),Parent=Main})

    Open.Activated:Connect(function()
        Main.Visible = not Main.Visible
        tween(Blur,TweenInfo.new(.3),{Size=Main.Visible and 20 or 0})
    end)

    -- TITLE
    create("TextLabel",{
        Size=UDim2.new(1,0,0,50),
        Text=cfg.Title.." 🐟",
        BackgroundTransparency=1,
        Font=Enum.Font.GothamBlack,
        TextSize=22,
        TextColor3=Theme.Text,
        Parent=Main
    })

    -- CREDITS
    create("TextLabel",{
        Size=UDim2.new(1,0,0,25),
        Position=UDim2.new(0,0,1,-25),
        Text=cfg.Credits or "",
        BackgroundTransparency=1,
        Font=Enum.Font.Gotham,
        TextSize=14,
        TextColor3=Theme.Text,
        Parent=Main
    })

    notify(Gui,"Welcome "..Player.Name)

    -- SIDE
    local Side = create("Frame",{Size=UDim2.new(0,70,1,0),BackgroundColor3=Theme.Side,Parent=Main})
    local Pages = create("Frame",{Size=UDim2.new(1,-80,1,-60),Position=UDim2.new(0,75,0,50),BackgroundTransparency=1,Parent=Main})

    local Window = {}

    function Window:AddTab(tab)
        local Page = create("ScrollingFrame",{
            Size=UDim2.fromScale(1,1),
            ScrollBarImageTransparency=1,
            CanvasSize=UDim2.new(0,0,0,0),
            Visible=false,
            Parent=Pages
        })

        local layout = create("UIListLayout",{Padding=UDim.new(0,12),Parent=Page})
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+20)
        end)

        local Btn = create("ImageButton",{
            Size=UDim2.fromOffset(45,45),
            Image=tab.Icon,
            BackgroundColor3=Theme.Button,
            Parent=Side
        })
        create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Btn})

        Btn.Activated:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible=false end
            end
            Page.Visible=true
        end)

        local TabObj = {}

        function TabObj:AddButton(cfg)
            local b = create("TextButton",{
                Size=UDim2.new(1,0,0,50),
                Text="  "..cfg.Text,
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.GothamBold,
                TextSize=16,
                TextXAlignment=Left,
                Parent=Page
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
            local state=false
            local t=create("TextButton",{
                Size=UDim2.new(1,0,0,50),
                Text=cfg.Text.." : OFF",
                BackgroundColor3=Theme.Button,
                TextColor3=Theme.Text,
                Font=Enum.Font.GothamBold,
                TextSize=16,
                Parent=Page
            })
            create("UICorner",{CornerRadius=UDim.new(0,12),Parent=t})
            t.Activated:Connect(function()
                state=not state
                t.Text=cfg.Text..(state and " : ON" or " : OFF")
                cfg.Callback(state)
            end)
        end

        function TabObj:AddSlider(cfg)
            local holder=create("Frame",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Parent=Page})
            local label=create("TextLabel",{Size=UDim2.new(1,0,0,20),Text=cfg.Text,TextColor3=Theme.Text,BackgroundTransparency=1,Parent=holder})
            local bar=create("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,35),BackgroundColor3=Theme.Button,Parent=holder})
            create("UICorner",{CornerRadius=UDim.new(1,0),Parent=bar})
            local fill=create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=Theme.Accent,Parent=bar})
            create("UICorner",{CornerRadius=UDim.new(1,0),Parent=fill})

            bar.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    local x=(i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
                    x=math.clamp(x,0,1)
                    fill.Size=UDim2.new(x,0,1,0)
                    cfg.Callback(math.floor(cfg.Min+(cfg.Max-cfg.Min)*x))
                end
            end)
        end

        return TabObj
    end

    return Window
end

return FishLib
