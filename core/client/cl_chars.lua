local config = module('config')
local Framework = module('sh_framework')

if config.debug then
	print('loaded spawn location', json.encode(config.spawnLocations))
end

local isCreatingCharacter = false
local cam = nil
local currentPosIndex = 1
local camThread = nil

local cameraPositions = {
	{ pos = vector3(-55.4898, -969.9152, 307.1311), heading = 339.8556, point = vector3(49.0955, -702.5053, 294.2001) },
	{ pos = vector3(49.0955, -702.5053, 294.2001), heading = 339.8556, point = vector3(-55.4898, -969.9152, 307.1311) },
}

local function moveCameraToNextPosition()
	camThread = CreateThread(function()
		while isCreatingCharacter and cam do
			currentPosIndex = currentPosIndex % #cameraPositions + 1
			local nextPos = cameraPositions[currentPosIndex]

			SetCamParams(
				cam,
				nextPos.pos.x, nextPos.pos.y, nextPos.pos.z
				-10.0, 0.0, nextPos.heading,
				50.0, 8000,
				0.0, 0.0, 2.0
			)
			Wait(8000)
		end
	end)
end

local function setupCharacterCreationCamera()
	local playerPed = PlayerPedId()
	SetNuiFocus(true, true)

	FreezeEntityPosition(playerPed, true)
	SetEntityCoords(playerPed, 0.0, 0.0, 800.0, false, false, false, true)

	DisplayRadar(false)

	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	local initialPos = cameraPositions[currentPosIndex]

	SetCamCoord(cam, initialPos.pos.x, initialPos.pos.y, initialPos.pos.z)
	SetCamRot(cam, -10.0, 0.0, initialPos.heading, 2)

	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, false, false)

	PointCamAtCoord(cam, initialPos.point.x, initialPos.point.y, initialPos.point.z)

	CreateThread(function()
		moveCameraToNextPosition()
	end)

	isCreatingCharacter = true
end

CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Wait(250)
	end

	DoScreenFadeOut(0)
	Wait(500)

	isCreatingCharacter = false
	DestroyCam(cam, false)

	setupCharacterCreationCamera()
	TriggerServerEvent('getCharacters')
end)

local startPos = {-647.5715, -865.6418, 438.6137}
local endPos = {-15.0, 0.0, -60.0}

RegisterNetEvent('spawnMenu', function()
	SetNuiFocus(true, true)
	local camPos = GetCamCoord(cam)
	local camRot = GetCamRot(cam, 2)

	local startpos = {camPos.x, camPos.y, camPos.z}
	local endpos = {camRot.x, camRot.y, camRot.z}
	SmoothCameraTransition(startPos, startPos, startPos, startPos, 1000)
	SendNUIMessage({
		action = 'spawnMenu',
		spawns = config.spawnLocations
	})
end)

function SmoothCameraTransition(startPos, startRot, endPos, endRot, duration)
	if cam then
		DestroyCam(cam,true)
		cam = nil
	end

	RequestCollisionAtCoord(endPos[1], endPos[2], endPos[3])
	NewLoadSceneStart(endPos[1], endPos[2], endPos[3], endPos[1], endPos[2], endPos[3], 50.0, 0)
	while not IsNewLoadSceneLoaded() do
		Wait(50)
	end

	cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	SetCamCoord(cam, startPos[1], startPos[2], startPos[3])
	SetCamRot(cam, startRot[1], startRot[2], startRot[3], 2)
	SetCamFov(cam, 50)
	RenderScriptCams(true, true, 500, true, true)

	local startTime = GetGameTimer()
	local endTime = startTime + duration

	CreateThread(function()
		while GetGameTimer() < endTime do
			local now = GetGameTimer()
			local progress = (now - startTime) / duration

			local x = startPos[1] + (endPos[1] - startPos[1]) * progress
			local y = startPos[2] + (endPos[2] - startPos[2]) * progress
			local z = startPos[3] + (endPos[3] - startPos[3]) * progress

			local rotX = startRot[1] + (endRot[1] - startRot[1]) * progress
			local rotY = startRot[2] + (endRot[2] - startRot[2]) * progress
			local rotZ = startRot[3] + (endRot[3] - startRot[3]) * progress

			SetCamCoord(cam, x,y,z)
			SetCamRot(cam, rotX, rotY, rotZ, 2)

			Wait(10)
		end

		SetCamCoord(cam, endPos[1], endPos[2], endPos[3])
		SetCamRot(cam, endRot[1], endRot[2], endRot[3], 2)

		RequestCollisionAtCoord(endPos[1], endPos[2], endPos[3])
		while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
			Wait(50)
		end
	end)
end

function ResetCamera()
	isCreatingCharacter = false

	if camThread then
		TerminateThread(camThread)
		camThread = nil
	end

	if cam then
		RenderScriptCams(false, false, 0, true, true)
		DestroyCam(cam, false)
		cam = nil
	end
end

Framework:RegisterCallback('loadCharacters', function(characters)
	if config.debug then
		print('load characters callback received from server')
	end

	SendNUIMessage({
		action = 'loadCharacters',
		characters = characters
	})
	if config.debug then
		print('sent characters to NUI')
	end
end)
