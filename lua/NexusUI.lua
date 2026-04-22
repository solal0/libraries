-- NexusUI v1.0.0
-- A sleek, dark-themed UI library with stacking notifications
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/nexus-ui/main/nexus.lua"))()

local NexusUI = {}
NexusUI.__index = NexusUI

-- Internal state management
local _nexus = {
    -- Core state
    initialized = false,
    screen_gui = nil,
    render_connection = nil,
    
    -- Notification system
    notifications = {},
    notification_queue = {},
    max_notifications = 5,
    notification_spacing = 10,
    notification_width = 300,
    notification_height = 80,
    notification_duration = 5, -- seconds
    notification_anim_speed = 0.3,
    
    -- Theme system
    themes = {},
    current_theme = "midnight",
    
    -- Window management
    windows = {},
    window_zindex = 10,
    focused_window = nil,
    dragging_window = nil,
    drag_offset = Vector2.new(0, 0),
    
    -- Input state
    mouse_position = Vector2.new(0, 0),
    mouse_down = false,
    mouse_clicked = false,
    keys_down = {},
    
    -- Animation system
    animations = {},
    animation_tween_service = game:GetService("TweenService"),
    
    -- Performance
    last_render_time = tick(),
    fps = 60,
    frame_count = 0,
    
    -- Configuration
    config = {
        enable_blur = true,
        enable_shadows = true,
        enable_animations = true,
        notification_sound = true,
        auto_scale = true,
        debug_mode = false
    }
}

-- **DARK THEME SYSTEM** - Multiple dark themes included
NexusUI.Themes = {
    ["midnight"] = {
        -- Core colors
        primary = Color3.fromRGB(25, 25, 35),
        secondary = Color3.fromRGB(40, 40, 55),
        tertiary = Color3.fromRGB(55, 55, 75),
        
        -- Text colors
        text_primary = Color3.fromRGB(240, 240, 245),
        text_secondary = Color3.fromRGB(180, 180, 190),
        text_disabled = Color3.fromRGB(100, 100, 110),
        
        -- Accent colors
        accent_primary = Color3.fromRGB(0, 150, 255),    -- Blue
        accent_success = Color3.fromRGB(0, 200, 100),    -- Green
        accent_warning = Color3.fromRGB(255, 180, 0),    -- Yellow
        accent_error = Color3.fromRGB(255, 80, 80),      -- Red
        accent_info = Color3.fromRGB(100, 180, 255),     -- Light Blue
        
        -- UI elements
        background = Color3.fromRGB(20, 20, 28),
        surface = Color3.fromRGB(30, 30, 40),
        surface_hover = Color3.fromRGB(40, 40, 55),
        surface_active = Color3.fromRGB(50, 50, 70),
        
        -- Borders and dividers
        border = Color3.fromRGB(50, 50, 65),
        border_hover = Color3.fromRGB(70, 70, 90),
        divider = Color3.fromRGB(40, 40, 55),
        
        -- Special elements
        selection = Color3.fromRGB(0, 120, 215, 0.3),
        scrollbar = Color3.fromRGB(60, 60, 80),
        scrollbar_hover = Color3.fromRGB(80, 80, 100),
        
        -- Notification colors
        notification_bg = Color3.fromRGB(30, 30, 40, 0.95),
        notification_border = Color3.fromRGB(0, 150, 255),
        notification_success = Color3.fromRGB(0, 200, 100),
        notification_warning = Color3.fromRGB(255, 180, 0),
        notification_error = Color3.fromRGB(255, 80, 80),
        notification_info = Color3.fromRGB(100, 180, 255),
        
        -- Shadow and effects
        shadow_color = Color3.fromRGB(0, 0, 0, 0.5),
        glow_color = Color3.fromRGB(0, 150, 255, 0.2),
        
        -- Typography
        font = Enum.Font.Gotham,
        font_bold = Enum.Font.GothamBold,
        font_mono = Enum.Font.Code,
        
        -- Sizing and spacing
        corner_radius = UDim.new(0, 8),
        border_size = 1,
        padding_small = 4,
        padding_medium = 8,
        padding_large = 12,
        spacing_small = 4,
        spacing_medium = 8,
        spacing_large = 16
    },
    
    ["obsidian"] = {
        primary = Color3.fromRGB(15, 15, 20),
        secondary = Color3.fromRGB(30, 30, 40),
        accent_primary = Color3.fromRGB(170, 0, 255), -- Purple accent
        text_primary = Color3.fromRGB(230, 230, 240),
        notification_border = Color3.fromRGB(170, 0, 255)
    },
    
    ["cyberpunk"] = {
        primary = Color3.fromRGB(10, 10, 20),
        secondary = Color3.fromRGB(25, 25, 45),
        accent_primary = Color3.fromRGB(0, 255, 200), -- Cyan accent
        text_primary = Color3.fromRGB(220, 255, 255),
        notification_border = Color3.fromRGB(0, 255, 200)
    },
    
    ["matrix"] = {
        primary = Color3.fromRGB(0, 20, 0),
        secondary = Color3.fromRGB(0, 40, 0),
        accent_primary = Color3.fromRGB(0, 255, 0), -- Green accent
        text_primary = Color3.fromRGB(0, 255, 100),
        notification_border = Color3.fromRGB(0, 255, 0)
    }
}

-- **NOTIFICATION TYPES AND TEMPLATES**
NexusUI.NotificationTypes = {
    SUCCESS = "success",
    ERROR = "error",
    WARNING = "warning",
    INFO = "info",
    CUSTOM = "custom"
}

-- **ANIMATION PRESETS**
local AnimationPresets = {
    slide_in = {
        from = {Position = UDim2.new(1, 10, 1, 0)},
        to = {Position = UDim2.new(1, -10, 1, 0)},
        easing = Enum.EasingStyle.Quint,
        direction = Enum.EasingDirection.Out
    },
    
    slide_out = {
        from = {Position = UDim2.new(1, -10, 1, 0)},
        to = {Position = UDim2.new(1, 10, 1, 0)},
        easing = Enum.EasingStyle.Quint,
        direction = Enum.EasingDirection.In
    },
    
    fade_in = {
        from = {BackgroundTransparency = 1, TextTransparency = 1},
        to = {BackgroundTransparency = 0.05, TextTransparency = 0},
        easing = Enum.EasingStyle.Quad,
        direction = Enum.EasingDirection.Out
    },
    
    fade_out = {
        from = {BackgroundTransparency = 0.05, TextTransparency = 0},
        to = {BackgroundTransparency = 1, TextTransparency = 1},
        easing = Enum.EasingStyle.Quad,
        direction = Enum.EasingDirection.In
    },
    
    bounce = {
        from = {Size = UDim2.new(0, 0, 0, 0)},
        to = {Size = UDim2.new(0, 300, 0, 80)},
        easing = Enum.EasingStyle.Back,
        direction = Enum.EasingDirection.Out
    },
    
    shake = {
        from = {Position = UDim2.new(1, -10, 1, 0)},
        to = {Position = UDim2.new(1, -10, 1, 0)},
        easing = Enum.EasingStyle.Sine,
        direction = Enum.EasingDirection.InOut
    }
}

-- **INTERNAL HELPER FUNCTIONS**
local function GetTheme()
    return NexusUI.Themes[_nexus.current_theme]
end

local function CreateRoundedFrame(name, size, position, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = GetTheme().primary
    frame.BackgroundTransparency = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = GetTheme().corner_radius
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = GetTheme().border
    stroke.Thickness = GetTheme().border_size
    stroke.Parent = frame
    
    if _nexus.config.enable_shadows then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = GetTheme().shadow_color
        shadow.ImageTransparency = 0.5
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.Parent = frame
    end
    
    if parent then
        frame.Parent = parent
    end
    
    return frame
end

local function CreateTextLabel(name, text, size, position, parent, options)
    options = options or {}
    
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = options.text_color or GetTheme().text_primary
    label.TextSize = options.text_size or 14
    label.Font = options.font or GetTheme().font
    label.TextXAlignment = options.x_align or Enum.TextXAlignment.Left
    label.TextYAlignment = options.y_align or Enum.TextYAlignment.Center
    label.TextWrapped = options.wrapped or false
    label.TextTruncate = options.truncate or Enum.TextTruncate.AtEnd
    label.RichText = options.rich_text or false
    
    if options.max_text_size then
        label.MaxVisibleGraphemes = options.max_text_size
    end
    
    if parent then
        label.Parent = parent
    end
    
    return label
end

local function CreateButton(name, text, size, position, parent, callback)
    local button = CreateRoundedFrame(name, size, position, parent)
    button.BackgroundColor3 = GetTheme().secondary
    
    local label = CreateTextLabel("Label", text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), button, {
        text_color = GetTheme().text_primary,
        x_align = Enum.TextXAlignment.Center
    })
    
    -- Hover effect
    local hover = false
    local active = false
    
    button.MouseEnter:Connect(function()
        hover = true
        if not active then
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = GetTheme().surface_hover
            }):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        hover = false
        if not active then
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = GetTheme().secondary
            }):Play()
        end
    end)
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = GetTheme().surface_active,
                Size = size - UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            active = false
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = hover and GetTheme().surface_hover or GetTheme().secondary,
                Size = size
            }):Play()
            
            if callback then
                callback()
            end
        end
    end)
    
    return button
end

local function CreateIcon(iconName, size, position, parent, color)
    local icon = Instance.new("ImageLabel")
    icon.Name = iconName
    icon.Size = size
    icon.Position = position
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. ({
        success = "6031068421",
        error = "6031068422",
        warning = "6031068423",
        info = "6031068424",
        close = "6031097222",
        check = "6031068425",
        alert = "6031068426",
        bell = "6031068427",
        settings = "6031068428",
        user = "6031068429",
        home = "6031068430",
        search = "6031068431",
        menu = "6031068432",
        arrow_right = "6031068433",
        arrow_left = "6031068434",
        download = "6031068435",
        upload = "6031068436",
        star = "6031068437",
        heart = "6031068438",
        clock = "6031068439",
        calendar = "6031068440"
    })[iconName] or "6031068424"
    
    icon.ImageColor3 = color or GetTheme().text_primary
    icon.ScaleType = Enum.ScaleType.Fit
    
    if parent then
        icon.Parent = parent
    end
    
    return icon
end

local function PlaySound(soundId, volume)
    if not _nexus.config.notification_sound then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.5
    sound.Parent = workspace
    sound:Play()
    
    game:GetService("Debris"):AddItem(sound, 2)
end

-- **NOTIFICATION SYSTEM IMPLEMENTATION**
function NexusUI.Notify(options)
    -- Default options
    local config = {
        title = options.title or "Notification",
        message = options.message or "",
        duration = options.duration or _nexus.notification_duration,
        type = options.type or NexusUI.NotificationTypes.INFO,
        icon = options.icon,
        sound = options.sound ~= false,
        callback = options.callback,
        buttons = options.buttons or {},
        priority = options.priority or 1,
        can_close = options.can_close ~= false,
        persistent = options.persistent or false
    }
    
    -- Generate unique ID
    local notificationId = "notification_" .. tick() .. "_" .. math.random(1000, 9999)
    
    -- Add to queue
    table.insert(_nexus.notification_queue, {
        id = notificationId,
        config = config,
        created = tick(),
        shown = false
    })
    
    -- Sort queue by priority
    table.sort(_nexus.notification_queue, function(a, b)
        return a.config.priority > b.config.priority
    end)
    
    -- Play sound if enabled
    if config.sound then
        local soundMap = {
            [NexusUI.NotificationTypes.SUCCESS] = "4590662768",
            [NexusUI.NotificationTypes.ERROR] = "4590662769",
            [NexusUI.NotificationTypes.WARNING] = "4590662770",
            [NexusUI.NotificationTypes.INFO] = "4590662771"
        }
        PlaySound(soundMap[config.type] or "4590662771", 0.3)
    end
    
    return notificationId
end

function NexusUI.RemoveNotification(id)
    for i, notification in ipairs(_nexus.notifications) do
        if notification.id == id then
            -- Animate out
            if notification.frame and notification.frame.Parent then
                local tween = _nexus.animation_tween_service:Create(
                    notification.frame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Position = UDim2.new(1, 10, 1, notification.frame.Position.Y.Offset)}
                )
                tween:Play()
                tween.Completed:Connect(function()
                    notification.frame:Destroy()
                    table.remove(_nexus.notifications, i)
                    NexusUI.UpdateNotificationPositions()
                end)
            else
                table.remove(_nexus.notifications, i)
                NexusUI.UpdateNotificationPositions()
            end
            break
        end
    end
end

function NexusUI.ClearNotifications()
    for _, notification in ipairs(_nexus.notifications) do
        if notification.frame then
            notification.frame:Destroy()
        end
    end
    _nexus.notifications = {}
    _nexus.notification_queue = {}
end

function NexusUI.UpdateNotificationPositions()
    local theme = GetTheme()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local startY = screenSize.Y - 100
    
    for i, notification in ipairs(_nexus.notifications) do
        if notification.frame then
            local targetY = startY - ((i - 1) * (_nexus.notification_height + _nexus.notification_spacing))
            
            _nexus.animation_tween_service:Create(
                notification.frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -_nexus.notification_width - 10, 0, targetY)}
            ):Play()
        end
    end
end

function NexusUI.ProcessNotificationQueue()
    if #_nexus.notifications >= _nexus.max_notifications then
        -- Remove oldest notification if at max capacity
        local oldest = _nexus.notifications[1]
        if oldest and not oldest.config.persistent then
            NexusUI.RemoveNotification(oldest.id)
        end
    end
    
    -- Process queued notifications
    for i = #_nexus.notification_queue, 1, -1 do
        local queued = _nexus.notification_queue[i]
        if not queued.shown then
            NexusUI.CreateNotification(queued)
            queued.shown = true
            table.remove(_nexus.notification_queue, i)
            break -- Only process one per frame
        end
    end
end

function NexusUI.CreateNotification(notificationData)
    local theme = GetTheme()
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- Create notification frame
    local notificationFrame = CreateRoundedFrame(
        notificationData.id,
        UDim2.new(0, _nexus.notification_width, 0, _nexus.notification_height),
        UDim2.new(1, 10, 1, 0),
        _nexus.screen_gui
    )
    
    notificationFrame.BackgroundColor3 = theme.notification_bg
    notificationFrame.BackgroundTransparency = 0.05
    notificationFrame.ZIndex = 100
    
    -- Set border color based on type
    local borderColor = theme.notification_info
    if notificationData.config.type == NexusUI.NotificationTypes.SUCCESS then
        borderColor = theme.notification_success
    elseif notificationData.config.type == NexusUI.NotificationTypes.ERROR then
        borderColor = theme.notification_error
    elseif notificationData.config.type == NexusUI.NotificationTypes.WARNING then
        borderColor = theme.notification_warning
    end
    
    notificationFrame.UIStroke.Color = borderColor
    notificationFrame.UIStroke.Thickness = 2
    
    -- Add glow effect
    if _nexus.config.enable_shadows then
        local glow = notificationFrame:FindFirstChild("Shadow")
        if glow then
            glow.ImageColor3 = borderColor
            glow.ImageTransparency = 0.7
        end
    end
    
    -- Create content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -20)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = notificationFrame
    
    -- Add icon
    local iconSize = 24
    local icon = CreateIcon(
        notificationData.config.icon or notificationData.config.type,
        UDim2.new(0, iconSize, 0, iconSize),
        UDim2.new(0, 0, 0, 0),
        content,
        borderColor
    )
    
    -- Add title
    local title = CreateTextLabel(
        "Title",
        notificationData.config.title,
        UDim2.new(1, -iconSize - 10, 0, 20),
        UDim2.new(0, iconSize + 10, 0, 0),
        content,
        {
            text_color = theme.text_primary,
            text_size = 16,
            font = theme.font_bold,
            truncate = true
        }
    )
    
    -- Add message
    local message = CreateTextLabel(
        "Message",
        notificationData.config.message,
        UDim2.new(1, 0, 1, -30),
        UDim2.new(0, 0, 0, 25),
        content,
        {
            text_color = theme.text_secondary,
            text_size = 14,
            wrapped = true
        }
    )
    
    -- Add close button if enabled
    if notificationData.config.can_close then
        local closeButton = CreateIcon(
            "close",
            UDim2.new(0, 16, 0, 16),
            UDim2.new(1, -16, 0, 0),
            content,
            theme.text_secondary
        )
        
        closeButton.MouseEnter:Connect(function()
            _nexus.animation_tween_service:Create(closeButton, TweenInfo.new(0.2), {
                ImageColor3 = theme.text_primary,
                Rotation = 90
            }):Play()
        end)
        
        closeButton.MouseLeave:Connect(function()
            _nexus.animation_tween_service:Create(closeButton, TweenInfo.new(0.2), {
                ImageColor3 = theme.text_secondary,
                Rotation = 0
            }):Play()
        end)
        
        closeButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                NexusUI.RemoveNotification(notificationData.id)
            end
        end)
    end
    
    -- Add progress bar for duration
    if not notificationData.config.persistent and notificationData.config.duration > 0 then
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(1, 0, 0, 2)
        progressBar.Position = UDim2.new(0, 0, 1, -2)
        progressBar.BackgroundColor3 = borderColor
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notificationFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 1)
        corner.Parent = progressBar
        
        -- Animate progress
        _nexus.animation_tween_service:Create(
            progressBar,
            TweenInfo.new(notificationData.config.duration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 0, 2)}
        ):Play()
    end
    
    -- Add buttons if provided
    if #notificationData.config.buttons > 0 then
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "Buttons"
        buttonContainer.Size = UDim2.new(1, 0, 0, 30)
        buttonContainer.Position = UDim2.new(0, 0, 1, -30)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = content
        
        local buttonWidth = (_nexus.notification_width - 40) / #notificationData.config.buttons
        
        for i, buttonConfig in ipairs(notificationData.config.buttons) do
            local button = CreateButton(
                "Button_" .. i,
                buttonConfig.text,
                UDim2.new(0, buttonWidth - 5, 0, 25),
                UDim2.new(0, (i-1) * buttonWidth + 5, 0, 0),
                buttonContainer,
                function()
                    if buttonConfig.callback then
                        buttonConfig.callback()
                    end
                    if buttonConfig.close_on_click then
                        NexusUI.RemoveNotification(notificationData.id)
                    end
                end
            )
            
            button.BackgroundColor3 = theme.secondary
            button.UIStroke.Color = borderColor
        end
    end
    
    -- Add to notifications list
    table.insert(_nexus.notifications, {
        id = notificationData.id,
        config = notificationData.config,
        frame = notificationFrame,
        created = notificationData.created
    })
    
    -- Animate in
    notificationFrame.Position = UDim2.new(1, 10, 1, 0)
    
    _nexus.animation_tween_service:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -_nexus.notification_width - 10, 1, 0)}
    ):Play()
    
    -- Update positions
    NexusUI.UpdateNotificationPositions()
    
    -- Set up auto-removal if not persistent
    if not notificationData.config.persistent and notificationData.config.duration > 0 then
        task.delay(notificationData.config.duration, function()
            if notificationFrame.Parent then
                NexusUI.RemoveNotification(notificationData.id)
            end
        end)
    end
    
    -- Return the notification frame for custom manipulation
    return notificationFrame
end

-- **WINDOW SYSTEM IMPLEMENTATION**
function NexusUI.CreateWindow(options)
    local config = {
        title = options.title or "Window",
        size = options.size or Vector2.new(400, 300),
        position = options.position or Vector2.new(100, 100),
        min_size = options.min_size or Vector2.new(200, 150),
        max_size = options.max_size or Vector2.new(800, 600),
        can_close = options.can_close ~= false,
        can_minimize = options.can_minimize or false,
        can_resize = options.can_resize or false,
        show_header = options.show_header ~= false,
        accent_color = options.accent_color,
        transparent = options.transparent or false,
        on_close = options.on_close
    }
    
    local windowId = "window_" .. tick() .. "_" .. math.random(1000, 9999)
    local theme = GetTheme()
    
    -- Create window container
    local window = CreateRoundedFrame(
        windowId,
        UDim2.new(0, config.size.X, 0, config.size.Y),
        UDim2.new(0, config.position.X, 0, config.position.Y),
        _nexus.screen_gui
    )
    
    window.ZIndex = _nexus.window_zindex
    _nexus.window_zindex = _nexus.window_zindex + 1
    
    if config.transparent then
        window.BackgroundTransparency = 0.1
    end
    
    -- Add header if enabled
    local headerHeight = 30
    local contentContainer
    
    if config.show_header then
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, headerHeight)
        header.Position = UDim2.new(0, 0, 0, 0)
        header.BackgroundColor3 = config.accent_color or theme.accent_primary
        header.BorderSizePixel = 0
        header.Parent = window
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 8)
        headerCorner.Parent = header
        
        -- Title
        local title = CreateTextLabel(
            "Title",
            config.title,
            UDim2.new(1, -60, 1, 0),
            UDim2.new(0, 10, 0, 0),
            header,
            {
                text_color = theme.text_primary,
                text_size = 16,
                font = theme.font_bold
            }
        )
        
        -- Close button
        if config.can_close then
            local closeButton = CreateIcon(
                "close",
                UDim2.new(0, 20, 0, 20),
                UDim2.new(1, -25, 0, 5),
                header,
                theme.text_primary
            )
            
            closeButton.MouseEnter:Connect(function()
                closeButton.ImageColor3 = theme.accent_error
            end)
            
            closeButton.MouseLeave:Connect(function()
                closeButton.ImageColor3 = theme.text_primary
            end)
            
            closeButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if config.on_close then
                        config.on_close()
                    end
                    window:Destroy()
                    _nexus.windows[windowId] = nil
                end
            end)
        end
        
        -- Content container
        contentContainer = Instance.new("Frame")
        contentContainer.Name = "Content"
        contentContainer.Size = UDim2.new(1, 0, 1, -headerHeight)
        contentContainer.Position = UDim2.new(0, 0, 0, headerHeight)
        contentContainer.BackgroundTransparency = 1
        contentContainer.Parent = window
    else
        contentContainer = window
    end
    
    -- Make window draggable via header
    if config.show_header then
        local header = window:FindFirstChild("Header")
        if header then
            header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    _nexus.dragging_window = windowId
                    _nexus.drag_offset = Vector2.new(
                        input.Position.X - window.AbsolutePosition.X,
                        input.Position.Y - window.AbsolutePosition.Y
                    )
                    _nexus.focused_window = windowId
                    
                    -- Bring to front
                    window.ZIndex = _nexus.window_zindex
                    _nexus.window_zindex = _nexus.window_zindex + 1
                end
            end)
        end
    end
    
    -- Store window data
    _nexus.windows[windowId] = {
        frame = window,
        config = config,
        content = contentContainer,
        size = config.size,
        position = config.position
    }
    
    return {
        id = windowId,
        frame = window,
        content = contentContainer,
        
        -- Public methods
        Close = function()
            if config.on_close then
                config.on_close()
            end
            window:Destroy()
            _nexus.windows[windowId] = nil
        end,
        
        SetTitle = function(newTitle)
            if window:FindFirstChild("Header") then
                local titleLabel = window.Header:FindFirstChild("Title")
                if titleLabel then
                    titleLabel.Text = newTitle
                end
            end
        end,
        
        SetSize = function(newSize)
            if newSize.X >= config.min_size.X and newSize.X <= config.max_size.X and
               newSize.Y >= config.min_size.Y and newSize.Y <= config.max_size.Y then
                window.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
                _nexus.windows[windowId].size = newSize
            end
        end,
        
        SetPosition = function(newPosition)
            window.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
            _nexus.windows[windowId].position = newPosition
        end,
        
        BringToFront = function()
            window.ZIndex = _nexus.window_zindex
            _nexus.window_zindex = _nexus.window_zindex + 1
            _nexus.focused_window = windowId
        end
    }
end

-- **WIDGET SYSTEM IMPLEMENTATION**
function NexusUI.CreateButton(parent, options)
    local config = {
        text = options.text or "Button",
        size = options.size or UDim2.new(0, 100, 0, 35),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback,
        accent_color = options.accent_color,
        disabled = options.disabled or false,
        tooltip = options.tooltip
    }
    
    local theme = GetTheme()
    local button = CreateButton(
        "NexusButton_" .. math.random(10000, 99999),
        config.text,
        config.size,
        config.position,
        parent,
        function()
            if not config.disabled and config.callback then
                config.callback()
            end
        end
    )
    
    if config.accent_color then
        button.BackgroundColor3 = config.accent_color
        button.UIStroke.Color = config.accent_color
    end
    
    if config.disabled then
        button.BackgroundColor3 = theme.tertiary
        button.UIStroke.Color = theme.border
        button:FindFirstChild("Label").TextColor3 = theme.text_disabled
    end
    
    -- Add tooltip if provided
    if config.tooltip then
        local tooltip = CreateTextLabel(
            "Tooltip",
            config.tooltip,
            UDim2.new(0, 200, 0, 30),
            UDim2.new(0.5, -100, 1, 5),
            button,
            {
                text_color = theme.text_primary,
                background_color = theme.surface,
                visible = false
            }
        )
        
        button.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        
        button.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end
    
    return {
        frame = button,
        
        SetText = function(newText)
            local label = button:FindFirstChild("Label")
            if label then
                label.Text = newText
            end
        end,
        
        SetEnabled = function(enabled)
            config.disabled = not enabled
            local theme = GetTheme()
            
            if enabled then
                button.BackgroundColor3 = config.accent_color or theme.secondary
                button.UIStroke.Color = config.accent_color or theme.border
                button:FindFirstChild("Label").TextColor3 = theme.text_primary
            else
                button.BackgroundColor3 = theme.tertiary
                button.UIStroke.Color = theme.border
                button:FindFirstChild("Label").TextColor3 = theme.text_disabled
            end
        end,
        
        SetCallback = function(newCallback)
            config.callback = newCallback
        end,
        
        Destroy = function()
            button:Destroy()
        end
    }
end

function NexusUI.CreateLabel(parent, options)
    local config = {
        text = options.text or "Label",
        size = options.size or UDim2.new(1, 0, 0, 20),
        position = options.position or UDim2.new(0, 0, 0, 0),
        text_color = options.text_color,
        text_size = options.text_size or 14,
        font = options.font,
        x_align = options.x_align or Enum.TextXAlignment.Left,
        y_align = options.y_align or Enum.TextYAlignment.Center,
        wrapped = options.wrapped or false,
        rich_text = options.rich_text or false
    }
    
    local theme = GetTheme()
    local label = CreateTextLabel(
        "NexusLabel_" .. math.random(10000, 99999),
        config.text,
        config.size,
        config.position,
        parent,
        {
            text_color = config.text_color or theme.text_primary,
            text_size = config.text_size,
            font = config.font or theme.font,
            x_align = config.x_align,
            y_align = config.y_align,
            wrapped = config.wrapped,
            rich_text = config.rich_text
        }
    )
    
    return {
        frame = label,
        
        SetText = function(newText)
            label.Text = newText
        end,
        
        SetColor = function(newColor)
            label.TextColor3 = newColor
        end,
        
        SetVisible = function(visible)
            label.Visible = visible
        end,
        
        Destroy = function()
            label:Destroy()
        end
    }
end

function NexusUI.CreateSlider(parent, options)
    local config = {
        label = options.label or "Slider",
        value = options.value or 0.5,
        min = options.min or 0,
        max = options.max or 1,
        step = options.step or 0.01,
        size = options.size or UDim2.new(1, 0, 0, 50),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback,
        show_value = options.show_value ~= false,
        format = options.format or "%.2f"
    }
    
    local theme = GetTheme()
    local sliderId = "NexusSlider_" .. math.random(10000, 99999)
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = sliderId
    container.Size = config.size
    container.Position = config.position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Label
    local label = CreateTextLabel(
        "Label",
        config.label,
        UDim2.new(1, 0, 0, 20),
        UDim2.new(0, 0, 0, 0),
        container,
        {
            text_color = theme.text_primary,
            text_size = 14
        }
    )
    
    -- Value display
    local valueText
    if config.show_value then
        valueText = CreateTextLabel(
            "Value",
            string.format(config.format, config.value),
            UDim2.new(0, 60, 0, 20),
            UDim2.new(1, -60, 0, 0),
            container,
            {
                text_color = theme.text_secondary,
                text_size = 14,
                x_align = Enum.TextXAlignment.Right
            }
        )
    end
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 25)
    track.BackgroundColor3 = theme.secondary
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    -- Slider fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((config.value - config.min) / (config.max - config.min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = theme.accent_primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    -- Slider thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
    thumb.BackgroundColor3 = theme.text_primary
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 8)
    thumbCorner.Parent = thumb
    
    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Color = theme.accent_primary
    thumbStroke.Thickness = 2
    thumbStroke.Parent = thumb
    
    -- Dragging logic
    local dragging = false
    
    local function updateValue(mouseX)
        local absolutePos = track.AbsolutePosition.X
        local absoluteSize = track.AbsoluteSize.X
        
        local relativeX = math.clamp((mouseX - absolutePos) / absoluteSize, 0, 1)
        local rawValue = config.min + (relativeX * (config.max - config.min))
        
        -- Apply step
        if config.step > 0 then
            rawValue = math.floor(rawValue / config.step + 0.5) * config.step
        end
        
        local newValue = math.clamp(rawValue, config.min, config.max)
        
        if newValue ~= config.value then
            config.value = newValue
            
            -- Update visuals
            fill.Size = UDim2.new((newValue - config.min) / (config.max - config.min), 0, 1, 0)
            thumb.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
            
            if valueText then
                valueText.Text = string.format(config.format, newValue)
            end
            
            -- Call callback
            if config.callback then
                config.callback(newValue)
            end
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {
        frame = container,
        
        GetValue = function()
            return config.value
        end,
        
        SetValue = function(newValue)
            config.value = math.clamp(newValue, config.min, config.max)
            fill.Size = UDim2.new((config.value - config.min) / (config.max - config.min), 0, 1, 0)
            thumb.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
            
            if valueText then
                valueText.Text = string.format(config.format, config.value)
            end
        end,
        
        SetCallback = function(newCallback)
            config.callback = newCallback
        end,
        
        Destroy = function()
            container:Destroy()
        end
    }
end

function NexusUI.CreateToggle(parent, options)
    local config = {
        label = options.label or "Toggle",
        value = options.value or false,
        size = options.size or UDim2.new(1, 0, 0, 30),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback,
        accent_color = options.accent_color
    }
    
    local theme = GetTheme()
    local toggleId = "NexusToggle_" .. math.random(10000, 99999)
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = toggleId
    container.Size = config.size
    container.Position = config.position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Toggle switch
    local switch = Instance.new("Frame")
    switch.Name = "Switch"
    switch.Size = UDim2.new(0, 50, 0, 25)
    switch.Position = UDim2.new(0, 0, 0, 0)
    switch.BackgroundColor3 = theme.secondary
    switch.BorderSizePixel = 0
    switch.Parent = container
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 12)
    switchCorner.Parent = switch
    
    -- Toggle thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 21, 0, 21)
    thumb.Position = config.value and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    thumb.BackgroundColor3 = theme.text_primary
    thumb.BorderSizePixel = 0
    thumb.Parent = switch
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 10)
    thumbCorner.Parent = thumb
    
    -- Label
    local label = CreateTextLabel(
        "Label",
        config.label,
        UDim2.new(1, -60, 1, 0),
        UDim2.new(0, 60, 0, 0),
        container,
        {
            text_color = theme.text_primary,
            text_size = 14
        }
    )
    
    -- Click handler
    local function toggle()
        config.value = not config.value
        
        -- Animate thumb
        _nexus.animation_tween_service:Create(
            thumb,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Position = config.value and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5),
                BackgroundColor3 = config.value and (config.accent_color or theme.accent_primary) or theme.text_primary
            }
        ):Play()
        
        -- Animate switch background
        _nexus.animation_tween_service:Create(
            switch,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundColor3 = config.value and Color3.fromRGB(
                    (config.accent_color or theme.accent_primary).R * 0.3,
                    (config.accent_color or theme.accent_primary).G * 0.3,
                    (config.accent_color or theme.accent_primary).B * 0.3
                ) or theme.secondary
            }
        ):Play()
        
        -- Call callback
        if config.callback then
            config.callback(config.value)
        end
    end
    
    switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    -- Set initial state
    if config.value then
        thumb.BackgroundColor3 = config.accent_color or theme.accent_primary
        switch.BackgroundColor3 = Color3.fromRGB(
            (config.accent_color or theme.accent_primary).R * 0.3,
            (config.accent_color or theme.accent_primary).G * 0.3,
            (config.accent_color or theme.accent_primary).B * 0.3
        )
    end
    
    return {
        frame = container,
        
        GetValue = function()
            return config.value
        end,
        
        SetValue = function(newValue)
            if newValue ~= config.value then
                toggle()
            end
        end,
        
        SetCallback = function(newCallback)
            config.callback = newCallback
        end,
        
        Destroy = function()
            container:Destroy()
        end
    }
end

function NexusUI.CreateDropdown(parent, options)
    local config = {
        label = options.label or "Dropdown",
        items = options.items or {"Item 1", "Item 2", "Item 3"},
        selected = options.selected or 1,
        size = options.size or UDim2.new(1, 0, 0, 35),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback,
        max_height = options.max_height or 200
    }
    
    local theme = GetTheme()
    local dropdownId = "NexusDropdown_" .. math.random(10000, 99999)
    local open = false
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = dropdownId
    container.Size = config.size
    container.Position = config.position
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = parent
    
    -- Main button
    local button = CreateRoundedFrame(
        "Button",
        UDim2.new(1, 0, 0, 35),
        UDim2.new(0, 0, 0, 0),
        container
    )
    
    button.BackgroundColor3 = theme.secondary
    
    -- Selected item label
    local selectedLabel = CreateTextLabel(
        "Selected",
        config.items[config.selected] or "Select...",
        UDim2.new(1, -30, 1, 0),
        UDim2.new(0, 10, 0, 0),
        button,
        {
            text_color = theme.text_primary,
            text_size = 14
        }
    )
    
    -- Dropdown icon
    local icon = CreateIcon(
        "arrow_down",
        UDim2.new(0, 20, 0, 20),
        UDim2.new(1, -25, 0.5, -10),
        button,
        theme.text_secondary
    )
    
    -- Dropdown list
    local list = Instance.new("Frame")
    list.Name = "List"
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 40)
    list.BackgroundColor3 = theme.surface
    list.BorderSizePixel = 0
    list.Visible = false
    list.Parent = container
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = GetTheme().corner_radius
    listCorner.Parent = list
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = theme.border
    listStroke.Thickness = 1
    listStroke.Parent = list
    
    -- Create list items
    local itemFrames = {}
    local itemHeight = 30
    
    local function createListItem(index, itemText)
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item_" .. index
        itemFrame.Size = UDim2.new(1, 0, 0, itemHeight)
        itemFrame.Position = UDim2.new(0, 0, 0, (index - 1) * itemHeight)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = list
        
        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Button"
        itemButton.Size = UDim2.new(1, 0, 1, 0)
        itemButton.Position = UDim2.new(0, 0, 0, 0)
        itemButton.BackgroundColor3 = index == config.selected and theme.selection or Color3.new(0, 0, 0)
        itemButton.BackgroundTransparency = index == config.selected and 0.7 or 1
        itemButton.Text = ""
        itemButton.Parent = itemFrame
        
        local itemLabel = CreateTextLabel(
            "Label",
            itemText,
            UDim2.new(1, -10, 1, 0),
            UDim2.new(0, 10, 0, 0),
            itemFrame,
            {
                text_color = theme.text_primary,
                text_size = 14
            }
        )
        
        -- Hover effects
        itemButton.MouseEnter:Connect(function()
            if index ~= config.selected then
                itemButton.BackgroundTransparency = 0.9
            end
        end)
        
        itemButton.MouseLeave:Connect(function()
            if index ~= config.selected then
                itemButton.BackgroundTransparency = 1
            end
        end)
        
        itemButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                config.selected = index
                selectedLabel.Text = itemText
                
                -- Close dropdown
                toggleDropdown()
                
                -- Call callback
                if config.callback then
                    config.callback(index, itemText)
                end
            end
        end)
        
        table.insert(itemFrames, itemFrame)
        return itemFrame
    end
    
    for i, item in ipairs(config.items) do
        createListItem(i, item)
    end
    
    -- Toggle dropdown function
    local function toggleDropdown()
        open = not open
        
        if open then
            list.Visible = true
            local totalHeight = math.min(#config.items * itemHeight, config.max_height)
            
            _nexus.animation_tween_service:Create(
                list,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, totalHeight)}
            ):Play()
            
            _nexus.animation_tween_service:Create(
                icon,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Rotation = 180}
            ):Play()
        else
            _nexus.animation_tween_service:Create(
                list,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(1, 0, 0, 0)}
            ):Play()
            
            _nexus.animation_tween_service:Create(
                icon,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Rotation = 0}
            ):Play()
            
            task.delay(0.3, function()
                list.Visible = false
            end)
        end
    end
    
    -- Button click handler
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleDropdown()
        end
    end)
    
    -- Close dropdown when clicking outside
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local buttonBounds = button.AbsolutePosition
            local buttonSize = button.AbsoluteSize
            
            if not (mousePos.X >= buttonBounds.X and mousePos.X <= buttonBounds.X + buttonSize.X and
                   mousePos.Y >= buttonBounds.Y and mousePos.Y <= buttonBounds.Y + buttonSize.Y + list.AbsoluteSize.Y) then
                if open then
                    toggleDropdown()
                end
            end
        end
    end)
    
    return {
        frame = container,
        
        GetSelected = function()
            return config.selected, config.items[config.selected]
        end,
        
        SetSelected = function(index)
            if index >= 1 and index <= #config.items then
                config.selected = index
                selectedLabel.Text = config.items[index]
            end
        end,
        
        SetItems = function(newItems)
            config.items = newItems
            
            -- Clear existing items
            for _, frame in ipairs(itemFrames) do
                frame:Destroy()
            end
            itemFrames = {}
            
            -- Create new items
            for i, item in ipairs(newItems) do
                createListItem(i, item)
            end
            
            -- Update selected if out of bounds
            if config.selected > #newItems then
                config.selected = 1
                selectedLabel.Text = newItems[1] or "Select..."
            end
        end,
        
        SetCallback = function(newCallback)
            config.callback = newCallback
        end,
        
        Destroy = function()
            container:Destroy()
        end
    }
end

function NexusUI.CreateTextBox(parent, options)
    local config = {
        label = options.label or "Text Box",
        text = options.text or "",
        placeholder = options.placeholder or "Type here...",
        size = options.size or UDim2.new(1, 0, 0, 35),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback,
        multiline = options.multiline or false,
        max_length = options.max_length
    }
    
    local theme = GetTheme()
    local textboxId = "NexusTextBox_" .. math.random(10000, 99999)
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = textboxId
    container.Size = config.size
    container.Position = config.position
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Label
    local label
    if config.label then
        label = CreateTextLabel(
            "Label",
            config.label,
            UDim2.new(1, 0, 0, 20),
            UDim2.new(0, 0, 0, 0),
            container,
            {
                text_color = theme.text_primary,
                text_size = 14
            }
        )
    end
    
    -- Text box frame
    local textboxFrame = CreateRoundedFrame(
        "TextBoxFrame",
        UDim2.new(1, 0, 0, 35),
        UDim2.new(0, 0, config.label and 25 or 0, 0),
        container
    )
    
    textboxFrame.BackgroundColor3 = theme.secondary
    
    -- Actual TextBox
    local textbox = Instance.new("TextBox")
    textbox.Name = "TextBox"
    textbox.Size = UDim2.new(1, -20, 1, 0)
    textbox.Position = UDim2.new(0, 10, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.Text = config.text
    textbox.PlaceholderText = config.placeholder
    textbox.TextColor3 = theme.text_primary
    textbox.PlaceholderColor3 = theme.text_disabled
    textbox.TextSize = 14
    textbox.Font = theme.font
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.TextYAlignment = config.multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    textbox.TextWrapped = config.multiline
    textbox.ClearTextOnFocus = false
    textbox.MultiLine = config.multiline
    textbox.Parent = textboxFrame
    
    if config.max_length then
        textbox.MaxVisibleGraphemes = config.max_length
    end
    
    -- Focus effects
    local focused = false
    
    textbox.Focused:Connect(function()
        focused = true
        _nexus.animation_tween_service:Create(
            textboxFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundColor3 = theme.surface_hover,
                UIStroke = {
                    Color = theme.accent_primary,
                    Thickness = 2
                }
            }
        ):Play()
    end)
    
    textbox.FocusLost:Connect(function()
        focused = false
        _nexus.animation_tween_service:Create(
            textboxFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundColor3 = theme.secondary,
                UIStroke = {
                    Color = theme.border,
                    Thickness = 1
                }
            }
        ):Play()
        
        if config.callback then
            config.callback(textbox.Text)
        end
    end)
    
    return {
        frame = container,
        
        GetText = function()
            return textbox.Text
        end,
        
        SetText = function(newText)
            textbox.Text = newText
        end,
        
        SetCallback = function(newCallback)
            config.callback = newCallback
        end,
        
        SetPlaceholder = function(newPlaceholder)
            textbox.PlaceholderText = newPlaceholder
        end,
        
        Destroy = function()
            container:Destroy()
        end
    }
end

-- **UTILITY FUNCTIONS**
function NexusUI.Init()
    if _nexus.initialized then
        return
    end
    
    -- Create ScreenGui
    _nexus.screen_gui = Instance.new("ScreenGui")
    _nexus.screen_gui.Name = "NexusUI"
    _nexus.screen_gui.ResetOnSpawn = false
    _nexus.screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _nexus.screen_gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Setup input handling
    local userInputService = game:GetService("UserInputService")
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    -- Mouse position tracking
    game:GetService("RunService").RenderStepped:Connect(function()
        _nexus.mouse_position = Vector2.new(mouse.X, mouse.Y)
        _nexus.mouse_down = mouse.Button1Down
        
        -- Handle window dragging
        if _nexus.dragging_window and _nexus.windows[_nexus.dragging_window] then
            local window = _nexus.windows[_nexus.dragging_window]
            local newPos = _nexus.mouse_position - _nexus.drag_offset
            
            window.frame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
            window.position = newPos
        end
    end)
    
    -- Main render loop
    _nexus.render_connection = game:GetService("RunService").RenderStepped:Connect(function()
        NexusUI.ProcessNotificationQueue()
        
        -- Update FPS counter
        _nexus.frame_count = _nexus.frame_count + 1
        local currentTime = tick()
        if currentTime - _nexus.last_render_time >= 1 then
            _nexus.fps = _nexus.frame_count
            _nexus.frame_count = 0
            _nexus.last_render_time = currentTime
        end
    end)
    
    _nexus.initialized = true
    
    -- Send welcome notification
    task.delay(1, function()
        NexusUI.Notify({
            title = "NexusUI Initialized",
            message = "Dark-themed UI library ready!",
            type = NexusUI.NotificationTypes.SUCCESS,
            duration = 3
        })
    end)
    
    return true
end

function NexusUI.Destroy()
    if _nexus.render_connection then
        _nexus.render_connection:Disconnect()
    end
    
    if _nexus.screen_gui then
        _nexus.screen_gui:Destroy()
    end
    
    _nexus.initialized = false
    
    -- Clear all state
    for k in pairs(_nexus) do
        if type(_nexus[k]) == "table" then
            _nexus[k] = {}
        else
            _nexus[k] = nil
        end
    end
    
    return true
end

function NexusUI.SetTheme(themeName)
    if NexusUI.Themes[themeName] then
        _nexus.current_theme = themeName
        
        -- Send notification
        NexusUI.Notify({
            title = "Theme Changed",
            message = "Switched to " .. themeName .. " theme",
            type = NexusUI.NotificationTypes.INFO,
            duration = 2
        })
        
        return true
    end
    return false
end

function NexusUI.GetThemeNames()
    local names = {}
    for name in pairs(NexusUI.Themes) do
        table.insert(names, name)
    end
    return names
end

function NexusUI.GetFPS()
    return _nexus.fps
end

function NexusUI.GetNotificationCount()
    return #_nexus.notifications
end

function NexusUI.GetWindowCount()
    return #_nexus.windows
end

function NexusUI.SetConfig(key, value)
    if _nexus.config[key] ~= nil then
        _nexus.config[key] = value
        return true
    end
    return false
end

function NexusUI.GetConfig(key)
    return _nexus.config[key]
end

-- **QUICK NOTIFICATION HELPERS**
function NexusUI.NotifySuccess(title, message, duration)
    return NexusUI.Notify({
        title = title,
        message = message,
        type = NexusUI.NotificationTypes.SUCCESS,
        duration = duration or 3
    })
end

function NexusUI.NotifyError(title, message, duration)
    return NexusUI.Notify({
        title = title,
        message = message,
        type = NexusUI.NotificationTypes.ERROR,
        duration = duration or 5
    })
end

function NexusUI.NotifyWarning(title, message, duration)
    return NexusUI.Notify({
        title = title,
        message = message,
        type = NexusUI.NotificationTypes.WARNING,
        duration = duration or 4
    })
end

function NexusUI.NotifyInfo(title, message, duration)
    return NexusUI.Notify({
        title = title,
        message = message,
        type = NexusUI.NotificationTypes.INFO,
        duration = duration or 3
    })
end

-- **DEMO FUNCTION**
function NexusUI.ShowDemo()
    if not _nexus.initialized then
        NexusUI.Init()
    end
    
    -- Create demo window
    local demoWindow = NexusUI.CreateWindow({
        title = "NexusUI Demo",
        size = Vector2.new(500, 600),
        position = Vector2.new(100, 100),
        can_close = true,
        can_resize = true,
        accent_color = GetTheme().accent_primary
    })
    
    -- Add content
    local content = demoWindow.content
    
    -- Title
    NexusUI.CreateLabel(content, {
        text = "NexusUI Demo",
        size = UDim2.new(1, 0, 0, 40),
        position = UDim2.new(0, 0, 0, 10),
        text_size = 24,
        font = GetTheme().font_bold,
        x_align = Enum.TextXAlignment.Center
    })
    
    -- Notification tester
    NexusUI.CreateLabel(content, {
        text = "Notification System",
        size = UDim2.new(1, 0, 0, 30),
        position = UDim2.new(0, 0, 0, 60),
        text_size = 18
    })
    
    local buttonY = 100
    local buttonSpacing = 45
    
    NexusUI.CreateButton(content, {
        text = "Show Success",
        size = UDim2.new(0.45, 0, 0, 35),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function()
            NexusUI.NotifySuccess("Operation Successful", "The task was completed successfully!")
        end
    })
    
    NexusUI.CreateButton(content, {
        text = "Show Error",
        size = UDim2.new(0.45, 0, 0, 35),
        position = UDim2.new(0.525, 0, 0, buttonY),
        callback = function()
            NexusUI.NotifyError("Critical Error", "Something went terribly wrong!")
        end
    })
    
    buttonY = buttonY + buttonSpacing
    
    NexusUI.CreateButton(content, {
        text = "Show Warning",
        size = UDim2.new(0.45, 0, 0, 35),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function()
            NexusUI.NotifyWarning("Warning", "Proceed with caution!")
        end
    })
    
    NexusUI.CreateButton(content, {
        text = "Show Info",
        size = UDim2.new(0.45, 0, 0, 35),
        position = UDim2.new(0.525, 0, 0, buttonY),
        callback = function()
            NexusUI.NotifyInfo("Information", "Here's some useful information.")
        end
    })
    
    buttonY = buttonY + buttonSpacing
    
    NexusUI.CreateButton(content, {
        text = "Show Custom Notification",
        size = UDim2.new(0.95, 0, 0, 35),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function()
            NexusUI.Notify({
                title = "Custom Notification",
                message = "This is a custom notification with buttons!",
                type = NexusUI.NotificationTypes.CUSTOM,
                duration = 10,
                buttons = {
                    {
                        text = "OK",
                        callback = function()
                            print("OK clicked!")
                        end,
                        close_on_click = true
                    },
                    {
                        text = "Cancel",
                        callback = function()
                            print("Cancel clicked!")
                        end,
                        close_on_click = true
                    }
                }
            })
        end
    })
    
    buttonY = buttonY + buttonSpacing
    
    NexusUI.CreateButton(content, {
        text = "Clear All Notifications",
        size = UDim2.new(0.95, 0, 0, 35),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function()
            NexusUI.ClearNotifications()
        end
    })
    
    -- Widget Demo Section
    buttonY = buttonY + 60
    
    NexusUI.CreateLabel(content, {
        text = "Widget Demo",
        size = UDim2.new(1, 0, 0, 30),
        position = UDim2.new(0, 0, 0, buttonY),
        text_size = 18
    })
    
    buttonY = buttonY + 40
    
    -- Toggle
    local toggle = NexusUI.CreateToggle(content, {
        label = "Enable Feature",
        value = true,
        size = UDim2.new(0.95, 0, 0, 30),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function(value)
            NexusUI.NotifyInfo("Toggle Changed", "Feature " .. (value and "enabled" or "disabled"))
        end
    })
    
    buttonY = buttonY + 40
    
    -- Slider
    local slider = NexusUI.CreateSlider(content, {
        label = "Volume Level",
        value = 0.75,
        min = 0,
        max = 1,
        step = 0.01,
        size = UDim2.new(0.95, 0, 0, 50),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function(value)
            -- Update in real-time
        end
    })
    
    buttonY = buttonY + 60
    
    -- Dropdown
    local dropdown = NexusUI.CreateDropdown(content, {
        label = "Select Option",
        items = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"},
        selected = 1,
        size = UDim2.new(0.95, 0, 0, 35),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function(index, value)
            NexusUI.NotifyInfo("Selection Changed", "Selected: " .. value)
        end
    })
    
    buttonY = buttonY + 50
    
    -- Text Box
    local textbox = NexusUI.CreateTextBox(content, {
        label = "Enter Text",
        placeholder = "Type something here...",
        size = UDim2.new(0.95, 0, 0, 60),
        position = UDim2.new(0.025, 0, 0, buttonY),
        callback = function(text)
            NexusUI.NotifyInfo("Text Entered", "You typed: " .. (text == "" and "(empty)" or text))
        end
    })
    
    buttonY = buttonY + 80
    
    -- Theme Switcher
    NexusUI.CreateLabel(content, {
        text = "Theme Switcher",
        size = UDim2.new(1, 0, 0, 30),
        position = UDim2.new(0, 0, 0, buttonY),
        text_size = 18
    })
    
    buttonY = buttonY + 40
    
    local themeNames = NexusUI.GetThemeNames()
    local themeButtonWidth = 0.95 / #themeNames
    
    for i, themeName in ipairs(themeNames) do
        NexusUI.CreateButton(content, {
            text = themeName:sub(1, 1):upper() .. themeName:sub(2),
            size = UDim2.new(themeButtonWidth - 0.02, 0, 0, 35),
            position = UDim2.new((i-1) * themeButtonWidth + 0.025, 0, 0, buttonY),
            callback = function()
                NexusUI.SetTheme(themeName)
            end
        })
    end
    
    buttonY = buttonY + 50
    
    -- Stats Display
    NexusUI.CreateLabel(content, {
        text = "System Stats",
        size = UDim2.new(1, 0, 0, 30),
        position = UDim2.new(0, 0, 0, buttonY),
        text_size = 18
    })
    
    buttonY = buttonY + 40
    
    local statsText = NexusUI.CreateLabel(content, {
        text = "FPS: 60 | Notifications: 0 | Windows: 1",
        size = UDim2.new(0.95, 0, 0, 20),
        position = UDim2.new(0.025, 0, 0, buttonY),
        text_color = GetTheme().text_secondary
    })
    
    -- Update stats in real-time
    game:GetService("RunService").RenderStepped:Connect(function()
        statsText.SetText(string.format(
            "FPS: %d | Notifications: %d | Windows: %d",
            NexusUI.GetFPS(),
            NexusUI.GetNotificationCount(),
            NexusUI.GetWindowCount()
        ))
    end)
    
    -- Send demo notification
    task.delay(0.5, function()
        NexusUI.Notify({
            title = "Demo Loaded",
            message = "NexusUI demo is now running!",
            type = NexusUI.NotificationTypes.INFO,
            duration = 4
        })
    end)
    
    return demoWindow
end

-- **ADVANCED NOTIFICATION FEATURES**
function NexusUI.CreateProgressNotification(options)
    local config = {
        title = options.title or "Processing...",
        message = options.message or "",
        duration = options.duration or 10,
        show_progress = options.show_progress ~= false,
        can_cancel = options.can_cancel or false,
        on_cancel = options.on_cancel
    }
    
    local notificationId = NexusUI.Notify({
        title = config.title,
        message = config.message,
        type = NexusUI.NotificationTypes.INFO,
        duration = config.duration,
        persistent = true,
        can_close = config.can_cancel,
        buttons = config.can_cancel and {
            {
                text = "Cancel",
                callback = function()
                    if config.on_cancel then
                        config.on_cancel()
                    end
                end,
                close_on_click = true
            }
        } or {}
    })
    
    local progress = 0
    
    return {
        id = notificationId,
        
        UpdateProgress = function(newProgress, newMessage)
            progress = math.clamp(newProgress, 0, 1)
            
            -- Find and update the notification
            for _, notif in ipairs(_nexus.notifications) do
                if notif.id == notificationId and notif.frame then
                    local content = notif.frame:FindFirstChild("Content")
                    if content then
                        -- Update message if provided
                        if newMessage then
                            local messageLabel = content:FindFirstChild("Message")
                            if messageLabel then
                                messageLabel.Text = newMessage
                            end
                        end
                        
                        -- Update progress bar
                        local progressBar = notif.frame:FindFirstChild("ProgressBar")
                        if progressBar then
                            progressBar.Size = UDim2.new(progress, 0, 0, 2)
                        end
                        
                        -- Update title with percentage
                        local titleLabel = content:FindFirstChild("Title")
                        if titleLabel and config.show_progress then
                            titleLabel.Text = string.format("%s (%d%%)", config.title, math.floor(progress * 100))
                        end
                    end
                    break
                end
            end
        end,
        
        Complete = function(success, finalMessage)
            local newType = success and NexusUI.NotificationTypes.SUCCESS or NexusUI.NotificationTypes.ERROR
            local newTitle = success and "Completed" or "Failed"
            
            -- Update the notification
            for _, notif in ipairs(_nexus.notifications) do
                if notif.id == notificationId and notif.frame then
                    local content = notif.frame:FindFirstChild("Content")
                    if content then
                        -- Update title
                        local titleLabel = content:FindFirstChild("Title")
                        if titleLabel then
                            titleLabel.Text = newTitle
                        end
                        
                        -- Update message
                        local messageLabel = content:FindFirstChild("Message")
                        if messageLabel then
                            messageLabel.Text = finalMessage or (success and "Operation completed successfully" or "Operation failed")
                        end
                        
                        -- Update border color
                        local theme = GetTheme()
                        local borderColor = success and theme.notification_success or theme.notification_error
                        notif.frame.UIStroke.Color = borderColor
                        
                        -- Update progress bar color
                        local progressBar = notif.frame:FindFirstChild("ProgressBar")
                        if progressBar then
                            progressBar.BackgroundColor3 = borderColor
                        end
                    end
                    break
               
                end
            end
            
            -- Auto-remove after delay
            task.delay(3, function()
                NexusUI.RemoveNotification(notificationId)
            end)
        end,
        
        Cancel = function()
            NexusUI.RemoveNotification(notificationId)
        end
    }
end

function NexusUI.CreateToastNotification(options)
    local config = {
        message = options.message or "",
        duration = options.duration or 2,
        position = options.position or "bottom", -- "top", "bottom", "middle"
        style = options.style or "minimal" -- "minimal", "standard", "rich"
    }
    
    local theme = GetTheme()
    local toastId = "toast_" .. tick() .. "_" .. math.random(1000, 9999)
    
    -- Determine position
    local positionY
    if config.position == "top" then
        positionY = UDim2.new(0.5, 0, 0, 50)
    elseif config.position == "middle" then
        positionY = UDim2.new(0.5, 0, 0.5, 0)
    else -- bottom
        positionY = UDim2.new(0.5, 0, 1, -50)
    end
    
    -- Create toast frame
    local toast = CreateRoundedFrame(
        toastId,
        UDim2.new(0, 0, 0, 40),
        positionY,
        _nexus.screen_gui
    )
    
    toast.BackgroundColor3 = theme.notification_bg
    toast.BackgroundTransparency = 0.1
    toast.ZIndex = 150
    toast.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Add message
    local message = CreateTextLabel(
        "Message",
        config.message,
        UDim2.new(1, -20, 1, 0),
        UDim2.new(0, 10, 0, 0),
        toast,
        {
            text_color = theme.text_primary,
            text_size = 14,
            x_align = Enum.TextXAlignment.Center
        }
    )
    
    -- Animate in
    toast.Size = UDim2.new(0, 0, 0, 40)
    
    _nexus.animation_tween_service:Create(
        toast,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, message.TextBounds.X + 40, 0, 40)}
    ):Play()
    
    -- Auto-remove
    task.delay(config.duration, function()
        _nexus.animation_tween_service:Create(
            toast,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 40)}
        ):Play()
        
        task.delay(0.3, function()
            toast:Destroy()
        end)
    end)
    
    return toastId
end

-- **WINDOW MANAGEMENT UTILITIES**
function NexusUI.BringAllToFront()
    local maxZIndex = 10
    
    -- Find current max z-index
    for _, window in pairs(_nexus.windows) do
        if window.frame.ZIndex > maxZIndex then
            maxZIndex = window.frame.ZIndex
        end
    end
    
    -- Update all windows
    for _, window in pairs(_nexus.windows) do
        window.frame.ZIndex = maxZIndex + 1
        maxZIndex = maxZIndex + 1
    end
    
    _nexus.window_zindex = maxZIndex + 1
end

function NexusUI.MinimizeAllWindows()
    for windowId, window in pairs(_nexus.windows) do
        window.frame.Visible = false
    end
end

function NexusUI.RestoreAllWindows()
    for windowId, window in pairs(_nexus.windows) do
        window.frame.Visible = true
    end
end

function NexusUI.CloseAllWindows()
    for windowId, window in pairs(_nexus.windows) do
        window.frame:Destroy()
    end
    _nexus.windows = {}
end

-- **INPUT UTILITIES**
function NexusUI.IsMouseOverUI()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    -- Check notifications
    for _, notification in ipairs(_nexus.notifications) do
        if notification.frame then
            local framePos = notification.frame.AbsolutePosition
            local frameSize = notification.frame.AbsoluteSize
            
            if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
               mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
                return true
            end
        end
    end
    
    -- Check windows
    for _, window in pairs(_nexus.windows) do
        local framePos = window.frame.AbsolutePosition
        local frameSize = window.frame.AbsoluteSize
        
        if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
           mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
            return true
        end
    end
    
    return false
end

function NexusUI.GetMousePosition()
    return _nexus.mouse_position
end

-- **CONFIGURATION MANAGEMENT**
function NexusUI.SaveConfig(filename)
    filename = filename or "nexusui_config.json"
    
    local config = {
        theme = _nexus.current_theme,
        notification_settings = {
            max_notifications = _nexus.max_notifications,
            duration = _nexus.notification_duration,
            sound = _nexus.config.notification_sound
        },
        window_positions = {}
    }
    
    -- Save window positions
    for windowId, window in pairs(_nexus.windows) do
        config.window_positions[windowId] = {
            position = {window.position.X, window.position.Y},
            size = {window.size.X, window.size.Y}
        }
    end
    
    -- In a real implementation, you'd save this to DataStore or a file
    -- For now, we'll just return the config
    return config
end

function NexusUI.LoadConfig(config)
    if config.theme then
        NexusUI.SetTheme(config.theme)
    end
    
    if config.notification_settings then
        _nexus.max_notifications = config.notification_settings.max_notifications or _nexus.max_notifications
        _nexus.notification_duration = config.notification_settings.duration or _nexus.notification_duration
        _nexus.config.notification_sound = config.notification_settings.sound or _nexus.config.notification_sound
    end
    
    -- Note: Window positions would be restored when windows are recreated
end

-- **PERFORMANCE OPTIMIZATIONS**
function NexusUI.EnablePerformanceMode()
    _nexus.config.enable_animations = false
    _nexus.config.enable_shadows = false
    _nexus.config.enable_blur = false
    _nexus.max_notifications = 3
    
    NexusUI.NotifyInfo("Performance Mode", "Enabled performance optimizations")
end

function NexusUI.DisablePerformanceMode()
    _nexus.config.enable_animations = true
    _nexus.config.enable_shadows = true
    _nexus.config.enable_blur = true
    _nexus.max_notifications = 5
    
    NexusUI.NotifyInfo("Performance Mode", "Disabled performance optimizations")
end

-- **QUICK SETUP FUNCTION**
function NexusUI.QuickSetup(options)
    local config = {
        theme = options.theme or "midnight",
        enable_notifications = options.enable_notifications ~= false,
        enable_performance_mode = options.enable_performance_mode or false,
        parent = options.parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    }
    
    -- Initialize if not already
    if not _nexus.initialized then
        NexusUI.Init()
    end
    
    -- Set theme
    NexusUI.SetTheme(config.theme)
    
    -- Set performance mode
    if config.enable_performance_mode then
        NexusUI.EnablePerformanceMode()
    end
    
    -- Reparent if needed
    if config.parent and _nexus.screen_gui then
        _nexus.screen_gui.Parent = config.parent
    end
    
    -- Send setup complete notification
    if config.enable_notifications then
        task.delay(1, function()
            NexusUI.NotifySuccess(
                "NexusUI Ready",
                string.format("Theme: %s | Performance Mode: %s", 
                    config.theme, 
                    config.enable_performance_mode and "On" or "Off"
                ),
                4
            )
        end)
    end
    
    return true
end

-- **EXPORT THE LIBRARY**
return setmetatable(NexusUI, {
    __call = function(self, options)
        return NexusUI.QuickSetup(options or {})
    end
})
