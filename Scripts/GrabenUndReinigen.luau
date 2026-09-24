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
    SubTitle = "Graben Und Reinigen",
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
local CONFIG_NAME = "graben"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then
        table.insert(dropdownResync, function() applyFn(handle:Get()) end)
    end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local digEnabled       = false
local digMaxPower      = true
local RARITY_OPTIONS   = { "common", "uncommon", "rare", "epic", "legendary", "mythic", "divine", "eternal", "transcendent", "omega" }
local digRarities      = {}
for _, r in ipairs(RARITY_OPTIONS) do digRarities[r] = true end
local function raritySetFromSel(sel)
    local set = {}
    for _, r in ipairs(sel or {}) do set[r] = true end
    return set
end
local cleanEnabled     = true
local cleanInstantly   = true
local sellEnabled      = false
local sellInterval     = 20
local collectEnabled   = false
local polishEnabled    = false
local digging         = false
local busy            = false
local digCount        = 0
local lastSellAt      = 0
local detectorKeeper  = nil
local digLoopRunning  = false
local buyRunning      = false
local buriedNodes   = {}
local surfacedSpots = {}
local failedNodes   = {}
local HumanoidRoot, TeleportTo
local NearestDigZoneCenter, GetInventory
local DoDig, GoDigArea, DigLoop
local InstantClean, CleanAll, CleanLoop
local DoSell, SellLoop
local MyPlot, CollectOnce, CollectLoop
local SellNpcRef, ResolveSellNpc
local InstallDigHooks, RestoreDigHooks
local BuySelectedGear, BuyAllGear
local function Notify(title, content, kind, dur)
    pcall(Window.Notify, Window, { Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
end
local function notifyOn(feature, on)
    Notify(feature, on and "ON" or "OFF", on and "Success" or "Error")
end
local function safeCallback(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            pcall(Notify, "NevaHub", "Error: " .. tostring(err), "Error", 4)
        end
    end
end
local function safeSpawn(fn)
    task.spawn(function()
        local ok, err = pcall(fn)
        if not ok then
            pcall(Notify, "NevaHub", "Engine error: " .. tostring(err), "Error", 4)
        end
    end)
end
local GEAR_CATALOG = {
    shovel = {
        { id = "plasticShovel",  name = "Plastic Shovel",         cost = 0,         island = "starterIsland" },
        { id = "woodShovel",     name = "Wood Shovel",            cost = 250,       island = "starterIsland" },
        { id = "stoneShovel",    name = "Stone Shovel",           cost = 1600,      island = "starterIsland" },
        { id = "metalShovel",    name = "Metal Shovel",           cost = 9000,      island = "starterIsland" },
        { id = "goldShovel",     name = "Gold Shovel",            cost = 45000,     island = "starterIsland" },
        { id = "amethystShovel", name = "Amethyst Shovel",        cost = 190000,    island = "starterIsland" },
        { id = "titaniumShovel", name = "Titanium Shovel",        cost = 390000,    island = "island2" },
        { id = "cobaltShovel",   name = "Cobalt Shovel",          cost = 650000,    island = "island2" },
        { id = "carbonShovel",   name = "Carbon Shovel",          cost = 1300000,   island = "island2" },
        { id = "rubyShovel",     name = "Ruby Shovel",            cost = 2900000,   island = "island2" },
        { id = "diamondShovel",  name = "Diamond Shovel",         cost = 9200000,   island = "island2" },
        { id = "sandstoneShovel",name = "Sandstone Shovel",       cost = 9000000,    island = "island3" },
        { id = "amberShovel",    name = "Amber Shovel",           cost = 15000000,   island = "island3" },
        { id = "scarabShovel",   name = "Scarab Shovel",          cost = 30000000,   island = "island3" },
        { id = "malachiteShovel",name = "Malachite Shovel",       cost = 66000000,   island = "island3" },
        { id = "aquamarineShovel",name = "Aquamarine Shovel",     cost = 210000000,  island = "island3" },
    },
    detector = {
        { id = "rusty",     name = "Rusty Detector",      cost = 0,         island = "starterIsland" },
        { id = "copper",    name = "Copper Detector",     cost = 500,       island = "starterIsland" },
        { id = "silver",    name = "Silver Detector",     cost = 5000,      island = "starterIsland" },
        { id = "gold",      name = "Gold Detector",       cost = 28000,     island = "starterIsland" },
        { id = "platinum",  name = "Platinum Detector",   cost = 140000,    island = "starterIsland" },
        { id = "onyx",      name = "Onyx Detector",       cost = 330000,    island = "island2" },
        { id = "sapphire",  name = "Sapphire Detector",   cost = 530000,    island = "island2" },
        { id = "jade",      name = "Jade Detector",       cost = 1000000,   island = "island2" },
        { id = "topaz",     name = "Topaz Detector",      cost = 2300000,   island = "island2" },
        { id = "crystal",   name = "Crystal Detector",    cost = 6400000,   island = "island2" },
        { id = "sandstone", name = "Sandstone Detector",  cost = 7500000,   island = "island3" },
        { id = "amber",     name = "Amber Detector",      cost = 12000000,  island = "island3" },
        { id = "scarab",    name = "Scarab Detector",     cost = 23000000,  island = "island3" },
        { id = "malachite", name = "Malachite Detector",  cost = 52000000,  island = "island3" },
        { id = "aquamarine",name = "Aquamarine Detector", cost = 145000000, island = "island3" },
    },
    spray = {
        { id = "basic",          name = "Basic Spray Bottle",         cost = 0,         island = "starterIsland" },
        { id = "rubber",         name = "Rubber Spray Bottle",       cost = 900,       island = "starterIsland" },
        { id = "plastic",        name = "Plastic Spray Bottle",      cost = 5500,      island = "starterIsland" },
        { id = "copper",         name = "Copper Spray Bottle",       cost = 26000,     island = "starterIsland" },
        { id = "steel",          name = "Steel Spray Bottle",        cost = 100000,    island = "starterIsland" },
        { id = "gold",           name = "Gold Spray Bottle",         cost = 220000,    island = "starterIsland" },
        { id = "turquoise",      name = "Turquoise Spray Bottle",    cost = 400000,    island = "starterIsland" },
        { id = "plasticWasher",  name = "Plastic Pressure Washer",   cost = 640000,    island = "island2" },
        { id = "metalWasher",    name = "Metal Pressure Washer",     cost = 1000000,   island = "island2" },
        { id = "obsidianWasher", name = "Obsidian Pressure Washer",  cost = 1600000,   island = "island2" },
        { id = "opalWasher",     name = "Opal Pressure Washer",      cost = 2800000,   island = "island2" },
        { id = "garnetWasher",   name = "Garnet Pressure Washer",    cost = 5200000,   island = "island2" },
        { id = "sandstoneWasher",name = "Sandstone Pressure Washer", cost = 14500000,  island = "island3" },
        { id = "amberWasher",    name = "Amber Pressure Washer",     cost = 23000000,  island = "island3" },
        { id = "scarabWasher",   name = "Scarab Pressure Washer",    cost = 36000000,  island = "island3" },
        { id = "malachiteWasher",name = "Malachite Pressure Washer", cost = 64000000,  island = "island3" },
        { id = "aquamarineWasher",name="Aquamarine Pressure Washer", cost = 118000000, island = "island3" },
    },
}
local function gearDisplay(item)
    return item.name .. " (" .. tostring(item.cost) .. " Gold)"
end
local function gearIdFromDisplay(category, display)
    for _, item in ipairs(GEAR_CATALOG[category] or {}) do
        if gearDisplay(item) == display then return item.id end
    end
    return nil
end
local buySel = { shovel = {}, detector = {}, spray = {} }
for cat, items in pairs(GEAR_CATALOG) do
    for _, item in ipairs(items) do
        buySel[cat][item.id] = true
    end
end
local BUY_RT, BUY_SF, BUY_FW, BUY_DC = nil, nil, nil, nil
local function buyInit()
    if BUY_RT and BUY_SF and BUY_DC then return true end
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local ps = game:GetService("Players").LocalPlayer.PlayerScripts
        BUY_RT = require(rs:WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
        local sn = require(ps.TS.network.ShopNetwork)
        BUY_SF = sn and sn.ShopFunctions
        local fw = require(rs.rbxts_include:WaitForChild("node_modules"):WaitForChild("@flamework"):WaitForChild("core"):WaitForChild("out"))
        if fw and fw.Flamework then
            BUY_FW = fw.Flamework
            BUY_DC = BUY_FW.resolveDependency("client/controllers/data/DataController@DataController")
        end
    end)
    return BUY_RT ~= nil and BUY_SF ~= nil and BUY_DC ~= nil
end
local function buyGetData()
    if not BUY_DC then return nil end
    local ok, dat = pcall(function()
        if type(BUY_DC.getDataIfLoaded) == "function" then
            return BUY_DC:getDataIfLoaded()
        end
        return BUY_DC.data
    end)
    return ok and dat or nil
end
local function buyGetHRP()
    local char = game.Players.LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or (char:FindFirstChildOfClass("Humanoid") and char.HumanoidRootPart))
end
local function buyFindShop(category, islandId)
    local names = { starterIsland = "Home Beach", island2 = "Shipwreck Cove", island3 = "Sphinx Sands" }
    local isl = workspace:FindFirstChild("Islands")
    isl = isl and isl:FindFirstChild(names[islandId or "starterIsland"])
    local gear = isl and isl:FindFirstChild("NPCs") and isl.NPCs:FindFirstChild("Gear")
    if not gear then return nil end
    local pref = ({ shovel = "BuyShovels", detector = "BuyDetectors", spray = "BuySprays" })[category]
    local hit = pref and (gear:FindFirstChild(pref) or (pref == "BuySprays" and gear:FindFirstChild("Sprays")))
    if hit then return hit end
    local kw = ({ shovel = "Shovel", detector = "Detector", spray = "Spray" })[category]
    for _, c in ipairs(gear:GetChildren()) do
        if string.find(c.Name, kw, 1, true) and not string.find(c.Name, "Stand", 1, true) then
            return c
        end
    end
    return nil
end
local function buyItem(category, id)
    if not buyInit() then return "env" end
    local def
    for _, item in ipairs(GEAR_CATALOG[category] or {}) do
        if item.id == id then def = item; break end
    end
    if not def then return "config" end
    local pd = buyGetData()
    if not pd then return "data" end
    local of = ({ shovel = "OwnedShovels", detector = "OwnedDetectors", spray = "OwnedSprays" })[category]
    for _, oid in ipairs(pd[of] or {}) do if oid == id then return "owned" end end
    local unlocked = false
    for _, iid in ipairs(pd.UnlockedIslands or {}) do if iid == def.island then unlocked = true; break end end
    if not unlocked then return "locked" end
    if (pd.Gold or 0) < def.cost then return "gold" end
    local shop = buyFindShop(category, def.island)
    if not shop then return "shop" end
    local hrp = buyGetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(shop:GetPivot().Position + Vector3.new(0, 4, 0))
        task.wait(0.7)
    end
    local ok, res = pcall(function()
        return BUY_RT.await(BUY_SF.buyGear:invoke(category, id))
    end)
    return (ok and res) and "ok" or "fail"
end
BuySelectedGear = function()
    if buyRunning then return 0, 0, { "already buying" } end
    buyRunning = true
    local bought, skipped, reasons = 0, 0, {}
    for _, cat in ipairs({ "shovel", "detector", "spray" }) do
        for id in pairs(buySel[cat] or {}) do
            local res = buyItem(cat, id)
            if res == "ok" then bought = bought + 1
            else skipped = skipped + 1; reasons[#reasons + 1] = cat .. ": " .. id .. " (" .. res .. ")" end
            task.wait(0.4)
        end
    end
    buyRunning = false
    return bought, skipped, reasons
end
BuyAllGear = function()
    if buyRunning then return 0, 0 end
    buyRunning = true
    local bought, skipped = 0, 0
    for _, cat in ipairs({ "shovel", "detector", "spray" }) do
        for _, item in ipairs(GEAR_CATALOG[cat] or {}) do
            local res = buyItem(cat, item.id)
            if res == "ok" then bought = bought + 1
            elseif res ~= "owned" then skipped = skipped + 1 end
            task.wait(0.4)
        end
    end
    buyRunning = false
    return bought, skipped
end
local AutoTab = Window:AddTab({ Title = "Auto", Icon = "solar/bolt-bold" })
local DigSub = AutoTab:AddSection("Auto Dig", "solar/home-bold")
DigSub:AddToggle({
    Title = "Enable Auto Dig",
    Default = false,
    Flag = "dig_enabled",
    Callback = safeCallback(function(v)
        digEnabled = v
        notifyOn("Auto Dig", v)
        if v and type(DigLoop) == "function" then task.spawn(DigLoop) end
    end),
})
DigSub:AddToggle({
    Title = "Max Power Stop (5x Luck)",
    Default = true,
    Flag = "dig_maxpower",
    Callback = function(v) digMaxPower = v end,
})
local digRarityDropdown = DigSub:AddMultiDropdown({
    Title = "Buried Rarity Filter",
    Options = RARITY_OPTIONS,
    Default = RARITY_OPTIONS,
    Flag = "dig_rarities",
    Callback = function(sel) digRarities = raritySetFromSel(sel) end,
})
registerResync(digRarityDropdown, function(sel) digRarities = raritySetFromSel(sel) end)
DigSub:AddButton({
    Title = "Teleport To Dig Area",
    Callback = safeCallback(function()
        if type(GoDigArea) == "function" then GoDigArea() end
    end),
})
DigSub:AddButton({
    Title = "Dig Once",
    Callback = safeCallback(function()
        task.spawn(function()
            if type(DoDig) ~= "function" then return end
            local okDig = DoDig()
            Notify("Auto Dig", okDig and "Dug an item!" or "Dig failed", okDig and "Success" or "Error")
        end)
    end),
})
local CleanSub = AutoTab:AddSection("Auto Clean", "solar/home-bold")
CleanSub:AddToggle({
    Title = "Enable Auto Clean",
    Default = true,
    Flag = "clean_enabled",
    Callback = safeCallback(function(v)
        cleanEnabled = v
        notifyOn("Auto Clean", v)
        if v and type(CleanLoop) == "function" then task.spawn(CleanLoop) end
    end),
})
CleanSub:AddButton({
    Title = "Instant Clean",
    Callback = safeCallback(function()
        task.spawn(function()
            if type(CleanAll) ~= "function" then return end
            local prevTurbo = turboClean
            local prevSkip = skipCleanPass
            turboClean = true
            skipCleanPass = true
            pcall(function()
                local mn = require(LocalPlayer.PlayerScripts.TS.network.MiscNetwork)
                if mn and mn.MiscEvents and mn.MiscEvents.SetPowerfulSpray then
                    mn.MiscEvents.SetPowerfulSpray:Fire(true)
                end
            end)
            local n = CleanAll()
            turboClean = prevTurbo
            skipCleanPass = prevSkip
            Notify("Instant Clean", ("Cleaned %d item(s)"):format(n), n > 0 and "Success" or "Info")
        end)
    end),
})
local SellSub = AutoTab:AddSection("Auto Sell", "solar/home-bold")
SellSub:AddToggle({
    Title = "Enable Auto Sell",
    Default = false,
    Flag = "sell_enabled",
    Callback = safeCallback(function(v)
        sellEnabled = v
        notifyOn("Auto Sell", v)
        if v and type(SellLoop) == "function" then task.spawn(SellLoop) end
    end),
})
SellSub:AddSlider({
    Title = "Sell Interval",
    Min = 5,
    Max = 120,
    Default = 20,
    Suffix = "s",
    Flag = "sell_interval",
    Callback = function(v) sellInterval = v end,
})
SellSub:AddButton({
    Title = "Sell Now",
    Callback = safeCallback(function()
        task.spawn(function()
            if type(DoSell) == "function" then DoSell() end
        end)
    end),
})
local CollectSub = AutoTab:AddSection("Auto Collect", "solar/home-bold")
CollectSub:AddToggle({
    Title = "Collect Pedestal Items",
    Default = false,
    Flag = "collect_enabled",
    Callback = safeCallback(function(v)
        collectEnabled = v
        notifyOn("Auto Collect", v)
        if v and type(CollectLoop) == "function" then task.spawn(CollectLoop) end
    end),
})
CollectSub:AddToggle({
    Title = "Collect Polish Money",
    Default = false,
    Flag = "polish_enabled",
    Callback = function(v) polishEnabled = v end,
})
CollectSub:AddButton({
    Title = "Collect Now",
    Callback = safeCallback(function()
        task.spawn(function()
            if type(CollectOnce) ~= "function" then return end
            local n = CollectOnce()
            Notify("Collect", ("Collected %d thing(s)"):format(n), n > 0 and "Success" or "Info")
        end)
    end),
})
local BuySub = AutoTab:AddSection("Buy Gear", "solar/home-bold")
for _, cat in ipairs({ "shovel", "detector", "spray" }) do
    local opts = {}
    for _, item in ipairs(GEAR_CATALOG[cat]) do
        opts[#opts + 1] = gearDisplay(item)
    end
    local function setFromSel(sel)
        local set = {}
        for _, o in ipairs(sel or {}) do
            local id = gearIdFromDisplay(cat, o)
            if id then set[id] = true end
        end
        return set
    end
    local dd = BuySub:AddMultiDropdown({
        Name = ({ shovel = "Shovels", detector = "Detectors", spray = "Spray Bottles" })[cat],
        Options = opts,
        Default = opts,
        Flag = "buy_" .. cat,
        Callback = function(sel) buySel[cat] = setFromSel(sel) end,
    })
    registerResync(dd, function(sel) buySel[cat] = setFromSel(sel) end)
end
BuySub:AddButton({
    Title = "Buy Selected Gear",
    Callback = safeCallback(function()
        safeSpawn(function()
            local bought, skipped, reasons = BuySelectedGear()
            Notify("Shop", ("Bought %d item(s)"):format(bought), bought > 0 and "Success" or "Info")
            if skipped > 0 then
                Notify("Shop", ("%d skipped: %s"):format(skipped, table.concat(reasons, ", ")), "Warning", 4)
            end
        end)
    end),
})
BuySub:AddButton({
    Title = "Buy All Gear",
    Callback = safeCallback(function()
        safeSpawn(function()
            local bought, skipped = BuyAllGear()
            Notify("Shop", ("Bought %d item(s)"):format(bought), bought > 0 and "Success" or "Info")
            if skipped > 0 then
                Notify("Shop", ("%d skipped (owned / locked / no gold / env)"):format(skipped), "Warning")
            end
        end)
    end),
})
local TeleTab = Window:AddTab({ Title = "Teleports", Icon = "map" })
local TeleSub = TeleTab:AddSection("Teleports", "solar/home-bold")
TeleSub:AddButton({
    Title = "Go To Dig Area",
    Callback = safeCallback(function()
        if type(GoDigArea) == "function" then GoDigArea() end
    end),
})
TeleSub:AddButton({
    Title = "Go To Sell NPC",
    Callback = safeCallback(function()
        local npc = type(ResolveSellNpc) == "function" and ResolveSellNpc()
        if npc then
            TeleportTo(npc.Position, 3)
            Notify("Teleport", "At Sell NPC", "Success")
        else
            Notify("Teleport", "Sell NPC not found", "Error")
        end
    end),
})
TeleSub:AddButton({
    Title = "Go To My Plot",
    Callback = safeCallback(function()
        if type(MyPlot) ~= "function" then return end
        local plot = MyPlot()
        if plot then
            local root = plot:FindFirstChild("Plot") or plot
            local okBb, bb = pcall(function() return select(2, root:GetBoundingBox()) end)
            local pos = okBb and bb
            if pos then
                TeleportTo(pos.Position, 6)
                Notify("Teleport", "At your plot", "Success")
            end
        else
            Notify("Teleport", "No plot found", "Error")
        end
    end),
})
local PatcherTab = Window:AddTab({ Title = "Patcher", Icon = "wrench" })
local PatcherSub = PatcherTab:AddSection("Patches", "solar/home-bold")
local function getControllerClass(folder, name)
    local mod = folder and folder:FindFirstChild(name)
    if not (mod and mod:IsA("ModuleScript")) then return nil end
    local exports = require(mod)
    return exports and exports[name]
end
local function hookUpvalueBySource(cls, sourcePattern, newFn)
    if not cls then return false end
    for _, method in pairs(cls) do
        if type(method) == "function" then
            for i = 1, 50 do
                local ok, upval = pcall(debug.getupvalue, method, i)
                if not ok or upval == nil then break end
                if type(upval) == "function" then
                    local ok2, src = pcall(debug.info, upval, "s")
                    if ok2 and src and src:find(sourcePattern) then
                        hookfunction(upval, newFn)
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function hookMethod(cls, methodName, newFn)
    if not cls or type(cls[methodName]) ~= "function" then return false end
    hookfunction(cls[methodName], newFn)
    return true
end
local function applyCheapPolishing()
    local ok = false
    pcall(function()
        local ctrl = LocalPlayer.PlayerScripts:FindFirstChild("TS")
        local world = ctrl and ctrl:FindFirstChild("components") and ctrl.components:FindFirstChild("world")
        if not world then return end
        local cls = getControllerClass(world, "PlotSectionComponent")
        if hookUpvalueBySource(cls, "plot.PlotSections", function() return 1 end) then
            ok = true
        end
        local pc = getControllerClass(world, "PolisherComponent")
        if pc and hookUpvalueBySource(pc, "PlotSections", function() return 1 end) then
            ok = true
        end
    end)
    return ok
end
local function applyVIPBypass()
    local ok = false
    local newFn = function() return true end
    pcall(function()
        local ctrl = LocalPlayer.PlayerScripts:FindFirstChild("TS")
        if not ctrl then return end
        local controllers = ctrl:FindFirstChild("controllers")
        if not controllers then return end
        local ui = controllers:FindFirstChild("ui")
        local plot = controllers:FindFirstChild("plot")
        local bc = getControllerClass(ui, "BenefitsController")
        if hookUpvalueBySource(bc, "monetization.Vip", newFn) then ok = true end
        local vc = getControllerClass(ui, "VipShopController")
        if hookUpvalueBySource(vc, "monetization.Vip", newFn) then ok = true end
        local sc = getControllerClass(plot, "VipSignController")
        if hookUpvalueBySource(sc, "monetization.Vip", newFn) then ok = true end
    end)
    return ok
end
local function applyDetectorSpeed()
    local ok = false
    pcall(function()
        local ctrl = LocalPlayer.PlayerScripts:FindFirstChild("TS")
        local world = ctrl and ctrl.controllers:FindFirstChild("world")
        if not world then return end
        local cls = getControllerClass(world, "DetectorSweepController")
        if not cls then return end
        local origStart = cls.onStart
        if type(origStart) == "function" then
            local hooked = function(self, ...)
                local result = origStart(self, ...)
                if self.sweepStartedAt then
                    self.sweepStartedAt = os.clock() - 10
                end
                return result
            end
            hookfunction(origStart, hooked)
            ok = true
        end
    end)
    return ok
end
local function applyDigSpeed()
    local ok = false
    pcall(function()
        local ctrl = LocalPlayer.PlayerScripts:FindFirstChild("TS")
        local world = ctrl and ctrl.controllers:FindFirstChild("world")
        if not world then return end
        local cls = getControllerClass(world, "DigController")
        if not cls then return end
        local origBegin = cls.beginDig
        if type(origBegin) == "function" then
            local hooked = function(self, ...)
                if self.buriedRevealStartedAt then
                    self.buriedRevealStartedAt = os.clock() - 100
                end
                return origBegin(self, ...)
            end
            hookfunction(origBegin, hooked)
            ok = true
        end
    end)
    return ok
end
PatcherSub:AddToggle({
    Title = "Cheap Polishing (1 Gold upgrades)",
    Default = true,
    Flag = "patch_polishing",
    Callback = safeCallback(function(v)
        if v then
            local ok = applyCheapPolishing()
            notifyOn("Cheap Polishing", ok)
        end
    end),
})
PatcherSub:AddToggle({
    Title = "VIP Bypass (free VIP perks)",
    Default = true,
    Flag = "patch_vip",
    Callback = safeCallback(function(v)
        if v then
            local ok = applyVIPBypass()
            notifyOn("VIP Bypass", ok)
        end
    end),
})
PatcherSub:AddToggle({
    Title = "Detector 16x Speed",
    Default = true,
    Flag = "patch_detector",
    Callback = safeCallback(function(v)
        if v then
            local ok = applyDetectorSpeed()
            notifyOn("Detector Speed", ok)
        end
    end),
})
PatcherSub:AddToggle({
    Title = "No Dig Cooldown",
    Default = true,
    Flag = "patch_digging",
    Callback = safeCallback(function(v)
        if v then
            local ok = applyDigSpeed()
            notifyOn("Dig Cooldown", ok)
        end
    end),
})
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })
local SettingsSub = SettingsTab:AddSection("Settings", "solar/home-bold")
SettingsSub:AddButton({
    Title = "Save Config",
    Callback = function()
        if HAS_CONFIG then
            Library:SaveConfig(CONFIG_NAME)
            Notify("Config", "Saved!", "Success")
        end
    end,
})
SettingsSub:AddButton({
    Title = "Load Config",
    Callback = function()
        if HAS_CONFIG then
            Library:LoadConfig(CONFIG_NAME)
            task.wait(0.1)
            ResyncAll()
            Notify("Config", "Loaded!", "Success")
        end
    end,
})
pcall(function()
    SettingsSub:AddKeybind({
        Title = "Toggle Auto Dig",
        Default = "LeftAlt",
        Flag = "dig_keybind",
        Callback = safeCallback(function()
            local v = not digEnabled
            digEnabled = v
            notifyOn("Auto Dig", v)
            if v and type(DigLoop) == "function" then task.spawn(DigLoop) end
        end),
    })
end)
SettingsSub:AddButton({
    Title = "Unload",
    Callback = safeCallback(function()
        digEnabled = false
        cleanEnabled = false
        sellEnabled = false
        collectEnabled = false
        if type(RestoreDigHooks) == "function" then RestoreDigHooks() end
        Notify("NevaHub", "Script unloaded", "Info")
        pcall(function() Window:Destroy() end)
    end),
})
local ENV_OK = false
local envWarned = false
local RuntimeLib
local ShovelEvents, ShovelFunctions, ItemsFunctions, ItemsEvents
local SellFunctions, PedestalFunctions, PolisherFunctions, DetectorEvents
local ShopFunctions
local Flamework
local DetectorController, ShovelController
local function EnvGate(feature)
    if ENV_OK then return true end
    if not envWarned then
        envWarned = true
        Notify(feature, "Game API init failed - UI only", "Error", 4)
    end
    return false
end
local function Await(promise)
    if RuntimeLib then return RuntimeLib.await(promise) end
    return nil
end
task.spawn(function()
    for _ = 1, 5 do
        if applyCheapPolishing() then break end
        task.wait(0.8)
    end
end)
task.spawn(function()
    for _ = 1, 5 do
        if applyVIPBypass() then break end
        task.wait(0.8)
    end
end)
task.spawn(function()
    for _ = 1, 5 do
        if applyDetectorSpeed() then break end
        task.wait(0.8)
    end
end)
task.spawn(function()
    for _ = 1, 5 do
        if applyDigSpeed() then break end
        task.wait(0.8)
    end
end)
pcall(function()
    RuntimeLib = require(ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
    local PlayerScripts = LocalPlayer.PlayerScripts
    local ShovelNet   = require(PlayerScripts.TS.network.ShovelNetwork)
    local ItemsNet    = require(PlayerScripts.TS.network.ItemsNetwork)
    local SellNet     = require(PlayerScripts.TS.network.SellNetwork)
    local PedNet      = require(PlayerScripts.TS.network.PedestalNetwork)
    local PolishNet   = require(PlayerScripts.TS.network.PolisherNetwork)
    local DetNet      = require(PlayerScripts.TS.network.DetectorNetwork)
    local ShopNet     = require(PlayerScripts.TS.network.ShopNetwork)
    ShovelEvents    = ShovelNet.ShovelEvents
    ShovelFunctions = ShovelNet.ShovelFunctions
    ItemsFunctions  = ItemsNet.ItemsFunctions
    ItemsEvents     = ItemsNet.ItemsEvents
    SellFunctions   = SellNet.SellFunctions
    PedestalFunctions = PedNet.PedestalFunctions
    PolisherFunctions = PolishNet.PolisherFunctions
    DetectorEvents  = DetNet.DetectorEvents
    ShopFunctions   = ShopNet.ShopFunctions
    local okFw, fw = pcall(require, ReplicatedStorage.rbxts_include.node_modules["@flamework"].core.out)
    if okFw and fw and fw.Flamework then
        Flamework = fw
        pcall(function()
            DetectorController = Flamework.Flamework.resolveDependency("client/controllers/world/DetectorController@DetectorController")
        end)
        pcall(function()
            ShovelController = Flamework.Flamework.resolveDependency("client/controllers/world/ShovelController@ShovelController")
        end)
    end
    DetectorEvents.BuriedNodes:connect(function(added, removed)
        local now = os.clock()
        for _, node in added do
            node.at = now
            buriedNodes[node.id] = node
        end
        for _, id in removed do
            buriedNodes[id] = nil
            failedNodes[id] = nil
        end
    end)
    ShovelEvents.SurfacedItemSpawned:connect(function(spot)
        surfacedSpots[spot.id] = spot
    end)
    ShovelEvents.SurfacedItemReleased:connect(function(spot)
        surfacedSpots[spot.id] = spot
    end)
    ShovelEvents.SurfacedItemRemoved:connect(function(id)
        surfacedSpots[id] = nil
    end)
    pcall(function() ShovelEvents.SetShovelEquipped:fire(true) end)
    if not detectorKeeper then
        detectorKeeper = true
        task.spawn(function()
            while true do
                if not digging and DetectorController and DetectorController.localRig then
                    pcall(function()
                        if ShovelController and ShovelController.localRig then
                            ShovelController:setEquipped(ShovelController.localRig, false)
                        end
                        DetectorController:setHeld(DetectorController.localRig, true)
                        DetectorEvents.SetDetectorHeld:fire(true)
                    end)
                end
                task.wait(3)
            end
        end)
    end
    ENV_OK = true
    pcall(function()
        GAME_digZoneAt = require(ReplicatedStorage.TS.utils.world.DigZoneSpawn).digZoneAt
    end)
    pcall(function()
        local mn = require(PlayerScripts.TS.network.MiscNetwork)
        if mn and mn.MiscEvents and mn.MiscEvents.SetPowerfulSpray then
            mn.MiscEvents.SetPowerfulSpray:Fire(true)
            Notify("OP Features", "Turbo Clean enabled", "Success", 2)
        end
    end)
end)
function HumanoidRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("Humanoid") and char.HumanoidRootPart)
end
function TeleportTo(position, yOffset)
    local hrp = HumanoidRoot()
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, (yOffset or 3), 0))
    end
end
function NearestDigZoneCenter()
    local tagged = CollectionService:GetTagged("DigZone")
    local best, bestDist = nil, math.huge
    local hrp = HumanoidRoot()
    local origin = hrp and hrp.Position or Vector3.zero
    for _, part in tagged do
        if part:IsA("BasePart") then
            local d = (part.Position - origin).Magnitude
            if d < bestDist then best, bestDist = part, d end
        end
    end
    if best then return best.Position end
    if not ENV_OK then return nil end
    local island = Workspace:FindFirstChild("Islands") and Workspace.Islands:FindFirstChild("Home Beach")
    local digArea = island and island:FindFirstChild("DigAreas") and island.DigAreas:FindFirstChild("DigArea")
    return digArea and digArea:IsA("BasePart") and digArea.Position or nil
end
local function rarityOk(r)
    if not r then return true end
    return digRarities[r] == true
end
local NODE_MAX_AGE = 60
local NODE_FAIL_COOLDOWN = 20
local function MarkNodeFailed(id)
    if id then failedNodes[id] = os.clock() end
end
local function NodeFailed(id)
    local at = failedNodes[id]
    return at ~= nil and (os.clock() - at) < NODE_FAIL_COOLDOWN
end
local GAME_digZoneAt = nil
local function IsInDigZone(pos)
    if not pos then return false end
    if GAME_digZoneAt then
        return GAME_digZoneAt(pos) ~= nil
    end
    for _, part in ipairs(CollectionService:GetTagged("DigZone")) do
        if part:IsA("BasePart") then
            local half = part.Size * 0.5
            if math.abs(pos.X - part.Position.X) <= half.X + 2
                and math.abs(pos.Z - part.Position.Z) <= half.Z + 2 then
                return true
            end
        end
    end
    return false
end
local function NearestBuriedNode()
    local hrp = HumanoidRoot()
    if not hrp then return nil end
    local now = os.clock()
    local best, bestDist = nil, math.huge
    for id, node in buriedNodes do
        if now - (node.at or 0) > NODE_MAX_AGE then
            buriedNodes[id] = nil
        elseif not NodeFailed(id) and rarityOk(node.rarity) and node.position
            and IsInDigZone(node.position) then
            local d = (node.position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = node, d end
        end
    end
    return best, bestDist
end
local function NearestSurfacedSpot()
    local hrp = HumanoidRoot()
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, spot in surfacedSpots do
        if spot.position and IsInDigZone(spot.position) then
            local d = (spot.position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = spot, d end
        end
    end
    return best, bestDist
end
local function GetPlayerData()
    if not Flamework or not Flamework.Flamework then
        local ok, fw = pcall(require, ReplicatedStorage.rbxts_include.node_modules["@flamework"].core.out)
        if not ok or not fw or not fw.Flamework then return nil end
        Flamework = fw
    end
    local ok, dataCtrl = pcall(function()
        return Flamework.Flamework.resolveDependency("client/controllers/data/DataController@DataController")
    end)
    if not ok or not dataCtrl then return nil end
    local okGet, data = pcall(function()
        if type(dataCtrl.getDataIfLoaded) == "function" then
            return dataCtrl:getDataIfLoaded()
        end
        return dataCtrl.data
    end)
    if not okGet or not data then return nil end
    return data
end
function GetInventory()
    local data = GetPlayerData()
    return data and data.Inventory
end
local ISLAND_SHOP_NAMES = {
    starterIsland = "Home Beach",
    island2       = "Shipwreck Cove",
    island3       = "Sphinx Sands",
}
local function FindGearShop(category, islandId)
    local islandName = ISLAND_SHOP_NAMES[islandId or "starterIsland"]
    local islands = Workspace:FindFirstChild("Islands")
    local isl = islands and islands:FindFirstChild(islandName)
    local gear = isl and isl:FindFirstChild("NPCs") and isl.NPCs:FindFirstChild("Gear")
    if not gear then return nil end
    local preferred = ({
        shovel   = "BuyShovels",
        detector = "BuyDetectors",
        spray    = "BuySprays",
    })[category]
    local hit = preferred and gear:FindFirstChild(preferred)
    if hit then return hit end
    local kw = ({
        shovel   = "Shovel",
        detector = "Detector",
        spray    = "Spray",
    })[category]
    for _, child in ipairs(gear:GetChildren()) do
        if string.find(child.Name, kw, 1, true)
            and not string.find(child.Name, "Stand", 1, true) then
            return child
        end
    end
    return nil
end
local GEAR_OWNED_FIELD = {
    shovel   = "OwnedShovels",
    detector = "OwnedDetectors",
    spray    = "OwnedSprays",
}
function ResolveSellNpc()
    local function findInIsland(island)
        local npcs = island and island:FindFirstChild("NPCs")
        local sell = npcs and npcs:FindFirstChild("Sell")
        local seller = sell and sell:FindFirstChild("SellerNPC")
        local hrp = seller and seller:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then return hrp end
        if sell then
            for _, child in sell:GetDescendants() do
                if child:IsA("BasePart") then return child end
            end
        end
        return nil
    end
    local islands = Workspace:FindFirstChild("Islands")
    if islands then
        for _, island in islands:GetChildren() do
            local hrp = findInIsland(island)
            if hrp then SellNpcRef = hrp; return hrp end
        end
    end
    return nil
end
local DIG_FULL_MASK = string.rep("/", 64)
local DIG_WIN_THRESHOLD    = 0.985
local DIG_PROGRESS_START   = 0.33
local DIG_REVEAL_SECONDS   = 0.72
local DIG_EFFECTIVE_CPS    = 11
local DIG_SESSION_MAX_SEC  = 30
local DIG_STREAM_BUDGET_SEC = 24
local function NeededClicks(clickPower)
    return math.max(1, math.ceil(
        (DIG_WIN_THRESHOLD - DIG_PROGRESS_START) / math.max(clickPower or 0.001, 0.0001)
    ))
end
local function FireClicksTo(sessionId, target)
    local total = 0
    local t0 = os.clock()
    while total < target do
        if os.clock() - t0 >= DIG_STREAM_BUDGET_SEC then break end
        total = math.min(total + 5, target)
        ShovelEvents.DigInput:fire(sessionId, total)
        task.wait(0.1)
    end
    return total
end
local function FireClicks(sessionId, duration, from)
    local total = from or 0
    local t0 = os.clock()
    while os.clock() - t0 < duration do
        total = total + 5
        ShovelEvents.DigInput:fire(sessionId, total)
        task.wait(0.1)
    end
    return total
end
local DigControllerClass
local origDigMethods = {}
function InstallDigHooks()
    if not DigControllerClass then return false end
    local function patch(name, newFn)
        if type(DigControllerClass[name]) == "function" and origDigMethods[name] == nil then
            origDigMethods[name] = DigControllerClass[name]
            DigControllerClass[name] = newFn
        end
    end
    patch("updatePowerBar", function(self, session, dt)
        local result = origDigMethods.updatePowerBar(self, session, dt)
        if digEnabled and session and session.phase == "power"
            and not session.powerStopping and session.power and session.power >= 0.97 then
            pcall(function() self:stopPower(false) end)
        end
        return result
    end)
    patch("updateMoundReveal", function(self, session, dt)
        if digEnabled and session and session.phase == "revealing" then
            session.revealStarted = session.revealStarted or os.clock()
            session.revealStarted = os.clock() - 100
        end
        return origDigMethods.updateMoundReveal(self, session, dt)
    end)
    patch("updateMinigame", function(self, session, dt)
        if digEnabled and session and session.phase == "minigame" and session.difficulty then
            local clickPower = session.difficulty.clickPower or 0.001
            local target = NeededClicks(clickPower)
            if not session.instantTarget then
                session.instantTarget = target
                session.instantSent = math.max(session.totalClicks or 0, 5)
            end
            local sent = session.instantSent
            if sent < session.instantTarget and (session.lastInputSent == nil
                or os.clock() - session.lastInputSent >= 0.1) then
                sent = math.min(sent + 5, session.instantTarget)
                session.totalClicks = sent
                session.instantSent = sent
                pcall(function() self:flushInput(session) end)
                session.lastInputSent = os.clock()
            end
            if sent >= session.instantTarget and not self:isResolving(session) then
                session.progress = 1
                pcall(function() self:finish(true) end)
            end
            return
        end
        return origDigMethods.updateMinigame(self, session, dt)
    end)
    return true
end
function RestoreDigHooks()
    if DigControllerClass then
        for name, orig in pairs(origDigMethods) do
            pcall(function() DigControllerClass[name] = orig end)
        end
    end
    table.clear(origDigMethods)
end
local function Resolve(sessionId, win, clicks)
    for _ = 1, 4 do
        local res = Await(ShovelFunctions.ResolveDig:invoke(sessionId, win, clicks):catch(function() return nil end))
        if res then return res end
        task.wait(0.35)
    end
    return nil
end
function DoDig()
    if not EnvGate("Auto Dig") then return false end
    if digging then return false end
    digging = true
    busy = true
    local ok = false
    pcall(function()
        local node, nodeDist = NearestBuriedNode()
        local spot, spotDist = NearestSurfacedSpot()
        local targetPos, targetId
        if node and (not spot or nodeDist <= (spotDist or 0) + 4) then
            targetPos, targetId = node.position, node.id
        elseif spot then
            targetPos, targetId = spot.position, nil
        end
        if not targetPos then
            return
        end
        if not IsInDigZone(targetPos) then
            return
        end
        TeleportTo(targetPos)
        task.wait(0.35)
        local begun = Await(ShovelFunctions.BeginDig:invoke(targetId or nil):catch(function() return nil end))
        if not begun or not begun.sessionId or not begun.difficulty then
            MarkNodeFailed(targetId)
            return
        end
        local sessionId = begun.sessionId
        local stop
        if not begun.surfaced and not begun.rolled then
            if digMaxPower then
                task.wait(math.max(0, 0.275 - (Workspace:GetServerTimeNow() - begun.powerStartedAt)) + 0.05)
                stop = Await(ShovelFunctions.StopPower:invoke(
                    sessionId,
                    begun.powerStartedAt + 0.275,
                    false
                ):catch(function() return nil end))
                if not stop or not stop.difficulty then
                    stop = Await(ShovelFunctions.StopPower:invoke(
                        sessionId,
                        Workspace:GetServerTimeNow(),
                        true
                    ):catch(function() return nil end))
                end
                if not stop or not stop.difficulty then
                    Resolve(sessionId, false, 0)
                    return
                end
            else
                task.wait(math.max(0, 0.12 - (Workspace:GetServerTimeNow() - begun.powerStartedAt)) + 0.05)
                stop = Await(ShovelFunctions.StopPower:invoke(
                    sessionId,
                    Workspace:GetServerTimeNow(),
                    false
                ):catch(function() return nil end))
                if not stop or not stop.difficulty then
                    Resolve(sessionId, false, 0)
                    return
                end
            end
        end
        local clickPower = 0.001
        if begun.difficulty and begun.difficulty.clickPower then
            clickPower = begun.difficulty.clickPower
        elseif stop and stop.difficulty and stop.difficulty.clickPower then
            clickPower = stop.difficulty.clickPower
        end
        local targetClicks = NeededClicks(clickPower)
        ShovelEvents.DigReady:fire(sessionId)
        task.wait(0.15)
        local sentClicks = FireClicksTo(sessionId, targetClicks)
        task.wait(0.4)
        local win = Resolve(sessionId, true, sentClicks)
        if not win then
            Notify("Auto Dig", "Instant dig stalled - streaming more clicks", "Warning", 2)
            sentClicks = FireClicks(sessionId, 6, sentClicks)
            task.wait(0.4)
            win = Resolve(sessionId, true, sentClicks)
        end
        if not win then
            MarkNodeFailed(targetId)
            Resolve(sessionId, false, 0)
            return
        end
        if targetId then failedNodes[targetId] = nil end
        digCount = digCount + 1
        ok = true
    end)
    digging = false
    busy = false
    return ok
end
function GoDigArea()
    local pos = NearestDigZoneCenter()
    if pos then
        TeleportTo(pos, 4)
        Notify("Auto Dig", "Teleported to dig area", "Success")
    else
        Notify("Auto Dig", "No dig zone found", "Error")
    end
end
local function InventoryFull()
    local inv = GetInventory()
    return inv ~= nil and #inv >= 50 or false
end
function DigLoop()
    if digLoopRunning then return end
    digLoopRunning = true
    local lastRoamPos = nil
    local lastRoamAt = 0
    while digEnabled do
        if not digging and not busy then
            if InventoryFull() then
                Notify("Auto Dig", "Backpack full - sell first", "Error", 2)
                task.wait(3)
            else
                local hrp = HumanoidRoot()
                local inZone = false
                if hrp then
                    for _, part in CollectionService:GetTagged("DigZone") do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 40 then
                            inZone = true
                            break
                        end
                    end
                end
                local node, nodeDist = NearestBuriedNode()
                local spot, spotDist = NearestSurfacedSpot()
                local target = (node and node.position and IsInDigZone(node.position)) and node.position
                    or (spot and spot.position and IsInDigZone(spot.position)) and spot.position or nil
                if target and ((node and nodeDist and nodeDist <= 20) or (spot and spotDist and spotDist <= 20)) then
                    local okDig = DoDig()
                    if okDig then
                        task.wait(0.3)
                    else
                        task.wait(1.2)
                    end
                elseif not inZone then
                    GoDigArea()
                    task.wait(1.5)
                elseif target and IsInDigZone(target) then
                    local now = os.clock()
                    local sameSpot = lastRoamPos
                        and (target - lastRoamPos).Magnitude < 8
                        and (now - lastRoamAt) < 2.5
                    if not sameSpot then
                        TeleportTo(target, 2)
                        lastRoamPos = target
                        lastRoamAt = now
                    end
                    task.wait(1.2)
                else
                    lastRoamPos = nil
                    local center = NearestDigZoneCenter()
                    if center then
                        TeleportTo(center + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30)), 4)
                    end
                    task.wait(1.2)
                end
            end
        else
            task.wait(0.5)
        end
    end
    digLoopRunning = false
end
local turboClean = true
local skipCleanPass = false
function InstantClean(uid)
    if not EnvGate("Clean") then return false end
    if not uid then return false end
    local begin = Await(ItemsFunctions.beginCleaning:invoke(uid):catch(function() return nil end))
    if begin == nil then return false end
    if skipCleanPass then
        pcall(function() ItemsEvents.requestSkipClean:fire() end)
        task.wait(0.3)
        local data = GetPlayerData()
        local inv = data and data.Inventory
        if inv then
            for _, item in inv do
                if item.uid == uid and not item.dirty then return true end
            end
        end
    end
    ItemsEvents.saveCleanProgress:fire(uid, DIG_FULL_MASK)
    task.wait(turboClean and 0.05 or 0.15)
    ItemsEvents.finishCleaning:fire(uid)
    return true
end
function CleanAll()
    if not EnvGate("Clean") then return 0 end
    local inv = GetInventory()
    if not inv then
        Notify("Clean", "Inventory not loaded yet", "Error")
        return 0
    end
    local cleaned = 0
    for _, item in inv do
        if item and item.dirty and not item.pedestalSlot then
            if InstantClean(item.uid) then cleaned = cleaned + 1 end
            task.wait(0.2)
        end
    end
    return cleaned
end
function CleanLoop()
    while cleanEnabled do
        if not busy then
            busy = true
            local n = CleanAll()
            if n > 0 then Notify("Clean", ("Cleaned %d item(s)"):format(n), "Success") end
            busy = false
        end
        task.wait(3)
    end
end
function DoSell()
    if not EnvGate("Sell") then return nil end
    if cleanEnabled then pcall(CleanAll) end
    local npc = ResolveSellNpc()
    if not npc then
        Notify("Sell", "Sell NPC not found", "Error")
        return nil
    end
    local inv = GetInventory()
    if not inv then
        Notify("Sell", "Inventory not loaded yet", "Error")
        return nil
    end
    if #inv == 0 then return nil end
    TeleportTo(npc.Position, 3)
    task.wait(0.8)
    local money
    for _ = 1, 3 do
        money = Await(SellFunctions.sellInventory:invoke():catch(function() return nil end))
        if money then break end
        task.wait(0.5)
    end
    if money then
        lastSellAt = os.clock()
        Notify("Sell", ("Sold for +$%s"):format(tostring(money)), "Success", 3)
    end
    return money
end
function SellLoop()
    while sellEnabled do
        if not busy then
            busy = true
            DoSell()
            busy = false
        end
        task.wait(sellInterval)
    end
end
function MyPlot()
    for _, plot in Workspace.Plots:GetChildren() do
        if plot:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end
function CollectOnce()
    if not EnvGate("Collect") then return 0 end
    local plot = MyPlot()
    local got = 0
    if plot then
        local pedestals = plot:FindFirstChild("Pedestals")
        if pedestals then
            for _, ped in pedestals:GetChildren() do
                local slot = ped:GetAttribute("Slot")
                local uid = ped:GetAttribute("ItemUid")
                if slot and uid then
                    local okPick = Await(PedestalFunctions.pickupItem:invoke(slot):catch(function() return nil end))
                    if okPick then
                        got = got + 1
                        task.wait(0.3)
                    end
                end
            end
        end
        if polishEnabled then
            local sections = plot:FindFirstChild("PlotComponents") and plot.PlotComponents:FindFirstChild("Sections")
            local polishing = sections and sections:FindFirstChild("Polishing")
            local polishers = polishing and polishing:FindFirstChild("Polishers")
            if polishers then
                for _, p in polishers:GetChildren() do
                    local slot = p:GetAttribute("Slot") or p:GetAttribute("PolisherSlot")
                    if slot then
                        local okCollect = Await(PolisherFunctions.collectPolish:invoke(slot):catch(function() return nil end))
                        if okCollect then
                            got = got + 1
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end
    return got
end
function CollectLoop()
    while collectEnabled do
        if not busy then
            busy = true
            local n = CollectOnce()
            if n > 0 then Notify("Collect", ("Collected %d thing(s)"):format(n), "Success") end
            busy = false
        end
        task.wait(5)
    end
end
if cleanEnabled then task.spawn(CleanLoop) end
task.spawn(function()
    RestoreDigHooks()
    for attempt = 1, 15 do
        local ok = pcall(function()
            local ps = LocalPlayer:FindFirstChild("PlayerScripts")
            local ts = ps and ps:FindFirstChild("TS")
            local controllers = ts and (ts:FindFirstChild("controllers") or ts:FindFirstChild("Controllers"))
            local world = controllers and controllers:FindFirstChild("world")
            local digMod = world and require(world:FindFirstChild("DigController"))
            if digMod and digMod.DigController then
                DigControllerClass = digMod.DigController
                return InstallDigHooks()
            end
            return false
        end)
        if ok then break end
        task.wait(1)
    end
end)
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
