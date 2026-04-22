-- made using deepseek. Use it if you wish and can, to me it's not good enough.

--[[
    AURA UI LIBRARY v2.0
    A comprehensive, ImGui-inspired UI library for Roblox
    Features: Dark theme, rounded corners, modular components
    Host this as a module and load with loadstring()
    
    Usage:
        local Aura = loadstring(game:HttpGet("YOUR_URL_HERE"))()
        local Window = Aura:CreateWindow("My Cheat", "v1.0")
        
        local Tab = Window:CreateTab("Main")
        Tab:AddToggle("God Mode", false, function(state) print("God:", state) end)
        Tab:AddSlider("WalkSpeed", 16, 100, 50, function(value) print("Speed:", value) end)
]]

-- =============================================
-- CORE LIBRARY DEFINITION
-- =============================================

local Aura = {}
Aura.__index = Aura

-- Version tracking
Aura.Version = "2.0.1"
Aura.Build = "Stable"
Aura.Creator = "Aura Development Team"

-- =============================================
-- INTERNAL UTILITIES
-- =============================================

local Utilities = {}

function Utilities.Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utilities.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utilities.Round(num, decimalPlaces)
    local multiplier = 10^(decimalPlaces or 0)
    return math.floor(num * multiplier + 0.5) / multiplier
end

function Utilities.Debounce(func, wait)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= (wait or 0.5) then
            lastCall = now
            return func(...)
        end
    end
end

-- =============================================
-- COLOR PALETTE & THEME SYSTEM
-- =============================================

local Colors = {
    -- Dark Theme (Default)
    Background = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(35, 35, 40),
    Tertiary = Color3.fromRGB(45, 45, 50),
    
    -- Accent Colors
    Primary = Color3.fromRGB(0, 150, 255),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 193, 7),
    Danger = Color3.fromRGB(244, 67, 54),
    Info = Color3.fromRGB(33, 150, 243),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDisabled = Color3.fromRGB(120, 120, 120),
    
    -- UI Elements
    Border = Color3.fromRGB(60, 60, 65),
    Shadow = Color3.fromRGB(0, 0, 0, 0.5),
    Hover = Color3.fromRGB(255, 255, 255, 0.1),
    Pressed = Color3.fromRGB(255, 255, 255, 0.2),
}

-- =============================================
-- FONT SYSTEM
-- =============================================

local Fonts = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Monospace = Enum.Font.Code,
    Icon = Enum.Font.Bodoni, --FontAwesome
}

-- =============================================
-- WINDOW CLASS
-- =============================================

local Window = {}
Window.__index = Window

function Window:Create(title, subtitle, size, position)
    local self = setmetatable({}, Window)
    
    self.Title = title or "Aura UI"
    self.Subtitle = subtitle or "v" .. Aura.Version
    self.Size = size or UDim2.new(0, 500, 0, 400)
    self.Position = position or UDim2.new(0.5, -250, 0.5, -200)
    self.Tabs = {}
    self.ActiveTab = nil
    self.Elements = {}
    self.Config = {
        AutoSave = true,
        ShowWatermark = true,
        ShowFPS = true,
        Theme = "Dark",
        AnimationSpeed = 0.2,
    }
    
    -- Create main container
    self.ScreenGui = Utilities.Create("ScreenGui", {
        Name = "AuraUI_" .. title:gsub("%s+", ""),
        DisplayOrder = 999,
        ResetOnSpawn = false,
    })
    
    self.MainFrame = Utilities.Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = self.Position,
        Size = self.Size,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    
    -- Rounded corners
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = self.MainFrame,
    })
    
    -- Drop shadow
    local Shadow = Utilities.Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://5554236805",
        ImageColor3 = Colors.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0, -15, 0, -15),
        Parent = self.MainFrame,
    })
    
    -- Title bar
    self.TitleBar = Utilities.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.MainFrame,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 12, 0, 0),
        Parent = self.TitleBar,
    })
    
    -- Title text
    self.TitleLabel = Utilities.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Fonts.Title,
        Text = self.Title,
        TextColor3 = Colors.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })
    
    self.SubtitleLabel = Utilities.Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 20),
        Size = UDim2.new(0.6, 0, 0, 20),
        Font = Fonts.Body,
        Text = self.Subtitle,
        TextColor3 = Colors.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })
    
    -- Control buttons
    local ControlContainer = Utilities.Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0),
        Parent = self.TitleBar,
    })
    
    -- Minimize button
    self.MinimizeButton = Utilities.Create("TextButton", {
        Name = "Minimize",
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -50, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Fonts.Icon,
        Text = "?",
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        Parent = ControlContainer,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.MinimizeButton,
    })
    
    -- Close button
    self.CloseButton = Utilities.Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Colors.Danger,
        BorderSizePixel = 0,
        Position = UDim2.new(0.8, 0, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Fonts.Icon,
        Text = "?",
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        Parent = ControlContainer,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.CloseButton,
    })
    
    -- Tab container
    self.TabContainer = Utilities.Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.MainFrame,
    })
    
    -- Content area
    self.ContentFrame = Utilities.Create("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Primary,
        ScrollBarImageTransparency = 0.7,
        Parent = self.MainFrame,
    })
    
    Utilities.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = self.ContentFrame,
    })
    
    -- Watermark
    self.Watermark = Utilities.Create("TextLabel", {
        Name = "Watermark",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -200, 1, -25),
        Size = UDim2.new(0, 185, 0, 20),
        Font = Fonts.Monospace,
        Text = "Aura UI v" .. Aura.Version,
        TextColor3 = Colors.TextSecondary,
        TextSize = 11,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Right,
        Visible = self.Config.ShowWatermark,
        Parent = self.MainFrame,
    })
    
    -- FPS Counter
    self.FPSCounter = Utilities.Create("TextLabel", {
        Name = "FPS",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 1, -25),
        Size = UDim2.new(0, 100, 0, 20),
        Font = Fonts.Monospace,
        Text = "FPS: 60",
        TextColor3 = Colors.TextSecondary,
        TextSize = 11,
        TextTransparency = 0.5,
        Visible = self.Config.ShowFPS,
        Parent = self.MainFrame,
    })
    
    -- Setup interactions
    self:SetupInteractions()
    
    -- Start FPS counter
    self:StartFPSCounter()
    
    -- Parent to CoreGui
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create credits tab automatically
    self:CreateCreditsTab()
    
    return self
end

function Window:SetupInteractions()
    -- Dragging
    local dragging = false
    local dragInput, dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Control buttons
    self.MinimizeButton.MouseButton1Click:Connect(function()
        local targetSize = self.MainFrame.Size.Y.Offset == 80 and self.Size or UDim2.new(self.Size.X, UDim.new(0, 80))
        Utilities.Tween(self.MainFrame, {Size = targetSize}, 0.3)
        Utilities.Tween(self.ContentFrame, {Visible = not self.ContentFrame.Visible}, 0.3)
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        Utilities.Tween(self.MainFrame, {Size = UDim2.new(self.MainFrame.Size.X, UDim.new(0, 0))}, 0.3)
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Hover effects
    local function SetupHover(button)
        button.MouseEnter:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.BackgroundColor3:lerp(Colors.Hover, 0.3)}, 0.1)
        end)
        
        button.MouseLeave:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.Name == "Close" and Colors.Danger or Colors.Tertiary}, 0.1)
        end)
        
        button.MouseButton1Down:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.BackgroundColor3:lerp(Colors.Pressed, 0.5)}, 0.05)
        end)
        
        button.MouseButton1Up:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.Name == "Close" and Colors.Danger or Colors.Tertiary}, 0.1)
        end)
    end
    
    SetupHover(self.MinimizeButton)
    SetupHover(self.CloseButton)
end

function Window:StartFPSCounter()
    local RunService = game:GetService("RunService")
    local frameCount = 0
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastUpdate >= 1 then
            self.FPSCounter.Text = string.format("FPS: %d", math.floor(frameCount / (now - lastUpdate)))
            frameCount = 0
            lastUpdate = now
        end
    end)
end

function Window:CreateCreditsTab()
    local CreditsTab = self:CreateTab("Credits")
    
    CreditsTab:AddLabel("Aura UI Library", {
        TextSize = 16,
        TextColor = Colors.Primary,
        Font = Fonts.Header,
    })
    
    CreditsTab:AddLabel("Version: " .. Aura.Version)
    CreditsTab:AddLabel("Build: " .. Aura.Build)
    CreditsTab:AddLabel("Creator: " .. Aura.Creator)
    
    CreditsTab:AddDivider()
    
    CreditsTab:AddLabel("Special Thanks:", {
        TextSize = 14,
        TextColor = Colors.Success,
    })
    
    CreditsTab:AddLabel("• ImGui - Inspiration")
    CreditsTab:AddLabel("• Roblox Community")
    CreditsTab:AddLabel("• All Contributors")
    
    CreditsTab:AddDivider()
    
    CreditsTab:AddButton("Join Discord", function()
        print("Discord link would open here")
    end, {
        ButtonColor = Colors.Primary,
    })
    
    CreditsTab:AddButton("View Source", function()
        print("GitHub link would open here")
    end, {
        ButtonColor = Colors.Secondary,
    })
    
    -- Auto-select first non-credits tab if exists
    for _, tab in pairs(self.Tabs) do
        if tab.Name ~= "Credits" then
            self:SelectTab(tab.Name)
            break
        end
    end
end

function Window:CreateTab(name)
    local Tab = {}
    Tab.__index = Tab
    
    Tab.Name = name
    Tab.Window = self
    Tab.Elements = {}
    Tab.ElementCount = 0
    
    -- Create tab button
    Tab.Button = Utilities.Create("TextButton", {
        Name = name .. "Tab",
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 80, 1, 0),
        Font = Fonts.Body,
        Text = name,
        TextColor3 = Colors.TextSecondary,
        TextSize = 13,
        Parent = self.TabContainer,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Tab.Button,
    })
    
    -- Create tab content
    Tab.Content = Utilities.Create("Frame", {
        Name = name .. "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self.ContentFrame,
    })
    
    Utilities.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = Tab.Content,
    })
    
    -- Tab selection logic
    Tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Add hover effect
    Tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            Utilities.Tween(Tab.Button, {BackgroundColor3 = Colors.Secondary}, 0.2)
        end
    end)
    
    Tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            Utilities.Tween(Tab.Button, {BackgroundColor3 = Colors.Tertiary}, 0.2)
        end
    end)
    
    -- Store tab
    self.Tabs[name] = Tab
    
    -- If this is the first tab, select it
    if not self.ActiveTab then
        self:SelectTab(name)
    end
    
    -- Add methods
    function Tab:AddLabel(text, options)
        options = options or {}
        local label = Utilities.Create("TextLabel", {
            Name = "Label_" .. self.ElementCount,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, options.TextSize or 14),
            Font = options.Font or Fonts.Body,
            Text = text,
            TextColor3 = options.TextColor or Colors.TextPrimary,
            TextSize = options.TextSize or 14,
            TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return label
    end
    
    function Tab:AddDivider()
        local divider = Utilities.Create("Frame", {
            Name = "Divider_" .. self.ElementCount,
            BackgroundColor3 = Colors.Border,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return divider
    end
    
    function Tab:AddButton(text, callback, options)
        options = options or {}
        
        local button = Utilities.Create("TextButton", {
            Name = "Button_" .. self.ElementCount,
            BackgroundColor3 = options.ButtonColor or Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Fonts.Body,
            Text = text,
            TextColor3 = Colors.TextPrimary,
            TextSize = 14,
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = button,
        })
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.BackgroundColor3:lerp(Colors.Hover, 0.3)}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = options.ButtonColor or Colors.Primary}, 0.2)
        end)
        
        button.MouseButton1Down:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = button.BackgroundColor3:lerp(Colors.Pressed, 0.5)}, 0.1)
        end)
        
        button.MouseButton1Up:Connect(function()
            Utilities.Tween(button, {BackgroundColor3 = options.ButtonColor or Colors.Primary}, 0.2)
        end)
        
        -- Click handler
        button.MouseButton1Click:Connect(Utilities.Debounce(callback, 0.2))
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return button
    end
    
    function Tab:AddToggle(text, default, callback, options)
        options = options or {}
        local state = default or false
        
        local container = Utilities.Create("Frame", {
            Name = "Toggle_" .. self.ElementCount,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        local label = Utilities.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.7, 0, 1, 0),
            Font = Fonts.Body,
            Text = text,
            TextColor3 = Colors.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container,
        })
        
        local toggleFrame = Utilities.Create("Frame", {
            Name = "ToggleFrame",
            BackgroundColor3 = state and Colors.Success or Colors.Danger,
            BorderSizePixel = 0,
            Position = UDim2.new(0.8, 0, 0.5, -10),
            Size = UDim2.new(0, 40, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Parent = container,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = toggleFrame,
        })
        
        local toggleCircle = Utilities.Create("Frame", {
            Name = "ToggleCircle",
            BackgroundColor3 = Colors.TextPrimary,
            BorderSizePixel = 0,
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Parent = toggleFrame,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = toggleCircle,
        })
        
        -- Click handler
        local function Toggle()
            state = not state
            Utilities.Tween(toggleFrame, {
                BackgroundColor3 = state and Colors.Success or Colors.Danger
            }, 0.2)
            
            Utilities.Tween(toggleCircle, {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }, 0.2)
            
            if callback then
                callback(state)
            end
        end
        
        container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Toggle()
            end
        end)
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return {
            Set = function(newState)
                if state ~= newState then
                    Toggle()
                end
            end,
            Get = function() return state end,
            Toggle = Toggle,
        }
    end
    
    function Tab:AddSlider(text, min, max, default, callback, options)
        options = options or {}
        local value = math.clamp(default or min, min, max)
        
        local container = Utilities.Create("Frame", {
            Name = "Slider_" .. self.ElementCount,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        local label = Utilities.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Fonts.Body,
            Text = text .. ": " .. value,
            TextColor3 = Colors.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container,
        })
        
        local sliderTrack = Utilities.Create("Frame", {
            Name = "Track",
            BackgroundColor3 = Colors.Tertiary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(1, 0, 0, 6),
            Parent = container,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderTrack,
        })
        
        local sliderFill = Utilities.Create("Frame", {
            Name = "Fill",
            BackgroundColor3 = Colors.Primary,
            BorderSizePixel = 0,
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = sliderTrack,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill,
        })
        
        local sliderButton = Utilities.Create("TextButton", {
            Name = "SliderButton",
            BackgroundColor3 = Colors.TextPrimary,
            BorderSizePixel = 0,
            Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Text = "",
            Parent = sliderTrack,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderButton,
        })
        
        -- Slider logic
        local dragging = false
        
        local function UpdateSlider(input)
            local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            value = math.floor(min + (max - min) * relativeX)
            if options.Precise then
                value = min + (max - min) * relativeX
                value = Utilities.Round(value, options.Decimals or 1)
            end
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX, -8, 0.5, -8)
            label.Text = text .. ": " .. value
            
            if callback then
                callback(value)
            end
        end
        
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
        
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateSlider(input)
                dragging = true
            end
        end)
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return {
            Set = function(newValue)
                value = math.clamp(newValue, min, max)
                local relativeX = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                sliderButton.Position = UDim2.new(relativeX, -8, 0.5, -8)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end,
            Get = function() return value end,
        }
    end
    
    function Tab:AddTextBox(placeholder, default, callback, options)
        options = options or {}
        
        local container = Utilities.Create("Frame", {
            Name = "TextBox_" .. self.ElementCount,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        local textBox = Utilities.Create("TextBox", {
            Name = "Input",
            BackgroundColor3 = Colors.Tertiary,
            BorderColor3 = Colors.Border,
            BorderSizePixel = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 35),
            Font = Fonts.Body,
            PlaceholderText = placeholder,
            Text = default or "",
            TextColor3 = Colors.TextPrimary,
            TextSize = 14,
            ClearTextOnFocus = false,
            Parent = container,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = textBox,
        })
        
        Utilities.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = textBox,
        })
        
        -- Focus effects
        textBox.Focused:Connect(function()
            Utilities.Tween(textBox, {BorderColor3 = Colors.Primary}, 0.2)
        end)
        
        textBox.FocusLost:Connect(function(enterPressed)
            Utilities.Tween(textBox, {BorderColor3 = Colors.Border}, 0.2)
            if enterPressed and callback then
                callback(textBox.Text)
            end
        end)
        
        self.ElementCount = self.ElementCount + 1
        self:UpdateCanvasSize()
        
        return textBox
    end
    
    function Tab:AddDropdown(text, options, default, callback)
        local selected = default or options[1]
        local isOpen = false
        
        local container = Utilities.Create("Frame", {
            Name = "Dropdown_" .. self.ElementCount,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = self.ElementCount,
            Parent = self.Content,
        })
        
        local label = Utilities.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.7, 0, 1, 0),
            Font = Fonts.Body,
            Text = text,
            TextColor3 = Colors.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container,
        })
        
        local dropdownButton = Utilities.Create("TextButton", {
            Name = "DropdownButton",
            BackgroundColor3 = Colors.Tertiary,
            BorderSizePixel = 0,
            Position = UDim2.new(0.8, 0, 0, 0),
            Size = UDim2.new(0.2, 0, 1, 0),
            Font = Fonts.Body,
            Text = selected,
            TextColor3 = Colors.TextPrimary,
            TextSize = 12,
            Parent = container,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = dropdownButton,
        })
        
        local dropdownList = Utilities.Create("ScrollingFrame", {
            Name = "DropdownList",
            BackgroundColor3 = Colors.Secondary,
            BorderColor3 = Colors.Border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.8, 0, 1, 5),
            Size = UDim2.new(0.2, 0, 0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Primary,
            Visible = false,
            Parent = container,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = dropdownList,
        })
        
        Utilities.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = dropdownList,
        })
        
        -- Populate dropdown
        for i, option in ipairs(options) do
            local optionButton = Utilities.Create("TextButton", {
            Name = "Option_" .. i,
            BackgroundColor3 = Colors.Tertiary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Fonts.Body,
            Text = option,
            TextColor3 = Colors.TextPrimary,
            TextSize = 12,
            LayoutOrder = i,
            Parent = dropdownList,
        })
        
        optionButton.MouseEnter:Connect(function()
            Utilities.Tween(optionButton, {BackgroundColor3 = Colors.Secondary}, 0.1)
        end)
        
        optionButton.MouseLeave:Connect(function()
            Utilities.Tween(optionButton, {BackgroundColor3 = Colors.Tertiary}, 0.1)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            selected = option
            dropdownButton.Text = selected
            ToggleDropdown()
            if callback then
                callback(selected)
            end
        end)
    end
    
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
    
    local function ToggleDropdown()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        
        local targetSize = isOpen and UDim2.new(0.2, 0, 0, math.min(#options * 25, 150)) or UDim2.new(0.2, 0, 0, 0)
        Utilities.Tween(dropdownList, {Size = targetSize}, 0.2)
        
        Utilities.Tween(dropdownButton, {
            BackgroundColor3 = isOpen and Colors.Primary or Colors.Tertiary
        }, 0.2)
    end
    
    dropdownButton.MouseButton1Click:Connect(ToggleDropdown)
    
    -- Close dropdown when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local dropdownAbsPos = dropdownList.AbsolutePosition
            local dropdownSize = dropdownList.AbsoluteSize
            
            if not (mousePos.X >= dropdownAbsPos.X and mousePos.X <= dropdownAbsPos.X + dropdownSize.X and
                   mousePos.Y >= dropdownAbsPos.Y and mousePos.Y <= dropdownAbsPos.Y + dropdownSize.Y) then
                ToggleDropdown()
            end
        end
    end)
    
    self.ElementCount = self.ElementCount + 1
    self:UpdateCanvasSize()
    
    return {
        Set = function(option)
            if table.find(options, option) then
                selected = option
                dropdownButton.Text = selected
                if callback then callback(selected) end
            end
        end,
        Get = function() return selected end,
        Options = options,
    }
end

function Tab:AddKeybind(text, defaultKey, callback, options)
    options = options or {}
    local key = defaultKey or Enum.KeyCode.Unknown
    local listening = false
    
    local container = Utilities.Create("Frame", {
        Name = "Keybind_" .. self.ElementCount,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = self.ElementCount,
        Parent = self.Content,
    })
    
    local label = Utilities.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Fonts.Body,
        Text = text,
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local keyButton = Utilities.Create("TextButton", {
        Name = "KeyButton",
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.8, 0, 0, 0),
        Size = UDim2.new(0.2, 0, 1, 0),
        Font = Fonts.Monospace,
        Text = key.Name ~= "Unknown" and key.Name or "None",
        TextColor3 = Colors.TextPrimary,
        TextSize = 12,
        Parent = container,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = keyButton,
    })
    
    local function StartListening()
        listening = true
        keyButton.Text = "..."
        Utilities.Tween(keyButton, {BackgroundColor3 = Colors.Primary}, 0.2)
    end
    
    local function StopListening(newKey)
        listening = false
        key = newKey or key
        keyButton.Text = key.Name
        Utilities.Tween(keyButton, {BackgroundColor3 = Colors.Tertiary}, 0.2)
    end
    
    keyButton.MouseButton1Click:Connect(StartListening)
    
    -- Key listening
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                StopListening(input.KeyCode)
                if callback then callback(key) end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                StopListening(Enum.KeyCode.Unknown)
                if callback then callback(key) end
            end
        elseif input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
            if callback then callback(key) end
        end
    end)
    
    self.ElementCount = self.ElementCount + 1
    self:UpdateCanvasSize()
    
    return {
        Set = function(newKey)
            key = newKey
            keyButton.Text = key.Name
        end,
        Get = function() return key end,
        StartListening = StartListening,
        StopListening = StopListening,
    }
end

function Tab:AddColorPicker(text, defaultColor, callback)
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    
    local container = Utilities.Create("Frame", {
        Name = "ColorPicker_" .. self.ElementCount,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = self.ElementCount,
        Parent = self.Content,
    })
    
    local label = Utilities.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Fonts.Body,
        Text = text,
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local colorPreview = Utilities.Create("TextButton", {
        Name = "ColorPreview",
        BackgroundColor3 = color,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(0.8, 0, 0, 0),
        Size = UDim2.new(0.2, 0, 1, 0),
        Text = "",
        Parent = container,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorPreview,
    })
    
    -- Color picker modal (simplified - would need full HSV picker for production)
    colorPreview.MouseButton1Click:Connect(function()
        -- Create color picker popup
        local colorPicker = Utilities.Create("Frame", {
            Name = "ColorPickerPopup",
            BackgroundColor3 = Colors.Secondary,
            BorderColor3 = Colors.Border,
            BorderSizePixel = 1,
            Position = UDim2.new(0.5, -100, 0.5, -75),
            Size = UDim2.new(0, 200, 0, 150),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Parent = self.Window.ScreenGui,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = colorPicker,
        })
        
        -- Simple RGB sliders for demo
        local rSlider = self:AddSlider("R", 0, 255, color.R * 255, function(value)
            color = Color3.fromRGB(value, color.G * 255, color.B * 255)
            colorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
        
        local gSlider = self:AddSlider("G", 0, 255, color.G * 255, function(value)
            color = Color3.fromRGB(color.R * 255, value, color.B * 255)
            colorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
        
        local bSlider = self:AddSlider("B", 0, 255, color.B * 255, function(value)
            color = Color3.fromRGB(color.R * 255, color.G * 255, value)
            colorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
        
        -- Close button
        local closeButton = Utilities.Create("TextButton", {
            Name = "Close",
            BackgroundColor3 = Colors.Danger,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, -25, 1, -30),
            Size = UDim2.new(0, 50, 0, 25),
            Font = Fonts.Body,
            Text = "Close",
            TextColor3 = Colors.TextPrimary,
            TextSize = 12,
            Parent = colorPicker,
        })
        
        Utilities.Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = closeButton,
        })
        
        closeButton.MouseButton1Click:Connect(function()
            colorPicker:Destroy()
        end)
    end)
    
    self.ElementCount = self.ElementCount + 1
    self:UpdateCanvasSize()
    
    return {
        Set = function(newColor)
            color = newColor
            colorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end,
        Get = function() return color end,
    }
end

function Tab:AddSection(title)
    local section = {}
    
    local container = Utilities.Create("Frame", {
        Name = "Section_" .. self.ElementCount,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        LayoutOrder = self.ElementCount,
        Parent = self.Content,
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = container,
    })
    
    local sectionLabel = Utilities.Create("TextLabel", {
        Name = "SectionLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Fonts.Header,
        Text = title,
        TextColor3 = Colors.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    
    local sectionContent = Utilities.Create("Frame", {
        Name = "SectionContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = container,
    })
    
    Utilities.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = sectionContent,
    })
    
    local isExpanded = false
    
    local function ToggleSection()
        isExpanded = not isExpanded
        sectionContent.Visible = isExpanded
        
        local targetHeight = isExpanded and (sectionContent.UIListLayout.AbsoluteContentSize.Y + 20) or 0
        Utilities.Tween(sectionContent, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.3)
        Utilities.Tween(container, {Size = UDim2.new(1, 0, 0, 40 + targetHeight)}, 0.3)
        
        self:UpdateCanvasSize()
    end
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleSection()
        end
    end)
    
    self.ElementCount = self.ElementCount + 1
    self:UpdateCanvasSize()
    
    -- Return section with methods to add elements
    function section:AddLabel(text, options)
        return Tab:AddLabel(text, options)
    end
    
    function section:AddButton(text, callback, options)
        return Tab:AddButton(text, callback, options)
    end
    
    function section:AddToggle(text, default, callback, options)
        return Tab:AddToggle(text, default, callback, options)
    end
    
    function section:AddSlider(text, min, max, default, callback, options)
        return Tab:AddSlider(text, min, max, default, callback, options)
    end
    
    return section
end

function Tab:UpdateCanvasSize()
    local totalHeight = 0
    for _, child in ipairs(self.Content:GetChildren()) do
        if child:IsA("Frame") and child ~= self.Content then
            totalHeight = totalHeight + child.Size.Y.Offset + 8
        end
    end
    
    self.Content.Parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

return Tab
end

-- Close the Window:CreateTab function
function Window:SelectTab(tabName)
    if not self.Tabs[tabName] then return end
    
    -- Hide all tabs
    for name, tab in pairs(self.Tabs) do
        tab.Content.Visible = false
        Utilities.Tween(tab.Button, {
            BackgroundColor3 = Colors.Tertiary,
            TextColor3 = Colors.TextSecondary
        }, 0.2)
    end
    
    -- Show selected tab
    self.Tabs[tabName].Content.Visible = true
    Utilities.Tween(self.Tabs[tabName].Button, {
        BackgroundColor3 = Colors.Primary,
        TextColor3 = Colors.TextPrimary
    }, 0.2)
    
    self.ActiveTab = tabName
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- =============================================
-- AURA LIBRARY PUBLIC API
-- =============================================

function Aura:CreateWindow(title, subtitle, size, position)
    return Window:Create(title, subtitle, size, position)
end

function Aura:SetTheme(themeName)
    -- Theme system placeholder
    print("[Aura UI] Theme system coming in v2.1")
    return true
end

function Aura:GetVersion()
    return self.Version
end

function Aura:CreateNotification(title, message, duration, type)
    -- Simple notification system
    local Colors = Colors
    local Utilities = Utilities
    
    local notification = Utilities.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Colors.Secondary,
        BorderColor3 = Colors.Border,
        BorderSizePixel = 1,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 10, 1, -90),
        AnchorPoint = Vector2.new(1, 1),
        Parent = game:GetService("CoreGui"),
    })
    
    Utilities.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = notification,
    })
    
    local titleLabel = Utilities.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification,
    })
    
    local messageLabel = Utilities.Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 1, -40),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = Colors.TextSecondary,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification,
    })
    
    -- Color based on type
    local colorMap = {
        Success = Colors.Success,
        Warning = Colors.Warning,
        Error = Colors.Danger,
        Info = Colors.Primary
    }
    
    local accent = Utilities.Create("Frame", {
        Name = "Accent",
        BackgroundColor3 = colorMap[type] or Colors.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notification,
    })
    
    -- Animate in
    notification.Position = UDim2.new(1, 310, 1, -90)
    Utilities.Tween(notification, {
        Position = UDim2.new(1, 10, 1, -90)
    }, 0.3)
    
    -- Auto remove
    task.delay(duration or 5, function()
        Utilities.Tween(notification, {
            Position = UDim2.new(1, 310, 1, -90)
        }, 0.3)
        
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

-- =============================================
-- EXAMPLE USAGE (COMMENTED OUT)
-- =============================================

--[[
    -- EXAMPLE SCRIPT:
    local Aura = loadstring(game:HttpGet("YOUR_URL"))()
    
    local Window = Aura:CreateWindow("My Cheat", "v1.0")
    
    local MainTab = Window:CreateTab("Main")
    MainTab:AddToggle("God Mode", false, function(state)
        print("God:", state)
    end)
    
    MainTab:AddSlider("Speed", 16, 500, 16, function(value)
        print("Speed:", value)
    end)
]]

-- =============================================
-- RETURN THE LIBRARY
-- =============================================

return Aura
