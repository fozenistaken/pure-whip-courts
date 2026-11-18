local Court = PWC.Court
local T = { cases = 'pure_whip_courts_cases', docket = 'pure_whip_courts_docket' }
local APP = 'pwcourt'

local Cases = { T = T, reminded = {} }
PWC.Cases = Cases

local function police() return exports[Config.Police] end
local function now() return os.time() end
local function year() return tonumber(os.date('%Y')) end

function Cases.no(id) return Court.caseNo(id, year()) end

local function inWords(at)
    local mins = math.max(0, math.floor((at - now()) / 60 + 0.5))
    if mins < 60 then return ('in %d min'):format(mins) end
    local h, m = math.floor(mins / 60), mins % 60
    if h < 24 then return m > 0 and ('in %d h %d min'):format(h, m) or ('in %d h'):format(h) end
    return ('in %d days'):format(math.floor(h / 24 + 0.5))
end

local function sourceOf(charId)
    charId = tonumber(charId)
    if not charId then return nil end
    for src, p in pairs(Whip.core:GetPlayers({ light = true }) or {}) do
        if p.charId == charId then return tonumber(src) end
    end
    return nil
end
Cases.sourceOf = sourceOf

local function tell(charId, title, text)
    local src = sourceOf(charId)
    if not src then return end
    if GetResourceState('whip_phone') == 'started' then
        exports.whip_phone:Notify(src, { app = APP, title = title, text = text, kind = 'command' })
        exports.whip_phone:Push(src, APP, 'changed', {})
    else
        Whip.core:NotifyPlayer(src, title .. ': ' .. text, 'info', 8000)
    end
end

local function decode(row)
    if not row then return nil end
    row.charges = type(row.charges) == 'string' and json.decode(row.charges) or {}
    row.deal = type(row.deal) == 'string' and json.decode(row.deal) or nil
    row.no = Cases.no(row.id)
    return row
end

function Cases.note(id, kind, text, byCharId)
    MySQL.insert.await(('INSERT INTO `%s` (`caseId`, `kind`, `text`, `byCharId`, `at`) VALUES (?, ?, ?, ?, ?)'):format(T.docket),
        { id, kind, PWC.clean(text, 500) or kind, byCharId, now() })
end

function Cases.row(id)
    return decode(MySQL.single.await(('SELECT * FROM `%s` WHERE `id` = ?'):format(T.cases), { tonumber(id) }))
end

local function set(id, fields)
    local cols, vals = {}, {}
    for k, v in pairs(fields) do cols[#cols + 1] = ('`%s` = ?'):format(k); vals[#vals + 1] = v end
    vals[#vals + 1] = id
    MySQL.update.await(('UPDATE `%s` SET %s WHERE `id` = ?'):format(T.cases, table.concat(cols, ', ')), vals)
end

local function titles(charges)
    local out = {}
    for _, c in ipairs(charges or {}) do out[#out + 1] = (c.count or 1) > 1 and (c.title .. ' x' .. c.count) or c.title end
    return table.concat(out, ', ')
end

local function totals(charges)
    local fine, months = 0, 0
    for _, c in ipairs(charges or {}) do fine = fine + (c.fine or 0); months = months + (c.months or 0) end
    return { fine = fine, months = months }
end
Cases.totals = totals

local function remanded(charId)
    local s = police():GetSentence(charId)
    return s and (s.months or 0) == 0 and s or nil
end

local function freeFromRemand(charId, why)
    local s = remanded(charId)
    if not s or not s.online or not s.source then return false end
    return police():Release(s.source, { early = true, reason = why })
end

function Cases.open(spec)
    local charId = tonumber(spec.charId)
    local priced = spec.priced
    local amount, state = Court.bail(priced, Config.Bail)
    local id = MySQL.insert.await(([[INSERT INTO `%s` (`charId`, `status`, `charges`, `months`, `fine`, `bail`, `bailState`,
        `officerCharId`, `dept`, `reportId`, `createdAt`) VALUES (?, 'open', ?, ?, ?, ?, ?, ?, ?, ?, ?)]]):format(T.cases),
        { charId, json.encode(priced.charges), priced.months, priced.fine, amount or 0, state == 'released' and 'none' or state,
            spec.officerCharId, spec.dept, spec.reportId, now() })
    if not id then return false, 'The case could not be filed' end
    Cases.note(id, 'filed', ('Not guilty plea. Charged with %s.'):format(titles(priced.charges)), spec.officerCharId)
    if state == 'due' then Cases.note(id, 'bail', ('Bail set at $%d.'):format(amount))
    elseif state == 'denied' then Cases.note(id, 'bail', 'Bail denied: held until the hearing or the end of remand.')
    else Cases.note(id, 'bail', 'Released to await the hearing; no bail on these charges.') end
    TriggerEvent(PWC.event('caseOpened'), { id = id, charId = charId, bail = amount, bailState = state })
    return id, state, amount
end

function Cases.list(where, args, limit)
    local rows = MySQL.query.await(('SELECT * FROM `%s` WHERE %s ORDER BY `status` = \'open\' DESC, `id` DESC LIMIT %d')
        :format(T.cases, where, limit or 60), args) or {}
    local ids = {}
    for _, r in ipairs(rows) do decode(r); ids[#ids + 1] = r.charId end
    local names = #ids > 0 and Whip.core:GetCharacterNames(ids) or {}
    for _, r in ipairs(rows) do r.name = names[r.charId] end
    return rows
end

function Cases.get(id)
    local r = Cases.row(id)
    if not r then return nil end
    r.docket = MySQL.query.await(('SELECT `kind`, `text`, `byCharId`, `at` FROM `%s` WHERE `caseId` = ? ORDER BY `id`'):format(T.docket),
        { r.id }) or {}
    local ids = { r.charId, r.officerCharId, r.lawyerCharId, r.judgeCharId }
    for _, d in ipairs(r.docket) do ids[#ids + 1] = d.byCharId end
    local list, seen = {}, {}
    for _, v in pairs(ids) do if v and not seen[v] then seen[v] = true; list[#list + 1] = v end end
    local names = #list > 0 and Whip.core:GetCharacterNames(list) or {}
    r.name, r.officer, r.lawyer, r.judge = names[r.charId], names[r.officerCharId], names[r.lawyerCharId], names[r.judgeCharId]
    for _, d in ipairs(r.docket) do d.by = names[d.byCharId] end
    r.online = sourceOf(r.charId) ~= nil
    r.held = remanded(r.charId) ~= nil
    return r
end

local function openCase(id)
    local r = Cases.row(id)
    if not r then return nil, 'No such case' end
    if r.status ~= 'open' then return nil, 'That case is closed' end
    return r
end

local function claim(id)
    local n = MySQL.update.await(("UPDATE `%s` SET `status` = 'closing' WHERE `id` = ? AND `status` = 'open'"):format(T.cases), { id })
    return n == 1
end

local function settled(id, fn)
    local ok, err = pcall(fn)
    if ok then return true end
    MySQL.update.await(("UPDATE `%s` SET `status` = 'open' WHERE `id` = ? AND `status` = 'closing'"):format(T.cases), { id })
    print(('[%s] case %d: %s'):format(PWC.RES, id, tostring(err)))
    return false, 'Something went wrong; the case is still open'
end

function Cases.postBail(id, payer)
    local r, why = openCase(id)
    if not r then return false, why end
    if r.bailState ~= 'due' then return false, r.bailState == 'denied' and 'Bail was denied' or 'There is no bail to pay' end
    local n = MySQL.update.await(("UPDATE `%s` SET `bailState` = 'paying' WHERE `id` = ? AND `bailState` = 'due'"):format(T.cases), { r.id })
    if n ~= 1 then return false, 'Someone is posting this bail right now' end
    local receipt, err = Whip.core:ChargePlayer(payer, r.bail, { reason = ('Bail, %s'):format(r.no) })
    if not receipt then
        set(r.id, { bailState = 'due' })
        return false, err
    end
    local payerChar = Whip.core:GetCharId(payer)
    set(r.id, { bailState = 'posted', bailPaid = r.bail, bailPayer = payerChar })
    Cases.note(r.id, 'bail', ('Bail of $%d posted.'):format(r.bail), payerChar)
    freeFromRemand(r.charId, 'Bail posted')
    tell(r.charId, 'Bail posted', ('%s: you are free until your hearing.'):format(r.no))
    TriggerEvent(PWC.event('bailPosted'), { id = r.id, charId = r.charId, amount = r.bail, payer = payerChar })
    return true
end

function Cases.setBail(id, amount, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    if r.bailState == 'posted' then return false, 'Bail is already posted' end
    if amount == nil then
        set(r.id, { bailState = 'denied', bail = 0 })
        Cases.note(r.id, 'bail', 'Bail denied by the court.', byChar)
    else
        amount = math.max(0, math.min(10000000, math.floor(tonumber(amount) or 0)))
        set(r.id, { bailState = amount > 0 and 'due' or 'none', bail = amount })
        Cases.note(r.id, 'bail', amount > 0 and ('Bail set at $%d by the court.'):format(amount) or 'Released on their own word.', byChar)
        if amount == 0 then freeFromRemand(r.charId, 'Released by the court') end
    end
    tell(r.charId, 'Bail changed', ('%s: open the Court app.'):format(r.no))
    return true
end

function Cases.schedule(id, at, room, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    at = math.floor(tonumber(at) or 0)
    if at < now() + 60 or at > now() + Config.HearingDays * 86400 then
        return false, ('Pick a time from now to %d days ahead'):format(Config.HearingDays)
    end
    local known = false
    for _, c in ipairs(Config.Courtrooms) do if c.label == room then known = true end end
    if not known then return false, 'Pick a courtroom' end
    set(r.id, { hearingAt = at, courtroom = room, judgeCharId = byChar })
    Cases.reminded[r.id] = {}
    Cases.note(r.id, 'hearing', ('Hearing set in %s.'):format(room), byChar)
    for _, who in ipairs({ r.charId, r.lawyerCharId, r.officerCharId }) do
        if who then tell(who, 'Hearing set', ('%s: %s, %s.'):format(r.no, inWords(at), room)) end
    end
    TriggerEvent(PWC.event('hearingSet'), { id = r.id, at = at, courtroom = room })
    return true
end

function Cases.requestLawyer(id, lawyerChar, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    if r.charId ~= byChar then return false, 'Only the defendant picks their lawyer' end
    local ok = false
    for _, l in ipairs(PWC.Jobs.lawyers()) do if l.charId == lawyerChar then ok = true end end
    if not ok then return false, 'That person is not an attorney' end
    set(r.id, { lawyerCharId = lawyerChar, lawyerState = 'requested' })
    Cases.note(r.id, 'lawyer', 'The defendant asked for an attorney.', byChar)
    tell(lawyerChar, 'New client', ('%s wants you to represent them.'):format(r.no))
    return true
end

function Cases.answerLawyer(id, lawyerChar, accept)
    local r, why = openCase(id)
    if not r then return false, why end
    if r.lawyerCharId ~= lawyerChar or r.lawyerState ~= 'requested' then return false, 'There is no request for you' end
    if accept then
        set(r.id, { lawyerState = 'accepted' })
        Cases.note(r.id, 'lawyer', 'Attorney took the case.', lawyerChar)
        tell(r.charId, 'Your attorney', ('%s: your attorney took the case.'):format(r.no))
    else
        MySQL.update.await(('UPDATE `%s` SET `lawyerCharId` = NULL, `lawyerState` = NULL WHERE `id` = ?'):format(T.cases), { r.id })
        Cases.note(r.id, 'lawyer', 'Attorney declined the case.', lawyerChar)
        tell(r.charId, 'Your attorney', ('%s: the attorney declined. Pick another.'):format(r.no))
    end
    return true
end

local function sentence(r, charges, how, applyBail, byChar)
    local t = totals(charges)
    if how == 'deal' then t = Court.discount(t, Config.Plea.discount) end
    local bail = r.bailState == 'posted' and (r.bailPaid or 0) or 0
    local s = Court.settle(bail, t.fine, applyBail)
    local fine = t.fine - s.toFine
    local reason = ('%s: %s'):format(r.no, titles(charges))
    if fine > 0 then police():Fine(r.charId, fine, { reason = reason, dept = r.dept }) end
    if bail > 0 then
        if s.back > 0 then Whip.core:PayPlayer({ charId = r.bailPayer or r.charId }, s.back, { reason = ('Bail returned, %s'):format(r.no) }) end
        set(r.id, { bailState = s.toFine > 0 and 'applied' or 'returned' })
    end
    local src = sourceOf(r.charId)
    if t.months > 0 then
        if src then
            freeFromRemand(r.charId, 'Sentenced')
            local ok, why = police():Jail(src, t.months, { reason = 'Court sentence, ' .. r.no, dept = r.dept })
            if not ok then set(r.id, { serveMonths = t.months }); print(('[%s] %s jail: %s'):format(PWC.RES, r.no, tostring(why))) end
        else
            set(r.id, { serveMonths = t.months })
        end
    else
        freeFromRemand(r.charId, 'Case over')
    end
    set(r.id, { sentenceMonths = t.months, sentenceFine = t.fine })
    return t
end

local function close(r, outcome, text, byChar)
    set(r.id, { status = 'closed', outcome = outcome, closedAt = now(), judgeCharId = byChar or r.judgeCharId })
    MySQL.update.await(("UPDATE `%s` SET `bailState` = 'none' WHERE `id` = ? AND `bailState` IN ('due', 'denied')"):format(T.cases), { r.id })
    Cases.note(r.id, 'ruling', text, byChar)
    Cases.reminded[r.id] = nil
    TriggerEvent(PWC.event('ruled'), { id = r.id, charId = r.charId, outcome = outcome })
    TriggerEvent(PWC.event('caseClosed'), { id = r.id, charId = r.charId, outcome = outcome })
end

local function giveBailBack(r)
    if r.bailState ~= 'posted' then return end
    Whip.core:PayPlayer({ charId = r.bailPayer or r.charId }, r.bailPaid or 0, { reason = ('Bail returned, %s'):format(r.no) })
    set(r.id, { bailState = 'returned' })
end

local function forfeit(r)
    if r.bailState ~= 'posted' then return end
    set(r.id, { bailState = 'forfeited' })
    local number = Config.Account
    local acc = type(number) == 'string' and number ~= '' and Whip.core:GetBankAccount({ number = number })
    if acc then Whip.core:BankSystemDeposit(acc.accountId, r.bailPaid or 0, { reason = ('Forfeited bail, %s'):format(r.no) }) end
end

function Cases.rule(id, verdict, codes, applyBail, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    if verdict ~= 'guilty' and verdict ~= 'not_guilty' and verdict ~= 'dismissed' and verdict ~= 'no_show' then
        return false, 'Pick a verdict'
    end
    local kept = Court.keep(r.charges, codes)
    if verdict == 'guilty' and #kept == 0 then return false, 'Pick the charges they are guilty of' end
    if not claim(r.id) then return false, 'Someone else is ruling on this case' end
    return settled(r.id, function()
        if verdict == 'guilty' then
            local t = sentence(r, kept, 'trial', applyBail, byChar)
            close(r, 'guilty', ('Guilty of %s. %d months, $%d.'):format(titles(kept), t.months, t.fine), byChar)
            tell(r.charId, 'Verdict: guilty', ('%s: %d months, $%d fine.'):format(r.no, t.months, t.fine))
        elseif verdict == 'not_guilty' or verdict == 'dismissed' then
            giveBailBack(r)
            freeFromRemand(r.charId, 'Case over')
            close(r, verdict, verdict == 'dismissed' and 'Case dismissed.' or 'Not guilty on all charges.', byChar)
            tell(r.charId, verdict == 'dismissed' and 'Case dismissed' or 'Verdict: not guilty', ('%s is closed.'):format(r.no))
        elseif verdict == 'no_show' then
            forfeit(r)
            police():IssueWarrant(r.charId, { reason = ('Failed to appear in court, %s'):format(r.no), days = 14, dept = r.dept })
            close(r, 'no_show', 'Failed to appear: bail forfeited, warrant issued.', byChar)
            tell(r.charId, 'Failed to appear', ('%s: a warrant is out for your arrest.'):format(r.no))
        end
    end)
end

function Cases.offerDeal(id, codes, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    local kept = Court.keep(r.charges, codes)
    if #kept == 0 then return false, 'A deal keeps at least one charge' end
    local t = Court.discount(totals(kept), Config.Plea.discount)
    set(r.id, { deal = json.encode({ codes = codes, months = t.months, fine = t.fine, by = byChar }) })
    Cases.note(r.id, 'deal', ('Plea deal offered: guilty of %s for %d months and $%d.'):format(titles(kept), t.months, t.fine), byChar)
    tell(r.charId, 'Plea deal offered', ('%s: %d months, $%d. Open the Court app to answer.'):format(r.no, t.months, t.fine))
    if r.lawyerCharId then tell(r.lawyerCharId, 'Plea deal offered', r.no) end
    return true
end

function Cases.answerDeal(id, byChar, accept)
    local r, why = openCase(id)
    if not r then return false, why end
    if r.charId ~= byChar then return false, 'Only the defendant answers a deal' end
    if not r.deal then return false, 'There is no deal on the table' end
    if accept and not claim(r.id) then return false, 'The case is being ruled on' end
    if not accept then
        MySQL.update.await(('UPDATE `%s` SET `deal` = NULL WHERE `id` = ?'):format(T.cases), { r.id })
        Cases.note(r.id, 'deal', 'The defendant turned the deal down.', byChar)
        return true
    end
    return settled(r.id, function()
        local kept = Court.keep(r.charges, r.deal.codes)
        local t = sentence(r, kept, 'deal', true, r.deal.by)
        close(r, 'deal', ('Took the plea deal: guilty of %s. %d months, $%d.'):format(titles(kept), t.months, t.fine), r.deal.by)
    end)
end

function Cases.motion(id, text, byChar)
    local r, why = openCase(id)
    if not r then return false, why end
    text = PWC.clean(text, 400)
    if not text then return false, 'Write the motion first' end
    Cases.note(r.id, 'motion', text, byChar)
    if r.judgeCharId and r.judgeCharId ~= byChar then tell(r.judgeCharId, 'New motion', r.no) end
    return true
end

local function sweep()
    local t = now()
    local stale = MySQL.query.await(("SELECT * FROM `%s` WHERE `status` = 'open' AND `hearingAt` IS NULL AND `createdAt` < ?")
        :format(T.cases), { t - Config.CaseDays * 86400 }) or {}
    for _, r in ipairs(stale) do
        decode(r)
        if not claim(r.id) then goto continue end
        giveBailBack(r)
        freeFromRemand(r.charId, 'Case over')
        close(r, 'expired', ('No hearing within %d days: dismissed.'):format(Config.CaseDays))
        tell(r.charId, 'Case dismissed', ('%s: no hearing was held in time.'):format(r.no))
        ::continue::
    end
    local soon = MySQL.query.await(("SELECT `id`, `charId`, `lawyerCharId`, `officerCharId`, `judgeCharId`, `hearingAt`, `courtroom` FROM `%s` WHERE `status` = 'open' AND `hearingAt` BETWEEN ? AND ?")
        :format(T.cases), { t, t + 130 * 60 }) or {}
    for _, r in ipairs(soon) do
        Cases.reminded[r.id] = Cases.reminded[r.id] or {}
        local mins, key = Court.due(t, r.hearingAt, Config.Reminders, Cases.reminded[r.id])
        if mins then
            Cases.reminded[r.id][key] = true
            for _, who in ipairs({ r.charId, r.lawyerCharId, r.officerCharId, r.judgeCharId }) do
                if who then tell(who, 'Hearing soon', ('%s in %d min, %s.'):format(Cases.no(r.id), mins, r.courtroom or 'court')) end
            end
        end
    end
end

AddEventHandler('whip_core:player:loaded', function(e)
    if GetInvokingResource() ~= 'whip_core' or type(e) ~= 'table' or not e.source or not e.charId then return end
    local due = MySQL.single.await(('SELECT `id`, `serveMonths` FROM `%s` WHERE `charId` = ? AND `serveMonths` > 0 ORDER BY `id` LIMIT 1')
        :format(T.cases), { e.charId })
    if due then
        Wait(5000)
        local ok = police():Jail(e.source, due.serveMonths, { reason = 'Court sentence, ' .. Cases.no(due.id) })
        if ok then set(due.id, { serveMonths = 0 }) end
        return
    end
    local posted = MySQL.single.await(("SELECT `id` FROM `%s` WHERE `charId` = ? AND `status` = 'open' AND `bailState` = 'posted' LIMIT 1")
        :format(T.cases), { e.charId })
    if posted then
        Wait(5000)
        freeFromRemand(e.charId, 'Bail posted')
    end
end)

Whip.register(function()
    local ok = Whip.core:EnsureTable(T.cases, ([[CREATE TABLE IF NOT EXISTS `%s` (
        `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, `charId` INT UNSIGNED NOT NULL,
        `status` VARCHAR(8) NOT NULL DEFAULT 'open', `outcome` VARCHAR(16) NULL, `charges` LONGTEXT NOT NULL,
        `months` INT NOT NULL DEFAULT 0, `fine` INT NOT NULL DEFAULT 0, `bail` INT NOT NULL DEFAULT 0,
        `bailState` VARCHAR(12) NOT NULL DEFAULT 'none', `bailPaid` INT NULL, `bailPayer` INT UNSIGNED NULL,
        `officerCharId` INT UNSIGNED NULL, `dept` VARCHAR(50) NULL, `reportId` INT UNSIGNED NULL,
        `lawyerCharId` INT UNSIGNED NULL, `lawyerState` VARCHAR(12) NULL, `judgeCharId` INT UNSIGNED NULL,
        `hearingAt` INT UNSIGNED NULL, `courtroom` VARCHAR(60) NULL, `deal` TEXT NULL,
        `serveMonths` INT NOT NULL DEFAULT 0, `sentenceMonths` INT NULL, `sentenceFine` INT NULL,
        `createdAt` INT UNSIGNED NOT NULL, `closedAt` INT UNSIGNED NULL,
        INDEX (`charId`), INDEX (`status`), INDEX (`lawyerCharId`), INDEX (`hearingAt`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]]):format(T.cases))
    if not ok then print(('[%s] table %s could not be made'):format(PWC.RES, T.cases)) end
    ok = Whip.core:EnsureTable(T.docket, ([[CREATE TABLE IF NOT EXISTS `%s` (
        `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, `caseId` INT UNSIGNED NOT NULL,
        `kind` VARCHAR(12) NOT NULL, `text` VARCHAR(500) NOT NULL, `byCharId` INT UNSIGNED NULL, `at` INT UNSIGNED NOT NULL,
        INDEX (`caseId`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]]):format(T.docket))
    if not ok then print(('[%s] table %s could not be made'):format(PWC.RES, T.docket)) end
end)

CreateThread(function()
    Whip.ready()
    while true do
        Wait(30000)
        local ok, err = pcall(sweep)
        if not ok then print(('[%s] sweep: %s'):format(PWC.RES, tostring(err))) end
    end
end)
