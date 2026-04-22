-- Simple Notification System for Roblox
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/solal0/libraries/refs/heads/main/lua/Notify.lua"))()

local NotificationSystem = {}

-- Internal state
local _notifications = {}
local _screenGui = nil
local _tweenService = game:GetService("TweenService")
local _runService = game:GetService("RunService")

-- Available icons (Roblox asset IDs)
NotificationSystem.Icons = {
    SUCCESS = "6031068421",
    ERROR = "6031068422",
    WARNING = "6031068423",
    INFO = "6031068424",
    CHECK = "6031068425",
    ALERT = "6031068426",
    BELL = "6031068427",
    SETTINGS = "6031068428",
    USER = "6031068429",
    HOME = "6031068430",
    SEARCH = "6031068431",
    MENU = "6031068432",
    STAR = "6031068437",
    HEART = "6031068438",
    CLOCK = "6031068439",
    CALENDAR = "6031068440"
}

-- Initialize the system
function NotificationSystem.Init()
    if _screenGui then return end
    
    _screenGui = Instance.new("ScreenGui")
    _screenGui.Name = "NotificationSystem"
    _screenGui.ResetOnSpawn = false
    _screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Start update loop
    _runService.Heartbeat:Connect(function()
        NotificationSystem.UpdatePositions()
    end)
end

-- Create a notification
function NotificationSystem.Notify(options)
    if not _screenGui then
        NotificationSystem.Init()
    end
    
    -- Default options
    local config = {
        title = options.title or "Notification",
        text = options.text or "",
        duration = options.duration or 5,
        outlineColor = options.outlineColor or Color3.fromRGB(0, 150, 255),
        icon = options.icon or NotificationSystem.Icons.INFO,
        iconColor = options.iconColor or Color3.fromRGB(255, 255, 255)
    }
    
    -- Generate unique ID
    local notificationId = "notif_" .. tick() .. "_" .. math.random(1000, 9999)
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = notificationId
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 10, 1, 0) -- Start off-screen right
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notification.BackgroundTransparency = 0.5 -- Half transparent
    notification.BorderSizePixel = 0
    notification.ZIndex = 100
    notification.Parent = _screenGui
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    -- Colored outline
    local outline = Instance.new("UIStroke")
    outline.Color = config.outlineColor
    outline.Thickness = 2
    outline.Parent = notification
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = notification
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -20)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = notification
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 0, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. config.icon
    icon.ImageColor3 = config.iconColor
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = content
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -34, 0, 20)
    title.Position = UDim2.new(0, 34, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = content
    
    -- Text
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.new(1, 0, 1, -25)
    text.Position = UDim2.new(0, 0, 0, 25)
    text.BackgroundTransparency = 1
    text.Text = config.text
    text.TextColor3 = Color3.fromRGB(200, 200, 210)
    text.TextSize = 14
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextWrapped = true
    text.Parent = content
    
    -- Progress bar (the line at bottom)
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = config.outlineColor
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notification
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 1)
    progressCorner.Parent = progressBar
    
    -- Close button (optional)
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "Close"
    closeButton.Size = UDim2.new(0, 16, 0, 16)
    closeButton.Position = UDim2.new(1, -16, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://6031097222"
    closeButton.ImageColor3 = Color3.fromRGB(150, 150, 160)
    closeButton.ScaleType = Enum.ScaleType.Fit
    closeButton.Parent = content
    
    -- Hover effect for close button
    closeButton.MouseEnter:Connect(function()
        _tweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            Rotation = 90
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        _tweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(150, 150, 160),
            Rotation = 0
        }):Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        NotificationSystem.Remove(notificationId)
    end)
    
    -- Store notification data
    local notificationData = {
        id = notificationId,
        frame = notification,
        progressBar = progressBar,
        duration = config.duration,
        created = tick(),
        index = #_notifications + 1
    }
    
    table.insert(_notifications, notificationData)
    
    -- Animate in
    notification.Position = UDim2.new(1, 10, 1, 0)
    
    local slideIn = _tweenService:Create(
        notification,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -310, 1, 0)}
    )
    slideIn:Play()
    
    -- Start progress bar animation
    local progressTween = _tweenService:Create(
        progressBar,
        TweenInfo.new(config.duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    progressTween:Play()
    
    -- Auto-remove after duration
    task.delay(config.duration, function()
        if notification.Parent then
            NotificationSystem.Remove(notificationId)
        end
    end)
    
    -- Update positions for all notifications
    NotificationSystem.UpdatePositions()
    
    return notificationId
end

-- Update positions of all notifications (stack them)
function NotificationSystem.UpdatePositions()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local startY = screenSize.Y - 100
    local spacing = 10
    
    for i, notif in ipairs(_notifications) do
        if notif.frame and notif.frame.Parent then
            local targetY = startY - ((i - 1) * (80 + spacing))
            
            _tweenService:Create(
                notif.frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -310, 0, targetY)}
            ):Play()
        end
    end
end

-- Remove a specific notification
function NotificationSystem.Remove(id)
    for i, notif in ipairs(_notifications) do
        if notif.id == id and notif.frame and notif.frame.Parent then
            -- Animate out
            local slideOut = _tweenService:Create(
                notif.frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 10, 0, notif.frame.Position.Y.Offset)}
            )
            slideOut:Play()
            
            slideOut.Completed:Connect(function()
                notif.frame:Destroy()
                table.remove(_notifications, i)
                NotificationSystem.UpdatePositions()
            end)
            
            break
        end
    end
end

-- Clear all notifications
function NotificationSystem.Clear()
    for _, notif in ipairs(_notifications) do
        if notif.frame then
            notif.frame:Destroy()
        end
    end
    _notifications = {}
end

-- Quick notification helpers
function NotificationSystem.Success(title, text, duration)
    return NotificationSystem.Notify({
        title = title,
        text = text,
        duration = duration or 3,
        outlineColor = Color3.fromRGB(0, 200, 100),
        icon = NotificationSystem.Icons.SUCCESS,
        iconColor = Color3.fromRGB(0, 200, 100)
    })
end

function NotificationSystem.Error(title, text, duration)
    return NotificationSystem.Notify({
        title = title,
        text = text,
        duration = duration or 5,
        outlineColor = Color3.fromRGB(255, 80, 80),
        icon = NotificationSystem.Icons.ERROR,
        iconColor = Color3.fromRGB(255, 80, 80)
    })
end

function NotificationSystem.Warning(title, text, duration)
    return NotificationSystem.Notify({
        title = title,
        text = text,
        duration = duration or 4,
        outlineColor = Color3.fromRGB(255, 180, 0),
        icon = NotificationSystem.Icons.WARNING,
        iconColor = Color3.fromRGB(255, 180, 0)
    })
end

function NotificationSystem.Info(title, text, duration)
    return NotificationSystem.Notify({
        title = title,
        text = text,
        duration = duration or 3,
        outlineColor = Color3.fromRGB(100, 180, 255),
        icon = NotificationSystem.Icons.INFO,
        iconColor = Color3.fromRGB(100, 180, 255)
    })
end

-- Export
return NotificationSystem
