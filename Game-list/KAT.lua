

-- UI 

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

OrionLib:MakeNotification({
    Name = "Script Loaded!",
    Content = "I already called FBI and sent your IP address to Roblox",
    Image = "rbxassetid://4483345998",
    Time = 5
})

local Window = OrionLib:MakeWindow({ Name = "Spimine/KAT", HidePremium = false, SaveConfig = true, ConfigFolder = "Orion" })

local PlayerTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local EspTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerSection = PlayerTab:AddSection({
    Name = "Aimbot"
})

local EspSection = EspTab:AddSection({
	Name = "ESP"
})

local TS = EspTab:AddSection({
	Name = "Tracers"
})

local Nametag = EspTab:AddSection({
	Name = "Nametags"
})

local Cre = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddParagraph("Note","If you see this ui miss some toggle or features at first run (check if 'First Person' disappear -> run script again)\nidk why this bug appear but it still working tho")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimbotEnabled = false
local aimTarget = "Head"
local aimStyle = "Hold right mouse to Aimbot"
local aiming = false

local function aimAtTarget(target)
    if target and target.Character and target.Character:FindFirstChild(aimTarget) then
        local part = target.Character[aimTarget]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    end
end

local function isInView(point)
    local screenPoint = Camera:WorldToViewportPoint(point)
    return screenPoint.Z > 0 and screenPoint.X > 0 and screenPoint.Y > 0 and screenPoint.X < Camera.ViewportSize.X and screenPoint.Y < Camera.ViewportSize.Y
end

local function getClosestTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimTarget) then
            local part = player.Character[aimTarget]
            if isInView(part.Position) then
                local screenPoint = Camera:WorldToViewportPoint(part.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

local function updateAimbot()
    while aiming do
        local targetPlayer = getClosestTarget()
        if targetPlayer then
            aimAtTarget(targetPlayer)
        end
        wait()
    end
end

UserInputService.InputBegan:Connect(function(input)
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if aimStyle == "Hold right mouse to Aimbot" then
            aiming = true
            updateAimbot()
        elseif aimStyle == "Press right mouse to Auto aimbot" then
            aiming = not aiming
            if aiming then
                updateAimbot()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if aimbotEnabled and aimStyle == "Hold right mouse to Aimbot" and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)


PlayerTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end    
})

PlayerTab:AddDropdown({
    Name = "Aim at",
    Default = "Head",
    Options = {"Head", "Torso"},
    Callback = function(Value)
        aimTarget = Value
    end    
})

PlayerTab:AddDropdown({
    Name = "Choose Style",
    Default = "Hold right mouse to Aimbot",
    Options = {"Hold right mouse to Aimbot", "Press right mouse to Auto aimbot"},
    Callback = function(Value)
        aimStyle = Value
    end    
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local Workspace = game:GetService("Workspace")

local espBoxes = {}
local espHighlights = {}
local espEnabled = false
local espStyle = "Box"
local enemyColor = Color3.fromRGB(255, 0, 0)
local teammateColor = Color3.fromRGB(0, 255, 0)
local murderWeaponColor = Color3.fromRGB(255, 0, 0)
local sheriffWeaponColor = Color3.fromRGB(0, 0, 255)

local headOffset = Vector3.new(0, 1.4, 0)
local feetOffset = Vector3.new(0, 3.4, 0)

local function getPlayerWeaponType(player)
    if player.Backpack then
        for _, item in pairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                if item.Name == "Knife" then
                    return "Knife"
                elseif item.Name == "Gun" then
                    return "Gun"
                end
            end
        end
    end
    return nil
end

local function createOrUpdateEspBox(player, weaponType)
    if not espBoxes[player] then
        espBoxes[player] = Drawing.new("Quad")
        espBoxes[player].Thickness = 2
        espBoxes[player].Transparency = 0.5
    end

    local espBox = espBoxes[player]

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local head = player.Character:FindFirstChild("Head")
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

        if head and humanoidRootPart then
            local headPosition = head.Position + headOffset
            local feetPosition = humanoidRootPart.Position - feetOffset
            local distance = (headPosition - Camera.CFrame.Position).Magnitude
            local headScreenPos, onScreen = Camera:WorldToViewportPoint(headPosition)
            local feetScreenPos = Camera:WorldToViewportPoint(feetPosition)

            if onScreen and headScreenPos.Z > 0 then
                local sizeX = 25 / (distance * 0.02)
                local sizeY = (headPosition.Y - feetPosition.Y) / (distance * 0.02)

                local color = teammateColor
                if player.Team ~= LocalPlayer.Team then
                    color = espStyle == "Box" and enemyColor or (weaponType == "Knife" and murderWeaponColor or sheriffWeaponColor)
                end

                espBox.Color = color
                espBox.PointA = Vector2.new(headScreenPos.X - sizeX, feetScreenPos.Y)
                espBox.PointB = Vector2.new(headScreenPos.X + sizeX, feetScreenPos.Y)
                espBox.PointC = Vector2.new(headScreenPos.X + sizeX, headScreenPos.Y)
                espBox.PointD = Vector2.new(headScreenPos.X - sizeX, headScreenPos.Y)
                espBox.Visible = espEnabled and espStyle == "Box"
            else
                espBox.Visible = false
            end
        else
            espBox.Visible = false
        end
    else
        espBox.Visible = false
    end
end

local function createOrUpdateEspHighlight(player, weaponType)
    if not espHighlights[player] then
        espHighlights[player] = Instance.new("Highlight")
        espHighlights[player].OutlineColor = Color3.fromRGB(255, 255, 255)
        espHighlights[player].OutlineTransparency = 0.5
        espHighlights[player].FillTransparency = 0.5
        espHighlights[player].Parent = player.Character or player.CharacterAdded:Wait()
    end

    local espHighlight = espHighlights[player]

    local function updateHighlight()
        if player.Character then
            local color = teammateColor
            if player.Team ~= LocalPlayer.Team then
                color = weaponType == "Knife" and murderWeaponColor or sheriffWeaponColor
            end

            espHighlight.FillColor = color
            espHighlight.Adornee = player.Character
            espHighlight.Enabled = espEnabled and espStyle == "Highlight"
        else
            espHighlight.Enabled = false
        end
    end

    player.CharacterAdded:Connect(function()
        espHighlight.Parent = player.Character
        updateHighlight()
    end)

    updateHighlight()
end

local function updateEsp()
    local gamemodeValue = Workspace:FindFirstChild("Gamemode")
    local gamemode = gamemodeValue and gamemodeValue.Value or ""

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local weaponType = getPlayerWeaponType(player)

            if espStyle == "Box" then
                createOrUpdateEspBox(player, weaponType)
                if espHighlights[player] then
                    espHighlights[player]:Destroy()
                    espHighlights[player] = nil
                end
            elseif espStyle == "Highlight" then
                createOrUpdateEspHighlight(player, weaponType)
                if espBoxes[player] then
                    espBoxes[player].Visible = false
                    espBoxes[player] = nil
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    updateEsp()
end)

Players.PlayerAdded:Connect(function(player)
    if espStyle == "Box" then
        createOrUpdateEspBox(player, nil)
    elseif espStyle == "Highlight" then
        createOrUpdateEspHighlight(player, nil)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player].Visible = false
        espBoxes[player] = nil
    end

    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end)

EspSection:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        updateEsp()
    end
})


EspSection:AddDropdown({
    Name = "Choose Style",
    Default = "Box",
    Options = {"Box", "Highlight"},
    Callback = function(Value)
        espStyle = Value
        updateEsp()
    end
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local nameTagOffset = Vector3.new(0, 2.2, 0)
local nameTagsEnabled = false
local nameTagHeight = 5

local function createNameTag(player)
    if not nameTagsEnabled then return end 

    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "NameTag"
    nameTag.Size = UDim2.new(0, 100, 0, 50)
    nameTag.AlwaysOnTop = true
    nameTag.Adornee = player.Character:WaitForChild("Head")

    local nameLabel = Instance.new("TextLabel", nameTag)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14

    nameTag.Parent = player.Character.Head


    nameTag.StudsOffset = Vector3.new(0, nameTagHeight, 0) 
end

local function setupNameTags()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            createNameTag(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) 
        createNameTag(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local nameTag = player.Character.Head:FindFirstChild("NameTag")
        if nameTag then
            nameTag:Destroy()
        end
    end
end)


setupNameTags()


RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") then
            local nameTag = player.Character.Head:FindFirstChild("NameTag")
            if not nameTag and nameTagsEnabled then
                createNameTag(player)
            elseif nameTag and not nameTagsEnabled then
                nameTag:Destroy()
            elseif nameTag then
                nameTag.StudsOffset = Vector3.new(0, nameTagHeight, 0)
            end
        end
    end
end)


Nametag:AddToggle({
    Name = "Nametag",
    Default = false,
    Callback = function(Value)
        nameTagsEnabled = Value
        if not Value then
           
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    local nameTag = player.Character.Head:FindFirstChild("NameTag")
                    if nameTag then
                        nameTag:Destroy()
                    end
                end
            end
        else
           
            setupNameTags()
        end
    end
})

Nametag:AddSlider({
    Name = "Nametag Height",
    Min = 0,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        nameTagHeight = Value
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local showDistance = true
local distanceHeight = 5

local function createBillboardGuiForPlayer(player)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "PlayerBillboardGui"
    billboardGui.Adornee = player.Character:WaitForChild("HumanoidRootPart") 
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, distanceHeight, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.LightInfluence = 1
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboardGui.Parent = player.Character.HumanoidRootPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "DistanceLabel"
    textLabel.Text = " "
    textLabel.TextSize = 15.9
    textLabel.Size = UDim2.new(1, 0, 1.8, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(255, 255, 255) 
    textLabel.TextScaled = false
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboardGui
end

local function updatePlayerDistance()
    if not showDistance then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local billboardGui = player.Character.HumanoidRootPart:FindFirstChild("PlayerBillboardGui")
                if billboardGui then
                    billboardGui:Destroy()
                end
            end
        end
        return
    end

    local localCharacter = Players.LocalPlayer.Character
    if not localCharacter then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local billboardGui = player.Character.HumanoidRootPart:FindFirstChild("PlayerBillboardGui")

            if billboardGui then
                billboardGui.DistanceLabel.Text = " " .. math.floor(distance) .. "m"
                billboardGui.StudsOffset = Vector3.new(0, distanceHeight, 0)
            else
                createBillboardGuiForPlayer(player)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) 
        createBillboardGuiForPlayer(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local billboardGui = player.Character.HumanoidRootPart:FindFirstChild("PlayerBillboardGui")
        if billboardGui then
            billboardGui:Destroy()
        end
    end
end)


RunService.RenderStepped:Connect(updatePlayerDistance)


for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createBillboardGuiForPlayer(player)
    end
end


Nametag:AddToggle({
    Name = "Show Distance",
    Default = false,
    Save = true,
    Flag = "toggle",
    Callback = function(value)
        showDistance = value
        updatePlayerDistance()
    end
})

Nametag:AddSlider({
    Name = "Distance Height",
    Min = 0,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "%",
    Callback = function(value)
        distanceHeight = value
        updatePlayerDistance() 
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local isFirstPerson = false

PlayerTab:AddBind({
	Name = "First Person - Required",
	Default = Enum.KeyCode.Q,
	Hold = false,
	Callback = function()
		if isFirstPerson then
			player.CameraMode = Enum.CameraMode.Classic
			isFirstPerson = false
		else
			player.CameraMode = Enum.CameraMode.LockFirstPerson
			isFirstPerson = true
		end
	end    
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera

local localPlayer = Players.LocalPlayer

_G.TracersEnabled = false
_G.TracerColor = Color3.fromRGB(0, 255, 0) 
local function createTracer(target)
    local tracer = Drawing.new("Line")
    tracer.Color = _G.TracerColor
    tracer.Thickness = 2
    tracer.Transparency = 1
    tracer.Visible = true

    local function update()
        if not _G.TracersEnabled or not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            tracer.Visible = false
            return
        end

        local targetPos = target.Character.HumanoidRootPart.Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        
        if onScreen then
            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            tracer.Visible = true
        else
            tracer.Visible = false
        end
    end

    RunService.RenderStepped:Connect(update)

    Players.PlayerRemoving:Connect(function(player)
        if player == target then
            tracer:Remove()
        end
    end)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        createTracer(player)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        createTracer(player)
    end
    onPlayerAdded(player)
end


TS:AddToggle({
    Name = "Tracers",
    Default = false,
    Save = true,
    Flag = "toggle",
    Callback = function(state)
        _G.TracersEnabled = state
    end
})

Cre:AddLabel("Scripter/Tester: SadSpillMine on Roblox")
Cre:AddLabel("Last Update: 17/07/2024")

OrionLib:Init()
