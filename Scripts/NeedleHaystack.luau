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
    SubTitle = "Needle Haystack",
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
    local prev = _G.OxideNeedleHaystack
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false, loops = {} }
_G.OxideNeedleHaystack = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackHighlight(h) if h then table.insert(HUB.highlights, h) end; return h end
local function TrackLoop(id, fn, interval)
    HUB.loops[id] = true
    task.spawn(function()
        local last = 0
        while HUB.loops[id] and not HUB.dead do
            local now = os.clock()
            if (interval or 0) <= 0 or (now - last) >= interval then
                last = now
                local ok, err = pcall(fn)
                if not ok then warn("[NevaHub NeedleHaystack] loop error " .. tostring(id) .. ": " .. tostring(err)) end
            end
            task.wait()
        end
    end)
end
local function KillLoop(id)
    HUB.loops[id] = nil
end
local CONFIG_NAME = "needlehaystack"
local Players             = game:GetService("Players")
local RS                  = game:GetService("ReplicatedStorage")
local ReplicatedStorage   = RS
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Workspace           = game:GetService("Workspace")
local Lighting            = game:GetService("Lighting")
local TweenService        = game:GetService("TweenService")
local VirtualUser         = game:GetService("VirtualUser")
local LP          = Players.LocalPlayer
local LocalPlayer = LP
local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
end
local function GetChar()
    return LP.Character
end
local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
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
            pcall(Notify, "NevaHub", "Error: " .. tostring(err), "Error", 4)
        end
    end
end
local function notifyOn(name, on)
    Notify(name, on and "Enabled" or "Disabled", on and "Success" or "Info", 1.2)
end
local GameConfig, GameSurface
do
    local okC, cfg = pcall(require, RS:WaitForChild("NeedleHaystack"):WaitForChild("Config", 10))
    if okC and type(cfg) == "table" then GameConfig = cfg end
    local okS, surf = pcall(require, RS:FindFirstChild("NeedleHaystack") and RS.NeedleHaystack:FindFirstChild("Surface"))
    if okS and type(surf) == "table" then GameSurface = surf end
end
local PILE_CENTER  = GameConfig and GameConfig.PILE_CENTER or Vector3.new(-199.18434, 2.1, 30.241207)
local PILE_RADIUS  = GameConfig and GameConfig.PILE_RADIUS or 17
local RENDERED_HAY = GameConfig and GameConfig.RENDERED_HAY or 13000
local TOTAL_HAY    = GameConfig and GameConfig.TOTAL_HAY or 100000
local SELL_POS     = Vector3.new(-161.28688049316406, 6.126363754272461, 56.90555191040039)
local function GetNH()
    return RS:FindFirstChild("NeedleHaystack")
end
local function Remote(name)
    local nh = GetNH()
    return nh and nh:FindFirstChild(name) or nil
end
local function GetHayState()
    local r = Remote("GetHayState")
    if not r then return nil end
    local ok, st = pcall(function() return r:InvokeServer() end)
    if ok and type(st) == "table" then return st end
    return nil
end
local function GetUpgradeState()
    local r = Remote("GetUpgradeState")
    if not r then return nil end
    local ok, st = pcall(function() return r:InvokeServer() end)
    if ok and type(st) == "table" then return st end
    return nil
end
local function Fire(name, ...)
    local r = Remote(name)
    if not r then return end
    local args = { ... }
    pcall(function() r:FireServer(unpack(args)) end)
end
local function strandPosition(index)
    if GameSurface and GameSurface.strandCFrame then
        local ok, cf = pcall(function()
            return GameSurface.strandCFrame(index, RENDERED_HAY, 11, 0, 0, true, 0, false)
        end)
        if ok and typeof(cf) == "CFrame" then
            return cf.Position
        end
    end
    return nil
end
local S = {
    autoDig         = false,
    digMode         = "Spiral",
    digRadius       = 8,
    digSpeed        = 1,
    rainbowMode     = "Off",
    autoSell        = false,
    sellThreshold   = 20,
    autoGems        = false,
    autoNeedle      = false,
    collectWith     = "Hand",
    autoBuyTools    = false,
    forceUnlock     = true,
    autoUpgrade     = false,
    maxUpgradeCost  = 100,
    upgradeTracks   = {},
    espEnabled      = false,
    espRainbow      = true,
    espNeedle       = true,
    espGems         = true,
    walkSpeed       = 16,
    jumpPower       = 50,
    infiniteJump    = false,
    fly             = false,
    noclip          = false,
    antiAFK         = false,
    fullbright      = false,
    _digAngle       = 0,
    _selling        = false,
    _lastSell       = 0,
    _lastGems       = 0,
    _lastNeedle     = 0,
    _lastPick       = 0,
    _rainbowList    = nil,
    _rainbowCacheT  = 0,
    _rainbowNext    = 1,
    _pickedHay      = {},
    _gemCache       = {},
    _needleCache    = {},
    _stateLabels    = {},
    _needleTarget   = nil,
    _ownedTools     = {},
    _buyBudget      = {},
    _buyCooldown    = 0,
}
local TRACK_COSTS = {
    Capacity          = { 0, 1, 2.5, 5, 10 },
    HandHold          = { 0, 1 },
    Speed             = { 0, 0.25, 0.5, 1, 2, 3 },
    Grab              = { 0, 0.25, 0.5, 1, 2, 4 },
    TntLuck           = { 0, 3, 6, 12, 24, 45 },
    TntCooldown       = { 0, 2, 5, 10, 20, 30 },
    TntPower          = { 0, 3, 7, 14, 28, 50 },
    PitchforkCooldown = { 0, 1, 2, 4, 8, 14 },
    PitchforkHold     = { 0, 1 },
    Pitchfork         = { 0, 1, 2, 4, 10, 23 },
    DroneSpeed        = { 0, 0.5, 1.5, 3, 6, 12 },
    DroneGrab         = { 0, 0.5, 1.5, 3, 6, 13 },
    DroneCapacity     = { 0, 0.5, 1, 2.5, 5, 9 },
    VacuumPower       = { 0, 6, 16, 32, 68, 128 },
    VacuumCooling     = { 0, 5, 12.5, 28, 56, 112 },
    VacuumRuntime     = { 0, 5, 12.5, 28, 60, 120 },
}
local PICK_COOLDOWNS = { 0.55, 0.5, 0.45, 0.4, 0.35, 0.3 }
local TOOL_NAMES = {
    Hand = "hand", TNT = "tnt", Pitchfork = "pitchfork",
    Drone = "drone", Vacuum = "vacuum", Needle = "needle",
}
local function isRainbowIndex(index)
    if GameConfig and type(GameConfig.isRainbow) == "function" then
        local ok, res = pcall(GameConfig.isRainbow, index)
        if ok then return res == true end
    end
    local v = math.sin(index * 7.31413 + 8242026 * 0.00037 + 1913.77) * 24634.6345
    return (v - math.floor(v)) < 0.0025
end
local function BuildRainbowList()
    local out = {}
    for i = 1, RENDERED_HAY do
        if isRainbowIndex(i) then
            local pos = strandPosition(i)
            if pos then
                table.insert(out, { index = i, pos = pos })
            end
        end
    end
    table.sort(out, function(a, b)
        return math.atan2(a.pos.X - PILE_CENTER.X, a.pos.Z - PILE_CENTER.Z)
            < math.atan2(b.pos.X - PILE_CENTER.X, b.pos.Z - PILE_CENTER.Z)
    end)
    return out
end
local function GetRainbowList()
    local now = os.clock()
    if not S._rainbowList or now - S._rainbowCacheT > 30 then
        S._rainbowCacheT = now
        S._rainbowList = BuildRainbowList()
        S._rainbowNext = 1
    end
    return S._rainbowList
end
local RAINBOW_COLOR = Color3.fromRGB(255, 90, 255)
local NEEDLE_COLOR = Color3.fromRGB(255, 60, 60)
local GEM_COLOR = Color3.fromRGB(90, 190, 255)
local function clearEsp()
    for _, h in ipairs(HUB.highlights) do
        pcall(h.Destroy, h)
    end
    HUB.highlights = {}
end
local function espPart(part, color)
    if not part or not part.Parent then return nil end
    local h = Instance.new("Highlight")
    h.Name = "OxideNeedleEsp"
    h.FillColor = color or RAINBOW_COLOR
    h.OutlineColor = Color3.new(1, 1, 1)
    h.FillTransparency = 0.45
    h.OutlineTransparency = 0
    h.Parent = part
    trackHighlight(h)
    return h
end
local function espAtPosition(pos, color)
    if not pos then return end
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("hay", 1, true) and not part:FindFirstChild("OxideNeedleEsp") then
            if (part.Position - pos).Magnitude < 1.2 then
                espPart(part, color)
                return
            end
        end
    end
end
TrackLoop("esp", function()
    if not S.espEnabled then return end
    local now = os.clock()
    if S.espRainbow then
        local list = GetRainbowList()
        local perFrame = math.min(6, #list)
        for k = 1, perFrame do
            local entry = list[(now * 17 + k * 7) % #list + 1]
            if entry then espAtPosition(entry.pos, RAINBOW_COLOR) end
        end
    end
    if S.espGems and now - (S._gemCache.t or 0) > 2 then
        S._gemCache.t = now
        S._gemCache.parts = {}
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("gem", 1, true)
                and not part:GetFullName():find("GemsClient", 1, true) then
                table.insert(S._gemCache.parts, part)
            end
        end
        for _, part in ipairs(S._gemCache.parts or {}) do
            if part.Parent and not part:FindFirstChild("OxideNeedleEsp") then
                espPart(part, GEM_COLOR)
            end
        end
    end
    if S.espNeedle then
        local st = GetHayState()
        if st and (st.needleRevealed or S._needleTarget) then
            local target = S._needleTarget
            if not target then
                if now - (S._needleCache.t or 0) > 2 then
                    S._needleCache.t = now
                    S._needleCache.parts = {}
                    for _, part in ipairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name:lower():find("needle", 1, true) then
                            table.insert(S._needleCache.parts, part)
                        end
                    end
                end
                local parts = S._needleCache.parts or {}
                for _, part in ipairs(parts) do
                    if part.Parent and not part:FindFirstChild("OxideNeedleEsp") then
                        espPart(part, NEEDLE_COLOR)
                    end
                end
            else
                espAtPosition(target, NEEDLE_COLOR)
            end
        end
    end
end, 0.4)
local _activeTween = nil
local function TweenTo(position, speed)
    local hrp = GetHRP()
    if not hrp then return end
    if _activeTween then
        pcall(function() _activeTween:Cancel() end)
        _activeTween = nil
    end
    local dist = (hrp.Position - position).Magnitude
    if dist < 2 then return end
    local duration = math.clamp(dist / math.max(1, speed or S.walkSpeed), 0.1, 3)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, { CFrame = CFrame.new(position, position + Vector3.new(0, 0, 1)) })
    tween:Play()
    _activeTween = tween
    tween.Completed:Connect(function()
        if _activeTween == tween then _activeTween = nil end
    end)
end
local function TeleportTo(position)
    local hrp = GetHRP()
    if not hrp then return end
    if _activeTween then
        pcall(function() _activeTween:Cancel() end)
        _activeTween = nil
    end
    hrp.CFrame = CFrame.new(position, position + Vector3.new(0, 0, 1))
end
local function EquipTool(toolName)
    local name = TOOL_NAMES[toolName]
    if not name then return end
    Fire("HeldToolState", name, "idle")
end
local TOOL_BUY = {
    Tnt       = { currency = "CASH" },
    Pitchfork = { currency = "CASH" },
    Vacuum    = { currency = "CASH" },
    Drone     = { currency = "GEMS" },
}
local UNLOCK_ATTRS = {
    "TntOwned", "PitchforkOwned", "DroneOwned", "VacuumOwned",
    "InfiniteBagOwned", "NeedleOwned",
    "PermanentTntOwned", "PermanentPitchforkOwned", "PermanentDroneOwned",
    "PermanentVacuumOwned", "PermanentInfiniteBagOwned",
}
local function BuyToolNow(name)
    Fire("BuyShopItem", name)
end
track(function()
    local spr = Remote("ShopPurchaseResult")
    if not spr then return end
    spr.OnClientEvent:Connect(function(ok, item)
        local key = tostring(item or "")
        if ok then
            S._ownedTools[key] = true
            Notify("Tools", key .. " unlocked! (server confirmed)", "Success", 3)
        end
    end)
end)
track(function()
    local function apply()
        if not S.forceUnlock then return end
        for _, k in ipairs(UNLOCK_ATTRS) do
            pcall(function() LP:SetAttribute(k, true) end)
        end
    end
    apply()
    for _, k in ipairs(UNLOCK_ATTRS) do
        pcall(function()
            LP:GetAttributeChangedSignal(k):Connect(function()
                if S.forceUnlock and LP:GetAttribute(k) ~= true then
                    pcall(function() LP:SetAttribute(k, true) end)
                end
            end)
        end)
    end
end)
TrackLoop("buytools", function()
    if not S.autoBuyTools then return end
    local now = os.clock()
    if now - S._buyCooldown < 1.2 then return end
    local st = GetUpgradeState()
    if not st then return end
    local cash = tonumber(st.cash or 0)
    local gems = tonumber(LP:GetAttribute("Gems") or 0)
    for name, info in pairs(TOOL_BUY) do
        if not S._ownedTools[name] then
            local budget = info.currency == "CASH" and cash or gems
            local last = S._buyBudget[name]
            if not last or budget >= last + 0.5 then
                S._buyBudget[name] = budget
                S._buyCooldown = now
                BuyToolNow(name)
                return
            end
        end
    end
end, 0.4)
local function IsToolOwned(name)
    return S._ownedTools[name] == true
end
local function nextDigIndex()
    local hrp = GetHRP()
    local hrpPos = hrp and hrp.Position or PILE_CENTER
    if S.rainbowMode ~= "Off" then
        local list = GetRainbowList()
        for tries = 1, #list do
            local entry = list[S._rainbowNext]
            S._rainbowNext = S._rainbowNext % #list + 1
            if entry and not S._pickedHay[entry.index] then
                if (entry.pos - hrpPos).Magnitude > 10 then
                    TeleportTo(entry.pos + Vector3.new(0, 2, 0))
                end
                return entry.index
            end
        end
        if S.rainbowMode == "Only" then
            return nil
        end
    end
    for tries = 1, 24 do
        local idx = math.random(1, RENDERED_HAY)
        if not S._pickedHay[idx] then
            local pos = strandPosition(idx)
            if pos and (pos - hrpPos).Magnitude < 14 then
                return idx
            end
        end
    end
    for tries = 1, 40 do
        local idx = math.random(1, RENDERED_HAY)
        if not S._pickedHay[idx] then return idx end
    end
    return math.random(1, RENDERED_HAY)
end
TrackLoop("dig", function()
    if not S.autoDig then return end
    if S._selling then return end
    local st = GetHayState()
    if st and st.needleClaimed then
        return
    end
    local now = os.clock()
    local up = GetUpgradeState()
    local speedLvl = up and tonumber(up.levels and up.levels.Speed or 1) or 1
    local cooldown = (PICK_COOLDOWNS[speedLvl] or 0.3) / S.digSpeed
    local usePitchfork = S.collectWith == "Pitchfork" and IsToolOwned("Pitchfork")
    if usePitchfork then cooldown = math.max(cooldown, 0.9) end
    if now - S._lastPick < cooldown then return end
    EquipTool(usePitchfork and "Pitchfork" or "Hand")
    local idx = nextDigIndex()
    if not idx then return end
    S._pickedHay[idx] = true
    if usePitchfork then
        local pos = strandPosition(idx)
        local hrp = GetHRP()
        if pos and hrp and (pos - hrp.Position).Magnitude > 3.5 then
            TeleportTo(pos + Vector3.new(0, 1, 0))
            return
        end
        Fire("PitchforkDig", idx)
    else
        Fire("PickHay", idx, {})
    end
    S._lastPick = now
    if S.rainbowMode == "Off" and S.digMode ~= "Random" and not usePitchfork then
        S._digAngle = S._digAngle + 0.12
        local radius = S.digMode == "Center" and 4
            or (S.digMode == "Ring" and S.digRadius or (8 + math.sin(S._digAngle) * 6))
        local pos = PILE_CENTER + Vector3.new(math.cos(S._digAngle) * radius, 2, math.sin(S._digAngle) * radius)
        local hrp = GetHRP()
        if hrp and (hrp.Position - pos).Magnitude > 16 then
            TeleportTo(pos)
        end
    end
    local n = 0
    for _ in pairs(S._pickedHay) do
        n = n + 1
        if n > 8000 then break end
    end
    if n > 8000 then S._pickedHay = {} end
end, 0.05)
local function SellNow()
    local st = GetUpgradeState()
    if st and tonumber(st.held or 0) <= 0 then
        return 0
    end
    Fire("SellHay")
    return 1
end
TrackLoop("sell", function()
    if not S.autoSell then return end
    local now = os.clock()
    if now - S._lastSell < 1 then return end
    local st = GetUpgradeState()
    if not st then return end
    local held = tonumber(st.held or 0)
    if held < S.sellThreshold then return end
    S._selling = true
    local ok, err = pcall(function()
        local hrp = GetHRP()
        if hrp and (hrp.Position - SELL_POS).Magnitude > 14 then
            TeleportTo(SELL_POS + Vector3.new(0, 0, 2))
            task.wait(0.8)
        end
        SellNow()
    end)
    S._selling = false
    if not ok then warn("[NevaHub NeedleHaystack] sell error: " .. tostring(err)) end
    S._lastSell = now
end, 0.3)
local function fireCollectGem(part)
    if not part or not part.Parent then return end
    local r = Remote("CollectGem")
    if not r then return end
    pcall(function() r:FireServer(part) end)
end
track(function()
    local gemSpawned = Remote("GemSpawned")
    if not gemSpawned then return end
    gemSpawned.OnClientEvent:Connect(function(...)
        local a = { ... }
        local target
        for _, v in ipairs(a) do
            if typeof(v) == "Instance" then target = v; break end
            if typeof(v) == "Vector3" and not target then
                target = { Position = v }
            end
        end
        if target then
            table.insert(S._gemCache.parts or {}, target)
            if S.autoGems and typeof(target) == "Instance" and target:IsA("BasePart") then
                task.spawn(function()
                    fireCollectGem(target)
                end)
            end
        end
    end)
end)
TrackLoop("gems", function()
    if not S.autoGems then return end
    local now = os.clock()
    if now - S._lastGems < 0.8 then return end
    S._lastGems = now
    local hrp = GetHRP()
    if not hrp then return end
    local best, bestDist
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("gem", 1, true)
            and not part:GetFullName():find("GemsClient", 1, true) then
            local d = (part.Position - hrp.Position).Magnitude
            if not bestDist or d < bestDist then
                best, bestDist = part, d
            end
        end
    end
    if best then
        if bestDist <= 25 then
            fireCollectGem(best)
        else
            TeleportTo(best.Position)
        end
    end
end, 0.5)
track(function()
    local ntc = Remote("NeedleTargetChanged")
    if not ntc then return end
    ntc.OnClientEvent:Connect(function(...)
        local a = { ... }
        for _, v in ipairs(a) do
            if typeof(v) == "Vector3" then
                S._needleTarget = v
            elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                S._needleTarget = v.Position
            end
        end
    end)
end)
TrackLoop("needle", function()
    if not S.autoNeedle then return end
    local now = os.clock()
    if now - S._lastNeedle < 1.5 then return end
    S._lastNeedle = now
    local st = GetHayState()
    if not st or st.needleClaimed then return end
    local target = S._needleTarget
    if not target and st.needleRevealed then
        local found
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("needle", 1, true) then
                found = part
                break
            end
        end
        if found then target = found.Position end
    end
    if not target then return end
    local hrp = GetHRP()
    if not hrp then return end
    if (hrp.Position - target).Magnitude > 8 then
        TeleportTo(target + Vector3.new(0, 3, 0))
        return
    end
    Fire("NeedleHandIn")
    Notify("Needle", "Needle found - handed it in!", "Success", 3)
    S._lastNeedle = now + 5
end, 0.6)
local function BuyUpgrade(track, level)
    Fire("BuyUpgrade", track, level)
end
TrackLoop("upgrade", function()
    if not S.autoUpgrade then return end
    local st = GetUpgradeState()
    if not st then return end
    local cash = tonumber(st.cash or 0)
    for track, enabled in pairs(S.upgradeTracks) do
        if enabled then
            local costs = TRACK_COSTS[track]
            if costs then
                local cur = tonumber(st.levels and st.levels[track] or 1)
                local nextLevel = cur + 1
                local cost = costs[nextLevel]
                if cost and cost <= cash and cost <= S.maxUpgradeCost then
                    BuyUpgrade(track, nextLevel)
                    cash = cash - cost
                    task.wait(0.35)
                    st = GetUpgradeState() or st
                    cash = tonumber(st.cash or cash)
                end
            end
        end
    end
end, 1)
local function BuyAllNow()
    task.spawn(function()
        local bought = 0
        for attempt = 1, 40 do
            local st = GetUpgradeState()
            if not st then break end
            local cash = tonumber(st.cash or 0)
            local any = false
            for track, enabled in pairs(S.upgradeTracks) do
                if enabled then
                    local costs = TRACK_COSTS[track]
                    if costs then
                        local cur = tonumber(st.levels and st.levels[track] or 1)
                        local nextLevel = cur + 1
                        local cost = costs[nextLevel]
                        if cost and cost <= cash and cost <= S.maxUpgradeCost then
                            BuyUpgrade(track, nextLevel)
                            cash = cash - cost
                            any = true
                            bought = bought + 1
                            task.wait(0.35)
                        end
                    end
                end
            end
            if not any then break end
            task.wait(0.5)
        end
        Notify("Upgrades", ("Bought %d upgrade level(s)"):format(bought), bought > 0 and "Success" or "Info")
    end)
end
do
    local flyBodyVel, flyBodyGyro
    local flyOn = false
    local function StopFly()
        if flyOn and flyBodyVel then
            pcall(flyBodyVel.Destroy, flyBodyVel)
            pcall(flyBodyGyro.Destroy, flyBodyGyro)
        end
        flyBodyVel, flyBodyGyro = nil, nil
        flyOn = false
    end
    local function StartFly()
        local hrp = GetHRP()
        local h = GetHumanoid()
        if not hrp then return end
        StopFly()
        if h then
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Flying) end)
        end
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = hrp
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        flyBodyGyro.P = 1
        flyBodyGyro.D = 1
        flyBodyGyro.Parent = hrp
        flyOn = true
    end
    TrackLoop("fly", function()
        if S.fly then
            local hrp = GetHRP()
            if not hrp then return end
            if not flyOn then StartFly() end
            local cam = GetCamera()
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            flyBodyVel.Velocity = dir.Magnitude > 0 and (dir.Unit * S.walkSpeed * 3) or Vector3.zero
        elseif flyOn then
            StopFly()
        end
    end)
    TrackLoop("movement", function()
        local h = GetHumanoid()
        if h then
            if h.WalkSpeed ~= S.walkSpeed then h.WalkSpeed = S.walkSpeed end
            if h.JumpPower ~= S.jumpPower then h.JumpPower = S.jumpPower end
        end
    end, 0.3)
    TrackLoop("infjump", function()
        if S.infiniteJump then
            local h = GetHumanoid()
            if h then
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end
    end)
    TrackLoop("noclip", function()
        if not S.noclip then return end
        local c = GetChar()
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end, 0.2)
    TrackLoop("afk", function()
        if S.antiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end, 60)
    TrackLoop("bright", function()
        if S.fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        end
    end, 2)
    HUB._StopFly = StopFly
end
local AutoTab = Window:AddTab({ Title = "Auto", Icon = "solar/bolt-bold" })
local DigSub = AutoTab:AddSection("Auto Dig", "solar/home-bold")
DigSub:AddToggle({
    Title = "Enable Auto Dig",
    Default = false,
    Flag = "dig_enabled",
    Callback = safeCallback(function(v)
        S.autoDig = v
        notifyOn("Auto Dig", v)
        if v then
            S._pickedHay = {}
            S._rainbowNext = 1
        end
    end),
})
DigSub:AddDropdown({
    Title = "Rainbow Farmer",
    Values = { "Off", "Priority", "Only" },
    Default = "Off",
    Flag = "dig_rainbow",
    Callback = function(v)
        S.rainbowMode = v
        S._pickedHay = {}
        S._rainbowNext = 1
    end,
})
DigSub:AddDropdown({
    Title = "Dig Target Mode",
    Values = { "Spiral", "Ring", "Center", "Random" },
    Default = "Spiral",
    Flag = "dig_mode",
    Callback = function(v) S.digMode = v end,
})
DigSub:AddSlider({
    Title = "Dig Radius (Ring mode)",
    Min = 3,
    Max = 16,
    Default = 8,
    Suffix = "studs",
    Flag = "dig_radius",
    Callback = function(v) S.digRadius = v end,
})
DigSub:AddSlider({
    Title = "Dig Speed",
    Min = 1,
    Max = 3,
    Default = 1,
    Suffix = "x",
    Flag = "dig_speed",
    Callback = function(v) S.digSpeed = v end,
})
DigSub:AddButton({
    Title = "Teleport To Hay Pile",
    Callback = safeCallback(function()
        TeleportTo(PILE_CENTER + Vector3.new(4, 2, 4))
        Notify("Teleport", "Moved to the hay pile", "Success")
    end),
})
local SellSub = AutoTab:AddSection("Auto Sell", "solar/home-bold")
SellSub:AddToggle({
    Title = "Enable Auto Sell",
    Default = false,
    Flag = "sell_enabled",
    Callback = safeCallback(function(v)
        S.autoSell = v
        notifyOn("Auto Sell", v)
    end),
})
SellSub:AddSlider({
    Title = "Sell When Holding",
    Min = 5,
    Max = 250,
    Default = 20,
    Suffix = "hay",
    Flag = "sell_threshold",
    Callback = function(v) S.sellThreshold = v end,
})
SellSub:AddButton({
    Title = "Sell Now",
    Callback = safeCallback(function()
        task.spawn(function()
            local hrp = GetHRP()
            if hrp and (hrp.Position - SELL_POS).Magnitude > 14 then
                TeleportTo(SELL_POS + Vector3.new(0, 0, 2))
                task.wait(1.2)
            end
            local n = SellNow()
            Notify("Sell", n > 0 and "Sold!" or "Nothing to sell", n > 0 and "Success" or "Info")
        end)
    end),
})
SellSub:AddButton({
    Title = "Teleport To Sell Cow",
    Callback = safeCallback(function()
        TeleportTo(SELL_POS + Vector3.new(0, 0, 2))
        Notify("Teleport", "Moved to the sell cow", "Success")
    end),
})
local SpecialSub = AutoTab:AddSection("Gems & Needle", "solar/home-bold")
SpecialSub:AddToggle({
    Title = "Auto Collect Gems",
    Default = false,
    Flag = "gems_enabled",
    Callback = safeCallback(function(v)
        S.autoGems = v
        notifyOn("Auto Collect Gems", v)
    end),
})
SpecialSub:AddToggle({
    Title = "Auto Needle (teleport + hand in)",
    Default = false,
    Flag = "needle_enabled",
    Callback = safeCallback(function(v)
        S.autoNeedle = v
        notifyOn("Auto Needle", v)
    end),
})
SpecialSub:AddDropdown({
    Title = "Collect With",
    Values = { "Hand", "TNT", "Pitchfork", "Drone", "Vacuum" },
    Default = "Hand",
    Flag = "collect_with",
    Callback = function(v)
        S.collectWith = v
        EquipTool(v)
    end,
})
local ToolsSub = AutoTab:AddSection("Auto Buy Tools", "solar/home-bold")
ToolsSub:AddToggle({
    Title = "Auto Buy Tools (server-granted)",
    Default = false,
    Flag = "tools_autobuy",
    Callback = safeCallback(function(v)
        S.autoBuyTools = v
        notifyOn("Auto Buy Tools", v)
    end),
})
ToolsSub:AddToggle({
    Title = "Unlock All Tools (Visual)",
    Default = true,
    Flag = "tools_visual",
    Callback = function(v) S.forceUnlock = v end,
})
ToolsSub:AddButton({
    Title = "Buy TNT",
    Callback = safeCallback(function() BuyToolNow("Tnt") end),
})
ToolsSub:AddButton({
    Title = "Buy Pitchfork",
    Callback = safeCallback(function() BuyToolNow("Pitchfork") end),
})
ToolsSub:AddButton({
    Title = "Buy Vacuum",
    Callback = safeCallback(function() BuyToolNow("Vacuum") end),
})
ToolsSub:AddButton({
    Title = "Buy Drone (Gems)",
    Callback = safeCallback(function() BuyToolNow("Drone") end),
})
local toolStatus = ToolsSub:AddLabel({ Text = "Server-owned: none yet" })
TrackLoop("toolstatus", function()
    local owned = {}
    for name, _ in pairs(S._ownedTools) do owned[#owned + 1] = name end
    table.sort(owned)
    local txt = #owned > 0 and table.concat(owned, ", ") or "none yet (auto-buy buys them as soon as affordable)"
    pcall(function() toolStatus:Set("Server-owned: " .. txt) end)
end, 1)
local UpgTab = Window:AddTab({ Title = "Upgrades", Icon = "star" })
local UpgradeMain = UpgTab:AddSection("General", "solar/home-bold")
UpgradeMain:AddToggle({
    Title = "Enable Auto Upgrade",
    Default = false,
    Flag = "upg_enabled",
    Callback = safeCallback(function(v)
        S.autoUpgrade = v
        notifyOn("Auto Upgrade", v)
    end),
})
UpgradeMain:AddSlider({
    Title = "Max Cost Per Level",
    Min = 1,
    Max = 130,
    Default = 100,
    Suffix = "coins",
    Flag = "upg_maxcost",
    Callback = function(v) S.maxUpgradeCost = v end,
})
UpgradeMain:AddButton({
    Title = "Buy All Enabled Now",
    Callback = safeCallback(BuyAllNow),
})
local trackGroups = {
    { Name = "Hand",      Tracks = { "Capacity", "HandHold", "Speed", "Grab" } },
    { Name = "TNT",       Tracks = { "TntLuck", "TntCooldown", "TntPower" } },
    { Name = "Pitchfork", Tracks = { "PitchforkCooldown", "PitchforkHold", "Pitchfork" } },
    { Name = "Drone",     Tracks = { "DroneSpeed", "DroneGrab", "DroneCapacity" } },
    { Name = "Vacuum",    Tracks = { "VacuumPower", "VacuumCooling", "VacuumRuntime" } },
}
local TRACK_DISPLAY = {
    Capacity = "Carry Capacity", HandHold = "Hold", Speed = "Speed", Grab = "Grasp",
    TntLuck = "Lucky Blast", TntCooldown = "TNT Cooldown", TntPower = "TNT Power",
    PitchforkCooldown = "Fork Cooldown", PitchforkHold = "Fork Hold", Pitchfork = "Fork Sweep",
    DroneSpeed = "Drone Speed", DroneGrab = "Drone Grasp", DroneCapacity = "Drone Capacity",
    VacuumPower = "Vacuum Power", VacuumCooling = "Vacuum Cooling", VacuumRuntime = "Vacuum Runtime",
}
local upgSubs = {}
for _, group in ipairs(trackGroups) do
    local sub = UpgTab:AddSection(group.Name, "solar/home-bold")
    upgSubs[group.Name] = sub
    sub:AddToggle({
        Title = "Enable " .. group.Name .. " Track",
        Default = true,
        Flag = "upg_group_" .. string.lower(group.Name),
        Callback = function(v)
            for _, t in ipairs(group.Tracks) do
                S.upgradeTracks[t] = v
            end
        end,
    })
    for _, t in ipairs(group.Tracks) do
        local costs = TRACK_COSTS[t]
        sub:AddToggle({
            Name = TRACK_DISPLAY[t] .. " (" .. (costs and #costs or 1) .. " lvls)",
            Default = true,
            Flag = "upg_" .. t,
            Callback = function(v) S.upgradeTracks[t] = v end,
        })
    end
end
for _, group in ipairs(trackGroups) do
    for _, t in ipairs(group.Tracks) do
        S.upgradeTracks[t] = true
    end
end
local EspTab = Window:AddTab({ Title = "ESP", Icon = "solar/eye-bold" })
local EspMain = EspTab:AddSection("ESP", "solar/home-bold")
EspMain:AddToggle({
    Title = "Master Enable",
    Default = false,
    Flag = "esp_enabled",
    Callback = function(v)
        S.espEnabled = v
        if not v then clearEsp() end
    end,
})
EspMain:AddToggle({
    Title = "Rainbow Hay ESP",
    Default = true,
    Flag = "esp_rainbow",
    Callback = function(v) S.espRainbow = v end,
})
EspMain:AddToggle({
    Title = "Needle ESP",
    Default = true,
    Flag = "esp_needle",
    Callback = function(v) S.espNeedle = v end,
})
EspMain:AddToggle({
    Title = "Gem ESP",
    Default = true,
    Flag = "esp_gems",
    Callback = function(v) S.espGems = v end,
})
local StatsSub = EspTab:AddSection("Stats", "solar/home-bold")
local function addStat(text)
    local lbl = StatsSub:AddLabel({ Text = text })
    table.insert(S._stateLabels, lbl)
    return lbl
end
addStat("Cash: --  |  Holding: --")
addStat("Pile remaining: --  |  Needle: --")
addStat("Rainbow strands: --")
TrackLoop("stats", function()
    local up = GetUpgradeState()
    local hay = GetHayState()
    if not up then return end
    local cash = tostring(up.cash or 0)
    local held = tostring(up.held or 0)
    local rem = hay and tostring(hay.remaining or "?") or "?"
    local needle = "?"
    if hay then
        if hay.needleClaimed then needle = "Claimed"
        elseif hay.needleRevealed then needle = "Revealed!"
        else needle = "Hidden" end
    end
    local rb = #GetRainbowList()
    local ok1, ok2 = pcall(function()
        if S._stateLabels[1] then S._stateLabels[1]:Set("Cash: " .. cash .. "  |  Holding: " .. held) end
        if S._stateLabels[2] then S._stateLabels[2]:Set("Pile remaining: " .. rem .. "  |  Needle: " .. needle) end
        if S._stateLabels[3] then S._stateLabels[3]:Set("Rainbow strands: " .. rb .. " (10x value)") end
    end)
    if not ok1 then S._stateLabels = {} end
end, 1)
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "user" })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
MoveSub:AddSlider({
    Title = "WalkSpeed",
    Min = 8,
    Max = 250,
    Default = 16,
    Suffix = "",
    Flag = "walkspeed",
    Callback = function(v) S.walkSpeed = v end,
})
MoveSub:AddSlider({
    Title = "JumpPower",
    Min = 25,
    Max = 350,
    Default = 50,
    Suffix = "",
    Flag = "jumppower",
    Callback = function(v) S.jumpPower = v end,
})
MoveSub:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Flag = "infjump",
    Callback = function(v) S.infiniteJump = v end,
})
MoveSub:AddToggle({
    Title = "Smooth Fly",
    Default = false,
    Flag = "fly",
    Callback = function(v) S.fly = v end,
})
MoveSub:AddToggle({
    Title = "Noclip",
    Default = false,
    Flag = "noclip",
    Callback = function(v) S.noclip = v end,
})
local UtilSub = PlayerTab:AddSection("Utility", "solar/home-bold")
UtilSub:AddToggle({
    Title = "Anti-AFK",
    Default = false,
    Flag = "antiafk",
    Callback = function(v) S.antiAFK = v end,
})
UtilSub:AddToggle({
    Title = "Fullbright",
    Default = false,
    Flag = "fullbright",
    Callback = function(v) S.fullbright = v end,
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
SettingsSub:AddKeybind({
    Title = "Toggle HUB",
    Default = "RightShift",
    Flag = "toggle_keybind",
    Callback = function()
        pcall(function() Window:Toggle() end)
    end,
})
SettingsSub:AddButton({
    Title = "Unload HUB",
    Callback = safeCallback(function()
        Notify("NevaHub", "Script unloaded", "Info")
        task.wait(0.3)
        pcall(function() Window:Destroy() end)
    end),
})
local function ResyncAll()
    local ok, err = pcall(function()
        S.autoDig        = Window:Get("dig_enabled", false)
        S.rainbowMode    = Window:Get("dig_rainbow", "Off")
        S.digMode        = Window:Get("dig_mode", "Spiral")
        S.digRadius      = Window:Get("dig_radius", 8)
        S.digSpeed       = Window:Get("dig_speed", 1)
        S.autoSell       = Window:Get("sell_enabled", false)
        S.sellThreshold  = Window:Get("sell_threshold", 20)
        S.autoGems       = Window:Get("gems_enabled", false)
        S.autoNeedle     = Window:Get("needle_enabled", false)
        S.collectWith    = Window:Get("collect_with", "Hand")
        S.autoUpgrade    = Window:Get("upg_enabled", false)
        S.maxUpgradeCost = Window:Get("upg_maxcost", 100)
        S.espEnabled     = Window:Get("esp_enabled", false)
        S.espRainbow     = Window:Get("esp_rainbow", true)
        S.espNeedle      = Window:Get("esp_needle", true)
        S.espGems        = Window:Get("esp_gems", true)
        S.walkSpeed      = Window:Get("walkspeed", 16)
        S.jumpPower      = Window:Get("jumppower", 50)
        S.infiniteJump   = Window:Get("infjump", false)
        S.fly            = Window:Get("fly", false)
        S.noclip         = Window:Get("noclip", false)
        S.antiAFK        = Window:Get("antiafk", false)
        S.fullbright     = Window:Get("fullbright", false)
        if not S.espEnabled then clearEsp() end
    end)
    if not ok then warn("[NevaHub NeedleHaystack] ResyncAll: " .. tostring(err)) end
end
function HUB.Unload()
    HUB.dead = true
    for id in pairs(HUB.loops) do HUB.loops[id] = nil end
    for _, c in ipairs(HUB.conns) do
        pcall(c.Disconnect, c)
    end
    HUB.conns = {}
    clearEsp()
    if HUB._StopFly then pcall(HUB._StopFly) end
    local sg = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("OxideNeedleHaystackUI")
    if sg then pcall(sg.Destroy, sg) end
    if HAS_CONFIG then
        pcall(function() Library.SaveConfig(CONFIG_NAME) end)
    end
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
