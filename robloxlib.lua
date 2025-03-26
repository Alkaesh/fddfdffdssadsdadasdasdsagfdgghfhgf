-- MyRobloxLib.lua
local MyRobloxLib = {}

-- Основные сервисы
local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInput = game:GetService("UserInputService")
}

-- Локальные утилиты
local function getPlayer()
    return Services.Players.LocalPlayer
end

-- Секция GUI
MyRobloxLib.Menu = {}

-- Система уведомлений
local notificationContainer = nil
local function setupNotifications()
    if not notificationContainer then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Parent = getPlayer():WaitForChild("PlayerGui")
        screenGui.Name = "Notifications"
        screenGui.ResetOnSpawn = false
        
        notificationContainer = Instance.new("Frame")
        notificationContainer.Parent = screenGui
        notificationContainer.Size = UDim2.new(0, 300, 1, 0)
        notificationContainer.Position = UDim2.new(1, -310, 0, 10)
        notificationContainer.BackgroundTransparency = 1
    end
end

function MyRobloxLib.Menu:Notify(message, duration)
    setupNotifications()
    
    local notification = Instance.new("Frame")
    notification.Parent = notificationContainer
    notification.Size = UDim2.new(1, 0, 0, 30)
    notification.Position = UDim2.new(0, 0, 0, (#notificationContainer:GetChildren() - 1) * 40)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = notification
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 0, 0, (#notificationContainer:GetChildren() - 1) * 40)
    Services.TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, (#notificationContainer:GetChildren() - 1) * 40)}
    ):Play()
    
    -- Исчезновение через заданное время
    duration = duration or 3
    spawn(function()
        wait(duration)
        Services.TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 0, 0, notification.Position.Y.Offset)}
        ):Play()
        wait(0.3)
        notification:Destroy()
        
        -- Обновляем позиции оставшихся уведомлений
        for i, notif in ipairs(notificationContainer:GetChildren()) do
            Services.TweenService:Create(
                notif,
                TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, (i - 1) * 40)}
            ):Play()
        end
    end)
end

-- Создание меню в стиле Fatality
function MyRobloxLib.Menu:CreateMenu(title)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = getPlayer():WaitForChild("PlayerGui")
    screenGui.Name = "CustomMenu"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.ClipsDescendants = true
    
    local gradient = Instance.new("UIGradient")
    gradient.Parent = mainFrame
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
    })
    gradient.Rotation = 90
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = mainFrame
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    tabFrame.BackgroundTransparency = 0.1
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    contentFrame.BackgroundTransparency = 0.1
    contentFrame.ClipsDescendants = true
    
    local menu = {
        Gui = screenGui,
        MainFrame = mainFrame,
        Tabs = {},
        CurrentTab = nil,
        ContentFrame = contentFrame,
        TabFrame = tabFrame,
        Elements = {},
        Visible = true
    }
    
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    Services.TweenService:Create(
        mainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -300, 0.5, -200)}
    ):Play()
    
    local dragging, dragStart, startPos
    tabFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    Services.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return menu
end

function MyRobloxLib.Menu:ShowMenu(menu)
    if not menu.Visible then
        menu.Visible = true
        menu.MainFrame.Visible = true
        Services.TweenService:Create(
            menu.MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -300, 0.5, -200)}
        ):Play()
    end
end

function MyRobloxLib.Menu:HideMenu(menu)
    if menu.Visible then
        menu.Visible = false
        local tween = Services.TweenService:Create(
            menu.MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -300, 1.5, -200)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            menu.MainFrame.Visible = false
        end)
    end
end

function MyRobloxLib.Menu:AddTab(menu, name)
    local tabCount = #menu.Tabs
    local tabButton = Instance.new("TextButton")
    tabButton.Parent = menu.TabFrame
    tabButton.Size = UDim2.new(0, 100, 1, -10)
    tabButton.Position = UDim2.new(0, 10 + (tabCount * 110), 0, 5)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = name:upper()
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.TextSize = 16
    tabButton.Font = Enum.Font.SourceSansBold
    
    local underline = Instance.new("Frame")
    underline.Parent = tabButton
    underline.Size = UDim2.new(1, 0, 0, 2)
    underline.Position = UDim2.new(0, 0, 1, -2)
    underline.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    underline.Visible = false
    
    local content = Instance.new("Frame")
    content.Parent = menu.ContentFrame
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    content.BackgroundTransparency = 0.1
    content.Visible = false
    
    local tab = {Button = tabButton, Underline = underline, Content = content, Elements = {}}
    
    tabButton.MouseButton1Click:Connect(function()
        if menu.CurrentTab then
            menu.CurrentTab.Content.Visible = false
            menu.CurrentTab.Underline.Visible = false
        end
        menu.CurrentTab = tab
        tab.Content.Visible = true
        tab.Underline.Visible = true
    end)
    
    if tabCount == 0 then
        menu.CurrentTab = tab
        tab.Content.Visible = true
        tab.Underline.Visible = true
    end
    
    table.insert(menu.Tabs, tab)
    return tab
end

function MyRobloxLib.Menu:AddSection(tab, name)
    local elementCount = #tab.Elements
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Parent = tab.Content
    sectionLabel.Size = UDim2.new(0.95, 0, 0, 20)
    sectionLabel.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = name:upper()
    sectionLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
    sectionLabel.TextSize = 14
    sectionLabel.Font = Enum.Font.SourceSansBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    table.insert(tab.Elements, sectionLabel)
    return sectionLabel
end

function MyRobloxLib.Menu:AddButton(tab, text, callback)
    local elementCount = #tab.Elements
    local button = Instance.new("TextButton")
    button.Parent = tab.Content
    button.Size = UDim2.new(0.3, 0, 0, 25)
    button.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    button.Text = text:upper()
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.SourceSans
    
    button.MouseButton1Click:Connect(callback)
    table.insert(tab.Elements, button)
    return button
end

function MyRobloxLib.Menu:AddToggle(tab, text, default, callback)
    local elementCount = #tab.Elements
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(0.95, 0, 0, 25)
    frame.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0, 2.5)
    toggle.Text = default and "ON" or "OFF"
    toggle.BackgroundColor3 = default and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 50)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextSize = 10
    
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        toggle.BackgroundColor3 = state and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
    
    table.insert(tab.Elements, frame)
    return toggle
end

function MyRobloxLib.Menu:AddSlider(tab, text, min, max, default, callback)
    local elementCount = #tab.Elements
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(0.95, 0, 0, 25)
    frame.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. " [" .. default .. "]"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = frame
    sliderBar.Size = UDim2.new(0, 100, 0, 5)
    sliderBar.Position = UDim2.new(0.6, 0, 0, 10)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBar
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Services.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X - sliderBar.AbsolutePosition.X
            local percent = math.clamp(mousePos / sliderBar.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. " [" .. math.floor(value) .. "]"
            callback(math.floor(value))
        end
    end)
    
    table.insert(tab.Elements, frame)
    return frame
end

function MyRobloxLib.Menu:AddTextBox(tab, text, default, callback)
    local elementCount = #tab.Elements
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(0.95, 0, 0, 25)
    frame.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local textBox = Instance.new("TextBox")
    textBox.Parent = frame
    textBox.Size = UDim2.new(0, 100, 0, 20)
    textBox.Position = UDim2.new(1, -100, 0, 2.5)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.Text = default or ""
    textBox.TextSize = 12
    textBox.Font = Enum.Font.SourceSans
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)
    
    table.insert(tab.Elements, frame)
    return textBox
end

function MyRobloxLib.Menu:AddColorPicker(tab, text, defaultColor, callback)
    local elementCount = #tab.Elements
    local frame = Instance.new("Frame")
    frame.Parent = tab.Content
    frame.Size = UDim2.new(0.95, 0, 0, 25)
    frame.Position = UDim2.new(0.025, 0, 0, 10 + (elementCount * 30))
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Parent = frame
    colorDisplay.Size = UDim2.new(0, 40, 0, 20)
    colorDisplay.Position = UDim2.new(1, -40, 0, 2.5)
    colorDisplay.BackgroundColor3 = defaultColor
    colorDisplay.Text = ""
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Parent = frame
    pickerFrame.Size = UDim2.new(0, 200, 0, 0)
    pickerFrame.Position = UDim2.new(0, 0, 1, 0)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    pickerFrame.ClipsDescendants = true
    pickerFrame.Visible = false
    
    local palette = Instance.new("ImageLabel")
    palette.Parent = pickerFrame
    palette.Size = UDim2.new(0, 180, 0, 100)
    palette.Position = UDim2.new(0, 10, 0, 10)
    palette.Image = "rbxassetid://698052001"
    palette.BackgroundTransparency = 1
    
    local cursor = Instance.new("Frame")
    cursor.Parent = palette
    cursor.Size = UDim2.new(0, 5, 0, 5)
    cursor.BackgroundColor3 = Color3.new(1, 1, 1)
    cursor.BorderSizePixel = 0
    
    local function updateColor(h, s)
        local color = Color3.fromHSV(h, s, 1)
        colorDisplay.BackgroundColor3 = color
        callback(color)
    end
    
    local dragging = false
    palette.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    palette.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp((input.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X, 0, 1)
            local y = math.clamp((input.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y, 0, 1)
            cursor.Position = UDim2.new(0, x * palette.AbsoluteSize.X - 2.5, 0, y * palette.AbsoluteSize.Y - 2.5)
            updateColor(x, 1 - y)
        end
    end)
    
    colorDisplay.MouseButton1Click:Connect(function()
        pickerFrame.Visible = not pickerFrame.Visible
        pickerFrame.Size = pickerFrame.Visible and UDim2.new(0, 200, 0, 120) or UDim2.new(0, 200, 0, 0)
    end)
    
    table.insert(tab.Elements, frame)
    return colorDisplay
end

return MyRobloxLib
