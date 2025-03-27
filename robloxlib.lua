-- robloxlib.lua

local Lib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Основные настройки UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Основной фрейм меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.Text = "Cheat Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame

-- Контейнер для вкладок (слева)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 100, 1, -30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Контейнер для содержимого вкладок (справа)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -100, 1, -30)
contentContainer.Position = UDim2.new(0, 100, 0, 30)
contentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- UIListLayout для вкладок
local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Parent = tabContainer

-- Функция для создания меню
function Lib.Menu:CreateMenu(title)
    titleLabel.Text = title
    local menu = {
        Visible = true,
        Tabs = {},
        CurrentTab = nil
    }
    return menu
end

-- Функция для показа/скрытия меню
function Lib.Menu:ShowMenu(menu)
    menu.Visible = true
    mainFrame.Visible = true
end

function Lib.Menu:HideMenu(menu)
    menu.Visible = false
    mainFrame.Visible = false
end

-- Функция для добавления вкладки
function Lib.Menu:AddTab(menu, tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.SourceSans
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer

    -- Создаем ScrollingFrame для содержимого вкладки
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Будет обновляться автоматически
    tabContent.ScrollBarThickness = 6
    tabContent.Visible = false
    tabContent.Parent = contentContainer

    -- UIListLayout для содержимого вкладки
    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentListLayout.Padding = UDim.new(0, 5)
    contentListLayout.Parent = tabContent

    -- Обновляем CanvasSize при добавлении новых элементов
    contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 10)
    end)

    local tab = {
        Name = tabName,
        Button = tabButton,
        Content = tabContent,
        Elements = {}
    }
    table.insert(menu.Tabs, tab)

    -- Переключение вкладок
    tabButton.MouseButton1Click:Connect(function()
        if menu.CurrentTab then
            menu.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            menu.CurrentTab.Content.Visible = false
        end
        menu.CurrentTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tab.Content.Visible = true
    end)

    -- Устанавливаем первую вкладку активной
    if not menu.CurrentTab then
        menu.CurrentTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tab.Content.Visible = true
    end

    return tab
end

-- Функция для добавления секции
function Lib.Menu:AddSection(tab, sectionName)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, -10, 0, 30)
    sectionFrame.Position = UDim2.new(0, 5, 0, 0)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = tab.Content

    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = sectionName
    sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionLabel.TextSize = 14
    sectionLabel.Font = Enum.Font.SourceSansBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.TextYAlignment = Enum.TextYAlignment.Center
    sectionLabel.Parent = sectionFrame

    table.insert(tab.Elements, sectionFrame)
end

-- Функция для добавления переключателя
function Lib.Menu:AddToggle(tab, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.Position = UDim2.new(0, 5, 0, 0)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Content

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.SourceSans
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 20)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    toggleButton.Text = default and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame

    local toggleState = default
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        toggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggleButton.Text = toggleState and "ON" or "OFF"
        callback(toggleState)
    end)

    table.insert(tab.Elements, toggleFrame)
end

-- Функция для добавления слайдера
function Lib.Menu:AddSlider(tab, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.Position = UDim2.new(0, 5, 0, 0)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Content

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.TextSize = 14
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 0, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -5)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBar

    local isDragging = false
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos - sliderBar.AbsolutePosition
            local fraction = math.clamp(relativePos.X / sliderBar.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * fraction
            value = math.floor(value)
            value = math.clamp(value, min, max)

            fillBar.Size = UDim2.new(fraction, 0, 1, 0)
            sliderButton.Position = UDim2.new(fraction, -10, 0, -5)
            sliderLabel.Text = name .. ": " .. value
            callback(value)
        end
    end)

    table.insert(tab.Elements, sliderFrame)
end

-- Функция для добавления кнопки
function Lib.Menu:AddButton(tab, name, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -10, 0, 30)
    buttonFrame.Position = UDim2.new(0, 5, 0, 0)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = tab.Content

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.BorderSizePixel = 0
    button.Parent = buttonFrame

    button.MouseButton1Click:Connect(callback)

    table.insert(tab.Elements, buttonFrame)
end

-- Функция для добавления текстового поля
function Lib.Menu:AddTextBox(tab, name, default, callback)
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Size = UDim2.new(1, -10, 0, 30)
    textBoxFrame.Position = UDim2.new(0, 5, 0, 0)
    textBoxFrame.BackgroundTransparency = 1
    textBoxFrame.Parent = tab.Content

    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Text = name
    textBoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBoxLabel.TextSize = 14
    textBoxLabel.Font = Enum.Font.SourceSans
    textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textBoxLabel.TextYAlignment = Enum.TextYAlignment.Center
    textBoxLabel.Parent = textBoxFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, 0, 0, 20)
    textBox.Position = UDim2.new(0.5, 0, 0.5, -10)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.Text = default
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.SourceSans
    textBox.BorderSizePixel = 0
    textBox.Parent = textBoxFrame

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)

    table.insert(tab.Elements, textBoxFrame)

    return textBox
end

-- Функция для добавления выбора цвета
function Lib.Menu:AddColorPicker(tab, name, defaultColor, callback)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Size = UDim2.new(1, -10, 0, 30)
    colorPickerFrame.Position = UDim2.new(0, 5, 0, 0)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = tab.Content

    local colorPickerLabel = Instance.new("TextLabel")
    colorPickerLabel.Size = UDim2.new(0.8, 0, 1, 0)
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Text = name
    colorPickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorPickerLabel.TextSize = 14
    colorPickerLabel.Font = Enum.Font.SourceSans
    colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerLabel.TextYAlignment = Enum.TextYAlignment.Center
    colorPickerLabel.Parent = colorPickerFrame

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 30, 0, 20)
    colorButton.Position = UDim2.new(1, -30, 0.5, -10)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.BorderSizePixel = 0
    colorButton.Parent = colorPickerFrame

    colorButton.MouseButton1Click:Connect(function()
        -- Здесь должен быть код для выбора цвета (упрощённый вариант)
        -- В реальной библиотеке это может быть сложнее
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        colorButton.BackgroundColor3 = newColor
        callback(newColor)
    end)

    table.insert(tab.Elements, colorPickerFrame)
end

-- Функция для уведомлений
function Lib.Menu:Notify(message, duration)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 200, 0, 50)
    notificationFrame.Position = UDim2.new(1, -210, 1, -60)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = screenGui

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, 0, 1, 0)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.Text = message
    notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationLabel.TextSize = 14
    notificationLabel.Font = Enum.Font.SourceSans
    notificationLabel.TextWrapped = true
    notificationLabel.Parent = notificationFrame

    spawn(function()
        wait(duration or 3)
        notificationFrame:Destroy()
    end)
end

return Lib
