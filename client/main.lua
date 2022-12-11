local isStartPoint = false
local isInGame = false
local isZoneStart = false
local InitialTimer = false
local teamName = nil
local startTime = nil
local playerScore = 0
local infoPlayerCacher = {}

RegisterNetEvent('ad_event_cacheCache:startEvent')
AddEventHandler('ad_event_cacheCache:startEvent', function()
	isInGame = false
	isStartPoint = false
	isZoneStart = false
	InitialTimer = false
	teamName = nil
	startTime = nil
	playerScore = 0
	infoPlayerCacher = {}
    startPoint()
end)

RegisterNetEvent('ad_event_cacheCache:stopEvent')
AddEventHandler('ad_event_cacheCache:stopEvent', function()
	startPoint = false
end)

function startPoint()
	isStartPoint = true
    while not isInGame and isStartPoint do
        local _Wait = 500
        if not isInGame then
            local PlayerPed = GetPlayerPed(-1)
            local dst = GetDistanceBetweenCoords(1359.22, 1138.97, 113.76, GetEntityCoords(PlayerPed))
            if dst < 20.0 then
                DrawMarker(1, 1359.22, 1138.97, 113.76 - 1.5, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 250, 250, 250, 180, 0, 0, 0,0)
                _Wait = 1
                if dst < 10.0 then
                    Draw3DText(1359.22, 1138.97, 113.76  -.500, "~b~A~w~D Event",4,0.3,0.2)
                    Draw3DText(1359.22, 1138.97, 113.76  -.900, "Cache-cache",4,0.3,0.2)
                    if dst < 2.0 then
                        Draw3DText(1359.22, 1138.97, 113.76  -1.400, "Appuyez sur E pour rejoindre l'équipe des chercheurs",4,0.15,0.1)
                        if (IsControlJustReleased(1, 38)) then
                            if isInGame == false then
                                teamName = "searcher"
                                isInGame = true
                                TriggerServerEvent("ad_event_cacheCache:joinTeam", teamName)
                                break
                            else
                                return
                            end
                        end
                    end
                end
            end

            local dst2 = GetDistanceBetweenCoords(1361.64, 1156.06, 113.76, GetEntityCoords(PlayerPed))
            if dst2 < 20.0 then
                DrawMarker(1, 1361.64, 1156.06, 113.76 - 1.5, 0, 0, 0, 0, 0, 0, 3.0001, 3.0001, 1.5001, 0, 0, 0, 180, 0, 0, 0,0)
                _Wait = 1
                if dst2 < 10.0 then
                    Draw3DText(1361.64, 1156.06, 113.76  -.500, "~b~A~w~D Event",4,0.3,0.2)
                    Draw3DText(1361.64, 1156.06, 113.76  -.900, "Cache-cache",4,0.3,0.2)
                    if dst2 < 2.0 then
                        Draw3DText(1361.64, 1156.06, 113.76  -1.400, "Appuyez sur E pour rejoindre l'équipe des cachés",4,0.15,0.1)
                        if (IsControlJustReleased(1, 38)) then
                            if isInGame == false then
                                teamName = "cacher"
                                isInGame = true
                                TriggerServerEvent("ad_event_cacheCache:joinTeam", teamName)
                                break
                            else
                                return
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(_Wait)
    end
end

RegisterNetEvent('ad_event_cacheCache:startGame')
AddEventHandler('ad_event_cacheCache:startGame', function()
    local playerPed = GetPlayerPed(-1)
    startTime = GetGameTimer() + 60000*1.5
    startInitialTimer()
    if teamName == "searcher" then
        exports["ad_c"]:SetEntityCoords2(playerPed, Config.StartTpSearcherCoords)
        FreezeEntityPosition(playerPed, true)
    elseif teamName == "cacher" then
        exports["ad_c"]:SetEntityCoords2(playerPed, Config.StartTpCacherCoords)
        createThreadForCreateWall()
        createThreadForCheckPlayerInZone()
    end
end)

RegisterNetEvent('ad_event_cacheCache:startSearc')
AddEventHandler('ad_event_cacheCache:startSearc', function()
    local playerPed = GetPlayerPed(-1)
    InitialTimer = false
    if teamName == "searcher" then
        createThreadForCreateWall()
        createThreadForCheckPlayerInZone()
        createThreadForSearPlayer()
		createThreadForFirstPerson()
        FreezeEntityPosition(playerPed, false)
        exports["ad_c"]:SetEntityCoords2(playerPed, Config.StartSearcTpSearcherCoords)
    elseif teamName == "cacher" then
        FreezeEntityPosition(playerPed, true)
        local playerCoords = GetEntityCoords(playerPed)
        TriggerServerEvent("ad_event_cacheCache:setPositionCacher", playerCoords)
    end
end)

RegisterNetEvent('ad_event_cacheCache:addPositionCacher')
AddEventHandler('ad_event_cacheCache:addPositionCacher', function(idPlayderCacher, coordsPlayderCacher)
    table.insert(infoPlayerCacher, {id = idPlayderCacher, coords = coordsPlayderCacher})
end)

RegisterNetEvent('ad_event_cacheCache:removePositionCacher')
AddEventHandler('ad_event_cacheCache:removePositionCacher', function(idPlayderCacher)
    for k,v in ipairs(infoPlayerCacher) do
        if v.id == idPlayderCacher then
			table.remove(infoPlayerCacher, k)
            break
        end
    end
end)

RegisterNetEvent('ad_event_cache:removePlayerInGame')
AddEventHandler('ad_event_cache:removePlayerInGame', function()
    --isInGame = false
	isZoneStart = false
	InitialTimer = false
    teamName = nil
    --startTime = nil
    playerScore = 0
    infoPlayerCacher = {}
    Citizen.Wait(200)
    local playerPed = GetPlayerPed(-1)
    exports["ad_c"]:SetEntityCoords2(playerPed, Config.FinalCoords)
    FreezeEntityPosition(playerPed, false)
end)

RegisterNetEvent('ad_event_cacheCache:finalGame')
AddEventHandler('ad_event_cacheCache:finalGame', function(statusSave)
    if teamName == "cacher" then
        playerScore = 1
    end
	if statusSave then
		if teamName ~= nil then
			TriggerServerEvent("ad_event_cacheCache:saveScore", playerScore)
		end
	end
    isInGame = false
	isZoneStart = false
	InitialTimer = false
    teamName = nil
    startTime = nil
    playerScore = 0
    infoPlayerCacher = {}
    Citizen.Wait(200)
    local playerPed = GetPlayerPed(-1)
    exports["ad_c"]:SetEntityCoords2(playerPed, Config.FinalCoords)
    FreezeEntityPosition(playerPed, false)
end)

RegisterNetEvent('ad_event_cache:reactiveSear')
AddEventHandler('ad_event_cache:reactiveSear', function()
    playerScore = playerScore + 2
	--createThreadForSearPlayer()
end)

local cooldownControl = false
function createThreadForSearPlayer()
    Citizen.CreateThread(function()
        while isInGame do
            local playerPed = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(playerPed)
			if not cooldownControl then
				if IsControlJustReleased(1, 38) then
					cooldownControl = true
					cooldown()
					for k,v in pairs(infoPlayerCacher) do
						local dst = GetDistanceBetweenCoords(v.coords, playerCoords, true)
						if dst <= 1.1 then
							TriggerServerEvent("ad_event_cacheCache:playerCacherFind", v.id)
							table.remove(infoPlayerCacher, k)
							break
						end
					end
				end
			end
            Citizen.Wait(1)
        end
    end)
end

function cooldown()
	Citizen.Wait(500)
	cooldownControl = false
end

function startInitialTimer()
    Citizen.CreateThread(function()
        InitialTimer = true
        while InitialTimer do
            local time = formatTimer(GetGameTimer(), startTime)
            if teamName == "searcher" then
                SendNUIMessage({HUD = "Green", Name = "<u>avant le début</u>", Time = time, Score = playerScore})
            elseif teamName == "cacher" then
                SendNUIMessage({HUD = "Red", Name = "<u>pour se cacher</u>", Time = time, Score = playerScore})
            end
            Citizen.Wait(1)
        end
        SendNUIMessage({HUD = false, Time = time, Score = 0})
        startTime = GetGameTimer() + 60000*4
        while isInGame do
            local time = formatTimer(GetGameTimer(), startTime)
            if teamName == "searcher" then
                SendNUIMessage({HUD = "Green", Name = "<u>de la partie</u>", Time = time, Score = playerScore})
            elseif teamName == "cacher" then
                SendNUIMessage({HUD = "Red", Name = "<u>de la partie</u>", Time = time, Score = playerScore})
			else
                SendNUIMessage({HUD = "Red", Name = "<u>de la partie</u>", Time = time, Score = "Trouvé"})
            end
            Citizen.Wait(1)
        end
        SendNUIMessage({HUD = false, Time = time, Score = 0})
    end)
end

function createThreadForFirstPerson()
    Citizen.CreateThread(function()
        while isInGame do
			SetFollowPedCamViewMode(4)
            Citizen.Wait(1)
		end
	end)
end

function formatTimer(startTime, currTime)
    local newTime = currTime - startTime
    local floor = math.floor
    local ms = floor(newTime % 1000)
    local hundredths = floor(ms / 10)
    local seconds = floor(newTime / 1000)
    local minutes = floor(seconds / 60);   seconds = floor(seconds % 60)
    local formattedTime = string.format("%02d:%02d.%02d", minutes, seconds, hundredths)
    return formattedTime
end

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 250)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


--!-------------!--
--! Partie ZONE !--
--!-------------!--


local pedCoordsInZone = nil
local isLeaveZone = false
local countLeaveZone = 0

local function insidePolygon(point)
    local oddNodes = false
    for i = 1, #Config.Zones do
        local Zone = Config.Zones[i]
        local j = #Zone
        for i = 1, #Zone do
            if (Zone[i][2] < point.y and Zone[j][2] >= point.y or Zone[j][2] < point.y and Zone[i][2] >= point.y) then
                if (Zone[i][1] + ( point[2] - Zone[i][2] ) / (Zone[j][2] - Zone[i][2]) * (Zone[j][1] - Zone[i][1]) < point.x) then
                    oddNodes = not oddNodes;
                end
            end
            j = i;
        end
    end
    return oddNodes 
end

function createThreadForCreateWall()
	isZoneStart = true
    Citizen.CreateThread(function()
        while isInGame and isZoneStart do
            local iPed = GetPlayerPed(-1)
            Citizen.Wait(0)
            point = GetEntityCoords(iPed, true)
            local inZone = insidePolygon(point)
            if Config.ShowBorder then
                drawPoly(inZone)
            end
        end
    end)
end

function createThreadForCheckPlayerInZone()
	isZoneStart = true
    Citizen.CreateThread(function()
        while isInGame and isZoneStart do
            local iPed = GetPlayerPed(-1)
            Citizen.Wait(200)
            point = GetEntityCoords(iPed, true)
            local inZone = insidePolygon(point)
            if inZone then
                pedCoordsInZone = point
                if isLeaveZone then
                    Wait(100)
                    FreezeEntityPosition(iPed, false)
                    isLeaveZone = false
                    countLeaveZone = 0
                end
            else
                if countLeaveZone < 2 then
                    TriggerEvent('esx:showAdvancedStreamedNotification', 'Event cache-cache', '~c~Information', 'Vous n\'avez pas le droit de quitter la zone de jeux !', 'CHAR_SOCIAL_CLUB', 'newstartlogo', 8)
                    FreezeEntityPosition(iPed, true)
                    exports["ad_c"]:SetEntityCoords2(iPed, vector3(pedCoordsInZone.x, pedCoordsInZone.y, pedCoordsInZone.z-1))
                    SetEntityHeading(iPed, GetEntityHeading(iPed) - 180)
                    isLeaveZone = true
                    countLeaveZone = countLeaveZone + 1
                else
                    TriggerEvent('esx:showAdvancedStreamedNotification', 'Event cache-cache', '~c~Information', 'Vous êtes resté trop longtemps hors de la zone de jeux ! Vous êtes donc téléporté au milieu de la zone', 'CHAR_SOCIAL_CLUB', 'newstartlogo', 8)
                    exports["ad_c"]:SetEntityCoords2(iPed, Config.CenterCoords)
                end
            end
        end
    end)
end

function drawPoly(isEntityZone)
    local iPed = GetPlayerPed(-1)
    for i = 1, #Config.Zones do
        local Zone = Config.Zones[i]
        local j = #Zone
        for i = 1, #Zone do
            local zone = Zone[i]
            if i < #Zone then
                local p2 = Zone[i+1]
                _drawWall(zone, p2)
            end
        end
    
        if #Zone > 2 then
            local firstPoint = Zone[1]
            local lastPoint = Zone[#Zone]
            _drawWall(firstPoint, lastPoint)
        end
    end
end

function _drawWall(p1, p2)
    local bottomLeft = vector3(p1[1], p1[2], p1[3] - 1.5)
    local topLeft = vector3(p1[1], p1[2], p1[3] + Config.BorderHight)
    local bottomRight = vector3(p2[1], p2[2], p2[3] - 1.5)
    local topRight = vector3(p2[1], p2[2], p2[3] + Config.BorderHight)
    
    DrawPoly(bottomLeft, topLeft, bottomRight, 255, 0, 0, Config.AlphaBorder)
    DrawPoly(topLeft, topRight, bottomRight, 255, 0, 0, Config.AlphaBorder)
    DrawPoly(bottomRight, topRight, topLeft, 255, 0, 0, Config.AlphaBorder)
    DrawPoly(bottomRight, topLeft, bottomLeft, 255, 0, 0, Config.AlphaBorder)
end

--create blip
Citizen.CreateThread(function()
    for _, info in pairs(Config.Blips) do
        info.blip = AddBlipForCoord(info.coords)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 1.5)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)