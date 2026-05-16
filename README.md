local OrionLib = nil
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if success and result then
    OrionLib = result
else
    OrionLib = {
        MakeWindow = function()
            return {
                MakeTab = function() return {} end
            }
        end
    }
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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
                local espText = ""
                
                if Settings.ESPType == "Fruits" and (name:find("fruit") or name:find("apple")) then
                    shouldESP = true
                    espColor = Color3.fromRGB(255, 100, 255)
                    espText = "🍎"
                elseif Settings.ESPType == "Chests" and (name:find("chest") or name:find("box")) then
                    shouldESP = true
                    espColor = Color3.fromRGB(255, 215, 0)
                    espText = "🎁"
                elseif Settings.ESPType == "Enemies" and obj:FindFirstChild("Humanoid") and obj.Name ~= Player.Name then
                    local humanoid = obj.Humanoid
                    if humanoid and humanoid.Health > 0 then
                        shouldESP = true
                        espColor = Color3.fromRGB(255, 50, 50)
                        espText = "👾"
                    end
                end
                
                if shouldESP then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = obj
                    highlight.FillColor = espColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    table.insert(ESPObjects, highlight)
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Parent = obj.HumanoidRootPart
                    billboard.Size = UDim2.new(0, 50, 0, 30)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    
                    local label = Instance.new("TextLabel")
                    label.Parent = billboard
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = espText
                    label.TextColor3 = espColor
                    label.TextSize = 20
                    label.Font = Enum.Font.GothamBold
                    table.insert(ESPObjects, billboard)
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

local Window = OrionLib:MakeWindow({
    Name = "INIO HUB",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "InioHub",
    IntroEnabled = false
})

local AutoFarmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://3926305904"
})

AutoFarmTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
        if Value then
            task.spawn(AutoFarmLoop)
        end
    end
})

AutoFarmTab:AddSlider({
    Name = "Range",
    Min = 10,
    Max = 50,
    Default = 25,
    Callback = function(Value)
        Settings.FarmRange = Value
    end
})

local TeleportsTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://3926305904"
})

TeleportsTab:AddDropdown({
    Name = "Ilhas",
    Default = "Deserto",
    Options = {"Ilha Inicial", "Selva", "Deserto", "Vila Pirata", "Coliseu", "Ilha da Fonte", "Base Marine", "Ilha do Gelo", "Prisão", "Ilha do Magma", "Ilha do Céu", "Reino das Rosas", "Cake Land"},
    Callback = function(Value)
        Settings.SelectedIsland = Value
    end
})

TeleportsTab:AddButton({
    Name = "Teleportar",
    Callback = function()
        TeleportToIsland(Settings.SelectedIsland)
    end
})

TeleportsTab:AddButton({
    Name = "Melhor Ilha",
    Callback = function()
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
    end
})

local CombatTab = Window:MakeTab({
    Name = "Combate",
    Icon = "rbxassetid://3926305904"
})

CombatTab:AddToggle({
    Name = "Auto Haki",
    Default = false,
    Callback = function(Value)
        Settings.AutoHaki = Value
    end
})

CombatTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        ToggleNoClip()
    end
})

CombatTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(Value)
        ToggleFly()
    end
})

local UtilitiesTab = Window:MakeTab({
    Name = "Util",
    Icon = "rbxassetid://3926305904"
})

UtilitiesTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(Value)
        Settings.ESP = Value
        if Value then
            CreateESP()
        else
            ClearESP()
        end
    end
})

UtilitiesTab:AddDropdown({
    Name = "ESP Type",
    Default = "Fruits",
    Options = {"Fruits", "Chests", "Enemies"},
    Callback = function(Value)
        Settings.ESPType = Value
        if Settings.ESP then
            CreateESP()
        end
    end
})

local SecurityTab = Window:MakeTab({
    Name = "Seg",
    Icon = "rbxassetid://3926305904"
})

SecurityTab:AddToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        Settings.AntiAFK = Value
        if Value then
            AntiAFK()
        end
    end
})

local StatsTab = Window:MakeTab({
    Name = "Stats",
    Icon = "rbxassetid://3926305904"
})

StatsTab:AddToggle({
    Name = "Auto Stats",
    Default = false,
    Callback = function(Value)
        Settings.AutoStats = Value
    end
})

StatsTab:AddDropdown({
    Name = "Prioridade",
    Default = "Melee",
    Options = {"Melee", "Defense", "Sword", "Fruit", "Gun"},
    Callback = function(Value)
        Settings.StatPriority = Value
    end
})

task.spawn(function()
    while true do
        UpdatePlayerData()
        wait(5)
    end
end)

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end)
