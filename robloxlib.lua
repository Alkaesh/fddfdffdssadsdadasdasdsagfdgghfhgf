-- robloxlib.lua

local Lib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Основные настройки UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Основной фрейм меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Тень для основного фрейма
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Parent = mainFrame

-- Заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = "Cheat Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = titleLabel

-- Контейнер для вкладок (слева)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 120, 1, -40)
tabContainer.Position = UDim2.new(0, 0, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Контейнер для содержимого вкладок (справа)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -120, 1, -40)
contentContainer.Position = UDim2.new(0, 120, 0, 40)
contentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- UIListLayout для вкладок
local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 5)
tabListLayout.Parent = tabContainer

-- UIPadding для вкладок
local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.Parent = tabContainer

-- Создаем поле Menu внутри Lib
Lib.Menu = {}

-- Функция для создания меню
function Lib.Menu:CreateMenu(title)
    titleLabel.Text = title
    local menu = {
        Visible = true,
        Tabs = {},
        CurrentTab = nil
    }

    -- Обработчик кнопки закрытия
    closeButton.MouseButton1Click:Connect(function()
        Lib.Menu:HideMenu(menu)
    end)

    return menu
end

-- Функция для показа/скрытия меню с анимацией
function Lib.Menu:ShowMenu(menu)
    menu.Visible = true
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -225, 0.5, -175)})
    tween:Play()
end

function Lib.Menu:HideMenu(menu)
    menu.Visible = false
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -225, 0.5, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        mainFrame.Visible = false
    end)
end

-- Функция для добавления вкладки
function Lib.Menu:AddTab(menu, tabName)
    -- Создаем кнопку вкладки
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 35)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 16
    tabButton.Font = Enum.Font.SourceSans
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer

    -- Эффект наведения
    tabButton.MouseEnter:Connect(function()
        if menu.CurrentTab ~= tab then
            tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if menu.CurrentTab ~= tab then
            tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
    end)

    -- Создаем ScrollingFrame для содержимого вкладки
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 6
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tabContent.Visible = false
    tabContent.Parent = contentContainer

    -- UIListLayout для содержимого вкладки
    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentListLayout.Padding = UDim.new(0, 5)
    contentListLayout.Parent = tabContent

    -- UIPadding для содержимого
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.Parent = tabContent

    -- Обновляем CanvasSize при изменении содержимого
    contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 20)
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
            menu.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            menu.CurrentTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            menu.CurrentTab.Content.Visible = false
        end
        menu.CurrentTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Content.Visible = true
    end)

    -- Устанавливаем первую вкладку активной
    if not menu.CurrentTab then
        menu.CurrentTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Content.Visible = true
    end

    return tab
end

-- Функция для добавления секции
function Lib.Menu:AddSection(tab, sectionName)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 30)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = tab.Content

    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, -10, 1, 0)
    sectionLabel.Position = UDim2.new(0, 5, 0, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = sectionName
    sectionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    sectionLabel.TextSize = 16
    sectionLabel.Font = Enum.Font.SourceSansBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.TextYAlignment = Enum.TextYAlignment.Center
    sectionLabel.Parent = sectionFrame

    table.insert(tab.Elements, sectionFrame)
end

-- Функция для добавления переключателя
function Lib.Menu:AddToggle(tab, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Content

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.SourceSans
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 20)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleButton.Text = default and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame

    -- Закругленные углы для кнопки
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = toggleButton

    local toggleState = default
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        toggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleButton.Text = toggleState and "ON" or "OFF"
        callback(toggleState)
    end)

    table.insert(tab.Elements, toggleFrame)
end

-- Функция для добавления слайдера
function Lib.Menu:AddSlider(tab, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Content

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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

    -- Закругленные углы для полосы слайдера
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 5)
    barCorner.Parent = sliderBar

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = fillBar

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -5)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBar

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton

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
    buttonFrame.Size = UDim2.new(1, 0, 0, 30)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = tab.Content

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.BorderSizePixel = 0
    button.Parent = buttonFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    table.insert(tab.Elements, buttonFrame)
end

-- Функция для добавления текстового поля
function Lib.Menu:AddTextBox(tab, name, default, callback)
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Size = UDim2.new(1, 0, 0, 30)
    textBoxFrame.BackgroundTransparency = 1
    textBoxFrame.Parent = tab.Content

    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Text = name
    textBoxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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
    textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.SourceSans
    textBox.BorderSizePixel = 0
    textBox.Parent = textBoxFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = textBox

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
    colorPickerFrame.Size = UDim2.new(1, 0, 0, 30)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = tab.Content

    local colorPickerLabel = Instance.new("TextLabel")
    colorPickerLabel.Size = UDim2.new(0.7, 0, 1, 0)
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Text = name
    colorPickerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = colorButton

    -- Простая реализация выбора цвета (можно заменить на полноценный ColorPicker)
    colorButton.MouseButton1Click:Connect(function()
        -- Здесь должен быть полноценный ColorPicker, но для примера используем случайный цвет
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        colorButton.BackgroundColor3 = newColor
        callback(newColor)
    end)

    table.insert(tab.Elements, colorPickerFrame)
end

-- Функция для уведомлений
function Lib.Menu:Notify(message, duration)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 250, 0, 60)
    notificationFrame.Position = UDim2.new(1, -260, 1, -70)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = notificationFrame

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, -10, 1, -10)
    notificationLabel.Position = UDim2.new(0, 5, 0, 5)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.Text = message
    notificationLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    notificationLabel.TextSize = 14
    notificationLabel.Font = Enum.Font.SourceSans
    notificationLabel.TextWrapped = true
    notificationLabel.TextXAlignment = Enum.TextXAlignment.Left
    notificationLabel.TextYAlignment = Enum.TextYAlignment.Top
    notificationLabel.Parent = notificationFrame

    spawn(function()
        wait(duration or 3)
        local tween = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 1, -70)})
        tween:Play()
        tween.Completed:Connect(function()
            notificationFrame:Destroy()
        end)
    end)
end

-- Функция для добавления выпадающего списка
function Lib.Menu:AddDropdown(tab, name, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = tab.Content

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdownLabel.TextSize = 14
    dropdownLabel.Font = Enum.Font.SourceSans
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.TextYAlignment = Enum.TextYAlignment.Center
    dropdownLabel.Parent = dropdownFrame

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.5, 0, 0, 20)
    dropdownButton.Position = UDim2.new(0.5, 0, 0.5, -10)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownButton.Text = default or options[1]
    dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Parent = dropdownFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = dropdownButton

    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.5, 0, 0, #options * 20)
    dropdownList.Position = UDim2.new(0.5, 0, 1, 0)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = dropdownList

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList

    for _, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 20)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Parent = dropdownList

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownList.Visible = false
            callback(option)
        end)

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0
            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end)
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
    end

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    table.insert(tab.Elements, dropdownFrame)
end

return Lib
