local gameIsStart = false
local idGame = 0
local playersInGame = {}
local admins = {
    'license:4827aac3948812e9ac266b4d7f16ff36ade6bdf2', -- Peter
    'license:fcf3ed924d3ae6df3591dd908f95b89c901201d9', -- Jenny
}

function isAllowedToChange(player)
    local allowed = false
    for i,id in ipairs(admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if debugprint then print('admin id: ' .. id .. '\nplayer id:' .. pid) end
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end

RegisterCommand("StartEvent", function(source, args, rawCommand)
    if (source == 0) then
		TriggerClientEvent("ad_event_cacheCache:startEvent", -1)
    elseif (source > 0) then
        if isAllowedToChange(source) then
            TriggerClientEvent("ad_event_cacheCache:startEvent", -1)
        else
            TriggerClientEvent("chat:addMessage", -1, {
                args = {
                    GetPlayerName(source),
                    "Accès refusé à cette commande !"
                },
                color = { 255, 0, 0 }
            })
        end
    end
end)

RegisterCommand("StopEvent", function(source, args, rawCommand)
    if (source == 0) then
		TriggerClientEvent("ad_event_cacheCache:stopEvent", -1)
    elseif (source > 0) then
        if isAllowedToChange(source) then
            TriggerClientEvent("ad_event_cacheCache:stopEvent", -1)
        else
            TriggerClientEvent("chat:addMessage", -1, {
                args = {
                    GetPlayerName(source),
                    "Accès refusé à cette commande !"
                },
                color = { 255, 0, 0 }
            })
        end
    end
end)

RegisterCommand("StartGame", function(source, args, rawCommand)
    if (source == 0) then
        startGame()
    elseif (source > 0) then
        if isAllowedToChange(source) then
            startGame()
        else
            TriggerClientEvent("chat:addMessage", -1, {
                args = {
                    GetPlayerName(source),
                    "Accès refusé à cette commande !"
                },
                color = { 255, 0, 0 }
            })
        end
    end
end)

RegisterCommand("StopGame", function(source, args, rawCommand)
    if (source == 0) then
		idGame = 0
		for k, v in ipairs(playersInGame) do
			TriggerClientEvent("ad_event_cacheCache:finalGame", v.id, false)
		end
    elseif (source > 0) then
        if isAllowedToChange(source) then
			idGame = 0
			for k, v in ipairs(playersInGame) do
				TriggerClientEvent("ad_event_cacheCache:finalGame", v.id, false)
			end
        else
            TriggerClientEvent("chat:addMessage", -1, {
                args = {
                    GetPlayerName(source),
                    "Accès refusé à cette commande !"
                },
                color = { 255, 0, 0 }
            })
        end
    end
end)

RegisterCommand("StopGameSave", function(source, args, rawCommand)
    if (source == 0) then
		idGame = 0
		for k, v in ipairs(playersInGame) do
			TriggerClientEvent("ad_event_cacheCache:finalGame", v.id, true)
		end
    elseif (source > 0) then
        if isAllowedToChange(source) then
			idGame = 0
			for k, v in ipairs(playersInGame) do
				TriggerClientEvent("ad_event_cacheCache:finalGame", v.id, true)
			end
        else
            TriggerClientEvent("chat:addMessage", -1, {
                args = {
                    GetPlayerName(source),
                    "Accès refusé à cette commande !"
                },
                color = { 255, 0, 0 }
            })
        end
    end
end)

function startGame()
    Citizen.CreateThread(function()
		local currentIdGame = math.random(1,999999999)
		idGame = currentIdGame
		gameIsStart = true
		if gameIsStart and idGame == currentIdGame then
			for k, v in ipairs(playersInGame) do
				TriggerClientEvent("ad_event_cacheCache:startGame", v.id)
			end
			Citizen.Wait(60000*1.5)
			if gameIsStart and idGame == currentIdGame then
				for k, v in ipairs(playersInGame) do
					TriggerClientEvent("ad_event_cacheCache:startSearc", v.id)
				end
				Citizen.Wait(60000*4)
				if gameIsStart and idGame == currentIdGame then
					for k, v in ipairs(playersInGame) do
						TriggerClientEvent("ad_event_cacheCache:finalGame", v.id, true)
					end
					gameIsStart = false
					idGame = 0
				end
			end
		end
	end)
end

RegisterServerEvent('ad_event_cacheCache:joinTeam')
AddEventHandler('ad_event_cacheCache:joinTeam', function(teamName)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]
    local playerName = GetPlayerName(src)
    table.insert(playersInGame, {id = src, playerName = playerName, teamName = teamName, identifier = identifier})
end)

RegisterServerEvent('ad_event_cacheCache:setPositionCacher')
AddEventHandler('ad_event_cacheCache:setPositionCacher', function(playerCoords)
    local src = source
    for k,v in ipairs(playersInGame) do
        if v.teamName == "searcher" then
            TriggerClientEvent("ad_event_cacheCache:addPositionCacher", v.id, src, playerCoords)
        end
    end

    for k,v in ipairs(playersInGame) do
        if v.id == src then
            v.playerCoords = playerCoords
            break
        end
    end
end)

RegisterServerEvent('ad_event_cacheCache:playerCacherFind')
AddEventHandler('ad_event_cacheCache:playerCacherFind', function(playerCacherId)
	local src = source
    for k,v in ipairs(playersInGame) do
        if v.teamName == "searcher" then
            TriggerClientEvent("ad_event_cacheCache:removePositionCacher", v.id, playerCacherId)
        end
    end

    --[[ for k,v in ipairs(playersInGame) do
        if v.id == playerCacherId then
			table.remove(playersInGame, k)
            break
        end
    end ]]

    TriggerClientEvent("ad_event_cache:removePlayerInGame", playerCacherId)
	Citizen.Wait(500)
    TriggerClientEvent("ad_event_cache:reactiveSear", src)
end)


function getScoreInDb(license, callback)
	local currentScore = nil
	MySQL.Async.fetchAll(
		'SELECT * FROM cache_cache WHERE license = @license', 
		{
			['@license'] = license
		},
		function(result)
			for i=1, #result, 1 do
				currentScore = json.decode(result[i].score)
			end
			if currentScore ~= nil then
				callback(currentScore)
			else
				callback(nil)
			end
        end
    )
end

RegisterServerEvent('ad_event_cacheCache:saveScore')
AddEventHandler('ad_event_cacheCache:saveScore', function(_score)
    local src = source
    local score = _score
    local license = GetPlayerIdentifiers(src)[1]
    local playerName = GetPlayerName(src)
	getScoreInDb(license, function(data)
		if data ~= nil then
			MySQL.Async.execute('UPDATE cache_cache SET score = @score, name = @name WHERE license = @license',
			{
				['@score']   = data + score,
				['@name']   = playerName,
				['@license'] = license
			},
			function (rowsChanged)
                TriggerClientEvent('esx:showAdvancedStreamedNotification', src, 'Cache-cache', '~c~Information', 'Votre score de la partie est de : '..score, 'CHAR_SOCIAL_CLUB', 'newstartlogo', 8)
                TriggerClientEvent('esx:showAdvancedStreamedNotification', src, 'Cache-cache', '~c~Information', 'Votre score total est de : '..data + score, 'CHAR_SOCIAL_CLUB', 'newstartlogo', 8)
			end)
        else
            MySQL.Async.execute('INSERT INTO cache_cache (license, name, score) VALUES (@license, @name, @score)',
            {
                ['@license'] = license,
                ['@name'] = playerName,
                ['@score'] = score
            }, function (rowsChanged)
                TriggerClientEvent('esx:showAdvancedStreamedNotification', src, 'Cache-cache', '~c~Information', 'Votre score de la partie est de : '..score, 'CHAR_SOCIAL_CLUB', 'newstartlogo', 8)
            end)
        end
    end)
end)
