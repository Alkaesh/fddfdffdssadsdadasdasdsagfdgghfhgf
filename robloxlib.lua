-- robloxlib.lua

local Lib = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Создание основного GUI
function Lib:CreateMenu(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CheatMenu"
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Parent = MainFrame

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local menu = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabFrame = TabFrame,
        ContentFrame = ContentFrame,
        Tabs = {},
        CurrentTab = nil,
        Visible = true
    }

    return menu
end

-- Добавление вкладки с прокруткой
function Lib:AddTab(menu, tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 100, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.SourceSans
    TabButton.Parent = menu.TabFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = TabButton

    -- Создаём ScrollingFrame вместо обычного Frame
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 5
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0) -- Будет обновляться автоматически
    TabContent.Visible = false
    TabContent.Parent = menu.ContentFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 5)
    ContentLayout.Parent = TabContent

    -- Обновление CanvasSize при изменении содержимого
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)

    local tab = {
        Button = TabButton,
        Content = TabContent,
        Sections = {}
    }

    table.insert(menu.Tabs, tab)

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(menu.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        tab.Content.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        menu.CurrentTab = tab
    end)

    if #menu.Tabs == 1 then
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        tab.Content.Visible = true
        menu.CurrentTab = tab
    end

    return tab
end

-- Добавление секции
function Lib:AddSection(tab, sectionName)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, -10, 0, 30)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = tab.Content

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = SectionFrame

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, 0, 0, 20)
    SectionLabel.Position = UDim2.new(0, 5, 0, 5)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = sectionName
    SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionLabel.TextSize = 16
    SectionLabel.Font = Enum.Font.SourceSansBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame

    local section = {
        Frame = SectionFrame,
        Height = 30
    }

    table.insert(tab.Sections, section)
    return section
end

-- Добавление переключателя
function Lib:AddToggle(tab, name, default, callback)
    local section = tab.Sections[#tab.Sections]
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 5, 0, section.Height)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = tab.Content

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.SourceSans
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0.85, 0, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleButton.Text = default and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Parent = ToggleFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = ToggleButton

    section.Height = section.Height + 35
    section.Frame.Size = UDim2.new(1, -10, 0, section.Height)

    ToggleButton.MouseButton1Click:Connect(function()
        default = not default
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- Добавление слайдера
function Lib:AddSlider(tab, name, min, max, default, callback)
    local section = tab.Sections[#tab.Sections]
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.Position = UDim2.new(0, 5, 0, section.Height)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = tab.Content

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.SourceSans
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, 0, 0, 10)
    SliderBar.Position = UDim2.new(0, 0, 0, 25)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.Parent = SliderFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SliderFill.Parent = SliderBar

    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(0, 5)
    UICornerFill.Parent = SliderFill

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar

    section.Height = section.Height + 55
    section.Frame.Size = UDim2.new(1, -10, 0, section.Height)

    local isDragging = false
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)

    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = SliderBar.AbsolutePosition.X
            local sliderWidth = SliderBar.AbsoluteSize.X
            local relativeX = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
            local value = min + (max - min) * relativeX
            value = math.floor(value)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            SliderLabel.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- Добавление текстового поля
function Lib:AddTextBox(tab, name, default, callback)
    local section = tab.Sections[#tab.Sections]
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Size = UDim2.new(1, -10, 0, 30)
    TextBoxFrame.Position = UDim2.new(0, 5, 0, section.Height)
    TextBoxFrame.BackgroundTransparency = 1
    TextBoxFrame.Parent = tab.Content

    local TextBoxLabel = Instance.new("TextLabel")
    TextBoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TextBoxLabel.BackgroundTransparency = 1
    TextBoxLabel.Text = name
    TextBoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBoxLabel.TextSize = 14
    TextBoxLabel.Font = Enum.Font.SourceSans
    TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextBoxLabel.Parent = TextBoxFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.5, 0, 0, 20)
    TextBox.Position = UDim2.new(0.5, 0, 0.5, -10)
    TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TextBox.Text = default
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14
    TextBox.Font = Enum.Font.SourceSans
    TextBox.Parent = TextBoxFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = TextBox

    section.Height = section.Height + 35
    section.Frame.Size = UDim2.new(1, -10, 0, section.Height)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(TextBox.Text)
        end
    end)

    return TextBox
end

-- Добавление кнопки
function Lib:AddButton(tab, name, callback)
    local section = tab.Sections[#tab.Sections]
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -10, 0, 30)
    ButtonFrame.Position = UDim2.new(0, 5, 0, section.Height)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = tab.Content

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.Parent = ButtonFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = Button

    section.Height = section.Height + 35
    section.Frame.Size = UDim2.new(1, -10, 0, section.Height)

    Button.MouseButton1Click:Connect(callback)
end

-- Добавление выбора цвета
function Lib:AddColorPicker(tab, name, defaultColor, callback)
    local section = tab.Sections[#tab.Sections]
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Size = UDim2.new(1, -10, 0, 30)
    ColorPickerFrame.Position = UDim2.new(0, 5, 0, section.Height)
    ColorPickerFrame.BackgroundTransparency = 1
    ColorPickerFrame.Parent = tab.Content

    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Text = name
    ColorPickerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorPickerLabel.TextSize = 14
    ColorPickerLabel.Font = Enum.Font.SourceSans
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorPickerLabel.Parent = ColorPickerFrame

    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(0, 40, 0, 20)
    ColorButton.Position = UDim2.new(0.85, 0, 0.5, -10)
    ColorButton.BackgroundColor3 = defaultColor
    ColorButton.Text = ""
    ColorButton.Parent = ColorPickerFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = ColorButton

    section.Height = section.Height + 35
    section.Frame.Size = UDim2.new(1, -10, 0, section.Height)

    ColorButton.MouseButton1Click:Connect(function()
        local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        ColorButton.BackgroundColor3 = color
        callback(color)
    end)
end

-- Показать/скрыть меню
function Lib:ShowMenu(menu)
    menu.MainFrame.Visible = true
    menu.Visible = true
end

function Lib:HideMenu(menu)
    menu.MainFrame.Visible = false
    menu.Visible = false
end

-- Уведомления
function Lib:Notify(message, duration)
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, 200, 0, 50)
    NotificationFrame.Position = UDim2.new(1, -210, 1, -60)
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = game.CoreGui:FindFirstChild("CheatMenu") or Instance.new("ScreenGui", game.CoreGui)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = NotificationFrame

    local NotificationLabel = Instance.new("TextLabel")
    NotificationLabel.Size = UDim2.new(1, 0, 1, 0)
    NotificationLabel.BackgroundTransparency = 1
    NotificationLabel.Text = message
    NotificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotificationLabel.TextSize = 14
    NotificationLabel.Font = Enum.Font.SourceSans
    NotificationLabel.TextWrapped = true
    NotificationLabel.Parent = NotificationFrame

    wait(duration or 3)
    local tween = TweenService:Create(NotificationFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 0, 1, -60)})
    tween:Play()
    tween.Completed:Wait()
    NotificationFrame:Destroy()
end

return Lib
