duration = 999
duration *= 3600

local player = game.Players.LocalPlayer
local char = player.Character
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local radius = 300
local origin = Vector3.new(-27150, -492, -11000)
local divisions = 108
local waitTime = 0.2
local velDir = Vector3.zero
local velSpeed = 100
local breakDelay = 1.5
local jumpDelay = 0.1
local turnAngle = math.rad(360 / divisions)
local pointsTable = {}
local doingCycle = false
local queueBreak = false
local PAUSED = false

char.scripts.movement.cst.Enabled = false
char.scripts.movement.jump_v4.Enabled = false

for i = 1, divisions do
    pointsTable[i] = origin + Vector3.new(math.cos(i * turnAngle), 0, math.sin(i * turnAngle)) * radius
    task.wait()
end

hrp.CFrame = CFrame.new(pointsTable[1])

local ground = Instance.new("Part")
ground.Parent = workspace
ground.CFrame = CFrame.new(origin + Vector3.new(0, -5, 0))
ground.Size = Vector3.new(2 * radius + 10, 1, 2 * radius + 10)
ground.Anchored = true

player.CharacterAdded:Connect(function()
    char = player.Character
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    char.scripts.movement.cst.Enabled = false
    char.scripts.movement.jump_v4.Enabled = false

    hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
        if hum.FloorMaterial == Enum.Material.Air or queueBreak or PAUSED then return end
        task.wait(jumpDelay)
        hum.JumpPower = 23
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if doingCycle or queueBreak or PAUSED then return end

    doingCycle = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    hrp.CFrame = CFrame.new(origin)

    for i, v in ipairs(pointsTable) do
        if queueBreak or PAUSED then
            velDir = Vector3.zero
            break
        end

        hrp.CFrame = CFrame.new(v * Vector3.new(1, 0, 1) + hrp.CFrame.Position * Vector3.new(0, 1, 0))
        velDir = ((pointsTable[i + 1] or pointsTable[1]) - pointsTable[i]).Unit
        task.wait(waitTime)
    end

    doingCycle = false
end)

game:GetService("RunService").RenderStepped:Connect(function()
    hrp.AssemblyLinearVelocity = Vector3.new(velDir.X * velSpeed, hrp.AssemblyLinearVelocity.Y, velDir.Z * velSpeed)
end)

hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
    if hum.FloorMaterial == Enum.Material.Air or queueBreak or PAUSED then return end
    task.wait(jumpDelay)
    hum.JumpPower = 23
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

player:GetAttributeChangedSignal("high_speed"):Connect(function()
    local hs = player:GetAttribute("high_speed")
    if hs == 16 then
        velSpeed = 65
    elseif hs == 0 then
        velSpeed = 100
    end
end)

game:GetService("ReplicatedStorage").events.player["local"].bonuspoints.OnClientEvent:Connect(function(type, value, message)
    if message == "bhop chain complete" then
        queueBreak = true
        task.wait(breakDelay)
        queueBreak = false
    end
end)

local currentEvent = game:GetService("ReplicatedStorage").values.events.currentevent
currentEvent:GetPropertyChangedSignal("Value"):Connect(function()
    if currentEvent.Value == "dolly" then
        PAUSED = true
        game:GetService("ReplicatedStorage").events.player.char.respawnchar:FireServer()
        return
    end
    PAUSED = false
end)


local blacklist = {
    897308029, 714146942, 1477284162
}

whitelist = {
    4111568109, 7937564209
}

game.Players.PlayerAdded:Connect(function(newPlayer)
    local shouldReturn = false

    for _, v in ipairs(whitelist) do
        if newPlayer.UserId == v then
            shouldReturn = true
            break
        end
    end

    if shouldReturn then return end

    for _, v in ipairs(blacklist) do
        if newPlayer.UserId == v then
            player:Kick("Eww Bad Guy: A Blacklisted User Joined Your Experience, " .. newPlayer.Name)
            return
        end
    end

    for _, v in ipairs(game.ReplicatedStorage.leaderboards.xp:GetChildren()) do
        if tonumber(v.Name) == newPlayer.UserId then
            player:Kick("Eww Level Guy: Yuck, " .. newPlayer.Name)
            return
        end
        task.wait()
    end

    local backpack = newPlayer:WaitForChild("Backpack")
    backpack.ChildAdded:Connect(function(child)
        if child.Name == "Possessor" then
            player:Kick("Eww Possessor Guy: A User Has Equipped Possessor. Goodbye!, " .. newPlayer.Name)
        end
    end)

    newPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        if newPlayer.Team == player.Team then
            player:Kick("Eww Stalker: GET AWAY FROM ME, " .. newPlayer.Name)
        end
    end)
end)

startTime = tick()
game:GetService("RunService").RenderStepped:Connect(function()
    if tick() - startTime > duration then
        player:Kick("wake up sleepyhead")
    end
end)

hum.HealthChanged:Connect(function(hp)
    player:Kick("loser.....")
end)
