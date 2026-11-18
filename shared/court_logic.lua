local Court = {}
PWC.Court = Court

function Court.caseNo(id, year)
    return ('CR-%d-%04d'):format(year, id)
end

function Court.bail(totals, cfg)
    local months, fine = totals.months or 0, totals.fine or 0
    if months <= 0 then return 0, 'released' end
    if months > cfg.denyAboveMonths then return nil, 'denied' end
    local raw = fine * cfg.multiplier
    local amount = math.max(cfg.min, math.floor(raw / cfg.round + 0.5) * cfg.round)
    return amount, 'due'
end

function Court.discount(totals, share)
    share = math.max(0, math.min(0.75, share or 0))
    local months = totals.months or 0
    local fine = totals.fine or 0
    return {
        months = months > 0 and math.max(1, math.floor(months * (1 - share) + 0.5)) or 0,
        fine = fine > 0 and math.max(1, math.floor(fine * (1 - share) + 0.5)) or 0,
    }
end

function Court.settle(bail, fine, apply)
    bail, fine = bail or 0, fine or 0
    if not apply or fine <= 0 then return { toFine = 0, back = bail } end
    local toFine = math.min(bail, fine)
    return { toFine = toFine, back = bail - toFine }
end

function Court.keep(charges, codes)
    local want = {}
    for _, c in ipairs(codes or {}) do want[c] = true end
    local out = {}
    for _, c in ipairs(charges or {}) do
        if want[c.code] then out[#out + 1] = c end
    end
    return out
end

function Court.due(now, at, before, sent)
    for _, mins in ipairs(before) do
        local key = tostring(mins)
        if not sent[key] and now >= at - mins * 60 and now < at then return mins, key end
    end
    return nil
end
