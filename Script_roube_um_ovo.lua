--[[ 
    Script de Roubo de Ovo com Anti-Botão - Delta Executor
    Compatível com servidores Roblox
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local egg = nil -- Substitua pelo caminho do ovo: game.Workspace:FindFirstChild("Ovo")

-- Configurações
local CONFIG = {
    CheckInterval = 0.5, -- Intervalo entre verificações
    AntiBotEnabled = true, -- Ativar sistema anti-botão
    MaxClicks = 10, -- Máximo de cliques permitidos
    CooldownTime = 5, -- Tempo de cooldown em segundos
    AutoCollect = true, -- Coletar automaticamente
    NotificationEnabled = true -- Mostrar notificações
}

-- Função para notificar
local function notify(message)
    if CONFIG.NotificationEnabled then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Sistema de Roubo",
            Text = message,
            Duration = 3
        })
    end
end

-- Sistema Anti-Botão
local AntiBot = {
    clickCount = 0,
    lastClickTime = 0,
    isCooldown = false
}

function AntiBot:Check()
    if not CONFIG.AntiBotEnabled then return true end
    
    local currentTime = tick()
    
    -- Verifica cooldown
    if self.isCooldown then
        if currentTime - self.lastClickTime >= CONFIG.CooldownTime then
            self.isCooldown = false
            self.clickCount = 0
            return true
        else
            notify("⏳ Cooldown ativo: " .. math.floor(CONFIG.CooldownTime - (currentTime - self.lastClickTime)) .. "s")
            return false
        end
    end
    
    -- Verifica limite de cliques
    if self.clickCount >= CONFIG.MaxClicks then
        self.isCooldown = true
        self.lastClickTime = currentTime
        notify("⚠️ Limite de cliques excedido! Cooldown de " .. CONFIG.CooldownTime .. "s")
        return false
    end
    
    self.clickCount = self.clickCount + 1
    self.lastClickTime = currentTime
    return true
end

-- Função principal de roubo
local function stealEgg()
    if not egg then
        notify("❌ Ovo não encontrado!")
        return
    end
    
    if not AntiBot:Check() then
        return
    end
    
    -- Verifica se o ovo existe e está acessível
    if egg:IsA("BasePart") and egg.Parent ~= nil then
        -- Simula o clique para roubar
        local args = {
            [1] = egg,
            [2] = "Steal" -- Ação de roubo
        }
        
        -- Tenta executar o roubo
        local success, err = pcall(function()
            -- Método 1: FirerServer (mais comum)
            if egg:FindFirstChild("RemoteEvent") then
                egg.RemoteEvent:FireServer(unpack(args))
            end
            
            -- Método 2: ClickDetector
            if egg:FindFirstChild("ClickDetector") then
                egg.ClickDetector:Click()
            end
            
            -- Método 3: Tool
            if player.Backpack:FindFirstChild("Ferramenta") then
                player.Backpack.Ferramenta:Activate()
            end
        end)
        
        if success then
            notify("🥚 Ovo roubado com sucesso!")
            
            -- Efeito visual (opcional)
            if egg:IsA("BasePart") then
                egg.BrickColor = BrickColor.new("Bright red")
                spawn(function()
                    wait(1)
                    egg.BrickColor = BrickColor.new("Bright yellow")
                end)
            end
        else
            notify("❌ Falha ao roubar ovo!")
        end
    else
        notify("❌ Ovo inválido ou inacessível!")
    end
end

-- Função para encontrar o ovo automaticamente
local function findEgg()
    local possibleEggs = {
        "Ovo", "Egg", "ovo", "egg", "EasterEgg", "GoldenEgg"
    }
    
    for _, name in ipairs(possibleEggs) do
        local found = game.Workspace:FindFirstChild(name)
        if found then
            egg = found
            notify("✅ Ovo encontrado: " .. egg.Name)
            return true
        end
    end
    return false
end

-- Auto-coletor
local function autoCollect()
    if not CONFIG.AutoCollect then return end
    
    while wait(CONFIG.CheckInterval) do
        if not egg then
            if not findEgg() then
                -- Tenta procurar em outros lugares
                for _, child in ipairs(game.Workspace:GetChildren()) do
                    if child:IsA("BasePart") and child.Name:lower():match("ovo") then
                        egg = child
                        notify("✅ Ovo encontrado: " .. child.Name)
                        break
                    end
                end
            end
        end
        
        if egg then
            stealEgg()
        end
    end
end

-- Sistema de tecla de atalho (F para roubar)
local function setupHotkey()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            if egg then
                stealEgg()
            else
                notify("🔍 Procurando ovo...")
                findEgg()
            end
        end
    end)
end

-- Interface de controle
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = player.PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BackgroundTransparency = 0.1
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "🥚 Roubo de Ovo"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Parent = Frame
    
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 30)
    Status.Position = UDim2.new(0, 0, 0, 30)
    Status.Text = "Status: Ativo"
    Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    Status.BackgroundTransparency = 1
    Status.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.Position = UDim2.new(0.5, -50, 0, 65)
    Button.Text = "Roubar"
    Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Parent = Frame
    
    Button.MouseButton1Click:Connect(function()
        if egg then
            stealEgg()
        else
            findEgg()
        end
    end)
end

-- Inicialização
local function init()
    print("🥚 Sistema de Roubo de Ovo iniciado!")
    print("🔑 Pressione F para roubar ou clicar no botão")
    print("🛡️ Anti-Botão: " .. (CONFIG.AntiBotEnabled and "Ativado" or "Desativado"))
    
    -- Cria interface
    createUI()
    
    -- Configura hotkey
    setupHotkey()
    
    -- Inicia auto-coletor
    if CONFIG.AutoCollect then
        spawn(autoCollect)
    end
    
    -- Procura ovo inicial
    findEgg()
end

-- Executa
init()

-- Comandos adicionais (digite no console)
_G.steal = stealEgg
_G.findEgg = findEgg
_G.toggleAntiBot = function()
    CONFIG.AntiBotEnabled = not CONFIG.AntiBotEnabled
    notify("🛡️ Anti-Botão: " .. (CONFIG.AntiBotEnabled and "Ativado" or "Desativado"))
end
_G.toggleAutoCollect = function()
    CONFIG.AutoCollect = not CONFIG.AutoCollect
    notify("🔄 Auto-coletor: " .. (CONFIG.AutoCollect and "Ativado" or "Desativado"))
end

print("✅ Script carregado! Comandos: _G.steal(), _G.findEgg(), _G.toggleAntiBot(), _G.toggleAutoCollect()")
