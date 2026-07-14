--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           C O S T U D I O   A I   v2.0                  ║
    ║     Premium AI Assistant • Luxury Edition                ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Cleanup previous instances
local existing = PlayerGui:FindFirstChild("CostudioAI")
if existing then existing:Destroy() end

-- ═══════════════════════════════════════════════
--  THEME CONFIGURATION
-- ═══════════════════════════════════════════════
local Theme = {
    -- Base Colors
    BG_Darkest    = Color3.fromRGB(8, 8, 14),
    BG_Dark       = Color3.fromRGB(14, 14, 22),
    BG_Card       = Color3.fromRGB(20, 20, 32),
    BG_Input      = Color3.fromRGB(16, 16, 28),
    BG_Hover      = Color3.fromRGB(28, 28, 44),

    -- Accent (Gold)
    Accent        = Color3.fromRGB(212, 175, 85),
    Accent_Light  = Color3.fromRGB(235, 205, 120),
    Accent_Dim    = Color3.fromRGB(140, 115, 55),
    Accent_Glow   = Color3.fromRGB(212, 175, 85),

    -- Text
    Text_Primary  = Color3.fromRGB(240, 240, 245),
    Text_Secondary= Color3.fromRGB(160, 160, 180),
    Text_Muted    = Color3.fromRGB(90, 90, 110),
    Text_Accent   = Color3.fromRGB(212, 175, 85),

    -- Semantic
    Success       = Color3.fromRGB(80, 200, 120),
    Danger        = Color3.fromRGB(220, 70, 70),
    Danger_Hover  = Color3.fromRGB(250, 90, 90),

    -- Borders
    Border        = Color3.fromRGB(40, 40, 58),
    Border_Light  = Color3.fromRGB(55, 55, 75),

    -- Glass
    Glass_BG      = Color3.fromRGB(18, 18, 30),
    Glass_Border  = Color3.fromRGB(50, 50, 70),

    -- AI Bubble
    AI_BG         = Color3.fromRGB(22, 22, 38),
    User_BG       = Color3.fromRGB(35, 30, 18),

    -- Fonts
    Font_Title    = Enum.Font.GothamBold,
    Font_Heading  = Enum.Font.GothamMedium,
    Font_Body     = Enum.Font.Gotham,
    Font_Input    = Enum.Font.Gotham,
    Font_Icon     = Enum.Font.GothamBold,
}

-- ═══════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════
local function MakeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim2.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function MakeStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function MakePadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim2.new(0, top or 0)
    pad.PaddingBottom = UDim2.new(0, bottom or 0)
    pad.PaddingLeft = UDim2.new(0, left or 0)
    pad.PaddingRight = UDim2.new(0, right or 0)
    pad.Parent = parent
    return pad
end

local function MakeGradient(parent, color1, color2, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(color1, color2)
    grad.Rotation = rotation or 90
    grad.Parent = parent
    return grad
end

local function SmoothTween(obj, props, duration, style)
    return TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

local function RippleEffect(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Theme.Accent
    ripple.BackgroundTransparency = 0.6
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 100
    MakeCorner(ripple, 300)
    ripple.Parent = button

    local grow = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 400),
        BackgroundTransparency = 1
    })
    grow:Play()
    grow.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function TypewriterEffect(label, text, speed)
    speed = speed or 0.02
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        task.wait(speed)
    end
end

-- ═══════════════════════════════════════════════
--  SESSION DATA
-- ═══════════════════════════════════════════════
local Sessions = {}
local ActiveSession = nil

local function CreateSession()
    local id = tostring(HttpService:GenerateGUID(false))
    local session = {
        Id = id,
        Title = "New Chat",
        Messages = {},
        CreatedAt = os.time()
    }
    table.insert(Sessions, session)
    ActiveSession = session
    return session
end

local function DeleteSession(id)
    for i, s in ipairs(Sessions) do
        if s.Id == id then
            table.remove(Sessions, i)
            if ActiveSession and ActiveSession.Id == id then
                ActiveSession = #Sessions > 0 and Sessions[#Sessions] or CreateSession()
            end
            break
        end
    end
end

-- ═══════════════════════════════════════════════
--  AI RESPONSE (Simulated)
-- ═══════════════════════════════════════════════
local AIResponses = {
    "That's a great question! Let me think about that for you. Based on my analysis, I'd recommend exploring multiple approaches to find the best solution for your specific use case.",
    "I understand what you're looking for. Here's my take — the key is to balance performance with readability. Sometimes the simplest solution is the most elegant one.",
    "Interesting point! In my experience, the best results come from iterating on your ideas. Start with a solid foundation and refine from there.",
    "Let me break this down for you step by step. First, we need to understand the core problem, then we can architect a solution that scales well.",
    "Great question! The answer depends on your context, but here are some general principles I'd suggest following for optimal results.",
    "I've analyzed your request carefully. The most effective approach would be to combine different techniques while keeping your codebase clean and maintainable.",
    "That's something I see a lot of people wonder about. The short answer is: it depends. But here's a framework for thinking about it more clearly.",
    "Absolutely! Here's what I'd suggest — focus on the fundamentals first, then layer in complexity as needed. Don't over-engineer early on.",
}

local function GetAIResponse(prompt)
    -- Simulate thinking delay
    task.wait(0.8 + math.random() * 1.2)
    return AIResponses[math.random(1, #AIResponses)]
end

-- ═══════════════════════════════════════════════
--  BUILD GUI
-- ═══════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CostudioAI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Main Container
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 820, 0, 560)
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.BackgroundColor3 = Theme.BG_Darkest
MainContainer.BorderSizePixel = 0
MainContainer.ClipsDescendants = true
MakeCorner(MainContainer, 16)
MakeStroke(MainContainer, Theme.Border, 1)
MakePadding(MainContainer, 0, 0, 0, 0)
MainContainer.Parent = ScreenGui

-- Shadow Frame
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 50, 1, 50)
Shadow.Position = UDim2.new(0, -25, 0, -25)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = -1
Shadow.Parent = MainContainer

-- ═══════════════════════════════════════════════
--  SIDEBAR
-- ═══════════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.BackgroundColor3 = Theme.BG_Dark
Sidebar.BorderSizePixel = 0
MakeCorner(Sidebar, 0)
MakeStroke(Sidebar, Theme.Border, 1)
Sidebar.Parent = MainContainer

-- Sidebar Header
local SidebarHeader = Instance.new("Frame")
SidebarHeader.Name = "Header"
SidebarHeader.Size = UDim2.new(1, 0, 0, 72)
SidebarHeader.BackgroundTransparency = 1
SidebarHeader.Parent = Sidebar

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Name = "LogoIcon"
LogoIcon.Size = UDim2.new(0, 32, 0, 32)
LogoIcon.Position = UDim2.new(0, 20, 0, 14)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "◆"
LogoIcon.TextColor3 = Theme.Accent
LogoIcon.Font = Theme.Font_Icon
LogoIcon.TextSize = 22
LogoIcon.Parent = SidebarHeader

local LogoText = Instance.new("TextLabel")
LogoText.Name = "LogoText"
LogoText.Size = UDim2.new(0, 120, 0, 20)
LogoText.Position = UDim2.new(0, 58, 0, 18)
LogoText.BackgroundTransparency = 1
LogoText.Text = "COSTUDIO AI"
LogoText.TextColor3 = Theme.Text_Primary
LogoText.Font = Theme.Font_Title
LogoText.TextSize = 16
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = SidebarHeader

local LogoSubtext = Instance.new("TextLabel")
LogoSubtext.Size = UDim2.new(0, 120, 0, 14)
LogoSubtext.Position = UDim2.new(0, 58, 0, 40)
LogoSubtext.BackgroundTransparency = 1
LogoSubtext.Text = "Premium Edition"
LogoSubtext.TextColor3 = Theme.Text_Muted
LogoSubtext.Font = Theme.Font_Body
LogoSubtext.TextSize = 10
LogoSubtext.TextXAlignment = Enum.TextXAlignment.Left
LogoSubtext.Parent = SidebarHeader

-- Gold accent line
local AccentLine = Instance.new("Frame")
AccentLine.Name = "AccentLine"
AccentLine.Size = UDim2.new(1, -40, 0, 1)
AccentLine.Position = UDim2.new(0, 20, 1, 0)
AccentLine.BackgroundColor3 = Theme.Accent
AccentLine.BackgroundTransparency = 0.4
AccentLine.BorderSizePixel = 0
AccentLine.Parent = SidebarHeader

-- New Chat Button
local NewChatBtn = Instance.new("TextButton")
NewChatBtn.Name = "NewChatBtn"
NewChatBtn.Size = UDim2.new(1, -32, 0, 42)
NewChatBtn.Position = UDim2.new(0, 16, 0, 80)
NewChatBtn.BackgroundColor3 = Theme.Accent
NewChatBtn.BorderSizePixel = 0
NewChatBtn.Text = "  ＋  New Chat"
NewChatBtn.TextColor3 = Theme.BG_Darkest
NewChatBtn.Font = Theme.Font_Heading
NewChatBtn.TextSize = 13
NewChatBtn.TextXAlignment = Enum.TextXAlignment.Center
MakeCorner(NewChatBtn, 10)
NewChatBtn.Parent = Sidebar

local NewChatGradient = MakeGradient(NewChatBtn, Theme.Accent, Theme.Accent_Light, 90)

NewChatBtn.MouseButton1Click:Connect(function()
    CreateSession()
    RefreshSessionList()
    RefreshChatArea()
end)

NewChatBtn.MouseEnter:Connect(function()
    SmoothTween(NewChatBtn, {BackgroundTransparency = 0, Size = UDim2.new(1, -28, 0, 44), Position = UDim2.new(0, 14, 0, 79)}, 0.2)
end)

NewChatBtn.MouseLeave:Connect(function()
    SmoothTween(NewChatBtn, {Size = UDim2.new(1, -32, 0, 42), Position = UDim2.new(0, 16, 0, 80)}, 0.2)
end)

-- Session List
local SessionScrollFrame = Instance.new("ScrollingFrame")
SessionScrollFrame.Name = "SessionList"
SessionScrollFrame.Size = UDim2.new(1, -16, 1, -200)
SessionScrollFrame.Position = UDim2.new(0, 8, 0, 132)
SessionScrollFrame.BackgroundTransparency = 1
SessionScrollFrame.BorderSizePixel = 0
SessionScrollFrame.ScrollBarThickness = 3
SessionScrollFrame.ScrollBarImageColor3 = Theme.Accent_Dim
SessionScrollFrame.ScrollBarImageTransparency = 0.5
SessionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
SessionScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SessionScrollFrame.Parent = Sidebar

local SessionLayout = Instance.new("UIListLayout")
SessionLayout.SortOrder = Enum.SortOrder.LayoutOrder
SessionLayout.Padding = UDim2.new(0, 4)
SessionLayout.Parent = SessionScrollFrame

-- Sidebar Footer
local SidebarFooter = Instance.new("Frame")
SidebarFooter.Name = "Footer"
SidebarFooter.Size = UDim2.new(1, 0, 0, 48)
SidebarFooter.Position = UDim2.new(0, 0, 1, -48)
SidebarFooter.BackgroundColor3 = Theme.BG_Dark
SidebarFooter.BorderSizePixel = 0
SidebarFooter.Parent = Sidebar

local FooterLine = Instance.new("Frame")
FooterLine.Size = UDim2.new(1, -40, 0, 1)
FooterLine.Position = UDim2.new(0, 20, 0, 0)
FooterLine.BackgroundColor3 = Theme.Border
FooterLine.BorderSizePixel = 0
FooterLine.Parent = SidebarFooter

local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Size = UDim2.new(0, 28, 0, 28)
UserAvatar.Position = UDim2.new(0, 16, 0, 10)
UserAvatar.BackgroundColor3 = Theme.BG_Card
UserAvatar.BorderSizePixel = 0
MakeCorner(UserAvatar, 14)
MakeStroke(UserAvatar, Theme.Border, 1)
UserAvatar.Parent = SidebarFooter

-- Try to load player avatar
pcall(function()
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    UserAvatar.Image = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)
end)

local UserName = Instance.new("TextLabel")
UserName.Size = UDim2.new(0, 100, 0, 16)
UserName.Position = UDim2.new(0, 52, 0, 11)
UserName.BackgroundTransparency = 1
UserName.Text = Player.DisplayName
UserName.TextColor3 = Theme.Text_Primary
UserName.Font = Theme.Font_Heading
UserName.TextSize = 12
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Parent = SidebarFooter

local UserTag = Instance.new("TextLabel")
UserTag.Size = UDim2.new(0, 100, 0, 12)
UserTag.Position = UDim2.new(0, 52, 0, 28)
UserTag.BackgroundTransparency = 1
UserTag.Text = "Premium User"
UserTag.TextColor3 = Theme.Accent_Dim
UserTag.Font = Theme.Font_Body
UserTag.TextSize = 9
UserTag.TextXAlignment = Enum.TextXAlignment.Left
UserTag.Parent = SidebarFooter

-- ═══════════════════════════════════════════════
--  CHAT AREA
-- ═══════════════════════════════════════════════
local ChatArea = Instance.new("Frame")
ChatArea.Name = "ChatArea"
ChatArea.Size = UDim2.new(1, -240, 1, 0)
ChatArea.Position = UDim2.new(0, 240, 0, 0)
ChatArea.BackgroundTransparency = 1
ChatArea.BorderSizePixel = 0
ChatArea.Parent = MainContainer

-- Chat Header
local ChatHeader = Instance.new("Frame")
ChatHeader.Name = "ChatHeader"
ChatHeader.Size = UDim2.new(1, 0, 0, 58)
ChatHeader.BackgroundColor3 = Theme.BG_Dark
ChatHeader.BorderSizePixel = 0
ChatHeader.Parent = ChatArea

local ChatHeaderAccent = Instance.new("Frame")
ChatHeaderAccent.Size = UDim2.new(1, 0, 0, 1)
ChatHeaderAccent.Position = UDim2.new(0, 0, 1, -1)
ChatHeaderAccent.BackgroundColor3 = Theme.Border
ChatHeaderAccent.BorderSizePixel = 0
ChatHeaderAccent.Parent = ChatHeader

local ChatTitle = Instance.new("TextLabel")
ChatTitle.Name = "Title"
ChatTitle.Size = UDim2.new(0, 200, 0, 20)
ChatTitle.Position = UDim2.new(0, 24, 0, 14)
ChatTitle.BackgroundTransparency = 1
ChatTitle.Text = "Costudio AI"
ChatTitle.TextColor3 = Theme.Text_Primary
ChatTitle.Font = Theme.Font_Title
ChatTitle.TextSize = 16
ChatTitle.TextXAlignment = Enum.TextXAlignment.Left
ChatTitle.Parent = ChatHeader

local ChatSubtitle = Instance.new("TextLabel")
ChatSubtitle.Size = UDim2.new(0, 200, 0, 14)
ChatSubtitle.Position = UDim2.new(0, 24, 0, 34)
ChatSubtitle.BackgroundTransparency = 1
ChatSubtitle.Text = "Always online • Ready to assist"
ChatSubtitle.TextColor3 = Theme.Text_Muted
ChatSubtitle.Font = Theme.Font_Body
ChatSubtitle.TextSize = 10
ChatSubtitle.TextXAlignment = Enum.TextXAlignment.Left
ChatSubtitle.Parent = ChatHeader

-- Online indicator dot
local OnlineDot = Instance.new("Frame")
OnlineDot.Size = UDim2.new(0, 7, 0, 7)
OnlineDot.Position = UDim2.new(0, 228, 0, 37)
OnlineDot.BackgroundColor3 = Theme.Success
OnlineDot.BorderSizePixel = 0
MakeCorner(OnlineDot, 4)
OnlineDot.Parent = ChatHeader

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 13)
MinimizeBtn.BackgroundColor3 = Theme.BG_Card
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.Text_Secondary
MinimizeBtn.Font = Theme.Font_Heading
MinimizeBtn.TextSize = 14
MakeCorner(MinimizeBtn, 8)
MakeStroke(MinimizeBtn, Theme.Border, 1)
MinimizeBtn.Parent = ChatHeader

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -84, 0, 13)
CloseBtn.BackgroundColor3 = Theme.BG_Card
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text_Secondary
CloseBtn.Font = Theme.Font_Heading
CloseBtn.TextSize = 13
MakeCorner(CloseBtn, 8)
MakeStroke(CloseBtn, Theme.Border, 1)
CloseBtn.Parent = ChatHeader

-- Messages ScrollFrame
local MessagesFrame = Instance.new("ScrollingFrame")
MessagesFrame.Name = "Messages"
MessagesFrame.Size = UDim2.new(1, -48, 1, -152)
MessagesFrame.Position = UDim2.new(0, 24, 0, 66)
MessagesFrame.BackgroundTransparency = 1
MessagesFrame.BorderSizePixel = 0
MessagesFrame.ScrollBarThickness = 3
MessagesFrame.ScrollBarImageColor3 = Theme.Accent_Dim
MessagesFrame.ScrollBarImageTransparency = 0.6
MessagesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MessagesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
MessagesFrame.Parent = ChatArea

local MessagesLayout = Instance.new("UIListLayout")
MessagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
MessagesLayout.Padding = UDim2.new(0, 10)
MessagesLayout.Parent = MessagesFrame

-- ═══════════════════════════════════════════════
--  WELCOME SCREEN
-- ═══════════════════════════════════════════════
local WelcomeFrame = Instance.new("Frame")
WelcomeFrame.Name = "Welcome"
WelcomeFrame.Size = UDim2.new(1, -48, 1, -152)
WelcomeFrame.Position = UDim2.new(0, 24, 0, 66)
WelcomeFrame.BackgroundTransparency = 1
WelcomeFrame.Visible = true
WelcomeFrame.Parent = ChatArea

local WelcomeInner = Instance.new("Frame")
WelcomeInner.Size = UDim2.new(0, 400, 0, 280)
WelcomeInner.Position = UDim2.new(0.5, 0, 0.5, 0)
WelcomeInner.AnchorPoint = Vector2.new(0.5, 0.5)
WelcomeInner.BackgroundTransparency = 1
WelcomeInner.Parent = WelcomeFrame

local WelcomeIcon = Instance.new("TextLabel")
WelcomeIcon.Size = UDim2.new(0, 60, 0, 60)
WelcomeIcon.Position = UDim2.new(0.5, 0, 0, 0)
WelcomeIcon.AnchorPoint = Vector2.new(0.5, 0)
WelcomeIcon.BackgroundTransparency = 1
WelcomeIcon.Text = "◆"
WelcomeIcon.TextColor3 = Theme.Accent
WelcomeIcon.Font = Theme.Font_Icon
WelcomeIcon.TextSize = 48
WelcomeIcon.Parent = WelcomeInner

local WelcomeTitle = Instance.new("TextLabel")
WelcomeTitle.Size = UDim2.new(0, 400, 0, 30)
WelcomeTitle.Position = UDim2.new(0, 0, 0, 72)
WelcomeTitle.BackgroundTransparency = 1
WelcomeTitle.Text = "Welcome to Costudio AI"
WelcomeTitle.TextColor3 = Theme.Text_Primary
WelcomeTitle.Font = Theme.Font_Title
WelcomeTitle.TextSize = 22
WelcomeTitle.Parent = WelcomeInner

local WelcomeDesc = Instance.new("TextLabel")
WelcomeDesc.Size = UDim2.new(0, 400, 0, 40)
WelcomeDesc.Position = UDim2.new(0, 0, 0, 106)
WelcomeDesc.BackgroundTransparency = 1
WelcomeDesc.Text = "Your premium AI assistant. Ask me anything —\nfrom scripting help to creative ideas."
WelcomeDesc.TextColor3 = Theme.Text_Secondary
WelcomeDesc.Font = Theme.Font_Body
WelcomeDesc.TextSize = 13
WelcomeDesc.Parent = WelcomeInner

-- Suggestion chips
local SuggestionsFrame = Instance.new("Frame")
SuggestionsFrame.Size = UDim2.new(0, 400, 0, 90)
SuggestionsFrame.Position = UDim2.new(0, 0, 0, 165)
SuggestionsFrame.BackgroundTransparency = 1
SuggestionsFrame.Parent = WelcomeInner

local SuggestionsLayout = Instance.new("UIListLayout")
SuggestionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SuggestionsLayout.Padding = UDim2.new(0, 8)
SuggestionsLayout.FillDirection = Enum.FillDirection.Horizontal
SuggestionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SuggestionsLayout.Parent = SuggestionsFrame

local Suggestions = {"Help me script", "Give me ideas", "Explain a concept", "Debug my code"}

for i, text in ipairs(Suggestions) do
    local chip = Instance.new("TextButton")
    chip.Name = "Chip" .. i
    chip.Size = UDim2.new(0, 0, 0, 34)
    chip.AutomaticSize = Enum.AutomaticSize.X
    chip.BackgroundColor3 = Theme.BG_Card
    chip.BorderSizePixel = 0
    chip.Text = "  " .. text .. "  "
    chip.TextColor3 = Theme.Text_Secondary
    chip.Font = Theme.Font_Body
    chip.TextSize = 12
    MakeCorner(chip, 17)
    MakeStroke(chip, Theme.Border, 1)
    chip.Parent = SuggestionsFrame

    chip.MouseEnter:Connect(function()
        SmoothTween(chip, {BackgroundColor3 = Theme.BG_Hover, TextColor3 = Theme.Accent}, 0.15)
    end)
    chip.MouseLeave:Connect(function()
        SmoothTween(chip, {BackgroundColor3 = Theme.BG_Card, TextColor3 = Theme.Text_Secondary}, 0.15)
    end)

    chip.MouseButton1Click:Connect(function()
        PromptInput.Text = text
        PromptInput:CaptureFocus()
    end)
end

-- ═══════════════════════════════════════════════
--  INPUT AREA
-- ═══════════════════════════════════════════════
local InputArea = Instance.new("Frame")
InputArea.Name = "InputArea"
InputArea.Size = UDim2.new(1, -48, 0, 72)
InputArea.Position = UDim2.new(0, 24, 1, -80)
InputArea.BackgroundColor3 = Theme.BG_Input
InputArea.BorderSizePixel = 0
MakeCorner(InputArea, 14)
MakeStroke(InputArea, Theme.Border, 1)
InputArea.Parent = ChatArea

local PromptInput = Instance.new("TextBox")
PromptInput.Name = "PromptInput"
PromptInput.Size = UDim2.new(1, -80, 1, -20)
PromptInput.Position = UDim2.new(0, 20, 0, 10)
PromptInput.BackgroundTransparency = 1
PromptInput.Text = ""
PromptInput.PlaceholderText = "Ask Costudio AI anything..."
PromptInput.PlaceholderColor3 = Theme.Text_Muted
PromptInput.TextColor3 = Theme.Text_Primary
PromptInput.Font = Theme.Font_Input
PromptInput.TextSize = 14
PromptInput.TextXAlignment = Enum.TextXAlignment.Left
PromptInput.TextYAlignment = Enum.TextYAlignment.Center
PromptInput.ClearTextOnFocus = false
PromptInput.MultiLine = true
PromptInput.TextWrapped = true
PromptInput.Parent = InputArea

-- Send Button
local SendBtn = Instance.new("TextButton")
SendBtn.Name = "SendBtn"
SendBtn.Size = UDim2.new(0, 40, 0, 40)
SendBtn.Position = UDim2.new(1, -52, 0, 16)
SendBtn.BackgroundColor3 = Theme.Accent
SendBtn.BorderSizePixel = 0
SendBtn.Text = "↑"
SendBtn.TextColor3 = Theme.BG_Darkest
SendBtn.Font = Theme.Font_Title
SendBtn.TextSize = 18
MakeCorner(SendBtn, 12)
SendBtn.Parent = InputArea

SendBtn.MouseEnter:Connect(function()
    SmoothTween(SendBtn, {BackgroundColor3 = Theme.Accent_Light, Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(1, -54, 0, 14)}, 0.15)
end)
SendBtn.MouseLeave:Connect(function()
    SmoothTween(SendBtn, {BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -52, 0, 16)}, 0.15)
end)

-- ═══════════════════════════════════════════════
--  DRAG FUNCTIONALITY
-- ═══════════════════════════════════════════════
local dragging = false
local dragStart, startPos

ChatHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ═══════════════════════════════════════════════
local isMinimized = false
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(0.5, 0, 1, -70)
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0)
ToggleBtn.BackgroundColor3 = Theme.Accent
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "◆"
ToggleBtn.TextColor3 = Theme.BG_Darkest
ToggleBtn.Font = Theme.Font_Icon
ToggleBtn.TextSize = 20
MakeCorner(ToggleBtn, 26)
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleShadow = Instance.new("ImageLabel")
ToggleShadow.Size = UDim2.new(1, 24, 1, 24)
ToggleShadow.Position = UDim2.new(0, -12, 0, -12)
ToggleShadow.BackgroundTransparency = 1
ToggleShadow.Image = "rbxassetid://6015897843"
ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
ToggleShadow.ImageTransparency = 0.5
ToggleShadow.ScaleType = Enum.ScaleType.Slice
ToggleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
ToggleShadow.ZIndex = -1
ToggleShadow.Parent = ToggleBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    SmoothTween(MainContainer, {Size = UDim2.new(0, 820, 0, 0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back):Play()
    task.delay(0.35, function()
        MainContainer.Visible = false
        ToggleBtn.Visible = true
        SmoothTween(ToggleBtn, {Size = UDim2.new(0, 52, 0, 52)}, 0.3):Play()
    end)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = false
    SmoothTween(ToggleBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
    task.delay(0.2, function()
        ToggleBtn.Visible = false
        MainContainer.Visible = true
        MainContainer.Size = UDim2.new(0, 820, 0, 0)
        SmoothTween(MainContainer, {Size = UDim2.new(0, 820, 0, 560), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back):Play()
    end)
end)

CloseBtn.MouseButton1Click:Connect(function()
    SmoothTween(MainContainer, {Size = UDim2.new(0, 820, 0, 0), BackgroundTransparency = 1}, 0.3):Play()
    SmoothTween(Shadow, {ImageTransparency = 1}, 0.3):Play()
    task.delay(0.4, function()
        ScreenGui:Destroy()
    end)
end)

-- ═══════════════════════════════════════════════
--  MESSAGE BUBBLE CREATION
-- ═══════════════════════════════════════════════
local function CreateUserBubble(text)
    local bubble = Instance.new("Frame")
    bubble.Name = "UserMessage"
    bubble.Size = UDim2.new(1, 0, 0, 0)
    bubble.AutomaticSize = Enum.AutomaticSize.Y
    bubble.BackgroundTransparency = 1
    bubble.LayoutOrder = #MessagesFrame:GetChildren() + 1

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(0.75, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Position = UDim2.new(0.25, 0, 0, 0)
    content.AnchorPoint = Vector2.new(0, 0)
    content.BackgroundColor3 = Theme.User_BG
    content.BorderSizePixel = 0
    MakeCorner(content, 12)
    MakeStroke(content, Theme.Accent_Dim, 0.5)
    MakePadding(content, 10, 10, 16, 16)
    content.Parent = bubble

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text_Primary
    label.Font = Theme.Font_Body
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local senderLabel = Instance.new("TextLabel")
    senderLabel.Size = UDim2.new(0, 60, 0, 14)
    senderLabel.Position = UDim2.new(1, -4, 0, -18)
    senderLabel.AnchorPoint = Vector2.new(1, 0)
    senderLabel.BackgroundTransparency = 1
    senderLabel.Text = "You"
    senderLabel.TextColor3 = Theme.Accent_Dim
    senderLabel.Font = Theme.Font_Body
    senderLabel.TextSize = 9
    senderLabel.TextXAlignment = Enum.TextXAlignment.Right
    senderLabel.Parent = content

    bubble.Parent = MessagesFrame

    -- Animate in
    bubble.Position = UDim2.new(0.15, 0, 0, 0)
    SmoothTween(bubble, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)

    return bubble
end

local function CreateAIBubble(text)
    local bubble = Instance.new("Frame")
    bubble.Name = "AIMessage"
    bubble.Size = UDim2.new(1, 0, 0, 0)
    bubble.AutomaticSize = Enum.AutomaticSize.Y
    bubble.BackgroundTransparency = 1
    bubble.LayoutOrder = #MessagesFrame:GetChildren() + 1

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(0.75, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundColor3 = Theme.AI_BG
    content.BorderSizePixel = 0
    MakeCorner(content, 12)
    MakeStroke(content, Theme.Border, 0.5)
    MakePadding(content, 10, 10, 16, 16)
    content.Parent = bubble

    local aiIconFrame = Instance.new("Frame")
    aiIconFrame.Size = UDim2.new(0, 22, 0, 22)
    aiIconFrame.Position = UDim2.new(0, 14, 0, 12)
    aiIconFrame.BackgroundColor3 = Theme.Accent
    aiIconFrame.BorderSizePixel = 0
    MakeCorner(aiIconFrame, 6)
    aiIconFrame.Parent = bubble

    local aiIconText = Instance.new("TextLabel")
    aiIconText.Size = UDim2.new(1, 0, 1, 0)
    aiIconText.BackgroundTransparency = 1
    aiIconText.Text = "◆"
    aiIconText.TextColor3 = Theme.BG_Darkest
    aiIconText.Font = Theme.Font_Icon
    aiIconText.TextSize = 11
    aiIconText.Parent = aiIconFrame

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingLeft = UDim2.new(0, 38)
    contentPad.Parent = bubble

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(1, -38, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text_Primary
    label.Font = Theme.Font_Body
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bubble

    local senderLabel = Instance.new("TextLabel")
    senderLabel.Size = UDim2.new(0, 70, 0, 14)
    senderLabel.Position = UDim2.new(0, 52, 0, 6)
    senderLabel.AnchorPoint = Vector2.new(0, 0)
    senderLabel.BackgroundTransparency = 1
    senderLabel.Text = "Costudio AI"
    senderLabel.TextColor3 = Theme.Accent
    senderLabel.Font = Theme.Font_Heading
    senderLabel.TextSize = 10
    senderLabel.TextXAlignment = Enum.TextXAlignment.Left
    senderLabel.Parent = bubble

    bubble.Parent = MessagesFrame

    -- Animate in
    bubble.Position = UDim2.new(-0.15, 0, 0, 0)
    SmoothTween(bubble, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)

    return bubble, label
end

-- ═══════════════════════════════════════════════
--  SESSION LIST REFRESH
-- ═══════════════════════════════════════════════
function RefreshSessionList()
    for _, child in ipairs(SessionScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for i, session in ipairs(Sessions) do
        local item = Instance.new("Frame")
        item.Name = "Session_" .. session.Id
        item.Size = UDim2.new(1, -8, 0, 46)
        item.BackgroundColor3 = (ActiveSession and ActiveSession.Id == session.Id) and Theme.BG_Card or Theme.BG_Dark
        item.BorderSizePixel = 0
        MakeCorner(item, 10)
        item.LayoutOrder = i

        if ActiveSession and ActiveSession.Id == session.Id then
            MakeStroke(item, Theme.Accent_Dim, 1)
        else
            MakeStroke(item, Color3.fromRGB(0,0,0), 0)
        end

        item.Parent = SessionScrollFrame

        -- Session icon
        local sessionIcon = Instance.new("TextLabel")
        sessionIcon.Size = UDim2.new(0, 18, 0, 18)
        sessionIcon.Position = UDim2.new(0, 12, 0.5, 0)
        sessionIcon.AnchorPoint = Vector2.new(0, 0.5)
        sessionIcon.BackgroundTransparency = 1
        sessionIcon.Text = "◈"
        sessionIcon.TextColor3 = (ActiveSession and ActiveSession.Id == session.Id) and Theme.Accent or Theme.Text_Muted
        sessionIcon.Font = Theme.Font_Icon
        sessionIcon.TextSize = 14
        sessionIcon.Parent = item

        -- Session title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -70, 0, 16)
        titleLabel.Position = UDim2.new(0, 36, 0, 10)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = session.Title
        titleLabel.TextColor3 = (ActiveSession and ActiveSession.Id == session.Id) and Theme.Text_Primary or Theme.Text_Secondary
        titleLabel.Font = Theme.Font_Heading
        titleLabel.TextSize = 12
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.Parent = item

        -- Time label
        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(1, -70, 0, 12)
        timeLabel.Position = UDim2.new(0, 36, 0, 27)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = os.date("%I:%M %p", session.CreatedAt)
        timeLabel.TextColor3 = Theme.Text_Muted
        timeLabel.Font = Theme.Font_Body
        timeLabel.TextSize = 9
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left
        timeLabel.Parent = item

        -- Delete button (FIXED: proper sizing, positioning, and click handling)
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Name = "DeleteBtn"
        deleteBtn.Size = UDim2.new(0, 28, 0, 28)
        deleteBtn.Position = UDim2.new(1, -38, 0.5, 0)
        deleteBtn.AnchorPoint = Vector2.new(0, 0.5)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        deleteBtn.BackgroundTransparency = 1
        deleteBtn.BorderSizePixel = 0
        deleteBtn.Text = "✕"
        deleteBtn.TextColor3 = Theme.Text_Muted
        deleteBtn.Font = Theme.Font_Heading
        deleteBtn.TextSize = 11
        deleteBtn.AutoButtonColor = false
        MakeCorner(deleteBtn, 6)
        deleteBtn.Parent = item

        -- Hover effects for delete button
        deleteBtn.MouseEnter:Connect(function()
            SmoothTween(deleteBtn, {BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0.15, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        end)
        deleteBtn.MouseLeave:Connect(function()
            SmoothTween(deleteBtn, {BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 1, TextColor3 = Theme.Text_Muted}, 0.15)
        end)

        -- Delete click handler (using MouseButton1Click for reliable click detection)
        deleteBtn.MouseButton1Click:Connect(function()
            local sessionId = session.Id
            -- Animate deletion
            SmoothTween(item, {Size = UDim2.new(1, -8, 0, 0), BackgroundTransparency = 1}, 0.2):Play()
            task.delay(0.25, function()
                DeleteSession(sessionId)
                RefreshSessionList()
                RefreshChatArea()
            end)
        end)

        -- Click to switch session
        item.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                -- Don't switch if clicking delete button
                local mousePos = UserInputService:GetMouseLocation()
                local btnPos = deleteBtn.AbsolutePosition
                local btnSize = deleteBtn.AbsoluteSize
                if mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
                    and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y then
                    return
                end

                ActiveSession = session
                RefreshSessionList()
                RefreshChatArea()
            end
        end)

        -- Hover effect for session item
        item.MouseEnter:Connect(function()
            if not (ActiveSession and ActiveSession.Id == session.Id) then
                SmoothTween(item, {BackgroundColor3 = Theme.BG_Hover}, 0.15)
            end
        end)
        item.MouseLeave:Connect(function()
            if not (ActiveSession and ActiveSession.Id == session.Id) then
                SmoothTween(item, {BackgroundColor3 = Theme.BG_Dark}, 0.15)
            end
        end)
    end
end

-- ═══════════════════════════════════════════════
--  CHAT AREA REFRESH
-- ═══════════════════════════════════════════════
function RefreshChatArea()
    -- Clear messages
    for _, child in ipairs(MessagesFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if not ActiveSession or #ActiveSession.Messages == 0 then
        WelcomeFrame.Visible = true
        MessagesFrame.Visible = false
        ChatTitle.Text = "Costudio AI"
        ChatSubtitle.Text = "Always online • Ready to assist"
        return
    end

    WelcomeFrame.Visible = false
    MessagesFrame.Visible = true
    ChatTitle.Text = ActiveSession.Title
    ChatSubtitle.Text = #ActiveSession.Messages .. " messages • Active session"

    for _, msg in ipairs(ActiveSession.Messages) do
        if msg.Role == "user" then
            CreateUserBubble(msg.Content)
        else
            CreateAIBubble(msg.Content)
        end
    end

    -- Scroll to bottom
    task.defer(function()
        MessagesFrame.CanvasPosition = Vector2.new(0, 99999)
    end)
end

-- ═══════════════════════════════════════════════
--  SEND MESSAGE LOGIC
-- ═══════════════════════════════════════════════
local isGenerating = false

local function SendMessage()
    if isGenerating then return end
    local text = PromptInput.Text
    if text == "" or text:match("^%s*$") then return end

    -- Ensure we have an active session
    if not ActiveSession then
        CreateSession()
        RefreshSessionList()
    end

    -- Hide welcome, show messages
    WelcomeFrame.Visible = false
    MessagesFrame.Visible = true

    -- Add user message
    local userMsg = {Role = "user", Content = text}
    table.insert(ActiveSession.Messages, userMsg)

    -- Update session title from first message
    if #ActiveSession.Messages == 1 then
        ActiveSession.Title = text:sub(1, 28) .. (#text > 28 and "..." or "")
        RefreshSessionList()
        ChatTitle.Text = ActiveSession.Title
    end

    ChatSubtitle.Text = #ActiveSession.Messages .. " messages • Active session"

    -- Create user bubble
    CreateUserBubble(text)

    -- Clear input
    PromptInput.Text = ""

    -- Scroll to bottom
    task.defer(function()
        MessagesFrame.CanvasPosition = Vector2.new(0, 99999)
    end)

    -- Generate AI response
    isGenerating = true
    SendBtn.Text = "..."
    SendBtn.BackgroundColor3 = Theme.Accent_Dim

    -- Show typing indicator
    local typingBubble, typingLabel = CreateAIBubble("● ● ●")

    -- Animate typing dots
    local dotCount = 0
    local typingConn
    typingConn = RunService.Heartbeat:Connect(function()
        if not isGenerating then
            typingConn:Disconnect()
            return
        end
        dotCount = dotCount + 1
        if dotCount % 15 == 0 then
            local dots = {"●", "● ●", "● ● ●", "● ●"}
            typingLabel.Text = dots[(math.floor(dotCount / 15) % #dots) + 1]
        end
    end)

    -- Get AI response in a separate thread
    task.spawn(function()
        local response = GetAIResponse(text)

        -- Clean up typing indicator
        typingConn:Disconnect()
        typingBubble:Destroy()

        -- Add AI message
        local aiMsg = {Role = "assistant", Content = response}
        table.insert(ActiveSession.Messages, aiMsg)

        -- Create AI bubble with typewriter effect
        local aiBubble, aiLabel = CreateAIBubble("")
        TypewriterEffect(aiLabel, response, 0.015)

        ChatSubtitle.Text = #ActiveSession.Messages .. " messages • Active session"

        -- Scroll to bottom
        task.defer(function()
            MessagesFrame.CanvasPosition = Vector2.new(0, 99999)
        end)

        isGenerating = false
        SendBtn.Text = "↑"
        SendBtn.BackgroundColor3 = Theme.Accent
    end)
end

-- ═══════════════════════════════════════════════
--  EVENT CONNECTIONS
-- ═══════════════════════════════════════════════
SendBtn.MouseButton1Click:Connect(SendMessage)

PromptInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SendMessage()
    end
end)

-- ═══════════════════════════════════════════════
--  ENTRANCE ANIMATION
-- ═══════════════════════════════════════════════
MainContainer.Size = UDim2.new(0, 820, 0, 0)
MainContainer.BackgroundTransparency = 1
MainContainer.ClipsDescendants = false

task.defer(function()
    task.wait(0.1)
    MainContainer.ClipsDescendants = true
    SmoothTween(MainContainer, {Size = UDim2.new(0, 820, 0, 560), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back):Play()
end)

-- ═══════════════════════════════════════════════
--  INITIALIZE
-- ═══════════════════════════════════════════════
CreateSession()
RefreshSessionList()

print("[Costudio AI] Loaded successfully — Premium Edition v2.0")
