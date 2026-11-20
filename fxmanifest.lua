fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'pure-whip-courts'
author 'PureFX (purefx.dev)'
description 'Courts and bail for WHIP: pleas at booking, cases, bail, hearings, plea deals, lawyers and the court app'
version '1.0.0'

dependency 'whip_core'
whip_requires '1.0'

shared_scripts {
    '@whip_core/lib/satellite.lua',
    'config.lua',
    'shared/util.lua',
    'shared/court_logic.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/jobs.lua',
    'server/cases.lua',
    'server/booking.lua',
    'server/app.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

files {
    'html/court/module.js',
    'html/court/fonts/*.woff2',
}
