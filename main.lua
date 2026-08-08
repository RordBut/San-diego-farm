-- RORD | Auto Script
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

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

local ReadTab = Window:Tab({ Title = "Read", Icon = "triangle-alert" })
local MainTab = Window:Tab({ Title = "Auto Farm", Icon = "bot" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "sliders-horizontal" })

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

local function findTarget(keyword)
    local key = string.lower(keyword)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objText = string.lower(prompt.ObjectText or "")
            local actText = string.lower(prompt.ActionText or "")
            local parentName = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if string.find(objText, key) or string.find(actText, key) or string.find(parentName, key) then
                local targetPart = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
                if targetPart:IsA("BasePart") then 
                    return targetPart, prompt
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
                        if dist < minDistance then 
                            minDistance = dist
                            nearestPart = part
                            nearestPrompt = prompt
                        end
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
        local currentSpeed = CONFIG.Speed * speedFactor
                    local direction = (targetPosWithHeight - currentPos)
        bodyVel.Velocity = direction.Unit * currentSpeed
        bodyGyro.CFrame = CFrame.lookAt(currentPos, Vector3.new(targetPosWithHeight.X, currentPos.Y, targetPosWithHeight.Z))
    end)

    while isRunning and not arrived and not rubberbandDetected do
        task.wait(0.01)
    end

    if noclipConnection then noclipConnection:Disconnect() end
    if renderConnection then renderConnection:Disconnect() end
    bodyVel:Destroy()
    bodyGyro:Destroy()
    floatPart:Destroy()

    if movePart and movePart.Parent then
        movePart.AssemblyLinearVelocity = Vector3.zero
        movePart.AssemblyAngularVelocity = Vector3.zero
    end
    if player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    return arrived, rubberbandDetected
end

local function moveToTargetVelocity(targetPart)
    if not targetPart then return false end
    local arrived, rubberband = moveToPositionVelocity(targetPart.Position)
    return arrived
end

local function tweenToInteract(targetPart)
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid then return false end

    local seat = humanoid.SeatPart
    local vehicleModel = getVehicleModel(seat)
    local groundTargetCFrame = targetPart.CFrame + Vector3.new(0, 3, 0)

    if seat and vehicleModel then
        local duration = math.clamp((vehicleModel.PrimaryPart.Position - targetPart.Position).Magnitude / 80, 0.15, 0.8)
        local cframeValue = Instance.new("CFrameValue")
        cframeValue.Value = vehicleModel:GetPivot()
        local tween = TweenService:Create(cframeValue, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = groundTargetCFrame})
        local conn = cframeValue.Changed:Connect(function(newCFrame)
            if vehicleModel and vehicleModel.Parent then
                vehicleModel:PivotTo(newCFrame)
            end
        end)
        tween:Play()
        task.wait(duration)
        conn:Disconnect()
        cframeValue:Destroy()
        if CONFIG.TweenDelay > 0 then task.wait(CONFIG.TweenDelay) end
        dismountVehicle()
        return true
    else
        local duration = math.clamp((hrp.Position - targetPart.Position).Magnitude / 80, 0.15, 0.8)
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = groundTargetCFrame})
        tween:Play()
        task.wait(duration)
        if CONFIG.TweenDelay > 0 then task.wait(CONFIG.TweenDelay) end
        return true
    end
end

local function goToTarget(targetPart)
    local reached = moveToTargetVelocity(targetPart)
    if not reached or not isRunning then return false end
    return tweenToInteract(targetPart)
end

local function processWaypoints(waypoints, labelPrefix)
    local currentIndex = 1
    while isRunning and currentIndex <= #waypoints do
        if currentIndex == 1 then getInVehicle() end
        drawForwardPath(waypoints, currentIndex)
        local targetPos = waypoints[currentIndex]
        local arrived, rubberbandDetected = moveToPositionVelocity(targetPos)
        if rubberbandDetected then
            task.wait(0.3)
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local nearestIdx = getNearestWaypointIndex(waypoints, hrp.Position)
                currentIndex = nearestIdx
                local safeTargetPos = waypoints[nearestIdx] + Vector3.new(0, CONFIG.Height, 0)
                local movePart = hrp
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart then
                    local vModel = getVehicleModel(humanoid.SeatPart)
                    if vModel then movePart = vModel.PrimaryPart or humanoid.SeatPart end
                end
                local recoverTween = TweenService:Create(movePart, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(safeTargetPos)})
                recoverTween:Play()
                recoverTween.Completed:Wait()
                task.wait(0.1)
            end
        elseif arrived then
            currentIndex = currentIndex + 1
        end
    end
    clearWaylines()
end

local function interactWith(targetPart, prompt)
    local activePrompt = prompt 
        or (targetPart and targetPart:FindFirstChildOfClass("ProximityPrompt")) 
        or (targetPart and targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")) 
        or (targetPart and targetPart:FindFirstChildWhichIsA("ProximityPrompt", true))

    if activePrompt then
        activePrompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(activePrompt)
        else
            pcall(function()
                activePrompt:InputHoldBegin()
                task.wait(0.01)
                activePrompt:InputHoldEnd()
            end)
        end
        return true
    end

    local clickDetector = (targetPart and targetPart:FindFirstChildOfClass("ClickDetector")) 
        or (targetPart and targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ClickDetector")) 
        or (targetPart and targetPart:FindFirstChildWhichIsA("ClickDetector", true))

    if clickDetector and fireclickdetector then
        fireclickdetector(clickDetector)
        return true
    end
    return false
end

local function getProcessableItemCount()
    local count = 0
    if player:FindFirstChild("Backpack") then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") and not isProtectedItem(item.Name) then
                count = count + 1
            end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and not isProtectedItem(item.Name) then
                count = count + 1
            end
        end
    end
    return count
end

local function getItemCount(itemName)
    local count = 0
    local key = string.lower(itemName)
    if player:FindFirstChild("Backpack") then
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if string.find(string.lower(item.Name), key) then
                count = count + 1
            end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if string.find(string.lower(item.Name), key) then
                count = count + 1
            end
        end
    end
    return count
end

local function mainLoop()
    local savedBuyPart, savedBuyPrompt = nil, nil

    while isRunning do
        if getItemCount(CONFIG.ItemName) < CONFIG.Amount then
            if not savedBuyPart or not savedBuyPart.Parent then 
                savedBuyPart, savedBuyPrompt = findTarget(CONFIG.ItemName) 
            end

            if savedBuyPart then
                getInVehicle()
                if goToTarget(savedBuyPart) then
                    local buyTimeout = 0
                    while isRunning and getItemCount(CONFIG.ItemName) < CONFIG.Amount and buyTimeout < 40 do
                        interactWith(savedBuyPart, savedBuyPrompt)
                        task.wait(0.05)
                        buyTimeout = buyTimeout + 1
                    end
                    getInVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        if not isRunning then break end
        processWaypoints(postBuyWaypoints, "Post-Buy Route")
        if not isRunning then break end

        if autoSell and getItemCount(CONFIG.ItemName) > 0 then
            local lastBuyPos = postBuyWaypoints[#postBuyWaypoints]
            local sellPart, sellPrompt = findNearestTargetToPos(CONFIG.SellName, lastBuyPos)
            if not sellPart then 
                sellPart, sellPrompt = findNearestTargetToPos("Smuggle", lastBuyPos) 
            end

            if sellPart then
                getInVehicle()
                if goToTarget(sellPart) then
                    local sellAttempts = 0
                    while isRunning and getItemCount(CONFIG.ItemName) > 0 and sellAttempts < 35 do
                        interactWith(sellPart, sellPrompt)
                        task.wait(0.08)
                        sellAttempts = sellAttempts + 1
                    end
                    getInVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        if not isRunning then break end
        processWaypoints(postSellWaypoints, "Post-Sell Route")
        if not isRunning then break end

        if autoLaunder then
            local launderPart, launderPrompt = findTarget(CONFIG.LaunderName)
            if launderPart then
                getInVehicle()
                if goToTarget(launderPart) then
                    local launderAttempts = 0
                    while isRunning and getProcessableItemCount() > 0 and launderAttempts < 40 do
                        interactWith(launderPart, launderPrompt)
                        task.wait(0.08)
                        launderAttempts = launderAttempts + 1
                    end
                    task.wait(0.1)
                    getInVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        task.wait(0.1)
    end
    clearWaylines()
end

ReadTab:Paragraph({ Title = "⚠️ RORD", Content = "Auto Farm for San Diego" })
ReadTab:Paragraph({ Title = "ℹ️", Content = "Configure and start in Auto Farm tab" })

MainTab:Toggle({
    Title = "Auto Farm",
    Desc = "",
    Icon = "power",
    Type = "Toggle",
    Value = isRunning,
    Callback = function(state)
        isRunning = state
        if isRunning then
            task.spawn(mainLoop)
        else
            clearWaylines()
        end
    end
})

MainTab:Toggle({
    Title = "Auto Sell Goods",
    Desc = "",
    Icon = "store",
    Type = "Toggle",
    Value = autoSell,
    Callback = function(state)
        autoSell = state
    end
})

MainTab:Toggle({
    Title = "Auto Launder Cash",
    Desc = "",
    Icon = "banknote",
    Type = "Toggle",
    Value = autoLaunder,
    Callback = function(state)
        autoLaunder = state
    end
})

MainTab:Slider({
    Title = "Fly Speed",
    Desc = "",
    Icon = "gauge",
    Step = 5,
    Value = {
        Min = 150,
        Max = 300,
        Default = CONFIG.Speed,
    },
    Callback = function(value)
        CONFIG.Speed = value
    end
})

MainTab:Slider({
    Title = "Tween Height (Y)",
    Desc = "",
    Icon = "arrow-up-right",
    Step = 0.1,
    Value = {
        Min = 1,
        Max = 5,
        Default = CONFIG.Height,
    },
    Callback = function(value)
        CONFIG.Height = value
    end
})

MainTab:Slider({
    Title = "Target Amount",
    Desc = "",
    Icon = "boxes",
    Step = 1,
    Value = {
        Min = 1,
        Max = 5,
        Default = CONFIG.Amount,
    },
    Callback = function(value)
        CONFIG.Amount = value
    end
})

MainTab:Slider({
    Title = "Tween Delay (s)",
    Desc = "",
    Icon = "timer",
    Step = 0.1,
    Value = {
        Min = 0,
        Max = 5,
        Default = CONFIG.TweenDelay,
    },
    Callback = function(value)
        CONFIG.TweenDelay = value
    end
})

MainTab:Dropdown({
    Title = "Select Item",
    Desc = "",
    Icon = "package-search",
    Values = {
        "Crate Of Avacados",
        "Wagyu Beef",
        "Witches Brew",
        "Fake Designer Sneakers",
        "Fake Diamond Ring"
    },
    Value = CONFIG.ItemName,
    Callback = function(selected)
        CONFIG.ItemName = selected
    end
})

MiscTab:Toggle({
    Title = "Boost FPS",
    Desc = "",
    Icon = "cpu",
    Type = "Toggle",
    Value = fpsBoostActive,
    Callback = function(state)
        applyFPSBoost(state)
    end
})

MiscTab:Toggle({
    Title = "Anti Gameplay Paused",
    Desc = "",
    Icon = "shield-check",
    Type = "Toggle",
    Value = antiPauseActive,
    Callback = function(state)
        applyAntiPause(state)
    end
})

MiscTab:Toggle({
    Title = "No Render",
    Desc = "",
    Icon = "eye-off",
    Type = "Toggle",
    Value = noRenderActive,
    Callback = function(state)
        applyNoRender(state)
    end
})

MiscTab:Toggle({
    Title = "Show Path Line",
    Desc = "Toggle visual path lines on/off",
    Icon = "route",
    Type = "Toggle",
    Value = showPathLine,
    Callback = function(state)
        showPathLine = state
        if not showPathLine then
            clearWaylines()
        end
    end
})

MiscTab:Slider({
    Title = "Path Glow Size",
    Desc = "Adjust line thickness and glow width",
    Icon = "sparkles",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 3.0,
        Default = pathGlowSize,
    },
    Callback = function(value)
        pathGlowSize = value
        updateActiveBeams()
    end
})

MiscTab:Slider({
    Title = "Path Texture Length",
    Desc = "Adjust line pattern stretch length",
    Icon = "ruler",
    Step = 0.1,
    Value = {
        Min = 0.5,
        Max = 10.0,
        Default = pathLength,
    },
    Callback = function(value)
        pathLength = value
        updateActiveBeams()
    end
})

MiscTab:Slider({
    Title = "Path Texture Speed",
    Desc = "Adjust path animation flow speed",
    Icon = "zap",
    Step = 0.1,
    Value = {
        Min = 0.0,
        Max = 10.0,
        Default = pathSpeed,
    },
    Callback = function(value)
        pathSpeed = value
        updateActiveBeams()
    end
})

MiscTab:Colorpicker({
    Title = "Path Gradient Color 1",
    Desc = "First color for animated path gradient",
    Default = pathColor1,
    Callback = function(color)
        pathColor1 = color
    end
})

MiscTab:Colorpicker({
    Title = "Path Gradient Color 2",
    Desc = "Second color for animated path gradient",
    Default = pathColor2,
    Callback = function(color)
        pathColor2 = color
    end
})

print("✅ RORD Auto Farm loaded successfully")
