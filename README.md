local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Settings = {
    AutoFarm = false,
    FarmRange = 25,
    AutoHaki = false,
    NoClip = false,
    Fly = false,
    ESP = false,
    ESPType = "Fruits",
    AntiAFK = false,
    AutoStats = false,
    StatPriority = "Melee",
}

local PlayerData = {
    Level = 0,
    Beli = 0,
    Fragments = 0,
    StatPoints = 0
}

local Islands = {
    {Name = "Ilha Inicial", CFrame = CFrame.new(0, 0, 0), Level = 0},
    {Name = "Selva", CFrame = CFrame.new(-1368.65405, 62.2030029, -56.9450073), Level = 15},
    {Name = "Deserto", CFrame = CFrame.new(1216.34399, 32.1029968, 4366.68799), Level = 30},
    {Name = "Vila Pirata", CFrame = CFrame.new(-1087.82104, 51.4420013, 4148.36816), Level = 60},
    {Name = "Coliseu", CFrame = CFrame.new(-1650.755, 56.6549988, -3169.92798), Level = 90},
    {Name = "Ilha da Fonte", CFrame = CFrame.new(5713.72314, 283.834991, 4392.41113), Level = 110},
    {Name = "Base Marine", CFrame = CFrame.new(-4934.0708, 165.384995, 4324.09814), Level = 120},
    {Name = "Ilha do Gelo", CFrame = CFrame.new(1254.02002, 26.5130005, -1464.75598), Level = 130},
    {Name = "Prisão", CFrame = CFrame.new(5272.05713, 69.6170044, 747.97699), Level = 150},
    {Name = "Ilha do Magma", CFrame = CFrame.new(-5574.34814, 118.358002, 8670.28027), Level = 175},
    {Name = "Ilha do Céu", CFrame = CFrame.new(-5017.71484, 362.227997, -2391.30811), Level = 230},
    {Name = "Reino das Rosas", CFrame = CFrame.new(-4908.09, 60.5, -4949.28), Level = 375},
    {Name = "Cake Land", CFrame = CFrame.new(-6900, 60, -9800), Level = 650},
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InioHub"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
MainFrame.Size = UDim2.new(0, 400, 0, 600)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local function TeleportToIsland(islandName)
    for _, island in ipairs(Islands) do
        if island.Name == islandName then
            pcall(function()
                RootPart.CFrame = island.CFrame
                wait(0.1)
                RootPart.Velocity = Vector3.new(0, 0, 0)
            end)
            break
        end
    end
end

local function UpdatePlayerData()
    pcall(function()
        if Player.Data then
            PlayerData.Level = Player.Data.Level and Player.Data.Level.Value or 0
            PlayerData.Beli = Player.Data.Beli and Player.Data.Beli.Value or 0
            PlayerData.Fragments = Player.Data.Fragments and Player.Data.Fragments.Value or 0
            PlayerData.StatPoints = Player.Data.StatPoints and Player.Data.StatPoints.Value or 0
        end
    end)
end

local function AutoDistributeStats()
    if not Settings.AutoStats then return end
    local statRemote = ReplicatedStorage:FindFirstChild("AddStat")
    if statRemote and PlayerData.StatPoints and PlayerData.StatPoints > 0 then
        for i = 1, PlayerData.StatPoints do
            pcall(function()
                statRemote:FireServer(Settings.StatPriority)
            end)
        end
    end
end

local function EnableHaki()
    if not Settings.AutoHaki then return end
    local hakiRemote = ReplicatedStorage:FindFirstChild("EnableHaki")
    if hakiRemote then
        pcall(function()
            hakiRemote:FireServer()
        end)
    end
end

local ESPObjects = {}
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj then pcall(function() obj:Destroy() end) end
    end
    ESPObjects = {}
end

local function CreateESP()
    if not Settings.ESP then 
        ClearESP()
        return 
    end
    ClearESP()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local name = obj.Name:lower()
                local shouldESP = false
                local espColor = Color3.fromRGB(255, 100, 100)
                
                if Settings.ESPType == "Fruits" and (name:find("fruit") or name:find("apple")) then
                    shouldESP = true
                    espColor = Color3.fromRGB(255, 100, 255)
                elseif Settings.ESPType == "Chests" and (name:find("chest") or name:find("box")) then
                    shouldESP = true
                    espColor = Color3.fromRGB(255, 215, 0)
                elseif Settings.ESPType == "Enemies" and obj:FindFirstChild("Humanoid") and obj.Name ~= Player.Name then
                    local humanoid = obj.Humanoid
                    if humanoid and humanoid.Health > 0 then
                        shouldESP = true
                        espColor = Color3.fromRGB(255, 50, 50)
                    end
                end
                
                if shouldESP then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = obj
                    highlight.FillColor = espColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    table.insert(ESPObjects, highlight)
                end
            end
        end
    end)
end

local FarmLoopRunning = false
local function FindNearestEnemy()
    local nearest = nil
    local shortestDist = Settings.FarmRange
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= Player.Name then
                local humanoid = obj.Humanoid
                if humanoid and humanoid.Health and humanoid.Health > 0 then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (RootPart.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearest = obj
                        end
                    end
                end
            end
        end
    end)
    return nearest
end

local function AttackEnemy(enemy)
    if not enemy then return end
    pcall(function()
        local attackRemote = ReplicatedStorage:FindFirstChild("AttackEntity")
        if attackRemote then
            attackRemote:FireServer(enemy)
        end
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end

local function AutoFarmLoop()
    if FarmLoopRunning then return end
    FarmLoopRunning = true
    while Settings.AutoFarm do
        pcall(function()
            if not Character or not Humanoid or Humanoid.Health <= 0 then
                wait(2)
                return
            end
            UpdatePlayerData()
            AutoDistributeStats()
            if Settings.AutoHaki then EnableHaki() end
            local enemy = FindNearestEnemy()
            if enemy then
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                if enemyRoot then
                    local dist = (RootPart.Position - enemyRoot.Position).Magnitude
                    if dist > 15 then
                        RootPart.CFrame = enemyRoot.CFrame + Vector3.new(0, 3, 0)
                    else
                        AttackEnemy(enemy)
                    end
                end
            end
            if Settings.ESP then CreateESP() end
        end)
        wait(0.1)
    end
    FarmLoopRunning = false
end

local BodyVelocity = nil
local function ToggleNoClip()
    Settings.NoClip = not Settings.NoClip
    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not Settings.NoClip
            end
        end
    end)
end

local function ToggleFly()
    Settings.Fly = not Settings.Fly
    if Settings.Fly then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(100000, 100000, 100000)
        bg.Parent = RootPart
    else
        if BodyVelocity then BodyVelocity:Destroy() end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if Settings.Fly and BodyVelocity then
        if input.KeyCode == Enum.KeyCode.Space then
            BodyVelocity.Velocity = Vector3.new(0, 100, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            BodyVelocity.Velocity = Vector3.new(0, -100, 0)
        elseif input.KeyCode == Enum.KeyCode.W then
            BodyVelocity.Velocity = RootPart.CFrame.LookVector * 100
        elseif input.KeyCode == Enum.KeyCode.S then
            BodyVelocity.Velocity = -RootPart.CFrame.LookVector * 100
        elseif input.KeyCode == Enum.KeyCode.A then
            BodyVelocity.Velocity = -RootPart.CFrame.RightVector * 100
        elseif input.KeyCode == Enum.KeyCode.D then
            BodyVelocity.Velocity = RootPart.CFrame.RightVector * 100
        end
    end
end)

local function AntiAFK()
    if not Settings.AntiAFK then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end)
end

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Parent = ScreenGui
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
FloatingButton.Image = "rbxassetid://3926305904"
FloatingButton.BackgroundTransparency = 0.1
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
TopBar.Size = UDim2.new(1, 0, 0, 50)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "INIO HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Position = UDim2.new(1, -45, 0.1, 0)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 8)

local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollFrame
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(text, setting, default)
    local frame = Instance.new("Frame")
    frame.Parent = ScrollFrame
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0, 70, 0, 35)
    btn.Position = UDim2.new(1, -80, 0.1, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 80)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    Settings[setting] = default
    
    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        if Settings[setting] then
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            btn.Text = "ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            btn.Text = "OFF"
        end
    end)
    
    return btn
end

local function CreateDropdown(text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = ScrollFrame
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdown = Instance.new("TextButton")
    dropdown.Parent = frame
    dropdown.Size = UDim2.new(0, 100, 0, 35)
    dropdown.Position = UDim2.new(1, -110, 0.1, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    dropdown.Text = default
    dropdown.TextColor3 = Color3.new(1,1,1)
    dropdown.Font = Enum.Font.GothamSemibold
    dropdown.TextSize = 12
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
    
    local current = default
    callback(current)
    
    dropdown.MouseButton1Click:Connect(function()
        local nextIndex = 1
        for i, v in ipairs(options) do
            if v == current then
                nextIndex = i % #options + 1
                break
            end
        end
        current = options[nextIndex]
        dropdown.Text = current
        callback(current)
    end)
    
    return dropdown
end

CreateToggle("Auto Farm", "AutoFarm", false)
CreateToggle("Auto Haki", "AutoHaki", false)
CreateToggle("No Clip", "NoClip", false)
CreateToggle("Fly", "Fly", false)
CreateToggle("ESP", "ESP", false)
CreateToggle("Anti-AFK", "AntiAFK", false)
CreateToggle("Auto Stats", "AutoStats", false)

CreateDropdown("ESP Type", {"Fruits", "Chests", "Enemies"}, "Fruits", function(val)
    Settings.ESPType = val
end)

CreateDropdown("Stat Priority", {"Melee", "Defense", "Sword", "Fruit", "Gun"}, "Melee", function(val)
    Settings.StatPriority = val
end)

CreateButton("Teleportar Melhor Ilha", Color3.fromRGB(255, 140, 30), function()
    local playerLevel = Player.Data and Player.Data.Level and Player.Data.Level.Value or 0
    local bestIsland = nil
    for _, island in ipairs(Islands) do
        if playerLevel >= island.Level then
            bestIsland = island
        end
    end
    if bestIsland then
        TeleportToIsland(bestIsland.Name)
    end
end)

for _, island in ipairs(Islands) do
    CreateButton(island.Name, Color3.fromRGB(50, 100, 150), function()
        TeleportToIsland(island.Name)
    end)
end

FloatingButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

task.spawn(function()
    while true do
        if Settings.AutoFarm then
            pcall(function()
                if not Character or not Humanoid or Humanoid.Health <= 0 then
                    wait(2)
                    return
                end
                UpdatePlayerData()
                AutoDistributeStats()
                if Settings.AutoHaki then EnableHaki() end
                if Settings.AntiAFK then AntiAFK() end
                local enemy = FindNearestEnemy()
                if enemy then
                    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyRoot then
                        local dist = (RootPart.Position - enemyRoot.Position).Magnitude
                        if dist > 15 then
                            RootPart.CFrame = enemyRoot.CFrame + Vector3.new(0, 3, 0)
                        else
                            AttackEnemy(enemy)
                        end
                    end
                end
                if Settings.ESP then CreateESP() end
            end)
        end
        wait(0.1)
    end
end)

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)
