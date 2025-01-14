local selfCode
local inCooldown = false


CreateThread(function()
  Wait(1000)
  selfCode = lib.callback.await("referral:server:getSelfCode", false)
end)

RegisterCommand("refercode", function()

   local input = lib.inputDialog('Referral Menu', {
    {type = 'input', label = 'Redeem Code', description = 'Input someone\'s code', required = true},
    {type = 'input', label = 'Your Code', description = "This is your own code to share!", default = selfCode, required = false, disabled = true},
  })


  if input and input[1] then
    if inCooldown then lib.notify({description = "You must wait  before trying again!"}) return end
    lib.callback.await("referral:server:validateCode", false,  input[1])
    inCooldown = true
    local timer = lib.timer(10000, function()
      inCooldown = false
   end)
  end
end, false)





