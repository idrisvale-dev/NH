local Fluent = _G.NevaHubUI
if not Fluent then
    local NEVAHUBUI_RAW_URL = "YOUR_NEVAHUBUI_RAW_URL_HERE"
    Fluent = loadstring(game:HttpGet(NEVAHUBUI_RAW_URL, true))()
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
    SubTitle = "Da Hood",
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
    local prev = _G.OxideDaHood
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.OxideDaHood = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end
local CONFIG_NAME = "dahood"
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
local function GetCurrency()
    local df = LocalPlayer:FindFirstChild("DataFolder")
    local c = df and df:FindFirstChild("Currency")
    if c and typeof(c.Value) == "number" then return c.Value end
    if c and typeof(c.Value) == "string" then return tonumber(c.Value) or 0 end
    return 0
end
local function GetWanted()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local w = ls and ls:FindFirstChild("Wanted")
    if w then
        if typeof(w.Value) == "number" then return w.Value end
        if typeof(w.Value) == "string" then return tonumber(w.Value) or 0 end
    end
    local df = LocalPlayer:FindFirstChild("DataFolder")
    local info = df and df:FindFirstChild("Information")
    local w2 = info and info:FindFirstChild("Wanted")
    if w2 then return tonumber(w2.Value) or 0 end
    return 0
end
local function FormatMoney(value)
    local n = math.floor(tonumber(value) or 0)
    local sign = n < 0 and "-" or ""
    local s = tostring(math.abs(n))
    while true do
        local replaced, count = s:gsub("^(%d+)(%d%d%d)", "%1,%2")
        s = replaced
        if count == 0 then break end
    end
    return sign .. s
end
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
    Description = "Re-applied every frame (Da Hood re-syncs stats)",
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
if not _G.OxideDaHoodAntiAFK then
    _G.OxideDaHoodAntiAFK = true
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
    Title = "Teleport To City Center",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(-184, 22, -142)
            Notify("Teleport", "Teleported to city center", "Success")
        end
    end,
})
TpMiscSub:AddButton({
    Title = "Teleport To Bank",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(-541, 4, -285)
            Notify("Teleport", "Teleported to bank", "Success")
        end
    end,
})
TpMiscSub:AddDivider()
local spots = {
    ["Police Station"] = CFrame.new(-260, 21, -40),
    ["Hospital"] = CFrame.new(-309, 4, -380),
    ["Casino"] = CFrame.new(-458, 4, -313),
    ["Gym"] = CFrame.new(-76, 22, -638),
    ["Clothing South"] = CFrame.new(-177, 22, -184),
    ["Gun Store"] = CFrame.new(-572, 7, -3),
    ["Barber"] = CFrame.new(-133, 22, -546),
    ["Taco Shop"] = CFrame.new(583, 51, -452),
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
local VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
local hasDrawing = (typeof(Drawing) == "table") or (Drawing ~= nil and pcall(function() return Drawing.new end))
local esp = {
    enabled = true, players = true, money = false,
    box = false, boxStyle = "Corner", boxThickness = 1, boxFill = false,
    name = false, distance = false, health = false,
    chams = false, chamsFillT = 0.55, chamsOutlineT = 0,
    tracer = false, tracerOrigin = "Bottom",
    arrow = false, skeleton = false, halo = false, headCircle = false,
    teamCheck = false, rainbow = false,
    maxDistance = 1000, textSize = 13, font = 2,
    color        = Color3.fromRGB(30, 90, 220),
    moneyColor   = Color3.fromRGB(80, 220, 120),
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
    box.highlight.Name = "OxideDaHoodESP"
    box.highlight.FillTransparency = 0.6
    box.highlight.OutlineTransparency = 0.5
    box.highlight.Enabled = false
    box.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    pcall(function() box.highlight.Parent = getEspParent() end)
    table.insert(HUB.highlights, box.highlight)
    box.halo = Instance.new("Highlight")
    box.halo.Name = "OxideDaHoodHalo"
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
EspSub:AddParagraph({
    Title = "ESP",
    Text = "Master toggle enables the ESP loop. Boxes use the Lua Drawing API when the executor supports it, otherwise Highlight-based chams color targets.",
})
EspSub:AddDivider()
EspSub:AddToggle({ Title = "Master Enable", Default = true, Flag = "esp_enabled", Callback = function(v) esp.enabled = v end })
EspSub:AddToggle({ Title = "Players", Default = true, Flag = "esp_players", Callback = function(v) esp.players = v end })
EspSub:AddToggle({ Title = "Money Pickups", Default = false, Flag = "esp_money", Description = "Highlight robbable cash drops", Callback = function(v) esp.money = v end })
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
EspSub:AddColorPicker({ Name = "Money Color", Default = esp.moneyColor, Flag = "esp_moneycolor", Callback = function(c) esp.moneyColor = c end })
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
local moneyESP = {}
task.spawn(function()
    local lastScan = 0
    while not HUB.dead do
        if esp.money and esp.enabled then
            local t = os.clock()
            if t - lastScan >= 1 then
                lastScan = t
                pcall(function()
                    local found = {}
                    local function getMoneySource()
                        local d = Workspace:FindFirstChild("Drop")
                        if d then return d end
                        local ign = Workspace:FindFirstChild("Ignored")
                        if ign then d = ign:FindFirstChild("Drop"); if d then return d end end
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            if v.Name == "Drop" and v:IsA("Folder") then return v end
                        end
                        return nil
                    end
                    local drop = getMoneySource()
                    local source = drop and drop:GetChildren() or {}
                    for _, part in ipairs(source) do
                        if part.Name == "MoneyDrop" and part:IsA("BasePart") then
                            found[part] = true
                            if not moneyESP[part] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "OxideDaHoodMoney"
                                hl.FillColor = esp.moneyColor
                                hl.FillTransparency = 0.25
                                hl.OutlineColor = esp.moneyColor
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                pcall(function() hl.Parent = part end)
                                table.insert(HUB.highlights, hl)
                                moneyESP[part] = hl
                            end
                        end
                    end
                    local removed = {}
                    for p, hl in pairs(moneyESP) do
                        if not found[p] then
                            pcall(function() hl:Destroy() end)
                            removed[#removed + 1] = p
                        end
                    end
                    for _, p in ipairs(removed) do moneyESP[p] = nil end
                end)
            end
        elseif next(moneyESP) then
            local removed = {}
            for p, hl in pairs(moneyESP) do
                pcall(function() hl:Destroy() end)
                removed[#removed + 1] = p
            end
            for _, p in ipairs(removed) do moneyESP[p] = nil end
        else
            for _, hl in pairs(moneyESP) do
                pcall(function()
                    hl.FillColor = esp.moneyColor
                    hl.OutlineColor = esp.moneyColor
                end)
            end
        end
        task.wait(0.5)
    end
end)
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
local RageTab = Window:AddTab({ Title = "Rage", Icon = "target" })
local RageAimSub = RageTab:AddSection("Silent Aim", "solar/home-bold")
local RageHitboxSub = RageTab:AddSection("Hitbox & Misc", "solar/home-bold")
local RageTargetSub = RageTab:AddSection("Target", "solar/home-bold")
local rage = {
    silentEnabled = false,
    fov = 150,
    showFOV = true,
    teamCheck = true,
    visibleCheck = false,
    hitPart = "Head",
    hitChance = 100,
    useFOV = true,
    tracerFOV = false,
    targetMode = "FOV",
    chosenTarget = nil,
}
local fovCircle = hasDrawing and newDrawing("Circle", { Thickness = 1.5, NumSides = 64, Radius = 150, Filled = false, Visible = false, Color = Color3.fromRGB(255,255,255), Transparency = 1 }) or nil
if fovCircle then pcall(function() fovCircle.ZIndex = 5 end) end
do
    local fovConn = RunService.RenderStepped:Connect(function()
        if HUB.dead then return end
        if fovCircle then
            local shouldShow = rage.showFOV and rage.silentEnabled
            fovCircle.Visible = shouldShow
            if shouldShow then
                pcall(function()
                    fovCircle.Radius = rage.fov
                    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    if esp and esp.rainbow then
                        fovCircle.Color = Color3.fromHSV((tick() % 5)/5, 0.85, 1)
                    else
                        fovCircle.Color = Color3.fromRGB(255,255,255)
                    end
                end)
            end
        end
    end)
    table.insert(HUB.conns, fovConn)
end
RageAimSub:AddDivider()
RageAimSub:AddToggle({
    Title = "Silent Aim", Default = false, Flag = "rage_silent",
    Description = "Redirects gun Raycast to nearest player in FOV (GunHandler.shoot hook)",
    Callback = function(v)
        rage.silentEnabled = v
        Notify("Rage", v and "Silent Aim ON" or "Silent Aim OFF", v and "Success" or "Error")
    end,
})
RageAimSub:AddSlider({
    Title = "FOV Radius", Min = 10, Max = 600, Default = 150, Suffix = "px", Flag = "rage_fov",
    Callback = function(v) rage.fov = v end,
})
RageAimSub:AddToggle({
    Title = "Show FOV", Default = true, Flag = "rage_showfov",
    Callback = function(v) rage.showFOV = v end,
})
RageAimSub:AddToggle({
    Title = "Team Check", Default = true, Flag = "rage_teamcheck",
    Callback = function(v) rage.teamCheck = v end,
})
RageAimSub:AddToggle({
    Title = "Wall Check", Default = false, Flag = "rage_wallcheck",
    Description = "Only target visible enemies (raycast)",
    Callback = function(v) rage.visibleCheck = v end,
})
local applyHitPart = function(v) rage.hitPart = v end
local hitPartDropdown = RageAimSub:AddDropdown({
    Title = "Hit Part", Values = {"Head", "HumanoidRootPart", "UpperTorso", "Random"}, Default = "Head", MaxVisible = 4, Flag = "rage_hitpart",
    Callback = applyHitPart,
})
registerResync(hitPartDropdown, applyHitPart)
RageAimSub:AddSlider({
    Title = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Flag = "rage_hitchance",
    Callback = function(v) rage.hitChance = v end,
})
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
        Notify("Rage", v and "Hitbox ON" or "Hitbox OFF", v and "Success" or "Error")
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
RageTargetSub:AddDivider()
RageTargetSub:AddParagraph({Title="How Silent Aim picks", Text="FOV = nearest to mouse within circle. Nearest = closest world distance. Lowest HP = weakest in FOV. Chosen = you pick the player."})
local function GetRagePlayerNames()
    local names={}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    table.sort(names)
    if #names==0 then return {"(no players)"} end
    return names
end
local function ResolveRagePlayer(name)
    for _,plr in ipairs(Players:GetPlayers()) do if plr.Name==name then return plr end end
    return nil
end
local applyTargetMode = function(v)
    if v:find("FOV") then rage.targetMode="FOV"
    elseif v:find("Nearest") then rage.targetMode="Nearest"
    elseif v:find("Lowest") then rage.targetMode="Lowest"
    elseif v:find("Chosen") then rage.targetMode="Chosen"
    else rage.targetMode=v end
end
local targetModeDropdown = RageTargetSub:AddDropdown({
    Name="Target Mode", Values = {"FOV (Mouse)", "Nearest (World)", "Lowest HP", "Chosen"}, Default="FOV (Mouse)", MaxVisible=4, Flag="rage_targetmode",
    Callback=applyTargetMode,
})
registerResync(targetModeDropdown, applyTargetMode)
local applyChosen = function(v) rage.chosenTarget=v end
local chosenDropdown = RageTargetSub:AddDropdown({
    Name="Chosen Player", Options=GetRagePlayerNames(), Default=nil, MaxVisible=6, Searchable=true, Flag="rage_chosen",
    Callback=applyChosen,
})
registerResync(chosenDropdown, applyChosen)
RageTargetSub:AddButton({
    Name="Refresh Players",
    Callback=function() chosenDropdown:SetOptions(GetRagePlayerNames()); Notify("Target","Players refreshed","Info") end,
})
RageTargetSub:AddParagraph({Title="Current", Text="Silent Aim will use the mode above. Chosen ignores FOV."})
RageHitboxSub:AddDivider()
local noRecoilEnabled = false
RageHitboxSub:AddToggle({
    Title = "Anti-Recoil (visual)", Default = false, Flag = "rage_norecoil",
    Description = "Reduces camera kick after shooting (client visual)",
    Callback = function(v) noRecoilEnabled = v end,
})
local function getClosestTarget()
    if not rage.silentEnabled then return nil end
    if math.random(1,100) > rage.hitChance then return nil end
    if rage.targetMode == "Chosen" and rage.chosenTarget and rage.chosenTarget ~= "(no players)" then
        local plr = ResolveRagePlayer(rage.chosenTarget)
        if plr and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if rage.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return nil end
                local want = rage.hitPart
                if want == "Random" then want = (math.random() > 0.5) and "Head" or "HumanoidRootPart" end
                local part = char:FindFirstChild(want) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if part and part:IsA("BasePart") then
                    if rage.visibleCheck then
                        local camPos2 = Camera.CFrame.Position
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
                        local dir2 = part.Position - camPos2
                        local res2 = Workspace:Raycast(camPos2, dir2, params)
                        if res2 and res2.Instance and not res2.Instance:IsDescendantOf(char) then return nil end
                    end
                    return part
                end
            end
        end
        return nil
    end
    local camPos = Camera.CFrame.Position
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local mPos = UserInputService:GetMouseLocation()
    local ref = (mPos.Magnitude < 5) and center or mPos
    local myPos = GetHRP() and GetHRP().Position or camPos
    local closestPart = nil
    if rage.targetMode == "Nearest" then
        local bestDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not (rage.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if char and hum and hum.Health > 0 then
                        local want = rage.hitPart
                        if want == "Random" then want = (math.random() > 0.5) and "Head" or "HumanoidRootPart" end
                        local part = char:FindFirstChild(want) or char:FindFirstChild("HumanoidRootPart")
                        if part and part:IsA("BasePart") then
                            local skip=false
                            if rage.visibleCheck then
                                local params = RaycastParams.new()
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
                                local dir = part.Position - camPos
                                local res = Workspace:Raycast(camPos, dir, params)
                                if res and res.Instance and not res.Instance:IsDescendantOf(char) then skip=true end
                            end
                            if not skip then
                                local d = (part.Position - myPos).Magnitude
                                if d < bestDist then bestDist=d; closestPart=part end
                            end
                        end
                    end
                end
            end
        end
        return closestPart
    elseif rage.targetMode == "Lowest" then
        local bestHP = math.huge
        local bestDistFOV = rage.fov
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not (rage.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if char and hum and hum.Health > 0 then
                        local want = rage.hitPart
                        if want == "Random" then want = (math.random() > 0.5) and "Head" or "HumanoidRootPart" end
                        local part = char:FindFirstChild(want) or char:FindFirstChild("HumanoidRootPart")
                        if part and part:IsA("BasePart") then
                            local sp, on = Camera:WorldToViewportPoint(part.Position)
                            if on and sp.Z > 0 then
                                local dist = (Vector2.new(sp.X, sp.Y) - ref).Magnitude
                                if dist <= rage.fov then
                                    local skip=false
                                    if rage.visibleCheck then
                                        local params = RaycastParams.new()
                                        params.FilterType = Enum.RaycastFilterType.Exclude
                                        params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
                                        local dir = part.Position - camPos
                                        local res = Workspace:Raycast(camPos, dir, params)
                                        if res and res.Instance and not res.Instance:IsDescendantOf(char) then skip=true end
                                    end
                                    if not skip and hum.Health < bestHP then
                                        bestHP = hum.Health
                                        closestPart = part
                                        bestDistFOV = dist
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return closestPart
    end
    local closestDist = rage.fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local skip = false
            if rage.teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                skip = true
            end
            local char = plr.Character
            if not skip and not char then skip = true end
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not skip and (not hum or hum.Health <= 0) then skip = true end
            local part
            if not skip then
                local want = rage.hitPart
                if want == "Random" then want = (math.random() > 0.5) and "Head" or "HumanoidRootPart" end
                part = char:FindFirstChild(want) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if not part or not part:IsA("BasePart") then skip = true end
            end
            if not skip and rage.visibleCheck and part then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
                local dir = part.Position - camPos
                local res = Workspace:Raycast(camPos, dir, params)
                if res and res.Instance and not res.Instance:IsDescendantOf(char) then skip = true end
            end
            if not skip and part then
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then
                    local dist = (Vector2.new(sp.X, sp.Y) - ref).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = part
                    end
                end
            end
        end
    end
    return closestPart
end
do
    local G = getgenv and getgenv() or _G
    if G.OxideRageHooked then
        print("Rage: already hooked, skipping")
    else
        G.OxideRageHooked = true
        local ok, mod = pcall(function() return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GunHandler")) end)
        if ok and mod and type(mod.getAim) == "function" then
            local HookFn2 = hookfunction or replaceclosure
            if HookFn2 then
                local origAim
                origAim = HookFn2(mod.getAim, function(origin, range)
                    if rage.silentEnabled then
                        local okT, tgt = pcall(getClosestTarget)
                        if okT and tgt then
                            local dir = (tgt.Position - origin).Unit
                            return dir, (tgt.Position - origin).Magnitude
                        end
                    end
                    return origAim(origin, range)
                end)
                G.OxideRageOrigAim = origAim
                print("Rage: GunHandler.getAim hooked")
            end
        end
        if ok and mod and type(mod.shoot) == "function" and not G.OxideRageOrigShoot then
            local HookFn = hookfunction or replaceclosure
            if HookFn then
                local origShoot
                origShoot = HookFn(mod.shoot, function(p26)
                    if rage.silentEnabled and p26 and p26.Shooter == LocalPlayer.Character and p26.AimPosition then
                        local okT, tgt = pcall(getClosestTarget)
                        if okT and tgt then
                            local vel = tgt.AssemblyLinearVelocity or Vector3.zero
                            local pred = tgt.Position + vel * 0.13
                            p26.AimPosition = pred
                        end
                    end
                    return origShoot(p26)
                end)
                G.OxideRageOrigShoot = origShoot
                if not origShoot then
                    local plainOrig = mod.shoot
                    G.OxideRageOrigShoot = plainOrig
                    mod.shoot = function(p26)
                        if rage.silentEnabled and p26 and p26.Shooter == LocalPlayer.Character and p26.AimPosition then
                            local okT, tgt = pcall(getClosestTarget)
                            if okT and tgt then p26.AimPosition = tgt.Position + (tgt.AssemblyLinearVelocity or Vector3.zero) * 0.13 end
                        end
                        return plainOrig(p26)
                    end
                end
            else
                local plainOrig = mod.shoot
                G.OxideRageOrigShoot = plainOrig
                mod.shoot = function(p26)
                    if rage.silentEnabled and p26 and p26.Shooter == LocalPlayer.Character and p26.AimPosition then
                        local okT, tgt = pcall(getClosestTarget)
                        if okT and tgt then p26.AimPosition = tgt.Position + (tgt.AssemblyLinearVelocity or Vector3.zero) * 0.13 end
                    end
                    return plainOrig(p26)
                end
            end
            print("Rage: GunHandler.shoot hooked for Silent Aim")
        elseif G.OxideRageOrigShoot then
            print("Rage: using existing hook")
        else
            if not G.OxideRageRayHooked then
                G.OxideRageRayHooked = true
                local origRay = Workspace.Raycast
                G.OxideRageOrigRay = origRay
                local HookFn2 = hookfunction
                if HookFn2 then
                    local orig
                    orig = HookFn2(Workspace.Raycast, function(self, origin, direction, params)
                        if rage.silentEnabled and self == Workspace and direction.Magnitude > 30 then
                            local okT, tgt = pcall(getClosestTarget)
                            if okT and tgt then
                                local newDir = (tgt.Position - origin).Unit * direction.Magnitude
                                return orig(self, origin, newDir, params)
                            end
                        end
                        return orig(self, origin, direction, params)
                    end)
                    G.OxideRageOrigRay = orig
                else
                    local plainRay = Workspace.Raycast
                    Workspace.Raycast = function(self, origin, direction, params)
                        if rage.silentEnabled and self == Workspace and direction.Magnitude > 30 then
                            local okT, tgt = pcall(getClosestTarget)
                            if okT and tgt then
                                local newDir = (tgt.Position - origin).Unit * direction.Magnitude
                                return plainRay(self, origin, newDir, params)
                            end
                        end
                        return plainRay(self, origin, direction, params)
                    end
                end
                print("Rage: fallback Raycast hook installed")
            else
                print("Rage: Raycast already hooked")
            end
        end
    end
end
local SystemTab = Window:AddTab({ Title = "System", Icon = "solar/settings-bold" })
local MoneySub = SystemTab:AddSection("Balance", "solar/home-bold")
local moneyLabel
local moneyText = ("Cash: $%s\nWanted: %d"):format(FormatMoney(GetCurrency()), math.floor(GetWanted()))
local moneyParagraph = MoneySub:AddParagraph({ Title = "Live Balance", Text = moneyText })
moneyLabel = moneyParagraph
local function RefreshMoneyCard()
    local text = ("Cash: $%s\nWanted: %d"):format(FormatMoney(GetCurrency()), math.floor(GetWanted()))
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
MoneySub:AddDivider()
local autoCollect = false
local autoCollectSpeed = 60
MoneySub:AddToggle({
    Title = "Auto Collect Cash", Default = false, Flag = "auto_collect",
    Description = "Walks to nearest MoneyDrop and collects it",
    Callback = function(v)
        autoCollect = v
        Notify("Money", v and "Auto Collect ON" or "Auto Collect OFF", v and "Success" or "Error")
    end,
})
MoneySub:AddSlider({
    Title = "Collect Interval", Min = 0.2, Max = 3, Default = 0.8, Suffix = "s", Flag = "auto_collect_speed",
    Callback = function(v) autoCollectSpeed = v end,
})
task.spawn(function()
    local function getNearestDrop()
        local d = Workspace:FindFirstChild("Drop")
        if not d then local ign=Workspace:FindFirstChild("Ignored"); if ign then d=ign:FindFirstChild("Drop") end end
        if not d then return nil end
        local hrp = GetHRP()
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, part in ipairs(d:GetChildren()) do
            if part.Name=="MoneyDrop" and part:IsA("BasePart") then
                local dist=(part.Position - hrp.Position).Magnitude
                if dist < bestDist then best=part; bestDist=dist end
            end
        end
        return best
    end
    while not HUB.dead do
        if autoCollect then
            local ok = pcall(function()
                local drop = getNearestDrop()
                local hrp = GetHRP()
                if drop and hrp then
                    local dist=(drop.Position - hrp.Position).Magnitude
                    if dist < 14 then
                        hrp.CFrame = drop.CFrame * CFrame.new(0,2,0)
                    else
                        local TweenService=game:GetService("TweenService")
                        local tw=TweenService:Create(hrp, TweenInfo.new(math.clamp(dist/60,0.3,1.2), Enum.EasingStyle.Linear), {CFrame = drop.CFrame * CFrame.new(0,2,0)})
                        tw:Play(); tw.Completed:Wait()
                    end
                end
            end)
            if not ok then task.wait(1) end
        end
        task.wait(autoCollect and autoCollectSpeed or 0.5)
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
ServerSub:AddParagraph({
    Title = "Session Info",
    Text = ("Place: %d\nJob: %s\nPlayers: %d/%d")
        :format(game.PlaceId, tostring(game.JobId), #Players:GetPlayers(), Players.MaxPlayers),
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
                local money = GetCurrency()
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
local function Cleanup()
    flying = false; noclip = false; infJump = false
    antiRagdoll = false; wsEnabled = false; jpEnabled = false; hipEnabled = false
    pcall(function() if flyConn then flyConn:Disconnect() end end)
    pcall(stopNoclip)
    pcall(stopAntiRagdoll)
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() if hitboxEnabled then stopHitboxLoop() end end)
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    for _, h in ipairs(HUB.highlights) do pcall(function() h:Destroy() end) end
    table.clear(playerObjects)
    for part, highlight in pairs(moneyESP) do
        pcall(function() highlight:Destroy() end)
        moneyESP[part] = nil
    end
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
        _G.OxideDaHood = nil
    end,
})
Notify("Da Hood", "NevaHub loaded — $" .. FormatMoney(GetCurrency()), "Success", 3)
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
