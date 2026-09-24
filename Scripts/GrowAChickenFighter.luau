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
    SubTitle = "Chicken Fighter",
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
    local prev = _G.OxideChickenFighter
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, dead = false }
_G.OxideChickenFighter = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local CONFIG_NAME = "chickenfighter"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then
        table.insert(dropdownResync, function() applyFn(handle:Get()) end)
    end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local Workspace          = game:GetService("Workspace")
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
    return c and c:FindFirstChild("HumanoidRootPart")
end
local SAFE_WALK = 18
local function TeleportTo(pos)
    local hrp = GetHRP()
    local hum = GetHumanoid()
    if not hrp or not pos then return false end
    if HUB.dead then return false end
    local target = CFrame.new(pos + Vector3.new(0, 3, 0))
    local prevWS = hum and hum.WalkSpeed or SAFE_WALK
    if hum then pcall(function() hum.WalkSpeed = SAFE_WALK end) end
    local budget = 45
    while not HUB.dead and budget > 0 do
        local root = GetHRP()
        if not root then break end
        local toGo = target.Position - root.Position
        local dist = toGo.Magnitude
        if dist < 2 then
            root.CFrame = target
            break
        end
        local dt = RunService.Heartbeat:Wait()
        budget = budget - dt
        local step = math.min(SAFE_WALK * dt, dist)
        root.CFrame = CFrame.new(root.Position + toGo.Unit * step) * (root.CFrame - root.Position)
    end
    if hum then pcall(function() hum.WalkSpeed = prevWS end) end
    return true
end
local Remotes, defs
local DataController, CoopController, DataClient
local GameConfig
local MissionView
local GAME_OK = false
local towerRunning = false
local gooseEnabled   = true
local hotEggEnabled  = true
local lastGoosePos   = nil
local lastEggPos     = nil
local gooseQueue     = {}
local eggQueue       = {}
local EGG_TIERS = {
    "barn", "feed", "charm", "diner", "storm", "circuit", "ordnance",
    "meme", "arena", "haunt", "void", "bloom", "crown", "fang", "golden",
    "hotEgg", "rival",
}
local EGG_NAMES = {
    barn = "Nest Egg",     feed = "Scratch Egg",   charm = "Charm Egg",
    diner = "Diner Egg",   storm = "Thunder Egg",  circuit = "Circuit Egg",
    ordnance = "Ordnance Egg", meme = "Cursed Egg", arena = "Arena Egg",
    haunt = "Haunt Egg",   void = "Void Egg",      bloom = "Bloom Egg",
    crown = "Royal Egg",   fang = "Fang Egg",      golden = "Fortune Egg",
    hotEgg = "Blazing Egg", rival = "Grudge Egg",
}
local RARITY_ORDER = {
    common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5,
    mythic = 6, divine = 7, cosmic = 8, celestial = 9, secret = 10,
}
local RARITY_LIST = { "common", "uncommon", "rare", "epic", "legendary",
    "mythic", "divine", "cosmic", "celestial", "secret" }
local GENERATORS = {
    { id = "corn_sack",    name = "Corn Sack",     tier = 1 },
    { id = "wood_feeder",  name = "Wooden Feeder", tier = 2 },
    { id = "silo",         name = "Silo",          tier = 3 },
    { id = "harvester",    name = "Harvester",     tier = 4 },
}
local COOP_MAX_SLOTS = #GENERATORS
local function isRemotesTable(v)
    return type(v) == "table" and type(v.invoke) == "function"
        and type(v.defs) == "table" and v.defs.HatchEgg ~= nil and v.defs.FuseChickens ~= nil
end
local function scanUpvalues(fn, depth, seen)
    depth = depth or 0
    if depth > 5 then return nil end
    seen = seen or {}
    if seen[fn] then return nil end
    seen[fn] = true
    for i = 1, 200 do
        local ok, v = pcall(debug.getupvalue, fn, i)
        if not ok or v == nil then break end
        if isRemotesTable(v) then return v end
        if type(v) == "function" then
            local r = scanUpvalues(v, depth + 1, seen)
            if r then return r end
        end
    end
    return nil
end
local function ExtractRemotes(mod)
    if type(mod) ~= "table" then return nil end
    for _, member in pairs(mod) do
        if type(member) == "function" then
            local r = scanUpvalues(member)
            if r then return r end
        end
    end
    return nil
end
local function HookEvent(remoteDef, cb)
    if not (Remotes and defs and remoteDef and cb) then return end
    pcall(function() Remotes.onClient(remoteDef, cb) end)
end
local function initGame()
    local LP = Players.LocalPlayer
    local ps = LP:WaitForChild("PlayerScripts")
    DataController = require(ps:WaitForChild("Core"):WaitForChild("Data"):WaitForChild("DataController"))
    CoopController = require(ps:WaitForChild("Features"):WaitForChild("Coop"):WaitForChild("CoopController"))
    pcall(function()
        DataClient = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("DataService")).client
    end)
    pcall(function()
        GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Content"):WaitForChild("GameConfig"))
    end)
    pcall(function()
        MissionView = require(game:GetService("ReplicatedStorage"):WaitForChild("Features"):WaitForChild("Missions"):WaitForChild("MissionView"))
    end)
    local ok = pcall(function()
        Remotes = require(game:GetService("ReplicatedStorage"):WaitForChild("Core"):WaitForChild("Remotes"))
    end)
    if not (ok and Remotes and type(Remotes.invoke) == "function") then
        Remotes = ExtractRemotes(CoopController) or ExtractRemotes(DataController)
    end
    if not Remotes then return end
    defs = Remotes.defs
    GAME_OK = true
    HookEvent(D("TowerRunStarted"), function() towerRunning = true end)
    HookEvent(D("TowerRunEnded"),   function() towerRunning = false end)
    HookEvent(D("TowerDefeat"),     function() towerRunning = false end)
    HookEvent(D("GooseEntrance"), function(d)
        if type(d) == "table" and typeof(d.at) == "Vector3" then
            lastGoosePos = d.at
            if gooseEnabled then table.insert(gooseQueue, d.at) end
        end
    end)
    HookEvent(D("GooseFinale"), function(d)
        if type(d) == "table" and typeof(d.at) == "Vector3" then
            lastGoosePos = d.at
            if d.phase ~= "windup" and gooseEnabled then
                local delay = (tonumber(d.windup) or 0) + 1.2
                task.delay(delay, function()
                    if HUB.dead or not gooseEnabled then return end
                    table.insert(gooseQueue, d.at)
                    if type(d.coops) == "table" then
                        for _, v in ipairs(d.coops) do
                            if typeof(v) == "Vector3" then table.insert(gooseQueue, v) end
                        end
                    end
                end)
            end
        end
    end)
    HookEvent(D("HotEggEntrance"), function(d)
        if type(d) == "table" and typeof(d.at) == "Vector3" then
            lastEggPos = d.at
            if hotEggEnabled then table.insert(eggQueue, d.at) end
        end
    end)
    HookEvent(D("HotEggMeteor"), function(d)
        if type(d) == "table" and typeof(d.at) == "Vector3" then
            lastEggPos = d.at
            if hotEggEnabled then table.insert(eggQueue, d.at) end
        end
    end)
end
local function Invoke(def, ...)
    if not (GAME_OK and def) then return nil end
    local args = { ... }
    local ok, res = pcall(function()
        return Remotes.invoke(def, table.unpack(args, 1, #args))
    end)
    return ok and res or nil
end
local function TryInvoke(def, ...)
    if not GAME_OK then return false, "Game API not connected" end
    local res = Invoke(def, ...)
    if res == nil then return false, "no response (server rejected)" end
    if res.ok then return true, res.data end
    return false, tostring(res.error or "unknown")
end
local function D(name)
    return defs and defs[name]
end
local function GetRoster()
    if not GAME_OK then return nil end
    local ok, r = pcall(function() return DataController.roster() end)
    return ok and r or nil
end
local function GetMoney()
    if not GAME_OK then return nil end
    local ok, n = pcall(function() return DataController.money():toNumber() end)
    return ok and n or nil
end
local function GetCoop()
    if not GAME_OK then return nil end
    local ok, c = pcall(function() return CoopController.coopView() end)
    return ok and c or nil
end
local function GetMissions()
    if not GAME_OK then return nil end
    local ok, m = pcall(function() return DataController.missions() end)
    return ok and m or nil
end
local function GetActiveChicken(roster)
    if not roster then return nil end
    local activeId = roster.activeId
    local chickens = roster.chickens or {}
    for _, c in ipairs(chickens) do
        if c.id == activeId then return c end
    end
    return chickens[1]
end
local hatchEnabled  = false
local hatchTiers    = {}
local hatchBatch    = false
local hatchGap      = 0.6
local equipBest     = false
local fuseEnabled   = false
local fuseMaxLevel  = 10
local fuseSameType  = false
local fuseGap       = 1.0
local sellEnabled   = false
local sellBelow     = 5
local sellRarities  = {}
local protectRarities = {}
local sellGap       = 1.5
local collectEnabled = false
local collectRadius  = 200
local collectGap     = 0.5
local coopEnabled   = false
local coopExpand    = true
local coopBuy       = true
local coopUpgrade   = true
local coopGap       = 4.0
local towerEnabled  = false
local towerGap      = 5.0
local pitEnabled    = false
local pitGap        = 4.0
local rebirthEnabled = false
local rebirthMinFloor = 0
local rebirthGap     = 10.0
local rewardDaily   = false
local rewardMissions = false
local rewardSocial  = false
local rewardPass    = false
local rewardGap     = 30.0
local redeemCode    = ""
local eventsEnabled = false
local eventGap      = 0.3
local function EggDisplayName(tier) return EGG_NAMES[tier] or tier end
local function TierFromOption(opt)
    if type(opt) ~= "string" then return nil end
    local t = opt:match("^([%w_]+)%s*%(")
    return t or opt
end
local function PickHatchTier(eggs)
    local selected = {}
    for i = #EGG_TIERS, 1, -1 do
        local t = EGG_TIERS[i]
        if hatchTiers[t] then table.insert(selected, t) end
    end
    if #selected > 0 then
        for _, t in ipairs(selected) do
            if (tonumber(eggs[t]) or 0) > 0 then return t end
        end
        return nil
    end
    for i = #EGG_TIERS, 1, -1 do
        local t = EGG_TIERS[i]
        if (tonumber(eggs[t]) or 0) > 0 then return t end
    end
    return nil
end
local function HatchOnce()
    local roster = GetRoster()
    local eggs = roster and roster.eggs
    if not eggs then return "no data" end
    local tier = PickHatchTier(eggs)
    if not tier then return "no eggs" end
    local count = tonumber(eggs[tier]) or 0
    local okR, err
    if hatchBatch and count >= 2 then
        okR, err = TryInvoke(D("HatchEggs"), tier, math.min(count, 10))
    else
        okR, err = TryInvoke(D("HatchEgg"), tier)
    end
    if not okR then return "hatch failed: " .. tostring(err) end
    return "hatched " .. EggDisplayName(tier)
end
local function PickFusePair(roster)
    local list = {}
    local activeId = roster.activeId
    for _, c in ipairs(roster.chickens or {}) do
        if c.id ~= activeId and not protectRarities[c.rarity] and (tonumber(c.level) or 0) < fuseMaxLevel then
            table.insert(list, c)
        end
    end
    table.sort(list, function(a, b) return (tonumber(a.level) or 0) < (tonumber(b.level) or 0) end)
    if fuseSameType and #list >= 2 then
        local byType = {}
        for _, c in ipairs(list) do
            byType[c.typeId] = byType[c.typeId] or {}
            table.insert(byType[c.typeId], c)
        end
        for _, group in pairs(byType) do
            if #group >= 2 then return group[1], group[2] end
        end
    end
    if #list >= 2 then return list[1], list[2] end
    return nil, nil
end
local function FuseOnce()
    local roster = GetRoster()
    if not roster then return "no data" end
    local a, b = PickFusePair(roster)
    if not (a and b) then return "no pair" end
    local okR, err = TryInvoke(D("FuseChickens"), a.id, b.id, nil, nil, nil)
    if not okR then return "fuse failed: " .. tostring(err) end
    return "fused"
end
local function SellableIds(roster)
    local ids = {}
    local activeId = roster.activeId
    for _, c in ipairs(roster.chickens or {}) do
        if c.id ~= activeId and not protectRarities[c.rarity] then
            local sell = false
            if sellBelow > 0 and (tonumber(c.level) or 0) < sellBelow then sell = true end
            if sellRarities[c.rarity] then sell = true end
            if sell then table.insert(ids, c.id) end
        end
    end
    return ids
end
local function SellOnce()
    local roster = GetRoster()
    if not roster then return "no data" end
    local ids = SellableIds(roster)
    if #ids == 0 then return "nothing to sell" end
    local okR, err = TryInvoke(D("SellChickens"), ids)
    if not okR then return "sell failed: " .. tostring(err) end
    return "sold " .. #ids
end
local function PowerScore(c)
    local lvl = tonumber(c.level) or 0
    local rank = RARITY_ORDER[c.rarity] or 1
    return lvl * 10 + rank
end
local function EquipBestOnce()
    local roster = GetRoster()
    if not roster then return "no data" end
    local best, bestScore = nil, -1
    for _, c in ipairs(roster.chickens or {}) do
        local s = PowerScore(c)
        if s > bestScore then best, bestScore = c, s end
    end
    if best and best.id ~= roster.activeId then
        local okR, err = TryInvoke(D("SetActiveChicken"), best.id)
        if not okR then return "equip failed: " .. tostring(err) end
        return "equipped " .. tostring(best.nickname or best.typeId)
    end
    return "already best"
end
local function ScanCollectibles(radius)
    local hrp = GetHRP()
    if not hrp then return {} end
    local list = {}
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent then
            local nm = part.Name:lower()
            if (nm:find("coop", 1, true) or nm:find("coin", 1, true) or nm:find("scrap", 1, true))
                and (part.Position - hrp.Position).Magnitude <= radius then
                table.insert(list, part)
            end
        end
    end
    return list
end
local function ScanEventDrops(radius)
    local hrp = GetHRP()
    if not hrp then return {} end
    local list = {}
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent then
            local nm = part.Name:lower()
            if (nm:find("coin", 1, true) or nm:find("scrap", 1, true)
                or nm:find("egg", 1, true) or nm:find("drop", 1, true)
                or nm:find("orb", 1, true) or nm:find("gem", 1, true))
                and (part.Position - hrp.Position).Magnitude <= radius then
                table.insert(list, part)
            end
        end
    end
    return list
end
local function CollectOnce()
    local drops = ScanCollectibles(collectRadius)
    if #drops == 0 then return 0 end
    for _, part in ipairs(drops) do
        if part.Parent then
            TeleportTo(part.Position)
            task.wait(0.1)
        end
    end
    return #drops
end
local function DrainQueue(queue, radius)
    local collected = 0
    while #queue > 0 and not HUB.dead do
        local pos = table.remove(queue, 1)
        if typeof(pos) == "Vector3" then
            TeleportTo(pos)
            task.wait(0.25)
            local drops = ScanEventDrops(radius)
            for _, part in ipairs(drops) do
                if part.Parent then
                    TeleportTo(part.Position)
                    task.wait(0.12)
                    collected = collected + 1
                end
            end
        end
    end
    return collected
end
local function CoopOnce()
    local view = GetCoop()
    if not view then return "no coop data" end
    local acted = {}
    if coopExpand and view.canExpand then
        local okRes = Invoke(D("ExpandCoop"))
        if okRes and okRes.ok then table.insert(acted, "expand") end
    end
    if coopBuy and view.buySlot then
        local okRes = Invoke(D("BuyGenerator"), view.buySlot)
        if okRes and okRes.ok then table.insert(acted, "buy slot " .. tostring(view.buySlot)) end
    end
    if coopUpgrade then
        local bestSlot, bestLvl = nil, nil
        for slot, g in pairs(view.gens or {}) do
            local lvl = tonumber(g.level) or 0
            if g.canUpgrade ~= false and (bestLvl == nil or lvl < bestLvl) then
                bestSlot, bestLvl = tonumber(slot), lvl
            end
        end
        if bestSlot then
            local okRes = Invoke(D("UpgradeGenerator"), bestSlot)
            if okRes and okRes.ok then table.insert(acted, "upgrade slot " .. tostring(bestSlot)) end
        end
    end
    return #acted > 0 and table.concat(acted, ", ") or "nothing"
end
local function ClaimAllMissions()
    if not (MissionView and GAME_OK) then return end
    local missions = GetMissions()
    local roster = GetRoster()
    if not missions then return end
    local snapshot = {
        roster = roster,
        towerBest = 0,
        rebirthCount = 0,
        recyclerLevel = 0,
        missions = missions,
    }
    pcall(function() snapshot.towerBest = tonumber(DataController.towerBest()) or 0 end)
    pcall(function()
        local rb = DataController.rebirth()
        if type(rb) == "table" then snapshot.rebirthCount = tonumber(rb.count) or 0 end
    end)
    pcall(function() snapshot.recyclerLevel = tonumber(DataController.recyclerLevel()) or 0 end)
    for _, scope in ipairs({ "daily", "weekly", "life" }) do
        local okAct, active = pcall(function() return MissionView.active(scope) end)
        if okAct and type(active) == "table" then
            for _, m in ipairs(active) do
                if m and m.id and m.kind == nil then
                    local okSt, st = pcall(function() return MissionView.stateOf(snapshot, m, os.time()) end)
                    if okSt and st == "ready" then
                        Invoke(D("MissionClaim"), m.id)
                    end
                end
            end
        end
    end
end
local function ClaimDaily()
    if not GAME_OK then return end
    local ok, daily = pcall(function() return DataController.daily() end)
    if not (ok and type(daily) == "table") then return end
    local claimed = daily.claimed or {}
    local played = tonumber(daily.played) or 0
    if (tonumber(daily.streak) or 0) >= 1 and not claimed["d"] then
        local res = Invoke(D("DailyClaim"), "day", nil)
        if res and res.ok then pcall(Notify, "Rewards", "Daily day " .. tostring(daily.streak) .. " claimed", "Success") end
    end
    local session = GameConfig and GameConfig.daily and GameConfig.daily.session
    local nSession = session and #session or 0
    for i = 1, nSession do
        if not claimed["s" .. i] then
            local at = session[i] and tonumber(session[i].at) or 0
            if played >= at then
                local res = Invoke(D("DailyClaim"), "session", i)
                if res and res.ok then
                    pcall(Notify, "Rewards", "Daily session tier " .. i .. " claimed", "Success")
                end
            end
        end
    end
end
local function ClaimPassLevels()
    if not (DataClient and GameConfig) then return end
    local ok, pass = pcall(function() return DataClient:get({ "pass" }) end)
    if not (ok and type(pass) == "table") then return end
    local passCfg = GameConfig.premium and GameConfig.premium.pass
    if not passCfg or not passCfg.levels then return end
    local points = tonumber(pass.points) or 0
    local claimed = pass.claimed or {}
    local maxLevel = math.min(math.floor(points / (tonumber(passCfg.xpPerLevel) or 60)), #passCfg.levels)
    local premium = pass.premium == true
    for lvl = 1, maxLevel do
        local track = passCfg.levels[lvl].premium and "premium" or "free"
        if track == "free" or (premium and not claimed[lvl .. ":premium"]) then
            if not claimed[lvl .. ":" .. track] then
                local res = Invoke(D("PassClaim"), lvl, track)
                if res and res.ok then
                    pcall(Notify, "Rewards", "Battle pass level " .. lvl .. " (" .. track .. ") claimed", "Success")
                end
            end
        end
    end
end
local function FindPitPosition()
    local pit = Workspace:FindFirstChild("Pit")
    if pit and pit:IsA("Model") then
        local pp = pit.PrimaryPart or pit:FindFirstChildWhichIsA("BasePart", true)
        if pp then return pp.Position end
        return pit:GetPivot().Position
    end
    local hrp = GetHRP()
    if not hrp then return nil end
    local arenas = Workspace:FindFirstChild("Arenas")
    if arenas then
        local best, bestD = nil, math.huge
        for _, a in ipairs(arenas:GetChildren()) do
            if a:IsA("Model") then
                local pp = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart", true)
                if pp then
                    local d = (pp.Position - hrp.Position).Magnitude
                    if d < bestD then best, bestD = pp.Position, d end
                end
            end
        end
        return best
    end
    return nil
end
local function GetFriendBoost()
    local n = LocalPlayer:GetAttribute("friendsHere") or 0
    n = math.max(0, math.min(math.floor(tonumber(n) or 0), 5))
    return n, n * 10
end
local function GetGroupPerk()
    return LocalPlayer:GetAttribute("groupMember") == true
end
local function GetServerBoost()
    local kind = Workspace:GetAttribute("ServerBoostKind")
    local mult = Workspace:GetAttribute("ServerBoostMult")
    local until_ = Workspace:GetAttribute("ServerBoostUntil")
    if kind and mult and until_ then
        local remain = 0
        pcall(function()
            remain = math.max(0, (tonumber(until_) or 0) - Workspace:GetServerTimeNow())
        end)
        return kind, tonumber(mult) or 1, remain
    end
    return nil, nil, nil
end
local function GetRebirthBonus()
    if not DataClient then return 0, 0, 1, 0 end
    local ok, rb = pcall(function() return DataClient:get({ "rebirth" }) end)
    if ok and type(rb) == "table" then
        local count = tonumber(rb.count) or 0
        local points = tonumber(rb.points) or 0
        local mult = 1 + count * 0.15 + points * 0.02
        local req = math.floor(25 + 5 * math.log(1 + 0.4 * count) + 0.5)
        return count, points, mult, req
    end
    return 0, 0, 1, 25
end
local function FormatBoostText()
    local lines = {}
    local friendCount, friendPct = GetFriendBoost()
    lines[#lines + 1] = "Friend Boost: " .. friendCount .. "/5 → +" .. friendPct .. "% money"
    if GetGroupPerk() then
        lines[#lines + 1] = "Group Perk: ACTIVE → +5% money"
    else
        lines[#lines + 1] = "Group Perk: join group 180466034 for +5%"
    end
    local kind, mult, remain = GetServerBoost()
    if kind then
        local mins = math.floor(remain / 60)
        local secs = math.floor(remain % 60)
        lines[#lines + 1] = "Server Boost: ACTIVE ×" .. mult .. " (" .. kind .. ", " .. mins .. "m " .. secs .. "s left)"
    else
        lines[#lines + 1] = "Server Boost: inactive (2+ players = ×2)"
    end
    local rc, rp, rmult, rreq = GetRebirthBonus()
    lines[#lines + 1] = "Rebirth: ×" .. string.format("%.2f", rmult) .. " (" .. rc .. " rebirths, " .. rp .. " pts) — next at tower floor " .. rreq
    return table.concat(lines, "\n")
end
local function GetTowerBest()
    if not GAME_OK then return 0 end
    local ok, n = pcall(function() return DataController.towerBest() end)
    return ok and (tonumber(n) or 0) or 0
end
local function GetOwnCoopPos()
    local plot = LocalPlayer:GetAttribute("Plot")
    if not plot then return nil end
    local coops = Workspace:FindFirstChild("Coops")
    local coop = coops and coops:FindFirstChild("Coop" .. tostring(plot))
    if not coop then return nil end
    local origin = coop:GetAttribute("Origin")
    if typeof(origin) == "CFrame" then
        return origin.Position + Vector3.new(0, 3, 0)
    end
    local prim = coop.PrimaryPart or coop:FindFirstChildWhichIsA("BasePart", true)
    if prim then return prim.Position end
    return coop:GetPivot().Position
end
local function GetOwnChickenState()
    local bodies = Workspace:FindFirstChild("ChickenBodies")
    local uid = LocalPlayer.UserId
    if not bodies then return nil end
    for _, b in ipairs(bodies:GetChildren()) do
        local ok, owner = pcall(function() return b:GetAttribute("ovOwner") end)
        if ok and owner == uid then
            local ok2, st = pcall(function() return b:GetAttribute("ovState") end)
            return ok2 and st or "corral"
        end
    end
    return nil
end
local function RebirthReady()
    if not GAME_OK then return false, "Game API not connected" end
    if not GetActiveChicken(GetRoster()) then return false, "no rooster" end
    if towerRunning then return false, "finish the tower run first" end
    local _, _, _, req = GetRebirthBonus()
    local best = GetTowerBest()
    if best < req then
        return false, "tower floor " .. best .. "/" .. req
    end
    return true, nil
end
local function RebirthOnce()
    local ready, reason = RebirthReady()
    if not ready then return false, reason end
    if GetOwnChickenState() ~= "corral" then
        local pos = GetOwnCoopPos()
        if pos then
            TeleportTo(pos)
            task.wait(2)
        end
    end
    local okR, err = TryInvoke(D("Rebirth"))
    if not okR then return false, err end
    return true, nil
end
local ChickensTab = Window:AddTab({ Title = "Chickens", Icon = "solar/crown-bold" })
local HatchSub = ChickensTab:AddSection("Hatch", "solar/home-bold")
HatchSub:AddToggle({
    Title = "Auto Hatch", Default = false, Flag = "hatch_auto",
    Callback = safeCallback(function(v)
        hatchEnabled = v
        Notify("Auto Hatch", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
do
    local opts = {}
    for _, t in ipairs(EGG_TIERS) do table.insert(opts, t .. " (" .. EggDisplayName(t) .. ")") end
    local function setTiers(list)
        hatchTiers = {}
        for _, opt in ipairs(list or {}) do
            local t = TierFromOption(opt)
            if t then hatchTiers[t] = true end
        end
    end
    local dd = HatchSub:AddMultiDropdown({
        Title = "Egg Tiers (empty = auto best)", Options = opts, Default = {},
        MaxVisible = 8, Searchable = true, Flag = "hatch_tiers",
        Callback = setTiers,
    })
    registerResync(dd, setTiers)
end
HatchSub:AddToggle({
    Title = "Auto Equip Best Chicken", Default = false, Flag = "equip_best",
    Callback = function(v) equipBest = v end,
})
HatchSub:AddToggle({
    Title = "Batch Hatch (up to 10)", Default = false, Flag = "hatch_batch",
    Callback = function(v) hatchBatch = v end,
})
HatchSub:AddSlider({ Title = "Hatch Gap", Min = 0.1, Max = 10, Default = 0.6, Suffix = "s", Flag = "hatch_gap", Callback = function(v) hatchGap = v end })
HatchSub:AddButton({
    Title = "Hatch Once", Primary = true,
    Callback = safeCallback(function()
        local res = HatchOnce()
        Notify("Hatch", res or "failed", res and res ~= "no eggs" and res ~= "no data" and "Success" or "Info")
    end),
})
local FuseSub = ChickensTab:AddSection("Fuse", "solar/home-bold")
FuseSub:AddToggle({
    Title = "Auto Fuse", Default = false, Flag = "fuse_auto",
    Callback = safeCallback(function(v)
        fuseEnabled = v
        Notify("Auto Fuse", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
FuseSub:AddSlider({ Title = "Fuse Below Level", Min = 1, Max = 500, Default = 10, Suffix = "", Flag = "fuse_maxlevel", Callback = function(v) fuseMaxLevel = v end })
FuseSub:AddToggle({ Title = "Prefer Same Type", Default = false, Flag = "fuse_sametype", Callback = function(v) fuseSameType = v end })
FuseSub:AddSlider({ Title = "Fuse Gap", Min = 0.1, Max = 30, Default = 1, Suffix = "s", Flag = "fuse_gap", Callback = function(v) fuseGap = v end })
FuseSub:AddButton({
    Title = "Fuse Once", Primary = true,
    Callback = safeCallback(function()
        local res = FuseOnce()
        Notify("Fuse", res or "failed", res and res ~= "no pair" and res ~= "no data" and "Success" or "Info")
    end),
})
local SellSub = ChickensTab:AddSection("Sell", "solar/home-bold")
SellSub:AddToggle({
    Title = "Auto Sell", Default = false, Flag = "sell_auto",
    Callback = safeCallback(function(v)
        sellEnabled = v
        Notify("Auto Sell", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
SellSub:AddSlider({ Title = "Sell Below Level", Min = 0, Max = 1000, Default = 5, Suffix = " (0 = off)", Flag = "sell_below", Callback = function(v) sellBelow = v end })
do
    local function setSellRarities(list)
        sellRarities = {}
        for _, r in ipairs(list or {}) do sellRarities[r] = true end
    end
    local dd = SellSub:AddMultiDropdown({
        Title = "Sell Rarities (always)", Options = RARITY_LIST, Default = {},
        MaxVisible = 8, Searchable = true, Flag = "sell_rarities",
        Callback = setSellRarities,
    })
    registerResync(dd, setSellRarities)
end
do
    local function setProtect(list)
        protectRarities = {}
        for _, r in ipairs(list or {}) do protectRarities[r] = true end
    end
    local dd = SellSub:AddMultiDropdown({
        Title = "Protect Rarities (never sell/fuse)", Options = RARITY_LIST, Default = {},
        MaxVisible = 8, Searchable = true, Flag = "protect_rarities",
        Callback = setProtect,
    })
    registerResync(dd, setProtect)
end
SellSub:AddSlider({ Title = "Sell Gap", Min = 0.1, Max = 30, Default = 1.5, Suffix = "s", Flag = "sell_gap", Callback = function(v) sellGap = v end })
SellSub:AddButton({
    Title = "Sell Now", Primary = true,
    Callback = safeCallback(function()
        local res = SellOnce()
        Notify("Sell", res or "failed", res and res ~= "nothing to sell" and res ~= "no data" and "Success" or "Info")
    end),
})
local RebirthSub = ChickensTab:AddSection("Rebirth", "solar/home-bold")
RebirthSub:AddToggle({
    Title = "Auto Rebirth", Default = false, Flag = "rebirth_auto",
    Callback = safeCallback(function(v)
        rebirthEnabled = v
        Notify("Auto Rebirth", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
RebirthSub:AddSlider({ Title = "Min Tower Floor (0 = auto)", Min = 0, Max = 1000, Default = 0, Suffix = "", Flag = "rebirth_floor", Callback = function(v) rebirthMinFloor = v end })
RebirthSub:AddSlider({ Title = "Check Gap", Min = 1, Max = 60, Default = 10, Suffix = "s", Flag = "rebirth_gap", Callback = function(v) rebirthGap = v end })
RebirthSub:AddButton({
    Title = "Rebirth Now", Primary = true,
    Callback = safeCallback(function()
        local okR, err = RebirthOnce()
        if okR then Notify("Rebirth", "Rebirth successful!", "Success")
        else Notify("Rebirth", "Failed: " .. tostring(err), "Error") end
    end),
})
local WorldTab = Window:AddTab({ Title = "World", Icon = "swords" })
local TowerSub = WorldTab:AddSection("Tower", "solar/home-bold")
TowerSub:AddToggle({
    Title = "Auto Tower", Default = false, Flag = "tower_auto",
    Callback = safeCallback(function(v)
        towerEnabled = v
        Notify("Auto Tower", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
TowerSub:AddSlider({ Title = "Restart Gap", Min = 1, Max = 60, Default = 5, Suffix = "s", Flag = "tower_gap", Callback = function(v) towerGap = v end })
TowerSub:AddButton({
    Title = "Start Tower Run", Primary = true,
    Callback = safeCallback(function()
        local okR, err = TryInvoke(D("TowerStart"))
        if okR then Notify("Tower", "Run started", "Success")
        else Notify("Tower", "Failed: " .. tostring(err), "Error") end
    end),
})
TowerSub:AddButton({
    Title = "Surrender Tower",
    Callback = safeCallback(function()
        local okR, err = TryInvoke(D("TowerSurrender"))
        if okR then Notify("Tower", "Run surrendered", "Success")
        else Notify("Tower", "Failed: " .. tostring(err), "Error") end
    end),
})
local PitSub = WorldTab:AddSection("Pit", "solar/home-bold")
PitSub:AddToggle({
    Title = "Auto Pit (stay in arena)", Default = false, Flag = "pit_auto",
    Callback = safeCallback(function(v)
        pitEnabled = v
        Notify("Auto Pit", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
PitSub:AddSlider({ Title = "Check Gap", Min = 1, Max = 30, Default = 4, Suffix = "s", Flag = "pit_gap", Callback = function(v) pitGap = v end })
PitSub:AddButton({
    Title = "Teleport To Pit", Primary = true,
    Callback = safeCallback(function()
        local pos = FindPitPosition()
        if pos then
            TeleportTo(pos)
            Notify("Pit", "Teleported to the pit", "Success")
        else
            Notify("Pit", "Pit not found", "Error")
        end
    end),
})
local EventsSub = WorldTab:AddSection("Events", "solar/home-bold")
EventsSub:AddToggle({
    Title = "Auto Events", Default = false, Flag = "events_auto",
    Callback = safeCallback(function(v)
        eventsEnabled = v
        Notify("Auto Events", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
EventsSub:AddToggle({
    Title = "Golden Goose (coins)", Default = true, Flag = "events_goose",
    Callback = function(v) gooseEnabled = v end,
})
EventsSub:AddToggle({
    Title = "HotEgg Meteor (eggs)", Default = true, Flag = "events_hotegg",
    Callback = function(v) hotEggEnabled = v end,
})
EventsSub:AddSlider({ Title = "Sweep Gap", Min = 0.1, Max = 2, Default = 0.3, Suffix = "s", Flag = "events_gap", Callback = function(v) eventGap = v end })
EventsSub:AddButton({
    Title = "Teleport To Last Goose", Primary = true,
    Callback = safeCallback(function()
        if lastGoosePos then TeleportTo(lastGoosePos); Notify("Events", "At last goose", "Success")
        else Notify("Events", "No goose seen yet", "Info") end
    end),
})
EventsSub:AddButton({
    Title = "Teleport To Last Meteor",
    Callback = safeCallback(function()
        if lastEggPos then TeleportTo(lastEggPos); Notify("Events", "At last meteor", "Success")
        else Notify("Events", "No meteor seen yet", "Info") end
    end),
})
local EconomyTab = Window:AddTab({ Title = "Economy", Icon = "solar/dollar-minimalistic-bold" })
local CoopSub = EconomyTab:AddSection("Coop", "solar/home-bold")
CoopSub:AddToggle({
    Title = "Auto Coop", Default = false, Flag = "coop_auto",
    Callback = safeCallback(function(v)
        coopEnabled = v
        Notify("Auto Coop", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
CoopSub:AddToggle({ Title = "Auto Expand", Default = true, Flag = "coop_expand", Callback = function(v) coopExpand = v end })
CoopSub:AddToggle({ Title = "Auto Buy Generator", Default = true, Flag = "coop_buy", Callback = function(v) coopBuy = v end })
CoopSub:AddToggle({ Title = "Auto Upgrade Generators", Default = true, Flag = "coop_upgrade", Callback = function(v) coopUpgrade = v end })
CoopSub:AddSlider({ Title = "Coop Gap", Min = 1, Max = 60, Default = 4, Suffix = "s", Flag = "coop_gap", Callback = function(v) coopGap = v end })
CoopSub:AddButton({
    Title = "Run Coop Once", Primary = true,
    Callback = safeCallback(function()
        local res = CoopOnce()
        Notify("Coop", res or "failed", "Info")
    end),
})
CoopSub:AddButton({
    Title = "Upgrade Recycler",
    Callback = safeCallback(function()
        local okR, err = TryInvoke(D("UpgradeRecycler"))
        if okR then Notify("Recycler", "Upgraded!", "Success")
        else Notify("Recycler", "Failed: " .. tostring(err), "Error") end
    end),
})
local CollectSub = EconomyTab:AddSection("Collect", "solar/home-bold")
CollectSub:AddToggle({
    Title = "Auto Collect", Default = false, Flag = "collect_auto",
    Callback = safeCallback(function(v)
        collectEnabled = v
        Notify("Auto Collect", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
CollectSub:AddSlider({ Title = "Scan Radius", Min = 30, Max = 1000, Default = 200, Suffix = " studs", Flag = "collect_radius", Callback = function(v) collectRadius = v end })
CollectSub:AddSlider({ Title = "Collect Gap", Min = 0.1, Max = 5, Default = 0.5, Suffix = "s", Flag = "collect_gap", Callback = function(v) collectGap = v end })
CollectSub:AddButton({
    Title = "Collect Once", Primary = true,
    Callback = safeCallback(function()
        local n = CollectOnce()
        Notify("Collect", n > 0 and ("Collected " .. n .. " drop(s)") or "Nothing nearby", n > 0 and "Success" or "Info")
    end),
})
local RewardsSub = EconomyTab:AddSection("Rewards", "solar/home-bold")
RewardsSub:AddToggle({ Title = "Auto Daily", Default = false, Flag = "reward_daily", Callback = function(v) rewardDaily = v end })
RewardsSub:AddToggle({ Title = "Auto Missions", Default = false, Flag = "reward_missions", Callback = function(v) rewardMissions = v end })
RewardsSub:AddToggle({ Title = "Auto Social", Default = false, Flag = "reward_social", Callback = function(v) rewardSocial = v end })
RewardsSub:AddToggle({ Title = "Auto Battle Pass", Default = false, Flag = "reward_pass", Callback = function(v) rewardPass = v end })
RewardsSub:AddSlider({ Title = "Claim Gap", Min = 5, Max = 300, Default = 30, Suffix = "s", Flag = "reward_gap", Callback = function(v) rewardGap = v end })
RewardsSub:AddButton({
    Title = "Claim All Now", Primary = true,
    Callback = safeCallback(function()
        ClaimDaily()
        Invoke(D("SocialClaim"))
        ClaimAllMissions()
        ClaimPassLevels()
        Notify("Rewards", "Daily + social + missions + pass claimed", "Success")
    end),
})
RewardsSub:AddInput({
    Title = "Redeem Code", Placeholder = "CODE", Default = "", Flag = "redeem_code",
    Callback = function(text) redeemCode = text or "" end,
})
RewardsSub:AddButton({
    Title = "Redeem",
    Callback = safeCallback(function()
        if redeemCode == "" then Notify("Rewards", "Enter a code first", "Error"); return end
        local okR, err = TryInvoke(D("RedeemCode"), redeemCode)
        if okR then Notify("Rewards", "Code accepted!", "Success")
        else Notify("Rewards", "Code rejected: " .. tostring(err), "Error") end
    end),
})
local BoostsSub = EconomyTab:AddSection("Boosts", "solar/home-bold")
local boostsParagraph = BoostsSub:AddParagraph({
    Title = "Live Boosts",
    Text = FormatBoostText(),
})
BoostsSub:AddButton({
    Title = "Refresh Now", Primary = true,
    Callback = safeCallback(function()
        if boostsParagraph then boostsParagraph:Set(FormatBoostText()) end
        Notify("Boosts", "Refreshed", "Success")
    end),
})
BoostsSub:AddButton({
    Title = "Dump Game Data",
    Callback = safeCallback(function()
        if not GAME_OK then Notify("Boosts", "Game API not ready", "Error"); return end
        local roster = GetRoster()
        local money = GetMoney()
        local active = GetActiveChicken(roster)
        print("[Oxide] ═══ CHICKEN FIGHTER ═══")
        print("[Oxide] Money:", tostring(money))
        print("[Oxide] Chickens:", #(roster and roster.chickens or {}), "| Active:", active and (active.id .. " lvl " .. tostring(active.level) .. " " .. tostring(active.rarity)) or "none")
        print("[Oxide] Boosts:", FormatBoostText():gsub("\n", " | "))
        Notify("Boosts", "Data dumped to console", "Success", 3)
    end),
})
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
local wsEnabled, wsValue = false, 16
local jpEnabled, jpValue = false, 60
MoveSub:AddToggle({
    Title = "WalkSpeed", Default = false, Flag = "ws_enabled",
    Callback = function(v)
        wsEnabled = v
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v and wsValue or 16 end
    end,
})
MoveSub:AddSlider({
    Title = "WalkSpeed Value", Min = 16, Max = 24, Default = 16, Suffix = " (max 24 = safe)", Flag = "ws_value",
    Callback = function(v)
        wsValue = v
        if wsEnabled then local hum = GetHumanoid(); if hum then hum.WalkSpeed = v end end
    end,
})
MoveSub:AddToggle({
    Title = "JumpPower", Default = false, Flag = "jp_enabled",
    Callback = function(v)
        jpEnabled = v
        local hum = GetHumanoid()
        if hum then
            if v then
                hum.UseJumpPower = true
                hum.JumpPower = jpValue
            else
                hum.UseJumpPower = false
            end
        end
    end,
})
MoveSub:AddSlider({
    Title = "JumpPower Value", Min = 50, Max = 100, Default = 60, Suffix = " (max 100 = safe)", Flag = "jp_value",
    Callback = function(v)
        jpValue = v
        if jpEnabled then local hum = GetHumanoid(); if hum then hum.UseJumpPower = true; hum.JumpPower = v end end
    end,
})
track(LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    task.wait(0.2)
    if HUB.dead then return end
    if wsEnabled then hum.WalkSpeed = wsValue end
    if jpEnabled then hum.UseJumpPower = true; hum.JumpPower = jpValue end
end))
local FlySub = PlayerTab:AddSection("Noclip", "solar/home-bold")
FlySub:AddParagraph({
    Title = "Fly removed",
    Text = "Fly was removed because the new movement guard detects sustained " ..
           "airtime and would disconnect you. All teleports now glide at a safe " ..
           "speed instead.",
})
local noclip = false
local noclipConn
FlySub:AddToggle({
    Title = "Noclip", Default = false, Flag = "noclip_enabled",
    Callback = function(v)
        noclip = v
        if v then
            if noclipConn then noclipConn:Disconnect() end
            noclipConn = RunService.Stepped:Connect(function()
                if HUB.dead or not noclip then return end
                local char = GetCharacter()
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        end
        Notify("Noclip", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end,
})
local AfkSub = PlayerTab:AddSection("Anti-AFK", "solar/home-bold")
local antiAFK = true
AfkSub:AddToggle({
    Title = "Anti-AFK", Default = true, Flag = "anti_afk",
    Callback = function(v) antiAFK = v end,
})
if not _G.OxideChickenFighterAntiAFK then
    _G.OxideChickenFighterAntiAFK = true
    LocalPlayer.Idled:Connect(function()
        if antiAFK and not HUB.dead then
            pcall(function()
                local VU = game:GetService("VirtualUser")
                VU:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(1)
                VU:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
    end)
end
local TpSub = PlayerTab:AddSection("Teleport", "solar/home-bold")
local selectedPlayer = nil
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    table.sort(names)
    if #names == 0 then names = { "(no other players)" } end
    return names
end
local function ResolvePlayer(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name then return p end
    end
    return nil
end
local function applyPlayerSelect(v) selectedPlayer = v end
local playerDropdown = TpSub:AddDropdown({
    Title = "Player", Options = GetPlayerNames(), Default = nil,
    MaxVisible = 6, Searchable = true, Flag = "tp_player",
    Callback = applyPlayerSelect,
})
registerResync(playerDropdown, applyPlayerSelect)
TpSub:AddButton({
    Title = "Refresh Players",
    Callback = function()
        playerDropdown:SetOptions(GetPlayerNames())
        Notify("Teleport", "Player list refreshed", "Info")
    end,
})
TpSub:AddButton({
    Title = "Teleport To Player", Primary = true,
    Callback = function()
        local target = ResolvePlayer(selectedPlayer)
        local tHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            TeleportTo((tHRP.CFrame * CFrame.new(0, 0, 3)).Position)
            Notify("Teleport", "Teleported to " .. target.Name, "Success")
        else
            Notify("Teleport", "Target unavailable", "Error")
        end
    end,
})
local waypoints = {}
local pendingName = "Spot 1"
local selectedWaypoint = nil
local function WaypointNames()
    local names = {}
    for name in pairs(waypoints) do table.insert(names, name) end
    table.sort(names)
    if #names == 0 then names = { "(none)" } end
    return names
end
local function applyWpSelect(v) selectedWaypoint = v end
local waypointDropdown
TpSub:AddInput({
    Title = "Waypoint Name", Placeholder = "Spot 1", Default = "Spot 1", Flag = "wp_name",
    Callback = function(text) pendingName = (text ~= "" and text) or "Spot 1" end,
})
TpSub:AddButton({
    Title = "Save Current Position", Primary = true,
    Callback = function()
        local hrp = GetHRP()
        if not hrp then Notify("Waypoints", "No character", "Error"); return end
        waypoints[pendingName] = hrp.CFrame
        if waypointDropdown then waypointDropdown:SetOptions(WaypointNames()) end
        Notify("Waypoints", "Saved '" .. pendingName .. "'", "Success")
    end,
})
waypointDropdown = TpSub:AddDropdown({
    Title = "Saved Waypoints", Options = WaypointNames(), Default = nil,
    MaxVisible = 6, Searchable = true, Flag = "wp_selected",
    Callback = applyWpSelect,
})
registerResync(waypointDropdown, applyWpSelect)
TpSub:AddButton({
    Title = "Teleport To Waypoint",
    Callback = function()
        local cf = selectedWaypoint and waypoints[selectedWaypoint]
        if cf then
            TeleportTo(cf.Position)
            Notify("Waypoints", "Teleported to '" .. selectedWaypoint .. "'", "Success")
        else
            Notify("Waypoints", "Waypoint unavailable", "Error")
        end
    end,
})
TpSub:AddButton({
    Title = "Teleport To Spawn",
    Callback = function()
        local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if spawn then
            TeleportTo(spawn.Position)
            Notify("Teleport", "Teleported to spawn", "Success")
        else
            Notify("Teleport", "No spawn found", "Error")
        end
    end,
})
TpSub:AddButton({
    Title = "Teleport To Pit",
    Callback = safeCallback(function()
        local pos = FindPitPosition()
        if pos then
            TeleportTo(pos)
            Notify("Teleport", "Teleported to the pit", "Success")
        else
            Notify("Teleport", "Pit not found", "Error")
        end
    end),
})
TpSub:AddButton({
    Title = "Teleport To Nearest Arena",
    Callback = safeCallback(function()
        local hrp = GetHRP()
        local arenas = Workspace:FindFirstChild("Arenas")
        if not (hrp and arenas) then Notify("Teleport", "Arenas not found", "Error"); return end
        local best, bestD = nil, math.huge
        for _, a in ipairs(arenas:GetChildren()) do
            if a:IsA("Model") then
                local pp = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart", true)
                if pp then
                    local d = (pp.Position - hrp.Position).Magnitude
                    if d < bestD then best, bestD = pp.Position, d end
                end
            end
        end
        if best then TeleportTo(best); Notify("Teleport", "At arena", "Success") end
    end),
})
if HAS_CONFIG then
    pcall(function() Library:LoadConfig(CONFIG_NAME) end)
    ResyncAll()
end
task.spawn(function()
    while not HUB.dead do
        task.wait(60)
        if HAS_CONFIG and not HUB.dead then
            pcall(function() Library:SaveConfig(CONFIG_NAME) end)
        end
    end
end)
task.spawn(function()
    while not HUB.dead do
        if hatchEnabled then pcall(HatchOnce) end
        task.wait(hatchGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if equipBest then pcall(EquipBestOnce) end
        task.wait(5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if fuseEnabled then pcall(FuseOnce) end
        task.wait(fuseGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if sellEnabled then pcall(SellOnce) end
        task.wait(sellGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if collectEnabled then pcall(CollectOnce) end
        task.wait(collectGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if coopEnabled then pcall(CoopOnce) end
        task.wait(coopGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if towerEnabled and GAME_OK and not towerRunning then
            local okR, err = TryInvoke(D("TowerStart"))
            if err and not okR then
                pcall(Notify, "Tower", "Start failed: " .. tostring(err), "Error")
            end
        end
        task.wait(towerGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if pitEnabled then
            local pos = FindPitPosition()
            local hrp = GetHRP()
            if pos and hrp and (hrp.Position - pos).Magnitude > 60 then
                TeleportTo(pos)
            end
        end
        task.wait(pitGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if rebirthEnabled then
            local ready = RebirthReady()
            if ready then
                local best = GetTowerBest()
                if rebirthMinFloor <= 0 or best >= rebirthMinFloor then
                    local okR, err = RebirthOnce()
                    if okR then
                        pcall(Notify, "Rebirth", "Rebirthed at tower floor " .. best .. "!", "Success")
                        task.wait(5)
                    elseif err then
                        pcall(Notify, "Rebirth", "Failed: " .. tostring(err), "Error")
                    end
                end
            end
        end
        task.wait(rebirthGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if rewardDaily then pcall(ClaimDaily) end
        if rewardSocial then Invoke(D("SocialClaim")) end
        if rewardMissions then pcall(ClaimAllMissions) end
        if rewardPass then pcall(ClaimPassLevels) end
        task.wait(rewardGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if eventsEnabled then
            if gooseEnabled then pcall(DrainQueue, gooseQueue, 30) end
            if hotEggEnabled then pcall(DrainQueue, eggQueue, 30) end
            local drops = ScanEventDrops(60)
            for _, part in ipairs(drops) do
                if part.Parent and not HUB.dead then
                    TeleportTo(part.Position)
                    task.wait(0.12)
                end
            end
        end
        task.wait(eventGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if boostsParagraph then
            pcall(function() boostsParagraph:Set(FormatBoostText()) end)
        end
        task.wait(5)
    end
end)
for _ = 1, 8 do
    if GAME_OK then break end
    pcall(initGame)
    if GAME_OK then break end
    task.wait(1)
end
if GAME_OK then
    Notify("NevaHub", "Game API connected", "Success", 2)
else
    Notify("NevaHub", "Game API unavailable - Auto tabs disabled", "Error", 4)
end
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(HUB.conns)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if HAS_CONFIG then pcall(function() Library:SaveConfig(CONFIG_NAME) end) end
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
    end)
    _G.OxideChickenFighter = nil
end
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
