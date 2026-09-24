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
    SubTitle = "Universal",
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
    local prev = _G.OxideUniversal
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideUniversal = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local TeleportService    = game:GetService("TeleportService")
local VirtualUser        = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local CONFIG_NAME = "universal"
local dropdownResync = {}
local function registerResync(handle, applyFn)
    if handle and applyFn then
        table.insert(dropdownResync, function() applyFn(handle:Get()) end)
    end
end
local function ResyncAll()
    for _, fn in ipairs(dropdownResync) do pcall(fn) end
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
local function GetRootCFrame()
    local hrp = GetHRP()
    return hrp and hrp.CFrame
end
local function Notify(title, content, kind, dur)
    Fluent:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
end
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "solar/user-bold" })
local MoveSub = PlayerTab:AddSection("Movement", "solar/home-bold")
local wsEnabled, wsValue   = false, 16
local jpEnabled, jpValue   = false, 50
local infJump              = false
local gravityEnabled, gravityValue = false, 196.2
local defaultGravity = Workspace.Gravity
MoveSub:AddDivider()
MoveSub:AddToggle({
    Title = "WalkSpeed", Default = false, Flag = "ws_enabled",
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
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v and jpValue or 50
        end
    end,
})
MoveSub:AddSlider({
    Title = "JumpPower Value", Min = 50, Max = 500, Default = 50, Suffix = "", Flag = "jp_value",
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
    Title = "Custom Gravity", Default = false, Flag = "grav_enabled",
    Callback = function(v)
        gravityEnabled = v
        Workspace.Gravity = v and gravityValue or defaultGravity
    end,
})
MoveSub:AddSlider({
    Title = "Gravity", Min = 0, Max = 400, Default = 196, Suffix = "", Flag = "grav_value",
    Callback = function(v)
        gravityValue = v
        if gravityEnabled then Workspace.Gravity = v end
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
    local hrp = GetHRP()
    if not hum or not hrp then return end
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
    table.clear(noclipParts)
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
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.UseJumpPower = true end
        Workspace.Gravity = defaultGravity
        Notify("Character", "Stats reset to default", "Success")
    end,
})
local antiAFK = true
CharSub:AddToggle({
    Title = "Anti-AFK", Default = true, Flag = "anti_afk",
    Callback = function(v) antiAFK = v end,
})
if not _G.OxideUniversalAntiAFK then
    _G.OxideUniversalAntiAFK = true
    LocalPlayer.Idled:Connect(function()
        if antiAFK then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
            end)
        end
    end)
end
local AvatarSub = PlayerTab:AddSection("Avatar", "solar/home-bold")
local hipEnabled, hipValue = false, 2
AvatarSub:AddDivider()
AvatarSub:AddToggle({
    Title = "Custom Hip Height", Default = false, Flag = "hip_enabled",
    Description = "How high the character floats",
    Callback = function(v)
        hipEnabled = v
        local hum = GetHumanoid()
        if hum then hum.HipHeight = v and hipValue or 2 end
    end,
})
AvatarSub:AddSlider({
    Title = "Hip Height", Min = 0, Max = 20, Default = 2, Suffix = "", Flag = "hip_value",
    Callback = function(v) hipValue = v; if hipEnabled then local h = GetHumanoid(); if h then h.HipHeight = v end end end,
})
track(LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 10)
    task.wait(0.4)
    if HUB.dead then return end
    if hipEnabled then local h = GetHumanoid(); if h then h.HipHeight = hipValue end end
end))
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
local following = false
PlayerTpSub:AddToggle({
    Title = "Follow Player", Default = false, Flag = "tp_follow",
    Callback = function(v) following = v end,
})
task.spawn(function()
    while true do
        if HUB.dead then break end
        if following then
            local target = ResolvePlayer(selectedPlayer)
            local myHRP = GetHRP()
            local tHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 4)
            end
        end
        task.wait(0.4)
    end
end)
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
    Title = "Teleport To Waypoint",
    Callback = function()
        local cf = selectedWaypoint and waypoints[selectedWaypoint]
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
        end
    end,
})
local TpMiscSub = TpTab:AddSection("Misc", "solar/home-bold")
local clickTp = false
TpMiscSub:AddToggle({
    Title = "Click Teleport", Default = false, Flag = "tp_click",
    Description = "Hold the keybind and click to teleport there",
    Callback = function(v)
        clickTp = v
        Notify("Click TP", v and "Enabled - press key to teleport to cursor" or "Disabled", v and "Success" or "Error")
    end,
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
    Title = "Teleport To Spawn",
    Callback = function()
        local hrp = GetHRP()
        local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if hrp and spawn then
            hrp.CFrame = spawn.CFrame * CFrame.new(0, 3, 0)
            Notify("Teleport", "Teleported to spawn", "Success")
        else
            Notify("Teleport", "No spawn found", "Error")
        end
    end,
})
local VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
local EspSub = VisualsTab:AddSection("ESP", "solar/home-bold")
local hasDrawing = (typeof(Drawing) == "table") or (Drawing ~= nil and pcall(function() return Drawing.new end))
local esp = {
    enabled = true, players = true, npcs = false,
    chams = false, chamsFillT = 0.55, chamsOutlineT = 0,
    box = false, boxStyle = "Corner", boxFill = false, boxFillT = 0.8, boxThickness = 1,
    name = false, distance = false, health = false, healthText = false, healthPercent = false,
    tool = false, tracer = false, tracerOrigin = "Bottom",
    skeleton = false, hat = false, arrow = false, look = false,
    halo = false, headCircle = false, ring = false,
    teamCheck = false, friendCheck = false, visibleCheck = false, rainbow = false, smooth = true,
    distanceFade = false, chamsDepth = "AlwaysOnTop",
    maxDistance = 1000, textSize = 14, font = 2,
    color        = Color3.fromRGB(30, 90, 220),
    visibleColor = Color3.fromRGB(95, 220, 120),
    hiddenColor  = Color3.fromRGB(235, 75, 75),
    friendColor  = Color3.fromRGB(95, 150, 255),
    npcColor     = Color3.fromRGB(235, 200, 70),
}
local espObjects = {}
local npcObjects = {}
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
local R15_BONES = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
}
local R6_BONES = {
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"},
}
local MAX_BONES = #R15_BONES
local RING_SEGMENTS = 16
local DRAW_KEYS = { "boxFill","boxOutline","box","hpOutline","hp","hpText","name","dist","tool","tracer","look","hat","arrow","halo","headCircle" }
local espCounter = 0
local function createEspObject()
    local obj = { skeleton = {}, corners = {}, ring = {} }
    espCounter = espCounter + 1
    local hl = Instance.new("Highlight")
    hl.Name = "OxideESP_" .. espCounter
    hl.FillTransparency = esp.chamsFillT
    hl.OutlineTransparency = esp.chamsOutlineT
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false
    pcall(function() hl.Parent = getEspParent() end)
    obj.highlight = hl
    table.insert(HUB.highlights, hl)
    if hasDrawing then
        obj.boxFill    = newDrawing("Square", { Filled = true, Transparency = 0.2, Color = esp.color, ZIndex = 0, Visible = false })
        obj.boxOutline = newDrawing("Square", { Thickness = 3, Filled = false, Color = Color3.new(0,0,0), ZIndex = 1, Visible = false })
        obj.box        = newDrawing("Square", { Thickness = 1, Filled = false, Color = esp.color, ZIndex = 2, Visible = false })
        for i = 1, 8 do obj.corners[i] = newDrawing("Line", { Thickness = 1.5, Color = esp.color, ZIndex = 2, Visible = false }) end
        obj.hpOutline  = newDrawing("Line",   { Thickness = 3, Color = Color3.new(0,0,0), ZIndex = 1, Visible = false })
        obj.hp         = newDrawing("Line",   { Thickness = 1, Color = Color3.fromRGB(0,255,0), ZIndex = 2, Visible = false })
        obj.hpText     = newDrawing("Text",   { Size = 11, Center = false, Outline = true, Font = esp.font, Color = Color3.new(1,1,1), ZIndex = 3, Visible = false })
        obj.name       = newDrawing("Text",   { Size = 14, Center = true, Outline = true, Font = esp.font, Color = esp.color, ZIndex = 3, Visible = false })
        obj.dist       = newDrawing("Text",   { Size = 13, Center = true, Outline = true, Font = esp.font, Color = Color3.new(1,1,1), ZIndex = 3, Visible = false })
        obj.tool       = newDrawing("Text",   { Size = 12, Center = true, Outline = true, Font = esp.font, Color = esp.color, ZIndex = 3, Visible = false })
        obj.tracer     = newDrawing("Line",   { Thickness = 1.5, Color = esp.color, ZIndex = 2, Visible = false })
        obj.look       = newDrawing("Line",   { Thickness = 1.5, Color = Color3.new(1,1,1), ZIndex = 2, Visible = false })
        obj.hat        = newDrawing("Triangle",{ Thickness = 1, Filled = true, Color = esp.color, ZIndex = 2, Visible = false })
        obj.arrow      = newDrawing("Triangle",{ Thickness = 1, Filled = true, Color = esp.color, ZIndex = 2, Visible = false })
        obj.halo       = newDrawing("Circle", { Thickness = 2, Filled = false, Color = esp.color, ZIndex = 2, Visible = false })
        obj.headCircle = newDrawing("Circle", { Thickness = 1.5, Filled = false, Color = esp.color, ZIndex = 2, Visible = false })
        for i = 1, RING_SEGMENTS do
            obj.ring[i] = newDrawing("Line", { Thickness = 1.5, Color = esp.color, ZIndex = 2, Visible = false })
        end
        for i = 1, MAX_BONES do
            obj.skeleton[i] = newDrawing("Line", { Thickness = 1, Color = esp.color, ZIndex = 2, Visible = false })
        end
    end
    return obj
end
local function removeEspObject(obj)
    if not obj then return end
    if obj.highlight then obj.highlight:Destroy() end
    for _, key in ipairs(DRAW_KEYS) do
        if obj[key] then pcall(function() obj[key]:Remove() end) end
    end
    for _, l in ipairs(obj.corners or {}) do pcall(function() l:Remove() end) end
    for _, l in ipairs(obj.ring or {}) do pcall(function() l:Remove() end) end
    for _, l in ipairs(obj.skeleton or {}) do pcall(function() l:Remove() end) end
end
local function createEsp(player)
    if espObjects[player] then return end
    local obj = createEspObject()
    obj.isFriend = false
    task.spawn(function()
        local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
        if ok then obj.isFriend = res == true end
    end)
    espObjects[player] = obj
end
local function removeEsp(player)
    local obj = espObjects[player]
    if not obj then return end
    removeEspObject(obj)
    espObjects[player] = nil
end
local function isFriendlyTeam(player)
    if not esp.teamCheck then return false end
    return player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
end
local function baseColorNow()
    if esp.rainbow then return Color3.fromHSV((tick() * 0.4) % 1, 1, 1) end
    return esp.color
end
local function healthColor(frac)
    return Color3.fromRGB(math.floor(255 * (1 - frac)), math.floor(255 * frac), 0)
end
local function isVisible(char, part)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { GetCharacter(), Camera }
    local origin = Camera.CFrame.Position
    local result = Workspace:Raycast(origin, part.Position - origin, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(char)
end
local function getBox2D(char)
    local cf, size = char:GetBoundingBox()
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
    if minX == math.huge then return nil end
    return minX, minY, maxX, maxY, anyOn
end
local function hideObj(obj)
    for _, key in ipairs(DRAW_KEYS) do if obj[key] then obj[key].Visible = false end end
    for _, l in ipairs(obj.corners) do l.Visible = false end
    for _, l in ipairs(obj.ring) do l.Visible = false end
    for _, l in ipairs(obj.skeleton) do l.Visible = false end
    if obj.highlight then obj.highlight.Enabled = false end
end
local function setCornerBox(obj, l, t, r, b, col, thick)
    local L = math.clamp((r - l) * 0.28, 4, 16)
    local segs = {
        {Vector2.new(l, t), Vector2.new(l + L, t)}, {Vector2.new(l, t), Vector2.new(l, t + L)},
        {Vector2.new(r, t), Vector2.new(r - L, t)}, {Vector2.new(r, t), Vector2.new(r, t + L)},
        {Vector2.new(l, b), Vector2.new(l + L, b)}, {Vector2.new(l, b), Vector2.new(l, b - L)},
        {Vector2.new(r, b), Vector2.new(r - L, b)}, {Vector2.new(r, b), Vector2.new(r, b - L)},
    }
    for i, s in ipairs(segs) do
        local line = obj.corners[i]
        line.From, line.To, line.Color, line.Thickness, line.Visible = s[1], s[2], col, thick + 0.5, true
    end
end
local F = {}
local function renderEntity(obj, char, displayName, isPlayer, player)
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart"))
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local dist = (hrp and F.myHRP) and (hrp.Position - F.myHRP.Position).Magnitude or 0
    local gate = isPlayer and esp.players or (not isPlayer and esp.npcs)
    local allowed = gate and char ~= nil and hrp ~= nil
        and (esp.maxDistance <= 0 or dist <= esp.maxDistance)
        and (not hum or hum.Health > 0)
    if isPlayer and allowed and isFriendlyTeam(player) then allowed = false end
    local col = isPlayer and F.baseCol or esp.npcColor
    if allowed and isPlayer and esp.friendCheck and obj.isFriend then col = esp.friendColor end
    if allowed and esp.visibleCheck then
        local probe = char:FindFirstChild("Head") or hrp
        col = isVisible(char, probe) and esp.visibleColor or esp.hiddenColor
    end
    if obj.highlight then
        obj.highlight.Enabled = allowed and esp.chams
        if allowed and esp.chams then
            obj.highlight.Adornee = char
            obj.highlight.FillColor = col
            obj.highlight.OutlineColor = col
            obj.highlight.FillTransparency = esp.chamsFillT
            obj.highlight.OutlineTransparency = esp.chamsOutlineT
            obj.highlight.DepthMode = esp.chamsDepth == "Occluded"
                and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
    if not hasDrawing then return end
    if not allowed or not F.anyDraw then hideObj(obj); return end
    local fade = esp.distanceFade and math.clamp(1 - dist / math.max(esp.maxDistance, 1), 0.2, 1) or 1
    local rootScreen, rootOn = Camera:WorldToViewportPoint(hrp.Position)
    local onScreen = rootScreen.Z > 0 and rootOn
    local left, top, right, bottom, boxOn = getBox2D(char)
    local haveBox = left ~= nil and boxOn
    if haveBox and esp.smooth then
        local prev = obj._rect
        if prev then
            local a = 0.45
            left   = prev[1] + (left - prev[1]) * a
            top    = prev[2] + (top - prev[2]) * a
            right  = prev[3] + (right - prev[3]) * a
            bottom = prev[4] + (bottom - prev[4]) * a
        end
        obj._rect = { left, top, right, bottom }
    end
    local showFull = esp.box and haveBox and esp.boxStyle == "Full"
    local showCorner = esp.box and haveBox and esp.boxStyle == "Corner"
    obj.box.Visible = showFull
    obj.boxOutline.Visible = showFull
    if showFull then
        local pos = Vector2.new(left, top)
        local sz  = Vector2.new(right - left, bottom - top)
        obj.boxOutline.Position = pos - Vector2.new(1, 1); obj.boxOutline.Size = sz + Vector2.new(2, 2)
        obj.boxOutline.Thickness = esp.boxThickness + 2
        obj.box.Position = pos; obj.box.Size = sz; obj.box.Color = col; obj.box.Thickness = esp.boxThickness
    end
    if showCorner then setCornerBox(obj, left, top, right, bottom, col, esp.boxThickness)
    else for _, l in ipairs(obj.corners) do l.Visible = false end end
    if esp.box and esp.boxFill and haveBox then
        obj.boxFill.Position = Vector2.new(left, top)
        obj.boxFill.Size = Vector2.new(right - left, bottom - top)
        obj.boxFill.Color = col
        obj.boxFill.Transparency = esp.boxFillT * fade
        obj.boxFill.Visible = true
    else obj.boxFill.Visible = false end
    local frac = hum and math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) or 1
    if esp.health and haveBox and hum then
        local barX = left - 5
        obj.hpOutline.From = Vector2.new(barX, top - 1); obj.hpOutline.To = Vector2.new(barX, bottom + 1); obj.hpOutline.Visible = true
        obj.hp.From = Vector2.new(barX, bottom); obj.hp.To = Vector2.new(barX, bottom - (bottom - top) * frac)
        obj.hp.Color = healthColor(frac); obj.hp.Visible = true
    else obj.hp.Visible = false; obj.hpOutline.Visible = false end
    if esp.healthText and haveBox and hum then
        obj.hpText.Text = esp.healthPercent and (math.floor(frac * 100) .. "%") or tostring(math.floor(hum.Health))
        obj.hpText.Font = esp.font
        obj.hpText.Position = Vector2.new(left - 24, (top + bottom) / 2 - 6)
        obj.hpText.Color = healthColor(frac)
        obj.hpText.Visible = true
    else obj.hpText.Visible = false end
    if esp.name and haveBox then
        obj.name.Text = displayName
        obj.name.Size = esp.textSize
        obj.name.Font = esp.font
        obj.name.Position = Vector2.new((left + right) / 2, top - esp.textSize - 2)
        obj.name.Color = col
        obj.name.Visible = true
    else obj.name.Visible = false end
    if esp.distance and haveBox then
        obj.dist.Text = math.floor(dist) .. "m"
        obj.dist.Size = esp.textSize - 1
        obj.dist.Font = esp.font
        obj.dist.Position = Vector2.new((left + right) / 2, bottom + 2)
        obj.dist.Visible = true
    else obj.dist.Visible = false end
    if esp.tool and haveBox then
        local toolInst = char:FindFirstChildOfClass("Tool")
        if toolInst then
            obj.tool.Text = toolInst.Name
            obj.tool.Size = esp.textSize - 2
            obj.tool.Font = esp.font
            obj.tool.Position = Vector2.new((left + right) / 2, bottom + 2 + (esp.distance and esp.textSize or 0))
            obj.tool.Color = col
            obj.tool.Visible = true
        else obj.tool.Visible = false end
    else obj.tool.Visible = false end
    if esp.tracer and onScreen then
        obj.tracer.From = F.tracerFrom
        obj.tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
        obj.tracer.Color = col
        obj.tracer.Visible = true
    else obj.tracer.Visible = false end
    if esp.look and char:FindFirstChild("Head") then
        local head = char.Head
        local fromP = Camera:WorldToViewportPoint(head.Position)
        local toP = Camera:WorldToViewportPoint(head.Position + head.CFrame.LookVector * 4)
        if fromP.Z > 0 and toP.Z > 0 then
            obj.look.From = Vector2.new(fromP.X, fromP.Y)
            obj.look.To = Vector2.new(toP.X, toP.Y)
            obj.look.Color = col
            obj.look.Visible = true
        else obj.look.Visible = false end
    else obj.look.Visible = false end
    if esp.hat and char:FindFirstChild("Head") then
        local head = char.Head
        local topPos = head.Position + Vector3.new(0, head.Size.Y * 0.5 + 0.6, 0)
        local sp, on = Camera:WorldToViewportPoint(topPos)
        if sp.Z > 0 and on then
            local apex = Vector2.new(sp.X, sp.Y)
            local w = math.clamp(haveBox and (right - left) * 0.45 or 9, 6, 26)
            local h = w * 1.1
            obj.hat.PointA = apex
            obj.hat.PointB = apex + Vector2.new(-w, -h)
            obj.hat.PointC = apex + Vector2.new(w, -h)
            obj.hat.Color = col
            obj.hat.Visible = true
        else obj.hat.Visible = false end
    else obj.hat.Visible = false end
    if esp.halo and char:FindFirstChild("Head") then
        local head = char.Head
        local topPos = head.Position + Vector3.new(0, head.Size.Y * 0.5 + 1.4, 0)
        local sp, on = Camera:WorldToViewportPoint(topPos)
        if sp.Z > 0 and on then
            obj.halo.Position = Vector2.new(sp.X, sp.Y)
            obj.halo.Radius = math.clamp(haveBox and (right - left) * 0.35 or 10, 6, 34)
            obj.halo.Color = col
            obj.halo.Visible = true
        else obj.halo.Visible = false end
    else obj.halo.Visible = false end
    if esp.headCircle and char:FindFirstChild("Head") then
        local head = char.Head
        local sp, on = Camera:WorldToViewportPoint(head.Position)
        local edge = Camera:WorldToViewportPoint(head.Position + Camera.CFrame.UpVector * (head.Size.Y * 0.6))
        if sp.Z > 0 and on then
            local r = math.clamp((Vector2.new(sp.X, sp.Y) - Vector2.new(edge.X, edge.Y)).Magnitude, 4, 40)
            obj.headCircle.Position = Vector2.new(sp.X, sp.Y)
            obj.headCircle.Radius = r
            obj.headCircle.Color = col
            obj.headCircle.Visible = true
        else obj.headCircle.Visible = false end
    else obj.headCircle.Visible = false end
    if esp.ring then
        local cf, size = char:GetBoundingBox()
        local feetY = cf.Position.Y - size.Y * 0.5
        local centerW = Vector3.new(hrp.Position.X, feetY, hrp.Position.Z)
        local worldR = math.max(size.X, size.Z) * 0.55 + 1
        local pts = {}
        for i = 1, RING_SEGMENTS do
            local a = (i - 1) / RING_SEGMENTS * math.pi * 2
            local wp = centerW + Vector3.new(math.cos(a) * worldR, 0, math.sin(a) * worldR)
            local s = Camera:WorldToViewportPoint(wp)
            pts[i] = { Vector2.new(s.X, s.Y), s.Z > 0 }
        end
        for i = 1, RING_SEGMENTS do
            local a, b = pts[i], pts[i % RING_SEGMENTS + 1]
            local line = obj.ring[i]
            if a[2] and b[2] then
                line.From, line.To, line.Color, line.Visible = a[1], b[1], col, true
            else line.Visible = false end
        end
    else
        for _, l in ipairs(obj.ring) do l.Visible = false end
    end
    if esp.skeleton then
        local bones = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
        local i = 0
        for _, pair in ipairs(bones) do
            local a = char:FindFirstChild(pair[1])
            local b = char:FindFirstChild(pair[2])
            if a and b then
                local sa = Camera:WorldToViewportPoint(a.Position)
                local sb = Camera:WorldToViewportPoint(b.Position)
                if sa.Z > 0 and sb.Z > 0 then
                    i = i + 1
                    local line = obj.skeleton[i]
                    if line then
                        line.From = Vector2.new(sa.X, sa.Y)
                        line.To = Vector2.new(sb.X, sb.Y)
                        line.Color = col
                        line.Visible = true
                    end
                end
            end
        end
        for j = i + 1, MAX_BONES do obj.skeleton[j].Visible = false end
    else
        for _, l in ipairs(obj.skeleton) do l.Visible = false end
    end
    if esp.arrow and not onScreen then
        local dir = Vector2.new(rootScreen.X, rootScreen.Y) - F.center
        if rootScreen.Z < 0 then dir = -dir end
        if dir.Magnitude > 0 then
            dir = dir.Unit
            local arrowPos = F.center + dir * math.min(F.vp.X, F.vp.Y) * 0.32
            local ang = math.atan2(dir.Y, dir.X)
            local s = 16
            obj.arrow.PointA = arrowPos + Vector2.new(math.cos(ang), math.sin(ang)) * s
            obj.arrow.PointB = arrowPos + Vector2.new(math.cos(ang + 2.6), math.sin(ang + 2.6)) * s
            obj.arrow.PointC = arrowPos + Vector2.new(math.cos(ang - 2.6), math.sin(ang - 2.6)) * s
            obj.arrow.Color = col
            obj.arrow.Visible = true
        else obj.arrow.Visible = false end
    else obj.arrow.Visible = false end
    if esp.distanceFade or obj._faded then
        local t = esp.distanceFade and fade or 1
        for _, k in ipairs(DRAW_KEYS) do
            if k ~= "boxFill" then local d = obj[k]; if d and d.Visible then d.Transparency = t end end
        end
        for _, l in ipairs(obj.corners) do if l.Visible then l.Transparency = t end end
        for _, l in ipairs(obj.ring) do if l.Visible then l.Transparency = t end end
        for _, l in ipairs(obj.skeleton) do if l.Visible then l.Transparency = t end end
        obj._faded = esp.distanceFade
    end
end
track(RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    F.myHRP = GetHRP()
    F.baseCol = baseColorNow()
    F.vp = Camera.ViewportSize
    F.center = Vector2.new(F.vp.X / 2, F.vp.Y / 2)
    F.tracerFrom = F.center
    if esp.tracerOrigin == "Bottom" then F.tracerFrom = Vector2.new(F.vp.X / 2, F.vp.Y)
    elseif esp.tracerOrigin == "Top" then F.tracerFrom = Vector2.new(F.vp.X / 2, 0)
    elseif esp.tracerOrigin == "Mouse" then
        local m = UserInputService:GetMouseLocation(); F.tracerFrom = Vector2.new(m.X, m.Y)
    end
    F.anyDraw = esp.box or esp.name or esp.distance or esp.health or esp.healthText
        or esp.tool or esp.tracer or esp.skeleton or esp.hat or esp.arrow or esp.look
        or esp.halo or esp.headCircle or esp.ring
    if esp.enabled then
        for player, obj in pairs(espObjects) do
            renderEntity(obj, player.Character, player.DisplayName, true, player)
        end
        for model, obj in pairs(npcObjects) do
            if model.Parent then renderEntity(obj, model, model.Name, false, nil)
            else hideObj(obj) end
        end
    else
        for _, obj in pairs(espObjects) do hideObj(obj) end
        for _, obj in pairs(npcObjects) do hideObj(obj) end
    end
end))
local function isPlayerCharacter(model)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return true end
    end
    return false
end
local function refreshNPCs()
    if not esp.npcs then
        for model, obj in pairs(npcObjects) do removeEspObject(obj); npcObjects[model] = nil end
        return
    end
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local model = d.Parent
            if model and model:IsA("Model") and not npcObjects[model] and not isPlayerCharacter(model) then
                local part = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if part then npcObjects[model] = createEspObject() end
            end
        end
    end
    for model, obj in pairs(npcObjects) do
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") or isPlayerCharacter(model) then
            removeEspObject(obj); npcObjects[model] = nil
        end
    end
end
task.spawn(function()
    while not HUB.dead do
        pcall(refreshNPCs)
        task.wait(2)
    end
end)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createEsp(p) end
end
track(Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createEsp(p) end end))
track(Players.PlayerRemoving:Connect(removeEsp))
if not hasDrawing then
    EspSub:AddParagraph({
        Title = "Limited ESP Mode",
        Text = "This executor has no Drawing API, so only Chams (Highlight) is available. Box / skeleton / hat / tracers need Drawing.",
    })
end
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Master Enable", Default = true, Flag = "esp_enabled", Callback = function(v) esp.enabled = v end })
EspSub:AddToggle({ Title = "Players", Default = true, Flag = "esp_players", Callback = function(v) esp.players = v end })
EspSub:AddToggle({ Title = "NPCs", Default = false, Flag = "esp_npcs", Description = "Non-player humanoids (mobs)", Callback = function(v) esp.npcs = v end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "2D Box", Default = false, Flag = "esp_box", Callback = function(v) esp.box = v end })
local applyBoxStyle = function(v) esp.boxStyle = v end
local boxStyleDropdown = EspSub:AddDropdown({
    Title = "Box Style", Values = { "Corner", "Full" }, Default = "Corner",
    MaxVisible = 2, Flag = "esp_boxstyle", Callback = applyBoxStyle,
})
registerResync(boxStyleDropdown, applyBoxStyle)
EspSub:AddSlider({ Title = "Box Thickness", Min = 1, Max = 5, Default = 1, Suffix = "", Flag = "esp_boxthick", Callback = function(v) esp.boxThickness = v end })
EspSub:AddToggle({ Title = "Box Fill", Default = false, Flag = "esp_boxfill", Callback = function(v) esp.boxFill = v end })
EspSub:AddSlider({ Title = "Box Fill Opacity", Min = 0, Max = 100, Default = 80, Suffix = "%", Flag = "esp_boxfill_op", Callback = function(v) esp.boxFillT = v / 100 end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Chams (Highlight)", Default = false, Flag = "esp_chams", Callback = function(v) esp.chams = v end })
local applyChamsDepth = function(v) esp.chamsDepth = v end
local chamsDepthDropdown = EspSub:AddDropdown({
    Title = "Chams Depth", Values = { "AlwaysOnTop", "Occluded" }, Default = "AlwaysOnTop",
    MaxVisible = 2, Flag = "esp_chamsdepth", Callback = applyChamsDepth,
})
registerResync(chamsDepthDropdown, applyChamsDepth)
EspSub:AddSlider({ Title = "Chams Fill", Min = 0, Max = 100, Default = 45, Suffix = "%", Flag = "esp_chams_fill", Callback = function(v) esp.chamsFillT = 1 - v / 100 end })
EspSub:AddSlider({ Title = "Chams Outline", Min = 0, Max = 100, Default = 100, Suffix = "%", Flag = "esp_chams_out", Callback = function(v) esp.chamsOutlineT = 1 - v / 100 end })
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Name", Default = false, Flag = "esp_name", Callback = function(v) esp.name = v end })
EspSub:AddToggle({ Title = "Distance", Default = false, Flag = "esp_distance", Callback = function(v) esp.distance = v end })
EspSub:AddToggle({ Title = "Held Tool", Default = false, Flag = "esp_tool", Callback = function(v) esp.tool = v end })
EspSub:AddToggle({ Title = "Health Bar", Default = false, Flag = "esp_health", Callback = function(v) esp.health = v end })
EspSub:AddToggle({ Title = "Health Number", Default = false, Flag = "esp_healthtext", Callback = function(v) esp.healthText = v end })
EspSub:AddToggle({ Title = "Health As %", Default = false, Flag = "esp_healthpct", Callback = function(v) esp.healthPercent = v end })
EspSub:AddSlider({ Title = "Text Size", Min = 10, Max = 22, Default = 14, Suffix = "", Flag = "esp_textsize", Callback = function(v) esp.textSize = v end })
local applyFont = function(v) esp.font = FONT_MAP[v] or 2 end
local fontDropdown = EspSub:AddDropdown({
    Title = "Text Font", Values = { "UI", "System", "Plain", "Monospace" }, Default = "Plain",
    MaxVisible = 4, Flag = "esp_font", Callback = applyFont,
})
registerResync(fontDropdown, applyFont)
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Halo (head ring)", Default = false, Flag = "esp_halo", Callback = function(v) esp.halo = v end })
EspSub:AddToggle({ Title = "Head Circle", Default = false, Flag = "esp_headcircle", Callback = function(v) esp.headCircle = v end })
EspSub:AddToggle({ Title = "Ground Ring (3D)", Default = false, Flag = "esp_ring", Callback = function(v) esp.ring = v end })
EspSub:AddToggle({ Title = "Skeleton", Default = false, Flag = "esp_skeleton", Callback = function(v) esp.skeleton = v end })
EspSub:AddToggle({ Title = "Chinese Hat (cone)", Default = false, Flag = "esp_hat", Callback = function(v) esp.hat = v end })
EspSub:AddToggle({ Title = "Look Direction", Default = false, Flag = "esp_look", Callback = function(v) esp.look = v end })
EspSub:AddToggle({ Title = "Tracers", Default = false, Flag = "esp_tracers", Callback = function(v) esp.tracer = v end })
EspSub:AddToggle({ Title = "Off-Screen Arrows", Default = false, Flag = "esp_arrow", Callback = function(v) esp.arrow = v end })
local applyTracerOrigin = function(v) esp.tracerOrigin = v end
local tracerOriginDropdown = EspSub:AddDropdown({
    Title = "Tracer Origin", Values = { "Bottom", "Center", "Top", "Mouse" },
    Default = "Bottom", MaxVisible = 4, Flag = "esp_tracer_origin",
    Callback = applyTracerOrigin,
})
registerResync(tracerOriginDropdown, applyTracerOrigin)
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Team Check (hide allies)", Default = false, Flag = "esp_team", Callback = function(v) esp.teamCheck = v end })
EspSub:AddToggle({ Title = "Friend Color", Default = false, Flag = "esp_friend", Description = "Color Roblox friends differently", Callback = function(v) esp.friendCheck = v end })
EspSub:AddToggle({
    Title = "Visibility Check", Default = false, Flag = "esp_visible",
    Description = "Color targets by line-of-sight",
    Callback = function(v) esp.visibleCheck = v end,
})
EspSub:AddToggle({ Title = "Box Smoothing", Default = true, Flag = "esp_smooth", Callback = function(v) esp.smooth = v end })
EspSub:AddToggle({ Title = "Distance Fade", Default = false, Flag = "esp_fade", Description = "Fade ESP for far targets", Callback = function(v) esp.distanceFade = v end })
EspSub:AddToggle({ Title = "Rainbow", Default = false, Flag = "esp_rainbow", Callback = function(v) esp.rainbow = v end })
EspSub:AddSlider({
    Title = "Max Distance", Min = 0, Max = 5000, Default = 1000, Suffix = "m", Flag = "esp_maxdist",
    Description = "0 = unlimited", Callback = function(v) esp.maxDistance = v end,
})
EspSub:AddDivider()
EspSub:AddColorPicker({ Name = "Main Color", Default = Color3.fromRGB(30, 90, 220), Flag = "esp_color", Callback = function(c) esp.color = c end })
EspSub:AddColorPicker({ Name = "Visible Color", Default = Color3.fromRGB(95, 220, 120), Flag = "esp_viscolor", Callback = function(c) esp.visibleColor = c end })
EspSub:AddColorPicker({ Name = "Hidden Color", Default = Color3.fromRGB(235, 75, 75), Flag = "esp_hidcolor", Callback = function(c) esp.hiddenColor = c end })
EspSub:AddColorPicker({ Name = "Friend Color", Default = Color3.fromRGB(95, 150, 255), Flag = "esp_friendcolor", Callback = function(c) esp.friendColor = c end })
EspSub:AddColorPicker({ Name = "NPC Color", Default = Color3.fromRGB(235, 200, 70), Flag = "esp_npccolor", Callback = function(c) esp.npcColor = c end })
local WorldSub = VisualsTab:AddSection("World", "solar/home-bold")
local fullbright = false
local savedLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
}
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
        else
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.FogEnd = savedLighting.FogEnd
            Lighting.GlobalShadows = savedLighting.GlobalShadows
            Lighting.Ambient = savedLighting.Ambient
        end
    end,
})
local defaultFOV = Camera.FieldOfView
WorldSub:AddSlider({
    Title = "Field of View", Min = 30, Max = 120, Default = math.floor(defaultFOV), Suffix = "°", Flag = "fov",
    Callback = function(v) Camera.FieldOfView = v end,
})
local CombatTab = Window:AddTab({ Title = "Combat", Icon = "target" })
local AimSub = CombatTab:AddSection("Aimbot", "solar/home-bold")
local aim = {
    enabled    = false,
    smoothness = 12,
    fov        = 150,
    prediction = 0,
    part       = "Head",
    teamCheck  = false,
    visibleCheck = false,
    aliveCheck = true,
    useRightClick = true,
    altKey     = nil,
    toggleMode = false,
    showFov    = true,
    fovColor   = Color3.fromRGB(30, 90, 220),
}
local mb2Down, altDown, toggleLocked = false, false, false
local function aimWanted()
    if aim.toggleMode then return toggleLocked end
    return (aim.useRightClick and mb2Down) or (aim.altKey ~= nil and altDown)
end
track(UserInputService.InputBegan:Connect(function(input, gp)
    if HUB.dead then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then mb2Down = true end
    if aim.altKey and input.KeyCode == aim.altKey then
        altDown = true
        if aim.toggleMode then toggleLocked = not toggleLocked end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and aim.toggleMode and aim.useRightClick then
        toggleLocked = not toggleLocked
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then mb2Down = false end
    if aim.altKey and input.KeyCode == aim.altKey then altDown = false end
end))
local fovCircle = newDrawing("Circle", { Thickness = 1.5, Filled = false, Visible = false })
local function getAimPart(char)
    if not char then return nil end
    return char:FindFirstChild(aim.part)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
end
local function isAlive(char)
    if not aim.aliveCheck then return true end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end
local function isVisible(char, part)
    if not aim.visibleCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { GetCharacter() }
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(char)
end
local function getClosestTarget()
    local best, bestDist
    local mouse = UserInputService:GetMouseLocation()
    local vp = Camera.ViewportSize
    local center = Vector2.new(mouse.X, mouse.Y)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local isTeammate = aim.teamCheck and p.Team ~= nil and LocalPlayer.Team ~= nil and p.Team == LocalPlayer.Team
            if not isTeammate then
                local char = p.Character
                local part = getAimPart(char)
                if part and isAlive(char) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if d <= aim.fov and (not bestDist or d < bestDist) then
                            if isVisible(char, part) then
                                best, bestDist = part, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end
track(RunService.RenderStepped:Connect(function()
    if HUB.dead then return end
    if fovCircle then
        fovCircle.Visible = aim.enabled and aim.showFov
        if fovCircle.Visible then
            local mouse = UserInputService:GetMouseLocation()
            fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
            fovCircle.Radius = aim.fov
            fovCircle.Color = aim.fovColor
        end
    end
    if not aim.enabled or not aimWanted() then return end
    local target = getClosestTarget()
    if not target then return end
    local camPos = Camera.CFrame.Position
    local aimPos = target.Position
    if aim.prediction > 0 then
        aimPos = aimPos + target.AssemblyLinearVelocity * aim.prediction
    end
    local goal = CFrame.new(camPos, aimPos)
    local alpha = math.clamp(1 / math.max(aim.smoothness, 1), 0, 1)
    Camera.CFrame = Camera.CFrame:Lerp(goal, alpha)
end))
AimSub:AddDivider()
AimSub:AddToggle({
    Title = "Enabled", Default = false, Flag = "aim_enabled",
    Callback = function(v)
        aim.enabled = v
        if not v then toggleLocked = false end
        Notify("Aimbot", v and "Enabled (hold Right-Click)" or "Disabled", v and "Success" or "Error")
    end,
})
AimSub:AddSlider({
    Title = "Smoothness", Min = 1, Max = 40, Default = 12, Suffix = "",
    Description = "Higher = smoother / slower lock", Flag = "aim_smooth",
    Callback = function(v) aim.smoothness = v end,
})
AimSub:AddSlider({
    Title = "FOV (px)", Min = 30, Max = 600, Default = 150, Suffix = "", Flag = "aim_fov",
    Callback = function(v) aim.fov = v end,
})
AimSub:AddSlider({
    Title = "Prediction", Min = 0, Max = 100, Default = 0, Suffix = "", Flag = "aim_prediction",
    Description = "Leads moving targets · raise if shots land behind them",
    Callback = function(v) aim.prediction = v / 1000 end,
})
local applyAimPart = function(v) aim.part = v end
local aimPartDropdown = AimSub:AddDropdown({
    Title = "Target Part", Values = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" },
    Default = "Head", MaxVisible = 4, Flag = "aim_part",
    Callback = applyAimPart,
})
registerResync(aimPartDropdown, applyAimPart)
AimSub:AddDivider()
AimSub:AddToggle({ Title = "Team Check", Default = false, Flag = "aim_team", Callback = function(v) aim.teamCheck = v end })
AimSub:AddToggle({ Title = "Wall Check (visible only)", Default = false, Flag = "aim_visible", Callback = function(v) aim.visibleCheck = v end })
AimSub:AddToggle({ Title = "Alive Check", Default = true, Flag = "aim_alive", Callback = function(v) aim.aliveCheck = v end })
AimSub:AddDivider()
AimSub:AddToggle({ Title = "Hold Right-Click", Default = true, Flag = "aim_rmb", Callback = function(v) aim.useRightClick = v end })
AimSub:AddToggle({
    Title = "Toggle Mode", Default = false, Flag = "aim_toggle",
    Description = "Press the key/button to lock instead of holding",
    Callback = function(v) aim.toggleMode = v; toggleLocked = false end,
})
AimSub:AddKeybind({
    Title = "Alt Aim Key", Default = nil, Flag = "aim_altkey",
    Callback = function(k) aim.altKey = k; altDown = false end,
})
AimSub:AddDivider()
AimSub:AddToggle({
    Title = "Show FOV Circle", Default = true, Flag = "aim_showfov",
    Description = hasDrawing and "Follows the cursor" or "Drawing API unavailable on this executor",
    Callback = function(v)
        aim.showFov = v and hasDrawing
        if v and not hasDrawing then Notify("Aimbot", "FOV circle needs Drawing API", "Warning", 3) end
    end,
})
AimSub:AddColorPicker({
    Name = "FOV Circle Color", Default = Color3.fromRGB(30, 90, 220), Flag = "aim_fovcolor",
    Callback = function(c) aim.fovColor = c end,
})
local ServerTab = Window:AddTab({ Title = "Server", Icon = "solar/planet-bold" })
local ServerSub = ServerTab:AddSection("Actions", "solar/home-bold")
ServerSub:AddButton({
    Title = "Rejoin Server", Primary = true,
    Callback = function()
        Notify("Server", "Rejoining...", "Info")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
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
                local raw = game:HttpGet(url)
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
ServerSub:AddParagraph({
    Title = "Session Info",
    Text = ("Place: %d\nJob: %s\nPlayers: %d/%d")
        :format(game.PlaceId, tostring(game.JobId), #Players:GetPlayers(), Players.MaxPlayers),
})
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })
local SettingsSub = SettingsTab:AddSection("General", "solar/home-bold")
if type(Library.SetTheme) == "function" then
    SettingsSub:AddDropdown({
        Title = "Theme", Values = { "Dark", "Light", "OLED" }, Default = "Dark",
        Flag = "ui_theme",
        Callback = function(v) pcall(function() Library:SetTheme(v) end) end,
    })
end
local setFpsCap = setfpscap or (getfenv and getfenv().setfpscap)
SettingsSub:AddDivider()
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
        Text = "This Oxide UI build does not expose the flag/config system (requires v2.3+). All other features still work.",
    })
end
SettingsSub:AddDivider()
function HUB.Unload()
    if HUB.dead then return end
    HUB.dead = true
    flying = false; noclip = false; following = false; aim.enabled = false
    pcall(function() if flyConn then flyConn:Disconnect() end end)
    pcall(stopNoclip)
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    for _, h in ipairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    table.clear(espObjects)
    table.clear(npcObjects)
    pcall(function()
        local hum = GetHumanoid()
        if hum then hum.PlatformStand = false; hum.WalkSpeed = 16; hum.JumpPower = 50 end
    end)
    Workspace.Gravity = defaultGravity
    Camera.FieldOfView = defaultFOV
    if fullbright then
        Lighting.Brightness = savedLighting.Brightness
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.FogEnd = savedLighting.FogEnd
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.Ambient = savedLighting.Ambient
    end
    pcall(function() Window:Destroy() end)
end
SettingsSub:AddButton({
    Title = "Unload Hub",
    Callback = function()
        HUB.Unload()
        _G.OxideUniversal = nil
    end,
})
Notify("NevaHub", "Universal loaded successfully", "Success", 4)
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
