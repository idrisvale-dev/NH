local Fluent = _G.NevaHubUI
if not Fluent then
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/idrisvale-dev/NH/refs/heads/master/Library/NevaHubUI.luau", true))()
    _G.NevaHubUI = Fluent
end
local SaveManager           = Fluent.SaveManager
local InterfaceManager      = Fluent.InterfaceManager
local FloatingButtonManager = Fluent.FloatingButtonManager
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Tabs = {}
local function Notify(title, content, ntype, icon, duration)
    Fluent:Notify({Title=title, Content=content, Type=ntype or "Info", Icon=icon, Duration=duration or 3})
end
local ButtonGradients = {
    Background = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 20, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 5, 70)),
    }),
    Stroke = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(145, 45, 245)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 95, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 45, 245)),
    }),
}
local function CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ButtonName
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = -2147483648
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = false
    local frame = Instance.new("Frame")
    frame.Name = ButtonName
    frame.Size = UDim2.new(Size1, 0, Size2, 0)
    frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.7
    frame.ZIndex = -10
    frame.Parent = screenGui
    local gradient = Instance.new("UIGradient")
    gradient.Color = ButtonGradients.Background
    gradient.Parent = frame
    task.spawn(function()
        while task.wait(0.03) do
            if not frame.Parent then break end
            gradient.Rotation = (gradient.Rotation + 1) % 360
            gradient.Color = ButtonGradients.Background
        end
    end)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = frame
    local gradientstroke = Instance.new("UIGradient")
    gradientstroke.Color = ButtonGradients.Stroke
    gradientstroke.Rotation = 0
    gradientstroke.Parent = stroke
    task.spawn(function()
        while frame.Parent do
            gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
            gradientstroke.Color = ButtonGradients.Stroke
            task.wait()
        end
    end)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = Name
    button.Font = Enum.Font.SourceSansBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.TextScaled = false
    button.ZIndex = -9
    button.Parent = frame
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 28, 0, 28)
    toggle.Position = UDim2.new(1, 6, 0.5, -14)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.Text = "○"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Visible = false
    toggle.ZIndex = -8
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local originalSize = UDim2.new(Size1, 0, Size2, 0)
    local holding, holdStart, hideAt = false, 0, 0
    frame:SetAttribute("IsCircle", false)
    local isCircle = CircleMode ~= nil and CircleMode or frame:GetAttribute("IsCircle")
    local function ApplyShape(circle)
        frame:SetAttribute("IsCircle", circle)
        local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
        if circle then
            frame.Size = UDim2.new(0, s, 0, s)
            button.TextWrapped = true
            button.TextScaled = true
            button.TextSize = math.floor(s * 0.45)
            corner.CornerRadius = UDim.new(1, 0)
            toggle.Text = "▢"
        else
            frame.Size = originalSize
            button.TextWrapped = false
            button.TextScaled = false
            button.TextSize = 24
            corner.CornerRadius = UDim.new(0, 15)
            toggle.Text = "○"
        end
    end
    ApplyShape(isCircle)
    task.spawn(function()
        while task.wait(0.25) do
            if not frame.Parent then break end
            if toggle.Visible and tick() - hideAt >= 10 then toggle.Visible = false end
        end
    end)
    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            holding = true; holdStart = tick()
        end
    end)
    button.InputEnded:Connect(function(i)
        if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            holding = false
            if tick() - holdStart >= 0.6 then toggle.Visible = true; hideAt = tick() end
        end
    end)
    toggle.MouseButton1Click:Connect(function()
        hideAt = tick()
        ApplyShape(not frame:GetAttribute("IsCircle"))
    end)
    button.Activated:Connect(function()
        if ScriptLogic then ScriptLogic(button) end
    end)
    FloatingButtonManager:AddButton(ButtonName, frame, false)
    local function MakeDraggable(topbarobject, object, locked)
        local Dragging, DragInput, DragStart, StartPosition = false, nil, nil, nil
        local Holding, HoldTime, MoveCancelThreshold, HoldToken = false, 1.0, 6, 0
        object:SetAttribute("Locked", locked or false)
        local function Update(input)
            if object:GetAttribute("Locked") then return end
            local delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
        end
        local function ToggleLock()
            local newState = not object:GetAttribute("Locked")
            object:SetAttribute("Locked", newState)
            Fluent:Notify({ Title = newState and "Button Locked" or "Button Unlocked", Content = newState and "Locked in place." or "Can now be moved.", Duration = 2 })
        end
        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            Dragging = not object:GetAttribute("Locked"); Holding = true; DragStart = input.Position; StartPosition = object.Position
            HoldToken += 1; local token = HoldToken
            task.delay(HoldTime, function() if Holding and token == HoldToken then ToggleLock() end end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false; Holding = false end
            end)
        end)
        topbarobject.InputChanged:Connect(function(input)
            if not DragStart then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if (input.Position - DragStart).Magnitude > MoveCancelThreshold then Holding = false end
                DragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then Update(input) end end)
    end
    MakeDraggable(button, frame, false)
    return frame, button, ApplyShape
end
local floatingGui = nil
Fluent:RegisterCustomTheme("NeonBlue", {
    Accent = Color3.fromRGB(0, 180, 255),
    AcrylicMain = Color3.fromRGB(10, 14, 28),
    AcrylicBorder = Color3.fromRGB(0, 100, 180),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(10, 14, 28), Color3.fromRGB(5, 8, 20)),
    AcrylicNoise = 0.75,
    TitleBarLine = Color3.fromRGB(0, 100, 180),
    Tab = Color3.fromRGB(15, 22, 48),
    Element = Color3.fromRGB(12, 18, 40),
    ElementBorder = Color3.fromRGB(0, 80, 160),
    InElementBorder = Color3.fromRGB(0, 120, 220),
    ElementTransparency = 0.82,
    ToggleSlider = Color3.fromRGB(20, 30, 70),
    ToggleToggled = Color3.fromRGB(0, 180, 255),
    SliderRail = Color3.fromRGB(20, 30, 70),
    DropdownFrame = Color3.fromRGB(10, 16, 36),
    DropdownHolder = Color3.fromRGB(6, 10, 24),
    DropdownBorder = Color3.fromRGB(0, 80, 160),
    DropdownOption = Color3.fromRGB(14, 22, 50),
    Keybind = Color3.fromRGB(14, 22, 50),
    Input = Color3.fromRGB(8, 14, 32),
    InputFocused = Color3.fromRGB(4, 8, 20),
    InputIndicator = Color3.fromRGB(0, 120, 220),
    Dialog = Color3.fromRGB(6, 10, 24),
    DialogHolder = Color3.fromRGB(4, 8, 20),
    DialogHolderLine = Color3.fromRGB(0, 70, 140),
    DialogButton = Color3.fromRGB(10, 16, 38),
    DialogButtonBorder = Color3.fromRGB(0, 80, 160),
    DialogBorder = Color3.fromRGB(0, 80, 160),
    DialogInput = Color3.fromRGB(8, 14, 32),
    DialogInputLine = Color3.fromRGB(0, 120, 220),
    Text = Color3.fromRGB(230, 245, 255),
    SubText = Color3.fromRGB(120, 170, 220),
    Hover = Color3.fromRGB(20, 36, 80),
    HoverChange = 0.05,
    ShineEnabled = true,
    Shine = {
        Speed = 0.5,
        RotationSpeed = 25,
        ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 60, 130)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 130)),
        }),
    },
    StrokeShine = true,
    StrokeDark = Color3.fromRGB(0, 60, 130),
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 30, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 10, 40)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 220)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 220)),
        }),
    },
})
Fluent:RegisterCustomTheme("EmeraldDark", {
    Accent = Color3.fromRGB(0, 220, 120),
    AcrylicMain = Color3.fromRGB(8, 20, 14),
    AcrylicBorder = Color3.fromRGB(0, 140, 70),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(8, 20, 14), Color3.fromRGB(4, 12, 8)),
    AcrylicNoise = 0.7,
    TitleBarLine = Color3.fromRGB(0, 140, 70),
    Tab = Color3.fromRGB(10, 28, 18),
    Element = Color3.fromRGB(8, 22, 14),
    ElementBorder = Color3.fromRGB(0, 110, 55),
    InElementBorder = Color3.fromRGB(0, 180, 90),
    ElementTransparency = 0.84,
    ToggleSlider = Color3.fromRGB(14, 40, 24),
    ToggleToggled = Color3.fromRGB(0, 220, 120),
    SliderRail = Color3.fromRGB(14, 40, 24),
    DropdownFrame = Color3.fromRGB(6, 18, 12),
    DropdownHolder = Color3.fromRGB(4, 12, 8),
    DropdownBorder = Color3.fromRGB(0, 110, 55),
    DropdownOption = Color3.fromRGB(10, 28, 18),
    Keybind = Color3.fromRGB(10, 28, 18),
    Input = Color3.fromRGB(6, 18, 12),
    InputFocused = Color3.fromRGB(3, 10, 7),
    InputIndicator = Color3.fromRGB(0, 170, 85),
    Dialog = Color3.fromRGB(4, 14, 9),
    DialogHolder = Color3.fromRGB(3, 10, 6),
    DialogHolderLine = Color3.fromRGB(0, 90, 45),
    DialogButton = Color3.fromRGB(8, 20, 13),
    DialogButtonBorder = Color3.fromRGB(0, 110, 55),
    DialogBorder = Color3.fromRGB(0, 110, 55),
    DialogInput = Color3.fromRGB(6, 18, 12),
    DialogInputLine = Color3.fromRGB(0, 170, 85),
    Text = Color3.fromRGB(220, 255, 235),
    SubText = Color3.fromRGB(120, 200, 155),
    Hover = Color3.fromRGB(14, 42, 26),
    HoverChange = 0.05,
    ShineEnabled = true,
    Shine = {
        Speed = 0.5,
        RotationSpeed = 25,
        ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 220, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 40)),
        }),
    },
    StrokeShine = false,
    StrokeDark = Color3.fromRGB(0, 80, 40),
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 10)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 75)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 220, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 75)),
        }),
    },
})
Fluent:RegisterCustomTheme("Sunset", {
    Accent = Color3.fromRGB(255, 110, 50),
    AcrylicMain = Color3.fromRGB(28, 16, 12),
    AcrylicBorder = Color3.fromRGB(180, 80, 30),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(28, 16, 12), Color3.fromRGB(14, 8, 6)),
    AcrylicNoise = 0.7,
    TitleBarLine = Color3.fromRGB(180, 80, 30),
    Tab = Color3.fromRGB(36, 22, 16),
    Element = Color3.fromRGB(30, 18, 13),
    ElementBorder = Color3.fromRGB(160, 70, 25),
    InElementBorder = Color3.fromRGB(220, 100, 45),
    ElementTransparency = 0.82,
    ToggleSlider = Color3.fromRGB(50, 30, 20),
    ToggleToggled = Color3.fromRGB(255, 110, 50),
    SliderRail = Color3.fromRGB(50, 30, 20),
    DropdownFrame = Color3.fromRGB(24, 14, 10),
    DropdownHolder = Color3.fromRGB(14, 8, 6),
    DropdownBorder = Color3.fromRGB(160, 70, 25),
    DropdownOption = Color3.fromRGB(36, 22, 16),
    Keybind = Color3.fromRGB(36, 22, 16),
    Input = Color3.fromRGB(24, 14, 10),
    InputFocused = Color3.fromRGB(12, 7, 5),
    InputIndicator = Color3.fromRGB(220, 100, 45),
    Dialog = Color3.fromRGB(14, 8, 6),
    DialogHolder = Color3.fromRGB(12, 7, 5),
    DialogHolderLine = Color3.fromRGB(120, 55, 20),
    DialogButton = Color3.fromRGB(28, 17, 12),
    DialogButtonBorder = Color3.fromRGB(160, 70, 25),
    DialogBorder = Color3.fromRGB(160, 70, 25),
    DialogInput = Color3.fromRGB(24, 14, 10),
    DialogInputLine = Color3.fromRGB(220, 100, 45),
    Text = Color3.fromRGB(255, 240, 230),
    SubText = Color3.fromRGB(220, 170, 145),
    Hover = Color3.fromRGB(56, 34, 24),
    HoverChange = 0.05,
    ShineEnabled = true,
    Shine = {
        Speed = 0.5,
        RotationSpeed = 25,
        ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 50, 15)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 50, 15)),
        }),
    },
    StrokeShine = true,
    StrokeDark = Color3.fromRGB(120, 50, 15),
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 50, 15)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 25, 8)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 100, 45)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 100, 45)),
        }),
    },
})
Fluent:RegisterCustomTheme("NevahubViolet", {
    Accent = Color3.fromRGB(150, 35, 235),
    AcrylicMain = Color3.fromRGB(15, 6, 28),
    AcrylicBorder = Color3.fromRGB(130, 48, 225),
    AcrylicGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 13, 58)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(19, 8, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 4, 20)),
    }),
    AcrylicNoise = 0.6,
    TitleBarLine = Color3.fromRGB(190, 85, 255),
    Tab = Color3.fromRGB(27, 11, 48),
    Element = Color3.fromRGB(38, 16, 66),
    ElementBorder = Color3.fromRGB(100, 36, 180),
    InElementBorder = Color3.fromRGB(150, 35, 235),
    ElementTransparency = 0.86,
    ToggleSlider = Color3.fromRGB(46, 22, 78),
    ToggleToggled = Color3.fromRGB(190, 85, 255),
    SliderRail = Color3.fromRGB(46, 22, 78),
    DropdownFrame = Color3.fromRGB(21, 8, 38),
    DropdownHolder = Color3.fromRGB(14, 5, 27),
    DropdownBorder = Color3.fromRGB(100, 36, 180),
    DropdownOption = Color3.fromRGB(27, 11, 48),
    Keybind = Color3.fromRGB(27, 11, 48),
    Input = Color3.fromRGB(21, 8, 38),
    InputFocused = Color3.fromRGB(14, 5, 27),
    InputIndicator = Color3.fromRGB(150, 35, 235),
    Dialog = Color3.fromRGB(13, 5, 25),
    DialogHolder = Color3.fromRGB(9, 3, 18),
    DialogHolderLine = Color3.fromRGB(92, 32, 168),
    DialogButton = Color3.fromRGB(27, 11, 48),
    DialogButtonBorder = Color3.fromRGB(114, 42, 200),
    DialogBorder = Color3.fromRGB(114, 42, 200),
    DialogInput = Color3.fromRGB(21, 8, 38),
    DialogInputLine = Color3.fromRGB(150, 35, 235),
    Text = Color3.fromRGB(245, 236, 255),
    SubText = Color3.fromRGB(198, 168, 235),
    IconColor = Color3.fromRGB(226, 190, 255),
    Hover = Color3.fromRGB(48, 21, 84),
    HoverChange = 0.05,
    ShineEnabled = true,
    Shine = {
        Speed = 0.5,
        RotationSpeed = 24,
        ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 8, 92)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 60, 196)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 8, 92)),
        }),
    },
    StrokeShine = true,
    StrokeDark = Color3.fromRGB(70, 20, 135),
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 35, 235)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 22, 195)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(48, 10, 105)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 35, 235)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 60, 196)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 35, 235)),
        }),
    },
    Background = "rbxassetid://133541508207801",
    BackgroundTransparency = 0.12,
    ViewportBackground = Color3.fromRGB(20, 7, 34),
    ViewportBackgroundImages = true,
    DropdownOutsideWindowBackground = Color3.fromRGB(26, 9, 42),
    DropdownOutsideWindowBackgroundImages = true,
})
Fluent:RegisterCustomTheme("SlateStatic", {
    Accent = Color3.fromRGB(140, 150, 165),
    AcrylicMain = Color3.fromRGB(22, 24, 28),
    AcrylicBorder = Color3.fromRGB(70, 75, 85),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(22, 24, 28), Color3.fromRGB(14, 15, 18)),
    AcrylicNoise = 0.6,
    TitleBarLine = Color3.fromRGB(70, 75, 85),
    Tab = Color3.fromRGB(28, 30, 35),
    Element = Color3.fromRGB(24, 26, 30),
    ElementBorder = Color3.fromRGB(60, 64, 72),
    InElementBorder = Color3.fromRGB(90, 96, 108),
    ElementTransparency = 0.82,
    ToggleSlider = Color3.fromRGB(40, 43, 48),
    ToggleToggled = Color3.fromRGB(140, 150, 165),
    SliderRail = Color3.fromRGB(40, 43, 48),
    DropdownFrame = Color3.fromRGB(20, 22, 26),
    DropdownHolder = Color3.fromRGB(14, 15, 18),
    DropdownBorder = Color3.fromRGB(60, 64, 72),
    DropdownOption = Color3.fromRGB(28, 30, 35),
    Keybind = Color3.fromRGB(28, 30, 35),
    Input = Color3.fromRGB(20, 22, 26),
    InputFocused = Color3.fromRGB(12, 13, 16),
    InputIndicator = Color3.fromRGB(90, 96, 108),
    Dialog = Color3.fromRGB(14, 15, 18),
    DialogHolder = Color3.fromRGB(12, 13, 16),
    DialogHolderLine = Color3.fromRGB(50, 54, 62),
    DialogButton = Color3.fromRGB(26, 28, 33),
    DialogButtonBorder = Color3.fromRGB(60, 64, 72),
    DialogBorder = Color3.fromRGB(60, 64, 72),
    DialogInput = Color3.fromRGB(20, 22, 26),
    DialogInputLine = Color3.fromRGB(90, 96, 108),
    Text = Color3.fromRGB(235, 237, 240),
    SubText = Color3.fromRGB(150, 155, 165),
    Hover = Color3.fromRGB(34, 37, 42),
    HoverChange = 0.04,
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 43, 48)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 26, 30)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 96, 108)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 150, 165)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 96, 108)),
        }),
    },
})
Fluent:RegisterCustomTheme("SlateAnimated", {
    Accent = Color3.fromRGB(140, 150, 165),
    AcrylicMain = Color3.fromRGB(22, 24, 28),
    AcrylicBorder = Color3.fromRGB(70, 75, 85),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(22, 24, 28), Color3.fromRGB(14, 15, 18)),
    AcrylicNoise = 0.6,
    TitleBarLine = Color3.fromRGB(70, 75, 85),
    Tab = Color3.fromRGB(28, 30, 35),
    Element = Color3.fromRGB(24, 26, 30),
    ElementBorder = Color3.fromRGB(60, 64, 72),
    InElementBorder = Color3.fromRGB(90, 96, 108),
    ElementTransparency = 0.82,
    ToggleSlider = Color3.fromRGB(40, 43, 48),
    ToggleToggled = Color3.fromRGB(140, 150, 165),
    SliderRail = Color3.fromRGB(40, 43, 48),
    DropdownFrame = Color3.fromRGB(20, 22, 26),
    DropdownHolder = Color3.fromRGB(14, 15, 18),
    DropdownBorder = Color3.fromRGB(60, 64, 72),
    DropdownOption = Color3.fromRGB(28, 30, 35),
    Keybind = Color3.fromRGB(28, 30, 35),
    Input = Color3.fromRGB(20, 22, 26),
    InputFocused = Color3.fromRGB(12, 13, 16),
    InputIndicator = Color3.fromRGB(90, 96, 108),
    Dialog = Color3.fromRGB(14, 15, 18),
    DialogHolder = Color3.fromRGB(12, 13, 16),
    DialogHolderLine = Color3.fromRGB(50, 54, 62),
    DialogButton = Color3.fromRGB(26, 28, 33),
    DialogButtonBorder = Color3.fromRGB(60, 64, 72),
    DialogBorder = Color3.fromRGB(60, 64, 72),
    DialogInput = Color3.fromRGB(20, 22, 26),
    DialogInputLine = Color3.fromRGB(90, 96, 108),
    Text = Color3.fromRGB(235, 237, 240),
    SubText = Color3.fromRGB(150, 155, 165),
    Hover = Color3.fromRGB(34, 37, 42),
    HoverChange = 0.04,
    ShineEnabled = true,
    Shine = {
        Speed = 0.5,
        RotationSpeed = 25,
        ColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 54, 62)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 150, 165)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 54, 62)),
        }),
    },
    StrokeShine = true,
    StrokeDark = Color3.fromRGB(50, 54, 62),
    ButtonGradient = {
        Background = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 43, 48)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 26, 30)),
        }),
        Stroke = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 96, 108)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 150, 165)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 96, 108)),
        }),
    },
})
local Window = Fluent:CreateWindow({
    Title = "NEVAHUB",
    SubTitle = "Dungeon Lootr",
    Version = "release 1.5.5",
    TabWidth = 130,
    Size = UDim2.fromOffset(580, 410),
    Acrylic = true,
    Theme = "NevahubViolet",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true,
    Icons = "solar/planet-bold",
    UserInfoTop = true,
    UserInfoTitle = "Welcome",
    UserInfoSubtitle = LocalPlayer.DisplayName,
    UserInfoColor = Color3.fromRGB(185, 70, 255),
})
Fluent:SetErrorHandler(function(msg, fullErr)
    pcall(function()
        Notify("Error", tostring(msg), "Error", nil, 5)
    end)
end)
Tabs = {}
Tabs.Info         = Window:AddTab({ Title = "Info",     Icon = "solar/info-circle-bold" })
Tabs.GUI_Settings = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold"   })
do
    local prev = _G.OxideDungeonLootr
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideDungeonLootr = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local CONFIG_NAME = "dungeonlootr"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then
        table.insert(dropdownResync, function() applyFn(handle:Get()) end)
    end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Workspace           = game:GetService("Workspace")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local VirtualUser         = game:GetService("VirtualUser")
local HttpService         = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local function Notify(title, content, kind, dur)
    pcall(function()
        Fluent:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
    end)
end
local function safeCallback(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            pcall(Notify, "NevaHub", "Error: " .. tostring(err), "Error", 4)
        end
    end
end
local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()
    local c = GetCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local c = GetCharacter()
    return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart"))
end
local function GetRootCFrame()
    local hrp = GetHRP()
    return hrp and hrp.CFrame
end
local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp or not pos then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end
local Knit
pcall(function()
    Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
end)
local function GetKnitService(name)
    if not Knit then return nil end
    local ok, svc = pcall(function() return Knit.GetService(name) end)
    return ok and svc or nil
end
local function GetKnitController(name)
    if not Knit then return nil end
    local ok, ctrl = pcall(function() return Knit.GetController(name) end)
    return ok and ctrl or nil
end
local function GetAttackRemote()
    return ReplicatedStorage:FindFirstChild("Player")
        and ReplicatedStorage.Player:FindFirstChild("Remotes")
        and ReplicatedStorage.Player.Remotes:FindFirstChild("Inputs")
        and ReplicatedStorage.Player.Remotes.Inputs:FindFirstChild("Attack")
end
local function GetSkillRemote()
    return ReplicatedStorage:FindFirstChild("Player")
        and ReplicatedStorage.Player:FindFirstChild("Remotes")
        and ReplicatedStorage.Player.Remotes:FindFirstChild("Inputs")
        and ReplicatedStorage.Player.Remotes.Inputs:FindFirstChild("Skill")
end
local function GetDashRemote()
    return ReplicatedStorage:FindFirstChild("Player")
        and ReplicatedStorage.Player:FindFirstChild("Remotes")
        and ReplicatedStorage.Player.Remotes:FindFirstChild("Inputs")
        and ReplicatedStorage.Player.Remotes.Inputs:FindFirstChild("Dash")
end
local function GetParryRemote()
    return ReplicatedStorage:FindFirstChild("Player")
        and ReplicatedStorage.Player:FindFirstChild("Remotes")
        and ReplicatedStorage.Player.Remotes:FindFirstChild("Inputs")
        and ReplicatedStorage.Player.Remotes.Inputs:FindFirstChild("Parry")
end
local function FireAttack(dir)
    local r = GetAttackRemote()
    if r then
        pcall(function() r:FireServer(dir or Vector3.new(0, 0, 1)) end)
    end
end
local function FireSkill(key, mode, dir)
    local r = GetSkillRemote()
    if r then
        pcall(function() r:FireServer(key, mode or "tap", dir or Vector3.new(0, 0, 1)) end)
    end
end
local function FireDash(dir)
    local r = GetDashRemote()
    if r then
        pcall(function() r:FireServer(dir or Vector3.new(0, 0, 1)) end)
    end
end
local function FireParry()
    local r = GetParryRemote()
    if r then
        pcall(function() r:FireServer() end)
    end
end
local ALL_ACTIVE_CODES = {
    "FULLRELEASE", "LOOTR", "LOOTRISBACK", "8KLIKE", "20KPLAYERS",
    "JACKPOT", "10KFAV", "RELEASE", "FORGESKIP", "GIVEMEGEMSPLEASE"
}
local DUNGEONS = {
    "Bandits Den", "Forest Challenge", "Goblins", "Knights", "Catacombs",
    "Snow", "Demon", "Throne Room", "Double Dungeon"
}
local DIFFICULTIES = {
    "Easy", "Normal", "Hard", "Nightmare", "Endless"
}
local BossNamesMap = {
    ["Bandit Chief"] = true,
    ["Bandit Enforcer"] = true,
    ["Knight Lord"] = true,
    ["Goblin Warchief"] = true,
    ["Awakened Devil"] = true,
    ["Frigid Monarch"] = true,
    ["Valkskar"] = true,
    ["Frost Warden"] = true,
    ["Tenebris"] = true,
    ["Karasu"] = true,
    ["Cursed King"] = true,
    ["Forge Archon"] = true,
    ["Imperator"] = true,
    ["Broken Reality"] = true,
    ["Kieru"] = true,
    ["Scarlet Knight"] = true,
    ["Shadow Monarch"] = true,
}
pcall(function()
    local ddata = require(ReplicatedStorage:WaitForChild("GameInfo"):WaitForChild("DungeonData"))
    if ddata and ddata.Dungeons then
        for _, dinfo in pairs(ddata.Dungeons) do
            if dinfo.Boss and dinfo.Boss.Name then
                BossNamesMap[dinfo.Boss.Name] = true
                local simpleName = dinfo.Boss.Name:match("^([^,]+)")
                if simpleName then BossNamesMap[simpleName] = true end
            end
            if dinfo.MiniBoss and dinfo.MiniBoss.Name then
                BossNamesMap[dinfo.MiniBoss.Name] = true
                local simpleName = dinfo.MiniBoss.Name:match("^([^,]+)")
                if simpleName then BossNamesMap[simpleName] = true end
            end
            if dinfo.SpecialBoss and dinfo.SpecialBoss.Name then
                BossNamesMap[dinfo.SpecialBoss.Name] = true
                local simpleName = dinfo.SpecialBoss.Name:match("^([^,]+)")
                if simpleName then BossNamesMap[simpleName] = true end
            end
            if dinfo.BossRotation then
                for _, b in ipairs(dinfo.BossRotation) do
                    if b.Name then
                        BossNamesMap[b.Name] = true
                        local simpleName = b.Name:match("^([^,]+)")
                        if simpleName then BossNamesMap[simpleName] = true end
                    end
                end
            end
        end
    end
end)
local function IsAlive(model)
    if not model or not model.Parent then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end
local function IsFriendlyNPC(model)
    if not model or not model.Parent then return true end
    if model.Parent.Name == "Dialogue_NPCS" or model.Parent.Name == "Dialogue" then
        return true
    end
    if model:FindFirstChild("Dialogue") or model:GetAttribute("Dialogue") then
        return true
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("ProximityPrompt") and (d.ActionText == "Talk" or d.ActionText == "Chat" or d.ActionText == "Interact") then
            return true
        end
    end
    return false
end
local function IsBoss(model)
    if not model then return false end
    local name = model.Name
    if BossNamesMap[name] then return true end
    local simpleName = name:match("^([^,]+)")
    if simpleName and BossNamesMap[simpleName] then return true end
    if model:GetAttribute("IsBoss") or model:GetAttribute("Boss") then return true end
    if model:FindFirstChild("BossBar") or model:FindFirstChild("BossHealth") then return true end
    return false
end
local function GetModelRoot(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChildWhichIsA("BasePart")
end
local function GetModelPosition(model)
    local root = GetModelRoot(model)
    if root then return root.Position, root end
    local ok, cf = pcall(function() return model:GetPivot() end)
    if ok and cf then return cf.Position, nil end
    return nil, nil
end
local function GetAllTargets(includeDummies, includeEnemies, maxDist)
    local targets = {}
    local hrp = GetHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local seen = {}
    local inDungeon = LocalPlayer:GetAttribute("InDungeon") == true
    if includeEnemies then
        local searchContainers = {}
        for _, c in ipairs(Workspace:GetChildren()) do
            if c.Name:find("Generated_") or c.Name == "Enemy Models" or c.Name == "NPCs" or c.Name == "Enemies" then
                table.insert(searchContainers, c)
            end
        end
        if not inDungeon or #searchContainers == 0 then
            table.insert(searchContainers, Workspace)
        end
        for _, container in ipairs(searchContainers) do
            local models = (container == Workspace) and container:GetChildren() or container:GetDescendants()
            for _, m in ipairs(models) do
                if m:IsA("Model") and not seen[m] and m ~= GetCharacter() and not Players:GetPlayerFromCharacter(m) then
                    if not IsFriendlyNPC(m) then
                        local hum = m:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local pos, root = GetModelPosition(m)
                            if pos then
                                seen[m] = true
                                local dist = (pos - myPos).Magnitude
                                if not maxDist or dist <= maxDist then
                                    table.insert(targets, {
                                        Model = m,
                                        HRP = root or m:FindFirstChildWhichIsA("BasePart"),
                                        Pos = pos,
                                        Dist = dist,
                                        IsBoss = IsBoss(m),
                                        Type = "Enemy"
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if includeDummies then
        local dummies = Workspace:FindFirstChild("Combat_Dummies")
        if dummies then
            for _, d in ipairs(dummies:GetChildren()) do
                if d:IsA("Model") and not seen[d] then
                    local pos, root = GetModelPosition(d)
                    if pos then
                        seen[d] = true
                        local dist = (pos - myPos).Magnitude
                        if not maxDist or dist <= maxDist then
                            table.insert(targets, {
                                Model = d,
                                HRP = root or d:FindFirstChildWhichIsA("BasePart"),
                                Pos = pos,
                                Dist = dist,
                                IsBoss = false,
                                Type = "Dummy"
                            })
                        end
                    end
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.Dist < b.Dist end)
    return targets
end
local function GetClosestTarget(targetMode, maxDist)
    local inclDummies = (targetMode == "Target Dummies" or targetMode == "All Targets" or targetMode == "Legit Directional")
    local inclEnemies = (targetMode == "Target Nearest" or targetMode == "Target Boss Only" or targetMode == "All Targets" or targetMode == "Legit Directional")
    local targets = GetAllTargets(inclDummies, inclEnemies, maxDist)
    if targetMode == "Target Boss Only" then
        for _, t in ipairs(targets) do
            if t.IsBoss then return t end
        end
        return nil
    elseif targetMode == "Target Dummies" then
        for _, t in ipairs(targets) do
            if t.Type == "Dummy" then return t end
        end
        return nil
    end
    return targets[1]
end
local killAuraEnabled     = false
local killAuraMode        = "All Targets"
local killAuraRadius      = 50
local killAuraDelay       = 0.08
local killAuraFaceTarget  = true
local autoSkillsEnabled   = false
local skill1Enabled       = true
local skill2Enabled       = true
local skill3Enabled       = true
local skill4Enabled       = true
local skillUltEnabled     = true
local autoPotionEnabled   = false
local autoPotionThreshold = 45
local hitboxExpanderEnabled = false
local hitboxSize            = 15
local hitboxTransparency    = 0.6
local autoDungeonAfkGrind = false
local selectedDungeon     = "Bandits Den"
local selectedDifficulty  = "Normal"
local autoSoloQueue       = false
local autoReplayDungeon   = false
local autoReturnLobby     = false
local autoClaimMidChests  = false
local autoClaimEndChests  = false
local autoLootRoomChests  = false
local autoLootBossChests  = false
local autoClaimAltars     = false
local autoRefillPotions   = false
local autoUnlockDoors     = false
local autoTeleportLoot    = true
local autoNextMobTeleport = false
local autoCollectDrops      = false
local autoCollectFloorGear  = false
local autoClaimAchievements = false
local autoClaimQuests       = false
local autoFreeChest         = false
local autoSellLootStorage   = false
local autoAllocateStats     = false
local autoAllocateStatChoice = "AutoAllocate"
local autoSpinEnabled       = false
local autoSpinType          = "Normal"
local function DismissChestSelectionUI()
    pcall(function()
        local csc = GetKnitController("ChestSelectionController")
        if csc then csc:_Reset() end
    end)
    pcall(function()
        local cframe = LocalPlayer.PlayerGui.Main.HUD:FindFirstChild("Chest_Selection")
        if cframe then cframe.Visible = false end
    end)
end
local function ClaimMidRunChestsInternal(ownsExtraLoot)
    local drs = GetKnitService("DungeonRunService")
    if not drs then return false end
    local picks = ownsExtraLoot and { 1, 2, 3 } or { 1, 2 }
    local ok, res = pcall(function() return drs:SelectMidRunChests(picks):await() end)
    DismissChestSelectionUI()
    return ok
end
local function ClaimEndChestsInternal(ownsExtraLoot)
    local drs = GetKnitService("DungeonRunService")
    if not drs then return false end
    local picks = ownsExtraLoot and { 1, 2, 3 } or { 1, 2 }
    local ok, res = pcall(function() return drs:SelectChests(picks):await() end)
    DismissChestSelectionUI()
    return ok
end
local function ClaimBossRushChestsInternal(ownsExtraLoot)
    local brs = GetKnitService("BossRushService")
    if not brs then return false end
    local picks = ownsExtraLoot and { 1, 2, 3 } or { 1, 2 }
    local ok, res = pcall(function() return brs:SelectFloorChests(picks):await() end)
    DismissChestSelectionUI()
    return ok
end
local function TeleportAndTriggerPrompt(prompt, returnBack)
    if not prompt or not prompt.Enabled or not prompt.Parent then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    local part = prompt.Parent
    if part:IsA("Attachment") then part = part.Parent end
    if not (part and part:IsA("BasePart")) then
        local model = prompt:FindFirstAncestorOfClass("Model")
        part = model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
    end
    if not part then return false end
    local origCf = hrp.CFrame
    local targetCf = part.CFrame + Vector3.new(0, 2, 2)
    hrp.CFrame = targetCf
    task.wait(0.06)
    pcall(function() fireproximityprompt(prompt) end)
    task.wait(0.06)
    if returnBack then
        hrp.CFrame = origCf
        task.wait(0.04)
    end
    return true
end
local function LootAllPhysicalRoomChests(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local count = 0
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and d.Name == "ChestPrompt" then
            local parentModel = d:FindFirstAncestorOfClass("Model")
            if parentModel and (parentModel.Name:find("DungeonChest") or parentModel:GetAttribute("DungeonChest") or parentModel.Name:find("BossLootChest")) then
                if autoTeleportLoot then
                    TeleportAndTriggerPrompt(d, false)
                else
                    pcall(function() fireproximityprompt(d) end)
                end
                count = count + 1
            end
        end
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return count
end
local function LootAllBossLootChests(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local count = 0
    local bossChests = Workspace:FindFirstChild("_LocalBossLootChests")
    if bossChests then
        for _, chest in ipairs(bossChests:GetChildren()) do
            local prompt = chest:FindFirstChild("ChestPrompt", true) or chest:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                if autoTeleportLoot then
                    TeleportAndTriggerPrompt(prompt, false)
                else
                    pcall(function() fireproximityprompt(prompt) end)
                end
                count = count + 1
            end
        end
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return count
end
local function ClaimAllBlessingAltars(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local count = 0
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Model") and d.Name == "Blessing_Altar" then
            local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                if autoTeleportLoot then
                    TeleportAndTriggerPrompt(prompt, false)
                else
                    pcall(function() fireproximityprompt(prompt) end)
                end
                count = count + 1
            end
        end
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return count
end
local function RefillAllPotionStations(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local count = 0
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Model") and d.Name == "Potion_Station" then
            local prompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                if autoTeleportLoot then
                    TeleportAndTriggerPrompt(prompt, false)
                else
                    pcall(function() fireproximityprompt(prompt) end)
                end
                count = count + 1
            end
        end
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return count
end
local function UnlockAllKeyDoors(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local count = 0
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and (d.ActionText:find("Key") or d.ActionText:find("Unlock") or (d.Parent and d.Parent.Name:find("KeyModel"))) then
            if autoTeleportLoot then
                TeleportAndTriggerPrompt(d, false)
            else
                pcall(function() fireproximityprompt(d) end)
            end
            count = count + 1
        end
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return count
end
local function LootEverythingInDungeon(returnBack)
    local hrp = GetHRP()
    local origCf = hrp and hrp.CFrame
    local total = 0
    total = total + LootAllPhysicalRoomChests(false)
    total = total + LootAllBossLootChests(false)
    total = total + ClaimAllBlessingAltars(false)
    total = total + RefillAllPotionStations(false)
    if autoUnlockDoors then
        total = total + UnlockAllKeyDoors(false)
    end
    if returnBack and origCf and hrp then
        hrp.CFrame = origCf
    end
    return total
end
task.spawn(function()
    while not HUB.dead do
        if killAuraEnabled or autoDungeonAfkGrind then
            local target = GetClosestTarget(killAuraMode, killAuraRadius)
            local hrp = GetHRP()
            if hrp and target and target.Pos then
                local dir = (target.Pos - hrp.Position).Unit
                if killAuraFaceTarget then
                    pcall(function()
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Pos.X, hrp.Position.Y, target.Pos.Z))
                    end)
                end
                FireAttack(dir)
            elseif hrp and killAuraMode == "Legit Directional" then
                local cam = Camera
                local camDir = cam and cam.CFrame.LookVector or Vector3.new(0, 0, 1)
                FireAttack(Vector3.new(camDir.X, 0, camDir.Z).Unit)
            end
        end
        task.wait(killAuraDelay)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoSkillsEnabled or autoDungeonAfkGrind then
            local target = GetClosestTarget("All Targets", 60)
            local hrp = GetHRP()
            if hrp then
                local dir
                if target and target.Pos then
                    dir = (target.Pos - hrp.Position).Unit
                else
                    local look = Camera and Camera.CFrame.LookVector or hrp.CFrame.LookVector
                    dir = Vector3.new(look.X, 0, look.Z).Unit
                end
                if skill1Enabled and not LocalPlayer:GetAttribute("Skill1_OnCooldown") then
                    FireSkill(1, "tap", dir)
                    task.wait(0.04)
                end
                if skill2Enabled and not LocalPlayer:GetAttribute("Skill2_OnCooldown") then
                    FireSkill(2, "tap", dir)
                    task.wait(0.04)
                end
                if skill3Enabled and not LocalPlayer:GetAttribute("Skill3_OnCooldown") then
                    FireSkill(3, "tap", dir)
                    task.wait(0.04)
                end
                if skill4Enabled and not LocalPlayer:GetAttribute("Skill4_OnCooldown") then
                    FireSkill(4, "tap", dir)
                    task.wait(0.04)
                end
                if skillUltEnabled and (LocalPlayer:GetAttribute("UltimateReady") == true or (not LocalPlayer:GetAttribute("SkillE_OnCooldown") and LocalPlayer:GetAttribute("HasUltimate") == true)) then
                    FireSkill("E", "tap", dir)
                    task.wait(0.04)
                end
            end
        end
        task.wait(0.12)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoPotionEnabled or autoDungeonAfkGrind then
            local hum = GetHumanoid()
            if hum and hum.MaxHealth > 0 then
                local hpPct = (hum.Health / hum.MaxHealth) * 100
                if hpPct <= autoPotionThreshold then
                    local ps = GetKnitService("PotionService")
                    if ps then pcall(function() ps:UsePotion(1):await() end) end
                end
            end
        end
        task.wait(0.4)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if hitboxExpanderEnabled then
            local targets = GetAllTargets(true, true, 300)
            for _, t in ipairs(targets) do
                local root = t.HRP
                if root and root.Parent then
                    pcall(function()
                        root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        root.Transparency = hitboxTransparency
                        root.CanCollide = false
                    end)
                end
            end
        end
        task.wait(1)
    end
end)
local function StartSoloDungeon(dungeonName, difficulty)
    local dqs = GetKnitService("DungeonQueueService")
    if not dqs then return false end
    local ok, res = pcall(function()
        dqs:RequestSelectMode("Solo"):await()
        dqs:RequestSelectDungeon(dungeonName):await()
        dqs:RequestSelectDifficulty(difficulty):await()
        dqs:RequestStartSoloRun():await()
    end)
    return ok
end
local function ReturnToLobby()
    local drs = GetKnitService("DungeonRunService")
    if drs then pcall(function() drs:RequestReturn():await() end) end
end
local function RequestReplay()
    local drs = GetKnitService("DungeonRunService")
    if drs then pcall(function() drs:RequestReplay():await() end) end
end
local function CollectAllFloorGear()
    local es = GetKnitService("EquipmentService")
    if not es then return false end
    local ok, res = pcall(function() return es:CollectAll():await() end)
    return ok and res
end
local function CollectDropsNearby()
    local ds = GetKnitService("DropService")
    local loot = Workspace:FindFirstChild("Loot") or Workspace:FindFirstChild("Collectables")
    if loot then
        for _, item in ipairs(loot:GetChildren()) do
            local prompt = item:FindFirstChildOfClass("ProximityPrompt") or item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
    end
    for _, c in ipairs(Workspace:GetChildren()) do
        local dropId = c:GetAttribute("DropId") or c:GetAttribute("BatchId")
        local dropType = c:GetAttribute("DropType") or "Coin"
        local dropVal = c:GetAttribute("Value") or 1
        if dropId and ds then
            pcall(function() ds:CollectDrop(dropId, dropType, dropVal):await() end)
        end
    end
end
local function ClaimAllAchievements()
    local as = GetKnitService("AchievementService")
    if not as then return false end
    local ok, res = pcall(function() return as:ClaimAll():await() end)
    return ok and res
end
local function ClaimAllQuests()
    local qs = GetKnitService("QuestService")
    if not qs then return false end
    pcall(function()
        for i = 1, 5 do
            qs:ClaimQuest("Daily", i):await()
            qs:ClaimQuest("Weekly", i):await()
        end
    end)
    return true
end
local function RedeemAllCodes()
    local cs = GetKnitService("CodesService")
    if not cs then return 0 end
    local redeemed = 0
    for _, code in ipairs(ALL_ACTIVE_CODES) do
        local ok, s1 = pcall(function() return cs:RedeemCode(code):await() end)
        if ok and s1 then redeemed = redeemed + 1 end
        task.wait(0.15)
    end
    return redeemed
end
local function ClaimFreeChest()
    local cs = GetKnitService("ChestService")
    if not cs then return false end
    local ok, res = pcall(function() return cs:ClaimFreeChest():await() end)
    return ok and res
end
local function SellAllLoot()
    local ss = GetKnitService("ShopService")
    if not ss then return false end
    local ok, res = pcall(function() return ss:SellAllLootStorage():await() end)
    return ok and res
end
local function AllocateStatPoints(choice)
    local ss = GetKnitService("StatService")
    if not ss then return false end
    pcall(function()
        if choice == "AutoAllocate" or choice == "None" then
            ss:AutoAllocate():await()
        else
            ss:AllocatePoints(choice, 5):await()
        end
    end)
    return true
end
local function SpinClass(spinType)
    local ss = GetKnitService("SummoningService")
    if not ss then return false end
    local ok, res = pcall(function() return ss:Spin(spinType, true):await() end)
    return ok and res
end
task.spawn(function()
    local drs = GetKnitService("DungeonRunService")
    if drs then
        if drs.ChestSelection then
            track(drs.ChestSelection:Connect(function(candidates, ownsExtraLoot)
                if autoClaimEndChests or autoDungeonAfkGrind then
                    task.wait(0.2)
                    ClaimEndChestsInternal(ownsExtraLoot)
                end
            end))
        end
        if drs.MidRunChestSelection then
            track(drs.MidRunChestSelection:Connect(function(candidates, ownsExtraLoot)
                if autoClaimMidChests or autoDungeonAfkGrind then
                    task.wait(0.2)
                    ClaimMidRunChestsInternal(ownsExtraLoot)
                end
            end))
        end
        if drs.DungeonComplete then
            track(drs.DungeonComplete:Connect(function()
                task.wait(1.2)
                if autoClaimEndChests or autoDungeonAfkGrind then
                    ClaimEndChestsInternal(false)
                end
                task.wait(1.5)
                if autoReplayDungeon or autoDungeonAfkGrind then
                    RequestReplay()
                elseif autoReturnLobby then
                    ReturnToLobby()
                end
            end))
        end
    end
    local brs = GetKnitService("BossRushService")
    if brs and brs.ChestSelection then
        track(brs.ChestSelection:Connect(function(candidates, ownsExtraLoot)
            if autoClaimMidChests or autoClaimEndChests or autoDungeonAfkGrind then
                task.wait(0.2)
                ClaimBossRushChestsInternal(ownsExtraLoot)
            end
        end))
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoDungeonAfkGrind then
            local inDungeon = LocalPlayer:GetAttribute("InDungeon") == true
            if inDungeon then
                local target = GetClosestTarget("Target Nearest", 2500)
                local hrp = GetHRP()
                if hrp and target and target.Pos then
                    local dist = (target.Pos - hrp.Position).Magnitude
                    if dist > 5 then
                        hrp.CFrame = CFrame.lookAt(target.Pos + Vector3.new(0, 2, 4), target.Pos)
                    else
                        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Pos.X, hrp.Position.Y, target.Pos.Z))
                    end
                else
                    LootEverythingInDungeon(false)
                    pcall(CollectDropsNearby)
                    pcall(CollectAllFloorGear)
                end
            else
                pcall(ClaimFreeChest)
                pcall(ClaimAllAchievements)
                pcall(ClaimAllQuests)
                pcall(CollectAllFloorGear)
                if autoAllocateStats then pcall(function() AllocateStatPoints(autoAllocateStatChoice) end) end
                StartSoloDungeon(selectedDungeon, selectedDifficulty)
                task.wait(4)
            end
        end
        task.wait(0.3)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoLootRoomChests or autoLootBossChests or autoClaimAltars or autoRefillPotions or autoDungeonAfkGrind then
            if LocalPlayer:GetAttribute("InDungeon") then
                pcall(function()
                    local foundAny = false
                    for _, d in ipairs(Workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and d.Enabled then
                            local model = d:FindFirstAncestorOfClass("Model")
                            local name = model and model.Name or ""
                            if (autoLootRoomChests and (name:find("DungeonChest") or d.Name == "ChestPrompt"))
                                or (autoLootBossChests and name:find("BossLootChest"))
                                or (autoClaimAltars and name:find("Blessing_Altar"))
                                or (autoRefillPotions and name:find("Potion_Station"))
                                or (autoUnlockDoors and (name:find("Locked_") or d.ActionText:find("Key"))) then
                                foundAny = true
                                break
                            end
                        end
                    end
                    if foundAny then
                        LootEverythingInDungeon(true)
                    end
                end)
                pcall(function()
                    local cframe = LocalPlayer.PlayerGui.Main.HUD:FindFirstChild("Chest_Selection")
                    if cframe and cframe.Visible then
                        ClaimMidRunChestsInternal(false)
                        ClaimEndChestsInternal(false)
                    end
                end)
            end
        end
        task.wait(1.5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoSoloQueue and not autoDungeonAfkGrind and not LocalPlayer:GetAttribute("InDungeon") then
            StartSoloDungeon(selectedDungeon, selectedDifficulty)
            task.wait(5)
        end
        task.wait(2)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoNextMobTeleport and not autoDungeonAfkGrind and LocalPlayer:GetAttribute("InDungeon") then
            local target = GetClosestTarget("Target Nearest", 2500)
            if target and target.Pos then
                local hrp = GetHRP()
                if hrp and (target.Pos - hrp.Position).Magnitude > 8 then
                    hrp.CFrame = CFrame.new(target.Pos + Vector3.new(0, 2, 4), target.Pos)
                end
            end
        end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoCollectDrops then pcall(CollectDropsNearby) end
        if autoCollectFloorGear then pcall(CollectAllFloorGear) end
        if autoClaimAchievements then pcall(ClaimAllAchievements) end
        if autoClaimQuests then pcall(ClaimAllQuests) end
        if autoFreeChest then pcall(ClaimFreeChest) end
        if autoSellLootStorage then pcall(SellAllLoot) end
        if autoAllocateStats and autoAllocateStatChoice ~= "None" then
            pcall(function() AllocateStatPoints(autoAllocateStatChoice) end)
        end
        if autoSpinEnabled then pcall(function() SpinClass(autoSpinType) end) end
        task.wait(1.5)
    end
end)
local esp = {
    enabled         = false,
    enemies         = true,
    bosses          = true,
    chests          = true,
    drops           = true,
    players         = false,
    dummies         = false,
    box             = true,
    boxStyle        = "Corner",
    names           = true,
    health          = true,
    distance        = true,
    tracers         = false,
    tracerOrigin    = "Bottom",
    chams           = true,
    maxDistance     = 600,
    enemyColor      = Color3.fromRGB(255, 65, 65),
    bossColor       = Color3.fromRGB(255, 215, 0),
    chestColor      = Color3.fromRGB(255, 170, 0),
    dropColor       = Color3.fromRGB(80, 220, 255),
    playerColor     = Color3.fromRGB(120, 255, 120),
    dummyColor      = Color3.fromRGB(200, 200, 200),
}
local hasDrawing = type(Drawing) == "table" and type(Drawing.new) == "function"
local trackedEspObjects = {}
local function createDrawingObject()
    if not hasDrawing then return {} end
    local o = {}
    o.box = trackDrawing(Drawing.new("Square"))
    o.box.Thickness = 1.5; o.box.Filled = false; o.box.Visible = false
    o.boxOutline = trackDrawing(Drawing.new("Square"))
    o.boxOutline.Thickness = 3.5; o.boxOutline.Filled = false; o.boxOutline.Color = Color3.new(0, 0, 0); o.boxOutline.Visible = false
    o.corners = {}
    for i = 1, 8 do
        local l = trackDrawing(Drawing.new("Line"))
        l.Thickness = 1.5; l.Visible = false
        table.insert(o.corners, l)
    end
    o.name = trackDrawing(Drawing.new("Text"))
    o.name.Size = 13; o.name.Center = true; o.name.Outline = true; o.name.Visible = false
    o.dist = trackDrawing(Drawing.new("Text"))
    o.dist.Size = 11; o.dist.Center = true; o.dist.Outline = true; o.dist.Visible = false
    o.hp = trackDrawing(Drawing.new("Line"))
    o.hp.Thickness = 2.5; o.hp.Visible = false
    o.hpOutline = trackDrawing(Drawing.new("Line"))
    o.hpOutline.Thickness = 4.5; o.hpOutline.Color = Color3.new(0, 0, 0); o.hpOutline.Visible = false
    o.tracer = trackDrawing(Drawing.new("Line"))
    o.tracer.Thickness = 1.2; o.tracer.Visible = false
    return o
end
local function getBox2D(model)
    if not model then return nil end
    local cf, size
    local ok, resCf, resSz = pcall(function() return model:GetBoundingBox() end)
    if ok and resCf and resSz and resSz.Magnitude > 1 then
        cf, size = resCf, resSz
    else
        local root = GetModelRoot(model)
        if not root then return nil end
        cf = root.CFrame
        size = Vector3.new(3, 5, 3)
    end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOn = false
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = (cf * CFrame.new(size.X/2 * x, size.Y/2 * y, size.Z/2 * z)).Position
                local sp, on = Camera:WorldToViewportPoint(corner)
                if sp.Z > 0 then
                    anyOn = anyOn or on
                    minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
                end
            end
        end
    end
    if minX == math.huge or not anyOn then return nil end
    return minX, minY, maxX, maxY
end
track(RunService.RenderStepped:Connect(function()
    if HUB.dead or not esp.enabled then
        for _, obj in pairs(trackedEspObjects) do
            if obj.box then obj.box.Visible = false end
            if obj.boxOutline then obj.boxOutline.Visible = false end
            if obj.corners then for _, l in ipairs(obj.corners) do l.Visible = false end end
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
            if obj.hp then obj.hp.Visible = false end
            if obj.hpOutline then obj.hpOutline.Visible = false end
            if obj.tracer then obj.tracer.Visible = false end
            if obj.highlight then obj.highlight.Enabled = false end
        end
        return
    end
    local hrp = GetHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local viewport = Camera.ViewportSize
    local renderItems = {}
    if esp.enemies or esp.bosses then
        local targets = GetAllTargets(false, true, esp.maxDistance > 0 and esp.maxDistance or nil)
        for _, t in ipairs(targets) do
            if (t.IsBoss and esp.bosses) or (not t.IsBoss and esp.enemies) then
                table.insert(renderItems, {
                    Key = t.Model,
                    Model = t.Model,
                    Name = t.IsBoss and ("[BOSS] " .. t.Model.Name) or t.Model.Name,
                    Color = t.IsBoss and esp.bossColor or esp.enemyColor,
                    Dist = t.Dist,
                    ShowHP = true,
                })
            end
        end
    end
    if esp.chests then
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("Model") and (d.Name:find("DungeonChest") or d.Name:find("BossLootChest") or d.Name == "Blessing_Altar") then
                local pos = d:GetPivot().Position
                local dist = (pos - myPos).Magnitude
                if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                    local chestName = d.Name == "Blessing_Altar" and "[ALTAR] Blessing" or (d.Name:find("BossLootChest") and "[BOSS CHEST]" or "[CHEST] Room Chest")
                    table.insert(renderItems, {
                        Key = d,
                        Model = d,
                        Name = chestName,
                        Color = esp.chestColor,
                        Dist = dist,
                        ShowHP = false,
                    })
                end
            end
        end
    end
    if esp.dummies then
        local dummies = GetAllTargets(true, false, esp.maxDistance > 0 and esp.maxDistance or nil)
        for _, t in ipairs(dummies) do
            table.insert(renderItems, {
                Key = t.Model,
                Model = t.Model,
                Name = "Dummy",
                Color = esp.dummyColor,
                Dist = t.Dist,
                ShowHP = false,
            })
        end
    end
    if esp.players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if pHrp then
                    local dist = (pHrp.Position - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        local cls = p:GetAttribute("Active_Class") or p:GetAttribute("Current_Class") or ""
                        local nameText = p.DisplayName .. (cls ~= "" and (" [" .. cls .. "]") or "")
                        table.insert(renderItems, {
                            Key = p,
                            Model = p.Character,
                            Name = nameText,
                            Color = esp.playerColor,
                            Dist = dist,
                            ShowHP = true,
                        })
                    end
                end
            end
        end
    end
    local activeKeys = {}
    for _, item in ipairs(renderItems) do
        activeKeys[item.Key] = true
        local obj = trackedEspObjects[item.Key]
        if not obj then
            obj = createDrawingObject()
            trackedEspObjects[item.Key] = obj
        end
        local leftX, topY, rightX, bottomY = getBox2D(item.Model)
        if leftX and topY and rightX and bottomY and hasDrawing then
            local w = rightX - leftX
            local h = bottomY - topY
            local cx = (leftX + rightX) / 2
            local cy = (topY + bottomY) / 2
            if esp.box then
                if esp.boxStyle == "Corner" then
                    if obj.box then obj.box.Visible = false end
                    if obj.boxOutline then obj.boxOutline.Visible = false end
                    local clen = math.clamp(w * 0.25, 4, 18)
                    local pts = {
                        { Vector2.new(leftX, topY), Vector2.new(leftX + clen, topY) },
                        { Vector2.new(leftX, topY), Vector2.new(leftX, topY + clen) },
                        { Vector2.new(rightX, topY), Vector2.new(rightX - clen, topY) },
                        { Vector2.new(rightX, topY), Vector2.new(rightX, topY + clen) },
                        { Vector2.new(leftX, bottomY), Vector2.new(leftX + clen, bottomY) },
                        { Vector2.new(leftX, bottomY), Vector2.new(leftX, bottomY - clen) },
                        { Vector2.new(rightX, bottomY), Vector2.new(rightX - clen, bottomY) },
                        { Vector2.new(rightX, bottomY), Vector2.new(rightX, bottomY - clen) },
                    }
                    for i, seg in ipairs(pts) do
                        local l = obj.corners[i]
                        if l then
                            l.From = seg[1]; l.To = seg[2]; l.Color = item.Color; l.Visible = true
                        end
                    end
                else
                    if obj.corners then for _, l in ipairs(obj.corners) do l.Visible = false end end
                    if obj.box then
                        obj.box.Position = Vector2.new(leftX, topY); obj.box.Size = Vector2.new(w, h); obj.box.Color = item.Color; obj.box.Visible = true
                    end
                    if obj.boxOutline then
                        obj.boxOutline.Position = Vector2.new(leftX, topY); obj.boxOutline.Size = Vector2.new(w, h); obj.boxOutline.Visible = true
                    end
                end
            else
                if obj.box then obj.box.Visible = false end
                if obj.boxOutline then obj.boxOutline.Visible = false end
                if obj.corners then for _, l in ipairs(obj.corners) do l.Visible = false end end
            end
            if esp.names and obj.name then
                obj.name.Text = item.Name; obj.name.Position = Vector2.new(cx, topY - 16); obj.name.Color = item.Color; obj.name.Visible = true
            elseif obj.name then obj.name.Visible = false end
            if esp.distance and obj.dist then
                obj.dist.Text = string.format("%d studs", math.floor(item.Dist)); obj.dist.Position = Vector2.new(cx, bottomY + 2); obj.dist.Color = Color3.fromRGB(220, 220, 220); obj.dist.Visible = true
            elseif obj.dist then obj.dist.Visible = false end
            local hum = item.Model:FindFirstChildOfClass("Humanoid")
            if esp.health and item.ShowHP and hum and hum.MaxHealth > 0 and obj.hp and obj.hpOutline then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barX = leftX - 6
                obj.hpOutline.From = Vector2.new(barX, bottomY); obj.hpOutline.To = Vector2.new(barX, topY); obj.hpOutline.Visible = true
                obj.hp.From = Vector2.new(barX, bottomY); obj.hp.To = Vector2.new(barX, bottomY - (h * pct))
                obj.hp.Color = Color3.fromRGB(math.floor(255 * (1 - pct)), math.floor(255 * pct), 50); obj.hp.Visible = true
            elseif obj.hp then
                obj.hp.Visible = false
                if obj.hpOutline then obj.hpOutline.Visible = false end
            end
            if esp.tracers and obj.tracer then
                local origin = Vector2.new(viewport.X / 2, viewport.Y)
                if esp.tracerOrigin == "Center" then origin = Vector2.new(viewport.X / 2, viewport.Y / 2)
                elseif esp.tracerOrigin == "Mouse" then origin = UserInputService:GetMouseLocation() end
                obj.tracer.From = origin; obj.tracer.To = Vector2.new(cx, bottomY); obj.tracer.Color = item.Color; obj.tracer.Visible = true
            elseif obj.tracer then obj.tracer.Visible = false end
        else
            if obj.box then obj.box.Visible = false end
            if obj.boxOutline then obj.boxOutline.Visible = false end
            if obj.corners then for _, l in ipairs(obj.corners) do l.Visible = false end end
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
            if obj.hp then obj.hp.Visible = false end
            if obj.hpOutline then obj.hpOutline.Visible = false end
            if obj.tracer then obj.tracer.Visible = false end
        end
        if esp.chams then
            if not obj.highlight then
                local hl = Instance.new("Highlight")
                hl.Name = "OxideHighlight"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                hl.Adornee = item.Model; hl.Parent = item.Model
                obj.highlight = hl; table.insert(HUB.highlights, hl)
            end
            obj.highlight.FillColor = item.Color; obj.highlight.OutlineColor = Color3.new(1, 1, 1); obj.highlight.Enabled = true
        elseif obj.highlight then
            obj.highlight.Enabled = false
        end
    end
    for key, obj in pairs(trackedEspObjects) do
        if not activeKeys[key] then
            if obj.box then obj.box.Visible = false end
            if obj.boxOutline then obj.boxOutline.Visible = false end
            if obj.corners then for _, l in ipairs(obj.corners) do l.Visible = false end end
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
            if obj.hp then obj.hp.Visible = false end
            if obj.hpOutline then obj.hpOutline.Visible = false end
            if obj.tracer then obj.tracer.Visible = false end
            if obj.highlight then obj.highlight.Enabled = false end
        end
    end
end))
local fullbrightEnabled = false
local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient
local defaultBrightness = Lighting.Brightness
local defaultClockTime = Lighting.ClockTime
local function SetFullbright(v)
    fullbrightEnabled = v
    if v then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = defaultAmbient
        Lighting.OutdoorAmbient = defaultOutdoor
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClockTime
    end
end
local walkSpeedEnabled = false
local walkSpeedVal     = 24
local jumpPowerEnabled = false
local jumpPowerVal     = 60
local infiniteJump     = false
local flying           = false
local flySpeed         = 60
local noclip           = false
local antiAFK          = false
local function ApplyWalkSpeed(v)
    walkSpeedVal = v
    local hum = GetHumanoid()
    if hum and walkSpeedEnabled then hum.WalkSpeed = v end
end
local function ApplyJumpPower(v)
    jumpPowerVal = v
    local hum = GetHumanoid()
    if hum and jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end
track(RunService.Stepped:Connect(function()
    if HUB.dead then return end
    local hum = GetHumanoid()
    if hum then
        if walkSpeedEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerVal end
    end
    if noclip then
        local char = GetCharacter()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end))
track(UserInputService.JumpRequest:Connect(function()
    if infiniteJump and not HUB.dead then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
local function startFly()
    if flying then return end
    local hrp = GetHRP()
    local hum = GetHumanoid()
    if not (hrp and hum) then return end
    flying = true
    hrp.Anchored = true
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1e5
    bodyGyro.P = 1e5
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    HUB._fly = {
        hrp = hrp,
        gyro = bodyGyro,
        conn = track(RunService.RenderStepped:Connect(function(dt)
            if not flying or HUB.dead then return end
            local cam = Camera
            if not cam then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            flatLook = flatLook.Magnitude > 0.001 and flatLook.Unit or Vector3.new(0, 0, -1)
            local flatRight = Vector3.new(right.X, 0, right.Z)
            flatRight = flatRight.Magnitude > 0.001 and flatRight.Unit or Vector3.new(1, 0, 0)
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + dir.Unit * flySpeed * math.min(dt, 0.1)
            end
            bodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
        end))
    }
end
local function stopFly()
    flying = false
    local f = HUB._fly
    if f then
        pcall(function() f.conn:Disconnect() end)
        pcall(function() f.hrp.Anchored = false end)
        pcall(function() f.gyro:Destroy() end)
        HUB._fly = nil
    end
end
local antiAfkConn = nil
local function SetAntiAFK(v)
    antiAFK = v
    if v and not antiAfkConn then
        antiAfkConn = track(LocalPlayer.Idled:Connect(function()
            if antiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end))
    elseif not v and antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
end
local LOBBY_LOCATIONS = {
    ["Spawn 1"]          = Vector3.new(10260.7, 1216.5, 1104.5),
    ["Spawn 2"]          = Vector3.new(10303.5, 1199.9, 149.8),
    ["Spawn 3"]          = Vector3.new(10248.2, 1187.7, 1208.2),
    ["Big Portal"]       = Vector3.new(2229.8, 605.9, -2387.5),
    ["Boss Portal"]      = Vector3.new(3099.0, 602.0, -2079.0),
    ["Secret 1"]         = Vector3.new(11601.4, 1153.5, 1243.0),
    ["PVP Arena"]        = Vector3.new(10179.4, 1187.1, 221.2),
    ["Combat Dummies"]   = Vector3.new(10200.0, 1185.0, 1050.0),
}
local LOBBY_NPCS = {
    ["Guide"]            = Vector3.new(10247.0, 1185.5, 1106.2),
    ["Forge Archon"]     = Vector3.new(10086.8, 1184.1, 1086.8),
    ["Great Mage"]       = Vector3.new(10191.3, 1184.7, 987.4),
    ["Cursed King"]      = Vector3.new(10251.2, 1184.7, 999.5),
    ["Kage"]             = Vector3.new(9998.0, 1185.1, 1033.1),
    ["Enzo"]             = Vector3.new(10092.6, 1184.3, 1053.8),
    ["Jetstream"]        = Vector3.new(10590.4, 1161.6, 1358.2),
    ["Valen"]            = Vector3.new(10737.3, 1187.6, 1337.3),
    ["Tenjin"]           = Vector3.new(10204.5, 1182.1, 1225.0),
    ["Genesis"]          = Vector3.new(10272.1, 1194.2, 214.8),
    ["Rose"]             = Vector3.new(10281.0, 1185.6, 1030.4),
    ["Hitman"]           = Vector3.new(10135.7, 1181.8, 977.5),
    ["Group Chest NPC"]  = Vector3.new(10280.4, 1180.8, 1165.5),
}
local selectedLobbyLocation = "Spawn 1"
local selectedLobbyNpc      = "Guide"
local locKeys = {}
for k in pairs(LOBBY_LOCATIONS) do table.insert(locKeys, k) end
table.sort(locKeys)
local npcKeys = {}
for k in pairs(LOBBY_NPCS) do table.insert(npcKeys, k) end
table.sort(npcKeys)
local CombatTab   = Window:AddTab({ Title = "Combat", Icon = "solar/sword-bold" })
local EconomyTab  = Window:AddTab({ Title = "Economy", Icon = "solar/bolt-bold" })
local VisualsTab  = Window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
local PlayerTab   = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })
local AuraSub          = CombatTab:AddSection("Kill Aura", "solar/home-bold")
local SkillsSub        = CombatTab:AddSection("Auto Skills", "solar/home-bold")
local HitboxSub        = CombatTab:AddSection("Hitbox Expander", "solar/home-bold")
local DungeonFarmSub   = CombatTab:AddSection("Auto Dungeon", "solar/home-bold")
local DungeonChestsSub = CombatTab:AddSection("Chests & Rewards", "solar/home-bold")
AuraSub:AddToggle({
    Title = "Kill Aura / Auto Attack", Default = false, Flag = "combat_killaura",
    Callback = safeCallback(function(v)
        killAuraEnabled = v
        Notify("Kill Aura", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
AuraSub:AddDropdown({
    Title = "Target Filter", Values = { "All Targets", "Target Nearest", "Target Boss Only", "Target Dummies", "Legit Directional" },
    Items = { "All Targets", "Target Nearest", "Target Boss Only", "Target Dummies", "Legit Directional" },
    Default = "All Targets", Flag = "combat_mode", Callback = function(v) killAuraMode = v end
})
AuraSub:AddSlider({
    Title = "Aura Radius", Min = 10, Max = 150, Default = 50, Suffix = " studs", Flag = "combat_radius",
    Callback = function(v) killAuraRadius = v end
})
AuraSub:AddSlider({
    Title = "Attack Delay", Min = 0.04, Max = 0.5, Default = 0.08, Suffix = "s", Flag = "combat_delay",
    Callback = function(v) killAuraDelay = v end
})
AuraSub:AddToggle({
    Title = "Auto Face Target", Default = true, Flag = "combat_face",
    Callback = function(v) killAuraFaceTarget = v end
})
AuraSub:AddButton({
    Title = "Attack Once (Manual)", Primary = true,
    Callback = safeCallback(function()
        local t = GetClosestTarget(killAuraMode, killAuraRadius)
        local hrp = GetHRP()
        local dir = (t and t.Pos and hrp) and (t.Pos - hrp.Position).Unit or (Camera and Camera.CFrame.LookVector) or Vector3.new(0, 0, 1)
        FireAttack(dir)
        Notify("Attack", "Fired attack", "Info")
    end)
})
SkillsSub:AddToggle({
    Title = "Auto Cast All Skills", Default = false, Flag = "skills_auto",
    Callback = safeCallback(function(v)
        autoSkillsEnabled = v
        Notify("Auto Skills", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
SkillsSub:AddDivider()
SkillsSub:AddToggle({ Title = "Cast Skill 1", Default = true, Flag = "skill_1", Callback = function(v) skill1Enabled = v end })
SkillsSub:AddToggle({ Title = "Cast Skill 2", Default = true, Flag = "skill_2", Callback = function(v) skill2Enabled = v end })
SkillsSub:AddToggle({ Title = "Cast Skill 3", Default = true, Flag = "skill_3", Callback = function(v) skill3Enabled = v end })
SkillsSub:AddToggle({ Title = "Cast Skill 4", Default = true, Flag = "skill_4", Callback = function(v) skill4Enabled = v end })
SkillsSub:AddToggle({ Title = "Cast Ultimate (Skill E)", Default = true, Flag = "skill_ult", Callback = function(v) skillUltEnabled = v end })
SkillsSub:AddDivider()
SkillsSub:AddButton({
    Title = "Cast All Ready Skills (Manual)", Primary = true,
    Callback = safeCallback(function()
        local t = GetClosestTarget("All Targets", 60)
        local hrp = GetHRP()
        local dir = (t and t.Pos and hrp) and (t.Pos - hrp.Position).Unit or (Camera and Camera.CFrame.LookVector) or Vector3.new(0, 0, 1)
        if not LocalPlayer:GetAttribute("Skill1_OnCooldown") then FireSkill(1, "tap", dir) end
        if not LocalPlayer:GetAttribute("Skill2_OnCooldown") then FireSkill(2, "tap", dir) end
        if not LocalPlayer:GetAttribute("Skill3_OnCooldown") then FireSkill(3, "tap", dir) end
        if not LocalPlayer:GetAttribute("Skill4_OnCooldown") then FireSkill(4, "tap", dir) end
        if LocalPlayer:GetAttribute("UltimateReady") == true or (not LocalPlayer:GetAttribute("SkillE_OnCooldown") and LocalPlayer:GetAttribute("HasUltimate") == true) then
            FireSkill("E", "tap", dir)
        end
        Notify("Skills", "Casting all ready skills", "Info")
    end)
})
SkillsSub:AddButton({
    Title = "Cast Ultimate Now",
    Callback = safeCallback(function()
        local t = GetClosestTarget("All Targets", 60)
        local hrp = GetHRP()
        local dir = (t and t.Pos and hrp) and (t.Pos - hrp.Position).Unit or (Camera and Camera.CFrame.LookVector) or Vector3.new(0, 0, 1)
        FireSkill("E", "tap", dir)
        Notify("Ultimate", "Fired ultimate skill", "Info")
    end)
})
SkillsSub:AddDivider()
SkillsSub:AddToggle({
    Title = "Auto Health Potion", Default = false, Flag = "auto_potion",
    Callback = safeCallback(function(v)
        autoPotionEnabled = v
        Notify("Auto Potion", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
SkillsSub:AddSlider({
    Title = "Drink When Health Below", Min = 10, Max = 90, Default = 45, Suffix = "%", Flag = "potion_threshold",
    Callback = function(v) autoPotionThreshold = v end
})
SkillsSub:AddButton({
    Title = "Drink Potion Now", Primary = true,
    Callback = safeCallback(function()
        local ps = GetKnitService("PotionService")
        if ps then
            ps:UsePotion(1):await()
            Notify("Potion", "Used equipped health potion", "Success")
        end
    end)
})
HitboxSub:AddToggle({
    Title = "Hitbox Expander", Default = false, Flag = "hitbox_enabled",
    Callback = safeCallback(function(v)
        hitboxExpanderEnabled = v
        Notify("Hitbox Expander", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
HitboxSub:AddSlider({
    Title = "Hitbox Size", Min = 5, Max = 50, Default = 15, Suffix = " studs", Flag = "hitbox_size",
    Callback = function(v) hitboxSize = v end
})
HitboxSub:AddSlider({
    Title = "Hitbox Transparency", Min = 0, Max = 1, Default = 0.6, Suffix = "", Flag = "hitbox_trans",
    Callback = function(v) hitboxTransparency = v end
})
DungeonFarmSub:AddDivider()
DungeonFarmSub:AddToggle({
    Title = "AFK Dungeon Grinder (Auto Clear & Farm)", Default = false, Flag = "dungeon_afk_grind",
    Callback = safeCallback(function(v)
        autoDungeonAfkGrind = v
        if v then
            killAuraEnabled = true
            autoSkillsEnabled = true
            autoPotionEnabled = true
        end
        Notify("AFK Grinder", v and "Started AFK Dungeon Loop!" or "Stopped AFK Loop", v and "Success" or "Info")
    end)
})
DungeonFarmSub:AddDivider()
DungeonFarmSub:AddDropdown({
    Title = "Select Dungeon", Options = DUNGEONS, Items = DUNGEONS, Default = "Bandits Den", Flag = "dungeon_choice",
    Callback = function(v) selectedDungeon = v end
})
DungeonFarmSub:AddDropdown({
    Title = "Select Difficulty", Options = DIFFICULTIES, Items = DIFFICULTIES,
    Default = "Normal", Flag = "dungeon_diff", Callback = function(v) selectedDifficulty = v end
})
DungeonFarmSub:AddToggle({
    Title = "Auto Solo Queue (Lobby)", Default = false, Flag = "dungeon_auto_queue",
    Callback = safeCallback(function(v)
        autoSoloQueue = v
        Notify("Auto Queue", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
DungeonFarmSub:AddToggle({
    Title = "Auto Replay on Victory", Default = false, Flag = "dungeon_auto_replay",
    Callback = function(v) autoReplayDungeon = v end
})
DungeonFarmSub:AddToggle({
    Title = "Auto Return to Lobby", Default = false, Flag = "dungeon_auto_return",
    Callback = function(v) autoReturnLobby = v end
})
DungeonFarmSub:AddToggle({
    Title = "Auto Mob Teleport (Dungeon)", Default = false, Flag = "dungeon_auto_mobtp",
    Callback = safeCallback(function(v)
        autoNextMobTeleport = v
        Notify("Mob Teleport", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
DungeonFarmSub:AddButton({
    Title = "Start Selected Dungeon Solo Now", Primary = true,
    Callback = safeCallback(function()
        local ok = StartSoloDungeon(selectedDungeon, selectedDifficulty)
        Notify("Dungeon Queue", ok and ("Queued " .. selectedDungeon .. " (" .. selectedDifficulty .. ")") or "Queue request failed", ok and "Success" or "Error")
    end)
})
DungeonFarmSub:AddButton({
    Title = "Return to Lobby Now",
    Callback = safeCallback(function()
        ReturnToLobby()
        Notify("Lobby", "Requested return to lobby", "Info")
    end)
})
DungeonChestsSub:AddDivider()
DungeonChestsSub:AddToggle({
    Title = "Auto Claim Mid-Run Chests (GUI)", Default = false, Flag = "chests_midrun",
    Callback = function(v) autoClaimMidChests = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Claim End-Run Chests (GUI)", Default = false, Flag = "chests_endrun",
    Callback = function(v) autoClaimEndChests = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Loot Room Chests (Physical TP)", Default = false, Flag = "chests_room",
    Callback = function(v) autoLootRoomChests = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Loot Boss Chests (Physical TP)", Default = false, Flag = "chests_boss",
    Callback = function(v) autoLootBossChests = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Claim Blessing Altars (TP)", Default = false, Flag = "altars_auto",
    Callback = function(v) autoClaimAltars = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Refill Potion Stations (TP)", Default = false, Flag = "potions_station_auto",
    Callback = function(v) autoRefillPotions = v end
})
DungeonChestsSub:AddToggle({
    Title = "Auto Unlock Key Doors (TP)", Default = false, Flag = "doors_unlock_auto",
    Callback = function(v) autoUnlockDoors = v end
})
DungeonChestsSub:AddToggle({
    Title = "Instant Teleport-Loot (Bypass Distance)", Default = true, Flag = "teleport_loot_enabled",
    Callback = function(v) autoTeleportLoot = v end
})
DungeonChestsSub:AddDivider()
DungeonChestsSub:AddButton({
    Title = "Loot All Chests & Altars in Dungeon", Primary = true,
    Callback = safeCallback(function()
        local count = LootEverythingInDungeon(true)
        Notify("Dungeon Loot", "Instant-looted " .. count .. " items / altars / chests!", "Success")
    end)
})
DungeonChestsSub:AddButton({
    Title = "Claim Mid-Run / End-Run Chests (GUI)", Primary = true,
    Callback = safeCallback(function()
        ClaimMidRunChestsInternal(false)
        ClaimEndChestsInternal(false)
        Notify("Reward Chests", "Claimed active reward chests", "Success")
    end)
})
DungeonChestsSub:AddButton({
    Title = "Loot All Room Chests (TP)",
    Callback = safeCallback(function()
        local c = LootAllPhysicalRoomChests(true)
        Notify("Room Chests", "Looted " .. c .. " chest(s)", "Success")
    end)
})
DungeonChestsSub:AddButton({
    Title = "Loot All Boss Chests (TP)",
    Callback = safeCallback(function()
        local c = LootAllBossLootChests(true)
        Notify("Boss Chests", "Looted " .. c .. " boss chest(s)", "Success")
    end)
})
DungeonChestsSub:AddButton({
    Title = "Claim Blessing Altars & Refill Potions (TP)",
    Callback = safeCallback(function()
        local b = ClaimAllBlessingAltars(true)
        local p = RefillAllPotionStations(true)
        Notify("Altars & Stations", "Claimed " .. b .. " altar(s), " .. p .. " station(s)", "Success")
    end)
})
DungeonChestsSub:AddButton({
    Title = "Unlock All Key Doors (TP)",
    Callback = safeCallback(function()
        local d = UnlockAllKeyDoors(true)
        Notify("Key Doors", "Unlocked " .. d .. " door(s)", "Success")
    end)
})
local DropsSub   = EconomyTab:AddSection("Drops & Gear", "solar/home-bold")
local QuestsSub  = EconomyTab:AddSection("Quests & Codes", "solar/home-bold")
local SummonSub  = EconomyTab:AddSection("Summon & Gacha", "solar/home-bold")
local ShopSub    = EconomyTab:AddSection("Shop & Stats", "solar/home-bold")
DropsSub:AddToggle({
    Title = "Auto Collect Drops (Coins/Gems/Stones)", Default = false, Flag = "drops_auto",
    Callback = safeCallback(function(v)
        autoCollectDrops = v
        Notify("Auto Collect Drops", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
DropsSub:AddToggle({
    Title = "Auto Collect Floor Gear", Default = false, Flag = "gear_auto_collect",
    Callback = function(v) autoCollectFloorGear = v end
})
DropsSub:AddButton({
    Title = "Collect All Floor Gear Now", Primary = true,
    Callback = safeCallback(function()
        local ok = CollectAllFloorGear()
        Notify("Floor Gear", ok and "Collected all floor items" or "Failed or no items", ok and "Success" or "Info")
    end)
})
DropsSub:AddButton({
    Title = "Collect Drops Nearby Now",
    Callback = safeCallback(function()
        CollectDropsNearby()
        Notify("Drops", "Triggered collection for nearby drops", "Success")
    end)
})
QuestsSub:AddToggle({
    Title = "Auto Claim Achievements", Default = false, Flag = "ach_auto_claim",
    Callback = function(v) autoClaimAchievements = v end
})
QuestsSub:AddToggle({
    Title = "Auto Claim Quests (Daily/Weekly)", Default = false, Flag = "quest_auto_claim",
    Callback = function(v) autoClaimQuests = v end
})
QuestsSub:AddButton({
    Title = "Claim All Achievements Now", Primary = true,
    Callback = safeCallback(function()
        local ok = ClaimAllAchievements()
        Notify("Achievements", ok and "Claimed all ready achievements" or "No unclaimed achievements", ok and "Success" or "Info")
    end)
})
QuestsSub:AddButton({
    Title = "Claim All Quests Now",
    Callback = safeCallback(function()
        ClaimAllQuests()
        Notify("Quests", "Claimed all ready Daily & Weekly quests", "Success")
    end)
})
QuestsSub:AddButton({
    Title = "Redeem All Active Codes (" .. #ALL_ACTIVE_CODES .. " Codes)", Primary = true,
    Callback = safeCallback(function()
        Notify("Codes", "Redeeming all active codes...", "Info")
        task.spawn(function()
            local n = RedeemAllCodes()
            Notify("Codes", "Redeemed active codes! (" .. n .. " successful)", "Success")
        end)
    end)
})
SummonSub:AddDropdown({
    Title = "Spin Type", Values = { "Normal", "Lucky" }, Items = { "Normal", "Lucky" }, Default = "Normal", Flag = "spin_type",
    Callback = function(v) autoSpinType = v end
})
SummonSub:AddToggle({
    Title = "Auto Spin Classes", Default = false, Flag = "spin_auto",
    Callback = safeCallback(function(v)
        autoSpinEnabled = v
        Notify("Auto Spin", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
SummonSub:AddButton({
    Title = "Spin Once (Normal)", Primary = true,
    Callback = safeCallback(function()
        local ok = SpinClass("Normal")
        Notify("Summon", ok and "Spun normal class" or "Spin failed", ok and "Success" or "Error")
    end)
})
SummonSub:AddButton({
    Title = "Spin Once (Lucky)",
    Callback = safeCallback(function()
        local ok = SpinClass("Lucky")
        Notify("Summon", ok and "Spun lucky class" or "Spin failed", ok and "Success" or "Error")
    end)
})
ShopSub:AddToggle({
    Title = "Auto Sell Loot Storage", Default = false, Flag = "sell_auto_loot",
    Callback = function(v) autoSellLootStorage = v end
})
ShopSub:AddDropdown({
    Title = "Stat Allocation Target", Values = { "AutoAllocate", "STR", "DEX", "INT", "VIT", "LCK", "None" },
    Items = { "AutoAllocate", "STR", "DEX", "INT", "VIT", "LCK", "None" },
    Default = "AutoAllocate", Flag = "stat_target", Callback = function(v) autoAllocateStatChoice = v end
})
ShopSub:AddToggle({
    Title = "Auto Spend Stat Points", Default = false, Flag = "stat_auto_spend",
    Callback = function(v) autoAllocateStats = v end
})
ShopSub:AddButton({
    Title = "Sell All Loot Storage Now", Primary = true,
    Callback = safeCallback(function()
        local ok = SellAllLoot()
        Notify("Shop", ok and "Sold all loot storage items" or "Failed or nothing to sell", ok and "Success" or "Info")
    end)
})
ShopSub:AddButton({
    Title = "Claim Free Daily Chest Now",
    Callback = safeCallback(function()
        local ok = ClaimFreeChest()
        Notify("Chest", ok and "Claimed free daily chest" or "Chest not ready", ok and "Success" or "Info")
    end)
})
ShopSub:AddButton({
    Title = "Auto Allocate Stats Now",
    Callback = safeCallback(function()
        AllocateStatPoints(autoAllocateStatChoice)
        Notify("Stats", "Allocated available stat points", "Success")
    end)
})
local EspSettingsSub = VisualsTab:AddSection("ESP Configuration", "solar/home-bold")
local EspWorldSub    = VisualsTab:AddSection("World & Lighting", "solar/home-bold")
EspSettingsSub:AddToggle({
    Title = "Master ESP Enabled", Default = false, Flag = "esp_master",
    Callback = safeCallback(function(v)
        esp.enabled = v
        Notify("ESP", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
EspSettingsSub:AddDivider()
EspSettingsSub:AddToggle({ Title = "Enemies ESP", Default = true, Flag = "esp_enemies", Callback = function(v) esp.enemies = v end })
EspSettingsSub:AddToggle({ Title = "Bosses ESP", Default = true, Flag = "esp_bosses", Callback = function(v) esp.bosses = v end })
EspSettingsSub:AddToggle({ Title = "Chests & Altars ESP", Default = true, Flag = "esp_chests", Callback = function(v) esp.chests = v end })
EspSettingsSub:AddToggle({ Title = "Players ESP", Default = false, Flag = "esp_players", Callback = function(v) esp.players = v end })
EspSettingsSub:AddToggle({ Title = "Combat Dummies ESP", Default = false, Flag = "esp_dummies", Callback = function(v) esp.dummies = v end })
EspSettingsSub:AddDivider()
EspSettingsSub:AddToggle({ Title = "Bounding Box", Default = true, Flag = "esp_box", Callback = function(v) esp.box = v end })
EspSettingsSub:AddDropdown({
    Title = "Box Style", Values = { "Corner", "Full" }, Items = { "Corner", "Full" }, Default = "Corner", Flag = "esp_box_style",
    Callback = function(v) esp.boxStyle = v end
})
EspSettingsSub:AddToggle({ Title = "Name Tags", Default = true, Flag = "esp_names", Callback = function(v) esp.names = v end })
EspSettingsSub:AddToggle({ Title = "Health Bars", Default = true, Flag = "esp_hp", Callback = function(v) esp.health = v end })
EspSettingsSub:AddToggle({ Title = "Distance Text", Default = true, Flag = "esp_dist", Callback = function(v) esp.distance = v end })
EspSettingsSub:AddToggle({ Title = "Snaplines / Tracers", Default = false, Flag = "esp_tracers", Callback = function(v) esp.tracers = v end })
EspSettingsSub:AddDropdown({
    Title = "Tracer Origin", Values = { "Bottom", "Center", "Mouse" }, Items = { "Bottom", "Center", "Mouse" }, Default = "Bottom", Flag = "esp_tracer_origin",
    Callback = function(v) esp.tracerOrigin = v end
})
EspSettingsSub:AddToggle({ Title = "Chams / Highlights", Default = true, Flag = "esp_chams", Callback = function(v) esp.chams = v end })
EspSettingsSub:AddSlider({ Title = "Max ESP Distance", Min = 50, Max = 1500, Default = 600, Suffix = " studs", Flag = "esp_maxdist", Callback = function(v) esp.maxDistance = v end })
EspWorldSub:AddToggle({
    Title = "Fullbright (Max Brightness)", Default = false, Flag = "world_fullbright",
    Callback = safeCallback(function(v)
        SetFullbright(v)
        Notify("Fullbright", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
EspWorldSub:AddDivider()
EspWorldSub:AddColorPicker({ Name = "Enemy Color", Default = esp.enemyColor, Flag = "col_enemy", Callback = function(c) esp.enemyColor = c end })
EspWorldSub:AddColorPicker({ Name = "Boss Color", Default = esp.bossColor, Flag = "col_boss", Callback = function(c) esp.bossColor = c end })
EspWorldSub:AddColorPicker({ Name = "Chest Color", Default = esp.chestColor, Flag = "col_chest", Callback = function(c) esp.chestColor = c end })
EspWorldSub:AddColorPicker({ Name = "Player Color", Default = esp.playerColor, Flag = "col_player", Callback = function(c) esp.playerColor = c end })
EspWorldSub:AddColorPicker({ Name = "Dummy Color", Default = esp.dummyColor, Flag = "col_dummy", Callback = function(c) esp.dummyColor = c end })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
local TeleSub = PlayerTab:AddSection("Teleports", "solar/home-bold")
MoveSub:AddToggle({
    Title = "Enable WalkSpeed", Default = false, Flag = "speed_enabled",
    Callback = safeCallback(function(v)
        walkSpeedEnabled = v
        if not v then
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
        Notify("WalkSpeed", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
MoveSub:AddSlider({
    Title = "WalkSpeed Multiplier", Min = 16, Max = 200, Default = 24, Suffix = " studs/s", Flag = "speed_val",
    Callback = function(v) ApplyWalkSpeed(v) end
})
MoveSub:AddToggle({
    Title = "Enable JumpPower", Default = false, Flag = "jump_enabled",
    Callback = safeCallback(function(v)
        jumpPowerEnabled = v
        if not v then
            local hum = GetHumanoid()
            if hum then hum.JumpPower = 50 end
        end
        Notify("JumpPower", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
MoveSub:AddSlider({
    Title = "JumpPower", Min = 50, Max = 300, Default = 60, Suffix = "", Flag = "jump_val",
    Callback = function(v) ApplyJumpPower(v) end
})
MoveSub:AddToggle({
    Title = "Infinite Jump", Default = false, Flag = "inf_jump",
    Callback = function(v) infiniteJump = v end
})
MoveSub:AddToggle({
    Title = "Smooth Fly (WASD + Space/Shift)", Default = false, Flag = "fly_enabled",
    Callback = safeCallback(function(v)
        if v then startFly() else stopFly() end
        Notify("Fly", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
MoveSub:AddSlider({
    Title = "Fly Speed", Min = 20, Max = 250, Default = 60, Suffix = " studs/s", Flag = "fly_speed",
    Callback = function(v) flySpeed = v end
})
MoveSub:AddToggle({
    Title = "Noclip (Walk Through Walls)", Default = false, Flag = "noclip_enabled",
    Callback = safeCallback(function(v)
        noclip = v
        if not v then
            local char = GetCharacter()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
        Notify("Noclip", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
MoveSub:AddToggle({
    Title = "Anti-AFK (Bypass 20min Kick)", Default = false, Flag = "anti_afk",
    Callback = function(v) SetAntiAFK(v) end
})
TeleSub:AddDivider()
TeleSub:AddDropdown({
    Title = "Select Location", Options = locKeys, Items = locKeys, Default = "Spawn 1", Flag = "tele_loc",
    Callback = function(v) selectedLobbyLocation = v end
})
TeleSub:AddButton({
    Title = "Teleport to Location", Primary = true,
    Callback = safeCallback(function()
        local pos = LOBBY_LOCATIONS[selectedLobbyLocation]
        if pos and TeleportTo(pos) then
            Notify("Teleport", "Teleported to " .. selectedLobbyLocation, "Success")
        else
            Notify("Teleport", "Teleport failed", "Error")
        end
    end)
})
TeleSub:AddDivider()
TeleSub:AddDropdown({
    Title = "Select NPC", Options = npcKeys, Items = npcKeys, Default = "Guide", Flag = "tele_npc",
    Callback = function(v) selectedLobbyNpc = v end
})
TeleSub:AddButton({
    Title = "Teleport to NPC", Primary = true,
    Callback = safeCallback(function()
        local pos = LOBBY_NPCS[selectedLobbyNpc]
        if pos and TeleportTo(pos) then
            Notify("Teleport", "Teleported to " .. selectedLobbyNpc, "Success")
        else
            Notify("Teleport", "Teleport failed", "Error")
        end
    end)
})
TeleSub:AddDivider()
TeleSub:AddButton({
    Title = "Teleport to Nearest Enemy / Mob",
    Callback = safeCallback(function()
        local target = GetClosestTarget("Target Nearest", 2500)
        if target and target.Pos and TeleportTo(target.Pos + Vector3.new(0, 2, 4)) then
            Notify("Teleport", "Teleported near " .. target.Model.Name, "Success")
        else
            Notify("Teleport", "No target found in range", "Info")
        end
    end)
})
local ConfigSub = SettingsTab:AddSection("Configuration", "solar/home-bold")
if HAS_CONFIG then
    ConfigSub:AddInput({
        Title = "Config Name", Default = CONFIG_NAME, Flag = "cfg_name",
        Callback = function(v) if v and #v > 0 then CONFIG_NAME = v end end
    })
    ConfigSub:AddButton({
        Title = "Save Config", Primary = true,
        Callback = safeCallback(function()
            local ok, err = Library:SaveConfig(CONFIG_NAME)
            Notify("Config", ok and ("Saved config '" .. CONFIG_NAME .. "'") or ("Save failed: " .. tostring(err)), ok and "Success" or "Error")
        end)
    })
    ConfigSub:AddButton({
        Title = "Load Config",
        Callback = safeCallback(function()
            local ok, err = Library:LoadConfig(CONFIG_NAME)
            if ok then
                ResyncAll()
                Notify("Config", "Loaded config '" .. CONFIG_NAME .. "'", "Success")
            else
                Notify("Config", "Load failed: " .. tostring(err), "Error")
            end
        end)
    })
end
ConfigSub:AddKeybind({
    Title = "Toggle UI Keybind", Default = Enum.KeyCode.RightControl, Flag = "ui_toggle_key",
    OnPress = function()
        Window:Toggle()
    end
})
ConfigSub:AddDivider()
ConfigSub:AddButton({
    Title = "Unload Oxide HUB",
    Callback = safeCallback(function()
        pcall(function() HUB.Unload() end)
    end)
})
ConfigSub:AddParagraph({
    Title = "NevaHub DungeonLootr",
    Content = "Version 1.2.0 (Production)\nDeveloped for Dungeon-Lootr.\nIncludes full combat aura, automated AFK dungeon grinder, drops collector, instant-teleport room & boss chest looter, mid-run & end-run auto reward claims, ESP suite and movement exploits."
})
HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    HUB.conns = {}
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    HUB.drawings = {}
    for _, h in ipairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    HUB.highlights = {}
    stopFly()
    SetFullbright(false)
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    local char = GetCharacter()
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    pcall(function() Window:Destroy() end)
    _G.OxideDungeonLootr = nil
end
Notify("NevaHub", "Dungeon-Lootr script loaded successfully!", "Success", 3.5)
local secInfo = Tabs.Info:AddSection("Information", "solar/info-square-bold")
secInfo:AddParagraph({
    Title = "NEVAHUB Discord",
    Content = "Join our community for updates and support!"
})
secInfo:AddDiscord({
    InviteCode = "GTMEDtwmva"
})
secInfo:AddDivider()
secInfo:AddParagraph({
    Title = "Credits",
    Content = "NEVA"
})
local secInterface = Tabs.GUI_Settings:AddSection("Interface Settings", "solar/monitor-bold")
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentShowcase")
InterfaceManager:BuildInterfaceSection(Tabs.GUI_Settings)
local secCustomTheme = Tabs.GUI_Settings:AddSection("Custom Themes", "solar/star-bold")
secCustomTheme:AddButton({
    Title = "Apply NeonBlue", Icon = "solar/star-bold",
    Callback = function()
        Fluent:SetTheme("NeonBlue")
        Notify("Theme", "NeonBlue applied", "Success", nil, 2)
    end,
})
secCustomTheme:AddButton({
    Title = "Apply EmeraldDark", Icon = "solar/leaf-bold",
    Callback = function()
        Fluent:SetTheme("EmeraldDark")
        Notify("Theme", "EmeraldDark applied", "Success", nil, 2)
    end,
})
secCustomTheme:AddButton({
    Title = "Apply Sunset", Icon = "solar/sun-bold",
    Callback = function()
        Fluent:SetTheme("Sunset")
        Notify("Theme", "Sunset applied", "Success", nil, 2)
    end,
})
secCustomTheme:AddButton({
    Title = "Apply NevahubViolet", Icon = "solar/palette-bold",
    Callback = function()
        Fluent:SetTheme("NevahubViolet")
        Notify("Theme", "NevahubViolet applied", "Success", nil, 2)
    end,
})
secCustomTheme:AddDivider()
secCustomTheme:AddButton({
    Title = "Apply SlateStatic", Icon = "solar/pause-circle-bold",
    Callback = function()
        Fluent:SetTheme("SlateStatic")
        Notify("Theme", "SlateStatic applied — this theme never animates", "Info", nil, 3)
    end,
})
secCustomTheme:AddButton({
    Title = "Apply SlateAnimated", Icon = "solar/play-circle-bold",
    Callback = function()
        Fluent:SetTheme("SlateAnimated")
        Notify("Theme", "SlateAnimated applied — try toggling Animated Window", "Info", nil, 3)
    end,
})
local secConfig = Tabs.GUI_Settings:AddSection("Configuration", "solar/diskette-bold")
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("FluentShowcase/Config")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs.GUI_Settings)
SaveManager:LoadAutoloadConfig()
local secFloating = Tabs.GUI_Settings:AddSection("Floating Buttons", "solar/widget-bold")
FloatingButtonManager:SetLibrary(Fluent)
FloatingButtonManager:SetFolder("FluentShowcase/Floating")
FloatingButtonManager:BuildConfigSection(Tabs.GUI_Settings)
FloatingButtonManager:LoadAutoloadConfig()
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "OpenUi"
toggleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.ResetOnSpawn = false
local mainBtn = Instance.new("TextButton")
mainBtn.Name = "OpenButton"
mainBtn.Parent = toggleGui
mainBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainBtn.BackgroundTransparency = 1
mainBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
mainBtn.Size = UDim2.new(0, 64, 0, 40)
mainBtn.Text = ""
mainBtn.Visible = true
Instance.new("UICorner", mainBtn)
local sizeBackMulti = 0.3
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "RotatingBackground"
backgroundImage.Parent = mainBtn
backgroundImage.Size = UDim2.new(2.3 + sizeBackMulti, 0, 2.3 + sizeBackMulti, 0)
backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = "rbxassetid://116852560271675"
backgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainBtn
frontImage.Size = UDim2.fromOffset(55, 55)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = "rbxassetid://120536599901920"
frontImage.ZIndex = 1
Instance.new("UICorner", frontImage).CornerRadius = UDim.new(0.2, 0)
local rotation = 0
local rotSpeed = 90
local lastTime = tick()
task.spawn(function()
    while true do
        local now = tick()
        local delta = now - lastTime
        lastTime = now
        rotation = (rotation + rotSpeed * delta) % 360
        backgroundImage.Rotation = rotation
        task.wait()
    end
end)
local function MakeDraggableOpenUi(topbar, obj)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local holdingDrag, holdToken = false, 0
    obj:SetAttribute("Locked", false)
    local function Update(input)
        if obj:GetAttribute("Locked") then return end
        local delta = input.Position - dragStart
        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    local function ToggleLock()
        local newState = not obj:GetAttribute("Locked")
        obj:SetAttribute("Locked", newState)
        Notify(newState and "Locked" or "Unlocked", newState and "Locked in place" or "Can be moved", "Info", nil, 2)
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = not obj:GetAttribute("Locked")
        holdingDrag = true
        dragStart = input.Position
        startPos = obj.Position
        holdToken = holdToken + 1
        local token = holdToken
        task.delay(1.0, function()
            if holdingDrag and token == holdToken then ToggleLock() end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                holdingDrag = false
            end
        end)
    end)
    topbar.InputChanged:Connect(function(input)
        if not dragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - dragStart).Magnitude > 6 then holdingDrag = false end
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then Update(input) end
    end)
end
MakeDraggableOpenUi(mainBtn, mainBtn)
local uiOpen = true
local function PlaySound(soundId)
    local sound = Instance.new("Sound")
    pcall(function() sound.SoundId = "rbxassetid://" .. soundId end)
    sound.Parent = game:GetService("SoundService")
    pcall(function() sound:Play() end)
    sound.Ended:Connect(function() sound:Destroy() end)
end
mainBtn.MouseButton1Click:Connect(function()
    local sounds = { "7127123605", "438666542" }
    PlaySound(sounds[math.random(#sounds)])
    uiOpen = not uiOpen
    if uiOpen then Window:Show() else Window:Hide() end
    local function SmoothSpeed(target, dur)
        local start = rotSpeed
        local steps = 30
        for i = 1, steps do
            rotSpeed = start + (target - start) * (i / steps)
            task.wait(dur / steps)
        end
        rotSpeed = target
    end
    task.spawn(function()
        SmoothSpeed(360, 0.4)
        task.wait(0.5)
        SmoothSpeed(180, 0.4)
        task.wait(0.3)
        SmoothSpeed(90, 0.4)
    end)
end)
FloatingButtonManager:AddButton("OpenUiBtn", mainBtn, false, false, nil, mainBtn)
Notify("NEVAHUB", "GUI loaded successfully", "Success", "solar/planet-bold", 4)
task.delay(0.5, function()
    Window:SelectTab(1)
end)
