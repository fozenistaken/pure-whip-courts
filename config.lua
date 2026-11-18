Config = {}

-- The police resource whose exports book, jail, fine and issue warrants (it must be started).
-- Example: Config.Police = 'pure-whip-police'
Config.Police = 'pure-whip-police'

-- The court's WHIP jobs. key: the job key in /whip -> Jobs. ranks: used only when the job is first made; afterwards
-- WHIP's Job Manager owns them. Permissions: rule (verdicts), bail (set or deny bail), schedule (hearings),
-- prosecute (plea deals, dropping charges), represent (lawyers: act for clients who picked them).
-- Example rank: { name = 'Magistrate', level = 50, permissions = { rule = true, bail = true, schedule = true } }
Config.Justice = {
    key = 'doj', name = 'Department of Justice', icon = 'shield',
    ranks = {
        { name = 'Chief Justice', level = 100 },
        { name = 'Judge', level = 60, permissions = { rule = true, bail = true, schedule = true } },
        { name = 'Prosecutor', level = 40, permissions = { prosecute = true, schedule = true } },
        { name = 'Clerk', level = 20, permissions = { schedule = true } },
    },
}
Config.Lawyers = {
    key = 'lawyer', name = 'Defence Attorneys', icon = 'id',
    ranks = {
        { name = 'Partner', level = 100 },
        { name = 'Attorney', level = 40, permissions = { represent = true } },
        { name = 'Paralegal', level = 10 },
    },
}

-- The plea at booking. seconds: how long the suspect has to answer, 10-120 (no answer counts as not guilty).
-- discount: share taken off time and fine for pleading guilty, 0-0.75 (0.25 = a quarter off).
-- Example: Config.Plea = { seconds = 45, discount = 0.3 }
Config.Plea = { seconds = 30, discount = 0.25 }

-- Bail for a not-guilty plea. multiplier: bail = the charges' total fine times this, 0.5-10, rounded to round ($),
-- at least min ($). Charges with no prison time: released with no bail. denyAboveMonths: total months above this
-- get no bail (held until the hearing or the remand ends), 1-1000.
-- Example: Config.Bail = { multiplier = 3.0, round = 100, min = 500, denyAboveMonths = 40 }
Config.Bail = { multiplier = 2.0, round = 50, min = 250, denyAboveMonths = 60 }

-- Remand: minutes a not-guilty suspect is held when bail is not posted, 5-240. After that they are released to wait
-- for their hearing. Example: Config.Remand = { minutes = 45 }
Config.Remand = { minutes = 30 }

-- Days an open case waits for a hearing before it is dismissed and bail paid back, 1-60. Keeps cases from sticking
-- on a server where no judge plays. Example: Config.CaseDays = 3
Config.CaseDays = 7

-- Minutes before a hearing the people in it get a phone reminder, each 1-120. Example: { 30, 5 }
Config.Reminders = { 15, 2 }

-- Hearings: how many days ahead a hearing can be set, 1-30, and the courtrooms to pick from. coords: optional, gives
-- a waypoint in the app; nil for none. Example: { label = 'Courtroom 2', coords = vector3(-544.0, -204.0, 38.2) }
Config.HearingDays = 7
Config.Courtrooms = {
    { label = 'Courtroom 1' },
    { label = 'Courtroom 2' },
}

-- Forfeited bail goes to this bank account number (e.g. 'WB-123456', a city account an admin made); nil: it is gone.
Config.Account = nil
