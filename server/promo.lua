local promoCodes = {}

local function insertNewPromos()
    for i = 1, #promoCodes do
        MySQL.insert.await('INSERT IGNORE INTO `referrals` (identifier, code, redeemed) VALUES (?, ?, ?) ' , {
            "promo_"..promoCodes[i], promoCodes[i], json.encode({})
        })
    end
end

local function checkForPromos()
    for code, v in pairs(Rewards) do
        if type(v) ~= "function" and v.isPromo then
            promoCodes[#promoCodes+1] = code
        end
    end
    insertNewPromos()
end

local function isCodeUsed(identifier, code, user)
    local result = MySQL.query.await('SELECT `redeemed` FROM `referrals` WHERE `identifier` = ?', {
        "promo_"..code
    })
    if result and #result == 1 then
        local names =  json.decode(result[1].redeemed) or {}
       for i =1, #names do
        if names[i] == identifier then
            Notify(user, "You already used the promo code!")
            return true
        end
       end
       return false, names
    end
    return false
end

local function usePromoCode(identifier, code, user, tb)
    tb[#tb+1] = identifier
    MySQL.update.await('UPDATE `referrals` SET redeemed = ? WHERE identifier = ?', {
        json.encode(tb), "promo_"..code
    })
    Rewards[code].action(tonumber(user))
    Notify(user, "You used the promo code!")

end

function ValidatePromoCode(identifier, code)
    local user = GetIdFromIdentifier(identifier)
    local isUsed, tb = isCodeUsed(identifier, code, user)
    if not isUsed then
        usePromoCode(identifier, code, user, tb)
    end
end
Wait(100)

checkForPromos()