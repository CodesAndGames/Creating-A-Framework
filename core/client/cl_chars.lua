local config = module('config')
local Framework = module('sh_framework')
if config.debug then
	print("[DEBUG] Loaded spawn locations:", json.encode(config.spawnLocations))
end

local isCreatingCharacter = false
local cam = nil
local currentPosIndex = 1
-- Define the new camera positions with headings
local cameraPositions = {
	{ pos = vector3(-55.4898, -969.9152, 307.1311), heading = 339.8556, point = vector3(49.0955, -702.5053, 294.2001) },
	{ pos = vector3(49.0955, -702.5053, 294.2001), heading = 340, point = vector3(-55.4898, -969.9152, 307.1311) }
}

local function moveCameraToNextPosition()
	if not isCreatingCharacter then return end
	currentPosIndex = currentPosIndex % #cameraPositions + 1
	local nextPos = cameraPositions[currentPosIndex]

	-- Use SetCamParams with correct rotation and position
	SetCamParams(
		cam,
		nextPos.pos.x, nextPos.pos.y, nextPos.pos.z, -- New position
		-10.0, 0.0, nextPos.heading,                -- Adjust pitch and heading
		50.0, 8000,                                -- FOV and transition duration
		0, 0, 2                                    -- No easing, rotation order
	)
	Citizen.Wait(8000)

	moveCameraToNextPosition()  -- Recursive call for endless loop
end

-- Function to set up the high-altitude camera with movement
local function setupCharacterCreationCamera()
	local playerPed = PlayerPedId()
	SetNuiFocus(true, true)

	
	-- Freeze player and move underground
	FreezeEntityPosition(playerPed, true)
	SetEntityCoords(playerPed, 0.0, 0.0, 800.0, false, false, false, true)

	DisplayRadar(false)  -- Turns off the minimap

	-- Create the camera
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	local initialPos = cameraPositions[currentPosIndex]

	-- Set the camera instantly to the position and rotation
	SetCamCoord(cam, initialPos.pos.x, initialPos.pos.y, initialPos.pos.z)
	SetCamRot(cam, -10.0, 0.0, initialPos.heading, 2)  -- Use correct pitch and heading

	-- Ensure the camera is immediately active without easing
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, false, false)  -- Disable easing

	-- Point the camera to the target position
	PointCamAtCoord(cam, initialPos.point.x, initialPos.point.y, initialPos.point.z)

	-- Start looping camera movement
	Citizen.CreateThread(function()
		moveCameraToNextPosition()
	end)

	isCreatingCharacter = true
end

CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Wait(250)
	end

	DoScreenFadeIn(0)
	Wait(500)

	isCreatingCharacter = false
	ResetCamera()

	setupCharacterCreationCamera()
	TriggerServerEvent('getCharacters')
end)


local startPos = {-647.5715, -865.6418, 438.6137}
local startRot = {-15.0, 0.0, -60.0}


RegisterNetEvent('spawnMenu', function()
	SetNuiFocus(true, true)
	local camPos = GetCamCoord(cam)
	local camRot = GetCamRot(cam, 2)

	local startpos = {camPos.x, camPos.y, camPos.z}
	local endpos = {camRot.x, camRot.y, camRot.z}
	SmoothCameraTransition(startPos, startRot,startPos, startRot, 1000)
	SendNUIMessage({ 
		action = 'spawnMenu',
		spawns = config.spawnLocations
	})
end)


function SmoothCameraTransition(startPos, startRot, endPos, endRot, duration)
	if cam then
		DestroyCam(cam, true)
		cam = nil
	end

	-- **Force load the area BEFORE moving the camera**
	RequestCollisionAtCoord(endPos[1], endPos[2], endPos[3])
	NewLoadSceneStart(endPos[1], endPos[2], endPos[3], endPos[1], endPos[2], endPos[3], 50.0, 0)
	while not IsNewLoadSceneLoaded() do
		Citizen.Wait(50) -- Wait for the new area to load
	end

	-- Create the camera
	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(cam, startPos[1], startPos[2], startPos[3])
	SetCamRot(cam, startRot[1], startRot[2], startRot[3], 2)
	SetCamFov(cam, 60.0)
	RenderScriptCams(true, true, 500, true, true)

	local startTime = GetGameTimer()
	local endTime = startTime + duration

	Citizen.CreateThread(function()
		while GetGameTimer() < endTime do
			local now = GetGameTimer()
			local progress = (now - startTime) / duration

			-- Lerp position
			local x = startPos[1] + (endPos[1] - startPos[1]) * progress
			local y = startPos[2] + (endPos[2] - startPos[2]) * progress
			local z = startPos[3] + (endPos[3] - startPos[3]) * progress

			-- Lerp rotation
			local rotX = startRot[1] + (endRot[1] - startRot[1]) * progress
			local rotY = startRot[2] + (endRot[2] - startRot[2]) * progress
			local rotZ = startRot[3] + (endRot[3] - startRot[3]) * progress

			-- Apply new position and rotation
			SetCamCoord(cam, x, y, z)
			SetCamRot(cam, rotX, rotY, rotZ, 2)

			Citizen.Wait(10) -- Small delay to make it smooth
		end

		-- **Ensure the final position is set exactly**
		SetCamCoord(cam, endPos[1], endPos[2], endPos[3])
		SetCamRot(cam, endRot[1], endRot[2], endRot[3], 2)

		-- **Final load check to ensure the area is fully loaded**
		RequestCollisionAtCoord(endPos[1], endPos[2], endPos[3])
		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
			Citizen.Wait(50)
		end
	end)
end

-- Function to reset the camera back to default
function ResetCamera()
	if cam then
		RenderScriptCams(false, true, 2000, true, true)
		DestroyCam(cam, false)
		cam = nil
	end
end

Framework:RegisterCallback('loadCharacters', function(characters)
	-- Debugging
	if config.debug then
		print("[CLIENT] loadCharacters event received!")
	end
	Citizen.SetTimeout(1000, function()
		SendNUIMessage({
			action = 'characters',
			characters = characters
		})
		if config.debug then
			print("Sent NUI Message after delay") -- Debugging
		end
	end)
	return 'ok'
end)
