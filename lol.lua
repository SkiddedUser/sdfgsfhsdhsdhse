local sword = LoadAssets(107336795603349):Get("Crescendo")
    sword.Parent = character

    -- Crear y configurar el sonido
    local theme = Instance.new("Sound")
    theme.Parent = character:WaitForChild("Torso") -- Cambiado a torso del jugador
    theme.SoundId = "rbxassetid://18550614625"
    theme.Looped = true
    theme.Playing = true
    theme.PlaybackSpeed = 1
    theme.Volume = 0.8

    local handle = sword:WaitForChild("Handle")

    -- Hacer las partes de la espada sin masa
    for _, v in pairs(sword:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Massless = true
        end
    end

    -- Crear el weld para la espada
    local weld = Instance.new("Motor6D")
    weld.Parent = character:WaitForChild("Right Arm")
    weld.Part0 = character:WaitForChild("Right Arm")
    weld.Part1 = handle
    weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), math.rad(0), 0) -- Ajustado para que la espada apunte hacia adelante

    -- Configurar el tiempo de animación
    local equipTimeVertical = 6.0 -- Tiempo en el aire
    local returnTime = 3.8 -- Tiempo para regresar a la posición normal
    local startTime = tick()

    local function animateIdleSword()
        local time = tick()
        local basePosition = CFrame.new(0, -1, 0)
        
        local offsetY = math.sin(time * 2) * 0.1
        local offsetZ = math.cos(time * 1.5) * 0.05
        local rotationX = math.sin(time) * math.rad(5)
        local rotationZ = math.cos(time * 0.7) * math.rad(3)
        
        local newCFrame = basePosition 
            * CFrame.new(0, offsetY, offsetZ) 
            * CFrame.Angles(math.rad(-90), 0, 0) -- Rotación en idle
        
        weld.C0 = newCFrame
    end

    local function animateEquipSword()
        local currentTime = tick() - startTime

        if currentTime <= equipTimeVertical then
            -- Giros verticales rápidos y largos
            local alpha = currentTime / equipTimeVertical
            local easedAlpha = math.sin(alpha * math.pi * 0.5)
            local rotationX = easedAlpha * math.pi * 16 -- 8 rotaciones completas

            local verticalCFrame = CFrame.new(0, -1, 0) * CFrame.Angles(rotationX, 0, 0)
            weld.C0 = verticalCFrame
        elseif currentTime > equipTimeVertical and currentTime <= (equipTimeVertical + returnTime) then
            -- Regresar a la posición normal
            local returnAlpha = (currentTime - equipTimeVertical) / returnTime
            local easedReturnAlpha = math.sin(returnAlpha * math.pi * 0.5) -- Interpolación suave

            -- Posición normal ahora es la de idle
            local idleCFrame = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)

            -- Interpolación entre las posiciones
            local currentCFrame = weld.C0
            weld.C0 = currentCFrame:lerp(idleCFrame, easedReturnAlpha) -- Interpolación correcta
        else
            -- Asegurarse de que la espada termine en la posición normal
            weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0) -- Ajusta para que apunte hacia adelante
            
            -- Llamar a la función de idle inmediatamente
            animateIdleSword()
        end
    end

    -- Conectar la función de animación al Heartbeat
    RunService.Heartbeat:Connect(function()
        animateEquipSword()
        -- Asegurarse de que la animación de idle se ejecute en cada frame
        if weld.C0 == CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0) then
            animateIdleSword()
        end
    end)
-- Conectar la función de animación al Heartbeat
local animationConnection = RunService.Heartbeat:Connect(animateSword)
local Eyes = sword:FindFirstChild("Handle"):FindFirstChild("Crescendo"):FindFirstChild("Eyes")
local Eye_Normal1 = Eyes:FindFirstChild("Eye_Normal")
local Eye_Normal2 = Eyes:FindFirstChild("Eye_Normal2")

-- Validar que los grupos de ojos existen
if not Eye_Normal1 or not Eye_Normal2 then
	error("No se encontraron los grupos Eye_Normal1 o Eye_Normal2 en el objeto Eyes.")
end

-- Función para encontrar las partes de los ojos
local function findEyeParts(eyeGroup)
	local base = eyeGroup:FindFirstChild("Base")
	if not base then
		error("No se pudo encontrar el objeto Base en el grupo: " .. eyeGroup.Name)
	end

	local center = base:FindFirstChild("Center")
	local left = base:FindFirstChild("Left")
	local right = base:FindFirstChild("Right")

	if not (center and left and right) then
		error("No se pudieron encontrar todos los objetos en Base dentro del grupo de ojos: " .. eyeGroup.Name)
	end

	return base, center, left, right
end

-- Buscar las partes de los ojos en Eye_Normal1 y Eye_Normal2
local Base1, Center1, Left1, Right1
local Base2, Center2, Left2, Right2

-- Manejar posibles errores en la búsqueda de partes
local success1, result1 = pcall(function()
	Base1, Center1, Left1, Right1 = findEyeParts(Eye_Normal1)
end)
if not success1 then
	error("Error al encontrar partes en Eye_Normal1: " .. result1)
end

local success2, result2 = pcall(function()
	Base2, Center2, Left2, Right2 = findEyeParts(Eye_Normal2)
end)
if not success2 then
	error("Error al encontrar partes en Eye_Normal2: " .. result2)
end

-- Función para agitar un objeto (Base o partes de los ojos)
local function shakeObject(object)
	local originalPosition = object.Position
	while true do
		local offsetX = math.random(-1, 0.7) * 1
		local offsetY = math.random(-1, 0.7) * 1
		object.Position = originalPosition + UDim2.new(0, offsetX, 0, offsetY)
		wait(0.025)
	end
end

-- Función para mover los ojos suavemente a la izquierda, derecha o centro
local function tweenEyePosition(eye, endPosition, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(eye, tweenInfo, {Position = endPosition})
	tween:Play()
	return tween
end

-- Función que realiza el movimiento de los ojos
local function animateEyeMovement(centerEye, leftEye, rightEye, direction)
	if direction == "right" then
		-- Mover hacia la derecha
		tweenEyePosition(centerEye, UDim2.new(0.8, 0, 0.5, 0), 0.5)
		tweenEyePosition(leftEye, UDim2.new(0.7, 0, 0.5, 0), 0.5)
		tweenEyePosition(rightEye, UDim2.new(0.9, 0, 0.5, 0), 0.5)
	elseif direction == "left" then
		-- Mover hacia la izquierda
		tweenEyePosition(centerEye, UDim2.new(0.2, 0, 0.5, 0), 0.5)
		tweenEyePosition(leftEye, UDim2.new(0.1, 0, 0.5, 0), 0.5)
		tweenEyePosition(rightEye, UDim2.new(0.3, 0, 0.5, 0), 0.5)
	else
		-- Volver al centro
		tweenEyePosition(centerEye, UDim2.new(0.5, 0, 0.5, 0), 0.5)
		tweenEyePosition(leftEye, UDim2.new(0.4, 0, 0.5, 0), 0.5)
		tweenEyePosition(rightEye, UDim2.new(0.6, 0, 0.5, 0), 0.5)
	end
end

-- Función para manejar la animación completa de ambos ojos
local function animateBothEyes(Base1, Center1, Left1, Right1, Base2, Center2, Left2, Right2)
	-- Agitar los ojos y las bases con la función original de agitación
	coroutine.wrap(function()
		shakeObject(Base1)
		shakeObject(Center1)
		shakeObject(Left1)
		shakeObject(Right1)
	end)()

	coroutine.wrap(function()
		shakeObject(Base2)
		shakeObject(Center2)
		shakeObject(Left2)
		shakeObject(Right2)
	end)()

	while true do
		print("Iniciando ciclo de animación para ambos ojos")

		-- Movimiento hacia la derecha
		animateEyeMovement(Center1, Left1, Right1, "right")
		animateEyeMovement(Center2, Left2, Right2, "right")
		wait(1)

		-- Volver al centro
		animateEyeMovement(Center1, Left1, Right1, "center")
		animateEyeMovement(Center2, Left2, Right2, "center")
		wait(1)

		-- Movimiento hacia la izquierda
		animateEyeMovement(Center1, Left1, Right1, "left")
		animateEyeMovement(Center2, Left2, Right2, "left")
		wait(1)

		-- Volver al centro
		animateEyeMovement(Center1, Left1, Right1, "center")
		animateEyeMovement(Center2, Left2, Right2, "center")
		wait(1)

		print("Ciclo de animación completado para ambos ojos")
	end
end

-- Iniciar la animación completa
print("Iniciando animación sincronizada de los ojos y sus bases")
animateBothEyes(Base1, Center1, Left1, Right1, Base2, Center2, Left2, Right2)
