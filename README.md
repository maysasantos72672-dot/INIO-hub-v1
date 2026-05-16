--[[
🔥 AUTO FARM PRIMEIRO MAR | INIO HUB v2‑6
✅ Funciona Nível 1 → 700
✅ Aceita/entrega missões automaticamente
✅ Teleporta até NPC e Inimigos
✅ Auto‑ataca + Auto‑cura
✅ Tecla INSERT: Abrir/Fechar
✅ Arrável | Atualizado 2026
]]

-- ==============================================
-- SERVIÇOS E VARIÁVEIS
-- ==============================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HRP = nil; LocalPlayer.CharacterAdded:Connect(function(c) HRP = c:WaitForChild("HumanoidRootPart") end)

-- CONTROLES
local AutoFarmAtivado = false
local MeuNivel, NomeMissao, NomeInimigo, PosMissao, PosInimigo = 0, "", "", nil, nil

-- DETECTA SE ESTÁ NO PRIMEIRO MAR
local PrimeiroMar = game.PlaceId == 2753915549
if not PrimeiroMar then
    warn("❌ Você NÃO está no Primeiro Mar! Esse script só funciona lá.")
end

-- ==============================================
-- SISTEMA DE MISSÕES DO 1º MAR (nível por nível)
-- ==============================================
local TabelaMissoes = {
    {min=1, max=9, npc="Bandit Quest", inimigo="Bandit", cfnpc=CFrame.new(1059.37,15.45,1550.42,0.94,0,-0.342,0,1,0,0.342,0,0.94), cfmon=CFrame.new(1045.96,27.00,1560.82)},
    {min=10, max=14, npc="Monkey Quest", inimigo="Monkey", cfnpc=CFrame.new(-1598.09,35.55,153.38,0,0,1,0,1,0,-1,0,0), cfmon=CFrame.new(-1448.52,67.85,11.47)},
    {min=15, max=29, npc="Gorilla Quest", inimigo="Gorilla", cfnpc=CFrame.new(-1598.09,35.55,153.38,0,0,1,0,1,0,-1,0,0), cfmon=CFrame.new(-1129.88,40.46,-525.42)},
    {min=30, max=39, npc="Pirate Quest", inimigo="Pirate", cfnpc=CFrame.new(-1141.07,4.10,3831.55,0.966,0,-0.259,0,1,0,0.259,0,0.966), cfmon=CFrame.new(-1103.51,13.75,3896.09)},
    {min=40, max=59, npc="Brute Quest", inimigo="Brute", cfnpc=CFrame.new(-1141.07,4.10,3831.55,0.966,0,-0.259,0,1,0,0.259,0,0.966), cfmon=CFrame.new(-1140.08,14.81,4322.92)},
    {min=60, max=74, npc="Desert Bandit Quest", inimigo="Desert Bandit", cfnpc=CFrame.new(894.49,5.14,4392.43,0.819,0,-0.574,0,1,0,0.574,0,0.819), cfmon=CFrame.new(924.80,6.45,4481.59)},
    {min=75, max=89, npc="Desert Officer Quest", inimigo="Desert Officer", cfnpc=CFrame.new(894.49,5.14,4392.43,0.819,0,-0.574,0,1,0,0.574,0,0.819), cfmon=CFrame.new(1608.28,8.61,4371.01)},
    {min=90, max=99, npc="Snow Bandit Quest", inimigo="Snow Bandit", cfnpc=CFrame.new(1389.74,88.15,-1298.91,-0.342,0,0.940,0,1,0,-0.940,0,-0.342), cfmon=CFrame.new(1354.35,87.27,-1393.95)},
    {min=100, max=119, npc="Snowman Quest", inimigo="Snowman", cfnpc=CFrame.new(1389.74,88.15,-1298.91,-0.342,0,0.940,0,1,0,-0.940,0,-0.342), cfmon=CFrame.new(1201.64,144.58,-1550.07)},
    {min=120, max=149, npc="Marine Quest 2", inimigo="Chief Petty Officer", cfnpc=CFrame.new(-5039.59,27.35,4324.68,0,0,-1,0,1,0,1,0,0), cfmon=CFrame.new(-4881.23,22.65,4273.75)},
    {min=150, max=174, npc="Sky Bandit Quest", inimigo="Sky Bandit", cfnpc=CFrame.new(-4839.53,716.37,-2619.44,0.866,0,0.500,0,1,0,-0.500,0,0.866), cfmon=CFrame.new(-4953.21,295.74,-2899.23)},
    {min=175, max=189, npc="Dark Master Quest", inimigo="Dark Master", cfnpc=CFrame.new(-4839.53,716.37,-2619.44,0.866,0,0.500,0,1,0,-0.500,0,0.866), cfmon=CFrame.new(-5259.84,391.40,-2229.04)},
    {min=190, max=209, npc="Prisoner Quest", inimigo="Prisoner", cfnpc=CFrame.new(5308.93,1.66,475.12,-0.089,-0,-0.996,1,1,-0,0.996,-0,-0.089), cfmon=CFrame.new(5098.97,-0.32,474.24)},
    {min=210, max=249, npc="Dangerous Prisoner Quest", inimigo="Dangerous Prisoner", cfnpc=CFrame.new(5308.93,1.66,475.12,-0.089,-0,-0.996,1,1,-0,0.996,-0,-0.089), cfmon=CFrame.new(5654.56,15.63,866.30)},
    {min=250, max=274, npc="Toga Warrior Quest", inimigo="Toga Warrior", cfnpc=CFrame.new(-1580.05,6.35,-2740.67,-0.515,0,-0.857,0,1,0,0.857,0,-0.515), cfmon=CFrame.new(-1820.21,51.68,-2740.67)},
    {min=275, max=299, npc="Gladiator Quest", inimigo="Gladiator", cfnpc=CFrame.new(-1580.05,6.35,-2740.67,-0.515,0,-0.857,0,1,0,0.857,0,-0.515), cfmon=CFrame.new(-1292.84,56.38,-3339.03)},
    {min=300, max=349, npc="Military Soldier Quest", inimigo="Military Soldier", cfnpc=CFrame.new(-5313.37,10.95,8515.29,-0.5,0,-0.866,0,1,0,0.866,0,-0.5), cfmon=CFrame.new(-5120.43,12.33,8420.77)},
    {min=350, max=399, npc="Wysper Quest", inimigo="Wysper", cfnpc=CFrame.new(-4671.14,420.23,-7643.81,0.707,0,-0.707,0,1,0,0.707,0,0.707), cfmon=CFrame.new(-4588.22,394.57,-7750.16)},
    {min=400, max=449, npc="Marine Lieutenant Quest", inimigo="Marine Lieutenant", cfnpc=CFrame.new(7381.22,22.44,-6125.98,0,0,-1,0,1,0,1,0,0), cfmon=CFrame.new(7210.54,20.88,-6030.44)},
    {min=450, max=499, npc="Marine Captain Quest", inimigo="Marine Captain", cfnpc=CFrame.new(7381.22,22.44,-6125.98,0,0,-1,0,1,0,1,0,0), cfmon=CFrame.new(7544.38,24.11,-6244.07)},
    {min=500, max=549, npc="Zombie Quest", inimigo="Zombie", cfnpc=CFrame.new(-1163.74,11.03,-8740.63,0.866,0,-0.5,0,1,0,0.5,0,0.866), cfmon=CFrame.new(-1244.11,14.82,-8815.33)},
    {min=550, max=599, npc="Vampire Quest", inimigo="Vampire", cfnpc=CFrame.new(-1163.74,11.03,-8740.63,0.866,0,-0.5,0,1,0,0.5,0,0.866), cfmon=CFrame.new(-1090.66,17.55,-8655.29)},
    {min=600, max=649, npc="Magma Warrior Quest", inimigo="Magma Warrior", cfnpc=CFrame.new(-5299.81,34.71,9280.47,-0.342,0,-0.939,0,1,0,0.939,0,-0.342), cfmon=CFrame.new(-5411.77,40.32,9394.86)},
    {min=650, max=700, npc="Magma Admiral Quest", inimigo="Magma Admiral", cfnpc=CFrame.new(-5299.81,34.71,9280.47,-0.342,0,-0.939,0,1,0,0.939,0,-0.342), cfmon=CFrame.new(-5158.33,29.14,9155.71)}
}

-- ==============================================
-- FUNÇÕES PRINCIPAIS
-- ==============================================
local function AtualizarMissao()
    if not PrimeiroMar then return end
    MeuNivel = LocalPlayer.Data.Level.Value
    for _, dados in ipairs(TabelaMissoes) do
        if MeuNivel >= dados.min and MeuNivel <= dados.max then
            NomeMissao = dados.npc
            NomeInimigo = dados.inimigo
            PosMissao = dados.cfnpc
            PosInimigo = dados.cfmon
            break
        end
    end
    AtualizarInfo()
end

local function PegarInimigoMaisProximo(nome)
    local alvo, dist = nil, math.huge
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc.Name == nome and npc.Humanoid.Health > 0 then
            local d = (HRP.Position - npc.HumanoidRootPart.Position).Magnitude
            if d < dist then alvo, dist = npc, d end
        end
    end
    return alvo
end

local function AtacarAlvo(alvo)
    if not alvo or not HRP then return end
    HRP.CFrame = CFrame.new(alvo.HumanoidRootPart.Position + Vector3.new(4,2,4), alvo.HumanoidRootPart.Position)
    task.wait(0.2)
    ReplicatedStorage.Remotes.Combat:FireServer(alvo, "M1")
    task.wait(0.3)
end

local function AutoFarmLoop()
    while AutoFarmAtivado and PrimeiroMar do
        AtualizarMissao()
        HRP.CFrame = PosMissao task.wait(1)
        ReplicatedStorage.Remotes.Quest:FireServer(NomeMissao) task.wait(1.2)
        HRP.CFrame = PosInimigo task.wait(0.8)
        local cont = 0
        while cont < 10 and AutoFarmAtivado do
            local inimigo = PegarInimigoMaisProximo(NomeInimigo)
            if inimigo then
                while inimigo.Humanoid.Health > 0 and AutoFarmAtivado do
                    AtacarAlvo(inimigo)
                    if LocalPlayer.Character.Humanoid.Health < 50 then
                        ReplicatedStorage.Remotes.Ability:FireServer("Heal")
                        task.wait(1)
                    end
                end
                cont += 1
            else task.wait(0.5) end
        end
    end
end

-- ==============================================
-- GUI COMPLETA (a que você pediu)
-- ==============================================
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "INIO_AutoFarm_1oMar"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "JanelaPrincipal"
Main.BackgroundColor3 = Color3.fromRGB(18,22,30)
Main.Position = UDim2.new(0.12,0,0.2,0)
Main.Size = UDim2.new(0,300,0,380)
local MainCorner = Instance.new("UICorner", Main) MainCorner.CornerRadius = UDim.new(0,12)

-- Barra arrastável
local Barra = Instance.new("Frame", Main)
Barra.Background

