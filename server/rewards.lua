Rewards = {
    ["default"] = function(id)
            exports.ox_inventory:AddItem(id, "money", 1000)
        end,
    ["VLMDFKCLEDJO"]  = function(id)
            exports.ox_inventory:AddItem(id, "money", 2000)
        end,
    ["MIAO"]  = {
        isPromo = true,
        action = function(id)
            exports.ox_inventory:AddItem(id, "money", 2000)
        end,
    },
}