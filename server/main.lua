local Cases = PWC.Cases

exports('Arraign', function(spec) return PWC.arraign(spec) end)

exports('OpenCase', function(spec)
    if type(spec) ~= 'table' or not tonumber(spec.charId) then return false, 'OpenCase takes { charId, charges }' end
    local priced = exports[Config.Police]:PriceCharges(spec.charges)
    if not priced or #priced.charges == 0 then return false, 'Pick at least one charge' end
    return Cases.open({ charId = tonumber(spec.charId), priced = priced, officerCharId = tonumber(spec.byCharId),
        dept = spec.dept, reportId = tonumber(spec.reportId) })
end)

exports('GetCase', function(id)
    local r = Cases.get(id)
    if not r then return false, 'No such case' end
    return r
end)

exports('GetCases', function(filter)
    filter = type(filter) == 'table' and filter or {}
    if tonumber(filter.charId) then return Cases.list('`charId` = ?', { tonumber(filter.charId) }, 60) end
    if filter.status == 'open' or filter.status == 'closed' then return Cases.list('`status` = ?', { filter.status }, 120) end
    return Cases.list('1 = 1', {}, 120)
end)

exports('SetBail', function(id, amount) return Cases.setBail(id, amount) end)
exports('PostBail', function(id, payer) return Cases.postBail(id, tonumber(payer)) end)
exports('ScheduleHearing', function(id, at, room) return Cases.schedule(id, at, room) end)
exports('Rule', function(id, verdict, opts)
    opts = type(opts) == 'table' and opts or {}
    return Cases.rule(id, verdict, opts.codes or {}, opts.applyBail == true, tonumber(opts.byCharId))
end)
