local Lib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Основные настройки UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EpicCheatMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Основной фрейм меню с градиентом
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Градиент для фона
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 80))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Тень с эффектом свечения
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Parent = mainFrame

-- Заголовок меню с RGB эффектом
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
titleLabel.Text = "Epic Cheat Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.BorderSizePixel = 0
titleLabel.Parent = mainFrame

-- RGB анимация для заголовка
local function updateRGB()
    local time = tick()
    local r = math.sin(time * 0.5) * 127 + 128
    local g = math.sin(time * 0.5 + 2) * 127 + 128
    local b = math.sin(time * 0.5 + 4) * 127 + 128
    titleLabel.TextColor3 = Color3.fromRGB(r, g, b)
end
RunService.Heartbeat:Connect(updateRGB)

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "✖"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleLabel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- Контейнер для вкладок
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 140, 1, -50)
tabContainer.Position = UDim2.new(0, 0, 0, 50)
tabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

-- Контейнер для содержимого вкладок
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -140, 1, -50)
contentContainer.Position = UDim2.new(0, 140, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainFrame

-- UIListLayout для вкладок
local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 8)
tabListLayout.Parent = tabContainer

-- UIPadding для вкладок
local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.Parent = tabContainer

-- Делаем фрейм перетаскиваемым
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    titleLabel.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
makeDraggable(mainFrame)

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

    -- Горячая клавиша для показа/скрытия (Right Shift)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            if menu.Visible then
                Lib.Menu:HideMenu(menu)
            else
                Lib.Menu:ShowMenu(menu)
            end
        end
    end)

    return menu
end

-- Функция для показа меню с анимацией
function Lib.Menu:ShowMenu(menu)
    menu.Visible = true
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200)
    })
    tween:Play()
end

-- Функция для скрытия меню
function Lib.Menu:HideMenu(menu)
    menu.Visible = false
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        mainFrame.Visible = false
    end)
end

-- Функция для добавления вкладки
function Lib.Menu:AddTab(menu, tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -10, 0, 40)
    tabButton.Position = UDim2.new(0, 5, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 16
    tabButton.Font = Enum.Font.Gotham
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabContainer
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton

    -- Градиент для активной вкладки
    local tabGradient = Instance.new("UIGradient")
    tabGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 100))
    })
    tabGradient.Enabled = false
    tabGradient.Parent = tabButton

    -- Эффект наведения
    tabButton.MouseEnter:Connect(function()
        if menu.CurrentTab ~= tab then
            local tween = TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
            tween:Play()
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if menu.CurrentTab ~= tab then
            local tween = TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)})
            tween:Play()
        end
    end)

    -- ScrollingFrame для содержимого вкладки
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    tabContent.Visible = false
    tabContent.Parent = contentContainer

    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentListLayout.Padding = UDim.new(0, 8)
    contentListLayout.Parent = tabContent

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.Parent = tabContent

    contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 30)
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
            menu.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            menu.CurrentTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            menu.CurrentTab.Content.Visible = false
            menu.CurrentTab.Button:FindFirstChild("UIGradient").Enabled = false
        end
        menu.CurrentTab = tab
        tabGradient.Enabled = true
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Content.Visible = true
        local tween = TweenService:Create(tab.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {CanvasPosition = Vector2.new(0, 0)})
        tween:Play()
    end)

    if not menu.CurrentTab then
        menu.CurrentTab = tab
        tabGradient.Enabled = true
        tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        tab.Content.Visible = true
    end

    return tab
end

-- Функция для добавления секции
function Lib.Menu:AddSection(tab, sectionName)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 40)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Parent = tab.Content
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 6)
    sectionCorner.Parent = sectionFrame

    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, -20, 1, 0)
    sectionLabel.Position = UDim2.new(0, 10, 0, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = sectionName
    sectionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    sectionLabel.TextSize = 18
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.TextYAlignment = Enum.TextYAlignment.Center
    sectionLabel.Parent = sectionFrame

    table.insert(tab.Elements, sectionFrame)
end

-- Функция для добавления переключателя
function Lib.Menu:AddToggle(tab, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Content

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.TextSize = 16
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 25)
    toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    toggleButton.Text = default and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton

    local toggleState = default
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        local targetColor = toggleState and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor})
        tween:Play()
        toggleButton.Text = toggleState and "ON" or "OFF"
        callback(toggleState)
    end)

    table.insert(tab.Elements, toggleFrame)
end

-- Функция для добавления слайдера
function Lib.Menu:AddSlider(tab, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Content

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 25)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    sliderLabel.TextSize = 16
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 12)
    sliderBar.Position = UDim2.new(0, 0, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = sliderBar

    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fillBar

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 24, 0, 24)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -12, 0, -6)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBar
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
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

            local tween = TweenService:Create(fillBar, TweenInfo.new(0.1), {Size = UDim2.new(fraction, 0, 1, 0)})
            tween:Play()
            sliderButton.Position = UDim2.new(fraction, -12, 0, -6)
            sliderLabel.Text = name .. ": " .. value
            callback(value)
        end
    end)

    table.insert(tab.Elements, sliderFrame)
end

-- Функция для добавления кнопки
function Lib.Menu:AddButton(tab, name, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = tab.Content

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    button.Parent = buttonFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        callback()
        local tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)})
        tween:Play()
        wait(0.1)
        tween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)})
        tween:Play()
    end)
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
        tween:Play()
    end)
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)})
        tween:Play()
    end)

    table.insert(tab.Elements, buttonFrame)
end

-- Функция для добавления текстового поля
function Lib.Menu:AddTextBox(tab, name, default, callback)
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Size = UDim2.new(1, 0, 0, 40)
    textBoxFrame.BackgroundTransparency = 1
    textBoxFrame.Parent = tab.Content

    local textBoxLabel = Instance.new("TextLabel")
    textBoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
    textBoxLabel.BackgroundTransparency = 1
    textBoxLabel.Text = name
    textBoxLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    textBoxLabel.TextSize = 16
    textBoxLabel.Font = Enum.Font.Gotham
    textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    textBoxLabel.TextYAlignment = Enum.TextYAlignment.Center
    textBoxLabel.Parent = textBoxFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.5, 0, 0, 25)
    textBox.Position = UDim2.new(0.5, 0, 0.5, -12.5)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textBox.Text = default
    textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.BorderSizePixel = 0
    textBox.Parent = textBoxFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)

    table.insert(tab.Elements, textBoxFrame)
    return textBox
end

-- Улучшенный ColorPicker
function Lib.Menu:AddColorPicker(tab, name, defaultColor, callback)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Size = UDim2.new(1, 0, 0, 40)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = tab.Content

    local colorPickerLabel = Instance.new("TextLabel")
    colorPickerLabel.Size = UDim2.new(0.7, 0, 1, 0)
    colorPickerLabel.BackgroundTransparency = 1
    colorPickerLabel.Text = name
    colorPickerLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    colorPickerLabel.TextSize = 16
    colorPickerLabel.Font = Enum.Font.Gotham
    colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerLabel.TextYAlignment = Enum.TextYAlignment.Center
    colorPickerLabel.Parent = colorPickerFrame

    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0, 40, 0, 25)
    colorButton.Position = UDim2.new(1, -40, 0.5, -12.5)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.Text = ""
    colorButton.BorderSizePixel = 0
    colorButton.Parent = colorPickerFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = colorButton

    -- Панель выбора цвета
    local colorPanel = Instance.new("Frame")
    colorPanel.Size = UDim2.new(0, 200, 0, 150)
    colorPanel.Position = UDim2.new(1, -210, 1, 5)
    colorPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    colorPanel.BorderSizePixel = 0
    colorPanel.Visible = false
    colorPanel.Parent = colorPickerFrame
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = colorPanel

    -- Ползунок для оттенка
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 20, 1, -20)
    hueBar.Position = UDim2.new(0, 10, 0, 10)
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueBar.Parent = colorPanel
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueBar

    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(1, 0, 0, 4)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSlider.BorderSizePixel = 0
    hueSlider.Parent = hueBar

    -- Цветовая палитра
    local colorSquare = Instance.new("ImageLabel")
    colorSquare.Size = UDim2.new(0, 150, 0, 150)
    colorSquare.Position = UDim2.new(0, 40, 0, 10)
    colorSquare.BackgroundTransparency = 1
    colorSquare.Image = "rbxassetid://698052001"
    colorSquare.Parent = colorPanel

    local colorCursor = Instance.new("Frame")
    colorCursor.Size = UDim2.new(0, 8, 0, 8)
    colorCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorCursor.BorderSizePixel = 0
    colorCursor.Parent = colorSquare
    local cursorCorner = Instance.new("UICorner")
    cursorCorner.CornerRadius = UDim.new(0, 4)
    cursorCorner.Parent = colorCursor

    local function updateColor(hue, sat, val)
        local color = Color3.fromHSV(hue, sat, val)
        colorButton.BackgroundColor3 = color
        callback(color)
    end

    local isPickingHue = false
    local isPickingSquare = false

    colorButton.MouseButton1Click:Connect(function()
        colorPanel.Visible = not colorPanel.Visible
    end)

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPickingHue = true
        end
    end)

    colorSquare.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPickingSquare = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isPickingHue = false
            isPickingSquare = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            if isPickingHue then
                local hueFraction = math.clamp((mousePos.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                hueSlider.Position = UDim2.new(0, 0, hueFraction, 0)
                updateColor(hueFraction, 1, 1)
            elseif isPickingSquare then
                local squarePos = mousePos - colorSquare.AbsolutePosition
                local sat = math.clamp(squarePos.X / colorSquare.AbsoluteSize.X, 0, 1)
                local val = math.clamp(1 - (squarePos.Y / colorSquare.AbsoluteSize.Y), 0, 1)
                colorCursor.Position = UDim2.new(sat, -4, 1 - val, -4)
                updateColor(hueSlider.Position.Y.Scale, sat, val)
            end
        end
    end)

    table.insert(tab.Elements, colorPickerFrame)
end

-- Улучшенная функция уведомлений
function Lib.Menu:Notify(message, duration)
    if not screenGui then
        warn("ScreenGui не инициализирован для уведомлений")
        return
    end

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, -310, 1, -90)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notificationFrame

    local notificationLabel = Instance.new("TextLabel")
    notificationLabel.Size = UDim2.new(1, -20, 1, -20)
    notificationLabel.Position = UDim2.new(0, 10, 0, 10)
    notificationLabel.BackgroundTransparency = 1
    notificationLabel.Text = message
    notificationLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    notificationLabel.TextSize = 14
    notificationLabel.Font = Enum.Font.Gotham
    notificationLabel.TextWrapped = true
    notificationLabel.TextXAlignment = Enum.TextXAlignment.Left
    notificationLabel.TextYAlignment = Enum.TextYAlignment.Top
    notificationLabel.Parent = notificationFrame

    local tweenIn = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -310, 1, -90)})
    tweenIn:Play()

    spawn(function()
        wait(duration or 3)
        local tweenOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 1, -90)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notificationFrame:Destroy()
        end)
    end)
end

-- Функция для выпадающего списка
function Lib.Menu:AddDropdown(tab, name, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = tab.Content

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = name
    dropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    dropdownLabel.TextSize = 16
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.TextYAlignment = Enum.TextYAlignment.Center
    dropdownLabel.Parent = dropdownFrame

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.5, 0, 0, 25)
    dropdownButton.Position = UDim2.new(0.5, 0, 0.5, -12.5)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropdownButton.Text = default or options[1]
    dropdownButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Parent = dropdownFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdownButton

    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0.5, 0, 0, #options * 25)
    dropdownList.Position = UDim2.new(0.5, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = dropdownList

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList

    for _, option in pairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.Gotham
        optionButton.Parent = dropdownList

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownList.Visible = false
            callback(option)
        end)

        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
    end)

    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        local tween = TweenService:Create(dropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0.5, 0, 0, dropdownList.Visible and #options * 25 or 0)})
        tween:Play()
    end)

    table.insert(tab.Elements, dropdownFrame)
end

-- Добавление эффекта частиц
local function addParticleEffect(parent)
    local particleEmitter = Instance.new("ImageLabel")
    particleEmitter.Size = UDim2.new(0, 10, 0, 10)
    particleEmitter.BackgroundTransparency = 1
    particleEmitter.Image = "rbxassetid://243098098"
    particleEmitter.ImageTransparency = 0.8
    particleEmitter.Parent = parent

    spawn(function()
        while particleEmitter.Parent do
            particleEmitter.Position = UDim2.new(math.random(), 0, math.random(), 0)
            local tween = TweenService:Create(particleEmitter, TweenInfo.new(2, Enum.EasingStyle.Quad), {ImageTransparency = 1, Position = UDim2.new(math.random(), 0, math.random(), 0)})
            tween:Play()
            wait(0.5)
        end
    end)
end
for i = 1, 5 do
    addParticleEffect(mainFrame)
end

return Lib
