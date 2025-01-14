math.randomseed(os.time())

local PlayerCodes = {}

local function getUserIdentifier(user)
    return (GetPlayerIdentifierByType(user, "license"):gsub("license:", ""))
end

local function generateCode()
    local length = math.random(12, 20)
    local arr = {}
    for i = 1, length do
        arr[i] = string.char(math.random(65, 90))
    end
    return table.concat(arr)
end




local function generateUserDb(identifier)
    local timeout = 0
        local result = MySQL.query.await('SELECT * FROM `referrals` WHERE `identifier` = ?', {identifier})
        if result and #result == 0 then
            local code = generateCode()
            while timeout <= 10 do
                local isunique = MySQL.query.await('SELECT identifier FROM `referrals` WHERE `code` = ?', {code})
                if isunique and #isunique == 0 then
                    MySQL.insert.await('INSERT INTO `referrals` (identifier, code) VALUES (?, ?)', {
                        identifier, code
                    })
                return code 
                end 
                Wait(1000)
                timeout += 1
            end
        end
    return false
end

local function getUserCode(user)
    local identifier = getUserIdentifier(user)
    local result = MySQL.query.await('SELECT code, redeemed FROM `referrals` WHERE `identifier` = ?', {identifier})
    if result and #result > 0 then
        return result[1].code, result[1].redeemed
    end
    return  generateUserDb(identifier)
end

local function validateCode(user, code)
    local identifier = getUserIdentifier(user)
    local code = (string.upper(code)):gsub("[%p%c%s]", "")
    if Rewards?[code]?.isPromo then goto skip end

    if PlayerCodes[user].redeem then Notify(user, "You already used a referral") return end
    if code == PlayerCodes[user].code then  Notify(user, "You cannot redeem your own code!") return end
    ::skip::
    local result = MySQL.query.await('SELECT * FROM `referrals` WHERE `code` = ?', {code})
    if result and #result == 1 then
        if result[1].identifier == "promo_"..code then return ValidatePromoCode(identifier, code) end
        MySQL.update.await('UPDATE `referrals` SET redeemed = ? WHERE identifier = ?', {
            code, identifier
        })
        return true
    end
    return false
end

function GetIdFromIdentifier(identifier)
    for _, id in pairs(GetPlayers()) do
        if getUserIdentifier(id) == identifier then
            return id
        end
    end
    return false
end

local function getUserFromCode(code)
    local result = MySQL.query.await('SELECT identifier FROM `referrals` WHERE `code` = ?', {code})
    if result and #result == 1 then
        return GetIdFromIdentifier(result[1].identifier)
    end

end

local function distributeUserRewards(used, code)
    local codeOwner = getUserFromCode(code)
    
    if not Rewards[code] then
        Rewards["default"](used)
    else
        Rewards[code](used)
    end
    Notify(used, "You claimed a referral code!")
    
    if not codeOwner then  Notify(used, "Referral owner is not online, you will still receive your rewards!") end
    if not Rewards[code] then
        Rewards["default"](codeOwner)
    else
        Rewards[code](codeOwner)
    end
    
    Notify(used, "Someone used your referral code!")
end

lib.callback.register("referral:server:getSelfCode", function(source)
    local source = source
    local code, redeemed =  getUserCode(source)
    PlayerCodes[source] = {code = code, redeem = (redeemed ~= nil)}
    return PlayerCodes[source].code
end)

lib.callback.register("referral:server:validateCode", function(source, code)
    if validateCode(source, code) then
        distributeUserRewards(source, code)
    end
end)


-- AddEventHandler("onPlayerJoined", function()
--     local source = source
--     local code, redeemed =  getUserCode(source)
--     PlayerCodes[source] = {code = code, redeem = (redeemed ~= nil)}
-- end)

AddEventHandler("onPlayerDropped", function()
    local source = source
    PlayerCodes[source] = nil
end)