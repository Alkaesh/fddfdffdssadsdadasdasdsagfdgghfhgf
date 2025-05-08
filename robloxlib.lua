-- CheatMenuLibrary.lua
-- Многофункциональная библиотека для создания красивого чит-меню в Roblox
local CheatMenuLibrary = {}
CheatMenuLibrary.__index = CheatMenuLibrary

-- Сервисы Roblox
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Создание нового экземпляра меню
function CheatMenuLibrary.new(config)
    local self = setmetatable({}, CheatMenuLibrary)
    
    -- Конфигурация по умолчанию
    self.config = {
        title = config.title or "Elite Cheat Menu",
        theme = config.theme or {
            primaryColor = Color3.fromRGB(30, 144, 255),
            secondaryColor = Color3.fromRGB(25, 25, 25),
            textColor = Color3.fromRGB(255, 255, 255),
            accentColor = Color3.fromRGB(255, 69, 0),
            gradient = {Color3.fromRGB(30, 144, 255), Color3.fromRGB(0, 255, 127)}
        },
        keybind = config.keybind or Enum.KeyCode.F9,
        draggable = config.draggable ~= false,
        animationSpeed = config.animationSpeed or 0.3,
        shadowEnabled = config.shadowEnabled ~= false
    }
    
    self.tabs = {}
    self.currentTab = nil
    self.isOpen = false
    
    -- Инициализация UI
    local success, err = pcall(function()
        self:InitUI()
    end)
    if not success then
        warn("Error initializing UI: " .. tostring(err))
        return nil
    end

    self:SetupKeybind()
    return self
end

-- Инициализация пользовательского интерфейса
function CheatMenuLibrary:InitUI()
    -- Проверка, что PlayerGui доступен
    if not LocalPlayer:FindFirstChild("PlayerGui") then
        warn("PlayerGui not found!")
        return
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CheatMenu"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Enabled = true
    self.ScreenGui = ScreenGui
    
    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = self.config.theme.secondaryColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false -- Начально скрыт
    self.MainFrame = MainFrame
    
    -- Закругленные углы
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Тень
    if self.config.shadowEnabled then
        local Shadow = Instance.new("ImageLabel")
        Shadow.Size = UDim2.new(1, 20, 1, 20)
        Shadow.Position = UDim2.new(0, -10, 0, -10)
        Shadow.BackgroundTransparency = 1
        Shadow.Image = "rbxassetid://1316045217"
        Shadow.ImageTransparency = 0.5
        Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        Shadow.ScaleType = Enum.ScaleType.Slice
        Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        Shadow.Parent = MainFrame
    end
    
    -- Заголовок
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, 0, 0, 50)
    TitleFrame.BackgroundColor3 = self.config.theme.primaryColor
    TitleFrame.Parent = MainFrame
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new(self.config.theme.gradient)
    TitleGradient.Parent = TitleFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.config.title
    TitleLabel.TextColor3 = self.config.theme.textColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleFrame
    
    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 10)
    CloseButton.BackgroundColor3 = self.config.theme.accentColor
    CloseButton.Text = "X"
    CloseButton.TextColor3 = self.config.theme.textColor
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 14
    CloseButton.Parent = TitleFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Панель вкладок
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 50)
    TabBar.BackgroundColor3 = self.config.theme.secondaryColor
    TabBar.Parent = MainFrame
    self.TabBar = TabBar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar
    
    -- Контейнер для содержимого вкладок
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -10, 1, -100)
    TabContainer.Position = UDim2.new(0, 5, 0, 95)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.Parent = MainFrame
    self.TabContainer = TabContainer
    
    -- Делаем меню перетаскиваемым
    if self.config.draggable then
        self:MakeDraggable(MainFrame, TitleFrame)
    end
    
    -- Обработчик кнопки закрытия
    CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
end

-- Настройка горячей клавиши
function CheatMenuLibrary:SetupKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.config.keybind then
            if self.isOpen then
                self:Close()
            else
                self:Open()
            end
        end
    end)
end

-- Открытие меню
function CheatMenuLibrary:Open()
    if self.isOpen then return end
    if not self.MainFrame then
        warn("MainFrame not initialized!")
        return
    end
    self.isOpen = true
    self.MainFrame.Visible = true
    
    local tweenInfo = TweenInfo.new(self.config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {Size = UDim2.new(0, 350, 0, 450)})
    tween:Play()
end

-- Закрытие меню
function CheatMenuLibrary:Close()
    if not self.isOpen then return end
    if not self.MainFrame then
        warn("MainFrame not initialized!")
        return
    end
    self.isOpen = false
    
    local tweenInfo = TweenInfo.new(self.config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {Size = UDim2.new(0, 350, 0, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        self.MainFrame.Visible = false
        self.MainFrame.Size = UDim2.new(0, 350, 0, 450)
    end)
end

-- Создание перетаскиваемого фрейма
function CheatMenuLibrary:MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

-- Добавление вкладки
function CheatMenuLibrary:AddTab(name)
    if not self.TabBar or not self.TabContainer then
        warn("TabBar or TabContainer not initialized!")
        return { content = Instance.new("Frame") }
    end

    local tab = {}
    tab.name = name
    
    -- Кнопка вкладки
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 80, 1, 0)
    TabButton.BackgroundColor3 = self.config.theme.primaryColor
    TabButton.Text = name
    TabButton.TextColor3 = self.config.theme.textColor
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = self.TabBar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    local TabGradient = Instance.new("UIGradient")
    TabGradient.Color = ColorSequence.new(self.config.theme.gradient)
    TabGradient.Enabled = false
    TabGradient.Parent = TabButton
    
    -- Контейнер для элементов вкладки
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 4
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Visible = false
    TabContent.Parent = self.TabContainer
    tab.content = TabContent
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabContent
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Обработчик переключения вкладки
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    self.tabs[name] = tab
    if not self.currentTab then
        self:SwitchTab(tab)
    end
    
    return tab
end

-- Переключение вкладки
function CheatMenuLibrary:SwitchTab(tab)
    if self.currentTab == tab then return end
    if not tab.content then
        warn("Tab content not initialized for: " .. tab.name)
        return
    end
    
    -- Скрываем текущую вкладку
    if self.currentTab and self.currentTab.content then
        self.currentTab.content.Visible = false
        for _, child in pairs(self.TabBar:GetChildren()) do
            if child:IsA("TextButton") and child.Text == self.currentTab.name then
                child:FindFirstChildOfClass("UIGradient").Enabled = false
            end
        end
    end
    
    -- Показываем новую вкладку
    self.currentTab = tab
    tab.content.Visible = true
    for _, child in pairs(self.TabBar:GetChildren()) do
        if child:IsA("TextButton") and child.Text == tab.name then
            child:FindFirstChildOfClass("UIGradient").Enabled = true
        end
    end
end

-- Добавление кнопки
function CheatMenuLibrary:AddButton(tab, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = self.config.theme.primaryColor
    Button.Text = name
    Button.TextColor3 = self.config.theme.textColor
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = tab:IsA("Frame") and tab or tab.content
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Button
    
    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Color = ColorSequence.new(self.config.theme.gradient)
    ButtonGradient.Enabled = false
    ButtonGradient.Parent = Button
    
    Button.MouseEnter:Connect(function()
        ButtonGradient.Enabled = true
    end)
    
    Button.MouseLeave:Connect(function()
        ButtonGradient.Enabled = false
    end)
    
    Button.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- Добавление переключателя
function CheatMenuLibrary:AddToggle(tab, name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = self.config.theme.primaryColor
    ToggleFrame.Parent = tab:IsA("Frame") and tab or tab.content
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = self.config.theme.textColor
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and self.config.theme.accentColor or Color3.fromRGB(100, 100, 100)
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleButton
    
    local state = default
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        local tweenInfo = TweenInfo.new(self.config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local goal = state and {BackgroundColor3 = self.config.theme.accentColor} or {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}
        local tween = TweenService:Create(ToggleButton, tweenInfo, goal)
        tween:Play()
        callback(state)
    end)
end

-- Добавление слайдера
function CheatMenuLibrary:AddSlider(tab, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = self.config.theme.primaryColor
    SliderFrame.Parent = tab:IsA("Frame") and tab or tab.content
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. default
    SliderLabel.TextColor3 = self.config.theme.textColor
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 14
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 10)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SliderBar.Parent = SliderFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 5)
    SliderCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = self.config.theme.accentColor
    SliderFill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = SliderFill
    
    local dragging = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local barX = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            local ratio = math.clamp((mouseX - barX) / barWidth, 0, 1)
            local value = min + (max - min) * ratio
            value = math.floor(value + 0.5)
            SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            SliderLabel.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- Добавление выпадающего списка
function CheatMenuLibrary:AddDropdown(tab, name, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = self.config.theme.primaryColor
    DropdownFrame.Parent = tab:IsA("Frame") and tab or tab.content
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = name .. ": " .. default
    DropdownButton.TextColor3 = self.config.theme.textColor
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 14
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.Parent = DropdownFrame
    
    local isOpen = false
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 1, 5)
    DropdownList.BackgroundColor3 = self.config.theme.secondaryColor
    DropdownList.ClipsDescendants = true
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = DropdownList
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, -10, 0, 25)
        OptionButton.BackgroundColor3 = self.config.theme.primaryColor
        OptionButton.Text = option
        OptionButton.TextColor3 = self.config.theme.textColor
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 14
        OptionButton.Parent = DropdownList
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 6)
        OptionCorner.Parent = OptionButton
        
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = name .. ": " .. option
            isOpen = false
            DropdownList.Visible = false
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            callback(option)
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownList.Visible = isOpen
        local tweenInfo = TweenInfo.new(self.config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local goal = isOpen and {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)} or {Size = UDim2.new(1, 0, 0, 0)}
        local tween = TweenService:Create(DropdownList, tweenInfo, goal)
        tween:Play()
    end)
end

-- Очистка меню
function CheatMenuLibrary:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    self = nil
end

return CheatMenuLibrary
