local Cases, Jobs = PWC.Cases, PWC.Jobs
local NS = PWC.RES .. ':app'
local H = {}

local function num(v) return tonumber(v) and math.floor(tonumber(v)) or nil end

local function role(src, r)
    local me = Whip.core:GetCharId(src)
    if not me then return nil end
    if r.charId == me then return 'defendant', me end
    if r.lawyerCharId == me and Jobs.lawyer(src) then return 'lawyer', me end
    if Jobs.justice(src) then return 'justice', me end
    if r.officerCharId == me then return 'officer', me end
    return nil, me
end

local function visible(r, who)
    if who == 'justice' or who == 'defendant' or who == 'lawyer' then return r end
    return { id = r.id, no = r.no, name = r.name, status = r.status, outcome = r.outcome, charges = r.charges,
        hearingAt = r.hearingAt, courtroom = r.courtroom, bail = r.bail, bailState = r.bailState, docket = {} }
end

function H.me(src)
    local p = Whip.core:GetPlayers({ light = true })[src] or {}
    local rooms = {}
    for _, c in ipairs(Config.Courtrooms) do rooms[#rooms + 1] = { label = c.label, map = c.coords ~= nil } end
    return { charId = Whip.core:GetCharId(src), name = p.fullName, justice = Jobs.justice(src), lawyer = Jobs.lawyer(src),
        courtrooms = rooms, hearingDays = Config.HearingDays, discount = Config.Plea.discount }
end

function H.mine(src)
    local me = Whip.core:GetCharId(src)
    return Cases.list('`charId` = ?', { me }, 30)
end

function H.clients(src)
    if not Jobs.lawyer(src) then return false, 'Only attorneys have clients' end
    return Cases.list('`lawyerCharId` = ?', { Whip.core:GetCharId(src) }, 60)
end

function H.docket(src)
    if not Jobs.justice(src) then return false, 'Only court staff see the docket' end
    return Cases.list("`status` = 'open'", {}, 120)
end

function H.recent(src)
    if not Jobs.justice(src) then return false, 'Only court staff see the docket' end
    return Cases.list("`status` = 'closed'", {}, 40)
end

function H.case(src, a)
    local r = Cases.get(num(a.id))
    if not r then return false, 'No such case' end
    local who = role(src, r)
    r.as = who or 'public'
    return visible(r, who)
end

function H.lookup(_, a)
    local q = PWC.clean(a.q, 20)
    local id = q and num(q:match('(%d+)%s*$'))
    local r = id and Cases.get(id)
    if not r then return false, 'No case with that number' end
    return visible(r, nil)
end

function H.lawyers() return Jobs.lawyers() end

function H.postBail(src, a) return Cases.postBail(num(a.id), src) end

function H.requestLawyer(src, a) return Cases.requestLawyer(num(a.id), num(a.lawyer), Whip.core:GetCharId(src)) end

function H.answerLawyer(src, a)
    local l = Jobs.lawyer(src)
    if not l or not l.represent then return false, 'Your rank cannot take clients' end
    return Cases.answerLawyer(num(a.id), Whip.core:GetCharId(src), a.accept == true)
end

function H.answerDeal(src, a) return Cases.answerDeal(num(a.id), Whip.core:GetCharId(src), a.accept == true) end

function H.motion(src, a)
    local r = Cases.row(num(a.id))
    if not r then return false, 'No such case' end
    local who, me = role(src, r)
    if who ~= 'defendant' and who ~= 'lawyer' and who ~= 'justice' then return false, 'Only the parties file motions' end
    if who == 'lawyer' and r.lawyerState ~= 'accepted' then return false, 'Take the case first' end
    return Cases.motion(r.id, a.text, me)
end

local function staff(perm, fn)
    return function(src, a)
        local ok, why = Jobs.can(src, perm)
        if not ok then return false, why end
        return fn(src, a, Whip.core:GetCharId(src))
    end
end

H.setBail = staff('bail', function(_, a, me)
    if a.deny == true then return Cases.setBail(num(a.id), nil, me) end
    return Cases.setBail(num(a.id), num(a.amount), me)
end)

H.schedule = staff('schedule', function(_, a, me) return Cases.schedule(num(a.id), num(a.at), PWC.clean(a.room, 60), me) end)

H.deal = staff('prosecute', function(_, a, me)
    return Cases.offerDeal(num(a.id), type(a.codes) == 'table' and a.codes or {}, me)
end)

H.drop = staff('prosecute', function(_, a, me) return Cases.rule(num(a.id), 'dismissed', {}, false, me) end)

H.rule = staff('rule', function(_, a, me)
    return Cases.rule(num(a.id), a.verdict, type(a.codes) == 'table' and a.codes or {}, a.applyBail == true, me)
end)

function H.waypoint(src, a)
    for _, c in ipairs(Config.Courtrooms) do
        if c.label == a.room and c.coords then return Whip.core:SetPlayerWaypoint(src, c.coords) end
    end
    return false, 'That courtroom has no place on the map'
end

Whip.register(function()
    for action, fn in pairs(H) do
        Whip.core:SecureCallback(NS .. ':' .. action, { rateLimit = 300, params = { { 'args', 'any' } } }, function(source, _, args)
            local ok, result, why = pcall(fn, source, type(args) == 'table' and args or {})
            if not ok then
                print(('[%s] app %s failed: %s'):format(PWC.RES, action, tostring(result)))
                return false, 'Something went wrong'
            end
            if result == false then return false, why end
            if result == nil then return true end
            return result
        end)
    end
end)
