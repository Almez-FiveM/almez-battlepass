ESX = exports['es_extended']:getSharedObject()

local emptyData = {
    ["free"] = {},
    ["premium"] = {},
}

for i = 1, #Config.FreePassDetails do
    emptyData["free"][i] = {
        status = false,
    }
end
for i = 1, #Config.PremiumPassDetails do
    emptyData["premium"][i] = {
        status = false,
    }
end

ESX.RegisterServerCallback('almez-battlepass:GetPlayerPassDetails', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    exports.oxmysql:execute("SELECT * FROM battlepass WHERE `identifier` = '"..xPlayer.identifier.."'", function(data)
        if data[1] ~= nil then
            cb(data[1])
        else
            exports.oxmysql:execute('INSERT INTO battlepass (identifier, level, xp, details) VALUES (@identifier, @passlevel, @passxp, @details)', {
                ['@identifier'] = xPlayer.identifier,
                ['@passlevel'] = 0,
                ['@passxp'] = 0,
                ['@details'] = json.encode(emptyData),
            })
            cb(data[1])
        end
    end)
end)

ESX.RegisterServerCallback('almez-battlepass:server:GetReward', function(source, cb, index, premium)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local type = premium and "premium" or "free"
    exports.oxmysql:execute("SELECT details, level FROM battlepass WHERE `identifier` = '"..xPlayer.identifier.."'", function(data)
        if (tonumber(data[1].level) < index) then
            cb(false)
            return
        end
        if premium then 
            local roleIDs = exports.chat:GetDiscordRoles(src)
            print(json.encode(roleIDs))
            local havePremium = false
            for i = 1, #roleIDs do 
                local roleID = roleIDs[i]
                if roleID == "1064528410883391540" then 
                    havePremium = true
                end
            end
            print("premium role", havePremium)
            if not havePremium then 
                cb(false)
                return
            end
        end
        local itemData = (premium and Config.PremiumPassDetails or Config.FreePassDetails)[index]
        if data[1] ~= nil then
            local pData = json.decode(data[1].details)
            if not pData[type][index].status then
                pData[type][index].status = true
                exports.oxmysql:execute('UPDATE battlepass SET details = @details WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@details'] = json.encode(pData),
                }, function(result)
                    if(result.affectedRows > 0) then
                        if itemData.type == "item" then 
                            xPlayer.addInventoryItem(itemData.reward, itemData.amount)
                        elseif itemData.type == "money" then 
                            xPlayer.addAccountMoney(itemData.reward, itemData.amount)
                        elseif itemData.type == "weapon" then 
                            xPlayer.addWeapon(itemData.reward, itemData.amount)
                        elseif itemData.type == "vehicle" then
                            -- vehicle event
                        end
                        print("coming true")
                        cb(true)
                    end 
                end)
            else
                print("coming false")
                cb(false)
            end
        end
    end)
end)

RegisterServerEvent('almez-battlepass:AddXp', function(amount)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    exports.oxmysql:execute("SELECT level, xp, premium FROM battlepass WHERE `identifier` = '"..xPlayer.identifier.."'", function(data)
        local level = data[1].level
        local xp = data[1].xp + amount
        local neededXp = Config.XPToLevelUp[level]
        local levelUp = false
        if Config.XPToLevelUp[level] == nil then return end
        if xp >= neededXp then 
            xp = xp - neededXp
            level = data[1].level + 1
            levelUp = true
        end
        exports.oxmysql:execute('UPDATE battlepass SET xp = @xp, level = @level WHERE identifier = @identifier', {
            ["@identifier"] = xPlayer.identifier,
            ["@xp"] = xp,
            ["@level"] = level,
        }, function(result) 
            if result.affectedRows > 0 then 
                if levelUp then 
                    TriggerClientEvent('almez-battlepass:client:LevelUp', src, level, data[1].premium)
                end
            end
        end)
    end)
end)

purchase_package_tebex {"transid":"{transaction}", "packagename":"{packageName}"}

RegisterCommand('redeempremium', function(source, args, rawCommand)
    local encode = args[1]
    local xPlayer = ESX.GetPlayerFromId(source)
    exports.oxmysql:execute('SELECT * FROM codes WHERE code = @playerCode', {['@playerCode'] = encode}, function(result)
        if result[1] then
            local packagename = json.encode(result[1].packagename)[1]
            if packagename == "Battle Pass VIP" then 
                exports.oxmysql:execute('DELETE FROM codes WHERE code = @playerCode', {['@playerCode'] = encode}, function(result) end)
                exports.oxmysql:execute('UPDATE battlepass SET premium=@premium WHERE identifier = @identifier', {["@premium"] = true, ['@identifier'] = xPlayer.identifier}, function(result) end)
                Wait(100)
                TriggerClientEvent('esx:showNotification', source, "You have successfully redeemed the Tebex Code")
                SendToDiscord('Tebex Code Redeemed', '**Package Name: **'..packagename..'\n**Player Name: **'..GetPlayerName(source)..'\n**Player ID: **'..source..' \n**Steam: **'..xPlayer.identifier, 10181046)
            end
        else
            TriggerClientEvent('esx:showNotification', source, "You have entered an invalid code")
        end
  end)
end)

RegisterServerEvent('almez-battlepass:AddXpServer', function(source, amount)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then 
        exports.oxmysql:execute("SELECT level, xp, premium FROM battlepass WHERE `identifier` = '"..xPlayer.identifier.."'", function(data)
            if data[1] then 
                local level = data[1].level
                local xp = data[1].xp + amount
                local neededXp = Config.XPToLevelUp[level]
                local levelUp = false
                if Config.XPToLevelUp[level] == nil then return end
                if xp >= neededXp then
                    xp = 0
                    level = level + 1
                    levelUp = true
                end
                exports.oxmysql:execute('UPDATE battlepass SET xp = @xp, level = @level WHERE identifier = @identifier', {
                    ["@identifier"] = xPlayer.identifier,
                    ["@xp"] = xp,
                    ["@level"] = level,
                }, function(result) 
                    if result.affectedRows > 0 then 
                        if levelUp then 
                            TriggerClientEvent('almez-battlepass:client:LevelUp', src, level, data[1].premium)
                        end
                    end
                end)
            end
        end)
    end
end)