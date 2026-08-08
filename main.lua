-- RORD | Auto Script

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Custom Theme
WindUI:AddTheme({
    Name = "RORD",
    Accent = Color3.fromHex("#ff6b00"),
    Background = Color3.fromHex("#0a0a0a"),
    BackgroundTransparency = 0,
    Outline = Color3.fromHex("#ff6b00"),
    Text = Color3.fromHex("#ffffff"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#1a1a1a"),
    Icon = Color3.fromHex("#ff6b00"),
    Hover = Color3.fromHex("#2a2a2a"),
    WindowBackground = Color3.fromHex("#0a0a0a"),
    WindowShadow = Color3.fromHex("#ff6b00"),
    DialogBackground = Color3.fromHex("#0a0a0a"),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromHex("#ffffff"),
    DialogContent = Color3.fromHex("#ffffff"),
    DialogIcon = Color3.fromHex("#ff6b00"),
    WindowTopbarButtonIcon = Color3.fromHex("#a1a1aa"),
    WindowTopbarTitle = Color3.fromHex("#ffffff"),
    WindowTopbarAuthor = Color3.fromHex("#ffffff"),
    WindowTopbarIcon = Color3.fromHex("#ff6b00"),
    TabBackground = Color3.fromHex("#0a0a0a"),
    TabTitle = Color3.fromHex("#ffffff"),
    TabIcon = Color3.fromHex("#ff6b00"),
    ElementBackground = Color3.fromHex("#141414"),
    ElementTitle = Color3.fromHex("#ffffff"),
    ElementDesc = Color3.fromHex("#A1A1AA"),
    ElementIcon = Color3.fromHex("#ff6b00"),
    PopupBackground = Color3.fromHex("#0a0a0a"),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromHex("#ffffff"),
    PopupContent = Color3.fromHex("#ffffff"),
    PopupIcon = Color3.fromHex("#a1a1aa"),
    Toggle = Color3.fromHex("#ff6b00"),
    ToggleBar = Color3.fromHex("#ffffff"),
    Checkbox = Color3.fromHex("#52525b"),
    CheckboxIcon = Color3.fromHex("#ffffff"),
    Slider = Color3.fromHex("#ff6b00"),
    SliderThumb = Color3.fromHex("#ffffff"),
})

-- Window
local Window = WindUI:CreateWindow({
    Title = "⚡ RORD",
    Icon = "monitor",
    Author = "RORD",
    Folder = "Rord",
    Size = UDim2.fromOffset(580, 460),
    Transparent = false,
    Theme = "RORD",
    SideBarWidth = 170,
    HasOutline = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() print("RORD activated") end,
    },
})

Window:EditOpenButton({
    Title = "⚡ RORD",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("ff6b00"), 
        Color3.fromHex("ffffff")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "v3.0",
    Icon = "github",
    Color = Color3.fromHex("#ff6b00"),
    Radius = 10,
})

-- Tabs
local ReadTab = Window:Tab({ Title = "Read", Icon = "triangle-alert" })
local MainTab = Window:Tab({ Title = "Auto Farm", Icon = "bot" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "sliders-horizontal" })

-- Variables
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local isRunning = false
local autoSell = true
local autoLaunder = true
local fpsBoostActive = false
local antiPauseActive = false
local noRenderActive = false
local showPathLine = true
local pathColor1 = Color3.fromHex("#ff6b00")
local pathColor2 = Color3.fromHex("#ffffff")
local pathGlowSize = 1.2
local pathLength = 6.5
local pathSpeed = 0
local lastVehicle = nil

local CONFIG = {
    Speed = 250,
    Height = 2.5,
    Amount = 5,
    TweenDelay = 0.1,
    ItemName = "Fake Diamond Ring",
    SellName = "Smuggle Goods Seller",
    LaunderName = "Launder Cash"
}

local PROTECTED_ITEMS = { ["fists"] = true, ["passport"] = true }
local function isProtectedItem(name) return PROTECTED_ITEMS[string.lower(name)] == true end

local postBuyWaypoints = {
    Vector3.new(6837.8, 17.2, 30.7),
    Vector3.new(6843.8, 17.2, 101.4),
    Vector3.new(2785.6, 17.2, 94.8),
    Vector3.new(2669.2, 17.2, 111.6),
    Vector3.new(97.4, 17.2, 112.9),
    Vector3.new(54.6, 17.2, 341.1),
    Vector3.new(-124.1, 17.2, 394.1),
    Vector3.new(-101.3, 17.2, 505.4),
    Vector3.new(13.0, 17.2, 494.9),
    Vector3.new(44.5, 17.2, 431.0),
    Vector3.new(47.6, 33.3, 563.5),
    Vector3.new(29.3, 33.3, 424.0),
    Vector3.new(42.9, 49.3, 561.7),
    Vector3.new(-80.5, 49.3, 428.5)
}

local postSellWaypoints = {
    Vector3.new(-33.5, 49.3, 429.2),
    Vector3.new(-24.6, 53.5, 405.4),
    Vector3.new(23.4, 17.2, 348.7),
    Vector3.new(169.1, 17.2, 148.7),
    Vector3.new(2848.5, 17.2, 159.6),
    Vector3.new(6867.7, 17.2, 133.0),
    Vector3.new(6832.1, 17.4, -41.5),
    Vector3.new(6805.6, 17.4, -34.4)
}

-- Path system
local pathFolder = workspace:FindFirstChild("RORD_Path") or Instance.new("Folder")
pathFolder.Name = "RORD_Path"
pathFolder.Parent = workspace

local activePathObjects = {}
local activeBeamsList = {}
local pathAnimConnection = nil

local function clearWaylines()
    if pathAnimConnection then pathAnimConnection:Disconnect(); pathAnimConnection = nil end
    for _, obj in ipairs(activePathObjects) do if obj and obj.Parent then obj:Destroy() end end
    activePathObjects = {}; activeBeamsList = {}; pathFolder:ClearAllChildren()
end

local function updateActiveBeams()
    for _, item in ipairs(activeBeamsList) do
        if item.Beam and item.Beam.Parent then
            item.Beam.Width0 = pathGlowSize; item.Beam.Width1 = pathGlowSize
            item.Beam.TextureLength = pathLength; item.Beam.TextureSpeed = pathSpeed
        end
    end
end

local function drawForwardPath(waypoints, currentIndex)
    clearWaylines()
    if not showPathLine or not waypoints or currentIndex > #waypoints then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pointsToDraw = { hrp.Position }
    for i = currentIndex, #waypoints do table.insert(pointsToDraw, waypoints[i]) end

    activeBeamsList = {}
    for i = 1, #pointsToDraw - 1 do
        local pA, pB = pointsToDraw[i], pointsToDraw[i+1]
        local partA = Instance.new("Part"); partA.Size = Vector3.new(0.1,0.1,0.1); partA.Position = pA; partA.Anchored = true; partA.CanCollide = false; partA.Transparency = 1; partA.Parent = pathFolder
        local partB = Instance.new("Part"); partB.Size = Vector3.new(0.1,0.1,0.1); partB.Position = pB; partB.Anchored = true; partB.CanCollide = false; partB.Transparency = 1; partB.Parent = pathFolder
        local attA = Instance.new("Attachment", partA); local attB = Instance.new("Attachment", partB)
        local beam = Instance.new("Beam"); beam.Attachment0 = attA; beam.Attachment1 = attB
        beam.Texture = "rbxassetid://446111271"; beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureLength = pathLength; beam.TextureSpeed = pathSpeed
        beam.Width0 = pathGlowSize; beam.Width1 = pathGlowSize
        beam.Transparency = NumberSequence.new(0); beam.FaceCamera = true; beam.LightEmission = 1; beam.LightInfluence = 0
        beam.Parent = pathFolder
        table.insert(activePathObjects, partA); table.insert(activePathObjects, partB); table.insert(activePathObjects, beam)
        table.insert(activeBeamsList, {Beam = beam, Index = i})
    end

    pathAnimConnection = RunService.RenderStepped:Connect(function()
        local speed = 0.5; local offset = (tick() * speed) % 1
        for _, item in ipairs(activeBeamsList) do
            if item.Beam and item.Beam.Parent then
                local factorA = math.sin((offset + (item.Index * 0.1)) * math.pi * 2) * 0.5 + 0.5
                local factorB = math.sin((offset + ((item.Index + 1) * 0.1)) * math.pi * 2) * 0.5 + 0.5
                local cA = pathColor1:Lerp(pathColor2, factorA)
                local cB = pathColor1:Lerp(pathColor2, factorB)
                item.Beam.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, cA),
                    ColorSequenceKeypoint.new(1, cB)
                })
            end
        end
    end)
end

-- Movement & interaction functions
local function applyAntiPause(state)
    antiPauseActive = state
    if state then
        pcall(function()
            local pauseScript = game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
            if pauseScript then pauseScript:Destroy() end
        end)
    end
end

local function applyNoRender(state)
    noRenderActive = state
    if state then RunService:Set3dRenderingEnabled(false) else RunService:Set3dRenderingEnabled(true) end
end

local originalLightingSettings = {}
local fpsConnections = {}

local function stripCharacter(char)
    if not char then return end
    local children = char:GetChildren()
    for i = #children, 1, -1 do
        local item = children[i]
        if item:IsA("Accessory") or item:IsA("Clothing") or item:IsA("ShirtGraphic") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("CharacterMesh") then
            pcall(function() item:Destroy() end)
        end
    end
end

local function optimizeInst(v)
    if not v then return end
    pcall(function()
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false; v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Light") then
            v.Enabled = false
        end
    end)
end

local function applyFPSBoost(state)
    fpsBoostActive = state
    if state then
        originalLightingSettings.GlobalShadows = Lighting.GlobalShadows
        originalLightingSettings.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLightingSettings.Ambient = Lighting.Ambient
        originalLightingSettings.FogEnd = Lighting.FogEnd
        originalLightingSettings.Technology = Lighting.Technology

        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
        Lighting.Ambient = Color3.fromRGB(15,15,15)
        Lighting.FogEnd = 9e9
        pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)

        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("PostEffect") or child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect") then
                pcall(function() child:Destroy() end)
            end
        end

        local darkSky = Instance.new("Sky")
        darkSky.Name = "FPSBoostSky"; darkSky.SkyboxBk = "rbxassetid://0"; darkSky.SkyboxDn = "rbxassetid://0"
        darkSky.SkyboxFt = "rbxassetid://0"; darkSky.SkyboxLf = "rbxassetid://0"; darkSky.SkyboxRt = "rbxassetid://0"
        darkSky.SkyboxUp = "rbxassetid://0"; darkSky.SkyboxColor = Color3.fromRGB(10,10,10)
        darkSky.Parent = Lighting

        for _, v in ipairs(workspace:GetDescendants()) do optimizeInst(v) end

        local connAdded = workspace.DescendantAdded:Connect(function(v)
            if fpsBoostActive then task.wait(); optimizeInst(v) end
        end)
        table.insert(fpsConnections, connAdded)

        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then stripCharacter(p.Character) end
            local connChar = p.CharacterAdded:Connect(function(char)
                if fpsBoostActive then
                    char:WaitForChild("Humanoid", 5); task.wait(0.2); stripCharacter(char)
                end
            end)
            table.insert(fpsConnections, connChar)
        end
    else
        for _, conn in ipairs(fpsConnections) do if conn then conn:Disconnect() end end
        fpsConnections = {}
        Lighting.GlobalShadows = originalLightingSettings.GlobalShadows or true
        Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient or Color3.fromRGB(128,128,128)
        Lighting.Ambient = originalLightingSettings.Ambient or Color3.fromRGB(128,128,128)
        local currentSky = Lighting:FindFirstChild("FPSBoostSky")
        if currentSky then currentSky:Destroy() end
    end
end

-- Target finders
local function findTarget(keyword)
    local key = string.lower(keyword)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objText = string.lower(prompt.ObjectText or "")
            local actText = string.lower(prompt.ActionText or "")
            local parentName = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if string.find(objText, key) or string.find(actText, key) or string.find(parentName, key) then
                local targetPart = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
                if targetPart:IsA("BasePart") then return targetPart, prompt
                elseif targetPart:IsA("Model") then
                    local part = targetPart.PrimaryPart or targetPart:FindFirstChildWhichIsA("BasePart", true)
                    if part then return part, prompt end
                end
            end
        end
    end
    return nil, nil
end

local function findNearestTargetToPos(keyword, pos)
    local key = string.lower(keyword)
    local nearestPart, nearestPrompt = nil, nil
    local minDistance = math.huge
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objText = string.lower(prompt.ObjectText or "")
            local actText = string.lower(prompt.ActionText or "")
            local parentName = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if string.find(objText, key) or string.find(actText, key) or string.find(parentName, key) then
                local targetPart = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
                if targetPart then
                    local part = targetPart:IsA("BasePart") and targetPart or targetPart.PrimaryPart or targetPart:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local dist = (pos - part.Position).Magnitude
                        if dist < minDistance then minDistance = dist; nearestPart = part; nearestPrompt = prompt end
                    end
                end
            end
        end
    end
    return nearestPart, nearestPrompt
end

local function getVehicleModel(seat)
    if not seat then return nil end
    local current = seat
    local vehicleModel = nil
    while current and current ~= workspace do
        if current:IsA("Model") then vehicleModel = current end
        current = current.Parent
    end
    return vehicleModel
end

local function dismountVehicle()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if humanoid and humanoid.SeatPart then
        lastVehicle = getVehicleModel(humanoid.SeatPart)
        if lastVehicle then
            for _, part in ipairs(lastVehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            local primary = lastVehicle.PrimaryPart or lastVehicle:FindFirstChildWhichIsA("BasePart", true)
            if primary then primary.Anchored = true end
        end
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        humanoid.Sit = false
        task.wait(0.1)
        if hrp and lastVehicle then
            local primary = lastVehicle.PrimaryPart or lastVehicle:FindFirstChildWhichIsA("BasePart", true)
            if primary then hrp.CFrame = primary.CFrame * CFrame.new(0, 5, 0) end
        end
    end
end

local function getInVehicle()
    if not lastVehicle or not lastVehicle.Parent then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid then return end

    local primary = lastVehicle.PrimaryPart or lastVehicle:FindFirstChildWhichIsA("BasePart", true)
    if primary then primary.Anchored = false end

    if humanoid.SeatPart then return end
    local seat = lastVehicle:FindFirstChildWhichIsA("VehicleSeat", true) or lastVehicle:FindFirstChildWhichIsA("Seat", true)
    if seat then
        hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        seat:Sit(humanoid)
        task.wait(0.2)
    end
end

local function getNearestWaypointIndex(waypoints, currentPos)
    local closestIdx = 1; local minDist = math.huge
    for i, wp in ipairs(waypoints) do
        local dist = (Vector3.new(currentPos.X, wp.Y, currentPos.Z) - wp).Magnitude
        if dist < minDist then minDist = dist; closestIdx = i end
    end
    return closestIdx
end

local function moveToPositionVelocity(targetPos)
    local char = player.Character
    if not char then return false, false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid then return false, false end

    local seat = humanoid.SeatPart
    local vehicleModel = getVehicleModel(seat)
    local movePart = (seat and vehicleModel) and (vehicleModel.PrimaryPart or seat) or hrp
    if not movePart then return false, false end

    local floatPart = Instance.new("Part")
    floatPart.Name = "RORD_Float"
    floatPart.Size = Vector3.new(30, 1, 30)
    floatPart.Anchored = true; floatPart.CanCollide = true; floatPart.Transparency = 1
    floatPart.Parent = workspace

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    bodyVel.Velocity = Vector3.zero; bodyVel.Parent = movePart

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    bodyGyro.P = 10000; bodyGyro.CFrame = movePart.CFrame; bodyGyro.Parent = movePart

    local noclipConnection = RunService.Stepped:Connect(function()
        if not isRunning then return end
        if movePart and movePart.Parent then floatPart.CFrame = movePart.CFrame * CFrame.new(0, -3.5, 0) end
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= floatPart then part.CanCollide = false end
            end
        end
        if vehicleModel then
            for _, part in ipairs(vehicleModel:GetDescendants()) do
                if part:IsA("BasePart") and part ~= floatPart then part.CanCollide = false end
            end
        end
    end)

    local targetPosWithHeight = Vector3.new(targetPos.X, targetPos.Y + CONFIG.Height, targetPos.Z)
    local arrived = false; local rubberbandDetected = false
    local previousPos = movePart.Position
    local stopThreshold = math.clamp(CONFIG.Speed * 0.04, 6, 15)

    local renderConnection = RunService.Heartbeat:Connect(function()
        if not isRunning or not movePart or not movePart.Parent then arrived = false; return end
        local currentPos = movePart.Position
        local moveDelta = (currentPos - previousPos).Magnitude
        local distToTarget = (targetPosWithHeight - currentPos).Magnitude
        if moveDelta > 45 and distToTarget > 20 then rubberbandDetected = true; bodyVel.Velocity = Vector3.zero; return end
        previousPos = currentPos
        if distToTarget <= stopThreshold then arrived = true; return end
        local speedFactor = math.clamp(distToTarget / 40, 0.25, 1)
        local currentSpeed = CONFIG.Speed
