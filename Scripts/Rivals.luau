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
    SubTitle = "Rivals",
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
    local prev = _G.OxideRivals
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideRivals = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local CONFIG_NAME = "rivals"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then table.insert(dropdownResync, function() applyFn(handle:Get()) end) end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
end
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local HttpService       = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local hasDrawing = (typeof(Drawing) == "table") or (Drawing ~= nil and pcall(function() return Drawing.new end))
local function Notify(title, content, kind, dur)
    Fluent:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
end
local reps = ReplicatedStorage
local U, GU, EL, GunMod
local UseItem
local enumStartShooting
do
    local ok, u = pcall(require, reps.Modules.Utility)
    if ok then U = u end
    local ok2, gu = pcall(require, reps.Modules.GameplayUtility)
    if ok2 then GU = gu end
    local ok3, el = pcall(require, reps.Modules.EnumLibrary)
    if ok3 then EL = el end
    local ok4, gun = pcall(require, LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
    if ok4 then GunMod = gun end
    local fighter = reps.Remotes and reps.Remotes.Replication and reps.Remotes.Replication.Fighter
    if fighter then UseItem = fighter:FindFirstChild("UseItem") end
    if EL and type(EL.ToEnum) == "function" then
        local ok5, v = pcall(EL.ToEnum, EL, "StartShooting")
        if ok5 then enumStartShooting = v end
    end
end
local function newDrawing(class, props)
    if not hasDrawing then return nil end
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do pcall(function() d[k] = v end) end
    return trackDrawing(d)
end
local rage = {
    enabled = false,
    fireDelayMs = 1,
    weaponSlot = "Melee",
    hitPart = "Head",
    maxDist = 500,
    teamCheck = true,
    deflectCheck = true,
    desync = true,
    knifeAdjust = true,
    randomOffset = true,
    priority = "Lowest HP",
    autoShoot = false,
    prediction = false,
    bulletSpeed = 350,
    burst = 1,
    lowHPPrio = false,
    lowHPThreshold = 60,
    wallCheck = false,
}
local noSpreadEnabled = false
local origIsFullyAiming
local function ApplyNoSpread(on)
    if on then
        if GunMod and type(GunMod.IsFullyAiming) == "function" then
            if not origIsFullyAiming then origIsFullyAiming = GunMod.IsFullyAiming end
            GunMod.IsFullyAiming = function() return true end
        end
    else
        if origIsFullyAiming then
            pcall(function() GunMod.IsFullyAiming = origIsFullyAiming end)
            origIsFullyAiming = nil
        end
    end
end
local RageTab = Window:AddTab({ Title = "Rage", Icon = "solar/bolt-bold" })
local NoSpreadSub = RageTab:AddSection("No Spread", "solar/home-bold")
NoSpreadSub:AddDivider()
NoSpreadSub:AddToggle({
    Title = "No Spread", Default = false, Flag = "rv_nospread",
    Callback = function(v)
        noSpreadEnabled = v
        ApplyNoSpread(v)
        Notify("Rage", v and "No Spread ON" or "No Spread OFF", v and "Success" or "Error")
    end,
})
NoSpreadSub:AddParagraph({
    Title = "Note",
    Text = "Forces Gun.IsFullyAiming to always return true for perfect accuracy.",
})
local function CloneSvc(svc)
    if type(cloneref) == "function" then
        local ok, c = pcall(cloneref, svc)
        if ok and c then return c end
    end
    return svc
end
local repS  = CloneSvc(ReplicatedStorage)
local plrsR = CloneSvc(Players)
local runSR = CloneSvc(RunService)
local wsR   = CloneSvc(Workspace)
local uisR  = CloneSvc(UserInputService)
local FighterController, SpectateController
local RageUtil, RageEnum
local UseItemR
local rageReady = false
do
    local ok1, fc = pcall(require, LocalPlayer.PlayerScripts.Controllers.FighterController)
    if ok1 then FighterController = fc end
    local ok2, sc = pcall(require, LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
    if ok2 then SpectateController = sc end
    local ok3, u = pcall(require, repS.Modules.Utility)
    if ok3 then RageUtil = u end
    local ok4, el = pcall(require, repS.Modules.EnumLibrary)
    if ok4 then RageEnum = el end
    local fighter = repS.Remotes and repS.Remotes.Replication and repS.Remotes.Replication.Fighter
    if fighter then UseItemR = fighter:FindFirstChild("UseItem") end
    rageReady = FighterController ~= nil and SpectateController ~= nil
        and RageUtil ~= nil and RageEnum ~= nil and UseItemR ~= nil
end
local SLOT_NUM = { Primary = 1, Secondary = 2, Melee = 3 }
local equipLoopAlive = true
local equipThread = task.spawn(function()
    while equipLoopAlive do
        task.wait(1)
        if rage.enabled and FighterController then
            local lf = FighterController.LocalFighter
            if lf then
                pcall(function() lf:EquipItem(SLOT_NUM[rage.weaponSlot] or 3) end)
            end
        end
    end
end)
local deflecting = {}
local playerRemoveConn = plrsR.PlayerRemoving:Connect(function(player)
    deflecting[player] = nil
end)
table.insert(HUB.conns, playerRemoveConn)
local function UpdateDeflection()
    if not FighterController or not FighterController.Objects then return end
    for _, fighterObj in FighterController.Objects do
        local player = fighterObj.Player
        if player then
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                deflecting[player] = false
            else
                local equipped = fighterObj.EquippedItem
                local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
                local isDeflecting = false
                if isKatana then
                    isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
                end
                deflecting[player] = isDeflecting
            end
        end
    end
end
local function IsEnemyR(player)
    if player == LocalPlayer then return false end
    if not rage.teamCheck then return true end
    if SpectateController and SpectateController.CurrentDuelSubject then
        local duel = SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(LocalPlayer)
        local localTeam = localDueler and localDueler:Get("TeamID") or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in duel.Duelers do
                if dueler.Player == player then
                    local team = dueler:Get("TeamID")
                    return team ~= localTeam
                end
            end
        end
    end
    local pTeam = player:GetAttribute("TeamID")
    local lTeam = LocalPlayer:GetAttribute("TeamID")
    if pTeam and lTeam then
        return pTeam ~= lTeam
    end
    return true
end
local function GetClosestTargetR()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil, nil end
    local closestPlayer, closestRoot, closestHead
    local closestDist = rage.maxDist
    local lowHPP, lowHPRoot, lowHPHead, lowHPHp = nil, nil, nil, math.huge
    for _, player in plrsR:GetPlayers() do
        if IsEnemyR(player) then
            local pChar = player.Character
            if pChar then
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                local pHead = pChar:FindFirstChild("Head")
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                if pRoot and pHead and pHum and pHum.Health > 0 then
                    local dist = (myRoot.Position - pRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                        closestRoot = pRoot
                        closestHead = pHead
                    end
                    if rage.lowHPPrio or rage.priority == "Lowest HP" then
                        if pHum.Health < lowHPHp then
                            lowHPHp = pHum.Health
                            lowHPP = player
                            lowHPRoot = pRoot
                            lowHPHead = pHead
                        end
                    end
                end
            end
        end
    end
    if rage.priority == "Lowest HP" and lowHPP then
        if rage.lowHPPrio then
            if lowHPHp < rage.lowHPThreshold then
                return lowHPP, lowHPRoot, lowHPHead
            end
        else
            return lowHPP, lowHPRoot, lowHPHead
        end
    end
    return closestPlayer, closestRoot, closestHead
end
local function HasKnifeViewModel(targetPlayer)
    if not targetPlayer then return false end
    local viewModels = wsR:FindFirstChild("ViewModels")
    if not viewModels then return false end
    local targetName = targetPlayer.Name
    for _, model in viewModels:GetChildren() do
        if model:IsA("Model")
            and string.find(model.Name, targetName, 1, true)
            and string.find(model.Name, "Knife", 1, true) then
            return true
        end
    end
    return false
end
local lastFire = 0
local function RageFireDelay()
    return math.max(rage.fireDelayMs, 0.5) / 1000
end
local rageConn = runSR.Heartbeat:Connect(function()
    if HUB.dead then return end
    if not rage.enabled then
        return
    end
    UpdateDeflection()
    local targetPlayer, targetRoot, targetHead = GetClosestTargetR()
    local desyncCF = nil
    if rage.desync and targetRoot and targetHead then
        local desyncPos
        if rage.knifeAdjust and HasKnifeViewModel(targetPlayer) then
            desyncPos = (targetRoot.CFrame * CFrame.new(0, 6, 0)).Position
        else
            desyncPos = (targetRoot.CFrame * CFrame.new(0, 1, 2)).Position
        end
        desyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
    end
    if rage.desync and desyncCF and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local oldCF = myRoot.CFrame
            local oldVel = myRoot.Velocity
            local oldRotVel = myRoot.RotVelocity
            myRoot.CFrame = desyncCF
            runSR:BindToRenderStep("OxideRageRestore", 101, function()
                if myRoot and myRoot.Parent then
                    myRoot.CFrame = oldCF
                    myRoot.Velocity = oldVel
                    myRoot.RotVelocity = oldRotVel
                end
                runSR:UnbindFromRenderStep("OxideRageRestore")
            end)
        end
    end
    if not targetPlayer or not targetHead or not targetRoot then return end
    if rage.deflectCheck and deflecting[targetPlayer] then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not FighterController or not FighterController.LocalFighter then return end
    local item = FighterController.LocalFighter.EquippedItem
    if not item then return end
    if rage.wallCheck and targetHead then
        local myHead = LocalPlayer.Character:FindFirstChild("Head")
        if myHead then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
            local dir = targetHead.Position - myHead.Position
            local result = workspace:Raycast(myHead.Position, dir, rayParams)
            if result and result.Instance then
                local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                if hitChar ~= targetPlayer.Character then return end
            end
        end
    end
    if not rage.autoShoot then
        local holding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if not holding then return end
    end
    local hitPart = targetHead
    if rage.hitPart == "Torso" then
        hitPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso") or targetHead
    elseif rage.hitPart == "Random" then
        local roll = math.random(1, 3)
        if roll == 1 then
            hitPart = targetHead
        else
            hitPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso") or targetHead
        end
    end
    local burstCount = math.max(1, math.floor(rage.burst or 1))
    for _ = 1, burstCount do
        if tick() - lastFire < RageFireDelay() then return end
        lastFire = tick()
        local originPos = desyncCF and desyncCF.Position or targetRoot.Position
        local targetPos = hitPart.Position
        if rage.prediction then
            local pRootVel = targetRoot.Velocity
            if pRootVel and pRootVel.Magnitude > 0.5 then
                local distToT = (originPos - targetPos).Magnitude
                local travelTime = distToT / math.max(rage.bulletSpeed, 50)
                targetPos = targetPos + pRootVel * travelTime
            end
        end
        local aimCF = CFrame.lookAt(originPos, targetPos)
        local targetCF = hitPart.CFrame
        local aimedPos = targetPos
        if rage.randomOffset then
            aimedPos = targetPos + Vector3.new(
                (math.random() - 0.5) * 0.1,
                (math.random() - 0.5) * 0.1,
                (math.random() - 0.5) * 0.1
            )
        end
        local objSpaceHeadOffset = hitPart.CFrame:ToObjectSpace(CFrame.new(aimedPos))
        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = RageUtil:EncodeCFrame(aimCF),
            [utf8.char(1)] = RageUtil:EncodeCFrame(targetCF),
            [utf8.char(2)] = hitPart,
            [utf8.char(3)] = RageUtil:EncodeCFrame(objSpaceHeadOffset),
        }
        local okFire, errFire = pcall(function()
            UseItemR:FireServer(
                item:Get("ObjectID"),
                RageEnum:ToEnum("StartShooting"),
                cameradata,
                nil
            )
        end)
        if not okFire then return end
    end
end)
table.insert(HUB.conns, rageConn)
local RageSub = RageTab:AddSection("Ragebot", "solar/home-bold")
RageSub:AddDivider()
RageSub:AddToggle({
    Title = "Ragebot", Default = false, Flag = "rv_rage",
    Callback = function(v)
        rage.enabled = v
        if v and not rageReady then
            Notify("Rage", "Controllers/modules not found — ragebot unavailable", "Error", 3.5)
        else
            Notify("Rage", v and "Ragebot ON" or "Ragebot OFF", v and "Success" or "Error")
        end
    end,
})
local applyWeaponSlot = function(v) rage.weaponSlot = v end
local weaponSlotDropdown = RageSub:AddDropdown({
    Title = "Weapon Slot", Values = { "Primary", "Secondary", "Melee" }, Default = "Melee",
    MaxVisible = 3, Flag = "rv_rage_slot", Callback = applyWeaponSlot,
})
registerResync(weaponSlotDropdown, applyWeaponSlot)
RageSub:AddSlider({
    Title = "Fire Rate", Min = 1, Max = 50, Default = 1, Suffix = "ms", Flag = "rv_rage_firerate",
    Callback = function(v) rage.fireDelayMs = v end,
})
RageSub:AddSlider({
    Title = "Max Distance", Min = 50, Max = 2000, Default = 500, Suffix = "", Flag = "rv_rage_dist",
    Callback = function(v) rage.maxDist = v end,
})
local applyHitPart = function(v) rage.hitPart = v end
local hitPartDropdown = RageSub:AddDropdown({
    Title = "Hit Part", Values = { "Head", "Torso", "Random" }, Default = "Head",
    MaxVisible = 3, Flag = "rv_rage_hitpart", Callback = applyHitPart,
})
registerResync(hitPartDropdown, applyHitPart)
local applyPriority = function(v) rage.priority = v end
local priorityDropdown = RageSub:AddDropdown({
    Title = "Target Priority", Values = { "Lowest HP", "Closest" }, Default = "Lowest HP",
    MaxVisible = 2, Flag = "rv_rage_priority", Callback = applyPriority,
})
registerResync(priorityDropdown, applyPriority)
RageSub:AddToggle({
    Title = "Team Check", Default = true, Flag = "rv_rage_team",
    Callback = function(v) rage.teamCheck = v end,
})
RageSub:AddToggle({
    Title = "Deflect Check", Default = true, Flag = "rv_rage_deflect",
    Callback = function(v) rage.deflectCheck = v end,
})
RageSub:AddToggle({
    Title = "Random Offset", Default = true, Flag = "rv_rage_offset",
    Callback = function(v) rage.randomOffset = v end,
})
RageSub:AddToggle({
    Title = "Auto Shoot", Default = false, Flag = "rv_rage_autoshoot",
    Callback = function(v) rage.autoShoot = v end,
})
RageSub:AddToggle({
    Title = "Wall Check", Default = false, Flag = "rv_rage_wallcheck",
    Callback = function(v) rage.wallCheck = v end,
})
RageSub:AddSlider({
    Title = "Burst Shots", Min = 1, Max = 10, Default = 1, Suffix = "", Flag = "rv_rage_burst",
    Callback = function(v) rage.burst = v end,
})
RageSub:AddToggle({
    Title = "Prediction", Default = false, Flag = "rv_rage_pred",
    Callback = function(v) rage.prediction = v end,
})
RageSub:AddSlider({
    Title = "Bullet Speed", Min = 100, Max = 1500, Default = 350, Suffix = "", Flag = "rv_rage_bulletspeed",
    Callback = function(v) rage.bulletSpeed = v end,
})
RageSub:AddToggle({
    Title = "Low HP Only (below threshold)", Default = false, Flag = "rv_rage_lowhp",
    Callback = function(v) rage.lowHPPrio = v end,
})
RageSub:AddSlider({
    Title = "Low HP Threshold", Min = 10, Max = 100, Default = 60, Suffix = "", Flag = "rv_rage_lowhpthresh",
    Callback = function(v) rage.lowHPThreshold = v end,
})
local DesyncSub = RageTab:AddSection("Desync", "solar/home-bold")
DesyncSub:AddDivider()
DesyncSub:AddToggle({
    Title = "Desync", Default = true, Flag = "rv_rage_desync",
    Callback = function(v) rage.desync = v end,
})
DesyncSub:AddToggle({
    Title = "Knife Adjust", Default = true, Flag = "rv_rage_knife",
    Callback = function(v) rage.knifeAdjust = v end,
})
DesyncSub:AddParagraph({
    Title = "Note",
    Text = "Desync repositions your character for the exact frame of the shot. If it feels too aggressive, turn it off and the ragebot will fire from your normal position instead.",
})
local rapidHitEnabled = false
local RapidItemLibrary
local rapidScanThread
do
    local ok, il = pcall(require, repS.Modules.ItemLibrary)
    if ok then RapidItemLibrary = il end
end
local function ScanCooldowns(tbl)
    if type(tbl) ~= "table" then return end
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if v.ShootCooldown ~= nil then v.ShootCooldown = 0.000000000000000001 end
            if v.BurstCooldown ~= nil then v.BurstCooldown = 0.000000000000000001 end
            if v.AttackCooldown ~= nil then v.AttackCooldown = 0.000000000000000001 end
            if v.HeavyAttackCooldown ~= nil then v.HeavyAttackCooldown = 0.000000000000000001 end
            ScanCooldowns(v)
        end
    end
end
local function RapidHitLoop()
    while rapidHitEnabled do
        task.wait(1)
        if RapidItemLibrary then
            pcall(function() ScanCooldowns(RapidItemLibrary) end)
        end
    end
end
local RapidSub = RageTab:AddSection("Rapid Hit", "solar/home-bold")
RapidSub:AddDivider()
RapidSub:AddToggle({
    Title = "Rapid Hit", Default = false, Flag = "rv_rapid",
    Callback = function(v)
        rapidHitEnabled = v
        if v then
            if not RapidItemLibrary then
                Notify("Rage", "ItemLibrary not found — rapid hit unavailable", "Error", 3.5)
            else
                pcall(function() ScanCooldowns(RapidItemLibrary) end)
                rapidScanThread = task.spawn(RapidHitLoop)
                Notify("Rage", "Rapid Hit ON — all cooldowns zeroed", "Success")
            end
        else
            Notify("Rage", "Rapid Hit OFF", "Error")
        end
    end,
})
RapidSub:AddParagraph({
    Title = "Note",
    Text = "Re-scans every second so freshly-loaded items get patched too. Works together with the ragebot for maximum fire rate.",
})
local VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
local esp = {
    enabled = true,
    box = false, boxStyle = "Corner", boxThickness = 1,
    name = false, distance = false, health = false,
    hpPercent = false, weapon = false,
    skeleton = false, skeletonColor = Color3.fromRGB(120, 255, 120),
    visibleCheck = false,
    tracer = false, tracerOrigin = "Bottom",
    teamCheck = false, rainbow = false,
    maxDistance = 1000, textSize = 13,
    color = Color3.fromRGB(255, 80, 80),
    nameColor = Color3.fromRGB(255, 255, 255),
}
local playerObjects = {}
local rayParamsESP
pcall(function()
    rayParamsESP = RaycastParams.new()
    rayParamsESP.FilterType = Enum.RaycastFilterType.Exclude
    rayParamsESP.IgnoreWater = true
end)
local function GetPlayerBox(plr)
    local o = playerObjects[plr]
    if o then return o end
    o = {}
    if hasDrawing then
        o.frame   = newDrawing("Square", { Thickness = 1, Filled = false, Visible = false })
        o.outline = newDrawing("Square", { Thickness = 3, Filled = false, Color = Color3.new(0, 0, 0), Visible = false })
        o.fill    = newDrawing("Square", { Thickness = 1, Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.4, Visible = false })
        o.name    = newDrawing("Text", { Color = Color3.fromRGB(255, 255, 255), Size = 13, Outline = true, Centre = true, Visible = false })
        o.dist    = newDrawing("Text", { Color = Color3.fromRGB(255, 255, 255), Size = 11, Outline = true, Centre = true, Visible = false })
        o.tracer  = newDrawing("Line", { Thickness = 1.2, Visible = false })
        o.hpBack  = newDrawing("Line", { Thickness = 3, Visible = false, Color = Color3.new(0, 0, 0) })
        o.hp      = newDrawing("Line", { Thickness = 2, Visible = false })
        o.hpText  = newDrawing("Text", { Color = Color3.fromRGB(255, 255, 255), Size = 11, Outline = true, Centre = true, Visible = false })
        o.weapon  = newDrawing("Text", { Color = Color3.fromRGB(255, 220, 120), Size = 10, Outline = true, Centre = true, Visible = false })
        o.corners = {}
        for i = 1, 8 do o.corners[i] = newDrawing("Line", { Thickness = 1, Visible = false, Color = Color3.new(1, 1, 1) }) end
        o.skel = {}
        for i = 1, 14 do o.skel[i] = newDrawing("Line", { Thickness = 1.2, Visible = false }) end
    end
    playerObjects[plr] = o
    return o
end
local R15_BONES = {
    { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local R6_BONES = {
    { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
    { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}
local function GetSkeletonPairs(char)
    if char:FindFirstChild("UpperTorso") then return R15_BONES end
    return R6_BONES
end
local function GetEquippedWeaponName(plr)
    if not FighterController or not FighterController.Objects then return nil end
    for _, fighterObj in FighterController.Objects do
        if fighterObj.Player == plr and fighterObj.EquippedItem then
            local name = fighterObj.EquippedItem.Name or fighterObj.EquippedItem:Get("Name")
            if name and name ~= "" then return name end
        end
    end
    return nil
end
local function IsPlayerVisible(char, myHeadPos, camDir)
    if not char then return false end
    if not rayParamsESP then return true end
    local targetHead = char:FindFirstChild("Head")
    local targetPart = targetHead or char:FindFirstChild("HumanoidRootPart")
    if not targetPart then return true end
    local origin = myHeadPos or Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local dist = dir.Magnitude
    if dist < 1 then return true end
    dir = dir.Unit
    pcall(function() rayParamsESP.FilterDescendantsInstances = { LocalPlayer.Character } end)
    local result = workspace:Raycast(origin, dir * dist, rayParamsESP)
    if not result then return true end
    if result.Instance then
        local m = result.Instance:FindFirstAncestorOfClass("Model")
        if m == char then return true end
    end
    return false
end
local function GetBox2D(char)
    if not char then return nil end
    local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
    if not ok or not cf then return nil end
    if size and size.Magnitude < 1 then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        cf = hrp.CFrame
        size = Vector3.new(3, 6, 2)
    end
    if not size then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOn = false
    for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
        local corner = (cf * CFrame.new(size.X / 2 * x, size.Y / 2 * y, size.Z / 2 * z)).Position
        local sp = Camera:WorldToViewportPoint(corner)
        if sp.Z > 0 then
            anyOn = true
            minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
            maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
        end
    end end end
    if minX == math.huge or not anyOn then return nil end
    return minX, minY, maxX, maxY
end
local function DrawCornerBox(o, minX, minY, maxX, maxY, color, thick)
    local len = math.max(6, (maxX - minX) * 0.25)
    local pts = {
        { minX, minY, minX + len, minY }, { maxX - len, minY, maxX, minY },
        { minX, maxY, minX + len, maxY }, { maxX - len, maxY, maxX, maxY },
        { minX, minY, minX, minY + len }, { minX, maxY - len, minX, maxY },
        { maxX, minY, maxX, minY + len }, { maxX, maxY - len, maxX, maxY },
    }
    for i, p in ipairs(pts) do
        local l = o.corners[i]
        if l then
            l.Visible = true
            l.Color = color
            l.Thickness = thick
            l.From = Vector2.new(p[1], p[2])
            l.To = Vector2.new(p[3], p[4])
        end
    end
end
local espRenderConn = RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    local enabled = esp.enabled and hasDrawing
    for plr, o in pairs(playerObjects) do
        for _, d in ipairs({ o.frame, o.outline, o.fill, o.name, o.dist, o.tracer, o.hpBack, o.hp, o.hpText, o.weapon }) do
            pcall(function() if d then d.Visible = false end end)
        end
        for _, l in ipairs(o.corners) do pcall(function() if l then l.Visible = false end end) end
        for _, l in ipairs(o.skel) do pcall(function() if l then l.Visible = false end end) end
    end
    if not enabled then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position or Camera.CFrame.Position
    local rainbow = esp.rainbow and Color3.fromHSV((tick() % 5) / 5, 0.85, 1) or nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not (esp.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local dist = hrp and (hrp.Position - myPos).Magnitude or 0
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        local o = GetPlayerBox(plr)
                        local minX, minY, maxX, maxY = GetBox2D(char)
                        if minX then
                            local color = rainbow or esp.color
                            if esp.visibleCheck then
                                local okVis, visible = pcall(function()
                                    local myChar = LocalPlayer.Character
                                    local myHead = myChar and myChar:FindFirstChild("Head")
                                    return IsPlayerVisible(char, myHead and myHead.Position or nil)
                                end)
                                if okVis and not visible then color = Color3.fromRGB(255, 60, 60) end
                            end
                            if esp.box then
                                if o.outline then o.outline.Visible = true; o.outline.Transparency = 0.6; o.outline.Color = color; o.outline.Thickness = esp.boxThickness + 2; o.outline.From = Vector2.new(minX - 1, minY - 1); o.outline.To = Vector2.new(maxX + 1, maxY + 1) end
                                if esp.boxStyle == "Corner" then
                                    DrawCornerBox(o, minX, minY, maxX, maxY, color, esp.boxThickness)
                                else
                                    if o.frame then o.frame.Visible = true; o.frame.Color = color; o.frame.Thickness = esp.boxThickness; o.frame.From = Vector2.new(minX, minY); o.frame.To = Vector2.new(maxX, maxY) end
                                end
                            end
                            if esp.health and o.hp and o.hpBack then
                                local h = hum.Health / hum.MaxHealth
                                o.hpBack.Visible = true
                                o.hpBack.From = Vector2.new(minX - 6, minY - 2)
                                o.hpBack.To = Vector2.new(minX - 6, maxY + 2)
                                o.hp.Visible = true
                                o.hp.Color = h > 0.5 and Color3.fromRGB(90, 220, 90) or (h > 0.25 and Color3.fromRGB(240, 200, 60) or Color3.fromRGB(230, 60, 60))
                                o.hp.From = Vector2.new(minX - 6, maxY + 2)
                                o.hp.To = Vector2.new(minX - 6, minY + 2 - (maxY - minY + 4) * math.clamp(h, 0, 1))
                            end
                            if esp.hpPercent and o.hpText then
                                o.hpText.Visible = true
                                o.hpText.Size = esp.textSize - 2
                                o.hpText.Text = tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth))
                                o.hpText.Position = Vector2.new(minX - 6, maxY + 2)
                            end
                            if esp.weapon and o.weapon then
                                local okW, wName = pcall(GetEquippedWeaponName, plr)
                                if okW and wName then
                                    o.weapon.Visible = true
                                    o.weapon.Size = esp.textSize - 3
                                    o.weapon.Color = rainbow or Color3.fromRGB(255, 220, 120)
                                    o.weapon.Text = wName
                                    o.weapon.Position = Vector2.new((minX + maxX) / 2, maxY + 14)
                                end
                            end
                            if esp.name and o.name then
                                o.name.Visible = true
                                o.name.Color = rainbow or esp.nameColor
                                o.name.Size = esp.textSize
                                o.name.Text = plr.DisplayName
                                o.name.Position = Vector2.new((minX + maxX) / 2, minY - 14)
                            end
                            if esp.distance and o.dist then
                                o.dist.Visible = true
                                o.dist.Size = esp.textSize - 2
                                o.dist.Text = tostring(math.floor(dist / 3.28)) .. "m"
                                o.dist.Position = Vector2.new((minX + maxX) / 2, maxY + 2)
                            end
                            if esp.tracer and o.tracer then
                                pcall(function()
                                    o.tracer.Visible = true
                                    o.tracer.Color = rainbow or esp.color
                                    local sp = Camera:WorldToViewportPoint((hrp or char):GetPivot().Position)
                                    if sp.Z > 0 then
                                        local origin = center
                                        if esp.tracerOrigin == "Bottom" then origin = Vector2.new(center.X, Camera.ViewportSize.Y)
                                        elseif esp.tracerOrigin == "Top" then origin = Vector2.new(center.X, 0)
                                        elseif esp.tracerOrigin == "Mouse" then origin = UserInputService:GetMouseLocation() end
                                        o.tracer.From = origin
                                        o.tracer.To = Vector2.new(sp.X, sp.Y)
                                    end
                                end)
                            end
                            if esp.skeleton and hrp then
                                pcall(function()
                                    local pairs = GetSkeletonPairs(char)
                                    local skelColor = rainbow or esp.skeletonColor or Color3.fromRGB(120, 255, 120)
                                    for i, bonePair in ipairs(pairs) do
                                        local a = char:FindFirstChild(bonePair[1], true)
                                        local b = char:FindFirstChild(bonePair[2], true)
                                        if a and not a:IsA("BasePart") then a = nil end
                                        if b and not b:IsA("BasePart") then b = nil end
                                        if a and b then
                                            local pa, pb = a.Position, b.Position
                                            local l = o.skel[i]
                                            if l then
                                                local okA, sa, oa = pcall(function() return Camera:WorldToViewportPoint(pa) end)
                                                local okB, sb, ob = pcall(function() return Camera:WorldToViewportPoint(pb) end)
                                                if okA and okB and sa.Z > 0 and sb.Z > 0 then
                                                    l.Visible = true
                                                    l.Color = skelColor
                                                    l.From = Vector2.new(sa.X, sa.Y)
                                                    l.To = Vector2.new(sb.X, sb.Y)
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)
table.insert(HUB.conns, espRenderConn)
local EspSub = VisualsTab:AddSection("ESP", "solar/home-bold")
EspSub:AddToggle({ Title = "Master Enable", Default = true, Flag = "rv_esp", Callback = function(v) esp.enabled = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "2D Box", Default = false, Flag = "rv_espbox", Callback = function(v) esp.box = v end })
local applyBoxStyle = function(v) esp.boxStyle = v end
local boxStyleDropdown = EspSub:AddDropdown({
    Title = "Box Style", Values = { "Corner", "Full" }, Default = "Corner", MaxVisible = 2,
    Flag = "rv_espboxstyle", Callback = applyBoxStyle,
})
registerResync(boxStyleDropdown, applyBoxStyle)
EspSub:AddSlider({ Title = "Box Thickness", Min = 1, Max = 5, Default = 1, Suffix = "", Flag = "rv_espthick", Callback = function(v) esp.boxThickness = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Name", Default = false, Flag = "rv_espname", Callback = function(v) esp.name = v end })
EspSub:AddToggle({ Title = "Distance", Default = false, Flag = "rv_espdist", Callback = function(v) esp.distance = v end })
EspSub:AddToggle({ Title = "Health Bar", Default = false, Flag = "rv_esphp", Callback = function(v) esp.health = v end })
EspSub:AddToggle({ Title = "HP Percent", Default = false, Flag = "rv_esphppct", Callback = function(v) esp.hpPercent = v end })
EspSub:AddToggle({ Title = "Weapon Name", Default = false, Flag = "rv_espweapon", Callback = function(v) esp.weapon = v end })
EspSub:AddSlider({ Title = "Text Size", Min = 10, Max = 20, Default = 13, Suffix = "", Flag = "rv_esptextsize", Callback = function(v) esp.textSize = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Skeleton", Default = false, Flag = "rv_espskel", Callback = function(v) esp.skeleton = v end })
EspSub:AddColorPicker({ Name = "Skeleton Color", Default = esp.skeletonColor, Flag = "rv_espskelcolor", Callback = function(c) esp.skeletonColor = c end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Tracers", Default = false, Flag = "rv_esptracer", Callback = function(v) esp.tracer = v end })
EspSub:AddToggle({ Title = "Visibility Check", Default = false, Flag = "rv_espvisible", Callback = function(v) esp.visibleCheck = v end })
local applyTracerOrigin = function(v) esp.tracerOrigin = v end
local tracerOriginDropdown = EspSub:AddDropdown({
    Title = "Tracer Origin", Values = { "Bottom", "Center", "Top", "Mouse" }, Default = "Bottom",
    MaxVisible = 4, Flag = "rv_esptracerorigin", Callback = applyTracerOrigin,
})
registerResync(tracerOriginDropdown, applyTracerOrigin)
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Team Check", Default = false, Flag = "rv_espteam", Callback = function(v) esp.teamCheck = v end })
EspSub:AddToggle({ Title = "Rainbow", Default = false, Flag = "rv_esprb", Callback = function(v) esp.rainbow = v end })
EspSub:AddSlider({ Title = "Max Distance", Min = 0, Max = 5000, Default = 1000, Suffix = "m", Flag = "rv_espmaxdist", Callback = function(v) esp.maxDistance = v end })
EspSub:AddDivider()
EspSub:AddColorPicker({ Name = "Box Color", Default = esp.color, Flag = "rv_espcolor", Callback = function(c) esp.color = c end })
EspSub:AddColorPicker({ Name = "Name Color", Default = esp.nameColor, Flag = "rv_espnamecolor", Callback = function(c) esp.nameColor = c end })
local WorldSub = VisualsTab:AddSection("World", "solar/home-bold")
local savedLighting = { GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient }
local okOutdoor, outdoorAmbient = pcall(function() return Lighting.OutdoorAmbient end)
local okExp, exposureComp = pcall(function() return Lighting.ExposureCompensation end)
if okOutdoor then savedLighting.OutdoorAmbient = outdoorAmbient end
if okExp then savedLighting.ExposureCompensation = exposureComp end
local fullbright = false
WorldSub:AddToggle({
    Title = "Fullbright", Default = false, Flag = "rv_fullbright",
    Callback = function(v)
        fullbright = v
        Lighting.GlobalShadows = not v
        Lighting.Ambient = v and Color3.new(1, 1, 1) or savedLighting.Ambient
        pcall(function() Lighting.OutdoorAmbient = v and Color3.new(1, 1, 1) or savedLighting.OutdoorAmbient end)
        pcall(function() Lighting.ExposureCompensation = v and 0.6 or savedLighting.ExposureCompensation end)
    end,
})
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
local wsEnabled, wsValue = false, 16
local jpEnabled, jpValue = false, 50
local infJump = false
local flyEnabled, flySpeed = false, 60
local noclipEnabled = false
MoveSub:AddDivider()
MoveSub:AddToggle({
    Title = "WalkSpeed", Default = false, Flag = "rv_ws",
    Callback = function(v)
        wsEnabled = v
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and wsValue or 16 end
    end,
})
MoveSub:AddSlider({
    Title = "WalkSpeed Value", Min = 16, Max = 200, Default = 16, Suffix = "", Flag = "rv_ws_value",
    Callback = function(v)
        wsValue = v
        if wsEnabled then local c = LocalPlayer.Character; local hum = c and c:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end
    end,
})
MoveSub:AddToggle({
    Title = "JumpPower", Default = false, Flag = "rv_jp",
    Callback = function(v)
        jpEnabled = v
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v and jpValue or 50 end
    end,
})
MoveSub:AddSlider({
    Title = "JumpPower Value", Min = 50, Max = 300, Default = 50, Suffix = "", Flag = "rv_jp_value",
    Callback = function(v)
        jpValue = v
        if jpEnabled then local c = LocalPlayer.Character; local hum = c and c:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = v end end
    end,
})
MoveSub:AddToggle({
    Title = "Infinite Jump", Default = false, Flag = "rv_infjump",
    Callback = function(v) infJump = v end,
})
MoveSub:AddDivider()
MoveSub:AddToggle({
    Title = "Fly", Default = false, Flag = "rv_fly",
    Callback = function(v) flyEnabled = v end,
})
MoveSub:AddSlider({
    Title = "Fly Speed", Min = 10, Max = 300, Default = 60, Suffix = "", Flag = "rv_fly_speed",
    Callback = function(v) flySpeed = v end,
})
MoveSub:AddToggle({
    Title = "Noclip", Default = false, Flag = "rv_noclip",
    Callback = function(v) noclipEnabled = v end,
})
local function ReapplyStats()
    local c = LocalPlayer.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        if wsEnabled then hum.WalkSpeed = wsValue end
        if jpEnabled then hum.JumpPower = jpValue end
    end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        if noclipEnabled then hrp.CanCollide = false end
        if flyEnabled then
            local move = UserInputService:GetMoveVector()
            local camCf = Camera.CFrame
            local dir = (camCf.RightVector * move.X + camCf.LookVector * -move.Y) * flySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, flySpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0, -flySpeed, 0) end
            hrp.CFrame = hrp.CFrame + dir * 0.016
        end
    end
end
track(RunService.Heartbeat:Connect(function()
    if HUB.dead then return end
    if wsEnabled or jpEnabled or flyEnabled or noclipEnabled then
        pcall(ReapplyStats)
    end
end))
track(UserInputService.JumpRequest:Connect(function()
    if infJump then
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))
local unlockEnabled = false
local unlockFinishers = true
local CosmeticLibrary, ItemLibrary, PlayerDataController
local equipped = {}
local favorites = {}
local constructingWeapon, viewingProfile = nil, nil
local lastUsedWeapon = nil
local origOwnsCosmetic, origDataGet, origGetWeaponData
local origNamecall
local origCreateViewModel, origClientVMNew, origGetCharm, origGetWrap, origGetVMImage, origFetch
local viewModelModule, ClientViewModel, ClientItem
local unlockFile = "unlockall/config.json"
do
    local ok1, cl = pcall(require, reps.Modules.CosmeticLibrary)
    if ok1 then CosmeticLibrary = cl end
    local ok2, il = pcall(require, reps.Modules.ItemLibrary)
    if ok2 then ItemLibrary = il end
    local ok3, pd = pcall(require, LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
    if ok3 then PlayerDataController = pd end
end
local function UnlockIsUnlockable(cosmetic)
    if not cosmetic then return false end
    local t = cosmetic.Type or ""
    local n = (cosmetic.Name or ""):lower()
    if t == "Skin" or t == "Charm" or t == "Dance" or t == "Emote" or t == "Wrap" or t == "Wrapping" then
        return true
    end
    if unlockFinishers and t == "Finisher" then
        return true
    end
    if n:find("charm") or n:find("dance") or n:find("emote") or n:find("wrap") then
        return true
    end
    return false
end
local function UnlockCloneCosmetic(name, cosmeticType, options)
    local base = CosmeticLibrary and CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
    if not base then return nil end
    local data = {}
    for key, value in pairs(base) do data[key] = value end
    data.Name = name
    data.Type = data.Type or cosmeticType
    data.Seed = data.Seed or math.random(1, 1000000)
    if options then
        if options.inverted ~= nil then data.Inverted = options.inverted end
        if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
    end
    return data
end
local function UnlockSaveConfig()
    if not writefile then return end
    pcall(function()
        local config = { equipped = {}, favorites = favorites }
        for weapon, cosmetics in pairs(equipped) do
            config.equipped[weapon] = {}
            for cosmeticType, cosmeticData in pairs(cosmetics) do
                if cosmeticData and cosmeticData.Name then
                    config.equipped[weapon][cosmeticType] = {
                        name = cosmeticData.Name,
                        seed = cosmeticData.Seed,
                        inverted = cosmeticData.Inverted,
                    }
                end
            end
        end
        makefolder("unlockall")
        writefile(unlockFile, HttpService:JSONEncode(config))
    end)
end
local function UnlockLoadConfig()
    if not readfile or not isfile or not isfile(unlockFile) then return end
    pcall(function()
        local config = HttpService:JSONDecode(readfile(unlockFile))
        if config.equipped then
            for weapon, cosmetics in pairs(config.equipped) do
                equipped[weapon] = {}
                for cosmeticType, cosmeticData in pairs(cosmetics) do
                    local cloned = UnlockCloneCosmetic(cosmeticData.name, cosmeticType, { inverted = cosmeticData.inverted })
                    if cloned then
                        cloned.Seed = cosmeticData.seed
                        equipped[weapon][cosmeticType] = cloned
                    end
                end
            end
        end
        favorites = config.favorites or {}
    end)
end
local function UnlockApplyViewmodelCosmetics(replicatedData, weaponName, weaponPlayer)
    if weaponPlayer == LocalPlayer and equipped[weaponName] then
        local ReplicatedClass = require(reps.Modules.ReplicatedClass)
        local dataKey = ReplicatedClass:ToEnum("Data")
        replicatedData[dataKey] = replicatedData[dataKey] or {}
        local cosmetics = equipped[weaponName]
        if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
        if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
        if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
    end
end
local function ApplyUnlockAll(on)
    if on then
        if not (CosmeticLibrary and ItemLibrary and PlayerDataController) then
            Notify("Unlock All", "Cosmetic modules not found", "Error", 3.5)
            return
        end
        if not origOwnsCosmetic then
            origOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
            CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
                if name:find("MISSING_") then return origOwnsCosmetic(self, inventory, name, weapon) end
                local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                if UnlockIsUnlockable(cosmetic) then return true end
                return origOwnsCosmetic(self, inventory, name, weapon)
            end
        end
        if not origDataGet then
            origDataGet = PlayerDataController.Get
            PlayerDataController.Get = function(self, key)
                local data = origDataGet(self, key)
                if key == "CosmeticInventory" then
                    local proxy = {}
                    if data then
                        for k, v in pairs(data) do
                            local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[k]
                            if UnlockIsUnlockable(cosmetic) then proxy[k] = v end
                        end
                    end
                    return setmetatable(proxy, { __index = function(t, k)
                        local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[k]
                        if UnlockIsUnlockable(cosmetic) then return true end
                        return nil
                    end })
                end
                if key == "FavoritedCosmetics" then
                    local result = data and table.clone(data) or {}
                    for weapon, favs in pairs(favorites) do
                        result[weapon] = result[weapon] or {}
                        for name, isFav in pairs(favs) do
                            local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[name]
                            if UnlockIsUnlockable(cosmetic) then result[weapon][name] = isFav end
                        end
                    end
                    return result
                end
                return data
            end
        end
        if not origGetWeaponData then
            origGetWeaponData = PlayerDataController.GetWeaponData
            PlayerDataController.GetWeaponData = function(self, weaponName)
                local data = origGetWeaponData(self, weaponName)
                if not data then return nil end
                local merged = {}
                for key, value in pairs(data) do merged[key] = value end
                merged.Name = weaponName
                if equipped[weaponName] then
                    for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do
                        if cosmeticType == "Skin" or cosmeticType == "Charm" or cosmeticType == "Wrap" or cosmeticType == "Wrapping" or cosmeticType == "Finisher" then
                            merged[cosmeticType] = cosmeticData
                        end
                    end
                end
                return merged
            end
        end
        if not origNamecall and hookmetamethod and getnamecallmethod then
            local remotes = reps.Remotes
            local dataRemotes = remotes and remotes:FindFirstChild("Data")
            local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
            local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
            if equipRemote then
                origNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if getnamecallmethod() ~= "FireServer" then return origNamecall(self, ...) end
                    local args = { ... }
                    if self == equipRemote then
                        local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}
                        local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[cosmeticName]
                        if not UnlockIsUnlockable(cosmetic) then return origNamecall(self, ...) end
                        if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                            local inventory = PlayerDataController:Get("CosmeticInventory")
                            if inventory and rawget(inventory, cosmeticName) then return origNamecall(self, ...) end
                        end
                        if cosmeticType == "Dance" or cosmeticType == "Emote" then
                            equipped.Dances = equipped.Dances or {}
                            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                equipped.Dances[cosmeticType] = nil
                            else
                                local cloned = UnlockCloneCosmetic(cosmeticName, cosmeticType, { inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites })
                                if cloned then equipped.Dances[cosmeticType] = cloned end
                            end
                            task.defer(function()
                                pcall(function() PlayerDataController.CurrentData:Replicate("CosmeticInventory") end)
                                task.wait(0.2)
                                UnlockSaveConfig()
                            end)
                        else
                            equipped[weaponName] = equipped[weaponName] or {}
                            if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                                equipped[weaponName][cosmeticType] = nil
                                if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                            else
                                local cloned = UnlockCloneCosmetic(cosmeticName, cosmeticType, { inverted = options.IsInverted, favoritesOnly = options.OnlyUseFavorites })
                                if cloned then equipped[weaponName][cosmeticType] = cloned end
                            end
                            task.defer(function()
                                pcall(function() PlayerDataController.CurrentData:Replicate("WeaponInventory") end)
                                task.wait(0.2)
                                UnlockSaveConfig()
                            end)
                        end
                        return
                    end
                    if self == favoriteRemote then
                        local cosmetic = CosmeticLibrary.Cosmetics and CosmeticLibrary.Cosmetics[args[2]]
                        if UnlockIsUnlockable(cosmetic) then
                            favorites[args[1]] = favorites[args[1]] or {}
                            favorites[args[1]][args[2]] = args[3] or nil
                            UnlockSaveConfig()
                            task.spawn(function() pcall(function() PlayerDataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                        end
                        return
                    end
                    return origNamecall(self, ...)
                end)
            end
        end
        pcall(function() ClientItem = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)
        if ClientItem and ClientItem._CreateViewModel and not origCreateViewModel then
            origCreateViewModel = ClientItem._CreateViewModel
            ClientItem._CreateViewModel = function(self, viewmodelRef)
                local weaponName = self.Name
                local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
                constructingWeapon = (weaponPlayer == LocalPlayer) and weaponName or nil
                if weaponPlayer == LocalPlayer and equipped[weaponName] and viewmodelRef then
                    local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                    if viewmodelRef[dataKey] then
                        if equipped[weaponName].Skin then
                            viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                            viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                        end
                    elseif viewmodelRef.Data then
                        if equipped[weaponName].Skin then
                            viewmodelRef.Data.Skin = equipped[weaponName].Skin
                            viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                        end
                    end
                end
                local result = origCreateViewModel(self, viewmodelRef)
                constructingWeapon = nil
                return result
            end
        end
        viewModelModule = LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
        if viewModelModule then
            ClientViewModel = require(viewModelModule)
            if not origClientVMNew then
                origClientVMNew = ClientViewModel.new
                ClientViewModel.new = function(replicatedData, clientItem)
                    local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
                    local weaponName = constructingWeapon or clientItem.Name
                    UnlockApplyViewmodelCosmetics(replicatedData, weaponName, weaponPlayer)
                    local result = origClientVMNew(replicatedData, clientItem)
                    if weaponPlayer == LocalPlayer and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                        result:_UpdateWrap()
                        task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
                    end
                    return result
                end
            end
            if not origGetCharm and ClientViewModel.GetCharm then
                origGetCharm = ClientViewModel.GetCharm
                ClientViewModel.GetCharm = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == LocalPlayer and equipped[weaponName] and equipped[weaponName].Charm then
                        return equipped[weaponName].Charm
                    end
                    return origGetCharm(self)
                end
            end
            if not origGetWrap and ClientViewModel.GetWrap then
                origGetWrap = ClientViewModel.GetWrap
                ClientViewModel.GetWrap = function(self)
                    local weaponName = self.ClientItem and self.ClientItem.Name
                    local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                    if weaponName and weaponPlayer == LocalPlayer and equipped[weaponName] and equipped[weaponName].Wrap then
                        return equipped[weaponName].Wrap
                    end
                    return origGetWrap(self)
                end
            end
        end
        if ItemLibrary and ItemLibrary.GetViewModelImageFromWeaponData and not origGetVMImage then
            origGetVMImage = ItemLibrary.GetViewModelImageFromWeaponData
            ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
                if not weaponData then return origGetVMImage(self, weaponData, highRes) end
                local weaponName = weaponData.Name
                local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == LocalPlayer and equipped[weaponName] and equipped[weaponName].Skin)
                if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                    local skinInfo = self.ViewModels and self.ViewModels[equipped[weaponName].Skin.Name]
                    if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
                end
                return origGetVMImage(self, weaponData, highRes)
            end
        end
        pcall(function()
            local ViewProfile = require(LocalPlayer.PlayerScripts.Modules.Pages.ViewProfile)
            if ViewProfile and ViewProfile.Fetch and not origFetch then
                origFetch = ViewProfile.Fetch
                ViewProfile.Fetch = function(self, targetPlayer)
                    viewingProfile = targetPlayer
                    return origFetch(self, targetPlayer)
                end
            end
        end)
        UnlockLoadConfig()
    else
        if CosmeticLibrary and origOwnsCosmetic then pcall(function() CosmeticLibrary.OwnsCosmetic = origOwnsCosmetic end); origOwnsCosmetic = nil end
        if PlayerDataController and origDataGet then pcall(function() PlayerDataController.Get = origDataGet end); origDataGet = nil end
        if PlayerDataController and origGetWeaponData then pcall(function() PlayerDataController.GetWeaponData = origGetWeaponData end); origGetWeaponData = nil end
        if origNamecall then pcall(function() hookmetamethod(game, "__namecall", origNamecall) end); origNamecall = nil end
        if ClientItem and origCreateViewModel then pcall(function() ClientItem._CreateViewModel = origCreateViewModel end); origCreateViewModel = nil end
        if ClientViewModel and origClientVMNew then pcall(function() ClientViewModel.new = origClientVMNew end); origClientVMNew = nil end
        if ClientViewModel and origGetCharm then pcall(function() ClientViewModel.GetCharm = origGetCharm end); origGetCharm = nil end
        if ClientViewModel and origGetWrap then pcall(function() ClientViewModel.GetWrap = origGetWrap end); origGetWrap = nil end
        if ItemLibrary and origGetVMImage then pcall(function() ItemLibrary.GetViewModelImageFromWeaponData = origGetVMImage end); origGetVMImage = nil end
        if origFetch then
            pcall(function()
                local ViewProfile = require(LocalPlayer.PlayerScripts.Modules.Pages.ViewProfile)
                if ViewProfile then ViewProfile.Fetch = origFetch end
            end)
            origFetch = nil
        end
        ClientItem, ClientViewModel, viewModelModule = nil, nil, nil
    end
end
local UnlockSub = PlayerTab:AddSection("Unlock All", "solar/home-bold")
UnlockSub:AddDivider()
UnlockSub:AddToggle({
    Title = "Unlock All Cosmetics", Default = false, Flag = "rv_unlockall",
    Callback = function(v)
        unlockEnabled = v
        ApplyUnlockAll(v)
        if v and not (CosmeticLibrary and ItemLibrary and PlayerDataController) then
            Notify("Unlock All", "Cosmetic modules not found", "Error", 3.5)
        else
            Notify("Unlock All", v and "All cosmetics unlocked" or "Unlock All off", v and "Success" or "Error")
        end
    end,
})
UnlockSub:AddToggle({
    Title = "Include Finishers", Default = true, Flag = "rv_unlock_finish",
    Callback = function(v)
        unlockFinishers = v
        Notify("Unlock All", v and "Finishers included" or "Finishers excluded", v and "Success" or "Error")
    end,
})
local spoofConfig = {
    nameSpoof = true,
    yourName = "Andy",
    enemyName = "Johnny",
    levelSpoof = false,
    spoofedLevel = 996,
    winstreakSpoof = false,
    spoofedWinstreak = 56,
}
local spoofConns = {}
local spoofLoopAlive = true
local function SpoofPlayer(player)
    if not spoofConfig.nameSpoof then return end
    if player == LocalPlayer then
        pcall(function()
            player.Name = spoofConfig.yourName
            player.DisplayName = spoofConfig.yourName
        end)
    else
        pcall(function()
            player.Name = spoofConfig.enemyName
            player.DisplayName = spoofConfig.enemyName
        end)
    end
end
local function SpoofLeaderstats(player)
    if player ~= LocalPlayer then return end
    local leaderstats = player:FindFirstChild("CustomLeaderstats")
    if not leaderstats then return end
    if spoofConfig.levelSpoof then
        local levelVal = leaderstats:FindFirstChild("Level")
        if levelVal and levelVal:IsA("IntValue") then levelVal.Value = spoofConfig.spoofedLevel end
        pcall(function() player:SetAttribute("Level", spoofConfig.spoofedLevel) end)
    end
    if spoofConfig.winstreakSpoof then
        local streakFolder = leaderstats:FindFirstChild("Win Streak")
        if streakFolder then
            if streakFolder:IsA("Folder") then
                local streakVal = streakFolder:FindFirstChildWhichIsA("IntValue")
                if streakVal then streakVal.Value = spoofConfig.spoofedWinstreak end
            elseif streakFolder:IsA("IntValue") then
                streakFolder.Value = spoofConfig.spoofedWinstreak
            end
        end
        pcall(function() player:SetAttribute("StatisticDuelsWinStreak", spoofConfig.spoofedWinstreak) end)
    end
end
local GUI_PATH = {
    "PlayerGui", "MainGui", "PlayerList", "Container",
    "Elements", "Container", "Middle", "List", "Container",
}
local function GetListContainer()
    local node = LocalPlayer
    for _, name in ipairs(GUI_PATH) do
        if not node then return nil end
        node = node:FindFirstChild(name)
    end
    return node
end
local function FindAllTitleLabels(instance, results)
    results = results or {}
    if not instance then return results end
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("TextLabel") and child.Name == "Title" then table.insert(results, child) end
        FindAllTitleLabels(child, results)
    end
    return results
end
local function SpoofTitleLabels(container)
    if not container then return end
    for _, playerFrame in ipairs(container:GetChildren()) do
        if playerFrame:IsA("Frame") then
            local spoofed = false
            local innerContainer = playerFrame:FindFirstChild("Container")
            if innerContainer and innerContainer:IsA("Frame") then
                for _, child in ipairs(innerContainer:GetChildren()) do
                    if child:IsA("Frame") then
                        local titleLabel = child:FindFirstChild("Title")
                        if titleLabel and titleLabel:IsA("TextLabel") then
                            local isLocal = titleLabel.Text == LocalPlayer.Name or titleLabel.Text == LocalPlayer.DisplayName
                            titleLabel.Text = isLocal and spoofConfig.yourName or spoofConfig.enemyName
                            spoofed = true
                        end
                    end
                end
            end
            if not spoofed then
                local labels = FindAllTitleLabels(playerFrame)
                for _, titleLabel in ipairs(labels) do
                    local isLocal = titleLabel.Text == LocalPlayer.Name or titleLabel.Text == LocalPlayer.DisplayName
                    titleLabel.Text = isLocal and spoofConfig.yourName or spoofConfig.enemyName
                end
            end
        end
    end
end
local function StartSpoofLoop()
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
        if not playerGui then return end
        local monitoredContainer = nil
        while spoofLoopAlive do
            task.wait(0.5)
            if not spoofConfig.nameSpoof then
            else
                local listContainer = GetListContainer()
                if listContainer and listContainer ~= monitoredContainer then
                    monitoredContainer = listContainer
                    local conn = listContainer.ChildAdded:Connect(function(child)
                        if child:IsA("Frame") then
                            task.wait(0.1)
                            pcall(SpoofTitleLabels, listContainer)
                        end
                    end)
                    table.insert(spoofConns, conn)
                end
                if listContainer then
                    pcall(SpoofTitleLabels, listContainer)
                end
            end
        end
    end)
end
local function ApplySpoof(on)
    if on then
        for _, player in ipairs(Players:GetPlayers()) do
            SpoofPlayer(player)
            if player == LocalPlayer then
                SpoofLeaderstats(player)
            end
        end
        local addedConn = Players.PlayerAdded:Connect(function(player) SpoofPlayer(player) end)
        table.insert(spoofConns, addedConn)
        StartSpoofLoop()
    else
        for _, c in ipairs(spoofConns) do pcall(function() c:Disconnect() end) end
        table.clear(spoofConns)
    end
end
local SpoofSub = PlayerTab:AddSection("Spoof", "solar/home-bold")
SpoofSub:AddDivider()
SpoofSub:AddToggle({
    Title = "Name Spoof", Default = true, Flag = "rv_spoof_name",
    Callback = function(v)
        spoofConfig.nameSpoof = v
        if v then
            ApplySpoof(true)
        else
            for _, c in ipairs(spoofConns) do pcall(function() c:Disconnect() end) end
            table.clear(spoofConns)
        end
    end,
})
SpoofSub:AddInput({
    Title = "Your Name", Default = "Andy", Flag = "rv_spoof_yname",
    Callback = function(t) spoofConfig.yourName = t end,
})
SpoofSub:AddInput({
    Title = "Enemy Name", Default = "Johnny", Flag = "rv_spoof_ename",
    Callback = function(t) spoofConfig.enemyName = t end,
})
SpoofSub:AddDivider()
SpoofSub:AddToggle({
    Title = "Level Spoof", Default = false, Flag = "rv_spoof_level",
    Callback = function(v) spoofConfig.levelSpoof = v; if v then SpoofLeaderstats(LocalPlayer) end end,
})
SpoofSub:AddInput({
    Title = "Spoofed Level", Default = "996", Flag = "rv_spoof_levelval",
    Callback = function(t) spoofConfig.spoofedLevel = tonumber(t) or 996 end,
})
SpoofSub:AddToggle({
    Title = "Winstreak Spoof", Default = false, Flag = "rv_spoof_ws",
    Callback = function(v) spoofConfig.winstreakSpoof = v; if v then SpoofLeaderstats(LocalPlayer) end end,
})
SpoofSub:AddInput({
    Title = "Spoofed Winstreak", Default = "56", Flag = "rv_spoof_wsval",
    Callback = function(t) spoofConfig.spoofedWinstreak = tonumber(t) or 56 end,
})
local SystemTab = Window:AddTab({ Title = "System", Icon = "solar/settings-bold" })
local SettingsSub = SystemTab:AddSection("Settings", "solar/home-bold")
if type(Library.SetTheme) == "function" then
    SettingsSub:AddDropdown({
        Title = "Theme", Values = { "Dark", "Light", "OLED" }, Default = "Dark",
        Flag = "rv_theme",
        Callback = function(v) pcall(function() Library:SetTheme(v) end) end,
    })
end
SettingsSub:AddDivider()
local setFpsCap = setfpscap or (getfenv and getfenv().setfpscap)
if type(setFpsCap) == "function" then
    local fpsUnlocked = false
    local fpsCap = 240
    SettingsSub:AddToggle({
        Title = "Unlock FPS (Unlimited)", Default = false, Flag = "rv_fps_unlock",
        Callback = function(v)
            fpsUnlocked = v
            pcall(setFpsCap, v and 0 or fpsCap)
            Notify("FPS", v and "Unlocked (unlimited)" or ("Capped at " .. fpsCap), v and "Success" or "Info")
        end,
    })
    SettingsSub:AddSlider({
        Title = "FPS Cap", Min = 30, Max = 1000, Default = 240, Suffix = "", Flag = "rv_fps_cap",
        Callback = function(v)
            fpsCap = v
            if not fpsUnlocked then pcall(setFpsCap, v) end
        end,
    })
else
    SettingsSub:AddParagraph({
        Title = "FPS Unlock Unavailable",
        Text = "This executor does not expose setfpscap, so the FPS cap can't be changed from here.",
    })
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
    SettingsSub:AddParagraph({
        Title = "Config Saving Unavailable",
        Text = "This Oxide UI build does not expose the flag/config system. All other features still work.",
    })
end
local function Cleanup()
    rage.enabled = false
    equipLoopAlive = false
    table.clear(deflecting)
    pcall(function() runSR:UnbindFromRenderStep("OxideRageRestore") end)
    noSpreadEnabled = false; ApplyNoSpread(false)
    rapidHitEnabled = false
    unlockEnabled = false; ApplyUnlockAll(false)
    spoofLoopAlive = false
    for _, c in ipairs(spoofConns) do pcall(function() c:Disconnect() end) end
    table.clear(spoofConns)
    wsEnabled = false; jpEnabled = false; infJump = false
    flyEnabled = false; noclipEnabled = false; fullbright = false
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    table.clear(HUB.conns)
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    table.clear(HUB.drawings)
    for _, h in pairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    table.clear(HUB.highlights)
    pcall(function()
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.Ambient = savedLighting.Ambient
        if okOutdoor then pcall(function() Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient end) end
        if okExp then pcall(function() Lighting.ExposureCompensation = savedLighting.ExposureCompensation end) end
    end)
    pcall(function() Window:Destroy() end)
end
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    Cleanup()
end
SettingsSub:AddDivider()
SettingsSub:AddButton({
    Title = "Unload Hub",
    Callback = function()
        HUB.Unload()
        _G.OxideRivals = nil
    end,
})
Notify("RIVALS", "NevaHub loaded", "Success", 3)
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
