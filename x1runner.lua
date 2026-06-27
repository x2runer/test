-- TRUEDEX V2 - Full UI Library (Updated 2026)
-- Features: Tabs + Search, All elements, ColorPicker (HSV), Keybind, Config Save/Load, Notifications, etc.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local TRUEDEXV2 = { connections = {} }

local function track(conn)
    table.insert(TRUEDEXV2.connections, conn)
    return conn
end

TRUEDEXV2.THEMES = {
    DarkBlue = {
        BG_MAIN = Color3.fromRGB(20, 20, 25),
        BG_SIDE = Color3.fromRGB(28, 28, 33),
        BG_CONTENT = Color3.fromRGB(25, 25, 30),
        ACCENT = Color3.fromRGB(52, 152, 219),
        TEXT = Color3.fromRGB(240, 240, 240),
        TEXT_DIM = Color3.fromRGB(150, 150, 150),
        GREEN = Color3.fromRGB(50, 200, 50),
        RED = Color3.fromRGB(220, 50, 50),
        DARK_ITEM = Color3.fromRGB(35, 35, 40)
    },
    Purple = {
        BG_MAIN = Color3.fromRGB(25, 20, 35),
        BG_SIDE = Color3.fromRGB(20, 15, 30),
        BG_CONTENT = Color3.fromRGB(30, 25, 40),
        ACCENT = Color3.fromRGB(155, 89, 182),
        TEXT = Color3.fromRGB(245, 245, 245),
        TEXT_DIM = Color3.fromRGB(160, 160, 170),
        GREEN = Color3.fromRGB(50, 200, 50),
        RED = Color3.fromRGB(220, 50, 50),
        DARK_ITEM = Color3.fromRGB(40, 35, 50)
    }
}

TRUEDEXV2.THEME = TRUEDEXV2.THEMES.DarkBlue

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or TRUEDEXV2.THEME.ACCENT
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function tween(o, p, d)
    local t = TweenService:Create(o, TweenInfo.new(d or 0.25, Enum.EasingStyle.Quart), p)
    t:Play()
    return t
end

local function makeDraggable(o)
    local drag, dInput, dStart, sPos
    track(o.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag, dStart, sPos = true, i.Position, o.Position
            track(i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end))
        end
    end))
    track(o.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dInput = i
        end
    end))
    track(UserInputService.InputChanged:Connect(function(i)
        if i == dInput and drag then
            local d = i.Position - dStart
            o.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end))
end

-- HSV helper
local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    return Color3.new(r, g, b)
end

function TRUEDEXV2:CreateWindow(config)
    config = config or {}
    if config.Theme and TRUEDEXV2.THEMES[config.Theme] then
        TRUEDEXV2.THEME = TRUEDEXV2.THEMES[config.Theme]
    end

    local title = config.Name or "TRUEDEX V2"
    local toggleIcon = config.ToggleIcon or "rbxassetid://102557398190054"
    local bgImageId = config.BackgroundImage or "rbxassetid://76224884569689"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TRUEDEX_V2_" .. math.random(100, 999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    -- Loading Screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(0, 420, 0, 180)
    LoadingFrame.Position = UDim2.new(0.5, -210, 0.5, -90)
    LoadingFrame.BackgroundColor3 = TRUEDEXV2.THEME.BG_MAIN
    LoadingFrame.BackgroundTransparency = 0.1
    LoadingFrame.Parent = ScreenGui
    corner(LoadingFrame, 12)
    stroke(LoadingFrame, TRUEDEXV2.THEME.ACCENT, 2)

    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Size = UDim2.new(1, 0, 0, 50)
    LoadTitle.Position = UDim2.new(0, 0, 0.15, 0)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.Text = config.LoadingTitle or "TRUEDEX V2 Loading..."
    LoadTitle.TextColor3 = TRUEDEXV2.THEME.TEXT
    LoadTitle.Font = Enum.Font.GothamBold
    LoadTitle.TextSize = 22
    LoadTitle.Parent = LoadingFrame

    local LoadSub = Instance.new("TextLabel")
    LoadSub.Size = UDim2.new(1, 0, 0, 30)
    LoadSub.Position = UDim2.new(0, 0, 0.45, 0)
    LoadSub.BackgroundTransparency = 1
    LoadSub.Text = config.LoadingSubtitle or "JS TRUEDEXV2"
    LoadSub.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
    LoadSub.Font = Enum.Font.Gotham
    LoadSub.TextSize = 14
    LoadSub.Parent = LoadingFrame

    task.wait(1.2)
    LoadingFrame:Destroy()

    local guiVisible = true

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(1, -60, 0, 10)
    ToggleBtn.BackgroundColor3 = TRUEDEXV2.THEME.BG_SIDE
    ToggleBtn.BackgroundTransparency = 0.15
    ToggleBtn.Image = toggleIcon
    ToggleBtn.ScaleType = Enum.ScaleType.Fit
    ToggleBtn.ZIndex = 20
    ToggleBtn.Parent = ScreenGui
    corner(ToggleBtn, 12)
    stroke(ToggleBtn, TRUEDEXV2.THEME.ACCENT, 2)
    makeDraggable(ToggleBtn)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 560, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
    MainFrame.BackgroundColor3 = TRUEDEXV2.THEME.BG_MAIN
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    corner(MainFrame, 12)
    stroke(MainFrame, TRUEDEXV2.THEME.ACCENT, 2)
    makeDraggable(MainFrame)

    local CenterPosition = MainFrame.Position

    track(ToggleBtn.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        if guiVisible then
            MainFrame.Position = UDim2.new(CenterPosition.X.Scale, CenterPosition.X.Offset, -0.35, -220)
            MainFrame.Visible = true
            tween(MainFrame, {Position = CenterPosition}, 0.5)
        else
            local currentPos = MainFrame.Position
            local hidePos = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, 1.25, 450)
            local t = tween(MainFrame, {Position = hidePos}, 0.4)
            t.Completed:Connect(function()
                MainFrame.Visible = false
                MainFrame.Position = CenterPosition
            end)
        end
    end))

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = TRUEDEXV2.THEME.BG_SIDE
    TopBar.BackgroundTransparency = 0.3
    TopBar.Parent = MainFrame
    corner(TopBar, 12)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = TRUEDEXV2.THEME.ACCENT
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -28, 0, 2)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = TRUEDEXV2.THEME.TEXT
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TopBar

    track(CloseBtn.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
        ToggleBtn:Destroy()
    end))

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.Position = UDim2.new(1, -52, 0, 2)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "—"
    MinBtn.TextColor3 = TRUEDEXV2.THEME.TEXT
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.Parent = TopBar

    local minimized = false
    track(MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(MainFrame, {Size = minimized and UDim2.new(0, 560, 0, 28) or UDim2.new(0, 560, 0, 360)}, 0.25)
    end))

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 115, 1, 0)
    Sidebar.BackgroundColor3 = TRUEDEXV2.THEME.BG_SIDE
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.Parent = MainFrame
    corner(Sidebar, 12)

    local SidebarLabel = Instance.new("TextLabel")
    SidebarLabel.Size = UDim2.new(1, 0, 0, 32)
    SidebarLabel.Position = UDim2.new(0, 0, 0, 8)
    SidebarLabel.BackgroundTransparency = 1
    SidebarLabel.Text = title
    SidebarLabel.TextColor3 = TRUEDEXV2.THEME.ACCENT
    SidebarLabel.Font = Enum.Font.GothamBold
    SidebarLabel.TextSize = 18
    SidebarLabel.Parent = Sidebar

    -- Search Bar
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.9, 0, 0, 26)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 42)
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SearchBox.PlaceholderText = "Tìm tab..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = TRUEDEXV2.THEME.TEXT
    SearchBox.PlaceholderColor3 = TRUEDEXV2.THEME.TEXT_DIM
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = Sidebar
    corner(SearchBox, 6)
    stroke(SearchBox, TRUEDEXV2.THEME.ACCENT, 1)

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -80)
    TabScroll.Position = UDim2.new(0, 0, 0, 75)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 3
    TabScroll.ScrollBarImageColor3 = TRUEDEXV2.THEME.ACCENT
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = Sidebar

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = TabScroll

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Parent = TabContainer

    track(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end))

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -130, 1, -20)
    ContentArea.Position = UDim2.new(0, 125, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = bgImageId
    BackgroundImage.ImageTransparency = 0.7
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 0
    BackgroundImage.Parent = ContentArea

    local pages, tabBtns = {}, {}
    local Window = {}
    Window.Flags = {}

    -- Notification System
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 300, 1, 0)
    NotificationHolder.Position = UDim2.new(1, -320, 0, 20)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui

    local NotifList = Instance.new("UIListLayout")
    NotifList.Padding = UDim.new(0, 8)
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifList.Parent = NotificationHolder

    function Window:Notify(title, message, duration)
        duration = duration or 4
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 70)
        notif.BackgroundColor3 = TRUEDEXV2.THEME.BG_MAIN
        notif.BackgroundTransparency = 0.1
        notif.Parent = NotificationHolder
        corner(notif, 8)
        stroke(notif, TRUEDEXV2.THEME.ACCENT, 1)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -16, 0, 22)
        titleLabel.Position = UDim2.new(0, 10, 0, 6)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = TRUEDEXV2.THEME.ACCENT
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.Parent = notif

        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(1, -16, 0, 40)
        msgLabel.Position = UDim2.new(0, 10, 0, 26)
        msgLabel.BackgroundTransparency = 1
        msgLabel.Text = message
        msgLabel.TextColor3 = TRUEDEXV2.THEME.TEXT
        msgLabel.Font = Enum.Font.Gotham
        msgLabel.TextSize = 12
        msgLabel.TextWrapped = true
        msgLabel.Parent = notif

        task.delay(duration, function()
            tween(notif, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.4)
            notif:Destroy()
        end)
    end

    local function addCommonMethods(Target, ParentScroll)
        local itemIndex = 0
        local function getIdx() itemIndex = itemIndex + 1 return itemIndex end

        function Target:AddSection(title)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 24)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -8, 1, 0)
            label.Position = UDim2.new(0, 4, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = title:upper()
            label.TextColor3 = TRUEDEXV2.THEME.ACCENT
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = f

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 1, -2)
            line.BackgroundColor3 = TRUEDEXV2.THEME.ACCENT
            line.BackgroundTransparency = 0.4
            line.Parent = f
            return f
        end

        function Target:AddLabel(text, size)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, size or 20)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.LayoutOrder = getIdx()
            l.Parent = ParentScroll
            return l
        end

        function Target:AddParagraph(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 0)
            l.AutomaticSize = Enum.AutomaticSize.Y
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.LayoutOrder = getIdx()
            l.Parent = ParentScroll
            return l
        end

        function Target:AddTextBox(text, default, placeholder, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 50)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -20, 0, 16)
            l.Position = UDim2.new(0, 10, 0, 2)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -20, 0, 22)
            box.Position = UDim2.new(0, 10, 0, 22)
            box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            box.Text = default or ""
            box.PlaceholderText = placeholder or "Nhập tại đây..."
            box.TextColor3 = TRUEDEXV2.THEME.TEXT
            box.PlaceholderColor3 = TRUEDEXV2.THEME.TEXT_DIM
            box.Font = Enum.Font.Gotham
            box.TextSize = 13
            box.ClearTextOnFocus = false
            box.Parent = f
            corner(box, 6)
            stroke(box, TRUEDEXV2.THEME.ACCENT, 1)

            track(box.FocusLost:Connect(function(enterPressed)
                if callback then callback(box.Text, enterPressed) end
                if flag and Window.Flags[flag] then
                    Window.Flags[flag].Value = box.Text
                end
            end))

            local TextBoxObj = {Instance = f}
            function TextBoxObj:Set(v)
                box.Text = tostring(v or "")
            end
            function TextBoxObj:Get()
                return box.Text
            end

            if flag then
                Window.Flags[flag] = {Set = TextBoxObj.Set, Get = TextBoxObj.Get, Value = default or ""}
            end
            return TextBoxObj
        end

        function Target:AddKeybind(text, defaultKey, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 32)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -110, 1, 0)
            l.Position = UDim2.new(0, 10, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 90, 0, 24)
            btn.Position = UDim2.new(1, -100, 0.5, -12)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.TextColor3 = TRUEDEXV2.THEME.TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.Text = defaultKey and defaultKey.Name or "None"
            btn.Parent = f
            corner(btn, 6)
            stroke(btn, TRUEDEXV2.THEME.ACCENT, 1)

            local currentKey = defaultKey
            local listening = false

            local function updateText()
                btn.Text = currentKey and currentKey.Name or "None"
            end

            track(btn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                btn.Text = "..."
                btn.BackgroundColor3 = TRUEDEXV2.THEME.ACCENT

                local conn
                conn = track(UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = input.KeyCode
                        updateText()
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        listening = false
                        if conn then conn:Disconnect() end
                        if callback then callback(currentKey) end
                        if flag and Window.Flags[flag] then
                            Window.Flags[flag].Value = currentKey
                        end
                    end
                end))
            end))

            local KeybindObj = {Instance = f}
            function KeybindObj:Set(key)
                currentKey = key
                updateText()
            end
            function KeybindObj:Get()
                return currentKey
            end

            if flag then
                Window.Flags[flag] = {Set = KeybindObj.Set, Get = KeybindObj.Get, Value = currentKey}
            end
            return KeybindObj
        end

        function Target:AddToggle(text, default, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 28)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -55, 1, 0)
            l.Position = UDim2.new(0, 10, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 36, 0, 18)
            btn.Position = UDim2.new(1, -46, 0.5, -9)
            btn.BackgroundColor3 = default and TRUEDEXV2.THEME.ACCENT or Color3.fromRGB(60, 60, 70)
            btn.Text = ""
            btn.Parent = f
            corner(btn, 9)

            local o = Instance.new("Frame")
            o.Size = UDim2.new(0, 14, 0, 14)
            o.Position = UDim2.new(default and 1 or 0, default and -16 or 2, 0.5, -7)
            o.BackgroundColor3 = Color3.new(1, 1, 1)
            o.Parent = btn
            corner(o, 7)

            local state = default or false

            local function update()
                tween(btn, {BackgroundColor3 = state and TRUEDEXV2.THEME.ACCENT or Color3.fromRGB(60, 60, 70)}, 0.2)
                tween(o, {Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, -7)}, 0.2)
            end

            track(btn.MouseButton1Click:Connect(function()
                state = not state
                update()
                if callback then callback(state) end
                if flag and Window.Flags[flag] then
                    Window.Flags[flag].Value = state
                end
            end))

            local ToggleObj = {Instance = f}
            function ToggleObj:Set(v)
                state = v
                update()
            end
            function ToggleObj:Get()
                return state
            end

            if flag then
                Window.Flags[flag] = {Set = ToggleObj.Set, Get = ToggleObj.Get, Value = state}
            end
            return ToggleObj
        end

        function Target:AddSlider(text, min, max, default, decimals, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 42)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -20, 0, 20)
            l.Position = UDim2.new(0, 10, 0, 4)
            l.BackgroundTransparency = 1
            l.Text = text .. ": " .. default
            l.TextColor3 = TRUEDEXV2.THEME.TEXT
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, -20, 0, 4)
            bg.Position = UDim2.new(0, 10, 0, 28)
            bg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            bg.Parent = f
            corner(bg, 2)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = TRUEDEXV2.THEME.ACCENT
            fill.Parent = bg
            corner(fill, 2)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
            knob.BackgroundColor3 = TRUEDEXV2.THEME.ACCENT
            knob.Parent = bg
            corner(knob, 6)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = f

            local dragging = false
            local prec = 10 ^ (decimals or 0)
            local currentValue = default

            local function updateValue(v)
                v = math.clamp(v, min, max)
                v = math.floor(v * prec + 0.5) / prec
                currentValue = v
                local rel = (v - min) / (max - min)
                l.Text = text .. ": " .. tostring(v)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, -6, 0.5, -6)
                if callback then callback(v) end
                if flag and Window.Flags[flag] then
                    Window.Flags[flag].Value = v
                end
            end

            track(btn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    updateValue(min + (max - min) * rel)
                end
            end))

            track(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))

            track(UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local rel = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    updateValue(min + (max - min) * rel)
                end
            end))

            local SliderObj = {Instance = f}
            function SliderObj:Set(v) updateValue(v) end
            function SliderObj:Get() return currentValue end

            if flag then
                Window.Flags[flag] = {Set = SliderObj.Set, Get = SliderObj.Get, Value = currentValue}
            end
            return SliderObj
        end

        function Target:AddDropdown(text, options, default, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 32)
            f.BackgroundTransparency = 1
            f.ClipsDescendants = true
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundTransparency = 1
            btn.Text = "  " .. text .. ": " .. (default or options[1] or "")
            btn.TextColor3 = TRUEDEXV2.THEME.TEXT
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = f

            local scroll = Instance.new("ScrollingFrame")
            scroll.Size = UDim2.new(1, 0, 0, 0)
            scroll.Position = UDim2.new(0, 0, 0, 32)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 2
            scroll.ScrollBarImageColor3 = TRUEDEXV2.THEME.ACCENT
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.Visible = false
            scroll.Parent = f

            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = scroll

            local function updateDropCanvas()
                scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
            end
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropCanvas)

            for i, v in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 26)
                item.BackgroundTransparency = 1
                item.Text = "    " .. tostring(v)
                item.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
                item.Font = Enum.Font.Gotham
                item.TextSize = 11
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.LayoutOrder = i
                item.Parent = scroll

                track(item.MouseEnter:Connect(function()
                    tween(item, {BackgroundTransparency = 0.8, TextColor3 = TRUEDEXV2.THEME.TEXT}, 0.15)
                end))
                track(item.MouseLeave:Connect(function()
                    tween(item, {BackgroundTransparency = 1, TextColor3 = TRUEDEXV2.THEME.TEXT_DIM}, 0.15)
                end))

                track(item.MouseButton1Click:Connect(function()
                    btn.Text = "  " .. text .. ": " .. tostring(v)
                    tween(f, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                    tween(scroll, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    task.delay(0.2, function() scroll.Visible = false end)
                    if callback then callback(v) end
                    if flag and Window.Flags[flag] then
                        Window.Flags[flag].Value = v
                    end
                end))
            end

            updateDropCanvas()

            local open = false
            track(btn.MouseButton1Click:Connect(function()
                open = not open
                if open then scroll.Visible = true end
                local targetHeight = math.min(#options * 26, 140)
                tween(f, {Size = UDim2.new(1, 0, 0, open and (32 + targetHeight + 4) or 32)}, 0.2)
                tween(scroll, {Size = UDim2.new(1, 0, 0, open and targetHeight or 0)}, 0.2)
                if not open then task.delay(0.2, function() scroll.Visible = false end) end
            end))

            local DropObj = {Instance = f}
            function DropObj:Set(v)
                btn.Text = "  " .. text .. ": " .. tostring(v)
            end
            function DropObj:Get()
                return btn.Text:match(": (.+)")
            end

            if flag then
                Window.Flags[flag] = {Set = DropObj.Set, Get = DropObj.Get, Value = default}
            end
            return DropObj
        end

        function Target:AddButton(text, color, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 30)
            b.BackgroundColor3 = color or TRUEDEXV2.THEME.ACCENT
            b.BackgroundTransparency = 0.75
            b.Text = text
            b.TextColor3 = TRUEDEXV2.THEME.TEXT
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.LayoutOrder = getIdx()
            b.Parent = ParentScroll
            corner(b, 6)
            stroke(b, TRUEDEXV2.THEME.ACCENT)

            track(b.MouseButton1Click:Connect(function()
                tween(b, {BackgroundTransparency = 0.4}, 0.1)
                task.wait(0.1)
                tween(b, {BackgroundTransparency = 0.75}, 0.1)
                if callback then callback() end
            end))
            return b
        end

        function Target:AddColorPicker(text, default, callback, flag)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 32)
            f.BackgroundTransparency = 1
            f.LayoutOrder = getIdx()
            f.Parent = ParentScroll

            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -90, 1, 0)
            l.Position = UDim2.new(0, 10, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = TRUEDEXV2.THEME.TEXT
            l.Font = Enum.Font.Gotham
            l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = f

            local preview = Instance.new("TextButton")
            preview.Size = UDim2.new(0, 70, 0, 22)
            preview.Position = UDim2.new(1, -80, 0.5, -11)
            preview.BackgroundColor3 = default or Color3.fromRGB(255, 100, 100)
            preview.Text = ""
            preview.Parent = f
            corner(preview, 4)
            stroke(preview, TRUEDEXV2.THEME.ACCENT, 1)

            local currentColor = default or Color3.fromRGB(255, 100, 100)
            local hue, sat, val = 0, 1, 1

            local function updateColor(c)
                currentColor = c
                preview.BackgroundColor3 = c
                if callback then callback(c) end
                if flag and Window.Flags[flag] then
                    Window.Flags[flag].Value = c
                end
            end

            track(preview.MouseButton1Click:Connect(function()
                local picker = Instance.new("Frame")
                picker.Size = UDim2.new(0, 260, 0, 200)
                picker.Position = UDim2.new(0.5, -130, 0.5, -100)
                picker.BackgroundColor3 = TRUEDEXV2.THEME.BG_MAIN
                picker.Parent = ScreenGui
                corner(picker, 8)
                stroke(picker, TRUEDEXV2.THEME.ACCENT, 2)

                local svBox = Instance.new("Frame")
                svBox.Size = UDim2.new(0, 160, 0, 160)
                svBox.Position = UDim2.new(0, 15, 0, 20)
                svBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                svBox.Parent = picker
                corner(svBox, 4)

                local draggingSV = false
                track(svBox.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        local relX = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        sat, val = relX, 1 - relY
                        updateColor(HSVToRGB(hue, sat, val))
                    end
                end))

                track(UserInputService.InputChanged:Connect(function(i)
                    if draggingSV and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local relX = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                        sat, val = relX, 1 - relY
                        updateColor(HSVToRGB(hue, sat, val))
                    end
                end))

                track(UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false end
                end))

                local close = Instance.new("TextButton")
                close.Size = UDim2.new(0, 20, 0, 20)
                close.Position = UDim2.new(1, -25, 0, 5)
                close.Text = "X"
                close.BackgroundTransparency = 1
                close.TextColor3 = TRUEDEXV2.THEME.TEXT
                close.Parent = picker
                track(close.MouseButton1Click:Connect(function() picker:Destroy() end))
            end))

            local ColorObj = {Instance = f}
            function ColorObj:Set(c) updateColor(c) end
            function ColorObj:Get() return currentColor end

            if flag then
                Window.Flags[flag] = {Set = ColorObj.Set, Get = ColorObj.Get, Value = currentColor}
            end
            return ColorObj
        end

        function Target:AddCollapsible(title)
            local c = Instance.new("Frame")
            c.Size = UDim2.new(1, 0, 0, 30)
            c.BackgroundColor3 = TRUEDEXV2.THEME.BG_CONTENT
            c.BackgroundTransparency = 0.35
            c.ClipsDescendants = true
            c.LayoutOrder = getIdx()
            c.Parent = ParentScroll
            corner(c, 6)
            stroke(c, TRUEDEXV2.THEME.ACCENT)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundTransparency = 1
            btn.Text = "  " .. title .. " ▼"
            btn.TextColor3 = TRUEDEXV2.THEME.TEXT
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = c

            local content = Instance.new("Frame")
            content.Position = UDim2.new(0, 0, 0, 30)
            content.Size = UDim2.new(1, 0, 0, 0)
            content.BackgroundTransparency = 1
            content.Parent = c

            local ly = Instance.new("UIListLayout")
            ly.Padding = UDim.new(0, 4)
            ly.SortOrder = Enum.SortOrder.LayoutOrder
            ly.Parent = content

            local open = false
            local function updateSize()
                local h = open and (30 + ly.AbsoluteContentSize.Y + 8) or 30
                tween(c, {Size = UDim2.new(1, 0, 0, h)}, 0.25)
                btn.Text = "  " .. title .. (open and " ▲" or " ▼")
                btn.TextColor3 = open and TRUEDEXV2.THEME.ACCENT or TRUEDEXV2.THEME.TEXT
            end

            track(btn.MouseButton1Click:Connect(function()
                open = not open
                updateSize()
            end))

            track(ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then updateSize() end
            end))

            local Collapsible = {Instance = c, Container = content}
            addCommonMethods(Collapsible, content)
            return Collapsible
        end
    end

    function Window:CreateTab(name)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0, 34)
        b.BackgroundColor3 = TRUEDEXV2.THEME.DARK_ITEM
        b.BackgroundTransparency = 1
        b.Text = name
        b.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.Parent = TabContainer
        corner(b, 8)

        local p = Instance.new("ScrollingFrame")
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = TRUEDEXV2.THEME.ACCENT
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        p.Parent = ContentArea

        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0, 6)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent = p

        local function updateCanvasSize()
            task.defer(function()
                p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 25)
            end)
        end
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        updateCanvasSize()

        track(b.MouseButton1Click:Connect(function()
            for _, x in ipairs(pages) do x.Visible = false end
            for _, x in ipairs(tabBtns) do
                x.BackgroundTransparency = 1
                x.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
            end
            p.Visible = true
            b.BackgroundTransparency = 0
            b.TextColor3 = TRUEDEXV2.THEME.ACCENT
        end))

        table.insert(pages, p)
        table.insert(tabBtns, b)

        local Tab = {ScrollFrame = p}
        addCommonMethods(Tab, p)
        return Tab
    end

    function Window:SelectTab(num)
        if tabBtns[num] then
            for _, x in ipairs(pages) do x.Visible = false end
            for _, x in ipairs(tabBtns) do
                x.BackgroundTransparency = 1
                x.TextColor3 = TRUEDEXV2.THEME.TEXT_DIM
            end
            pages[num].Visible = true
            tabBtns[num].BackgroundTransparency = 0
            tabBtns[num].TextColor3 = TRUEDEXV2.THEME.ACCENT
        end
    end

    function Window:Destroy()
        ScreenGui:Destroy()
        for _, conn in ipairs(TRUEDEXV2.connections) do
            if conn.Connected then conn:Disconnect() end
        end
        TRUEDEXV2.connections = {}
    end

    -- Config System
    function Window:SaveConfig()
        local data = {}
        for flag, obj in pairs(Window.Flags) do
            if obj.Get then
                data[flag] = obj.Get()
            end
        end
        return data
    end

    function Window:LoadConfig(data)
        for flag, value in pairs(data) do
            if Window.Flags[flag] and Window.Flags[flag].Set then
                Window.Flags[flag].Set(value)
            end
        end
    end

    function Window:GetFlag(flag)
        return Window.Flags[flag] and Window.Flags[flag].Value
    end

    task.delay(0.20, function()
        if #tabBtns > 0 then
            tabBtns[1].BackgroundTransparency = 0
            tabBtns[1].TextColor3 = TRUEDEXV2.THEME.ACCENT
            pages[1].Visible = true
        end
    end)

    return Window
end

return TRUEDEXV2
