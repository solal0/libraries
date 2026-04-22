-- bad.

-- ImGui-Lua for Roblox
-- Version: 1.0.0
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/solal0/libraries/refs/heads/main/lua/ImGui2.lua"))()

local ImGui = {}
ImGui.__index = ImGui

-- Internal state management
local _context = {
    current_window = nil,
    windows = {},
    next_window_id = 1,
    next_widget_id = 1,
    style = {},
    io = {},
    draw_calls = {},
    hot_item = nil,
    active_item = nil,
    hovered_item = nil,
    mouse_pos = Vector2.new(0, 0),
    mouse_down = {false, false, false},
    keys_down = {},
    frame_count = 0,
    time = 0,
    delta_time = 0
}

-- Style configuration (matching original ImGui defaults)
ImGui.Style = {
    Alpha = 1.0,
    WindowPadding = Vector2.new(8, 8),
    WindowRounding = 0.0,
    WindowBorderSize = 1.0,
    WindowMinSize = Vector2.new(32, 32),
    WindowTitleAlign = Vector2.new(0.0, 0.5),
    ChildRounding = 0.0,
    ChildBorderSize = 1.0,
    PopupRounding = 0.0,
    PopupBorderSize = 1.0,
    FramePadding = Vector2.new(4, 3),
    FrameRounding = 0.0,
    FrameBorderSize = 0.0,
    ItemSpacing = Vector2.new(8, 4),
    ItemInnerSpacing = Vector2.new(4, 4),
    IndentSpacing = 21.0,
    ScrollbarSize = 16.0,
    ScrollbarRounding = 9.0,
    GrabMinSize = 10.0,
    GrabRounding = 0.0,
    TabRounding = 4.0,
    ButtonTextAlign = Vector2.new(0.5, 0.5),
    DisplayWindowPadding = Vector2.new(19, 19),
    DisplaySafeAreaPadding = Vector2.new(3, 3),
    MouseCursorScale = 1.0,
    AntiAliasedLines = true,
    AntiAliasedFill = true,
    CurveTessellationTol = 1.25,
    
    -- Colors (using Roblox Color3 values)
    Colors = {
        Text = Color3.fromRGB(255, 255, 255),
        TextDisabled = Color3.fromRGB(128, 128, 128),
        WindowBg = Color3.fromRGB(15, 15, 15),
        ChildBg = Color3.fromRGB(0, 0, 0),
        PopupBg = Color3.fromRGB(20, 20, 20),
        Border = Color3.fromRGB(40, 40, 40),
        BorderShadow = Color3.fromRGB(0, 0, 0),
        FrameBg = Color3.fromRGB(41, 74, 122),
        FrameBgHovered = Color3.fromRGB(66, 150, 250),
        FrameBgActive = Color3.fromRGB(66, 150, 250),
        TitleBg = Color3.fromRGB(10, 10, 10),
        TitleBgActive = Color3.fromRGB(41, 74, 122),
        TitleBgCollapsed = Color3.fromRGB(0, 0, 0),
        MenuBarBg = Color3.fromRGB(36, 36, 36),
        ScrollbarBg = Color3.fromRGB(5, 5, 5),
        ScrollbarGrab = Color3.fromRGB(80, 80, 80),
        ScrollbarGrabHovered = Color3.fromRGB(100, 100, 100),
        ScrollbarGrabActive = Color3.fromRGB(120, 120, 120),
        CheckMark = Color3.fromRGB(66, 150, 250),
        SliderGrab = Color3.fromRGB(61, 133, 224),
        SliderGrabActive = Color3.fromRGB(66, 150, 250),
        Button = Color3.fromRGB(41, 74, 122),
        ButtonHovered = Color3.fromRGB(66, 150, 250),
        ButtonActive = Color3.fromRGB(15, 135, 250),
        Header = Color3.fromRGB(41, 74, 122),
        HeaderHovered = Color3.fromRGB(66, 150, 250),
        HeaderActive = Color3.fromRGB(66, 150, 250),
        Separator = Color3.fromRGB(61, 61, 61),
        SeparatorHovered = Color3.fromRGB(66, 150, 250),
        SeparatorActive = Color3.fromRGB(66, 150, 250),
        ResizeGrip = Color3.fromRGB(200, 200, 200),
        ResizeGripHovered = Color3.fromRGB(66, 150, 250),
        ResizeGripActive = Color3.fromRGB(66, 150, 250),
        Tab = Color3.fromRGB(46, 89, 148),
        TabHovered = Color3.fromRGB(66, 150, 250),
        TabActive = Color3.fromRGB(51, 105, 173),
        TabUnfocused = Color3.fromRGB(17, 26, 37),
        TabUnfocusedActive = Color3.fromRGB(35, 67, 108),
        PlotLines = Color3.fromRGB(156, 156, 156),
        PlotLinesHovered = Color3.fromRGB(255, 110, 89),
        PlotHistogram = Color3.fromRGB(230, 179, 0),
        PlotHistogramHovered = Color3.fromRGB(255, 153, 0),
        TableHeaderBg = Color3.fromRGB(48, 48, 48),
        TableBorderStrong = Color3.fromRGB(79, 79, 79),
        TableBorderLight = Color3.fromRGB(59, 59, 59),
        TableRowBg = Color3.fromRGB(0, 0, 0),
        TableRowBgAlt = Color3.fromRGB(255, 255, 255, 0.06),
        TextSelectedBg = Color3.fromRGB(66, 150, 250, 0.35),
        DragDropTarget = Color3.fromRGB(255, 255, 0, 0.9),
        NavHighlight = Color3.fromRGB(66, 150, 250),
        NavWindowingHighlight = Color3.fromRGB(255, 255, 255, 0.7),
        NavWindowingDimBg = Color3.fromRGB(204, 204, 204, 0.2),
        ModalWindowDimBg = Color3.fromRGB(204, 204, 204, 0.35)
    }
}

-- IO Configuration
ImGui.IO = {
    DisplaySize = Vector2.new(1920, 1080),
    DeltaTime = 1.0 / 60.0,
    IniSavingRate = 5.0,
    IniFilename = nil,
    LogFilename = nil,
    MouseDoubleClickTime = 0.30,
    MouseDoubleClickMaxDist = 6.0,
    MouseDragThreshold = 6.0,
    KeyRepeatDelay = 0.275,
    KeyRepeatRate = 0.050,
    FontGlobalScale = 1.0,
    FontAllowUserScaling = false,
    DisplayFramebufferScale = Vector2.new(1, 1),
    ConfigDockingNoSplit = false,
    ConfigDockingWithShift = false,
    ConfigDockingAlwaysTabBar = false,
    ConfigDockingTransparentPayload = false,
    ConfigViewportsNoAutoMerge = false,
    ConfigViewportsNoTaskBarIcon = false,
    ConfigViewportsNoDecoration = true,
    ConfigViewportsNoDefaultParent = false,
    MouseDrawCursor = false,
    ConfigMacOSXBehaviors = false,
    ConfigInputTrickleEventQueue = true,
    ConfigInputTextCursorBlink = true,
    ConfigInputTextEnterKeepActive = false,
    ConfigDragClickToInputText = false,
    ConfigWindowsResizeFromEdges = true,
    ConfigWindowsMoveFromTitleBarOnly = false,
    ConfigMemoryCompactTimer = 60.0,
    BackendPlatformName = "Roblox",
    BackendRendererName = "Roblox Renderer",
    BackendPlatformUserData = nil,
    BackendRendererUserData = nil,
    BackendLanguageUserData = nil,
    GetClipboardTextFn = function() return "" end,
    SetClipboardTextFn = function(text) end,
    ClipboardUserData = nil,
    ImeWindowHandle = nil,
    ImeSetInputScreenPosFn = function(pos) end,
    RenderDrawListsFn = nil,
    MousePos = Vector2.new(0, 0),
    MouseWheel = 0.0,
    MouseWheelH = 0.0,
    KeyCtrl = false,
    KeyShift = false,
    KeyAlt = false,
    KeySuper = false,
    KeysDown = {},
    WantCaptureMouse = false,
    WantCaptureKeyboard = false,
    WantTextInput = false,
    WantSetMousePos = false,
    WantSaveIniSettings = false,
    NavActive = false,
    NavVisible = false,
    Framerate = 60.0,
    MetricsRenderVertices = 0,
    MetricsRenderIndices = 0,
    MetricsRenderWindows = 0,
    MetricsActiveWindows = 0,
    MetricsActiveAllocations = 0,
    MouseDelta = Vector2.new(0, 0)
}

-- Internal helper functions
local function GetID(str)
    _context.next_widget_id = _context.next_widget_id + 1
    return tostring(str) .. "_" .. tostring(_context.next_widget_id)
end

local function IsMouseHoveringRect(min, max)
    local mouse = _context.mouse_pos
    return mouse.X >= min.X and mouse.Y >= min.Y and mouse.X <= max.X and mouse.Y <= max.Y
end

local function CalculateTextSize(text, font, wrap_width)
    -- Simplified text size calculation
    local char_width = 6
    local char_height = 12
    local lines = 1
    local max_line_width = 0
    local current_line_width = 0
    
    for i = 1, #text do
        local char = text:sub(i, i)
        if char == '\n' then
            lines = lines + 1
            max_line_width = math.max(max_line_width, current_line_width)
            current_line_width = 0
        else
            current_line_width = current_line_width + char_width
        end
    end
    
    max_line_width = math.max(max_line_width, current_line_width)
    
    if wrap_width > 0 then
        -- Simple word wrapping (simplified)
        local words = {}
        for word in text:gmatch("%S+") do
            table.insert(words, word)
        end
        
        local line_width = 0
        lines = 1
        for _, word in ipairs(words) do
            local word_width = #word * char_width
            if line_width + word_width > wrap_width then
                lines = lines + 1
                line_width = word_width + char_width
            else
                line_width = line_width + word_width + char_width
            end
        end
        max_line_width = wrap_width
    end
    
    return Vector2.new(max_line_width, lines * char_height)
end

local function PushColor(target, color)
    table.insert(_context.draw_calls, {
        type = "color",
        target = target,
        color = color
    })
end

local function PopColor()
    for i = #_context.draw_calls, 1, -1 do
        if _context.draw_calls[i].type == "color" then
            table.remove(_context.draw_calls, i)
            break
        end
    end
end

-- Core Window Functions
function ImGui.Begin(name, open, flags)
    flags = flags or 0
    
    local window_id = GetID(name)
    local window = _context.windows[window_id]
    
    if not window then
        window = {
            id = window_id,
            name = name,
            position = Vector2.new(100, 100),
            size = Vector2.new(400, 300),
            open = open ~= false,
            flags = flags,
            scroll = Vector2.new(0, 0),
            content_region = Vector2.new(0, 0),
            cursor_pos = Vector2.new(0, 0),
            cursor_start_pos = Vector2.new(0, 0),
            items = {}
        }
        _context.windows[window_id] = window
    end
    
    if not window.open then
        return false
    end
    
    _context.current_window = window
    
    -- Calculate window rect
    local title_bar_height = 20
    local window_rect_min = window.position
    local window_rect_max = window.position + window.size
    
    -- Check if window is being dragged
    local title_bar_rect_min = window_rect_min
    local title_bar_rect_max = Vector2.new(window_rect_max.X, window_rect_min.Y + title_bar_height)
    
    if IsMouseHoveringRect(title_bar_rect_min, title_bar_rect_max) and _context.mouse_down[1] then
        window.position = window.position + (_context.mouse_pos - _context.mouse_pos_prev)
    end
    
    -- Store mouse position for next frame
    _context.mouse_pos_prev = _context.mouse_pos
    
    -- Add window to draw calls
    table.insert(_context.draw_calls, {
        type = "window",
        id = window_id,
        name = name,
        position = window.position,
        size = window.size,
        open = window.open,
        flags = flags
    })
    
    -- Reset window cursor
    window.cursor_pos = Vector2.new(window.position.X + 8, window.position.Y + title_bar_height + 8)
    window.cursor_start_pos = window.cursor_pos
    
    return true
end

function ImGui.End()
    if not _context.current_window then
        return
    end
    
    -- Add window end marker
    table.insert(_context.draw_calls, {
        type = "window_end",
        id = _context.current_window.id
    })
    
    _context.current_window = nil
end

-- Widget Functions
function ImGui.Button(label, size)
    size = size or Vector2.new(0, 0)
    
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    local text_size = CalculateTextSize(label)
    
    if size.X == 0 then size = Vector2.new(text_size.X + 20, text_size.Y + 10) end
    
    local button_min = window.cursor_pos
    local button_max = button_min + size
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(button_min, button_max)
    local is_clicked = false
    
    if is_hovered and _context.mouse_down[1] and not _context.active_item then
        _context.active_item = id
    end
    
    if _context.active_item == id and not _context.mouse_down[1] then
        if is_hovered then
            is_clicked = true
        end
        _context.active_item = nil
    end
    
    -- Add button to draw calls
    table.insert(_context.draw_calls, {
        type = "button",
        id = id,
        label = label,
        position = button_min,
        size = size,
        hovered = is_hovered,
        active = _context.active_item == id
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, button_max.Y + 4)
    
    return is_clicked
end

function ImGui.Checkbox(label, value)
    if not _context.current_window then
        return value, false
    end
    
    local window = _context.current_window
    local size = Vector2.new(20, 20)
    
    local checkbox_min = window.cursor_pos
    local checkbox_max = checkbox_min + size
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(checkbox_min, checkbox_max)
    local changed = false
    
    if is_hovered and _context.mouse_down[1] and not _context.active_item then
        value = not value
        changed = true
        _context.active_item = id
    end
    
    if _context.active_item == id and not _context.mouse_down[1] then
        _context.active_item = nil
    end
    
    -- Add checkbox to draw calls
    table.insert(_context.draw_calls, {
        type = "checkbox",
        id = id,
        label = label,
        position = checkbox_min,
        size = size,
        value = value,
        hovered = is_hovered
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(checkbox_max.X + 10, checkbox_min.Y)
    local text_size = CalculateTextSize(label)
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, math.max(checkbox_max.Y, checkbox_min.Y + text_size.Y) + 4)
    
    return value, changed
end

function ImGui.SliderFloat(label, value, min, max, format, flags)
    format = format or "%.3f"
    flags = flags or 0
    
    if not _context.current_window then
        return value, false
    end
    
    local window = _context.current_window
    local width = 200
    local height = 20
    
    local slider_min = window.cursor_pos
    local slider_max = slider_min + Vector2.new(width, height)
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(slider_min, slider_max)
    local changed = false
    
    local normalized = (value - min) / (max - min)
    local grab_pos = slider_min.X + normalized * width
    
    if _context.active_item == id then
        if _context.mouse_down[1] then
            local mouse_x = _context.mouse_pos.X
            local new_normalized = math.clamp((mouse_x - slider_min.X) / width, 0, 1)
            value = min + new_normalized * (max - min)
            changed = true
        else
            _context.active_item = nil
        end
    elseif is_hovered and _context.mouse_down[1] then
        _context.active_item = id
        changed = true
    end
    
    -- Add slider to draw calls
    table.insert(_context.draw_calls, {
        type = "slider",
        id = id,
        label = label,
        position = slider_min,
        size = Vector2.new(width, height),
        value = value,
        min = min,
        max = max,
        normalized = normalized,
        hovered = is_hovered,
        active = _context.active_item == id
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, slider_max.Y + 4)
    
    return value, changed
end

function ImGui.InputText(label, text, flags, callback)
    flags = flags or 0
    
    if not _context.current_window then
        return text, false
    end
    
    local window = _context.current_window
    local width = 200
    local height = 25
    
    local input_min = window.cursor_pos
    local input_max = input_min + Vector2.new(width, height)
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(input_min, input_max)
    local changed = false
    
    -- Focus management
    if is_hovered and _context.mouse_down[1] then
        _context.active_item = id
    elseif _context.mouse_down[1] and _context.active_item == id and not is_hovered then
        _context.active_item = nil
    end
    
    -- Text input (simplified - in real implementation would handle keyboard input)
    if _context.active_item == id then
        -- This is where you'd handle actual text input
        -- For this example, we'll just mark it as active
    end
    
    -- Add input text to draw calls
    table.insert(_context.draw_calls, {
        type = "input_text",
        id = id,
        label = label,
        position = input_min,
        size = Vector2.new(width, height),
        text = text,
        hovered = is_hovered,
        active = _context.active_item == id,
        has_focus = _context.active_item == id
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, input_max.Y + 4)
    
    return text, changed
end

function ImGui.Text(text)
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    local text_size = CalculateTextSize(text)
    
    -- Add text to draw calls
    table.insert(_context.draw_calls, {
        type = "text",
        position = window.cursor_pos,
        text = text,
        color = ImGui.Style.Colors.Text
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + text_size.Y + 4)
end

function ImGui.TextColored(color, text)
    PushColor("Text", color)
    ImGui.Text(text)
    PopColor()
end

function ImGui.TextDisabled(text)
    PushColor("Text", ImGui.Style.Colors.TextDisabled)
    ImGui.Text(text)
    PopColor()
end

function ImGui.Separator()
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    local width = window.size.X - 16
    
    -- Add separator to draw calls
    table.insert(_context.draw_calls, {
        type = "separator",
        position = window.cursor_pos,
        width = width
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + 10)
end

function ImGui.SameLine(offset_from_start_x, spacing)
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    offset_from_start_x = offset_from_start_x or 0
    spacing = spacing or -1
    
    if spacing == -1 then
        spacing = ImGui.Style.ItemSpacing.X
    end
    
    window.cursor_pos = Vector2.new(
        window.cursor_start_pos.X + offset_from_start_x,
        window.cursor_pos.Y
    )
end

function ImGui.NewLine()
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + ImGui.Style.ItemSpacing.Y)
end

function ImGui.Spacing()
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + ImGui.Style.ItemSpacing.Y)
end

function ImGui.Dummy(size)
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    window.cursor_pos = window.cursor_pos + size
end

function ImGui.BeginChild(id, size, border, flags)
    -- Simplified child implementation
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    size = size or Vector2.new(0, 0)
    
    if size.X == 0 then size = Vector2.new(window.size.X - 16, 100) end
    if size.Y == 0 then size = Vector2.new(size.X, 100) end
    
    local child_min = window.cursor_pos
    local child_max = child_min + size
    
    -- Add child to draw calls
    table.insert(_context.draw_calls, {
        type = "child",
        id = id,
        position = child_min,
        size = size,
        border = border or false
    })
    
    -- Update window cursor for child content
    window.cursor_start_pos = child_min + Vector2.new(4, 4)
    window.cursor_pos = window.cursor_start_pos
    
    return true
end

function ImGui.EndChild()
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    
    -- Add child end marker
    table.insert(_context.draw_calls, {
        type = "child_end"
    })
    
    -- Restore original cursor position
    window.cursor_start_pos = Vector2.new(window.position.X + 8, window.position.Y + 28)
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + 8)
end

-- Layout Functions
function ImGui.BeginGroup()
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    window.group_start_pos = window.cursor_pos
end

function ImGui.EndGroup()
    if not _context.current_window or not window.group_start_pos then
        return
    end
    
    local window = _context.current_window
    local group_min = window.group_start_pos
    local group_max = window.cursor_pos
    
    -- Advance cursor below the group
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, group_max.Y + ImGui.Style.ItemSpacing.Y)
    window.group_start_pos = nil
end

-- Tree Nodes
function ImGui.TreeNode(label)
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    local id = GetID(label)
    
    -- Check if this tree node is open
    if not _context.tree_nodes then
        _context.tree_nodes = {}
    end
    
    if _context.tree_nodes[id] == nil then
        _context.tree_nodes[id] = false
    end
    
    local is_open = _context.tree_nodes[id]
    
    -- Draw tree node
    table.insert(_context.draw_calls, {
        type = "tree_node",
        id = id,
        label = label,
        position = window.cursor_pos,
        is_open = is_open
    })
    
    -- Handle click
    local text_size = CalculateTextSize((is_open and "[-] " or "[+] ") .. label)
    local rect_min = window.cursor_pos
    local rect_max = rect_min + text_size
    
    if IsMouseHoveringRect(rect_min, rect_max) and _context.mouse_down[1] then
        _context.tree_nodes[id] = not is_open
    end
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, rect_max.Y + 4)
    
    return is_open
end

function ImGui.TreePop()
    -- In a full implementation, this would handle indentation levels
end

-- Tab Bars and Tabs
function ImGui.BeginTabBar(id, flags)
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    
    _context.current_tab_bar = {
        id = id,
        flags = flags or 0,
        position = window.cursor_pos,
        selected_tab = nil
    }
    
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + 30)
    
    return true
end

function ImGui.EndTabBar()
    if not _context.current_tab_bar then
        return
    end
    
    _context.current_tab_bar = nil
end

function ImGui.BeginTabItem(label, open, flags)
    if not _context.current_tab_bar then
        return false
    end
    
    local tab_bar = _context.current_tab_bar
    local id = GetID(label)
    
    -- Draw tab item
    table.insert(_context.draw_calls, {
        type = "tab_item",
        id = id,
        label = label,
        position = tab_bar.position,
        is_selected = tab_bar.selected_tab == id
    })
    
    -- Handle click
    local text_size = CalculateTextSize(label)
    local tab_width = text_size.X + 20
    local tab_rect_min = tab_bar.position
    local tab_rect_max = tab_rect_min + Vector2.new(tab_width, 30)
    
    if IsMouseHoveringRect(tab_rect_min, tab_rect_max) and _context.mouse_down[1] then
        tab_bar.selected_tab = id
    end
    
    -- Update position for next tab
    tab_bar.position = Vector2.new(tab_bar.position.X + tab_width + 2, tab_bar.position.Y)
    
    return tab_bar.selected_tab == id
end

function ImGui.EndTabItem()
    -- Tab item end marker
end

-- Style Functions
function ImGui.PushStyleColor(idx, color)
    PushColor(idx, color)
end

function ImGui.PopStyleColor(count)
    count = count or 1
    for i = 1, count do
        PopColor()
    end
end

function ImGui.PushStyleVar(idx, value)
    table.insert(_context.draw_calls, {
        type = "style_var",
        idx = idx,
        value = value
    })
end

function ImGui.PopStyleVar(count)
    count = count or 1
    for i = 1, count do
        for j = #_context.draw_calls, 1, -1 do
            if _context.draw_calls[j].type == "style_var" then
                table.remove(_context.draw_calls, j)
                break
            end
        end
    end
end

-- Renderer (Roblox-specific implementation)
function ImGui.CreateRenderer(screenGui)
    local renderer = {
        screenGui = screenGui or Instance.new("ScreenGui"),
        frames = {},
        current_frame = nil
    }
    
    renderer.screenGui.Name = "ImGuiRenderer"
    renderer.screenGui.ResetOnSpawn = false
    renderer.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    function renderer:Render(draw_calls)
        -- Clear previous frame
        for _, obj in ipairs(self.screenGui:GetChildren()) do
            if obj.Name == "ImGuiFrame" then
                obj:Destroy()
            end
        end
        
        -- Create new frame
        local frame = Instance.new("Frame")
        frame.Name = "ImGuiFrame"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = self.screenGui
        
        -- Process draw calls
        for _, call in ipairs(draw_calls) do
            if call.type == "window" then
                -- Create window frame
                local window = Instance.new("Frame")
                window.Name = call.id
                window.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                window.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                window.BackgroundColor3 = ImGui.Style.Colors.WindowBg
                window.BorderColor3 = ImGui.Style.Colors.Border
                window.BorderSizePixel = 1
                window.Parent = frame
                
                -- Title bar
                local titleBar = Instance.new("Frame")
                titleBar.Name = "TitleBar"
                titleBar.Position = UDim2.new(0, 0, 0, 0)
                titleBar.Size = UDim2.new(1, 0, 0, 20)
                titleBar.BackgroundColor3 = ImGui.Style.Colors.TitleBg
                titleBar.BorderSizePixel = 0
                titleBar.Parent = window
                
                -- Title text
                local titleText = Instance.new("TextLabel")
                titleText.Name = "Title"
                titleText.Position = UDim2.new(0, 8, 0, 0)
                titleText.Size = UDim2.new(1, -16, 1, 0)
                titleText.BackgroundTransparency = 1
                titleText.Text = call.name
                titleText.TextColor3 = ImGui.Style.Colors.Text
                titleText.TextXAlignment = Enum.TextXAlignment.Left
                titleText.Font = Enum.Font.Code
                titleText.TextSize = 14
                titleText.Parent = titleBar
                
            elseif call.type == "button" then
                local button = Instance.new("TextButton")
                button.Name = call.id
                button.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                button.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                button.BackgroundColor3 = call.active and ImGui.Style.Colors.ButtonActive 
                                        or call.hovered and ImGui.Style.Colors.ButtonHovered 
                                        or ImGui.Style.Colors.Button
                button.BorderColor3 = ImGui.Style.Colors.Border
                button.BorderSizePixel = 1
                button.Text = call.label
                button.TextColor3 = ImGui.Style.Colors.Text
                button.Font = Enum.Font.Code
                button.TextSize = 14
                button.Parent = frame
                
            elseif call.type == "text" then
                local text = Instance.new("TextLabel")
                text.Name = "Text_" .. #frame:GetChildren()
                text.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                text.Size = UDim2.new(0, 200, 0, 20)
                text.BackgroundTransparency = 1
                text.Text = call.text
                text.TextColor3 = call.color or ImGui.Style.Colors.Text
                text.TextXAlignment = Enum.TextXAlignment.Left
                text.Font = Enum.Font.Code
                text.TextSize = 14
                text.Parent = frame
                
            elseif call.type == "checkbox" then
                -- Checkbox frame
                local checkbox = Instance.new("Frame")
                checkbox.Name = call.id
                checkbox.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                checkbox.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                checkbox.BackgroundColor3 = ImGui.Style.Colors.FrameBg
                checkbox.BorderColor3 = ImGui.Style.Colors.Border
                checkbox.BorderSizePixel = 1
                checkbox.Parent = frame
                        -- Checkmark (if checked)
                if call.value then
                    local checkmark = Instance.new("Frame")
                    checkmark.Name = "Checkmark"
                    checkmark.Position = UDim2.new(0, 4, 0, 4)
                    checkmark.Size = UDim2.new(0, call.size.X - 8, 0, call.size.Y - 8)
                    checkmark.BackgroundColor3 = ImGui.Style.Colors.CheckMark
                    checkmark.BorderSizePixel = 0
                    checkmark.Parent = checkbox
                end
                
                -- Checkbox label
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Position = UDim2.new(0, call.size.X + 8, 0, 0)
                label.Size = UDim2.new(0, 200, 0, call.size.Y)
                label.BackgroundTransparency = 1
                label.Text = call.label
                label.TextColor3 = ImGui.Style.Colors.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Font = Enum.Font.Code
                label.TextSize = 14
                label.Parent = checkbox
                
            elseif call.type == "slider" then
                -- Slider background
                local slider = Instance.new("Frame")
                slider.Name = call.id
                slider.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                slider.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                slider.BackgroundColor3 = ImGui.Style.Colors.FrameBg
                slider.BorderColor3 = ImGui.Style.Colors.Border
                slider.BorderSizePixel = 1
                slider.Parent = frame
                
                -- Slider fill
                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.Position = UDim2.new(0, 0, 0, 0)
                fill.Size = UDim2.new(call.normalized, 0, 1, 0)
                fill.BackgroundColor3 = call.active and ImGui.Style.Colors.SliderGrabActive 
                                      or call.hovered and ImGui.Style.Colors.SliderGrabHovered 
                                      or ImGui.Style.Colors.SliderGrab
                fill.BorderSizePixel = 0
                fill.Parent = slider
                
                -- Slider label and value
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Position = UDim2.new(0, 0, 0, -20)
                label.Size = UDim2.new(1, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.Text = string.format("%s: %.3f", call.label, call.value)
                label.TextColor3 = ImGui.Style.Colors.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Font = Enum.Font.Code
                label.TextSize = 12
                label.Parent = slider
                
            elseif call.type == "input_text" then
                -- Input field background
                local input = Instance.new("Frame")
                input.Name = call.id
                input.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                input.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                input.BackgroundColor3 = call.active and ImGui.Style.Colors.FrameBgActive 
                                       or call.hovered and ImGui.Style.Colors.FrameBgHovered 
                                       or ImGui.Style.Colors.FrameBg
                input.BorderColor3 = ImGui.Style.Colors.Border
                input.BorderSizePixel = 1
                input.Parent = frame
                
                -- Input text
                local textBox = Instance.new("TextBox")
                textBox.Name = "TextBox"
                textBox.Position = UDim2.new(0, 4, 0, 0)
                textBox.Size = UDim2.new(1, -8, 1, 0)
                textBox.BackgroundTransparency = 1
                textBox.Text = call.text
                textBox.TextColor3 = ImGui.Style.Colors.Text
                textBox.TextXAlignment = Enum.TextXAlignment.Left
                textBox.Font = Enum.Font.Code
                textBox.TextSize = 14
                textBox.ClearTextOnFocus = false
                textBox.Parent = input
                
                -- Input label
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.Position = UDim2.new(0, 0, 0, -20)
                label.Size = UDim2.new(1, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.Text = call.label
                label.TextColor3 = ImGui.Style.Colors.Text
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Font = Enum.Font.Code
                label.TextSize = 12
                label.Parent = input
                
            elseif call.type == "separator" then
                local separator = Instance.new("Frame")
                separator.Name = "Separator_" .. #frame:GetChildren()
                separator.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                separator.Size = UDim2.new(0, call.width, 0, 1)
                separator.BackgroundColor3 = ImGui.Style.Colors.Separator
                separator.BorderSizePixel = 0
                separator.Parent = frame
                
            elseif call.type == "child" then
                local child = Instance.new("Frame")
                child.Name = call.id
                child.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                child.Size = UDim2.new(0, call.size.X, 0, call.size.Y)
                child.BackgroundColor3 = ImGui.Style.Colors.ChildBg
                child.BorderColor3 = call.border and ImGui.Style.Colors.Border or Color3.new(0, 0, 0)
                child.BorderSizePixel = call.border and 1 or 0
                child.Parent = frame
                
            elseif call.type == "tree_node" then
                local treeNode = Instance.new("TextButton")
                treeNode.Name = call.id
                treeNode.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                treeNode.Size = UDim2.new(0, 200, 0, 20)
                treeNode.BackgroundTransparency = 1
                treeNode.Text = (call.is_open and "[-] " or "[+] ") .. call.label
                treeNode.TextColor3 = ImGui.Style.Colors.Text
                treeNode.TextXAlignment = Enum.TextXAlignment.Left
                treeNode.Font = Enum.Font.Code
                treeNode.TextSize = 14
                treeNode.Parent = frame
                
            elseif call.type == "tab_item" then
                local tab = Instance.new("TextButton")
                tab.Name = call.id
                tab.Position = UDim2.new(0, call.position.X, 0, call.position.Y)
                tab.Size = UDim2.new(0, 100, 0, 30)
                tab.BackgroundColor3 = call.is_selected and ImGui.Style.Colors.TabActive 
                                     or ImGui.Style.Colors.Tab
                tab.BorderColor3 = ImGui.Style.Colors.Border
                tab.BorderSizePixel = 1
                tab.Text = call.label
                tab.TextColor3 = ImGui.Style.Colors.Text
                tab.Font = Enum.Font.Code
                tab.TextSize = 14
                tab.Parent = frame
            end
        end
        
        return frame
    end
    
    function renderer:Destroy()
        self.screenGui:Destroy()
    end
    
    return renderer
end

-- Input Handling
function ImGui.UpdateInput()
    -- Get mouse position
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    _context.mouse_pos = Vector2.new(mouse.X, mouse.Y)
    
    -- Get mouse button states
    _context.mouse_down[1] = mouse.Button1Down  -- Left
    _context.mouse_down[2] = mouse.Button2Down  -- Right
    
    -- Get key states
    local userInputService = game:GetService("UserInputService")
    _context.keys_down = {}
    
    -- Update IO
    ImGui.IO.MousePos = _context.mouse_pos
    ImGui.IO.MouseDown[0] = _context.mouse_down[1]
    ImGui.IO.MouseDown[1] = _context.mouse_down[2]
    ImGui.IO.DeltaTime = _context.delta_time
    ImGui.IO.DisplaySize = Vector2.new(
        workspace.CurrentCamera.ViewportSize.X,
        workspace.CurrentCamera.ViewportSize.Y
    )
end

-- Frame Management
function ImGui.NewFrame()
    _context.frame_count = _context.frame_count + 1
    _context.time = tick()
    
    -- Calculate delta time
    if _context.last_time then
        _context.delta_time = _context.time - _context.last_time
    else
        _context.delta_time = 1/60
    end
    _context.last_time = _context.time
    
    -- Clear draw calls from previous frame
    _context.draw_calls = {}
    
    -- Update input
    ImGui.UpdateInput()
    
    -- Reset IO capture flags
    ImGui.IO.WantCaptureMouse = false
    ImGui.IO.WantCaptureKeyboard = false
    
    -- Update window states
    for _, window in pairs(_context.windows) do
        if window.open then
            -- Check if mouse is over any window
            local window_rect_min = window.position
            local window_rect_max = window.position + window.size
            
            if IsMouseHoveringRect(window_rect_min, window_rect_max) then
                ImGui.IO.WantCaptureMouse = true
            end
        end
    end
end

function ImGui.Render()
    return _context.draw_calls
end

-- Demo/Example Window (like ImGui.ShowDemoWindow)
function ImGui.ShowDemoWindow(open)
    open = open or true
    
    if ImGui.Begin("ImGui Demo", open) then
        -- Menu Bar
        if ImGui.BeginMenuBar() then
            if ImGui.BeginMenu("File") then
                if ImGui.MenuItem("New") then
                    print("New clicked")
                end
                if ImGui.MenuItem("Open") then
                    print("Open clicked")
                end
                ImGui.Separator()
                if ImGui.MenuItem("Exit") then
                    print("Exit clicked")
                end
                ImGui.EndMenu()
            end
            if ImGui.BeginMenu("Edit") then
                if ImGui.MenuItem("Undo") then
                    print("Undo clicked")
                end
                if ImGui.MenuItem("Redo") then
                    print("Redo clicked")
                end
                ImGui.EndMenu()
            end
            ImGui.EndMenuBar()
        end
        
        -- Basic Widgets Section
        if ImGui.TreeNode("Basic Widgets") then
            -- Buttons
            ImGui.Text("Buttons:")
            if ImGui.Button("Click Me") then
                print("Button clicked!")
            end
            ImGui.SameLine()
            if ImGui.Button("Disabled", true) then
                -- This won't fire when disabled
            end
            
            -- Checkboxes
            ImGui.Text("Checkboxes:")
            local checked = true
            checked, changed = ImGui.Checkbox("Enable Feature", checked)
            if changed then
                print("Checkbox changed to:", checked)
            end
            
            -- Radio Buttons
            ImGui.Text("Radio Buttons:")
            local radio_value = 1
            if ImGui.RadioButton("Option 1", radio_value == 1) then radio_value = 1 end
            ImGui.SameLine()
            if ImGui.RadioButton("Option 2", radio_value == 2) then radio_value = 2 end
            ImGui.SameLine()
            if ImGui.RadioButton("Option 3", radio_value == 3) then radio_value = 3 end
            
            ImGui.TreePop()
        end
        
        -- Input Widgets Section
        if ImGui.TreeNode("Input Widgets") then
            -- Sliders
            ImGui.Text("Sliders:")
            local slider_value = 0.5
            slider_value, changed = ImGui.SliderFloat("Float Slider", slider_value, 0.0, 1.0)
            if changed then
                print("Slider value:", slider_value)
            end
            
            -- Input Text
            ImGui.Text("Input Text:")
            local input_text = "Hello World"
            input_text, changed = ImGui.InputText("Text Input", input_text)
            if changed then
                print("Input text:", input_text)
            end
            
            -- Color Picker
            ImGui.Text("Color Picker:")
            local color = Color3.new(1, 0, 0)
            local color_array = {color.R, color.G, color.B}
            if ImGui.ColorEdit3("Color", color_array) then
                color = Color3.new(color_array[1], color_array[2], color_array[3])
                print("Color changed to:", color)
            end
            
            ImGui.TreePop()
        end
        
        -- Layout Section
        if ImGui.TreeNode("Layout") then
            -- Columns
            ImGui.Text("Columns:")
            if ImGui.BeginTable("##table", 3) then
                ImGui.TableSetupColumn("Name")
                ImGui.TableSetupColumn("Value")
                ImGui.TableSetupColumn("Action")
                ImGui.TableHeadersRow()
                
                for i = 1, 5 do
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    ImGui.Text("Item " .. i)
                    ImGui.TableNextColumn()
                    ImGui.Text(tostring(i * 100))
                    ImGui.TableNextColumn()
                    if ImGui.Button("Action " .. i) then
                        print("Action", i, "clicked")
                    end
                end
                
                ImGui.EndTable()
            end
            
            -- Child Windows
            ImGui.Text("Child Windows:")
            if ImGui.BeginChild("Child1", Vector2.new(200, 100), true) then
                ImGui.Text("Inside child window")
                ImGui.Button("Child Button")
                ImGui.EndChild()
            end
            
            ImGui.SameLine()
            
            if ImGui.BeginChild("Child2", Vector2.new(200, 100), true) then
                ImGui.Text("Another child")
                ImGui.Checkbox("Child Checkbox", true)
                ImGui.EndChild()
            end
            
            ImGui.TreePop()
        end
        
        -- Plotting Section
        if ImGui.TreeNode("Plotting") then
            ImGui.Text("Plot Lines:")
            local values = {0.1, 0.5, 0.3, 0.8, 0.2, 0.6, 0.9, 0.4}
            ImGui.PlotLines("Values", values, #values, 0, "Min: 0, Max: 1", 0, 1, Vector2.new(200, 80))
            
            ImGui.Text("Plot Histogram:")
            ImGui.PlotHistogram("Distribution", values, #values, 0, nil, 0, 1, Vector2.new(200, 80))
            
            ImGui.TreePop()
        end
        
        -- Style Editor
        if ImGui.TreeNode("Style Editor") then
            ImGui.ShowStyleEditor()
            ImGui.TreePop()
        end
        
        -- Metrics Window
        if ImGui.TreeNode("Metrics/Debug") then
            ImGui.Text(string.format("Frame: %d", _context.frame_count))
            ImGui.Text(string.format("Delta Time: %.3f ms", _context.delta_time * 1000))
            ImGui.Text(string.format("FPS: %.1f", 1 / _context.delta_time))
            ImGui.Text(string.format("Windows: %d", #_context.windows))
            ImGui.Text(string.format("Draw Calls: %d", #_context.draw_calls))
            ImGui.TreePop()
        end
        
        ImGui.End()
    end
end

-- Style Editor Function
function ImGui.ShowStyleEditor()
    -- Window rounding
    local window_rounding = ImGui.Style.WindowRounding
    window_rounding, changed = ImGui.SliderFloat("Window Rounding", window_rounding, 0, 12)
    if changed then ImGui.Style.WindowRounding = window_rounding end
    
    -- Frame rounding
    local frame_rounding = ImGui.Style.FrameRounding
    frame_rounding, changed = ImGui.SliderFloat("Frame Rounding", frame_rounding, 0, 12)
    if changed then ImGui.Style.FrameRounding = frame_rounding end
    
    -- Colors
    if ImGui.TreeNode("Colors") then
        for name, color in pairs(ImGui.Style.Colors) do
            local color_array = {color.R, color.G, color.B}
            if ImGui.ColorEdit3(name, color_array) then
                ImGui.Style.Colors[name] = Color3.new(color_array[1], color_array[2], color_array[3])
            end
        end
        ImGui.TreePop()
    end
end

-- Additional Widgets
function ImGui.RadioButton(label, active)
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    local size = Vector2.new(20, 20)
    
    local radio_min = window.cursor_pos
    local radio_max = radio_min + size
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(radio_min, radio_max)
    local clicked = false
    
    if is_hovered and _context.mouse_down[1] and not _context.active_item then
        clicked = true
        _context.active_item = id
    end
    
    if _context.active_item == id and not _context.mouse_down[1] then
        _context.active_item = nil
    end
    
    -- Draw radio button
    table.insert(_context.draw_calls, {
        type = "radio_button",
        id = id,
        label = label,
        position = radio_min,
        size = size,
        active = active,
        hovered = is_hovered
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(radio_max.X + 10, radio_min.Y)
    local text_size = CalculateTextSize(label)
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, math.max(radio_max.Y, radio_min.Y + text_size.Y) + 4)
    
    return clicked
end

function ImGui.ColorEdit3(label, color)
    if not _context.current_window then
        return color, false
    end
    
    local window = _context.current_window
    local size = Vector2.new(100, 20)
    
    local color_min = window.cursor_pos
    local color_max = color_min + size
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(color_min, color_max)
    local changed = false
    
    -- Draw color preview
    table.insert(_context.draw_calls, {
        type = "color_edit",
        id = id,
        label = label,
        position = color_min,
        size = size,
        color = Color3.new(color[1], color[2], color[3]),
        hovered = is_hovered
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, color_max.Y + 4)
    
    return color, changed
end

-- Table API (simplified)
function ImGui.BeginTable(id, columns_count, flags, outer_size, inner_width)
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    
    _context.current_table = {
        id = id,
        columns_count = columns_count,
        current_column = 0,
        current_row = 0,
        position = window.cursor_pos,
        row_started = false
    }
    
    return true
end

function ImGui.EndTable()
    if not _context.current_table then
        return
    end
    
    _context.current_table = nil
end

function ImGui.TableNextRow(row_flags, min_row_height)
    if not _context.current_table then
        return
    end
    
    local table = _context.current_table
    table.current_row = table.current_row + 1
    table.current_column = 0
    table.row_started = true
    
    -- Advance cursor for new row
    if _context.current_window then
        _context.current_window.cursor_pos = Vector2.new(
            table.position.X,
            _context.current_window.cursor_pos.Y + 25
        )
    end
end

function ImGui.TableNextColumn()
    if not _context.current_table or not _context.current_table.row_started then
        return false
    end
    
    local table = _context.current_table
    table.current_column = table.current_column + 1
    
    if table.current_column > table.columns_count then
        return false
    end
    
    -- Calculate column position
    if _context.current_window then
        local column_width = 100  -- Simplified
        _context.current_window.cursor_pos = Vector2.new(
            table.position.X + (table.current_column - 1) * column_width,
            _context.current_window.cursor_pos.Y
        )
    end
    
    return true
end

function ImGui.TableHeadersRow()
    if not _context.current_table then
        return
    end
    
    local table = _context.current_table
    local original_pos = _context.current_window.cursor_pos
    
    for i = 1, table.columns_count do
        ImGui.TableNextColumn()
        ImGui.Text("Column " .. i)
    end
    
    ImGui.TableNextRow()
end

function ImGui.TableSetupColumn(label, flags, init_width_or_weight, user_id)
    -- In a full implementation, this would configure column properties
end

-- Menu API
function ImGui.BeginMenuBar()
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    
    _context.current_menu_bar = {
        position = Vector2.new(window.position.X + 8, window.position.Y + 20),
        width = window.size.X - 16
    }
    
    window.cursor_pos = Vector2.new(
        _context.current_menu_bar.position.X,
        _context.current_menu_bar.position.Y + 25
    )
    
    return true
end

function ImGui.EndMenuBar()
    _context.current_menu_bar = nil
end

function ImGui.BeginMenu(label, enabled)
    enabled = enabled or true
    
    if not _context.current_menu_bar then
        return false
    end
    
    local menu_bar = _context.current_menu_bar
    local text_size = CalculateTextSize(label)
    local menu_width = text_size.X + 20
    
    local menu_min = menu_bar.position
    local menu_max = menu_min + Vector2.new(menu_width, 25)
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(menu_min, menu_max)
    
    -- Draw menu item
    table.insert(_context.draw_calls, {
        type = "menu",
        id = id,
        label = label,
        position = menu_min,
        size = Vector2.new(menu_width, 25),
        hovered = is_hovered
    })
    
    -- Update menu bar position for next item
    menu_bar.position = Vector2.new(menu_bar.position.X + menu_width, menu_bar.position.Y)
    
    return is_hovered and enabled
end

function ImGui.EndMenu()
    -- Menu end marker
end

function ImGui.MenuItem(label, shortcut, selected, enabled)
    enabled = enabled or true
    selected = selected or false
    
    if not _context.current_window then
        return false
    end
    
    local window = _context.current_window
    local height = 25
    
    local item_min = window.cursor_pos
    local item_max = item_min + Vector2.new(200, height)
    
    local id = GetID(label)
    local is_hovered = IsMouseHoveringRect(item_min, item_max)
    local clicked = false
    
    if is_hovered and enabled and _context.mouse_down[1] then
        clicked = true
    end
    
    -- Draw menu item
    table.insert(_context.draw_calls, {
        type = "menu_item",
        id = id,
        label = label,
        shortcut = shortcut,
        position = item_min,
        size = Vector2.new(200, height),
        selected = selected,
        hovered = is_hovered,
        enabled = enabled
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, item_max.Y)
    
    return clicked
end

-- Plotting Functions
function ImGui.PlotLines(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    graph_size = graph_size or Vector2.new(200, 80)
    
    -- Draw plot
    table.insert(_context.draw_calls, {
        type = "plot_lines",
        label = label,
        values = values,
        values_count = values_count,
        position = window.cursor_pos,
        size = graph_size,
        overlay_text = overlay_text,
        scale_min = scale_min,
        scale_max = scale_max
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + graph_size.Y + 4)
end

function ImGui.PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size)
    if not _context.current_window then
        return
    end
    
    local window = _context.current_window
    graph_size = graph_size or Vector2.new(200, 80)
    
    -- Draw histogram
    table.insert(_context.draw_calls, {
        type = "plot_histogram",
        label = label,
        values = values,
        values_count = values_count,
        position = window.cursor_pos,
        size = graph_size,
        overlay_text = overlay_text,
        scale_min = scale_min,
        scale_max = scale_max
    })
    
    -- Advance cursor
    window.cursor_pos = Vector2.new(window.cursor_start_pos.X, window.cursor_pos.Y + graph_size.Y + 4)
end

-- Utility Functions
function ImGui.GetIO()
    return ImGui.IO
end

function ImGui.GetStyle()
    return ImGui.Style
end

function ImGui.GetFrameCount()
    return _context.frame_count
end

function ImGui.GetTime()
    return _context.time
end

function ImGui.GetDrawData()
    return {
        draw_calls = _context.draw_calls,
        display_size = ImGui.IO.DisplaySize,
        frame_count = _context.frame_count
    }
end

-- Setup and Shutdown
function ImGui.CreateContext()
    -- Already created in initialization
    return ImGui
end

function ImGui.DestroyContext()
    _context = {
        current_window = nil,
        windows = {},
        next_window_id = 1,
        next_widget_id = 1,
        style = ImGui.Style,
        io = ImGui.IO,
        draw_calls = {},
        hot_item = nil,
        active_item = nil,
        hovered_item = nil,
        mouse_pos = Vector2.new(0, 0),
        mouse_down = {false, false, false},
        keys_down = {},
        frame_count = 0,
        time = 0,
        delta_time = 0
    }
end

-- Main Loop Integration Example
function ImGui.RunExample()
    -- Create screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create renderer
    local renderer = ImGui.CreateRenderer(screenGui)
    
    -- Main render loop
    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        -- Start new frame
        ImGui.NewFrame()
        
        -- Show demo window
        ImGui.ShowDemoWindow(true)
        
        -- Custom window example
        if ImGui.Begin("Custom Window") then
            ImGui.Text("Hello from ImGui-Lua!")
            
            -- Example of using different widgets
            if ImGui.Button("Test Button") then
                print("Test button clicked!")
            end
            
            local slider_val = 0.5
            slider_val = ImGui.SliderFloat("Test Slider", slider_val, 0, 1)
            
            local checkbox_state = true
            checkbox_state = ImGui.Checkbox("Enable Feature", checkbox_state)
            
            ImGui.End()
        end
        
        -- Render everything
        local draw_calls = ImGui.Render()
        renderer:Render(draw_calls)
    end)
    
    -- Return cleanup function
    return function()
        connection:Disconnect()
        renderer:Destroy()
        ImGui.DestroyContext()
    end
end

-- Export the library
return ImGui
