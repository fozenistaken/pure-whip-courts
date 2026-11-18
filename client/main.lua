local APP = 'pwcourt'
local registered = false

local function sync()
    if GetResourceState('whip_phone') ~= 'started' then registered = false return end
    if registered then return end
    local ok, why = exports.whip_phone:RegisterModule({ id = APP, script = 'html/court/module.js', ns = PWC.RES .. ':app' })
    registered = ok == true
    if not ok then print('[pure-whip-courts] court app: ' .. tostring(why)) end
end

local function money(n) return ('$%s'):format(tostring(math.floor(n or 0)):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')) end

RegisterNetEvent(PWC.event('plea'), function(token, s)
    local trial = s.trial or {}
    local bail = trial.state == 'due' and ('bail ' .. money(trial.bail))
        or trial.state == 'denied' and ('no bail, held up to ' .. trial.remand .. ' min')
        or 'free until the hearing'
    local message = ('Charged with %s.\n\nGuilty now: %d months, %s (%d%% off for pleading).\n\nNot guilty: a court case, %s. If found guilty: %d months, %s.')
        :format(s.charges, s.guilty.months, money(s.guilty.fine), s.guilty.off, bail, trial.months, money(trial.fine))
    local yes = Whip.core:Confirm({ title = 'Your plea', message = message, yes = 'Guilty', no = 'Not guilty' })
    TriggerServerEvent(PWC.event('plea'), token, yes == true)
end)

RegisterCommand('court', function()
    if not registered then return Whip.core:Notify('The court app needs a phone', 'error') end
    CreateThread(function()
        local _, why = exports.whip_phone:RunApp(APP, {})
        if why and why ~= 'busy' then Whip.core:Notify('Court: ' .. tostring(why), 'error') end
    end)
end, false)

AddEventHandler('whip_core:player:loaded', sync)
AddEventHandler('onClientResourceStart', function(res) if res == 'whip_phone' then registered = false; sync() end end)
AddEventHandler('onClientResourceStop', function(res) if res == 'whip_phone' then registered = false end end)
CreateThread(sync)
