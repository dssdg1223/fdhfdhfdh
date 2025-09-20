local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ↓ WindUI
local Version = "1.6.41"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "GOJO HUB | Brookhaven",
    Icon = "door-open",
    Author = "by ghost626262628",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("User clicked")
        end,
    },
})

local Tab = Window:Tab({
    Title = "Comandos",
    Icon = "bird",
    Locked = false,
})

-- Configurações do Firebase
local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"
local player = Players.LocalPlayer
local playerName = player.Name

-- Função para enviar chat local e global
local function SendChat(msg)
    -- Chat local
    pcall(function()
        player:Chat(msg)
    end)
    
    -- Chat global
    pcall(function()
        local ChatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
        ChatEvent:FireServer(msg, "All")
    end)
end

-- Função que checa comando "verifique" no Firebase
local function checkVerifiqueCommand()
    local success, response = pcall(function()
        local url = firebaseUrl .. "commands/verifique.json?auth=" .. secretKey
        return game:HttpGet(url)
    end)

    if success and response and response ~= "null" then
        -- Comando encontrado, envia "oi" no chat
        SendChat("oi")

        -- Apaga o comando do Firebase
        pcall(function()
            local deleteUrl = firebaseUrl .. "commands/verifique.json?auth=" .. secretKey
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = deleteUrl,
                    Method = "DELETE",
                    Headers = { ["Content-Type"] = "application/json" },
                })
                print("[GOJO HUB] Comando verifique removido do Firebase.")
            end
        end)
    end
end

-- Adiciona botão na WindUI para verificar manualmente
Tab:Button({
    Name = "Verifique",
    Description = "Checa o comando 'verifique' no Firebase e envia 'oi' no chat",
    Callback = function()
        checkVerifiqueCommand()
    end,
})

-- Loop contínuo para verificar a flag global ou automático
RunService.RenderStepped:Connect(function()
    if _G.SendGojoChat then
        SendChat("GOJO_user")
        _G.SendGojoChat = false
    end

    -- Você pode ativar a verificação automática se quiser
    -- checkVerifiqueCommand()
end)
