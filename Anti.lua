-- A Simple Anti-Cheat System for any Roblox Studio Prodject
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local banStore = DataStoreService:GetDataStore("BanList")

-- Function to ban players
local function banPlayer(player, reason)
    banStore:SetAsync(player.UserId, true)
    player:Kick("You have been banned for exploiting: " .. reason)
end

-- Check if player is banned on join
Players.PlayerAdded:Connect(function(player)
    local isBanned = banStore:GetAsync(player.UserId)
    if isBanned then
        player:Kick("You are banned from this game.")
    end
end)

-- Monitor Remote Events for Exploits
ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(player, data)
    if typeof(data) ~= "table" or #data > 10 then
        banPlayer(player, "Suspicious remote event activity.")
    end
end)

-- Speed Hack Detection
local function detectSpeedHack(player)
    player.CharacterAdded:Connect(function(character)
        local root = character:WaitForChild("HumanoidRootPart")
        local lastPosition = root.Position

        RunService.Heartbeat:Connect(function()
            if root then
                local distance = (root.Position - lastPosition).Magnitude
                if distance > 100 then -- Adjust threshold as needed
                    banPlayer(player, "Speed hacking detected.")
                end
                lastPosition = root.Position
            end
        end)
    end)
end

-- Anti-Noclip Check
local function detectNoclip(player)
    RunService.Stepped:Connect(function()
        if player.Character and player.Character.PrimaryPart then
            for _, part in pairs(workspace:GetPartsInPart(player.Character.PrimaryPart)) do
                if part:IsA("BasePart") and part.CanCollide then
                    banPlayer(player, "Noclip detected.")
                end
            end
        end
    end)
end

-- Anti-Fast Execution Exploit
local function detectFastExecution(player)
    local start = tick()
    task.wait(1)
    if tick() - start < 0.9 then
        banPlayer(player, "Exploit detected: Unnatural script execution speed.")
    end
end

-- Connect detections on player join
Players.PlayerAdded:Connect(function(player)
    detectSpeedHack(player)
    detectNoclip(player)
    detectFastExecution(player)
end)

print("Anti-cheat system loaded.")
