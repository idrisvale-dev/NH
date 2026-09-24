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
    SubTitle = "Leaf Simulator",
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
    local prev = _G.OxideLeafSim
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, dead = false }
_G.OxideLeafSim = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local CONFIG_NAME = "leafspiel"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then
        table.insert(dropdownResync, function() applyFn(handle:Get()) end)
    end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp or not pos then return false end
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    return true
end
local LeafSim, LeafSimErr
local Remotes, UpgradeConfig, BagConfig
local GAME_OK = false
local function tryRequire(mod)
    local ok, m = pcall(require, mod)
    return ok, m
end
local function initGame()
    if GAME_OK then return end
    if not LeafSim then
        local ok, m = tryRequire(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("LeafSim"))
        if ok and m then LeafSim = m else LeafSimErr = tostring(m) end
    end
    if not Remotes then
        Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    end
    if not UpgradeConfig then
        UpgradeConfig = require(ReplicatedStorage:WaitForChild("UpgradeConfig"))
    end
    if not BagConfig then
        BagConfig = require(ReplicatedStorage:WaitForChild("BagConfig"))
    end
    GAME_OK = LeafSim ~= nil and Remotes ~= nil
end
local function Remote(name)
    return Remotes and Remotes:FindFirstChild(name) or nil
end
local function fire(name, ...)
    local r = Remote(name)
    if not r then return false end
    local args = { ... }
    local ok = pcall(function() r:FireServer(unpack(args)) end)
    return ok
end
local function invoke(name, ...)
    local r = Remote(name)
    if not r then return nil end
    local args = { ... }
    local ok, res = pcall(function() return r:InvokeServer(unpack(args)) end)
    return ok and res or nil
end
local function attr(name) return LocalPlayer:GetAttribute(name) end
local function setAttr(name, v) return pcall(function() LocalPlayer:SetAttribute(name, v) end) end
local function GetCash()     return tonumber(attr("Cash")) or 0 end
local function GetLeaves()   return tonumber(attr("Leaves")) or 0 end
local function GetCapacity() return tonumber(attr("LeafCapacity")) or 0 end
local function GetInfinite() return attr("InfiniteBag") == true end
local function GetBagSpace()
    if GetInfinite() then return 1e9 end
    local cap = GetCapacity()
    if cap <= 0 then cap = 25 end
    return math.max(0, cap - GetLeaves())
end
local function GetUpgLevel(toolKey, upgName)
    return tonumber(attr("Upg_" .. toolKey .. "_" .. upgName)) or 0
end
local function IsInRun()
    return ReplicatedStorage:GetAttribute("RunEndTime") ~= nil
end
local function CollectNearby(radius)
    if not LeafSim or not LeafSim.folder then return 0 end
    local hrp = GetHRP()
    if not hrp then return 0 end
    local space = GetBagSpace()
    if space <= 0 then return 0 end
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { LeafSim.folder }
    params.MaxParts = 800
    local parts = Workspace:GetPartBoundsInRadius(hrp.Position, radius, params)
    local pick = {}
    local n = 0
    for _, p in ipairs(parts) do
        if n >= space then break end
        n = n + 1
        pick[n] = p
    end
    if n == 0 then return 0 end
    local got = LeafSim.collectMany(pick)
    return got or 0
end
local function GetDumpsters()
    local list = {}
    local folder = Workspace:FindFirstChild("Dumpsters")
    if not folder then return list end
    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") or m:IsA("BasePart") then
            list[#list + 1] = m
        end
    end
    return list
end
local function NearestDumpsterPos()
    local hrp = GetHRP()
    local best, bestD
    for _, m in ipairs(GetDumpsters()) do
        local pos = m:GetPivot().Position
        local d = hrp and (pos - hrp.Position).Magnitude or 0
        if not bestD or d < bestD then best, bestD = pos, d end
    end
    return best
end
local function SellNow(doTeleport)
    local eb = Remote("EmptyBackpack")
    if not eb then return false, "no remote" end
    if doTeleport then
        local pos = NearestDumpsterPos()
        if pos then TeleportTo(pos) end
    end
    task.wait(0.3)
    local ok = pcall(function() eb:FireServer() end)
    return ok
end
local UPGRADE_ORDER = {
    { key = "Hand",       names = { "Hold", "Dexterity", "Grasp" } },
    { key = "Rake",       names = { "Radius", "Range", "Stickiness" } },
    { key = "LeafBlower", names = { "Width", "Power", "Spread" } },
}
local function BuildUpgradeOptions()
    local opts = {}
    for _, t in ipairs(UPGRADE_ORDER) do
        for _, n in ipairs(t.names) do
            opts[#opts + 1] = t.key .. " / " .. n
        end
    end
    return opts
end
local function ParseUpgradeOption(opt)
    for _, t in ipairs(UPGRADE_ORDER) do
        for _, n in ipairs(t.names) do
            if opt == (t.key .. " / " .. n) then return t.key, n end
        end
    end
    return nil, nil
end
local function UpgradePrice(toolKey, upgName)
    if not UpgradeConfig then return nil end
    local section = UpgradeConfig.tools and UpgradeConfig.tools[toolKey]
    local upg = section and section.upgrades and section.upgrades[upgName]
    if not upg then return nil end
    local lvl = GetUpgLevel(toolKey, upgName)
    if lvl >= (upg.max or 0) then return nil end
    return upg.prices[lvl + 1]
end
local function BuyUpgradeOnce(toolKey, upgName)
    local price = UpgradePrice(toolKey, upgName)
    if price == nil then return false, "maxed" end
    if GetCash() < price then return false, "poor" end
    return fire("BuyUpgrade", toolKey, upgName)
end
local function AutoUpgradeOnce(prioritySet)
    local bought = false
    for _, t in ipairs(UPGRADE_ORDER) do
        for _, n in ipairs(t.names) do
            if (not prioritySet or prioritySet[t.key .. " / " .. n]) then
                local price = UpgradePrice(t.key, n)
                if price ~= nil and GetCash() >= price then
                    local ok = fire("BuyUpgrade", t.key, n)
                    if ok then bought = true end
                end
            end
        end
    end
    return bought
end
local function BuyBagOnce()
    if not BagConfig then return false, "no config" end
    local prices = BagConfig.prices
    local lvl = 0
    local data = invoke("GetMyData")
    if data and data.Upgrades then
        lvl = tonumber(data.Upgrades.BagCapacity) or 0
    end
    if lvl >= #prices then return false, "maxed" end
    local price = prices[lvl + 1]
    if not price then return false, "maxed" end
    if GetCash() < price then return false, "poor" end
    return fire("BuyBagUpgrade")
end
local TOOL_BUY_ORDER = { "Rake", "LeafBlower", "Molotov" }
local function OwnsTool(key)
    if key == "Rake" then return attr("OwnsRake") == true end
    if key == "LeafBlower" then return attr("OwnsLeafBlower") == true end
    if key == "Molotov" then return attr("OwnsMolotov") == true end
    return false
end
local function BuyToolOnce(key)
    if OwnsTool(key) then return false, "owned" end
    local section = UpgradeConfig and UpgradeConfig.shop and UpgradeConfig.shop[key]
    if not section then return false, "no config" end
    if section.robuxOnly then return false, "robux" end
    local price = section.cash
    if not price or GetCash() < price then return false, "poor" end
    return fire("BuyToolCash", key)
end
local function AutoBuyToolsOnce()
    local bought = false
    for _, key in ipairs(TOOL_BUY_ORDER) do
        local ok = BuyToolOnce(key)
        if ok then bought = true end
    end
    return bought
end
local function AutoBuyVentsOnce()
    local vents = Workspace:FindFirstChild("Vents")
    if not vents then return false end
    local hrp = GetHRP()
    local bought = false
    for _, v in ipairs(vents:GetChildren()) do
        if v:IsA("BasePart") and v:GetAttribute("Cost") ~= nil and not v:GetAttribute("Unlocked") then
            local cost = v:GetAttribute("Cost") or 0
            if GetCash() >= cost and hrp and (v.Position - hrp.Position).Magnitude <= 20 then
                local ok = fire("BuyVent", v)
                if ok then bought = true end
            end
        end
    end
    return bought
end
local function EquipTool(name)
    if name and name ~= "Hand" then
        setAttr("SelectedTool", name)
    else
        setAttr("SelectedTool", "Hand")
    end
    return fire("EquipTool", name ~= "Hand" and name or nil)
end
local function EquipBestOnce()
    if attr("OwnsLeafVacuum") == true then return EquipTool("LeafVacuum") end
    if attr("OwnsLeafBlower") == true then return EquipTool("LeafBlower") end
    if attr("OwnsRake") == true then return EquipTool("Rake") end
    return EquipTool("Hand")
end
local leafCache, leafCacheSeed = nil, nil
local function GetLeafCache()
    local seed = ReplicatedStorage:GetAttribute("LeafSeed")
    if not seed then return nil end
    if seed == leafCacheSeed and leafCache then return leafCache end
    local ok, LG = pcall(require, ReplicatedStorage:WaitForChild("LeafGenShared"))
    if not ok or not LG then return nil end
    local cache = {}
    local okg = pcall(function()
        LG.generate(seed, function(id, cf, zone, tpl)
            cache[#cache + 1] = { id = id, pos = cf.Position }
        end)
    end)
    if not okg or #cache == 0 then return nil end
    leafCache, leafCacheSeed = cache, seed
    return cache
end
local function GetNearestVent()
    local vents = Workspace:FindFirstChild("Vents")
    if not vents then return nil end
    local hrp = GetHRP()
    local best, bestD
    for _, v in ipairs(vents:GetChildren()) do
        if v:IsA("BasePart") then
            local d = hrp and (v.Position - hrp.Position).Magnitude or 1e9
            if not bestD or d < bestD then best, bestD = v, d end
        end
    end
    return best
end
local function EnsureVentUnlocked()
    local vents = Workspace:FindFirstChild("Vents")
    if not vents then return false end
    local hrp = GetHRP()
    for _, v in ipairs(vents:GetChildren()) do
        if v:IsA("BasePart") and v:GetAttribute("Cost") ~= nil and not v:GetAttribute("Unlocked") then
            local cost = v:GetAttribute("Cost") or 0
            if GetCash() >= cost and hrp and (v.Position - hrp.Position).Magnitude <= 20 then
                fire("BuyVent", v)
                return true
            end
        end
    end
    return false
end
local function VentFarmOnce(radius, doTeleport, doBuyVent)
    local ven = GetNearestVent()
    if not ven then return 0, "no vent" end
    if doBuyVent then pcall(EnsureVentUnlocked) end
    if doTeleport then
        TeleportTo(ven.Position)
        task.wait(0.3)
    end
    local cache = GetLeafCache()
    if not cache then return 0, "no cache" end
    local LN = require(ReplicatedStorage:WaitForChild("LeafNet"))
    local ids = {}
    local vp = ven.Position
    for _, e in ipairs(cache) do
        if (e.pos - vp).Magnitude <= radius and #ids < 200 then
            ids[#ids + 1] = e.id
        end
    end
    if #ids == 0 then return 0, "empty" end
    local ok = fire("VentEat", LN.packIds(ids, #ids))
    return ok and #ids or 0
end
local walkSpeed = 16
local flying = false
local flySpeed = 60
local noclip = false
local noclipConn = nil
local infiniteJump = false
local antiAFK = false
local function ApplyWalkSpeed(v)
    walkSpeed = v
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = v end
end
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
    HUB._fly = { hrp = hrp, gyro = bodyGyro, conn = track(RunService.RenderStepped:Connect(function(dt)
        if not flying then return end
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
    end)) }
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
local function setNoclip(v)
    noclip = v
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if not v then
        local c = GetCharacter()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
        return
    end
    noclipConn = track(RunService.Stepped:Connect(function()
        local c = GetCharacter()
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end))
end
local function setInfiniteJump(v)
    infiniteJump = v
    local hum = GetHumanoid()
    if not hum then return end
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, not v) end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Landed, not v) end)
    hum.JumpPower = 50
end
local function GetZones()
    local list = {}
    local ll = Workspace:FindFirstChild("Leave_Locations")
    if not ll then return list end
    for _, m in ipairs(ll:GetChildren()) do
        if m:IsA("Model") then list[#list + 1] = m end
    end
    return list
end
local function ZonePosition(name)
    local ll = Workspace:FindFirstChild("Leave_Locations")
    local m = ll and ll:FindFirstChild(name)
    if not m then return nil end
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") then return d.Position end
    end
    return m:GetPivot().Position
end
local allToolsEnabled = true
local autoRakeEnabled = true
local keepAliveStarted = false
local oldLevelOf, oldUpgEffect
local PlayerUpgradeConfig, PlayerUpgradeConfigErr
local itemAttributes = {
    OwnsRake = true,
    OwnsLeafBlower = true,
    OwnsLeafVacuum = true,
    OwnsMolotov = true,
    PermRake = true,
    PermLeafBlower = true,
    PermLeafVacuum = true,
    PermMolotov = true,
}
local upgradeAttributes = {
    Upg_Hand_Hold = 1,
    Upg_Hand_Dexterity = 5,
    Upg_Hand_Grasp = 5,
    Upg_Rake_Radius = 5,
    Upg_Rake_Range = 4,
    Upg_Rake_Stickiness = 4,
    Upg_LeafBlower_Width = 5,
    Upg_LeafBlower_Power = 4,
    Upg_LeafBlower_Spread = 4,
    LobbyWalkSpeed = 21,
    LobbyBagBonus = 125,
    LobbyCashMult = 1.5,
    LobbyGemsMult = 1.5,
    LobbyRakeDiscount = 1,
    LobbyBlowerDiscount = 1,
}
local cooldownAttributes = {
    HandCooldown = false,
    RakeCooldown = false,
    MolotovCooldown = false,
}
local function EnsureUpgradeConfig()
    if PlayerUpgradeConfig then return true end
    local ok, m = tryRequire(ReplicatedStorage:WaitForChild("PlayerUpgradeConfig"))
    if ok and m then
        PlayerUpgradeConfig = m
        return true
    end
    PlayerUpgradeConfigErr = tostring(m)
    return false
end
local function ApplyAllTools()
    for attr, val in pairs(itemAttributes) do setAttr(attr, val) end
    for attr, val in pairs(upgradeAttributes) do setAttr(attr, val) end
    if EnsureUpgradeConfig() and PlayerUpgradeConfig then
        if not oldLevelOf then oldLevelOf = PlayerUpgradeConfig.levelOf end
        PlayerUpgradeConfig.levelOf = function() return 5 end
    end
    if LeafSim then
        if not oldUpgEffect then oldUpgEffect = LeafSim.upgEffect end
        LeafSim.upgEffect = function(tool, upgrade)
            if tool == "Hand" then
                if upgrade == "Dexterity" then return 0
                elseif upgrade == "Hold" then return 1
                elseif upgrade == "Grasp" then return 6 end
            elseif tool == "Rake" then
                if upgrade == "Range" then return 20
                elseif upgrade == "Radius" then return 6
                elseif upgrade == "Stickiness" then return 160 end
            elseif tool == "LeafBlower" then
                if upgrade == "Width" then return 6
                elseif upgrade == "Power" then return 2.5
                elseif upgrade == "Spread" then return 0.2 end
            end
            return oldUpgEffect and oldUpgEffect(tool, upgrade)
        end
    end
end
local namecallOld
local function SetupNamecallHook()
    if namecallOld then return end
    local hasHooks = pcall(function()
        return hookmetamethod ~= nil and getnamecallmethod ~= nil
    end)
    if not hasHooks then return end
    local wrap = newcclosure or function(f) return f end
    local ok, old = pcall(hookmetamethod, game, "__namecall", wrap(function(self, ...)
        local method = getnamecallmethod()
        if method == "GetAttribute" and self == LocalPlayer then
            local attrName = ...
            if itemAttributes[attrName] ~= nil then return true end
            if upgradeAttributes[attrName] ~= nil then return upgradeAttributes[attrName] end
            if cooldownAttributes[attrName] ~= nil then return false end
        end
        return namecallOld and namecallOld(self, ...)
    end))
    if ok and old then namecallOld = old end
end
local function StartKeepAlive()
    if keepAliveStarted then return end
    keepAliveStarted = true
    for attr, _ in pairs(cooldownAttributes) do
        track(LocalPlayer:GetAttributeChangedSignal(attr):Connect(function()
            if LocalPlayer:GetAttribute(attr) == true then setAttr(attr, false) end
        end))
    end
    for attr, val in pairs(itemAttributes) do
        track(LocalPlayer:GetAttributeChangedSignal(attr):Connect(function()
            if LocalPlayer:GetAttribute(attr) ~= val then setAttr(attr, val) end
        end))
    end
    for attr, val in pairs(upgradeAttributes) do
        track(LocalPlayer:GetAttributeChangedSignal(attr):Connect(function()
            if LocalPlayer:GetAttribute(attr) ~= val then setAttr(attr, val) end
        end))
    end
end
local rakeHolding = false
local rakeRayParams = RaycastParams.new()
rakeRayParams.FilterType = Enum.RaycastFilterType.Exclude
rakeRayParams.IgnoreWater = true
local function RakeAimPos()
    local cam = Camera
    local hrp = GetHRP()
    if not (cam and hrp) then return nil end
    rakeRayParams.FilterDescendantsInstances = { GetCharacter() }
    local result = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 50, rakeRayParams)
    return result and result.Position or hrp.Position + cam.CFrame.LookVector * 10
end
local function InstantRake()
    if not LeafSim then return end
    local aim = RakeAimPos()
    if not aim then return end
    pcall(function()
        local okS, SC = tryRequire(ReplicatedStorage:WaitForChild("SoundController"))
        if okS and SC and SC.play then SC.play("RakeSFX") end
    end)
    pcall(function() LeafSim.rake(aim) end)
end
local function StartAutoRake()
    track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            rakeHolding = true
            task.spawn(function()
                while rakeHolding and not HUB.dead and autoRakeEnabled do
                    if (LocalPlayer:GetAttribute("SelectedTool") or "Hand") == "Rake"
                        and not LocalPlayer:GetAttribute("JournalOpen")
                        and not LocalPlayer:GetAttribute("ToolShopFocus") then
                        pcall(InstantRake)
                        task.wait(0.08)
                    else
                        break
                    end
                end
            end)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            rakeHolding = false
        end
    end))
end
local FarmTab = Window:AddTab({ Title = "Farm", Icon = "solar/bag-bold" })
local EconomyTab = Window:AddTab({ Title = "Economy", Icon = "solar/dollar-minimalistic-bold" })
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "solar/routing-bold" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })
local CollectSub = FarmTab:AddSection("Collect", "solar/home-bold")
local collectEnabled = false
local collectRadius = 12
local collectGap = 0.15
local collectOnlyRun = false
CollectSub:AddToggle({
    Title = "Auto Collect", Default = false, Flag = "collect_auto",
    Callback = safeCallback(function(v)
        collectEnabled = v
        Notify("Auto Collect", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
CollectSub:AddSlider({ Title = "Collect Radius", Min = 4, Max = 60, Default = 12, Suffix = " studs", Flag = "collect_radius", Callback = function(v) collectRadius = v end })
CollectSub:AddSlider({ Title = "Collect Gap", Min = 0.05, Max = 2, Default = 0.15, Suffix = "s", Flag = "collect_gap", Callback = function(v) collectGap = v end })
CollectSub:AddToggle({ Title = "Only During Run", Default = false, Flag = "collect_runonly", Callback = function(v) collectOnlyRun = v end })
CollectSub:AddButton({
    Title = "Collect Once", Primary = true,
    Callback = safeCallback(function()
        local n = CollectNearby(collectRadius)
        Notify("Collect", n > 0 and ("Collected " .. n .. " leaves") or "Nothing in range", n > 0 and "Success" or "Info")
    end),
})
local SellSub = FarmTab:AddSection("Sell", "solar/home-bold")
local sellEnabled = false
local sellThreshold = 90
local sellGap = 2
local sellTeleport = true
SellSub:AddToggle({
    Title = "Auto Sell", Default = false, Flag = "sell_auto",
    Callback = safeCallback(function(v)
        sellEnabled = v
        Notify("Auto Sell", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
SellSub:AddSlider({ Title = "Sell When Bag Full", Min = 25, Max = 100, Default = 90, Suffix = " %", Flag = "sell_threshold", Callback = function(v) sellThreshold = v end })
SellSub:AddSlider({ Title = "Sell Gap", Min = 0.5, Max = 20, Default = 2, Suffix = "s", Flag = "sell_gap", Callback = function(v) sellGap = v end })
SellSub:AddToggle({ Title = "Teleport To Dumpster", Default = true, Flag = "sell_teleport", Callback = function(v) sellTeleport = v end })
SellSub:AddButton({
    Title = "Sell Now", Primary = true,
    Callback = safeCallback(function()
        local ok = SellNow(sellTeleport)
        Notify("Sell", ok and "Backpack emptied" or "Sell failed", ok and "Success" or "Error")
    end),
})
local VentSub = FarmTab:AddSection("Vent Farm", "solar/home-bold")
local ventFarmEnabled = false
local ventFarmRadius = 8
local ventFarmGap = 1.5
local ventFarmTeleport = true
local ventFarmBuy = true
VentSub:AddToggle({
    Title = "Auto Vent Farm", Default = false, Flag = "vent_auto",
    Callback = safeCallback(function(v)
        ventFarmEnabled = v
        Notify("Vent Farm", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
VentSub:AddSlider({ Title = "Vent Radius", Min = 4, Max = 20, Default = 8, Suffix = " studs", Flag = "vent_radius", Callback = function(v) ventFarmRadius = v end })
VentSub:AddSlider({ Title = "Vent Gap", Min = 0.5, Max = 10, Default = 1.5, Suffix = "s", Flag = "vent_gap", Callback = function(v) ventFarmGap = v end })
VentSub:AddToggle({ Title = "Teleport To Vent", Default = true, Flag = "vent_teleport", Callback = function(v) ventFarmTeleport = v end })
VentSub:AddToggle({ Title = "Auto Buy Vent", Default = true, Flag = "vent_buy", Callback = function(v) ventFarmBuy = v end })
VentSub:AddButton({
    Title = "Vent Farm Once", Primary = true,
    Callback = safeCallback(function()
        local n = VentFarmOnce(ventFarmRadius, ventFarmTeleport, ventFarmBuy)
        Notify("Vent Farm", n > 0 and ("Fed " .. n .. " leaves") or "No leaves near vent", n > 0 and "Success" or "Info")
    end),
})
local UpgradesSub = EconomyTab:AddSection("Upgrades", "solar/home-bold")
local upgradeEnabled = false
local upgradeGap = 1.5
local upgradePriority = {}
do
    local opts = BuildUpgradeOptions()
    local function setPriority(list)
        upgradePriority = {}
        for _, opt in ipairs(list or {}) do upgradePriority[opt] = true end
    end
    local dd = UpgradesSub:AddMultiDropdown({
        Title = "Upgrade Priority (empty = all)", Options = opts, Default = {},
        MaxVisible = 8, Searchable = true, Flag = "upg_priority",
        Callback = setPriority,
    })
    registerResync(dd, setPriority)
end
UpgradesSub:AddToggle({
    Title = "Auto Upgrade", Default = false, Flag = "upg_auto",
    Callback = safeCallback(function(v)
        upgradeEnabled = v
        Notify("Auto Upgrade", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
UpgradesSub:AddSlider({ Title = "Upgrade Gap", Min = 0.2, Max = 10, Default = 1.5, Suffix = "s", Flag = "upg_gap", Callback = function(v) upgradeGap = v end })
UpgradesSub:AddButton({
    Title = "Buy All Now", Primary = true,
    Callback = safeCallback(function()
        local bought = AutoUpgradeOnce(nil)
        Notify("Upgrades", bought and "Bought upgrades" or "Nothing affordable", bought and "Success" or "Info")
    end),
})
local ToolsSub = EconomyTab:AddSection("Tools & Bag", "solar/home-bold")
local autoBag = false
local autoTools = false
local autoVents = false
local autoEquip = false
ToolsSub:AddToggle({ Title = "Auto Buy Bag Upgrade", Default = false, Flag = "buy_bag", Callback = function(v) autoBag = v end })
ToolsSub:AddToggle({ Title = "Auto Buy Tools", Default = false, Flag = "buy_tools", Callback = function(v) autoTools = v end })
ToolsSub:AddToggle({ Title = "Auto Buy Vents", Default = false, Flag = "buy_vents", Callback = function(v) autoVents = v end })
ToolsSub:AddToggle({ Title = "Auto Equip Best Tool", Default = false, Flag = "auto_equip", Callback = function(v) autoEquip = v end })
ToolsSub:AddButton({ Title = "Buy Rake ($7.99)", Callback = safeCallback(function() local ok, why = BuyToolOnce("Rake"); Notify("Tool", ok and "Rake bought" or tostring(why), ok and "Success" or "Info") end) })
ToolsSub:AddButton({ Title = "Buy Leaf Blower ($29.99)", Callback = safeCallback(function() local ok, why = BuyToolOnce("LeafBlower"); Notify("Tool", ok and "Blower bought" or tostring(why), ok and "Success" or "Info") end) })
ToolsSub:AddButton({ Title = "Buy Molotov ($100)", Callback = safeCallback(function() local ok, why = BuyToolOnce("Molotov"); Notify("Tool", ok and "Molotov bought" or tostring(why), ok and "Success" or "Info") end) })
ToolsSub:AddButton({ Title = "Buy Bag Upgrade", Callback = safeCallback(function() local ok, why = BuyBagOnce(); Notify("Bag", ok and "Bag upgraded" or tostring(why), ok and "Success" or "Info") end) })
local MovementSub = PlayerTab:AddSection("Movement", "solar/home-bold")
MovementSub:AddSlider({ Title = "WalkSpeed", Min = 16, Max = 300, Default = 16, Suffix = "", Flag = "walkspeed", Callback = function(v) ApplyWalkSpeed(v) end })
MovementSub:AddToggle({
    Title = "Fly", Default = false, Flag = "fly",
    Callback = safeCallback(function(v)
        if v then startFly() else stopFly() end
        Notify("Fly", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end),
})
MovementSub:AddSlider({ Title = "Fly Speed", Min = 10, Max = 300, Default = 60, Suffix = "", Flag = "flyspeed", Callback = function(v) flySpeed = v end })
MovementSub:AddToggle({ Title = "Noclip", Default = false, Flag = "noclip", Callback = function(v) setNoclip(v) end })
MovementSub:AddToggle({ Title = "Infinite Jump", Default = false, Flag = "infjump", Callback = function(v) setInfiniteJump(v) end })
MovementSub:AddToggle({ Title = "Anti-AFK", Default = false, Flag = "antiafk", Callback = function(v) antiAFK = v end })
local TeleportSub = PlayerTab:AddSection("Teleport", "solar/home-bold")
do
    local zoneOpts = {}
    for _, m in ipairs(GetZones()) do zoneOpts[#zoneOpts + 1] = m.Name end
    table.sort(zoneOpts)
    local selectedZone = zoneOpts[1]
    local dd = TeleportSub:AddDropdown({
        Title = "Zone", Options = zoneOpts, Default = selectedZone,
        Flag = "tp_zone", Callback = function(v) selectedZone = v end,
    })
    TeleportSub:AddButton({
        Title = "Teleport To Zone",
        Callback = safeCallback(function()
            local pos = ZonePosition(selectedZone)
            if pos then TeleportTo(pos); Notify("Teleport", "At " .. selectedZone, "Success") end
        end),
    })
end
TeleportSub:AddButton({
    Title = "Teleport To Dumpster",
    Callback = safeCallback(function()
        local pos = NearestDumpsterPos()
        if pos then TeleportTo(pos); Notify("Teleport", "At dumpster", "Success") end
    end),
})
TeleportSub:AddButton({
    Title = "Teleport To Nearest Vent",
    Callback = safeCallback(function()
        local vents = Workspace:FindFirstChild("Vents")
        local hrp = GetHRP()
        local best, bestD
        if vents and hrp then
            for _, v in ipairs(vents:GetChildren()) do
                if v:IsA("BasePart") then
                    local d = (v.Position - hrp.Position).Magnitude
                    if not bestD or d < bestD then best, bestD = v.Position, d end
                end
            end
        end
        if best then TeleportTo(best); Notify("Teleport", "At vent", "Success") end
    end),
})
TeleportSub:AddButton({
    Title = "Teleport To Player",
    Callback = safeCallback(function()
        local target
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                target = p
                break
            end
        end
        if target then
            local pos = target.Character:FindFirstChild("HumanoidRootPart").Position
            TeleportTo(pos)
            Notify("Teleport", "At " .. target.Name, "Success")
        else
            Notify("Teleport", "No other players", "Info")
        end
    end),
})
local ExtrasTab = Window:AddTab({ Title = "Extras", Icon = "star" })
local ExtrasSub = ExtrasTab:AddSection("All Tools", "solar/home-bold")
ExtrasSub:AddToggle({
    Title = "All Tools & Max Upgrades", Default = true, Flag = "extras_alltools",
    Callback = safeCallback(function(v)
        allToolsEnabled = v
        if v then
            pcall(ApplyAllTools)
            SetupNamecallHook()
            StartKeepAlive()
            Notify("Extras", "All tools & upgrades applied", "Success")
        else
            Notify("Extras", "Disabled", "Info")
        end
    end),
})
ExtrasSub:AddToggle({
    Title = "Auto Rake (hold MB1)", Default = true, Flag = "extras_autorage",
    Callback = function(v)
        autoRakeEnabled = v
        if not v then rakeHolding = false end
    end,
})
local ConfigSub = SettingsTab:AddSection("Config", "solar/home-bold")
ConfigSub:AddButton({
    Title = "Save Config",
    Callback = safeCallback(function()
        if HAS_CONFIG then
            Library:SaveConfig(CONFIG_NAME)
            Notify("Config", "Saved", "Success")
        else
            Notify("Config", "Not supported", "Error")
        end
    end),
})
ConfigSub:AddButton({
    Title = "Load Config",
    Callback = safeCallback(function()
        if HAS_CONFIG then
            Library:LoadConfig(CONFIG_NAME)
            ResyncAll()
            Notify("Config", "Loaded", "Success")
        else
            Notify("Config", "Not supported", "Error")
        end
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
        if collectEnabled and (not collectOnlyRun or IsInRun()) then
            pcall(function() CollectNearby(collectRadius) end)
        end
        task.wait(collectGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if sellEnabled then
            local cap = GetCapacity()
            if cap <= 0 then cap = 25 end
            local leaves = GetLeaves()
            if (not GetInfinite()) and cap > 0 and (leaves / cap) * 100 >= sellThreshold then
                pcall(function() SellNow(sellTeleport) end)
            end
        end
        task.wait(sellGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if ventFarmEnabled then
            pcall(function() VentFarmOnce(ventFarmRadius, ventFarmTeleport, ventFarmBuy) end)
        end
        task.wait(ventFarmGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if upgradeEnabled then
            local prio = (next(upgradePriority) ~= nil) and upgradePriority or nil
            pcall(function() AutoUpgradeOnce(prio) end)
        end
        task.wait(upgradeGap)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoBag then pcall(function() BuyBagOnce() end) end
        if autoTools then pcall(AutoBuyToolsOnce) end
        if autoVents then pcall(AutoBuyVentsOnce) end
        task.wait(3)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoEquip then pcall(EquipBestOnce) end
        task.wait(5)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if antiAFK then
            local vus = game:GetService("VirtualUser")
            vus:CaptureController()
            vus:ClickButton2(Vector2.new())
        end
        task.wait(60)
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
    Notify("NevaHub", "Game API unavailable (" .. tostring(LeafSimErr or "?") .. ")", "Error", 4)
end
if allToolsEnabled then
    pcall(ApplyAllTools)
    SetupNamecallHook()
    StartKeepAlive()
end
StartAutoRake()
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(HUB.conns)
    if flying then stopFly() end
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    rakeHolding = false
    if PlayerUpgradeConfig and oldLevelOf then
        pcall(function() PlayerUpgradeConfig.levelOf = oldLevelOf end)
    end
    if LeafSim and oldUpgEffect then
        pcall(function() LeafSim.upgEffect = oldUpgEffect end)
    end
    if namecallOld then
        pcall(function() hookmetamethod(game, "__namecall", namecallOld) end)
        namecallOld = nil
    end
    if HAS_CONFIG then pcall(function() Library:SaveConfig(CONFIG_NAME) end) end
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
    end)
    _G.OxideLeafSim = nil
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
