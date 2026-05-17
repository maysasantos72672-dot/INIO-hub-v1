-- ===================================
-- INIO HUB - Auto Farm Profissional
-- ===================================

local ProxyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProxyHubDev/ProxyLib/refs/heads/main/Documents/ProxyLibrary"))()
local Library = ProxyLib.new()

-- ===================================
-- SERVIÇOS
-- ===================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ===================================
-- CONFIGURAÇÕES GLOBAIS
-- ===================================
local Settings = {
    -- Farm
    AutoFarmEnabled = false,
    FarmDistance = 150,
    -- UI
    Notifications = true,
}

-- ===================================
-- MAPEAMENTO COMPLETO DE MISSÕES
-- ===================================
local MissionMap = {
    -- Nível 1-5: Bandit Quest Giver
    [1] = { 
        npc = "Bandit Quest Giver", 
        enemy = "Bandit", 
        location = "Starter Island",
        position = CFrame.new(1058.96802, 12.6660004, 1551.81396, 0.956294656, -0, -0.292404652, 0, 1, -0, 0.292404652, 0, 0.956294656)
    },
    
    -- Nível 10: Pirate Adventurer
    [10] = { 
        npc = "Pirate Adventurer", 
        enemy = "Pirate", 
        location = "Pirate Island",
        position = CFrame.new(-1141.07495, 1.1000061, 3831.55005, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
    },
    
    -- Nível 30: Marine Recruiter
    [30] = { 
        npc = "Marine Recruiter", 
        enemy = "Marine", 
        location = "Marine Base",
        position = CFrame.new(880.392029, 4.67199707, 1336.29004, -0.173624277, 0, 0.984811902, 0, 1, 0, -0.984811902, 0, -0.173624277)
    },
    
    -- Nível 60: Desert Adventurer
    [60] = { 
        npc = "Desert Adventurer", 
        enemy = "Bandit", 
        location = "Desert",
        position = CFrame.new(894.489014, 5.58999634, 4392.43408, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
    },
    
    -- Nível 90: Marine Leader
    [90] = { 
        npc = "Marine Leader", 
        enemy = "Marine", 
        location = "Marine Fortress",
        position = CFrame.new(-2708.5769, 23.4660034, 2105.3479, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)
    },
    
    -- Nível 120: Villager
    [120] = { 
        npc = "Villager", 
        enemy = "Bandit", 
        location = "Village",
        position = CFrame.new(1387.18799, 86.6210022, -1295.04504, -0.25917995, 0, 0.965829313, 0, 1, 0, -0.965829313, 0, -0.25917995)
    },
    
    -- Nível 150: Colosseum Quest Giver
    [150] = { 
        npc = "Colosseum Quest Giver", 
        enemy = "Colosseum Fighter", 
        location = "Colosseum",
        position = CFrame.new(-1580.047, 7.19999695, -2986.47607, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
    },
    
    -- Nível 200: Head Jailer
    [200] = { 
        npc = "Head Jailer", 
        enemy = "Prison Guard", 
        location = "Prison",
        position = CFrame.new(5191.86084, 2.83999634, 686.439026, -0.731384635, 0, 0.681965172, 0, 1, 0, -0.681965172, 0, -0.731384635)
    },
    
    -- Nível 250: Sky Adventurer
    [250] = { 
        npc = "Sky Adventurer", 
        enemy = "Sky Knight", 
        location = "Sky Island",
        position = CFrame.new(-4839.51611, 716.671021, -2619.41699, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
    },
    
    -- Nível 300: The Mayor
    [300] = { 
        npc = "The Mayor", 
        enemy = "Bandit", 
        location = "Town",
        position = CFrame.new(-5313.37012, 11.25, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
    },
    
    -- Nível 350: Mole
    [350] = { 
        npc = "Mole", 
        enemy = "Underground Enemy", 
        location = "Underground",
        position = CFrame.new(-7858.43994, 5544.49023, -381.78299, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
    },
    
    -- Nível 400: Sky Quest Giver 2
    [400] = { 
        npc = "Sky Quest Giver 2", 
        enemy = "Sky Enemy", 
        location = "Sky Kingdom",
        position = CFrame.new(-7904.68506, 5634.66113, -1409.96704, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    },
}

-- ===================================
-- SISTEMA DE CHAVES
-- ===================================
local KS = Library:CreateKeySystem({
    Title = "INIO HUB",
    Icon = "rbxassetid://11165189124",
    Theme = "Blue",
    Size = Vector2.new(420, 265),
    Acrylic = {
        Enabled = true,
        Opacity = 0.55,
    },
})

KS:CreateButton({
    Description = "Entrar",
    Icon = "rbxassetid://10734962649",
    Callback = function()
        if KS:GetText() == "bloxfruit" then
            KS:Destroy()
            CreateMainWindow()
        else
            KS:Notify({
                Title = "❌ Chave Inválida",
                Text = "Digite a chave correta para continuar.",
                Duration = 3,
            })
        end
    end,
})

KS:CreateSocialButton({ Type = "Discord", Link = "https://discord.gg/GMAFx8NxdK", Order = 1 })
KS:CreateSocialButton({ Type = "Youtube", Link = "https://youtube.com", Order = 2 })

-- ===================================
-- FUNÇÕES AUXILIARES
-- ===================================

local function GetPlayerLevel()
    local playerStats = LocalPlayer:FindFirstChild("leaderstats")
    if not playerStats then
        return 1
    end
    
    -- Tenta encontrar Level em diferentes locais
    local levelValue = playerStats:FindFirstChild("Level") or 
                       playerStats:FindFirstChild("Lvl") or
                       playerStats:FindFirstChild("level")
    
    if levelValue then
        return levelValue.Value
    end
    return 1
end

local function FindMissionForLevel(level)
    local bestMission = MissionMap[1] -- Fallback para nível 1
    
    -- Procura a missão com o nível mais alto que seja <= ao nível do jogador
    for levelKey, missionData in pairs(MissionMap) do
        if levelKey <= level and levelKey > (bestMission.levelKey or 1) then
            bestMission = missionData
            bestMission.levelKey = levelKey
        end
    end
    
    return bestMission
end

local function FindNearestEnemy(enemyType)
    local Enemies = Workspace:FindFirstChild("Enemies")
    if not Enemies then return nil end
    
    local nearest = nil
    local shortestDistance = math.huge
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        -- Verifica se é o tipo de inimigo procurado
        if enemy.Name == enemyType and enemy:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            
            if distance < shortestDistance then
                nearest = enemy
                shortestDistance = distance
            end
        end
    end
    
    return nearest
end

local function FindNPC(npcName)
    local NPCs = Workspace:FindFirstChild("NPCs")
    if not NPCs then return nil end
    
    for _, npc in pairs(NPCs:GetChildren()) do
        if string.find(npc.Name, npcName) then
            return npc
        end
    end
    
    return nil
end

local function TeleportTo(position)
    if RootPart then
        if typeof(position) == "CFrame" then
            RootPart.CFrame = position + Vector3.new(0, 3, 0)
        else
            RootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        end
        wait(0.5)
    end
end

local function InteractWithNPC(npc)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        -- Teleportar para o NPC
        TeleportTo(npc.HumanoidRootPart.Position)
        
        -- Procurar por ClickDetector ou Humanoid para interagir
        local clickDetector = npc:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            -- Simular clique no ClickDetector
            game:GetService("Mouse").TargetFilter = npc
            game:GetService("Mouse").Move:Connect(function()
                if game:GetService("Mouse").Target == npc then
                    clickDetector:FireServer()
                end
            end)
        end
    end
end

local function AttackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") then return end
    
    -- Teleportar próximo ao inimigo
    TeleportTo(enemy.HumanoidRootPart.Position)
    
    -- Simular ataque (Z = ataque padrão)
    UserInputService:SendKeyEvent(true, Enum.KeyCode.Z, false)
    wait(0.3)
    UserInputService:SendKeyEvent(false, Enum.KeyCode.Z, false)
end

local function FarmEnemy(enemyType, maxKills)
    local killCount = 0
    local startTime = tick()
    local maxTime = 300 -- 5 minutos máximo
    
    while killCount < maxKills and (tick() - startTime) < maxTime do
        local enemy = FindNearestEnemy(enemyType)
        
        if enemy and enemy:FindFirstChild("Humanoid") then
            -- Atacar enquanto vivo
            while enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 do
                AttackEnemy(enemy)
                wait(0.5)
            end
            
            killCount = killCount + 1
            wait(0.5)
        else
            wait(1)
        end
    end
    
    return killCount >= maxKills
end

-- ===================================
-- LOOP PRINCIPAL DE AUTO FARM
-- ===================================

local function StartAutoFarm()
    while Settings.AutoFarmEnabled do
        local playerLevel = GetPlayerLevel()
        
        -- Encontrar a missão apropriada para o nível
        local missionConfig = FindMissionForLevel(playerLevel)
        
        if missionConfig and missionConfig.position then
            -- 1. IR ATÉ NPC
            TeleportTo(missionConfig.position)
            wait(1)
            
            -- 2. PEGAR MISSÃO
            InteractWithNPC(FindNPC(missionConfig.npc))
            wait(2)
            
            -- 3. PROCURAR E MATAR INIMIGOS
            FarmEnemy(missionConfig.enemy, 10) -- Matar 10 inimigos
            
            -- 4. VOLTAR AO NPC E CLAIMAR
            TeleportTo(missionConfig.position)
            wait(1)
            InteractWithNPC(FindNPC(missionConfig.npc))
            wait(2)
        else
            wait(2)
        end
    end
end

-- ===================================
-- JANELA PRINCIPAL
-- ===================================

function CreateMainWindow()
    local Window = Library:CreateWindow({
        Title = "INIO HUB",
        Subtitle = "v2.0 - Auto Farm Pro",
        Icon = "rbxassetid://11165189124",
        Size = Vector2.new(620, 480),
        MinSize = Vector2.new(400, 300),
        MaxSize = Vector2.new(900, 700),
        TypeUI = "Modern",
        Theme = "Blue",
        Language = "Portuguese",
        AutoSave = true,
        AutoLoad = true,

        Acrylic = {
            Enabled = true,
            Opacity = 0.55,
        },

        ConfigPanel = {
            Enabled = true,
            Acrylic = true,
            Theme = true,
            Fps = true,
            Ping = true,
            Language = true,
        },

        FloatButton = {
            Shape = "Circle",
            Color = "Black",
            Size = 50,
            Icon = "rbxassetid://11165189124",
        },
    })

    Window:Notify({
        Title = "✅ Bem-vindo ao INIO HUB!",
        Text = "Auto Farm Profissional Carregado!",
        TitleColoredWords = {
            { Text = "INIO HUB", Colors = { Color3.fromRGB(35, 85, 170), Color3.fromRGB(55, 110, 200) }, Gradient = true },
        },
        Duration = 4,
    })

    -- ===================================
    -- ABA: AUTO FARM
    -- ===================================
    local TabAutoFarm = Window:CreateTab({
        Title = "Auto Farm",
        Subtitle = "Sistema automático de missões",
        Icon = "rbxassetid://10734966411",
    })

    TabAutoFarm:CreateSection({ Text = "⚙️ Controle Principal" })

    local AutoFarmToggle = TabAutoFarm:CreateToggle({
        Title = "Ativar Auto Farm",
        Description = "Sistema automático de farm com ataque e coleta",
        Default = false,
        SaveId = "autofarm_toggle",
        Callback = function(state)
            Settings.AutoFarmEnabled = state
            if state then
                Window:Notify({
                    Title = "✅ Auto Farm Ativado",
                    Text = "Começando a farmar missões...",
                    ColoredWords = {
                        { Text = "Ativado", Colors = { Color3.fromRGB(80, 220, 80) } },
                    },
                    Duration = 3,
                })
                task.spawn(StartAutoFarm)
            else
                Window:Notify({
                    Title = "❌ Auto Farm Desativado",
                    Text = "Farm parado.",
                    Duration = 2,
                })
            end
        end,
    })

    TabAutoFarm:CreateSeparatorLine()
    TabAutoFarm:CreateSection({ Text = "📊 Status" })

    local playerLevel = GetPlayerLevel()
    TabAutoFarm:CreateParagraph({
        Title = "Informações do Jogador",
        DescriptionWords = {
            "Nível: ",
            { Text = tostring(playerLevel), Colors = { Color3.fromRGB(100, 220, 255) } },
            " | Status: ",
            { Text = "Pronto", Colors = { Color3.fromRGB(80, 220, 80) } },
        },
    })

    TabAutoFarm:CreateParagraph({
        Title = "Missão Atual",
        Description = "Aguardando ativação do Auto Farm...",
        ColoredWords = {
            { Text = "Aguardando", Colors = { Color3.fromRGB(255, 200, 50) } },
        },
    })

    TabAutoFarm:CreateSeparatorLine()
    TabAutoFarm:CreateSection({ Text = "🎯 Ações Rápidas" })

    TabAutoFarm:CreateButton({
        Title = "Teleportar para Bandit Quest Giver",
        Description = "Vai direto para a missão de Bandit",
        Callback = function()
            local missionConfig = MissionMap[1]
            if missionConfig and missionConfig.position then
                TeleportTo(missionConfig.position)
                Window:Notify({
                    Title = "📍 Teleportado",
                    Text = "Chegou ao NPC com precisão!",
                    Duration = 2,
                })
            else
                local npc = FindNPC("Bandit Quest Giver")
                if npc then
                    TeleportTo(npc.HumanoidRootPart.Position)
                    Window:Notify({
                        Title = "📍 Teleportado",
                        Text = "Chegou ao NPC!",
                        Duration = 2,
                    })
                else
                    Window:Notify({
                        Title = "❌ Erro",
                        Text = "NPC não encontrado!",
                        Duration = 2,
                    })
                end
            end
        end,
    })

    TabAutoFarm:CreateButton({
        Title = "Atacar Inimigo Mais Próximo",
        Description = "Ataca o inimigo mais perto",
        Callback = function()
            local enemy = FindNearestEnemy("Bandit")
            if enemy then
                AttackEnemy(enemy)
                Window:Notify({
                    Title = "⚔️ Atacando",
                    Text = "Ataque iniciado!",
                    Duration = 1,
                })
            end
        end,
    })

    TabAutoFarm:CreateButton({
        Title = "Resetar Posição",
        Description = "Volta à posição inicial",
        Callback = function()
            RootPart.CFrame = CFrame.new(0, 50, 0)
            Humanoid:ChangeHealth(Humanoid.MaxHealth)
            Window:Notify({
                Title = "🔄 Reset",
                Text = "Posição resetada!",
                Duration = 1,
            })
        end,
    })

    -- ===================================
    -- ABA: CONFIGURAÇÕES
    -- ===================================
    local TabSettings = Window:CreateTab({
        Title = "Configurações",
        Subtitle = "Ajustes gerais",
        Icon = "rbxassetid://10702254382",
    })

    TabSettings:CreateSection({ Text = "🎨 Tema" })

    TabSettings:CreateDropdown({
        Title = "Tema da UI",
        Options = { "Blue", "Red", "Green", "Purple", "Pink", "Yellow", "White", "Grey" },
        Default = "Blue",
    })

    TabSettings:CreateSeparatorLine()
    TabSettings:CreateSection({ Text = "📢 Notificações" })

    TabSettings:CreateToggle({
        Title = "Notificações",
        Description = "Mostrar notificações de eventos",
        Default = true,
        SaveId = "notifications",
        Callback = function(state)
            Settings.Notifications = state
        end,
    })

    TabSettings:CreateSeparatorLine()
    TabSettings:CreateSection({ Text = "ℹ️ Sobre" })

    TabSettings:CreateParagraph({
        Title = "INIO HUB",
        Description = "Auto Farm Profissional para Blox Fruit com sistema automático de missões.",
        TitleColoredWords = {
            { Text = "INIO HUB", Colors = { Color3.fromRGB(35, 85, 170), Color3.fromRGB(55, 110, 200) }, Gradient = true },
        },
        ColoredWords = {
            { Text = "Auto Farm", Colors = { Color3.fromRGB(80, 220, 80) } },
        },
    })

    TabSettings:CreateDiscordInvite({
        Title = "Servidor Discord",
        Description = "Junte-se à nossa comunidade!",
        Link = "https://discord.gg/GMAFx8NxdK",
        Button = "Entrar",
    })

    -- Atualizar character quando morrer
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
    end)
end

print("INIO HUB - Auto Farm Pro Carregado! Digite a chave: bloxfruit")
