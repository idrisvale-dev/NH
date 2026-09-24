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
    SubTitle = "MM2",
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
    local prev = _G.OxideMm2
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideMm2 = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local CONFIG_NAME = "mm2"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then table.insert(dropdownResync, function() applyFn(handle:Get()) end) end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local TeleportService    = game:GetService("TeleportService")
local VirtualUser        = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()
    local c = GetCharacter()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end
local function GetHRP()
    local c = GetCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetRootCFrame()
    local hrp = GetHRP()
    return hrp and hrp.CFrame
end
local function Notify(title, content, kind, dur)
    Fluent:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
end
local function GetCoins()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local c = ls and (ls:FindFirstChild("Coins") or ls:FindFirstChild("Coin"))
    if c and typeof(c.Value) == "number" then return c.Value end
    local df = LocalPlayer:FindFirstChild("DataFolder")
    local c2 = df and df:FindFirstChild("Coins")
    if c2 then return tonumber(c2.Value) or 0 end
    return 0
end
local function GetLevel()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local l = ls and ls:FindFirstChild("Level")
    if l then return tonumber(l.Value) or 0 end
    return 0
end
local function GetRole(plr)
    plr = plr or LocalPlayer
    local char = plr.Character
    if not char then return "Unknown" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return "Dead" end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("knife") then return "Murderer" end
            if n:find("gun") then return "Sheriff" end
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("knife") then return "Murderer?" end
            if t:IsA("Tool") and t.Name:lower():find("gun") then return "Sheriff?" end
        end
    end
    return "Innocent"
end
local function RoleColor(role)
    if role == "Murderer" then return Color3.fromRGB(220, 50, 50)
    elseif role == "Sheriff" then return Color3.fromRGB(50, 120, 255)
    elseif role:find("Sheriff") then return Color3.fromRGB(80, 140, 255)
    elseif role:find("Murderer") then return Color3.fromRGB(255, 80, 80)
    elseif role == "Dead" then return Color3.fromRGB(120, 120, 120)
    else return Color3.fromRGB(80, 220, 120) end
end
local function FormatMoney(v) return tostring(math.floor(tonumber(v) or 0)) end
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
local wsEnabled, wsValue   = false, 16
local jpEnabled, jpValue   = false, 50
local infJump              = false
local hipEnabled, hipValue = false, 2
local defaultGravity = Workspace.Gravity
MoveSub:AddDivider()
MoveSub:AddToggle({
    Title = "WalkSpeed", Default = false, Flag = "ws_enabled",
    Description = "Re-applied every frame (MM2 re-syncs stats)",
    Callback = function(v)
        wsEnabled = v
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v and wsValue or 16 end
    end,
})
MoveSub:AddSlider({
    Title = "WalkSpeed Value", Min = 16, Max = 500, Default = 16, Suffix = "", Flag = "ws_value",
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
        if hum then hum.UseJumpPower = true; hum.JumpPower = v and jpValue or 50 end
    end,
})
MoveSub:AddSlider({
    Title = "JumpPower Value", Min = 50, Max = 400, Default = 50, Suffix = "", Flag = "jp_value",
    Callback = function(v)
        jpValue = v
        if jpEnabled then local hum = GetHumanoid(); if hum then hum.UseJumpPower = true; hum.JumpPower = v end end
    end,
})
MoveSub:AddToggle({
    Title = "Infinite Jump", Default = false, Flag = "inf_jump",
    Callback = function(v) infJump = v end,
})
MoveSub:AddDivider()
MoveSub:AddToggle({
    Title = "Custom Hip Height", Default = false, Flag = "hip_enabled",
    Description = "How high the character floats",
    Callback = function(v)
        hipEnabled = v
        local hum = GetHumanoid()
        if hum then hum.HipHeight = v and hipValue or 2 end
    end,
})
MoveSub:AddSlider({
    Title = "Hip Height", Min = 0, Max = 20, Default = 2, Suffix = "", Flag = "hip_value",
    Callback = function(v) hipValue = v; if hipEnabled then local h = GetHumanoid(); if h then h.HipHeight = v end end end,
})
MoveSub:AddDivider()
local gravityEnabled, gravityValue = false, defaultGravity
MoveSub:AddToggle({
    Title = "Custom Gravity", Default = false, Flag = "grav_enabled",
    Description = "Override Workspace.Gravity",
    Callback = function(v)
        gravityEnabled = v
        Workspace.Gravity = v and gravityValue or defaultGravity
    end,
})
MoveSub:AddSlider({
    Title = "Gravity", Min = 0, Max = 400, Default = math.floor(defaultGravity), Suffix = "", Flag = "grav_value",
    Callback = function(v) gravityValue = v; if gravityEnabled then Workspace.Gravity = v end end,
})
track(LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 10)
    task.wait(0.3)
    if HUB.dead then return end
    if gravityEnabled then Workspace.Gravity = gravityValue end
end))
local movementConn = RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    local hum = GetHumanoid()
    if not hum then
        if gravityEnabled and Workspace.Gravity ~= gravityValue then Workspace.Gravity = gravityValue end
        return
    end
    if wsEnabled and hum.WalkSpeed ~= wsValue then hum.WalkSpeed = wsValue end
    if jpEnabled then
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= jpValue then hum.JumpPower = jpValue end
    end
    if hipEnabled and hum.HipHeight ~= hipValue then hum.HipHeight = hipValue end
    if gravityEnabled and Workspace.Gravity ~= gravityValue then Workspace.Gravity = gravityValue end
end)
table.insert(HUB.conns, movementConn)
track(UserInputService.JumpRequest:Connect(function()
    if HUB.dead then return end
    if infJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
local FlySub = PlayerTab:AddSection("Fly & Noclip", "solar/home-bold")
local flying, flySpeed = false, 50
local noclip = false
local noclipParts = {}
local flyConn, noclipConn
local function startFly()
    local hum = GetHumanoid()
    if not hum then return end
    hum.PlatformStand = true
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function()
        if HUB.dead or not flying then return end
        local h = GetHumanoid(); local root = GetHRP()
        if not h or not root then return end
        h.PlatformStand = true
        local dir = Vector3.zero
        local cf = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * flySpeed else dir = Vector3.zero end
        root.AssemblyLinearVelocity = dir
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local hum = GetHumanoid()
    if hum then hum.PlatformStand = false end
    local root = GetHRP()
    if root then root.AssemblyLinearVelocity = Vector3.zero end
end
FlySub:AddToggle({
    Title = "Fly", Default = false, Flag = "fly_enabled",
    Callback = function(v)
        flying = v
        if v then startFly() else stopFly() end
        Notify("Fly", v and "Enabled (W/A/S/D, Space, Shift)" or "Disabled", v and "Success" or "Error")
    end,
})
FlySub:AddSlider({
    Title = "Fly Speed", Min = 10, Max = 500, Default = 50, Suffix = "", Flag = "fly_speed",
    Callback = function(v) flySpeed = v end,
})
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if HUB.dead or not noclip then return end
        local char = GetCharacter()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                noclipParts[part] = true
                part.CanCollide = false
            end
        end
    end)
end
local function stopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    for part in pairs(noclipParts) do
        if part and part.Parent then pcall(function() part.CanCollide = true end) end
    end
    if table.clear then table.clear(noclipParts) else for k in pairs(noclipParts) do noclipParts[k]=nil end end
end
FlySub:AddToggle({
    Title = "Noclip", Default = false, Flag = "noclip_enabled",
    Callback = function(v)
        noclip = v
        if v then startNoclip() else stopNoclip() end
        Notify("Noclip", v and "Enabled" or "Disabled", v and "Success" or "Error")
    end,
})
local CharSub = PlayerTab:AddSection("Character", "solar/home-bold")
CharSub:AddButton({
    Title = "Respawn", Primary = true,
    Callback = function()
        local hum = GetHumanoid()
        if hum then hum.Health = 0 end
        Notify("Character", "Respawning...", "Info")
    end,
})
CharSub:AddButton({
    Title = "Reset Stats",
    Callback = function()
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.UseJumpPower = true; hum.HipHeight = 2 end
        Workspace.Gravity = defaultGravity
        Notify("Character", "Stats reset to default", "Success")
    end,
})
local antiRagdoll = false
local antiRagdollConn
local function startAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect() end
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        if HUB.dead or not antiRagdoll then return end
        local hum = GetHumanoid()
        if not hum then return end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end
local function stopAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
end
CharSub:AddToggle({
    Title = "Anti-Ragdoll", Default = false, Flag = "anti_ragdoll",
    Description = "Get up instantly when knocked to the ground",
    Callback = function(v)
        antiRagdoll = v
        if v then startAntiRagdoll() else stopAntiRagdoll() end
    end,
})
local antiAFK = true
CharSub:AddToggle({
    Title = "Anti-AFK", Default = true, Flag = "anti_afk",
    Callback = function(v) antiAFK = v end,
})
if not _G.OxideMm2AntiAFK then
    _G.OxideMm2AntiAFK = true
    LocalPlayer.Idled:Connect(function()
        if not antiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(0.15)
            VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end)
    end)
end
local TpTab = Window:AddTab({ Title = "Teleport", Icon = "solar/routing-bold" })
local PlayerTpSub = TpTab:AddSection("Players", "solar/home-bold")
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
    if not name then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name then return p end
    end
    return nil
end
local function applyPlayerSelect(v) selectedPlayer = v end
local playerDropdown = PlayerTpSub:AddDropdown({
    Title = "Player", Options = GetPlayerNames(), Default = nil,
    MaxVisible = 6, Searchable = true, Flag = "tp_player",
    Callback = applyPlayerSelect,
})
registerResync(playerDropdown, applyPlayerSelect)
PlayerTpSub:AddButton({
    Title = "Refresh Players",
    Callback = function()
        playerDropdown:SetOptions(GetPlayerNames())
        Notify("Teleport", "Player list refreshed", "Info")
    end,
})
PlayerTpSub:AddButton({
    Title = "Teleport To Player", Primary = true,
    Callback = function()
        local target = ResolvePlayer(selectedPlayer)
        local myHRP = GetHRP()
        local tHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
            Notify("Teleport", "Teleported to " .. target.Name, "Success")
        else
            Notify("Teleport", "Target unavailable", "Error")
        end
    end,
})
local WaypointSub = TpTab:AddSection("Waypoints", "solar/home-bold")
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
WaypointSub:AddInput({
    Title = "Waypoint Name", Placeholder = "Spot 1", Default = "Spot 1", Flag = "wp_name",
    Callback = function(text) pendingName = (text ~= "" and text) or "Spot 1" end,
})
local applyWpSelect = function(v) selectedWaypoint = v end
local waypointDropdown
WaypointSub:AddButton({
    Title = "Save Current Position", Primary = true,
    Callback = function()
        local cf = GetRootCFrame()
        if not cf then Notify("Waypoints", "No character", "Error"); return end
        waypoints[pendingName] = cf
        if waypointDropdown then waypointDropdown:SetOptions(WaypointNames()) end
        Notify("Waypoints", "Saved '" .. pendingName .. "'", "Success")
    end,
})
waypointDropdown = WaypointSub:AddDropdown({
    Title = "Saved Waypoints", Options = WaypointNames(), Default = nil,
    MaxVisible = 6, Searchable = true, Flag = "wp_selected",
    Callback = applyWpSelect,
})
registerResync(waypointDropdown, applyWpSelect)
WaypointSub:AddButton({
    Title = "Teleport To Waypoint", Primary = true,
    Callback = function()
        local cf = waypoints[selectedWaypoint]
        local hrp = GetHRP()
        if cf and hrp then
            hrp.CFrame = cf
            Notify("Waypoints", "Teleported to '" .. selectedWaypoint .. "'", "Success")
        else
            Notify("Waypoints", "Waypoint unavailable", "Error")
        end
    end,
})
WaypointSub:AddButton({
    Title = "Delete Waypoint",
    Callback = function()
        if selectedWaypoint and waypoints[selectedWaypoint] then
            local removed = selectedWaypoint
            waypoints[selectedWaypoint] = nil
            waypointDropdown:SetOptions(WaypointNames())
            Notify("Waypoints", "Deleted '" .. removed .. "'", "Info")
        else
            Notify("Waypoints", "Nothing to delete", "Error")
        end
    end,
})
local TpMiscSub = TpTab:AddSection("Misc", "solar/home-bold")
local clickTp = false
TpMiscSub:AddToggle({
    Title = "Click Teleport", Default = false, Flag = "tp_click",
    Description = "Hold the keybind and click to teleport there",
    Callback = function(v) clickTp = v end,
})
TpMiscSub:AddKeybind({
    Title = "Click TP Key", Default = Enum.KeyCode.T, Flag = "tp_click_key",
    OnPress = function()
        if not clickTp then return end
        local hrp = GetHRP()
        if not hrp then return end
        local mouseLoc = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { GetCharacter() }
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
        if result then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end,
})
TpMiscSub:AddButton({
    Title = "Teleport To Lobby",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(-109.56, 137.91, -11.67)
            Notify("Teleport", "Teleported to lobby", "Success")
        end
    end,
})
TpMiscSub:AddButton({
    Title = "Teleport To Bank",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = spots["Hotel"]
            Notify("Teleport", "Teleported to Hotel", "Success")
        end
    end,
})
TpMiscSub:AddDivider()
local spots = {
    ["Lobby"] = CFrame.new(-109.56, 137.91, -11.67),
    ["Hotel"] = CFrame.new(76, 131, 28),
    ["Mansion"] = CFrame.new(-97, 131, 56),
    ["Bank"] = CFrame.new(-7, 131, -11),
    ["Factory"] = CFrame.new(-33, 131, -102),
    ["Hospital"] = CFrame.new(44, 131, -82),
    ["House 2"] = CFrame.new(19, 131, -42),
    ["Workplace"] = CFrame.new(-42, 131, 56),
}
local spotNames = {}
for n in pairs(spots) do table.insert(spotNames, n) end
table.sort(spotNames)
local selectedSpot = spotNames[1]
local applySpot = function(v) selectedSpot = v end
local spotDropdown = TpMiscSub:AddDropdown({
    Title = "Location", Options = spotNames, Default = selectedSpot, MaxVisible = 6, Searchable = true, Flag = "tp_spot",
    Callback = applySpot,
})
registerResync(spotDropdown, applySpot)
TpMiscSub:AddButton({
    Title = "Teleport To Location", Primary = true,
    Callback = function()
        local cf = spots[selectedSpot]
        local hrp = GetHRP()
        if cf and hrp then hrp.CFrame = cf; Notify("Teleport", "To "..selectedSpot, "Success") else Notify("Teleport", "Unavailable", "Error") end
    end,
})
TpMiscSub:AddToggle({
    Title = "Tween Teleport", Default = false, Flag = "tp_tween",
    Description = "Smooth tween instead of instant CFrame",
    Callback = function(v) _G.OxideTweenTP = v end,
})
local function tweenTP(cf)
    local hrp = GetHRP()
    if not hrp then return end
    if _G.OxideTweenTP then
        local TweenService=game:GetService("TweenService")
        local dist=(hrp.Position - cf.Position).Magnitude
        local tw=TweenService:Create(hrp, TweenInfo.new(math.clamp(dist/80,0.4,1.5), Enum.EasingStyle.Quad), {CFrame = cf})
        tw:Play()
    else hrp.CFrame = cf end
end
local VisualsTab = Window:AddTab({ Title = "Visual", Icon = "solar/eye-bold" })
local hasDrawing = (typeof(Drawing) == "table") or (Drawing ~= nil and pcall(function() return Drawing.new end))
local esp = {
    enabled = true, players = true, money = false,
    box = false, boxStyle = "Corner", boxThickness = 1, boxFill = false,
    name = false, distance = false, health = false,
    chams = false, chamsFillT = 0.55, chamsOutlineT = 0,
    tracer = false, tracerOrigin = "Bottom",
    arrow = false, skeleton = false, halo = false, headCircle = false,
    roleESP = true, coinESP = false, gunESP = false,
    teamCheck = false, rainbow = false,
    maxDistance = 1000, textSize = 13, font = 2,
    color        = Color3.fromRGB(30, 90, 220),
    coinColor    = Color3.fromRGB(255, 220, 60),
}
local playerObjects = {}
local FONT_MAP = { UI = 0, System = 1, Plain = 2, Monospace = 3 }
local function getEspParent()
    local ok, parent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
    if ok and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function newDrawing(class, props)
    if not hasDrawing then return nil end
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do pcall(function() d[k] = v end) end
    return trackDrawing(d)
end
local function MakeBox(setup)
    local box = {}
    if hasDrawing then
        box.frame   = newDrawing("Square", { Thickness = 1, Filled = false, Visible = false })
        box.fill    = newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.new(0,0,0), Transparency = 0.35, Visible = false })
        box.outline = newDrawing("Square", { Thickness = 2, Filled = false, Color = Color3.new(0,0,0), Visible = false })
        for _, d in ipairs({ box.frame, box.fill, box.outline }) do
            if d then pcall(function() d.ZIndex = 1 end) end
        end
        box.corners = {}
        for i = 1, 8 do
            local l = newDrawing("Line", { Thickness = 1, Visible = false, Color = Color3.new(1,1,1) })
            if l then pcall(function() l.ZIndex = 2 end) end
            box.corners[i] = l
        end
        box.headCircle = newDrawing("Circle", { Thickness = 1, NumSides = 24, Radius = 18, Filled = false, Visible = false })
        box.skeleton = {}
        for i = 1, 7 do
            local l = newDrawing("Line", { Thickness = 1, Visible = false, Color = Color3.new(1,1,1) })
            if l then pcall(function() l.ZIndex = 2 end) end
            box.skeleton[i] = l
        end
    end
    box.highlight = Instance.new("Highlight")
    box.highlight.Name = "OxideMm2ESP"
    box.highlight.FillTransparency = 0.6
    box.highlight.OutlineTransparency = 0.5
    box.highlight.Enabled = false
    box.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() box.highlight.Parent = getEspParent() end)
    table.insert(HUB.highlights, box.highlight)
    box.halo = Instance.new("Highlight")
    box.halo.Name = "OxideMm2Halo"
    box.halo.FillTransparency = 1
    box.halo.OutlineTransparency = 0
    box.halo.OutlineColor = Color3.fromRGB(255,255,255)
    box.halo.Enabled = false
    box.halo.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() box.halo.Parent = getEspParent() end)
    table.insert(HUB.highlights, box.halo)
    box.name = newDrawing("Text", { Color = Color3.fromRGB(255,255,255), Size = 13, Outline = true, Centre = true, Visible = false })
    box.dist = newDrawing("Text", { Color = Color3.fromRGB(255,255,255), Size = 11, Outline = true, Centre = true, Visible = false })
    box.hpText = newDrawing("Text", { Color = Color3.fromRGB(255,255,255), Size = 11, Outline = true, Centre = false, Visible = false })
    if hasDrawing then
        box.tracer = newDrawing("Line", { Thickness = 1.2, Visible = false })
        box.boxFill = newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.fromRGB(30,90,220), Transparency = 0.7, Visible = false })
        box.hpOutline = newDrawing("Line", { Thickness = 3, Visible = false, Color = Color3.new(0,0,0) })
        box.hp = newDrawing("Line", { Thickness = 2, Visible = false })
        box.arrow = newDrawing("Triangle", { Thickness = 1, Filled = true, Visible = false })
        box.ring = {}
        for i=1,16 do
            local l = newDrawing("Line", { Thickness = 1.2, Visible = false })
            if l then pcall(function() l.ZIndex = 2 end) end
            box.ring[i] = l
        end
    end
    return box
end
local function AddPlayerESP(p)
    local obj = MakeBox()
    playerObjects[p] = obj
    return obj
end
local function RemovePlayerESP(p)
    local obj = playerObjects[p]
    if not obj then return end
    for _, d in ipairs({ obj.frame, obj.fill, obj.outline, obj.name, obj.dist, obj.tracer, obj.headCircle, obj.hpText, obj.boxFill, obj.hp, obj.hpOutline, obj.arrow }) do
        if d then pcall(function() d:Remove() end) end
    end
    if obj.corners then for _, l in ipairs(obj.corners) do if l then pcall(function() l:Remove() end) end end end
    if obj.skeleton then for _, l in ipairs(obj.skeleton) do if l then pcall(function() l:Remove() end) end end end
    if obj.ring then for _, l in ipairs(obj.ring) do if l then pcall(function() l:Remove() end) end end end
    if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
    if obj.halo then pcall(function() obj.halo:Destroy() end) end
    playerObjects[p] = nil
end
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then AddPlayerESP(p) end
end
track(Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then AddPlayerESP(p) end
end))
track(Players.PlayerRemoving:Connect(RemovePlayerESP))
local EspSub = VisualsTab:AddSection("ESP", "solar/home-bold")
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Master Enable", Default = true, Flag = "esp_enabled", Callback = function(v) esp.enabled = v end })
EspSub:AddToggle({ Title = "Players", Default = true, Flag = "esp_players", Callback = function(v) esp.players = v end })
EspSub:AddToggle({ Title = "Role ESP", Default = true, Flag = "esp_role", Description = "Colors Murderer/Sheriff/Innocent", Callback = function(v) esp.roleESP = v end })
EspSub:AddToggle({ Title = "Coin ESP", Default = false, Flag = "esp_coin", Description = "Highlight coins", Callback = function(v) esp.coinESP = v end })
EspSub:AddToggle({ Title = "Gun ESP", Default = false, Flag = "esp_gun", Description = "Highlight dropped gun/knife", Callback = function(v) esp.gunESP = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "2D Box", Default = false, Flag = "esp_box", Callback = function(v) esp.box = v end })
local applyBoxStyle = function(v) esp.boxStyle = v end
local boxStyleDropdown = EspSub:AddDropdown({
    Title = "Box Style", Values = { "Full", "Corner", "Radius" }, Default = "Corner",
    MaxVisible = 3, Flag = "esp_boxstyle", Callback = applyBoxStyle,
})
registerResync(boxStyleDropdown, applyBoxStyle)
EspSub:AddSlider({ Title = "Box Thickness", Min = 1, Max = 5, Default = 1, Suffix = "", Flag = "esp_boxthick", Callback = function(v) esp.boxThickness = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Chams (Highlight)", Default = false, Flag = "esp_chams", Callback = function(v) esp.chams = v end })
EspSub:AddSlider({ Title = "Chams Fill", Min = 0, Max = 100, Default = 45, Suffix = "%", Flag = "esp_chams_fill", Callback = function(v) esp.chamsFillT = 1 - v / 100 end })
EspSub:AddSlider({ Title = "Chams Outline", Min = 0, Max = 100, Default = 100, Suffix = "%", Flag = "esp_chams_out", Callback = function(v) esp.chamsOutlineT = 1 - v / 100 end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Name", Default = false, Flag = "esp_name", Callback = function(v) esp.name = v end })
EspSub:AddToggle({ Title = "Distance", Default = false, Flag = "esp_distance", Callback = function(v) esp.distance = v end })
EspSub:AddSlider({ Title = "Text Size", Min = 10, Max = 20, Default = 13, Suffix = "", Flag = "esp_textsize", Callback = function(v) esp.textSize = v end })
local applyFont = function(v) esp.font = FONT_MAP[v] or 2 end
local fontDropdown = EspSub:AddDropdown({
    Title = "Text Font", Values = { "UI", "System", "Plain", "Monospace" }, Default = "Plain",
    MaxVisible = 4, Flag = "esp_font", Callback = applyFont,
})
registerResync(fontDropdown, applyFont)
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Box Fill", Default = false, Flag = "esp_boxfill", Callback = function(v) esp.boxFill = v end })
EspSub:AddToggle({ Title = "Health Bar", Default = false, Flag = "esp_health", Callback = function(v) esp.health = v end })
EspSub:AddToggle({ Title = "Off-Screen Arrow", Default = false, Flag = "esp_arrow", Callback = function(v) esp.arrow = v end })
EspSub:AddToggle({ Title = "Halo", Default = false, Flag = "esp_halo", Callback = function(v) esp.halo = v end })
EspSub:AddToggle({ Title = "Head Circle", Default = false, Flag = "esp_headcircle", Callback = function(v) esp.headCircle = v end })
EspSub:AddToggle({ Title = "Skeleton", Default = false, Flag = "esp_skeleton", Callback = function(v) esp.skeleton = v end })
EspSub:AddToggle({ Title = "Tracers", Default = false, Flag = "esp_tracers", Callback = function(v) esp.tracer = v end })
local applyTracerOrigin = function(v) esp.tracerOrigin = v end
local tracerOriginDropdown = EspSub:AddDropdown({
    Title = "Tracer Origin", Values = { "Bottom", "Center", "Top", "Mouse" },
    Default = "Bottom", MaxVisible = 4, Flag = "esp_tracer_origin", Callback = applyTracerOrigin,
})
registerResync(tracerOriginDropdown, applyTracerOrigin)
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Team Check", Default = false, Flag = "esp_teamcheck", Callback = function(v) esp.teamCheck = v end })
EspSub:AddToggle({ Title = "Rainbow", Default = false, Flag = "esp_rainbow", Callback = function(v) esp.rainbow = v end })
EspSub:AddSlider({ Title = "Max Distance", Min = 0, Max = 5000, Default = 1000, Suffix = "m", Flag = "esp_maxdist", Description = "0 = unlimited", Callback = function(v) esp.maxDistance = v end })
EspSub:AddDivider()
EspSub:AddColorPicker({ Name = "Player Color", Default = esp.color, Flag = "esp_color", Callback = function(c) esp.color = c end })
EspSub:AddColorPicker({ Name = "Coin Color", Default = esp.coinColor, Flag = "esp_coincolor", Callback = function(c) esp.coinColor = c end })
local function getBox2D(char)
    if not char then return nil end
    local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
    if not ok or not cf or not size then return nil end
    if size.Magnitude < 1 then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        cf = hrp.CFrame
        size = Vector3.new(3, 6, 2)
    end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOn = false
    for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
        local corner = (cf * CFrame.new(size.X/2 * x, size.Y/2 * y, size.Z/2 * z)).Position
        local sp, on = Camera:WorldToViewportPoint(corner)
        if sp.Z > 0 then
            anyOn = anyOn or on
            minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
            maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
        end
    end end end
    if minX == math.huge or not anyOn then return nil end
    return minX, minY, maxX, maxY
end
local function WorldToScreen(cf)
    if not cf then return nil end
    local v, on = Camera:WorldToScreenPoint(cf.Position)
    if not on or v.Z <= 0 then return nil end
    return v
end
local drawcounter = 0
local espConn = RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    drawcounter = drawcounter + 1
    local hrp = GetHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local color = esp.color
    if esp.rainbow then color = Color3.fromHSV((tick() % 5) / 5, 0.8, 1) end
    local myTeam = LocalPlayer.Team
    for p, obj in pairs(playerObjects) do
        local visible = esp.enabled and esp.players
        if visible and esp.teamCheck and p.Team and myTeam and p.Team == myTeam then
            visible = false
        end
        local char = p.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
        local hum2 = char and char:FindFirstChildOfClass("Humanoid")
        if visible and head and hrp2 then
                local dist = (hrp2.Position - myPos).Magnitude
                local color = (esp.roleESP and RoleColor(GetRole(p))) or (esp.rainbow and Color3.fromHSV((tick() % 5) / 5, 0.8, 1)) or esp.color
            if esp.maxDistance > 0 and dist > esp.maxDistance then
                if obj.frame then obj.frame.Visible = false end
                if obj.outline then obj.outline.Visible = false end
                if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
                if obj.name then obj.name.Visible = false end
                if obj.dist then obj.dist.Visible = false end
                if obj.tracer then obj.tracer.Visible = false end
                if obj.headCircle then obj.headCircle.Visible = false end
                if obj.skeleton then for _, l in ipairs(obj.skeleton) do if l then l.Visible = false end end end
                if obj.boxFill then obj.boxFill.Visible = false end
                if obj.hp then obj.hp.Visible = false end
                if obj.hpOutline then obj.hpOutline.Visible = false end
                if obj.hpText then obj.hpText.Visible = false end
                if obj.arrow then obj.arrow.Visible = false end
                if obj.ring then for _, l in ipairs(obj.ring) do if l then l.Visible = false end end end
                if obj.highlight then obj.highlight.Enabled = false end
                if obj.halo then obj.halo.Enabled = false end
            else
                if obj.highlight and obj.highlight.Adornee ~= char then pcall(function() obj.highlight.Adornee = char end) end
                if obj.halo and obj.halo.Adornee ~= char then pcall(function() obj.halo.Adornee = char end) end
                local leftX, topY, rightX, bottomY = getBox2D(char)
                if leftX and topY and rightX and bottomY then
                    local w = rightX - leftX
                    local h = bottomY - topY
                    if h < 8 then
                        local pad = (8 - h)/2
                        topY = topY - pad; bottomY = bottomY + pad; h = 8
                    end
                    if w < 6 then
                        local pad = (6 - w)/2
                        leftX = leftX - pad; rightX = rightX + pad; w = 6
                    end
                    leftX = leftX - 1; topY = topY - 1; rightX = rightX + 1; bottomY = bottomY + 1
                    w = rightX - leftX; h = bottomY - topY
                    local cx = (leftX + rightX)/2
                    local cy = (topY + bottomY)/2
                    local cornerLen = math.clamp(w * 0.28, 4, 18)
                    local showBox = esp.box and hasDrawing
                    if showBox then
                        if esp.boxStyle == "Corner" then
                            if obj.frame then obj.frame.Visible = false end
                            if obj.outline then obj.outline.Visible = false end
                            if obj.corners then
                                local pts = {
                                    {Vector2.new(leftX, topY), Vector2.new(leftX + cornerLen, topY)},
                                    {Vector2.new(leftX, topY), Vector2.new(leftX, topY + cornerLen)},
                                    {Vector2.new(rightX, topY), Vector2.new(rightX - cornerLen, topY)},
                                    {Vector2.new(rightX, topY), Vector2.new(rightX, topY + cornerLen)},
                                    {Vector2.new(leftX, bottomY), Vector2.new(leftX + cornerLen, bottomY)},
                                    {Vector2.new(leftX, bottomY), Vector2.new(leftX, bottomY - cornerLen)},
                                    {Vector2.new(rightX, bottomY), Vector2.new(rightX - cornerLen, bottomY)},
                                    {Vector2.new(rightX, bottomY), Vector2.new(rightX, bottomY - cornerLen)},
                                }
                                for i, l in ipairs(obj.corners) do
                                    if l then
                                        local a,b = pts[i][1], pts[i][2]
                                        l.Visible = true
                                        l.Color = color
                                        l.Thickness = esp.boxThickness
                                        l.From = a
                                        l.To = b
                                    end
                                end
                            end
                        elseif esp.boxStyle == "Radius" then
                            if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
                            if obj.outline then
                                obj.outline.Visible = true
                                obj.outline.Size = Vector2.new(w + 2, h + 2)
                                obj.outline.Position = Vector2.new(leftX - 1, topY - 1)
                                obj.outline.Color = Color3.new(0, 0, 0)
                            end
                            if obj.frame then
                                obj.frame.Visible = true
                                obj.frame.Color = color
                                obj.frame.Thickness = esp.boxThickness
                                obj.frame.Size = Vector2.new(w, h)
                                obj.frame.Position = Vector2.new(leftX, topY)
                                pcall(function() obj.frame.Transparency = 0.15 end)
                            end
                        else
                            if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
                            if obj.outline then
                                obj.outline.Visible = true
                                obj.outline.Size = Vector2.new(w + 2, h + 2)
                                obj.outline.Position = Vector2.new(leftX - 1, topY - 1)
                                obj.outline.Color = Color3.new(0, 0, 0)
                            end
                            if obj.frame then
                                obj.frame.Visible = true
                                obj.frame.Color = color
                                obj.frame.Thickness = esp.boxThickness
                                obj.frame.Size = Vector2.new(w, h)
                                obj.frame.Position = Vector2.new(leftX, topY)
                                pcall(function() obj.frame.Transparency = 0 end)
                            end
                        end
                    else
                        if obj.outline then obj.outline.Visible = false end
                        if obj.frame then obj.frame.Visible = false end
                        if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
                    end
                    if esp.name and obj.name then
                        obj.name.Visible = true
                        obj.name.Text = p.DisplayName ~= p.Name and (p.DisplayName .. " (@" .. p.Name .. ")") or p.Name
                        obj.name.Color = color
                        obj.name.Size = esp.textSize
                        obj.name.Font = esp.font
                        obj.name.Position = Vector2.new(cx, topY - 14)
                    else
                        if obj.name then obj.name.Visible = false end
                    end
                    if esp.distance and obj.dist then
                        obj.dist.Visible = true
                        obj.dist.Text = string.format("%.0fm", dist / 3)
                        obj.dist.Size = math.max(9, esp.textSize - 2)
                        obj.dist.Font = esp.font
                        obj.dist.Color = Color3.fromRGB(220,220,220)
                        obj.dist.Position = Vector2.new(cx, bottomY + 4)
                    else
                        if obj.dist then obj.dist.Visible = false end
                    end
                    if esp.tracer and obj.tracer then
                        obj.tracer.Visible = true
                        obj.tracer.Color = color
                        obj.tracer.Thickness = 1
                        local from
                        local vs = Camera.ViewportSize
                        if esp.tracerOrigin == "Bottom" then
                            from = Vector2.new(vs.X/2, vs.Y - 4)
                        elseif esp.tracerOrigin == "Top" then
                            from = Vector2.new(vs.X/2, 4)
                        elseif esp.tracerOrigin == "Center" then
                            from = Vector2.new(vs.X/2, vs.Y/2)
                        elseif esp.tracerOrigin == "Mouse" then
                            local m = UserInputService:GetMouseLocation()
                            from = Vector2.new(m.X, m.Y)
                        else
                            from = Vector2.new(vs.X/2, vs.Y - 4)
                        end
                        obj.tracer.From = from
                        obj.tracer.To = Vector2.new(cx, bottomY)
                    else
                        if obj.tracer then obj.tracer.Visible = false end
                    end
                    if esp.headCircle and obj.headCircle and head then
                        local headPos = WorldToScreen(head.CFrame)
                        if headPos then
                            local scale = math.clamp( (400 / math.max(dist, 10)) * 12, 8, 28)
                            obj.headCircle.Visible = true
                            obj.headCircle.Color = color
                            obj.headCircle.Radius = scale
                            obj.headCircle.Position = Vector2.new(headPos.X, headPos.Y)
                            obj.headCircle.Thickness = 1.5
                        else
                            obj.headCircle.Visible = false
                        end
                    else
                        if obj.headCircle then obj.headCircle.Visible = false end
                    end
                    if esp.skeleton and obj.skeleton and char then
                        local parts = {
                            Head = char:FindFirstChild("Head"),
                            Torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp2,
                            LArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
                            RArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
                            LLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
                            RLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
                        }
                        local function wts(part)
                            if not part then return nil end
                            local cf = part:IsA("BasePart") and part.CFrame or nil
                            if not cf then return nil end
                            return WorldToScreen(cf)
                        end
                        local hPos = wts(parts.Head)
                        local tPos = wts(parts.Torso)
                        local laPos = wts(parts.LArm)
                        local raPos = wts(parts.RArm)
                        local llPos = wts(parts.LLeg)
                        local rlPos = wts(parts.RLeg)
                        local sk = obj.skeleton
                        local lines = {
                            {hPos, tPos},
                            {tPos, laPos},
                            {tPos, raPos},
                            {tPos, llPos},
                            {tPos, rlPos},
                        }
                        for i, pair in ipairs(lines) do
                            local l = sk[i]
                            if l then
                                local a,b = pair[1], pair[2]
                                if a and b then
                                    l.Visible = true
                                    l.Color = color
                                    l.From = Vector2.new(a.X, a.Y)
                                    l.To = Vector2.new(b.X, b.Y)
                                else
                                    l.Visible = false
                                end
                            end
                        end
                        for i = #lines+1, #sk do if sk[i] then sk[i].Visible = false end end
                    else
                        if obj.skeleton then for _, l in ipairs(obj.skeleton) do if l then l.Visible = false end end end
                    end
                    if esp.boxFill and hasDrawing and obj.boxFill then
                        obj.boxFill.Visible = true
                        obj.boxFill.Color = color
                        obj.boxFill.Size = Vector2.new(w, h)
                        obj.boxFill.Position = Vector2.new(leftX, topY)
                    else
                        if obj.boxFill then obj.boxFill.Visible = false end
                    end
                    local humHealth = hum2 and hum2.Health or 100
                    local humMax = hum2 and hum2.MaxHealth or 100
                    local healthFrac = math.clamp(humHealth / math.max(humMax,1), 0, 1)
                    if esp.health and hasDrawing and hum2 then
                        local barX = leftX - 5
                        if obj.hpOutline then
                            obj.hpOutline.Visible = true
                            obj.hpOutline.From = Vector2.new(barX, topY - 1)
                            obj.hpOutline.To = Vector2.new(barX, bottomY + 1)
                        end
                        if obj.hp then
                            local col = Color3.fromRGB(math.floor(255*(1-healthFrac)), math.floor(255*healthFrac), 0)
                            obj.hp.Visible = true
                            obj.hp.Color = col
                            obj.hp.From = Vector2.new(barX, bottomY)
                            obj.hp.To = Vector2.new(barX, bottomY - h * healthFrac)
                        end
                        if obj.hpText then
                            obj.hpText.Visible = true
                            obj.hpText.Text = tostring(math.floor(humHealth))
                            obj.hpText.Color = Color3.fromRGB(255,255,255)
                            obj.hpText.Size = 11
                            obj.hpText.Position = Vector2.new(barX - 16, (topY+bottomY)/2 - 6)
                        end
                    else
                        if obj.hpOutline then obj.hpOutline.Visible = false end
                        if obj.hp then obj.hp.Visible = false end
                        if obj.hpText then obj.hpText.Visible = false end
                    end
                    if esp.arrow and obj.arrow then
                        local hrpPos = hrp2.Position
                        local sp, onScreen = Camera:WorldToViewportPoint(hrpPos)
                        if not onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local dir = Vector2.new(sp.X, sp.Y) - center
                            if sp.Z < 0 then dir = -dir end
                            if dir.Magnitude > 0 then
                                dir = dir.Unit
                                local pos = center + dir * math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) * 0.38
                                local ang = math.atan2(dir.Y, dir.X)
                                local s = 14
                                obj.arrow.Visible = true
                                obj.arrow.Color = color
                                obj.arrow.PointA = pos + Vector2.new(math.cos(ang), math.sin(ang)) * s
                                obj.arrow.PointB = pos + Vector2.new(math.cos(ang+2.5), math.sin(ang+2.5)) * s
                                obj.arrow.PointC = pos + Vector2.new(math.cos(ang-2.5), math.sin(ang-2.5)) * s
                            else
                                obj.arrow.Visible = false
                            end
                        else
                            obj.arrow.Visible = false
                        end
                    else
                        if obj.arrow then obj.arrow.Visible = false end
                    end
                    if obj.highlight then
                        if esp.chams then
                            obj.highlight.FillColor = color
                            obj.highlight.OutlineColor = color
                            obj.highlight.FillTransparency = esp.chamsFillT
                            obj.highlight.OutlineTransparency = esp.chamsOutlineT
                            obj.highlight.Enabled = true
                        else
                            obj.highlight.Enabled = false
                        end
                    end
                    if obj.halo then
                        if esp.halo then
                            obj.halo.OutlineColor = color
                            obj.halo.OutlineTransparency = 0
                            obj.halo.Enabled = true
                        else
                            obj.halo.Enabled = false
                        end
                    end
                else
                    if obj.frame then obj.frame.Visible = false end
                    if obj.outline then obj.outline.Visible = false end
                    if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
                    if obj.name then obj.name.Visible = false end
                    if obj.dist then obj.dist.Visible = false end
                    if obj.tracer then obj.tracer.Visible = false end
                    if obj.headCircle then obj.headCircle.Visible = false end
                    if obj.skeleton then for _, l in ipairs(obj.skeleton) do if l then l.Visible = false end end end
                    if obj.highlight then obj.highlight.Enabled = false end
                    if obj.halo then obj.halo.Enabled = false end
                end
            end
        else
            if obj.frame then obj.frame.Visible = false end
            if obj.outline then obj.outline.Visible = false end
            if obj.corners then for _, l in ipairs(obj.corners) do if l then l.Visible = false end end end
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
            if obj.tracer then obj.tracer.Visible = false end
            if obj.headCircle then obj.headCircle.Visible = false end
            if obj.skeleton then for _, l in ipairs(obj.skeleton) do if l then l.Visible = false end end end
            if obj.boxFill then obj.boxFill.Visible = false end
            if obj.hp then obj.hp.Visible = false end
            if obj.hpOutline then obj.hpOutline.Visible = false end
            if obj.hpText then obj.hpText.Visible = false end
            if obj.arrow then obj.arrow.Visible = false end
            if obj.ring then for _, l in ipairs(obj.ring) do if l then l.Visible = false end end end
            if obj.highlight then obj.highlight.Enabled = false end
            if obj.halo then obj.halo.Enabled = false end
        end
    end
end)
table.insert(HUB.conns, espConn)
local WorldSub = VisualsTab:AddSection("World", "solar/home-bold")
local fullbright = false
local savedLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
}
pcall(function() savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient end)
pcall(function() savedLighting.ExposureCompensation = Lighting.ExposureCompensation end)
pcall(function() savedLighting.ShadowDensity = Lighting.ShadowDensity end)
WorldSub:AddToggle({
    Title = "Fullbright", Default = false, Flag = "fullbright",
    Callback = function(v)
        fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e9
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180) end)
            pcall(function() Lighting.ExposureCompensation = 0.2 end)
            pcall(function() Lighting.ShadowDensity = 0 end)
        else
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.FogEnd = savedLighting.FogEnd
            Lighting.GlobalShadows = savedLighting.GlobalShadows
            Lighting.Ambient = savedLighting.Ambient
            pcall(function() Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient end)
            pcall(function() Lighting.ExposureCompensation = savedLighting.ExposureCompensation end)
            pcall(function() Lighting.ShadowDensity = savedLighting.ShadowDensity end)
        end
    end,
})
local defaultFOV = Camera.FieldOfView
WorldSub:AddSlider({
    Title = "Field of View", Min = 30, Max = 120, Default = math.floor(defaultFOV), Suffix = "°", Flag = "fov",
    Callback = function(v) Camera.FieldOfView = v end,
})
WorldSub:AddDivider()
local timeEnabled, timeValue = false, 14
local savedClock = Lighting.ClockTime
local savedFog = Lighting.FogEnd
local savedFogColor = Lighting.FogColor
WorldSub:AddToggle({
    Title = "Lock Time", Default = false, Flag = "time_enabled",
    Description = "Freeze ClockTime",
    Callback = function(v)
        timeEnabled = v
        if v then Lighting.ClockTime = timeValue else Lighting.ClockTime = savedClock end
    end,
})
WorldSub:AddSlider({
    Title = "Clock Time", Min = 0, Max = 24, Default = 14, Suffix = "h", Flag = "time_value",
    Callback = function(v) timeValue = v; if timeEnabled then Lighting.ClockTime = v end end,
})
WorldSub:AddToggle({
    Title = "No Fog", Default = false, Flag = "nofog_enabled",
    Callback = function(v)
        if v then savedFog = Lighting.FogEnd; Lighting.FogEnd = 1e9; Lighting.FogColor = Color3.fromRGB(255,255,255)
        else Lighting.FogEnd = savedFog; Lighting.FogColor = savedFogColor end
    end,
})
task.spawn(function()
    while not HUB.dead do
        if timeEnabled then pcall(function() Lighting.ClockTime = timeValue end) end
        task.wait(1)
    end
end)
local RageTab = Window:AddTab({ Title = "Gameplay", Icon = "target" })
local RageFarmSub = RageTab:AddSection("Auto Farm", "solar/home-bold")
local RageHitboxSub = RageTab:AddSection("Roles & Hitbox", "solar/home-bold")
RageFarmSub:AddDivider()
local autoCollect = false
local autoCollectSpeed = 0.8
RageFarmSub:AddToggle({
    Title = "Auto Collect Coins", Default = false, Flag = "auto_collect",
    Description = "Walks to nearest Coin and collects it",
    Callback = function(v)
        autoCollect = v
        Notify("Gameplay", v and "Auto Coins ON" or "Auto Coins OFF", v and "Success" or "Error")
    end,
})
RageFarmSub:AddSlider({
    Title = "Collect Interval", Min = 0.2, Max = 3, Default = 0.8, Suffix = "s", Flag = "auto_collect_speed",
    Callback = function(v) autoCollectSpeed = v end,
})
task.spawn(function()
        local function getNearestCoin()
            local hrp = GetHRP()
            if not hrp then return nil end
            local best, bestDist = nil, math.huge
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency < 1 and v.Parent and (v.Name == "Coin" or v.Name:lower():find("coin")) then
                    if v:IsDescendantOf(LocalPlayer.Character) or v:IsDescendantOf(LocalPlayer) then
                    end
                    local ok, d = pcall(function() return (v.Position - hrp.Position).Magnitude end)
                    if ok and d < bestDist and d <= 250 then best = v; bestDist = d end
                end
            end
            return best
        end
    while not HUB.dead do
        if autoCollect then
            local ok = pcall(function()
                local coin = getNearestCoin()
                local hrp = GetHRP()
                if coin and hrp then
                    local dist = (coin.Position - hrp.Position).Magnitude
                    if dist < 10 then
                        if firetouchinterest then
                            pcall(function() firetouchinterest(hrp, coin, 0); firetouchinterest(hrp, coin, 1) end)
                        end
                        pcall(function() hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 1.5, 0)) end)
                        task.wait(0.15)
                    else
                        local TweenService = game:GetService("TweenService")
                        local tw = TweenService:Create(hrp, TweenInfo.new(math.clamp(dist/100, 0.22, 0.9), Enum.EasingStyle.Linear), { CFrame = CFrame.new(coin.Position + Vector3.new(0, 2.5, 0)) })
                        tw:Play()
                        tw.Completed:Wait()
                    end
                end
            end)
            if not ok then task.wait(1) end
        end
        task.wait(autoCollect and autoCollectSpeed or 0.5)
    end
end)
RageFarmSub:AddDivider()
local rage = {
    hitPart = "Head",
    hitChance = 100,
}
RageHitboxSub:AddDivider()
local hitboxEnabled, hitboxSize = false, 4
local hitboxConn = nil
local originalSizes = {}
local function applyHitbox(enable)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:IsA("BasePart") then
                if enable then
                    if not originalSizes[hrp] then originalSizes[hrp] = hrp.Size end
                    pcall(function()
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.Transparency = 0.6
                        hrp.CanCollide = false
                        hrp.Massless = true
                    end)
                else
                    local orig = originalSizes[hrp]
                    if orig then pcall(function() hrp.Size = orig; hrp.Transparency = 1 end) end
                    originalSizes[hrp] = nil
                end
            end
        end
    end
end
local function startHitboxLoop()
    if hitboxConn then hitboxConn:Disconnect() end
    hitboxConn = RunService.Heartbeat:Connect(function()
        if HUB.dead or not hitboxEnabled then return end
        applyHitbox(true)
    end)
    table.insert(HUB.conns, hitboxConn)
end
local function stopHitboxLoop()
    if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
    for part, orig in pairs(originalSizes) do
        if part and part.Parent then pcall(function() part.Size = orig; part.Transparency = 1 end) end
    end
    table.clear(originalSizes)
end
RageHitboxSub:AddToggle({
    Title = "Expand Hitbox", Default = false, Flag = "rage_hitbox",
    Description = "Makes enemy HRP larger and semi-transparent",
    Callback = function(v)
        hitboxEnabled = v
        if v then startHitboxLoop() else stopHitboxLoop() end
        Notify("Gameplay", v and "Hitbox ON" or "Hitbox OFF", v and "Success" or "Error")
    end,
})
RageHitboxSub:AddSlider({
    Title = "Hitbox Size", Min = 2, Max = 12, Default = 4, Suffix = "", Flag = "rage_hitboxsize",
    Callback = function(v)
        hitboxSize = v
        if hitboxEnabled then applyHitbox(true) end
    end,
})
track(Players.PlayerAdded:Connect(function(p)
    if hitboxEnabled then task.wait(1); applyHitbox(true) end
end))
local RageTabMM2 = Window:AddTab({ Title = "Rage", Icon = "skull" })
local RageMurderSub = RageTabMM2:AddSection("Murderer", "solar/home-bold")
local RageSheriffSub = RageTabMM2:AddSection("Sheriff", "solar/home-bold")
local murderKillAll = false
local murderKillDistance = 35
local murderKillDelay = 0.18
RageMurderSub:AddDivider()
local function isMurderer()
    local char = GetCharacter()
    if not char then return false end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("knife") then return true end
    end
    return false
end
local function killPlayer(targetPlr)
    local char = targetPlr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local myHRP = GetHRP()
    local myChar = GetCharacter()
    if not hrp or not myHRP or not myChar then return end
    local knife = myChar:FindFirstChildOfClass("Tool")
    if not knife or not knife.Name:lower():find("knife") then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then knife = bp:FindFirstChildOfClass("Tool") end
        if knife and knife.Name:lower():find("knife") then
            pcall(function() knife.Parent = myChar end)
            task.wait(0.15)
        else
            return
        end
    end
    local origSize = hrp.Size
    pcall(function()
        hrp.Size = Vector3.new(10,10,10)
        hrp.CanCollide = false
        hrp.Transparency = 0.5
    end)
    pcall(function()
        local handle = knife:FindFirstChild("Handle") or knife:FindFirstChild("Blade") or knife:FindFirstChildWhichIsA("BasePart")
        if handle then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if firetouchinterest then
                        firetouchinterest(handle, part, 0)
                        firetouchinterest(handle, part, 1)
                    end
                end
            end
            pcall(function() knife:Activate() end)
        end
    end)
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("stab") then
                pcall(function() v:FireServer(targetPlr) end)
                pcall(function() v:FireServer(char) end)
                pcall(function() v:FireServer(hrp.Position) end)
            end
        end
    end)
    task.wait(0.05)
    pcall(function()
        hrp.Size = origSize
        hrp.Transparency = 1
    end)
end
RageMurderSub:AddToggle({
    Title = "Kill Aura (nearby)", Default = false, Flag = "mm2_killaura",
    Description = "Auto stabs nearby players when you are murderer",
    Callback = function(v)
        murderKillAll = v
        Notify("Rage", v and "Kill Aura ON" or "Kill Aura OFF", v and "Success" or "Error")
    end,
})
RageMurderSub:AddSlider({
    Title = "Aura Distance", Min = 5, Max = 80, Default = 35, Suffix = " studs", Flag = "mm2_killdist",
    Callback = function(v) murderKillDistance = v end,
})
RageMurderSub:AddSlider({
    Title = "Kill Delay", Min = 0.05, Max = 1, Default = 0.18, Suffix = "s", Flag = "mm2_killdelay",
    Callback = function(v) murderKillDelay = v end,
})
RageMurderSub:AddButton({
    Title = "Kill All (Murderer)", Primary = true,
    Callback = function()
        if not isMurderer() then Notify("Rage", "You are not Murderer!", "Error"); return end
        Notify("Rage", "Killing all...", "Info")
        task.spawn(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if HUB.dead then break end
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    killPlayer(plr)
                    task.wait(murderKillDelay)
                end
            end
            Notify("Rage", "Kill All done", "Success")
        end)
    end,
})
RageMurderSub:AddButton({
    Title = "Kill Closest",
    Callback = function()
        if not isMurderer() then Notify("Rage", "Not murderer", "Error"); return end
        local myPos = GetHRP() and GetHRP().Position or Vector3.zero
        local closest, dist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < dist then dist = d; closest = plr end
            end
        end
        if closest then killPlayer(closest); Notify("Rage", "Killed "..closest.Name, "Success") else Notify("Rage", "No target", "Error") end
    end,
})
task.spawn(function()
    while not HUB.dead do
        if murderKillAll and isMurderer() then
            local myPos = GetHRP() and GetHRP().Position or Vector3.zero
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character.Humanoid.Health > 0 then
                    local hrp = plr.Character.HumanoidRootPart
                    if (hrp.Position - myPos).Magnitude <= murderKillDistance then
                        killPlayer(plr)
                        task.wait(murderKillDelay)
                    end
                end
            end
        end
        task.wait(0.12)
    end
end)
RageSheriffSub:AddDivider()
RageSheriffSub:AddButton({
    Title = "Grab Gun if Dropped",
    Callback = function()
        local gunDrop = nil
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("gun") and v:IsA("Tool") then gunDrop = v; break end
            if v.Name == "GunDrop" and v:IsA("BasePart") then gunDrop = v; break end
        end
        if gunDrop then
            local hrp = GetHRP()
            if hrp then
                local pos = gunDrop:IsA("BasePart") and gunDrop.Position or gunDrop:GetPivot().Position
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,2,0))
                Notify("Rage", "Teleported to gun", "Success")
            end
        else
            Notify("Rage", "No dropped gun found", "Error")
        end
    end,
})
local sheriff = {
    silentEnabled = false,
    fov = 150,
    showFOV = true,
    teamCheck = false,
    hitPart = "Head",
    hitChance = 100,
    targetMode = "Murderer",
    chosenTarget = nil,
}
local function GetSheriffPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    table.sort(names)
    if #names == 0 then names = { "(no players)" } end
    return names
end
local function ResolveSheriffPlayer(name)
    for _, plr in ipairs(Players:GetPlayers()) do if plr.Name == name then return plr end end
    return nil
end
local fovCircle = hasDrawing and newDrawing("Circle", { Thickness = 1.5, NumSides = 64, Radius = 150, Filled = false, Visible = false, Color = Color3.fromRGB(255,255,255), Transparency = 1 }) or nil
if fovCircle then pcall(function() fovCircle.ZIndex = 5 end) end
RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    if fovCircle then
        local on = sheriff.showFOV and sheriff.silentEnabled
        fovCircle.Visible = on
        if on then
            pcall(function()
                fovCircle.Radius = sheriff.fov
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                fovCircle.Color = esp.rainbow and Color3.fromHSV((tick() % 5)/5, 0.85, 1) or Color3.fromRGB(255,255,255)
            end)
        end
    end
end)
local function getAimTarget()
    if not sheriff.silentEnabled then return nil end
    if math.random(1,100) > sheriff.hitChance then return nil end
    local camPos = Camera.CFrame.Position
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local mPos = UserInputService:GetMouseLocation()
    local ref = (mPos.Magnitude < 5) and center or mPos
    local myPos = GetHRP() and GetHRP().Position or camPos
    local bestPart, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local skip = false
            if sheriff.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then skip = true end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not skip and (not char or not hum or hum.Health <= 0) then skip = true end
            if not skip and sheriff.targetMode == "Murderer" then
                local role = GetRole(plr)
                if role ~= "Murderer" and role ~= "Murderer?" then skip = true end
            end
            local part
            if not skip then
                local want = sheriff.hitPart
                if want == "Random" then want = (math.random() > 0.5) and "Head" or "HumanoidRootPart" end
                part = char:FindFirstChild(want) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                if not part or not part:IsA("BasePart") then skip = true end
            end
            if not skip and sheriff.visibleCheck then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { LocalPlayer.Character, char, Camera }
                local dir = part.Position - camPos
                local res = Workspace:Raycast(camPos, dir, params)
                if res and res.Instance and not res.Instance:IsDescendantOf(char) then skip = true end
            end
            if not skip then
                if sheriff.targetMode == "Nearest" then
                    local d = (part.Position - myPos).Magnitude
                    if d < bestScore then bestScore = d; bestPart = part end
                elseif sheriff.targetMode == "Chosen" then
                    if sheriff.chosenTarget and plr.Name == sheriff.chosenTarget then bestPart = part; break end
                else
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - ref).Magnitude
                        if d <= sheriff.fov and d < bestScore then bestScore = d; bestPart = part end
                    end
                end
            end
        end
    end
    return bestPart
end
do
    local G = getgenv and getgenv() or _G
    if not G.OxideSheriffHooked then
        G.OxideSheriffHooked = true
        local mod
        pcall(function() mod = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GunHandler")) end)
        local HookFn = hookfunction or replaceclosure
        if mod and type(mod.shoot) == "function" and HookFn then
            local orig
            orig = HookFn(mod.shoot, function(p26)
                if sheriff.silentEnabled and p26 and p26.Shooter == LocalPlayer.Character and p26.AimPosition then
                    local tgt = getAimTarget()
                    if tgt then
                        p26.AimPosition = tgt.Position + (tgt.AssemblyLinearVelocity or Vector3.zero) * 0.13
                    end
                end
                return orig(p26)
            end)
            G.OxideSheriffOrigShoot = orig
            print("Sheriff: GunHandler.shoot hooked")
        elseif mod and type(mod.getAim) == "function" and HookFn then
            local orig
            orig = HookFn(mod.getAim, function(origin, range)
                if sheriff.silentEnabled then
                    local t = getAimTarget()
                    if t then return (t.Position - origin).Unit, (t.Position - origin).Magnitude end
                end
                return orig(origin, range)
            end)
            G.OxideSheriffOrigAim = orig
            print("Sheriff: GunHandler.getAim hooked")
        else
            if not G.OxideSheriffRayHooked then
                G.OxideSheriffRayHooked = true
                local origRay = Workspace.Raycast
                Workspace.Raycast = function(self, origin, direction, params)
                    if sheriff.silentEnabled and self == Workspace and direction and direction.Magnitude > 30 then
                        local t = getAimTarget()
                        if t then
                            local newDir = (t.Position - origin).Unit * direction.Magnitude
                            return origRay(self, origin, newDir, params)
                        end
                    end
                    return origRay(self, origin, direction, params)
                end
                print("Sheriff: Raycast fallback hooked")
            end
        end
    end
end
RageSheriffSub:AddDivider()
RageSheriffSub:AddToggle({
    Title = "Silent Aim", Default = false, Flag = "sheriff_silent",
    Callback = function(v)
        sheriff.silentEnabled = v
        Notify("Rage", v and "Silent Aim ON" or "Silent Aim OFF", v and "Success" or "Error")
    end,
})
RageSheriffSub:AddDropdown({
    Title = "Target Mode", Values = {"Murderer", "FOV", "Nearest", "Chosen"}, Default = "Murderer", MaxVisible = 4, Flag = "sheriff_targetmode",
    Callback = function(v) sheriff.targetMode = v end,
})
local applyChosen = function(v) sheriff.chosenTarget = v end
local chosenDropdown = RageSheriffSub:AddDropdown({
    Title = "Chosen Player", Options = GetSheriffPlayerNames(), Default = nil, MaxVisible = 6, Searchable = true, Flag = "sheriff_chosen",
    Callback = applyChosen,
})
registerResync(chosenDropdown, applyChosen)
RageSheriffSub:AddButton({ Title = "Refresh Players", Callback = function() chosenDropdown:SetOptions(GetSheriffPlayerNames()) end })
RageSheriffSub:AddSlider({ Title = "FOV Radius", Min = 10, Max = 600, Default = 150, Suffix = "px", Flag = "sheriff_fov", Callback = function(v) sheriff.fov = v end })
RageSheriffSub:AddToggle({ Title = "Show FOV", Default = true, Flag = "sheriff_showfov", Callback = function(v) sheriff.showFOV = v end })
RageSheriffSub:AddToggle({ Title = "Team Check", Default = false, Flag = "sheriff_teamcheck", Callback = function(v) sheriff.teamCheck = v end })
RageSheriffSub:AddToggle({ Title = "Wall Check", Default = false, Flag = "sheriff_wallcheck", Callback = function(v) sheriff.visibleCheck = v end })
RageSheriffSub:AddDropdown({ Title = "Hit Part", Values = {"Head", "HumanoidRootPart", "UpperTorso", "Random"}, Default = "Head", MaxVisible = 4, Flag = "sheriff_hitpart", Callback = function(v) sheriff.hitPart = v end })
RageSheriffSub:AddSlider({ Title = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Flag = "sheriff_hitchance", Callback = function(v) sheriff.hitChance = v end })
local SystemTab = Window:AddTab({ Title = "System", Icon = "solar/settings-bold" })
local MoneySub = SystemTab:AddSection("Balance", "solar/home-bold")
local moneyText = ("Coins: %s\nLevel: %d\nRole: %s"):format(FormatMoney(GetCoins()), GetLevel(), GetRole())
local moneyLabel = MoneySub:AddParagraph({ Title = "Balance", Text = moneyText })
local function RefreshMoneyCard()
    local text = ("Coins: %s\nLevel: %d\nRole: %s"):format(FormatMoney(GetCoins()), GetLevel(), GetRole())
    if moneyLabel then
        pcall(function()
            if type(moneyLabel.Set) == "function" then moneyLabel:Set(text) end
        end)
    end
end
task.spawn(function()
    local tries = 0
    while not HUB.dead do
        pcall(RefreshMoneyCard)
        task.wait(2)
        tries = tries + 1
        if tries > 600 then break end
    end
end)
MoneySub:AddButton({
    Title = "Refresh Now",
    Callback = function() RefreshMoneyCard(); Notify("Money", "Refreshed", "Info") end,
})
local coinHighlights = {}
task.spawn(function()
    while not HUB.dead do
        if esp.coinESP and esp.enabled then
            pcall(function()
                local found={}
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v.Name=="Coin" and v:IsA("BasePart") and v.Transparency < 1 then
                        found[v]=true
                        if not coinHighlights[v] then
                            local hl=Instance.new("Highlight")
                            hl.Name="OxideMm2Coin"
                            hl.FillColor=esp.coinColor or Color3.fromRGB(255,221,0)
                            hl.FillTransparency=0.6
                            hl.OutlineColor=esp.coinColor or Color3.fromRGB(255,221,0)
                            hl.OutlineTransparency=0
                            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                            pcall(function() hl.Parent=v end)
                            table.insert(HUB.highlights, hl)
                            coinHighlights[v]=hl
                        end
                    end
                end
                for part,hl in pairs(coinHighlights) do
                    if not found[part] then pcall(function() hl:Destroy() end); coinHighlights[part]=nil end
                end
            end)
        elseif next(coinHighlights) then
            for p,hl in pairs(coinHighlights) do pcall(function() hl:Destroy() end); coinHighlights[p]=nil end
        end
        task.wait(1)
    end
end)
local gunHighlights = {}
task.spawn(function()
    while not HUB.dead do
        if esp.gunESP and esp.enabled then
            pcall(function()
                local found={}
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v.Name:lower():find("gun") or v.Name:lower():find("knife") then
                        if v:IsA("Tool") or v:IsA("BasePart") then
                            local p = v:IsA("BasePart") and v or v:FindFirstChild("Handle") or v
                            if p and p:IsA("BasePart") then
                                found[p]=true
                                if not gunHighlights[p] then
                                    local hl=Instance.new("Highlight")
                                    hl.Name="OxideMm2Gun"
                                    hl.FillColor=Color3.fromRGB(120,80,255)
                                    hl.FillTransparency=0.5
                                    hl.OutlineColor=Color3.fromRGB(120,80,255)
                                    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                                    pcall(function() hl.Parent=p end)
                                    table.insert(HUB.highlights, hl)
                                    gunHighlights[p]=hl
                                end
                            end
                        end
                    end
                end
                for part,hl in pairs(gunHighlights) do if not found[part] then pcall(function() hl:Destroy() end); gunHighlights[part]=nil end end
            end)
        elseif next(gunHighlights) then
            for p,hl in pairs(gunHighlights) do pcall(function() hl:Destroy() end); gunHighlights[p]=nil end
        end
        task.wait(1.2)
    end
end)
local ServerSub = SystemTab:AddSection("Server", "solar/home-bold")
ServerSub:AddButton({
    Title = "Rejoin Server", Primary = true,
    Callback = function()
        Notify("Server", "Rejoining...", "Info")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})
ServerSub:AddSlider({
    Title = "Hop Player Max", Min = 5, Max = 28, Default = 12, Suffix = " players", Flag = "hop_playermax",
    Description = "Only hop to servers below this count",
    Callback = function(v) _G.OxideHopMax = v end,
})
ServerSub:AddButton({
    Title = "Hop To Low Player Server", Primary = true,
    Callback = function()
        Notify("Server", "Finding low player server...", "Info")
        task.spawn(function()
            local ok,err=pcall(function()
                local HttpService=game:GetService("HttpService")
                local url=("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
                local raw
                local ok2,res=pcall(function() return game:HttpGet(url) end)
                if ok2 and type(res)=="string" and #res>10 then raw=res
                elseif typeof(request)=="function" then local r=request({Url=url,Method="GET"}); if r and r.Body and r.StatusCode==200 then raw=r.Body else error("request failed") end
                else error("no http") end
                local data=HttpService:JSONDecode(raw)
                local best=nil
                local maxPlayers=_G.OxideHopMax or 12
                for _,s in ipairs(data.data or {}) do
                    if type(s.playing)=="number" and s.playing < maxPlayers and s.playing < s.maxPlayers and s.id~=game.JobId then
                        if not best or s.playing < best.playing then best=s end
                    end
                end
                if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
                else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
            end)
            if not ok then Notify("Server", "Low Hop failed: "..tostring(err), "Error",4) end
        end)
    end,
})
ServerSub:AddButton({
    Title = "Server Hop",
    Callback = function()
        Notify("Server", "Finding a new server...", "Info")
        task.spawn(function()
            local ok, err = pcall(function()
                local HttpService = game:GetService("HttpService")
                local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
                local raw
                local ok2, res = pcall(function() return game:HttpGet(url) end)
                if ok2 and type(res) == "string" and #res > 10 then
                    raw = res
                elseif typeof(request) == "function" then
                    local r = request({Url = url, Method = "GET"})
                    if r and r.Body and r.StatusCode == 200 then raw = r.Body else error("request failed") end
                elseif typeof(syn) == "table" and syn.request then
                    local r = syn.request({Url = url, Method = "GET"})
                    if r and r.Body and r.StatusCode == 200 then raw = r.Body else error("syn.request failed") end
                else
                    error("no http method available")
                end
                local data = HttpService:JSONDecode(raw)
                for _, s in ipairs(data.data or {}) do
                    if type(s.playing) == "number" and s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
            if not ok then Notify("Server", "Hop failed: " .. tostring(err), "Error", 4) end
        end)
    end,
})
ServerSub:AddButton({
    Title = "Copy Job ID",
    Callback = function()
        local ok = pcall(function() (setclipboard or toclipboard or writeclipboard)(game.JobId) end)
        Notify("Server", ok and "Job ID copied" or "Clipboard unavailable", ok and "Success" or "Error")
    end,
})
local ShopSub = SystemTab:AddSection("Shop", "solar/home-bold")
ShopSub:AddDivider()
local shopFolder = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Shop")
local function getShopGuns()
    local list = {}
    if not shopFolder then return {"(no shop)"} end
    for _, it in ipairs(shopFolder:GetChildren()) do
        if it.Name:match("^%[.*%]") and it:FindFirstChild("ClickDetector") then
            table.insert(list, it.Name)
        end
    end
    table.sort(list)
    if #list == 0 then return {"(no guns)"} end
    return list
end
local selectedGun = nil
local function applyGun(v) selectedGun = v end
local gunDropdown = ShopSub:AddDropdown({
    Title = "Weapon", Options = getShopGuns(), Default = nil, MaxVisible = 6, Searchable = true, Flag = "shop_gun",
    Callback = applyGun,
})
registerResync(gunDropdown, applyGun)
ShopSub:AddButton({
    Title = "Refresh Guns",
    Callback = function() gunDropdown:SetOptions(getShopGuns()); Notify("Shop", "Guns refreshed", "Info") end,
})
local function buyGun(name)
    if not name or name:find("%(no") then Notify("Shop", "Select a gun first", "Error"); return end
    local item = shopFolder and shopFolder:FindFirstChild(name)
    if not item then Notify("Shop", "Gun not found: "..tostring(name), "Error"); return end
    local cd = item:FindFirstChildOfClass("ClickDetector") or item:FindFirstChild("ClickDetector", true)
    if not cd then Notify("Shop", "No ClickDetector for "..name, "Error"); return end
    local bought = false
    if type(fireclickdetector) == "function" then
        local ok = pcall(function() fireclickdetector(cd) end)
        bought = ok
    elseif type(clickDetector) == "function" then
        pcall(function() clickDetector(cd) end)
    end
    if not bought then
        pcall(function()
            local part = item:FindFirstChild("Head") or item:FindFirstChildWhichIsA("BasePart")
            if part then
                local hrp = GetHRP()
                if hrp then
                    local old = hrp.CFrame
                    hrp.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.15)
                    if fireclickdetector then fireclickdetector(cd) end
                    task.wait(0.15)
                    hrp.CFrame = old
                    bought = true
                end
            end
        end)
    end
    Notify("Shop", bought and ("Bought "..name) or ("Failed "..name), bought and "Success" or "Error")
end
ShopSub:AddButton({
    Title = "Buy Selected", Primary = true,
    Callback = function() buyGun(selectedGun) end,
})
local autoBuyEnabled = false
local autoBuyAmmo = false
ShopSub:AddToggle({
    Title = "Auto Buy on Low Ammo", Default = false, Flag = "shop_autobuy",
    Description = "Re-buys gun when you have no tool of that gun",
    Callback = function(v) autoBuyEnabled = v; Notify("Shop", v and "Auto Buy ON" or "Auto Buy OFF", v and "Success" or "Error") end,
})
ShopSub:AddToggle({
    Title = "Include Ammo", Default = false, Flag = "shop_autoammo",
    Callback = function(v) autoBuyAmmo = v end,
})
task.spawn(function()
    while not HUB.dead do
        if autoBuyEnabled and selectedGun and not selectedGun:find("%(no") then
            local has = false
            local char = GetCharacter()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local checkName = selectedGun:match("^%[[^%]]+%]") or selectedGun
            if char then for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:find(checkName, 1, true) then has=true end end end
            if bp and not has then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:find(checkName, 1, true) then has=true end end end
            local inv = LocalPlayer:FindFirstChild("DataFolder") and LocalPlayer.DataFolder:FindFirstChild("Inventory")
            local iv = inv and inv:FindFirstChild(checkName)
            if iv and iv.Value > 0 then has = true end
            if not has then
                local money = GetCoins()
                local shopItem = shopFolder and shopFolder:FindFirstChild(selectedGun)
                local priceObj = shopItem and shopItem:FindFirstChild("Price")
                local price = priceObj and priceObj.Value or 0
                if money >= price then
                    buyGun(selectedGun)
                    if autoBuyAmmo then
                        task.wait(0.4)
                        local ammoName = "30 ["..checkName:gsub("%[",""):gsub("%]","").." Ammo] - $"
                        for _,it in ipairs(shopFolder:GetChildren()) do
                            if it.Name:lower():find("ammo") and it.Name:lower():find(checkName:lower():gsub("%[",""):gsub("%]",""):sub(1,4)) then
                                buyGun(it.Name)
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)
ShopSub:AddDivider()
local quickGuns = {"[Revolver] - $1339", "[Glock] - $338", "[Shotgun] - $1250", "[AK47] - $2250"}
for _, q in ipairs(quickGuns) do
    ShopSub:AddButton({
        Title = "Buy "..q:match("^%[[^%]]+%]"),
        Callback = function() buyGun(q) end,
    })
end
local SettingsSub = SystemTab:AddSection("Settings", "solar/home-bold")
if type(Library.SetTheme) == "function" then
    SettingsSub:AddDropdown({
        Title = "Theme", Values = { "Dark", "Light", "OLED" }, Default = "Dark",
        Flag = "ui_theme",
        Callback = function(v) pcall(function() Library:SetTheme(v) end) end,
    })
end
SettingsSub:AddDivider()
local setFpsCap = setfpscap or (getfenv and getfenv().setfpscap)
if type(setFpsCap) == "function" then
    local fpsUnlocked = false
    local fpsCap = 240
    SettingsSub:AddToggle({
        Title = "Unlock FPS (Unlimited)", Default = false, Flag = "fps_unlock",
        Description = "Removes the FPS cap (infinite)",
        Callback = function(v)
            fpsUnlocked = v
            pcall(setFpsCap, v and 0 or fpsCap)
            Notify("FPS", v and "Unlocked (unlimited)" or ("Capped at " .. fpsCap), v and "Success" or "Info")
        end,
    })
    SettingsSub:AddSlider({
        Title = "FPS Cap", Min = 30, Max = 1000, Default = 240, Suffix = "", Flag = "fps_cap",
        Description = "Used when FPS is not unlocked (0 via unlock = ∞)",
        Callback = function(v)
            fpsCap = v
            if not fpsUnlocked then pcall(setFpsCap, v) end
        end,
    })
else
    end
if HAS_CONFIG then
    SettingsSub:AddDivider()
    SettingsSub:AddButton({
        Title = "Save Config", Primary = true,
        Callback = function()
            local ok = pcall(function() Library:SaveConfig(CONFIG_NAME) end)
            Notify("Config", ok and "Saved" or "Save failed", ok and "Success" or "Error")
        end,
    })
    SettingsSub:AddButton({
        Title = "Load Config",
        Callback = function()
            local ok = pcall(function() Library:LoadConfig(CONFIG_NAME) end)
            if ok then ResyncAll() end
            Notify("Config", ok and "Loaded" or "Load failed", ok and "Success" or "Error")
        end,
    })
else
    end
SettingsSub:AddDivider()
local function Cleanup()
    flying = false; noclip = false; infJump = false
    antiRagdoll = false; wsEnabled = false; jpEnabled = false; hipEnabled = false
    pcall(function() if flyConn then flyConn:Disconnect() end end)
    pcall(stopNoclip)
    pcall(stopAntiRagdoll)
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() if hitboxEnabled then stopHitboxLoop() end end)
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    for _, h in ipairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    table.clear(playerObjects)
    if coinHighlights then for p,hl in pairs(coinHighlights) do pcall(function() hl:Destroy() end); coinHighlights[p]=nil end end
    if gunHighlights then for p,hl in pairs(gunHighlights) do pcall(function() hl:Destroy() end); gunHighlights[p]=nil end end
    pcall(function()
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50; hum.HipHeight = 2 end
    end)
    Workspace.Gravity = defaultGravity
    Camera.FieldOfView = defaultFOV
    if fullbright then
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.Ambient = savedLighting.Ambient
        pcall(function() Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient end)
        pcall(function() Lighting.ExposureCompensation = savedLighting.ExposureCompensation end)
        pcall(function() Lighting.ShadowDensity = savedLighting.ShadowDensity end)
    end
    pcall(function() Window:Destroy() end)
end
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    Cleanup()
end
SettingsSub:AddButton({
    Title = "Unload Hub",
    Callback = function()
        HUB.Unload()
        _G.OxideMm2 = nil
    end,
})
Notify("MM2", "NevaHub loaded — Coins: "..tostring(GetCoins()).." | Role: "..GetRole(), "Success", 3)
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
