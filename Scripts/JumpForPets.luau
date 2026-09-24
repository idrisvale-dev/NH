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
    SubTitle = "Jump For Pets",
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
    local prev = _G.OxideJumpForPets
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideJumpForPets = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local Players             = game:GetService("Players")
local RS                  = game:GetService("ReplicatedStorage")
local ReplicatedStorage   = RS
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Workspace           = game:GetService("Workspace")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local VirtualUser         = game:GetService("VirtualUser")
local TweenService        = game:GetService("TweenService")
local HttpService         = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LP          = Players.LocalPlayer
local LocalPlayer = LP
local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
end
local function Notify(title, content, kind, dur)
    pcall(function()
        Fluent:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
    end)
end
local function safeCallback(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[JumpForPets Error] " .. tostring(err))
            Notify("Error", tostring(err), "Error", 4)
        end
    end
end
local AreasSettings, EggsSettings, RaritiesSettings, AnimalsSettings, TrailsSettings, SpeedUpgradesSettings, RecommendedJumpsSettings
pcall(function() AreasSettings = require(RS.Settings.Areas) end)
pcall(function() EggsSettings = require(RS.Settings.Eggs) end)
pcall(function() RaritiesSettings = require(RS.Settings.Rarities) end)
pcall(function() AnimalsSettings = require(RS.Settings.Animals) end)
pcall(function() TrailsSettings = require(RS.Settings.Trails) end)
pcall(function() SpeedUpgradesSettings = require(RS.Settings.SpeedUpgrades) end)
pcall(function() RecommendedJumpsSettings = require(RS.Settings.RecommendedJumps) end)
local function GetEggRequiredJumpPower(egg, stageName)
    if not RecommendedJumpsSettings or not RecommendedJumpsSettings.List then return 0 end
    local aName = egg:GetAttribute("AreaName") or stageName
    local sName = egg:GetAttribute("SpawnerName") or "1"
    local key = tostring(aName) .. tostring(sName)
    return RecommendedJumpsSettings.List[key] or 0
end
local function GetPlayerJumpPower()
    local jp = LP:FindFirstChild("JumpPower")
    if jp and typeof(jp.Value) == "number" then
        return jp.Value
    end
    local hum = findHum()
    return hum and hum.JumpPower or 0
end
local function GetRemote(name)
    local f = RS:FindFirstChild("Remotes")
    return f and f:FindFirstChild(name)
end
local function findChar() return LP.Character end
local function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end
local function GetMyPlot()
    local pFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Plots")
    if not pFolder then return nil end
    local uidStr = tostring(LP.UserId)
    for _, plot in ipairs(pFolder:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == uidStr or plot:GetAttribute("OwnerUserId") == LP.UserId then
            return plot
        end
    end
    return nil
end
local function GetPlotPenPosition()
    local plot = GetMyPlot()
    local detector = plot and plot:FindFirstChild("Detector")
    if detector then
        return detector.Position + Vector3.new(0, 1.5, 0)
    end
    return plot and (plot:GetPivot().Position + Vector3.new(0, 3, 0)) or Vector3.new(-72, 5, 65)
end
local function GetSquatDetector()
    local plot = GetMyPlot()
    local sz = plot and plot:FindFirstChild("SquatZone")
    local floor = sz and sz:FindFirstChild("Floor")
    local det = floor and floor:FindFirstChild("Detector")
    return det
end
local function GetSquatDetectorPosition()
    local det = GetSquatDetector()
    return det and (det.Position + Vector3.new(0, 1.5, 0)) or nil
end
local RARITY_NAMES = {
    "Ascended", "Eternal", "Celestial", "Divine", "Mythic",
    "Legendary", "Epic", "Rare", "Uncommon", "Common"
}
local RARITY_SCORE_MAP = {
    ["Ascended"]    = 1500,
    ["Eternal"]     = 1300,
    ["Celestial"]   = 1100,
    ["Divine"]      = 950,
    ["Mythic"]      = 800,
    ["Legendary"]   = 650,
    ["Epic"]        = 500,
    ["Rare"]        = 350,
    ["Uncommon"]    = 200,
    ["Common"]      = 100,
}
local STAGE_NAMES = {
    "Meadow", "Coral Reef", "Winter", "Desert", "Crystal Mines",
    "Jungle", "Mystic Isles", "Prehistoric", "Celestial Heights"
}
local STAGE_COORDINATES = {
    ["Meadow"]            = Vector3.new(0, -2, -50),
    ["Coral Reef"]        = Vector3.new(38, 13, -201),
    ["Winter"]            = Vector3.new(-3, 70, -321),
    ["Desert"]            = Vector3.new(8, 253, -502),
    ["Crystal Mines"]     = Vector3.new(19, 538, -617),
    ["Jungle"]            = Vector3.new(20, 904, -781),
    ["Mystic Isles"]      = Vector3.new(-15, 1400, -923),
    ["Prehistoric"]       = Vector3.new(8, 2047, -1067),
    ["Celestial Heights"] = Vector3.new(-26, 3233, -1177),
    ["My Plot"]           = Vector3.new(-72, 3, 65),
    ["Sell Stand"]        = Vector3.new(142, 3, -25),
    ["Coil Shop"]         = Vector3.new(71, 3, -29),
    ["Main Shop"]         = Vector3.new(-70, 0, -31),
    ["Spawn"]             = Vector3.new(3, -2, 0),
}
local autoFarmEggs            = false
local autoPlaceEggs           = false
local autoHatchEggs           = false
local autoEquipBest           = false
local equipBestInterval       = 15
local hasStolenInitialEgg     = false
local farmRarities            = {}
local farmMutatedOnly         = false
local farmMinCPS              = 0
local autoSellPets            = false
local sellRarities            = {}
local sellIgnoreMutations     = true
local sellBelowCPS            = 10
local autoTrain               = false
local auto2xBonus             = false
local autoUpgradeBarbell      = false
local autoBuyBestCoil         = false
local autoBuyBestTrail        = false
local autoUpgradePlot         = false
local autoClaimIndex          = false
local webhookEnabled          = false
local webhookURL              = ""
local webhookUserPing         = ""
local webhookRarities         = {}
local webhookMutatedOnly      = false
local webhookMinCPS           = 0
local antiAFK                 = true
local divineFirstRoutineMode  = true
local lastTrainedLevel        = nil
local autoScaleToJumpPower    = true
local stealMovementMethod     = "Instant Safe TP"
local rareEggHunter           = true
local stealBigEggsOnly        = false
local glideSpeed              = 200
local stealDelay              = 0
local savedReturnCFrame       = nil
local autoStealEnabled        = false
local autoSquatTrain          = false
local autoClickSquatBonus     = false
local autoUpgradeBarbells     = false
local autoEquipBestPets       = false
local autoClaimAllRewards     = false
local autoSell                = false
local autoEquipBestTrail      = false
local autoEquipBestCoil       = false
local autoPlaceEggs           = true
local selectedStealRarities   = {}
local selectedStealAreas      = {}
local function SafeTeleport(targetPos)
    local root = findHRP()
    if not root or not targetPos then return false end
    root.CFrame = CFrame.new(targetPos)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end
local function MoveToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or tonumber(glideSpeed) or 200, 50, 750)
    local moveTime = math.max(dist / speed, 0.02)
    if easeOut then moveTime = moveTime * 1.25 end
    local t0 = os.clock()
    local delta = target - start
    local dir = delta.Magnitude > 0.001 and delta.Unit or Vector3.new(1, 0, 0)
    while os.clock() - t0 < moveTime and not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local linearAlpha = math.clamp((os.clock() - t0) / moveTime, 0, 1)
        local a = easeOut and math.sin(linearAlpha * (math.pi / 2)) or linearAlpha
        local cur = start:Lerp(target, a)
        hrp.CFrame = CFrame.lookAt(cur, cur + dir)
        local curSpeed = easeOut and math.max(speed * (1 - linearAlpha * 0.8), 35) or speed
        hrp.AssemblyLinearVelocity = dir * curSpeed
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hrp.CFrame = CFrame.new(target)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end
local function FlyToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or tonumber(glideSpeed) or 200, 50, 750)
    local moveTime = math.max(dist / speed, 0.02)
    if easeOut then moveTime = moveTime * 1.25 end
    local t0 = os.clock()
    local delta = target - start
    local dir = delta.Magnitude > 0.001 and delta.Unit or Vector3.new(1, 0, 0)
    while os.clock() - t0 < moveTime and not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local linearAlpha = math.clamp((os.clock() - t0) / moveTime, 0, 1)
        local a = easeOut and math.sin(linearAlpha * (math.pi / 2)) or linearAlpha
        local cur = start:Lerp(target, a)
        hrp.CFrame = CFrame.lookAt(cur, cur + dir)
        local curSpeed = easeOut and math.max(speed * (1 - linearAlpha * 0.8), 35) or speed
        hrp.AssemblyLinearVelocity = dir * curSpeed
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hrp.CFrame = CFrame.new(target)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end
local function TravelFlyDirect(targetPos, speed, isApproach)
    local hrp = findHRP()
    if not hrp or not targetPos then return false end
    local startPos = hrp.Position
    local totalDist = (targetPos - startPos).Magnitude
    if totalDist < 25 then
        FlyToPoint(targetPos + Vector3.new(0, 1.2, 0), speed, isApproach == true)
        return true
    end
    local flyAltitude = math.max(startPos.Y, targetPos.Y) + 30
    local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
    local pSky2 = Vector3.new(targetPos.X, flyAltitude, targetPos.Z)
    local pGround = targetPos + Vector3.new(0, 1.2, 0)
    FlyToPoint(pSky1, speed, false)
    FlyToPoint(pSky2, speed, false)
    FlyToPoint(pGround, speed, isApproach == true)
    return true
end
local function TravelSafeWalk(targetPos)
    local hum = findHum()
    local hrp = findHRP()
    if not hum or not hrp or not targetPos then return false end
    hum:MoveTo(targetPos)
    local t0 = os.clock()
    while (hrp.Position - targetPos).Magnitude > 4.5 and os.clock() - t0 < 8 and not HUB.dead do
        task.wait(0.05)
    end
    return true
end
local function TravelToDestination(targetPos, speed, isApproach)
    if stealMovementMethod == "Fly Glide" then
        return TravelFlyDirect(targetPos, speed, isApproach)
    elseif stealMovementMethod == "Safe Walk" then
        return TravelSafeWalk(targetPos)
    elseif stealMovementMethod == "Instant Safe TP" then
        return SafeTeleport(targetPos + Vector3.new(0, 1.2, 0))
    else
        return MoveToPoint(targetPos + Vector3.new(0, 1.2, 0), speed, isApproach == true)
    end
end
local function isRarityAllowed(rarityName, filter)
    if not filter or type(filter) ~= "table" then return true end
    local count = 0
    for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    if filter[rarityName] == true then return true end
    local rLower = string.lower(tostring(rarityName))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == rLower then
            return true
        elseif type(k) == "string" and string.lower(k) == rLower and v == true then
            return true
        end
    end
    return false
end
local function isAreaAllowed(areaName, filter)
    if not filter or type(filter) ~= "table" then return true end
    local count = 0
    for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    if filter[areaName] == true then return true end
    local aLower = string.lower(tostring(areaName))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == aLower then
            return true
        elseif type(k) == "string" and string.lower(k) == aLower and v == true then
            return true
        end
    end
    return false
end
local function isBigEgg(eggModel)
    local size = tonumber(eggModel:GetAttribute("SizeMultiplier")) or 1
    local scale = tonumber(eggModel:GetAttribute("BaseScale")) or 1
    return size >= 1.35 or scale >= 1.2
end
local function isPlayerCarryingEgg()
    if (tonumber(LP:GetAttribute("CarriedEggCount")) or 0) > 0 then
        return true
    end
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and (t:GetAttribute("IsEggTool") == true or t:GetAttribute("EggId") ~= nil) then
                return true
            end
        end
    end
    return false
end
local function hasAnyEggToPlace()
    if isPlayerCarryingEgg() then return true end
    if LP:FindFirstChild("Backpack") then
        for _, t in ipairs(LP.Backpack:GetChildren()) do
            if t:IsA("Tool") and (t:GetAttribute("IsEggTool") == true or t:GetAttribute("EggId") ~= nil) then
                return true
            end
        end
    end
    return false
end
local function GetEggEstimatedCPS(egg)
    if not egg then return 1 end
    local aName = egg:GetAttribute("AnimalName") or egg.Name
    local ok, AnimalsMod = pcall(function() return require(ReplicatedStorage.Settings.Animals) end)
    local animalsList = ok and (AnimalsMod.List or AnimalsMod) or {}
    local animalData = animalsList[aName]
    local baseCPS = (animalData and tonumber(animalData.CashPerSecond)) or 1
    local sizeMult = tonumber(egg:GetAttribute("SizeMultiplier")) or 1
    local mut = egg:GetAttribute("Mutation") or ""
    local mutMult = (mut == "Gold") and 4 or 1
    return math.floor(baseCPS * sizeMult * mutMult)
end
local function GetAllSpawnedEggs(areaFilter, rarityFilter)
    local stagesFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Stages")
    if not stagesFolder then return {} end
    local myJP = GetPlayerJumpPower()
    local candidates = {}
    local activeRarityFilter = nil
    if type(farmRarities) == "table" and next(farmRarities) ~= nil then
        activeRarityFilter = farmRarities
    elseif type(rarityFilter) == "table" and next(rarityFilter) ~= nil then
        activeRarityFilter = rarityFilter
    end
    for _, stage in ipairs(stagesFolder:GetChildren()) do
        local eggsFolder = stage:FindFirstChild("SpawnedEggs")
        if eggsFolder and isAreaAllowed(stage.Name, areaFilter) then
            for _, egg in ipairs(eggsFolder:GetChildren()) do
                if egg:IsA("Model") then
                    local reqJP = GetEggRequiredJumpPower(egg, stage.Name)
                    local canSteal = (not autoScaleToJumpPower) or (myJP >= reqJP)
                    if canSteal then
                        local rarity = egg:GetAttribute("Rarity") or "Common"
                        if isRarityAllowed(rarity, activeRarityFilter) then
                            local mut = egg:GetAttribute("EventMutation") or egg:GetAttribute("Mutation") or ""
                            local passesMutation = (not farmMutatedOnly) or (mut ~= "")
                            local estCPS = GetEggEstimatedCPS(egg)
                            local passesCPS = (farmMinCPS <= 0) or (estCPS >= farmMinCPS)
                            if passesMutation and passesCPS then
                                if not stealBigEggsOnly or isBigEgg(egg) then
                                    local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt and prompt.Enabled then
                                        local score = RARITY_SCORE_MAP[rarity] or 100
                                        if isBigEgg(egg) then score = score + 500 end
                                        if mut ~= "" then score = score + 300 end
                                        score = score + (reqJP * 2)
                                        local isDivinePlus = (rarity == "Divine" or rarity == "Celestial" or rarity == "Eternal" or rarity == "Ascended")
                                        if isDivinePlus then
                                            score = score + 50000
                                        end
                                        table.insert(candidates, {
                                            model = egg,
                                            prompt = prompt,
                                            name = egg.Name,
                                            rarity = rarity,
                                            mutation = mut,
                                            cps = estCPS,
                                            isDivinePlus = isDivinePlus,
                                            score = score,
                                            stage = stage.Name,
                                            reqJP = reqJP,
                                            pos = egg:GetPivot().Position
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if #candidates > 1 and rareEggHunter then
        table.sort(candidates, function(a, b) return a.score > b.score end)
    end
    return candidates
end
local function EnsureSavedReturnPosition()
    if not savedReturnCFrame then
        local hrp = findHRP()
        if hrp then savedReturnCFrame = hrp.CFrame end
    end
end
local function PlaceAllCarriedEggs()
    local req = GetRemote("PlaceEggRequest")
    if not req then return 0 end
    local plot = GetMyPlot()
    local detector = plot and plot:FindFirstChild("Detector")
    if not detector then return 0 end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return 0 end
    local function getNextEggTool()
        if LP.Character then
            for _, t in ipairs(LP.Character:GetChildren()) do
                if t:IsA("Tool") and (t:GetAttribute("IsEggTool") == true or t:GetAttribute("EggId") ~= nil) then
                    return t
                end
            end
        end
        if LP:FindFirstChild("Backpack") then
            for _, t in ipairs(LP.Backpack:GetChildren()) do
                if t:IsA("Tool") and (t:GetAttribute("IsEggTool") == true or t:GetAttribute("EggId") ~= nil) then
                    return t
                end
            end
        end
        return nil
    end
    local firstTool = getNextEggTool()
    if not firstTool then return 0 end
    local placedEggs = plot:FindFirstChild("PlacedEggs")
    local currentPlacedCount = placedEggs and #placedEggs:GetChildren() or 0
    local maxCanPlace = math.max(0, 8 - currentPlacedCount)
    if maxCanPlace <= 0 then return 0 end
    hrp.CFrame = detector.CFrame + Vector3.new(0, 1.5, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.12)
    local placed = 0
    local tool = getNextEggTool()
    while tool and placed < maxCanPlace and not HUB.dead do
        local id = tool:GetAttribute("EggId")
        if id then
            hum:EquipTool(tool)
            task.wait(0.18)
            local placePos = detector.Position + Vector3.new(math.random(-5, 5), 0.5, math.random(-5, 5))
            pcall(function() req:FireServer(id, placePos) end)
            placed = placed + 1
            task.wait(0.18)
        else
            break
        end
        tool = getNextEggTool()
    end
    return placed
end
local function SendDiscordWebhook(url, eggData)
    if not url or url == "" or not string.find(url, "discord") then return false end
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if not req then return false end
    local content = ""
    if webhookUserPing and webhookUserPing ~= "" then
        local pingClean = string.gsub(webhookUserPing, "[<@!>]", "")
        if #pingClean > 0 then
            content = "<@" .. pingClean .. ">"
        end
    end
    local color = 0x5865F2
    local r = tostring(eggData.rarity or "Common")
    if r == "Common" then color = 0x95A5A6
    elseif r == "Uncommon" then color = 0x2ECC71
    elseif r == "Rare" then color = 0x3498DB
    elseif r == "Epic" then color = 0x9B59B6
    elseif r == "Legendary" then color = 0xF1C40F
    elseif r == "Mythic" then color = 0xE67E22
    elseif r == "Divine" then color = 0xE74C3C
    elseif r == "Celestial" then color = 0x1ABC9C
    elseif r == "Eternal" then color = 0x00FFFF
    elseif r == "Ascended" then color = 0xFF00FF
    end
    local totalBanked = LP:GetAttribute("TotalEggs") or 0
    local jpVal = LP:FindFirstChild("JumpPower") and LP.JumpPower.Value or 0
    local fields = {
        { name = "Egg / Animal", value = tostring(eggData.name or "Unknown"), inline = true },
        { name = "Rarity", value = tostring(eggData.rarity or "Common"), inline = true },
        { name = "Mutation", value = (eggData.mutation and eggData.mutation ~= "") and tostring(eggData.mutation) or "None", inline = true },
        { name = "Estimated $/s", value = "$" .. tostring(eggData.cps or 0) .. "/s", inline = true },
        { name = "Total Banked", value = tostring(totalBanked), inline = true },
        { name = "Jump Power", value = tostring(jpVal), inline = true }
    }
    local payload = {
        content = (content ~= "") and content or nil,
        embeds = {
            {
                title = "Egg Banked in Pen!",
                description = string.format("Successfully banked **%s** (%s) into your pen.", tostring(eggData.name), tostring(eggData.rarity)),
                color = color,
                fields = fields,
                footer = { text = "NevaHub • Springen für Tiere!" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }
    local ok, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if ok and body then
        pcall(function()
            req({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
    end
    return true
end
local function StealEggTarget(targetEgg)
    if not targetEgg or not targetEgg.model or not targetEgg.model.Parent then return false end
    local hrp = findHRP()
    if not hrp then return false end
    if LP:GetAttribute("IsSquatting") == true then
        StopSquatTraining()
        task.wait(0.08)
    end
    EnsureSavedReturnPosition()
    local eggPos = targetEgg.pos
    local penPos = GetPlotPenPosition()
    local speed = glideSpeed or 200
    local isInstantTP = (stealMovementMethod == "Instant Safe TP")
    if isInstantTP then
        local offsetPos = eggPos + Vector3.new(1.2, 0.4, 0.8)
        SafeTeleport(offsetPos)
        hrp.CFrame = CFrame.new(offsetPos, eggPos)
        task.wait(0.04)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:MoveTo(eggPos)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        hrp.AssemblyLinearVelocity = (eggPos - offsetPos).Unit * 14
        task.wait(0.12)
        hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.0, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.06)
    else
        TravelToDestination(eggPos, speed, true)
        hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.2, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.12)
    end
    local prompt = targetEgg.prompt or targetEgg.model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt.HoldDuration = 0
        pcall(fireproximityprompt, prompt)
    end
    local t0 = os.clock()
    local lastPromptFire = os.clock()
    local carried = false
    while os.clock() - t0 < 0.9 and not HUB.dead do
        hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.0, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if isPlayerCarryingEgg() then
            carried = true
            break
        end
        if prompt and (os.clock() - lastPromptFire >= 0.15) then
            lastPromptFire = os.clock()
            prompt.HoldDuration = 0
            pcall(fireproximityprompt, prompt)
        end
        task.wait(0.03)
    end
    if carried or isPlayerCarryingEgg() then
        if isInstantTP then
            local tWait = os.clock()
            while os.clock() - tWait < 0.6 and not HUB.dead do
                hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 1.0, 0))
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.04)
            end
        end
        TravelToDestination(penPos, speed, true)
        if isInstantTP then
            hrp.CFrame = CFrame.new(penPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.2)
        else
            task.wait(0.12)
        end
        local placedCount = PlaceAllCarriedEggs()
        task.wait(0.1)
        if webhookEnabled and webhookURL ~= "" and placedCount > 0 then
            local shouldNotify = true
            if #webhookRarities > 0 and not isRarityAllowed(targetEgg.rarity, webhookRarities) then
                shouldNotify = false
            end
            if shouldNotify and webhookMutatedOnly and (targetEgg.mutation or "") == "" then
                shouldNotify = false
            end
            if shouldNotify and webhookMinCPS > 0 and (targetEgg.cps or 0) < webhookMinCPS then
                shouldNotify = false
            end
            if shouldNotify then
                task.spawn(function()
                    SendDiscordWebhook(webhookURL, {
                        name = targetEgg.name,
                        rarity = targetEgg.rarity,
                        mutation = targetEgg.mutation,
                        cps = targetEgg.cps
                    })
                end)
            end
        end
    end
    if autoTrain and not (autoFarmEggs or autoStealEnabled) then
        local squatPos = GetSquatDetectorPosition()
        if squatPos then
            SafeTeleport(squatPos)
            task.wait(0.1)
            StartSquatTraining()
        end
    elseif savedReturnCFrame then
        task.wait(0.05)
        SafeTeleport(savedReturnCFrame.Position)
        local h = findHRP()
        if h then h.CFrame = savedReturnCFrame end
    end
    local c = LP.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hu = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
    end
    if hu then
        hu.PlatformStand = false
        pcall(function() hu:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    return carried or isPlayerCarryingEgg()
end
local function StealBestEggOnce()
    local candidates = GetAllSpawnedEggs(selectedStealAreas, selectedStealRarities)
    if #candidates == 0 then return false end
    return StealEggTarget(candidates[1])
end
local function StartSquatTraining()
    local req = GetRemote("SquatTrainingRequest")
    local det = GetSquatDetector()
    if req and det then
        pcall(function() req:FireServer(det) end)
    end
end
local function StopSquatTraining()
    local req = GetRemote("StopSquattingRequest")
    if req then pcall(function() req:FireServer() end) end
end
local function ClaimSquatBonus()
    local req = GetRemote("SquatBonusRequest")
    if req and LP:GetAttribute("SquatBonusAvailable") == true then
        local v = math.floor(tonumber(LP:GetAttribute("SquatBonusVersion")) or 0)
        pcall(function() req:FireServer(v) end)
    end
end
local function UpgradeBarbells()
    local plot = GetMyPlot()
    local prompt = plot and plot:FindFirstChild("BarbellUpgradePrompt", true)
    if prompt and prompt.Enabled then
        prompt.HoldDuration = 0
        pcall(fireproximityprompt, prompt)
    end
end
local function GetPlayerCash()
    local ls = LP:FindFirstChild("leaderstats")
    local c = ls and ls:FindFirstChild("Cash")
    local v = c and c:FindFirstChild("V")
    if v and v:IsA("NumberValue") then return v.Value end
    return 0
end
local function AutoBuyBestCoilAction()
    local myCash = GetPlayerCash()
    local ok, SpeedUpgradesMod = pcall(function() return require(ReplicatedStorage.Settings.SpeedUpgrades) end)
    if not ok or not SpeedUpgradesMod then return false end
    local ordered = SpeedUpgradesMod.GetOrdered and SpeedUpgradesMod.GetOrdered() or {}
    local coilData = LP:FindFirstChild("CoilData")
    local ownedFolder = coilData and coilData:FindFirstChild("Owned")
    for i = #ordered, 1, -1 do
        local item = ordered[i]
        local isOwned = ownedFolder and ownedFolder:FindFirstChild(item.Name) and ownedFolder[item.Name].Value == true
        if not isOwned and myCash >= (item.Cost or 0) then
            local rem = GetRemote("Coils")
            if rem then
                pcall(function() rem:FireServer("Select", item.Name) end)
                task.wait(0.2)
                return true
            end
        end
    end
    for i = #ordered, 1, -1 do
        local item = ordered[i]
        local isOwned = ownedFolder and ownedFolder:FindFirstChild(item.Name) and ownedFolder[item.Name].Value == true
        if isOwned then
            if coilData and coilData:FindFirstChild("Equipped") and coilData.Equipped.Value ~= item.Name then
                local rem = GetRemote("Coils")
                if rem then pcall(function() rem:FireServer("Select", item.Name) end) end
            end
            break
        end
    end
    return false
end
local function AutoBuyBestTrailAction()
    local myCash = GetPlayerCash()
    local ok, TrailsMod = pcall(function() return require(ReplicatedStorage.Settings.Trails) end)
    if not ok or not TrailsMod then return false end
    local ordered = TrailsMod.GetOrdered and TrailsMod.GetOrdered() or {}
    local trailData = LP:FindFirstChild("TrailData")
    local ownedFolder = trailData and trailData:FindFirstChild("Owned")
    for i = #ordered, 1, -1 do
        local item = ordered[i]
        local isOwned = ownedFolder and ownedFolder:FindFirstChild(item.Name) and ownedFolder[item.Name].Value == true
        if not isOwned and myCash >= (item.Cost or 0) then
            local rem = GetRemote("Trails")
            if rem then
                pcall(function() rem:FireServer("Select", item.Name) end)
                task.wait(0.2)
                return true
            end
        end
    end
    for i = #ordered, 1, -1 do
        local item = ordered[i]
        local isOwned = ownedFolder and ownedFolder:FindFirstChild(item.Name) and ownedFolder[item.Name].Value == true
        if isOwned then
            if trailData and trailData:FindFirstChild("Equipped") and trailData.Equipped.Value ~= item.Name then
                local rem = GetRemote("Trails")
                if rem then pcall(function() rem:FireServer("Select", item.Name) end) end
            end
            break
        end
    end
    return false
end
local function AutoUpgradePlotAction()
    local rem = GetRemote("PetInventory")
    if rem then
        pcall(function() rem:FireServer("BuyEquipSlot") end)
    end
end
local function AutoClaimIndexAction()
    local rem = GetRemote("ClaimAnimalIndexReward")
    if rem then
        pcall(function() rem:FireServer("__ALL__") end)
    end
end
local function AutoHatchEggsAction()
    local plot = GetMyPlot()
    local placedEggs = plot and plot:FindFirstChild("PlacedEggs")
    if not placedEggs then return false end
    local count = 0
    for _, egg in ipairs(placedEggs:GetChildren()) do
        if egg:GetAttribute("HatchReady") == true then
            local prompt = egg:FindFirstChild("HatchPrompt", true) or egg:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local act = string.lower(prompt.ActionText or "")
                local obj = string.lower(prompt.ObjectText or "")
                if not string.find(act, "skip") and not string.find(act, "robux") and not string.find(obj, "skip") then
                    prompt.HoldDuration = 0
                    pcall(fireproximityprompt, prompt)
                    count = count + 1
                end
            end
        end
    end
    return count > 0
end
local function AutoEquipBestAction()
    local rem = GetRemote("PetInventory")
    if rem then
        pcall(function() rem:FireServer("EquipBest") end)
    end
end
local function SellMatchingPetsAction()
    local plot = GetMyPlot()
    local placedAnimals = plot and plot:FindFirstChild("PlacedAnimals")
    if not placedAnimals then return false end
    local ok, AnimalsMod = pcall(function() return require(ReplicatedStorage.Settings.Animals) end)
    local animalsList = ok and (AnimalsMod.List or AnimalsMod) or {}
    for _, a in ipairs(placedAnimals:GetChildren()) do
        local aName = a:GetAttribute("AnimalName") or a.Name
        local animalData = animalsList[aName] or {}
        local rarity = a:GetAttribute("Rarity") or animalData.Rarity or "Common"
        local mut = a:GetAttribute("Mutation") or a:GetAttribute("EventMutation") or ""
        local cps = tonumber(a:GetAttribute("CashPerSecond")) or 0
        local eggId = a:GetAttribute("EggId") or a:GetAttribute("Id")
        local shouldSell = true
        if sellIgnoreMutations and mut ~= "" then
            shouldSell = false
        end
        if shouldSell and #sellRarities > 0 and not isRarityAllowed(rarity, sellRarities) then
            shouldSell = false
        end
        if shouldSell and sellBelowCPS > 0 and cps >= sellBelowCPS then
            shouldSell = false
        end
        if shouldSell and eggId then
            local rem = GetRemote("PetInventory")
            if rem then
                pcall(function() rem:FireServer("SetEquipped", eggId, true) end)
                task.wait(0.2)
            end
            local tool = LP.Backpack:FindFirstChild(aName) or (LP.Character and LP.Character:FindFirstChild(aName))
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            local hrp = findHRP()
            local sellPart = workspace.Map:FindFirstChild("Sell") and workspace.Map.Sell:FindFirstChild("Detector")
            if tool and hum and hrp and sellPart then
                hum:EquipTool(tool)
                task.wait(0.15)
                local oldPos = hrp.CFrame
                hrp.CFrame = sellPart.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.15)
                local prompt = workspace.Map.Sell:FindFirstChild("SellAnimalPrompt", true)
                if prompt then
                    prompt.HoldDuration = 0
                    pcall(fireproximityprompt, prompt)
                else
                    local sRem = GetRemote("Sell")
                    if sRem then pcall(function() sRem:FireServer() end) end
                end
                task.wait(0.3)
                hrp.CFrame = oldPos
                return true
            end
        end
    end
    return false
end
local isStealingNow = false
local lastEquipBestTime = 0
task.spawn(function()
    while not HUB.dead do
        local loopWait = 0.05
        local shouldFarm = (autoFarmEggs == true or autoStealEnabled == true)
        if shouldFarm and not isStealingNow then
            local candidates = GetAllSpawnedEggs(nil, farmRarities)
            local target = candidates[1]
            if target then
                isStealingNow = true
                pcall(StealEggTarget, target)
                isStealingNow = false
                loopWait = 0.08
            else
                loopWait = 0.5
            end
        end
        task.wait(math.max(tonumber(loopWait) or 0, 0.02))
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoPlaceEggs and not isStealingNow then
            if hasAnyEggToPlace() then
                pcall(PlaceAllCarriedEggs)
            end
        end
        task.wait(1.5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoHatchEggs then
            pcall(AutoHatchEggsAction)
        end
        task.wait(0.8)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoEquipBest and os.clock() - lastEquipBestTime >= equipBestInterval then
            lastEquipBestTime = os.clock()
            pcall(AutoEquipBestAction)
        end
        task.wait(1.0)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoSellPets and not isStealingNow and not isPlayerCarryingEgg() then
            pcall(SellMatchingPetsAction)
        end
        task.wait(2.5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        local shouldFarm = (autoFarmEggs == true or autoStealEnabled == true)
        if autoTrain and not shouldFarm and not isPlayerCarryingEgg() then
            local det = GetSquatDetector()
            local hrp = findHRP()
            if det and hrp and (hrp.Position - det.Position).Magnitude > 6 then
                MoveToPoint(det.Position + Vector3.new(0, 1.5, 0), glideSpeed or 200, true)
                task.wait(0.1)
            end
            if LP:GetAttribute("IsSquatting") ~= true then
                pcall(StartSquatTraining)
            end
        end
        if (auto2xBonus or autoClickSquatBonus or shouldFarm) and LP:GetAttribute("SquatBonusAvailable") == true then
            pcall(ClaimSquatBonus)
        end
        task.wait(0.35)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoUpgradeBarbell then pcall(UpgradeBarbells) end
        if autoBuyBestCoil then pcall(AutoBuyBestCoilAction) end
        if autoBuyBestTrail then pcall(AutoBuyBestTrailAction) end
        if autoUpgradePlot then pcall(AutoUpgradePlotAction) end
        if autoClaimIndex then pcall(AutoClaimIndexAction) end
        task.wait(1.5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if slapAuraEnabled then
            pcall(SlapNearestPlayer)
        end
        task.wait(slapAuraDelay)
    end
end)
local esp = {
    enabled         = false,
    eggs            = true,
    players         = false,
    rareOnly        = false,
    showBadges      = true,
    maxDistance     = 1200,
    eggColor        = Color3.fromRGB(255, 205, 50),
    rareEggColor    = Color3.fromRGB(255, 60, 220),
    playerColor     = Color3.fromRGB(90, 225, 110),
}
local hasDrawing = type(Drawing) == "table" and type(Drawing.new) == "function"
local trackedEspObjects = {}
local espBillboards = {}
local espContainer = nil
local function getEspContainer()
    if espContainer and espContainer.Parent then return espContainer end
    local p = (gethui and gethui()) or game:GetService("CoreGui") or LP:FindFirstChild("PlayerGui")
    pcall(function()
        for _, c in ipairs(p:GetChildren()) do
            if c:IsA("Folder") and c.Name == "JFP_Esp_Holder" then c:Destroy() end
        end
    end)
    espContainer = Instance.new("Folder")
    espContainer.Name = "JFP_Esp_Holder"
    pcall(function() espContainer.Parent = p end)
    return espContainer
end
local function updateEggBillboard(key, pos, icon)
    local bb = espBillboards[key]
    if not bb or not bb.gui or not bb.gui.Parent then
        local holder = getEspContainer()
        local part = Instance.new("Part")
        part.Name = "EspAnchor"
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CFrame = CFrame.new(pos)
        part.Parent = holder
        local gui = Instance.new("BillboardGui")
        gui.Name = "EggIconBillboard"
        gui.Adornee = part
        gui.Size = UDim2.fromOffset(26, 26)
        gui.StudsOffset = Vector3.new(-2.2, 1.2, 0)
        gui.AlwaysOnTop = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = part
        local img = Instance.new("ImageLabel")
        img.Name = "PetImage"
        img.Size = UDim2.fromScale(1, 1)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = icon or ""
        img.Parent = gui
        bb = { part = part, gui = gui, img = img }
        espBillboards[key] = bb
    else
        bb.part.CFrame = CFrame.new(pos)
        bb.img.Image = icon or ""
        bb.gui.Enabled = (icon ~= nil and icon ~= "")
    end
    return bb
end
local function createDrawingObject()
    if not hasDrawing then return {} end
    local o = {}
    o.name = trackDrawing(Drawing.new("Text"))
    o.name.Size = 13; o.name.Center = true; o.name.Outline = true; o.name.Visible = false
    o.dist = trackDrawing(Drawing.new("Text"))
    o.dist.Size = 11; o.dist.Center = true; o.dist.Outline = true; o.dist.Visible = false
    return o
end
track(RunService.RenderStepped:Connect(function()
    if HUB.dead or not esp.enabled then
        for _, obj in pairs(trackedEspObjects) do
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
        for _, bb in pairs(espBillboards) do
            if bb.gui then bb.gui.Enabled = false end
        end
        return
    end
    local hrp = findHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local cam = GetCamera()
    local renderItems = {}
    local activeBbKeys = {}
    if esp.eggs then
        local stages = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Stages")
        if stages then
            for _, stage in ipairs(stages:GetChildren()) do
                local eggsF = stage:FindFirstChild("SpawnedEggs")
                if eggsF then
                    for _, egg in ipairs(eggsF:GetChildren()) do
                        if egg:IsA("Model") then
                            local pos = egg:GetPivot().Position
                            local dist = (pos - myPos).Magnitude
                            if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                                local rarity = egg:GetAttribute("Rarity") or "Common"
                                local reqJP = GetEggRequiredJumpPower(egg, stage.Name)
                                local myJP = GetPlayerJumpPower()
                                local lockNotice = (reqJP > 0 and myJP < reqJP) and (" [Need " .. reqJP .. " JP]") or ""
                                local isRare = rarity ~= "Common" and rarity ~= "Uncommon"
                                if not esp.rareOnly or isRare then
                                    local label = egg.Name .. " (" .. rarity .. ")" .. lockNotice
                                    local itemColor = (reqJP > 0 and myJP < reqJP) and Color3.fromRGB(150, 150, 150) or (isRare and esp.rareEggColor or esp.eggColor)
                                    table.insert(renderItems, {
                                        Key = egg,
                                        Pos = pos,
                                        Name = label,
                                        Color = itemColor,
                                        Dist = dist
                                    })
                                    if esp.showBadges then
                                        activeBbKeys[egg] = true
                                        updateEggBillboard(egg, pos, "rbxassetid://10709791437")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if esp.players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if oHrp then
                    local dist = (oHrp.Position - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        table.insert(renderItems, {
                            Key = p,
                            Pos = oHrp.Position,
                            Name = p.DisplayName .. " (@" .. p.Name .. ")",
                            Color = esp.playerColor,
                            Dist = dist
                        })
                    end
                end
            end
        end
    end
    for k, bb in pairs(espBillboards) do
        if not activeBbKeys[k] and bb.gui then
            bb.gui.Enabled = false
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
        local screenPos, onScreen = nil, false
        if cam then
            screenPos, onScreen = cam:WorldToViewportPoint(item.Pos)
        end
        if onScreen and hasDrawing and screenPos then
            if obj.name then
                obj.name.Text = item.Name
                obj.name.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
                obj.name.Color = item.Color
                obj.name.Visible = true
            end
            if obj.dist then
                obj.dist.Text = math.floor(item.Dist) .. " studs"
                obj.dist.Position = Vector2.new(screenPos.X, screenPos.Y + 2)
                obj.dist.Color = Color3.fromRGB(220, 220, 220)
                obj.dist.Visible = true
            end
        else
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
    for k, obj in pairs(trackedEspObjects) do
        if not activeKeys[k] then
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
end))
local walkSpeedEnabled = false
local walkSpeedVal     = 24
local jumpPowerEnabled = false
local jumpPowerVal     = 60
local infiniteJump     = false
local flying           = false
local flySpeed         = 60
local antiAFK          = false
local function ApplyWalkSpeed(v)
    walkSpeedVal = v
    local hum = findHum()
    if hum and walkSpeedEnabled then hum.WalkSpeed = v end
end
local function ApplyJumpPower(v)
    jumpPowerVal = v
    local hum = findHum()
    if hum and jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end
track(RunService.Stepped:Connect(function()
    if HUB.dead then return end
    local hum = findHum()
    if hum then
        if walkSpeedEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerVal end
    end
end))
track(UserInputService.JumpRequest:Connect(function()
    if HUB.dead then return end
    local hum = findHum()
    if hum and infiniteJump then
        hum.Jump = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))
local function startFly()
    if flying then return end
    local hrp = findHRP()
    local hum = findHum()
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
            local cam = GetCamera()
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
        antiAfkConn = track(LP.Idled:Connect(function()
            if antiAFK then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end))
    elseif not v and antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
end
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
local MainTab    = Window:AddTab({ Title = "Main", Icon = "solar/crown-bold" })
local WebhookTab = Window:AddTab({ Title = "Webhook", Icon = "solar/planet-bold" })
local MiscTab    = Window:AddTab({ Title = "Misc", Icon = "solar/settings-bold" })
local FarmSub        = MainTab:AddSection("Farm", "solar/home-bold")
local ProgressionSub = MainTab:AddSection("Progression", "solar/home-bold")
local StatusSub      = MainTab:AddSection("Status", "solar/home-bold")
FarmSub:AddToggle({
    Title = "Auto Farm Eggs", Default = false, Flag = "auto_farm_eggs",
    Callback = safeCallback(function(v)
        autoFarmEggs = v
        autoStealEnabled = v
        if v then
            EnsureSavedReturnPosition()
            hasStolenInitialEgg = false
            lastTrainedLevel = nil
        end
        Notify("Auto Farm Eggs", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end)
})
FarmSub:AddToggle({
    Title = "Auto Place Eggs", Default = false, Flag = "auto_place_eggs",
    Callback = function(v)
        autoPlaceEggs = v
        Notify("Auto Place Eggs", v and "Enabled (auto-equipping & placing)" or "Disabled", v and "Success" or "Error")
    end
})
FarmSub:AddToggle({
    Title = "Auto Hatch Eggs", Default = false, Flag = "auto_hatch_eggs",
    Callback = function(v)
        autoHatchEggs = v
        Notify("Auto Hatch", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end
})
FarmSub:AddToggle({
    Title = "Auto Equip Best", Default = false, Flag = "auto_equip_best",
    Callback = function(v)
        autoEquipBest = v
        if v then AutoEquipBestAction() end
    end
})
FarmSub:AddSlider({
    Title = "Equip Best Interval", Min = 5, Max = 60, Default = 15, Suffix = "s", Flag = "equip_best_interval",
    Callback = function(v) equipBestInterval = tonumber(v) or 15 end
})
FarmSub:AddDivider()
FarmSub:AddSection({ Name = "Egg Filter" })
FarmSub:AddMultiDropdown({
    Title = "Filter by Rarity", Options = RARITY_NAMES, Default = {}, Flag = "farm_rarities",
    Callback = function(selectedList) farmRarities = selectedList end
})
FarmSub:AddToggle({
    Title = "Mutated Eggs Only", Default = false, Flag = "farm_mutated_only",
    Callback = function(v) farmMutatedOnly = v end
})
FarmSub:AddSlider({
    Title = "Minimum $/s", Min = 0, Max = 1000, Default = 0, Suffix = " $/s", Flag = "farm_min_cps",
    Callback = function(v) farmMinCPS = tonumber(v) or 0 end
})
FarmSub:AddDivider()
FarmSub:AddSection({ Name = "Pet Selling" })
FarmSub:AddToggle({
    Title = "Auto Sell Pets", Default = false, Flag = "auto_sell_pets",
    Callback = function(v)
        autoSellPets = v
        Notify("Auto Sell", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end
})
FarmSub:AddMultiDropdown({
    Title = "Sell Filter (Rarity)", Options = RARITY_NAMES, Default = {}, Flag = "sell_rarities",
    Callback = function(selectedList) sellRarities = selectedList end
})
FarmSub:AddToggle({
    Title = "Ignore Mutated Pets (Don't Sell)", Default = true, Flag = "sell_ignore_mutations",
    Callback = function(v) sellIgnoreMutations = v end
})
FarmSub:AddSlider({
    Title = "Sell Below $/s", Min = 0, Max = 500, Default = 10, Suffix = " $/s", Flag = "sell_below_cps",
    Callback = function(v) sellBelowCPS = tonumber(v) or 10 end
})
FarmSub:AddDivider()
FarmSub:AddSection({ Name = "Training" })
FarmSub:AddToggle({
    Title = "Auto Train", Default = false, Flag = "auto_train",
    Callback = function(v)
        autoTrain = v
        if v then StartSquatTraining() else StopSquatTraining() end
        Notify("Auto Train", v and "Started squat training" or "Stopped", v and "Success" or "Error")
    end
})
FarmSub:AddToggle({
    Title = "Auto 2x Bonus", Default = false, Flag = "auto_2x_bonus",
    Callback = function(v)
        auto2xBonus = v
    end
})
ProgressionSub:AddToggle({
    Title = "Auto Upgrade Barbell", Default = false, Flag = "auto_upgrade_barbell",
    Callback = function(v) autoUpgradeBarbell = v end
})
ProgressionSub:AddToggle({
    Title = "Auto Buy Best Coil", Default = false, Flag = "auto_buy_best_coil",
    Callback = function(v)
        autoBuyBestCoil = v
        if v then AutoBuyBestCoilAction() end
    end
})
ProgressionSub:AddToggle({
    Title = "Auto Buy Best Trail", Default = false, Flag = "auto_buy_best_trail",
    Callback = function(v)
        autoBuyBestTrail = v
        if v then AutoBuyBestTrailAction() end
    end
})
ProgressionSub:AddToggle({
    Title = "Auto Upgrade Plot", Default = false, Flag = "auto_upgrade_plot",
    Callback = function(v)
        autoUpgradePlot = v
        if v then AutoUpgradePlotAction() end
    end
})
ProgressionSub:AddToggle({
    Title = "Auto Claim Index", Default = false, Flag = "auto_claim_index",
    Callback = function(v)
        autoClaimIndex = v
        if v then AutoClaimIndexAction() end
    end
})
StatusSub:AddSection({ Name = "Live Farming & Training" })
local lblEgg      = StatusSub:AddLabel({ Text = "Live Egg: Banked 0 | Carried 0 | In Pen 0" })
local lblTrain    = StatusSub:AddLabel({ Text = "Train: Idle | 2x Bonus: None" })
local lblLevel    = StatusSub:AddLabel({ Text = "Level: 0 | XP: 0 | Jump Power: 0" })
local lblBarbell  = StatusSub:AddLabel({ Text = "Barbell: Level 1" })
StatusSub:AddDivider()
StatusSub:AddSection({ Name = "Live Progression" })
local lblCoilTrail = StatusSub:AddLabel({ Text = "Coil: None | Trail: None" })
local lblPen       = StatusSub:AddLabel({ Text = "Pen: Level 0 (0 Active Pets)" })
local lblIndex     = StatusSub:AddLabel({ Text = "Animal Index: 0 Discovered" })
local WebhookSub = WebhookTab:AddSection("Discord Webhook", "solar/home-bold")
WebhookSub:AddSection({ Name = "Webhook Setup" })
WebhookSub:AddInput({
    Title = "Discord Webhook URL", Default = "", Placeholder = "https://discord.com/api/webhooks/...", Flag = "webhook_url",
    Callback = function(v) webhookURL = tostring(v or "") end
})
WebhookSub:AddToggle({
    Title = "Discord Webhook (posts every egg you bank)", Default = false, Flag = "webhook_enabled",
    Callback = function(v)
        webhookEnabled = v
        Notify("Discord Webhook", v and "Enabled egg logger" or "Disabled", v and "Success" or "Error")
    end
})
WebhookSub:AddInput({
    Title = "User Ping", Default = "", Placeholder = "Discord User ID (e.g. 1234567890)", Flag = "webhook_user_ping",
    Callback = function(v) webhookUserPing = tostring(v or "") end
})
WebhookSub:AddButton({
    Title = "Send Test Post", Primary = true,
    Callback = safeCallback(function()
        if not webhookURL or webhookURL == "" or not string.find(webhookURL, "discord") then
            Notify("Webhook", "Please enter a valid Discord Webhook URL first", "Error")
            return
        end
        local ok = SendDiscordWebhook(webhookURL, {
            name = "Golden Dragon",
            rarity = "Divine",
            mutation = "Gold",
            cps = 99999
        })
        Notify("Webhook", ok and "Test embed sent successfully" or "Failed to send embed", ok and "Success" or "Error")
    end)
})
WebhookSub:AddDivider()
WebhookSub:AddSection({ Name = "Notify Filter" })
WebhookSub:AddMultiDropdown({
    Title = "Filter by Rarity", Options = RARITY_NAMES, Default = {}, Flag = "webhook_rarities",
    Callback = function(selectedList) webhookRarities = selectedList end
})
WebhookSub:AddToggle({
    Title = "Mutated Eggs Only", Default = false, Flag = "webhook_mutated_only",
    Callback = function(v) webhookMutatedOnly = v end
})
WebhookSub:AddSlider({
    Title = "Minimum $/s", Min = 0, Max = 1000, Default = 0, Suffix = " $/s", Flag = "webhook_min_cps",
    Callback = function(v) webhookMinCPS = tonumber(v) or 0 end
})
local MiscGeneralSub = MiscTab:AddSection("General", "solar/home-bold")
MiscGeneralSub:AddSection({ Name = "Anti AFK" })
MiscGeneralSub:AddToggle({
    Title = "Anti AFK", Default = true, Flag = "anti_afk",
    Callback = function(v)
        SetAntiAFK(v)
        Notify("Anti AFK", v and "Enabled (20-min kick blocked)" or "Disabled", v and "Success" or "Error")
    end
})
MiscGeneralSub:AddDivider()
MiscGeneralSub:AddSection({ Name = "Controls" })
MiscGeneralSub:AddKeybind({
    Title = "Toggle UI Keybind", Default = Enum.KeyCode.RightControl, Flag = "ui_toggle_key",
    OnPress = function()
        Window:Toggle()
    end
})
MiscGeneralSub:AddButton({
    Title = "Unload Oxide HUB",
    Callback = safeCallback(function()
        pcall(function() HUB.Unload() end)
    end)
})
task.spawn(function()
    while not HUB.dead do
        pcall(function()
            if lblEgg and lblEgg.Set then
                local banked = LP:GetAttribute("TotalEggs") or 0
                local carried = LP:GetAttribute("CarriedEggCount") or 0
                local plot = GetMyPlot()
                local inPen = plot and plot:FindFirstChild("PlacedEggs") and #plot.PlacedEggs:GetChildren() or 0
                lblEgg:Set(string.format("Live Egg: Banked %d | Carried %d | In Pen %d", banked, carried, inPen))
            end
            if lblTrain and lblTrain.Set then
                local squatting = LP:GetAttribute("IsSquatting") == true
                local bonus = LP:GetAttribute("SquatBonusAvailable") == true
                lblTrain:Set(string.format("Train: %s | 2x Bonus: %s", squatting and "Squatting (Active)" or "Idle", bonus and "READY" or "None"))
            end
            if lblLevel and lblLevel.Set then
                local ls = LP:FindFirstChild("leaderstats")
                local lvl = ls and ls:FindFirstChild("Level") and ls.Level.Value or "0"
                local xp = LP:FindFirstChild("JumpTrainingXP") and LP.JumpTrainingXP.Value or 0
                local jp = LP:FindFirstChild("JumpPower") and LP.JumpPower.Value or 0
                lblLevel:Set(string.format("Level: %s | XP: %d | JP: %d", tostring(lvl), xp, jp))
            end
            if lblBarbell and lblBarbell.Set then
                local bb = LP:FindFirstChild("BarbellLevel") and LP.BarbellLevel.Value or 1
                lblBarbell:Set(string.format("Barbell: Level %d", bb))
            end
            if lblCoilTrail and lblCoilTrail.Set then
                local cd = LP:FindFirstChild("CoilData")
                local coil = cd and cd:FindFirstChild("Equipped") and cd.Equipped.Value or "None"
                if coil == "" then coil = "None" end
                local td = LP:FindFirstChild("TrailData")
                local trail = td and td:FindFirstChild("Equipped") and td.Equipped.Value or "None"
                if trail == "" then trail = "None" end
                lblCoilTrail:Set(string.format("Coil: %s | Trail: %s", coil, trail))
            end
            if lblPen and lblPen.Set then
                local penLvl = LP:GetAttribute("PenUpgradeLevel") or 0
                local plot = GetMyPlot()
                local animals = plot and plot:FindFirstChild("PlacedAnimals") and #plot.PlacedAnimals:GetChildren() or 0
                lblPen:Set(string.format("Pen: Level %d (%d Active Pets)", penLvl, animals))
            end
            if lblIndex and lblIndex.Set then
                local idx = LP:FindFirstChild("AnimalIndex") and #LP.AnimalIndex:GetChildren() or 0
                lblIndex:Set(string.format("Animal Index: %d Discovered", idx))
            end
        end)
        task.wait(0.4)
    end
end)
HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    HUB.conns = {}
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    HUB.drawings = {}
    for _, h in ipairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    HUB.highlights = {}
    if espContainer and espContainer.Parent then
        pcall(function() espContainer:Destroy() end)
    end
    espBillboards = {}
    stopFly()
    SetFullbright(false)
    local hum = findHum()
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 31
    end
    pcall(function() Window:Destroy() end)
    _G.OxideJumpForPets = nil
end
Notify("NevaHub", "Jump for Pets script loaded successfully!", "Success", 3.5)
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
