local Court, Cases = PWC.Court, PWC.Cases
local asking = {}
local bySuspect = {}

local function police() return exports[Config.Police] end

local function titles(charges)
    local out = {}
    for _, c in ipairs(charges) do out[#out + 1] = c.count > 1 and (c.title .. ' x' .. c.count) or c.title end
    return table.concat(out, ', ')
end

local function ask(suspect, summary)
    local token = ('%d-%d-%d'):format(suspect, GetGameTimer(), math.random(100000, 999999))
    local p = promise.new()
    asking[token] = { suspect = suspect, p = p }
    bySuspect[suspect] = token
    TriggerClientEvent(PWC.event('plea'), suspect, token, summary)
    SetTimeout((Config.Plea.seconds + 5) * 1000, function()
        if asking[token] then asking[token] = nil; p:resolve(false) end
    end)
    local guilty = Citizen.Await(p)
    if bySuspect[suspect] == token then bySuspect[suspect] = nil end
    return guilty
end

local function pleadGuilty(spec, charId, priced, cut)
    local reason = 'Pleaded guilty: ' .. titles(priced.charges)
    local id = MySQL.insert.await(([[INSERT INTO `%s` (`charId`, `status`, `outcome`, `charges`, `months`, `fine`, `officerCharId`, `dept`,
        `reportId`, `sentenceMonths`, `sentenceFine`, `createdAt`, `closedAt`) VALUES (?, 'closed', 'plea', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)]])
        :format(Cases.T.cases), { charId, json.encode(priced.charges), priced.months, priced.fine, spec.officerCharId, spec.dept,
            spec.reportId, cut.months, cut.fine, os.time(), os.time() })
    if id then Cases.note(id, 'ruling', ('Pleaded guilty at booking: %d months, $%d.'):format(cut.months, cut.fine), charId) end
    if cut.fine > 0 then police():Fine(charId, cut.fine, { reason = reason, by = spec.officer, dept = spec.dept, reportId = spec.reportId }) end
    if cut.months > 0 then
        local ok, why = police():Jail(spec.suspect, cut.months, { reason = reason, by = spec.officer, dept = spec.dept, reportId = spec.reportId })
        if not ok then return Whip.core:NotifyPlayer(spec.officer, 'Prison refused: ' .. tostring(why), 'error') end
    end
    Whip.core:NotifyPlayer(spec.officer, ('Guilty plea: %d months, $%d.'):format(cut.months, cut.fine), 'success', 8000)
end

local function pleadNotGuilty(spec, charId, priced)
    local id, state, amount = Cases.open({ charId = charId, priced = priced, officerCharId = spec.officerCharId,
        dept = spec.dept, reportId = spec.reportId })
    if not id then return Whip.core:NotifyPlayer(spec.officer, state or 'The case could not be filed', 'error') end
    local no = Cases.no(id)
    if state == 'released' then
        police():Uncuff(spec.suspect, { by = spec.officer })
        Whip.core:NotifyPlayer(spec.suspect, ('Not guilty plea. %s is open; you are free until the hearing.'):format(no), 'info', 10000)
        return Whip.core:NotifyPlayer(spec.officer, ('Not guilty: %s filed. No bail on these charges, they are free to go.'):format(no), 'info', 8000)
    end
    local held, why = police():Hold(spec.suspect, Config.Remand.minutes, { by = spec.officer, dept = spec.dept, reason = 'Held for court, ' .. no })
    if not held then Whip.core:NotifyPlayer(spec.officer, 'Remand refused: ' .. tostring(why), 'error') end
    Whip.core:NotifyPlayer(spec.suspect, state == 'due'
        and ('Not guilty plea. %s: bail is $%d. Anyone can post it in the Court app.'):format(no, amount)
        or ('Not guilty plea. %s: bail denied, held until the hearing or the remand ends.'):format(no), 'info', 12000)
    Whip.core:NotifyPlayer(spec.officer, ('Not guilty: %s filed, %s.'):format(no, state == 'due' and ('bail $' .. amount) or 'no bail'), 'info', 8000)
end

local function arraign(spec)
    if type(spec) ~= 'table' then return false, 'Arraign takes { officer, suspect, charges }' end
    local officer, suspect = tonumber(spec.officer), tonumber(spec.suspect)
    local charId = suspect and Whip.core:GetCharId(suspect)
    if not officer or not charId then return false, 'They are not here' end
    if bySuspect[suspect] then return false, 'They are already being asked for a plea' end
    local priced = police():PriceCharges(spec.charges)
    if not priced or #priced.charges == 0 then return false, 'Pick at least one charge' end
    spec.officer, spec.suspect, spec.officerCharId = officer, suspect, Whip.core:GetCharId(officer)
    local cut = Court.discount(priced, Config.Plea.discount)
    local bail, state = Court.bail(priced, Config.Bail)
    CreateThread(function()
        local guilty = ask(suspect, {
            charges = titles(priced.charges), seconds = Config.Plea.seconds,
            guilty = { months = cut.months, fine = cut.fine, off = math.floor(Config.Plea.discount * 100 + 0.5) },
            trial = { months = priced.months, fine = priced.fine, bail = bail, state = state, remand = Config.Remand.minutes },
        })
        if Whip.core:GetCharId(suspect) ~= charId then return Whip.core:NotifyPlayer(officer, 'They left before the plea', 'error') end
        if guilty then pleadGuilty(spec, charId, priced, cut) else pleadNotGuilty(spec, charId, priced) end
    end)
    return true
end

AddEventHandler('playerDropped', function()
    local token = bySuspect[source]
    if token and asking[token] then asking[token].p:resolve(false); asking[token] = nil end
    bySuspect[source] = nil
end)

Whip.register(function()
    Whip.core:SecureEvent(PWC.event('plea'), {
        rateLimit = 1000,
        params = { { 'token', 'string', 40 }, { 'guilty', 'bool' } },
    }, function(source, _, token, guilty)
        local w = asking[token]
        if not w or w.suspect ~= source then return end
        asking[token] = nil
        w.p:resolve(guilty == true)
    end)
end)

PWC.arraign = arraign
