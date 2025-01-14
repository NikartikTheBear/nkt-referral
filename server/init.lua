local function initTable()
    MySQL.query.await('CREATE TABLE referrals ( identifier VARCHAR(255) PRIMARY KEY, code VARCHAR(255), redeemed VARCHAR(255)) ' , {})
end


local function init()
    local response = MySQL.query.await('SHOW TABLES LIKE "referrals" ')
    if response and #response == 0 then
        initTable()
    end
end

function Notify(user, msg)
    TriggerClientEvent('ox_lib:notify', user, {description = msg})
end
CreateThread(init)
