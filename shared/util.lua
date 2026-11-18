PWC = { RES = GetCurrentResourceName and GetCurrentResourceName() or 'pure-whip-courts' }

function PWC.event(suffix) return PWC.RES .. ':' .. suffix end

function PWC.clean(text, max)
    if type(text) ~= 'string' then return nil end
    text = text:gsub('[%z\1-\8\11\12\14-\31\127]', ''):gsub('^%s+', ''):gsub('%s+$', '')
    if text == '' then return nil end
    return text:sub(1, max or 200)
end
