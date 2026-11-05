-- Roblox iOS VR - DEMO de diagnostico (LocalScript)
-- Instale em StarterPlayer > StarterPlayerScripts.
-- NAO desbloqueia VR nativo e NAO rastreia dedos/posicao real das maos.
-- Usa giroscopio do telefone (se disponivel), visualizacao estereo experimental
-- e marcadores de maos simulados controlados por toque/gamepad.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("RobloxIOSVRDemo")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RobloxIOSVRDemo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 30
gui.Parent = playerGui

local function frame(parent, name, pos, size, color)
    local item = Instance.new("Frame")
    item.Name = name
    item.Position = pos
    item.Size = size
    item.BackgroundColor3 = color
    item.BorderSizePixel = 0
    item.Parent = parent
    return item
end

local function textLabel(parent, name, pos, size, value)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = pos
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = value
    label.TextColor3 = Color3.fromRGB(239, 245, 255)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = parent
    return label
end

local function button(parent, name, x, width, value)
    local item = Instance.new("TextButton")
    item.Name = name
    item.Position = UDim2.new(x, 0, 0.12, 0)
    item.Size = UDim2.new(width, -5, 0.76, 0)
    item.BackgroundColor3 = Color3.fromRGB(34, 70, 110)
    item.Text = value
    item.TextColor3 = Color3.fromRGB(255, 255, 255)
    item.TextScaled = true
    item.TextWrapped = true
    item.Font = Enum.Font.GothamBold
    item.BorderSizePixel = 0
    item.Parent = parent
    return item
end

local header = frame(gui, "StatusBar", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.22), Color3.fromRGB(10, 18, 31))
local title = textLabel(header, "Title", UDim2.fromScale(0.01, 0.02), UDim2.fromScale(0.98, 0.28), "ROBLOX iOS | VR LAB")
title.Font = Enum.Font.GothamBold
local diag = textLabel(header, "Diagnostics", UDim2.fromScale(0.01, 0.34), UDim2.fromScale(0.98, 0.61), "Lendo sensores...")
diag.TextColor3 = Color3.fromRGB(170, 231, 250)

local area = frame(gui, "EyeArea", UDim2.fromScale(0, 0.22), UDim2.fromScale(1, 0.61), Color3.fromRGB(5, 8, 14))
local footer = frame(gui, "Controls", UDim2.fromScale(0, 0.83), UDim2.fromScale(1, 0.17), Color3.fromRGB(10, 18, 31))

local splitBtn = button(footer, "Split", 0.01, 0.23, "Estereo ON")
local centerBtn = button(footer, "Center", 0.25, 0.23, "Recentrar")
local leftBtn = button(footer, "LeftHand", 0.49, 0.24, "Mao E")
local rightBtn = button(footer, "RightHand", 0.74, 0.25, "Mao D")

local function viewport(parent, name)
    local item = Instance.new("ViewportFrame")
    item.Name = name
    item.Position = UDim2.fromScale(0, 0)
    item.Size = UDim2.fromScale(1, 1)
    item.BackgroundColor3 = Color3.fromRGB(13, 21, 36)
    item.BorderSizePixel = 0
    item.Ambient = Color3.fromRGB(170, 180, 200)
    item.LightColor = Color3.fromRGB(255, 255, 255)
    item.LightDirection = Vector3.new(-0.5, -1, -0.5)
    item.Parent = parent

    local world = Instance.new("WorldModel")
    world.Parent = item

    local camera = Instance.new("Camera")
    camera.FieldOfView = 78
    camera.Parent = item
    item.CurrentCamera = camera

    local function part(nameOfPart, size, cf, color, shape)
        local p = Instance.new("Part")
        p.Name = nameOfPart
        p.Anchored = true
        p.CanCollide = false
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = Enum.Material.SmoothPlastic
        if shape then p.Shape = shape end
        p.Parent = world
        return p
    end

    part("Piso", Vector3.new(22, 0.14, 26), CFrame.new(0, -0.14, -4), Color3.fromRGB(36, 53, 72))
    for n = -4, 4 do
        part("GradeX", Vector3.new(0.025, 0.025, 23), CFrame.new(n * 2, -0.05, -4), Color3.fromRGB(58, 96, 125))
        part("GradeZ", Vector3.new(18, 0.025, 0.025), CFrame.new(0, -0.05, -4 + n * 2), Color3.fromRGB(58, 96, 125))
    end
    part("AlvoCentral", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 2, -7), Color3.fromRGB(246, 183, 67), Enum.PartType.Ball)
    part("PilarEsquerda", Vector3.new(1, 3, 1), CFrame.new(-4, 1.5, -7), Color3.fromRGB(61, 179, 250))
    part("PilarDireita", Vector3.new(1, 3, 1), CFrame.new(4, 1.5, -7), Color3.fromRGB(226, 99, 173))
    part("PilarFundo", Vector3.new(2, 4, 1), CFrame.new(0, 2, -13), Color3.fromRGB(116, 218, 145))
    local leftHand = part("MaoEsquerdaSimulada", Vector3.new(0.3, 0.32, 0.45), CFrame.new(0, 0, 0), Color3.fromRGB(73, 194, 255), Enum.PartType.Ball)
    local rightHand = part("MaoDireitaSimulada", Vector3.new(0.3, 0.32, 0.45), CFrame.new(0, 0, 0), Color3.fromRGB(255, 126, 175), Enum.PartType.Ball)
    return {viewport = item, camera = camera, handL = leftHand, handR = rightHand}
end

local viewL = viewport(area, "EyeLeft")
local viewR = viewport(area, "EyeRight")
local stereo = true
local handLUp = false
local handRUp = false
local calibration = CFrame.new()
local currentRaw = CFrame.new()
local gyroReadOk = false

local function setStereo(value)
    stereo = value
    viewR.viewport.Visible = stereo
    if stereo then
        viewL.viewport.Size = UDim2.fromScale(0.5, 1)
        viewR.viewport.Position = UDim2.fromScale(0.5, 0)
        viewR.viewport.Size = UDim2.fromScale(0.5, 1)
        splitBtn.Text = "Estereo ON"
    else
        viewL.viewport.Size = UDim2.fromScale(1, 1)
        splitBtn.Text = "Estereo OFF"
    end
end

local function readGyro()
    if not UserInputService.GyroscopeEnabled then
        return nil
    end
    local ok, _, rotation = pcall(function()
        return UserInputService:GetDeviceRotation()
    end)
    if ok and typeof(rotation) == "CFrame" then
        currentRaw = rotation
        gyroReadOk = true
        return rotation
    end
    return nil
end

local function recenter()
    local rotation = readGyro()
    if rotation then
        calibration = rotation
    else
        calibration = CFrame.new()
    end
end

setStereo(true)
recenter()

splitBtn.Activated:Connect(function()
    setStereo(not stereo)
end)
centerBtn.Activated:Connect(recenter)
leftBtn.Activated:Connect(function()
    handLUp = not handLUp
    leftBtn.Text = handLUp and "Mao E alta" or "Mao E"
end)
rightBtn.Activated:Connect(function()
    handRUp = not handRUp
    rightBtn.Text = handRUp and "Mao D alta" or "Mao D"
end)

-- Alguns gamepads enviam L1/R1 pelo Gamepad1.
-- Isso NAO significa que seus giroscopios estejam disponiveis.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.ButtonL1 then
            handLUp = not handLUp
        elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
            handRUp = not handRUp
        end
    end
end)

local lastDiagnostics = 0
local HALF_IPD = 0.11 -- Distancia visual simulada: separacao total de 0.22 stud
RunService.RenderStepped:Connect(function()
    if not gui.Parent then return end
    local sensor = readGyro()
    local relative = sensor and (calibration:Inverse() * sensor) or CFrame.new()
    local head = CFrame.new(0, 2.2, 7) * relative

    for _, view in ipairs({viewL, viewR}) do
        local eyeOffset = 0
        if stereo then
            eyeOffset = view == viewL and -HALF_IPD or HALF_IPD
        end
        view.camera.CFrame = head * CFrame.new(eyeOffset, 0, 0)
        view.handL.CFrame = head * CFrame.new(-0.48, handLUp and -0.16 or -0.63, -1.25)
        view.handR.CFrame = head * CFrame.new(0.48, handRUp and -0.16 or -0.63, -1.25)
    end

    if os.clock() - lastDiagnostics > 0.3 then
        lastDiagnostics = os.clock()
        local gamepads = 0
        local okPads, pads = pcall(function()
            return UserInputService:GetConnectedGamepads()
        end)
        if okPads and type(pads) == "table" then gamepads = #pads end
        local okHead, trackedHead = pcall(function()
            return VRService:GetUserCFrameEnabled(Enum.UserCFrame.Head)
        end)
        local realVR = VRService.VREnabled
        local pitch, yaw = relative:ToOrientation()
        diag.Text = string.format(
            "VR nativo: %s | Head tracked: %s | Giroscopio: %s (leitura: %s)\nGamepads: %d | Olhar: pitch %.0f / yaw %.0f | Maos: simuladas",
            realVR and "SIM" or "NAO",
            (okHead and trackedHead) and "SIM" or "NAO",
            UserInputService.GyroscopeEnabled and "SIM" or "NAO",
            gyroReadOk and "OK" or "N/A",
            gamepads,
            math.deg(pitch),
            math.deg(yaw)
        )
    end
end)

print("[Roblox iOS VR Lab] Demo carregada: estereo simulado, diagnosticos e giroscopio.")
