-- PROJECT YANG
-- Author: NotJDM

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer

-- Anti-Rubberband Fix (Disables the game's physics throttle)
pcall(function()
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "Project Yang",
    Icon = "shield",
    Author = "NotJDM",
    Folder = "0MZ",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    Transparent = true,
    Resizable = true,
})

-- Variables
local currentWalkSpeed = 16 -- Back to normal
local currentJumpPower = 50
local espObjects = {}
local skeletonLines = {}
local espEnabled = false
local skeletonEnabled = false

----------------------------------------------------------------
-- MAIN
----------------------------------------------------------------
local MainTab = Window:Tab({Title = "Main", Icon = "house"})

MainTab:Section({Title = "Welcome"})
MainTab:Paragraph({Title = "Project Yang", Desc = "Welcome to Project Yang! Enjoy the available features."})

MainTab:Section({Title = "Supported Game"})
MainTab:Paragraph({Title = "Obby", Desc = "Project Yang is intended for supported Obby games."})

MainTab:Section({Title = "Warning"})
MainTab:Paragraph({Title = "Important Warning", Desc = "Do not use Project Yang on combat games. Use responsibly."})

----------------------------------------------------------------
-- VISUAL (ESP & SKELETON)
----------------------------------------------------------------
local VisualTab = Window:Tab({Title = "Visual", Icon = "eye"})

-- ESP Function
local function createESP(plr)
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "0MZ_ESP"
    highlight.Adornee = plr.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = plr.Character
    espObjects[plr] = highlight
end

-- Skeleton Function
local function createSkeleton(plr)
    local lines = {
        Head = Drawing.new("Line"),
        Torso = Drawing.new("Line"),
        LeftArm = Drawing.new("Line"),
        RightArm = Drawing.new("Line"),
        LeftLeg = Drawing.new("Line"),
        RightLeg = Drawing.new("Line")
    }
    for _, line in pairs(lines) do
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
    end
    skeletonLines[plr] = lines
end

-- Render Loop for Skeleton
RunService.RenderStepped:Connect(function()
    if not skeletonEnabled then
        for _, lines in pairs(skeletonLines) do
            for _, line in pairs(lines) do line.Visible = false end
        end
        return
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local lines = skeletonLines[plr]
            if not lines then createSkeleton(plr) lines = skeletonLines[plr] end
            
            local function getPart(name) return plr.Character:FindFirstChild(name) end
            local head, torso = getPart("Head"), getPart("UpperTorso") or getPart("Torso")
            local lArm, rArm = getPart("LeftUpperArm") or getPart("Left Arm"), getPart("RightUpperArm") or getPart("Right Arm")
            local lLeg, rLeg = getPart("LeftUpperLeg") or getPart("Left Leg"), getPart("RightUpperLeg") or getPart("Right Leg")
            
            if head and torso then
                local function updateLine(line, p1, p2)
                    if p1 and p2 then
                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            line.From = Vector2.new(s1.X, s1.Y)
                            line.To = Vector2.new(s2.X, s2.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
                
                updateLine(lines.Head, head, torso)
                updateLine(lines.Torso, torso, torso)
                updateLine(lines.LeftArm, torso, lArm)
                updateLine(lines.RightArm, torso, rArm)
                updateLine(lines.LeftLeg, torso, lLeg)
                updateLine(lines.RightLeg, torso, rLeg)
            end
        end
    end
end)

VisualTab:Toggle({
    Title = "ESP",
    Desc = "Full-body player highlighting",
    Value = false,
    Callback = function(Value)
        espEnabled = Value
        if Value then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player then createESP(plr) end
            end
            Players.PlayerAdded:Connect(function(newPlr)
                if espEnabled then createESP(newPlr) end
            end)
        else
            for plr, highlight in pairs(espObjects) do
                if highlight then highlight:Destroy() end
            end
            espObjects = {}
        end
    end
})

VisualTab:Toggle({
    Title = "Skeleton ESP",
    Desc = "Player skeleton lines",
    Value = false,
    Callback = function(Value)
        skeletonEnabled = Value
        if not Value then
            for _, lines in pairs(skeletonLines) do
                for _, line in pairs(lines) do line.Visible = false end
            end
        end
    end
})

----------------------------------------------------------------
-- PLAYER
----------------------------------------------------------------
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

PlayerTab:Slider({
    Title = "Walk Speed",
    Desc = "Movement speed (Keep under 45 to avoid rubberbanding)",
    Value = {Min = 16, Max = 150, Default = 16}, -- Default back to 16
    Callback = function(Value)
        currentWalkSpeed = Value
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then Humanoid.WalkSpeed = currentWalkSpeed end
    end
})

PlayerTab:Slider({
    Title = "Jump Power",
    Desc = "Jump strength",
    Value = {Min = 50, Max = 200, Default = 50},
    Callback = function(Value)
        currentJumpPower = Value
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = currentJumpPower
        end
    end
})

local InfiniteJump = false

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump repeatedly in midair",
    Value = false,
    Callback = function(Value) InfiniteJump = Value end
})

UIS.JumpRequest:Connect(function()
    if not InfiniteJump then return end
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Anti-Reset Background Loop
task.spawn(function()
    while task.wait(0.5) do
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            if Humanoid.WalkSpeed ~= currentWalkSpeed then Humanoid.WalkSpeed = currentWalkSpeed end
            if Humanoid.JumpPower ~= currentJumpPower and Humanoid.UseJumpPower then Humanoid.JumpPower = currentJumpPower end
        end
    end
end)

----------------------------------------------------------------
-- OTHER
----------------------------------------------------------------
local OtherTab = Window:Tab({Title = "Other", Icon = "settings"})

OtherTab:Button({
    Title = "Join Discord",
    Desc = "Project Yang Discord server",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eFbwNTx8M")
            WindUI:Notify({Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3})
        end
    end
})

Window:SelectTab(1)
