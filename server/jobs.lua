local Jobs = {}
PWC.Jobs = Jobs

local PERMISSIONS = {
    justice = { rule = 'Rule on cases', bail = 'Set or deny bail', schedule = 'Set hearings', prosecute = 'Plea deals and dropping charges' },
    lawyer = { represent = "Act for clients who picked you" },
}

function Jobs.justice(src)
    local role = Whip.core:GetPlayerRole(src, Config.Justice.key)
    if not role then return nil end
    local perms = {}
    for p in pairs(PERMISSIONS.justice) do perms[p] = Whip.core:HasJobPermission(src, Config.Justice.key, p) == true end
    return { rank = role.name, level = role.level, onDuty = Whip.core:IsPlayerClockedOn(src, Config.Justice.key) == true, perms = perms }
end

function Jobs.lawyer(src)
    local role = Whip.core:GetPlayerRole(src, Config.Lawyers.key)
    if not role then return nil end
    return { rank = role.name, represent = Whip.core:HasJobPermission(src, Config.Lawyers.key, 'represent') == true }
end

function Jobs.can(src, perm)
    local j = Jobs.justice(src)
    if not j then return false, 'Only court staff can do that' end
    if not j.onDuty then return false, 'Go on duty at the Department of Justice first' end
    if not j.perms[perm] then return false, 'Your rank cannot do that' end
    return true
end

function Jobs.lawyers()
    local list, ids = {}, {}
    for charId, e in pairs(Whip.core:GetJobEmployees(Config.Lawyers.key) or {}) do
        list[#list + 1] = { charId = tonumber(charId), onDuty = e.onDuty == true }
        ids[#ids + 1] = tonumber(charId)
    end
    local names = #ids > 0 and Whip.core:GetCharacterNames(ids) or {}
    for _, l in ipairs(list) do l.name = names[l.charId] or ('Attorney #' .. l.charId) end
    table.sort(list, function(a, b)
        if a.onDuty ~= b.onDuty then return a.onDuty end
        return a.name < b.name
    end)
    return list
end

Whip.register(function()
    for _, def in ipairs({ { Config.Justice, PERMISSIONS.justice }, { Config.Lawyers, PERMISSIONS.lawyer } }) do
        local cfg, perms = def[1], def[2]
        local job, why = Whip.core:EnsureJob(cfg.key, { name = cfg.name, icon = cfg.icon, roles = cfg.ranks,
            permissions = perms, selfClockOn = true })
        if not job then print(('[%s] job %s: %s'):format(PWC.RES, cfg.key, tostring(why))) end
    end
end)
