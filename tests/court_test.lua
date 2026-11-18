local Court = PWC.Court
local BAIL = { multiplier = 2.0, round = 50, min = 250, denyAboveMonths = 60 }

Test('case numbers', function()
    Eq(Court.caseNo(42, 2026), 'CR-2026-0042', 'padded')
    Eq(Court.caseNo(12345, 2026), 'CR-2026-12345', 'long')
end)

Test('bail follows the charges', function()
    local a, s = Court.bail({ months = 0, fine = 500 }, BAIL)
    Eq(a, 0, 'fine-only charges: no bail'); Eq(s, 'released', 'released')
    a, s = Court.bail({ months = 10, fine = 1020 }, BAIL)
    Eq(a, 2050, 'twice the fine, rounded to 50'); Eq(s, 'due', 'due')
    a = Court.bail({ months = 5, fine = 30 }, BAIL)
    Eq(a, 250, 'at least the minimum')
    a, s = Court.bail({ months = 61, fine = 9000 }, BAIL)
    Eq(a, nil, 'too serious'); Eq(s, 'denied', 'denied')
    a, s = Court.bail({ months = 60, fine = 100 }, BAIL)
    Eq(s, 'due', 'the limit itself still gets bail')
end)

Test('plea discount', function()
    local d = Court.discount({ months = 15, fine = 4000 }, 0.25)
    Eq(d.months, 11, 'months rounded'); Eq(d.fine, 3000, 'fine')
    d = Court.discount({ months = 1, fine = 0 }, 0.75)
    Eq(d.months, 1, 'never below one month'); Eq(d.fine, 0, 'no fine stays none')
    d = Court.discount({ months = 10, fine = 100 }, 2)
    Eq(d.months, 3, 'share capped at 0.75')
end)

Test('bail settles against a fine', function()
    local s = Court.settle(2000, 500, true)
    Eq(s.toFine, 500, 'fine paid from bail'); Eq(s.back, 1500, 'rest back')
    s = Court.settle(300, 500, true)
    Eq(s.toFine, 300, 'all of it'); Eq(s.back, 0, 'nothing back')
    s = Court.settle(2000, 500, false)
    Eq(s.toFine, 0, 'not applied'); Eq(s.back, 2000, 'all back')
end)

Test('keep picks the charges that stand', function()
    local list = { { code = 'A' }, { code = 'B' }, { code = 'C' } }
    local kept = Court.keep(list, { 'C', 'A' })
    Eq(#kept, 2, 'two'); Eq(kept[1].code, 'A', 'order kept'); Eq(kept[2].code, 'C', 'second')
end)

Test('reminders fire once each, before the hearing', function()
    local sent = {}
    local at = 10000
    Eq(Court.due(at - 20 * 60, at, { 15, 2 }, sent), nil, 'too early')
    local m, key = Court.due(at - 14 * 60, at, { 15, 2 }, sent)
    Eq(m, 15, 'first reminder'); sent[key] = true
    Eq(Court.due(at - 10 * 60, at, { 15, 2 }, sent), nil, 'not twice')
    Eq(Court.due(at - 60, at, { 15, 2 }, sent), 2, 'second reminder')
    Eq(Court.due(at + 5, at, { 15, 2 }, {}), nil, 'none after it starts')
end)
