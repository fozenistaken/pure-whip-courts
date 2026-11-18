local root = (arg and arg[1]) or '.'
local failed, passed = 0, 0

function Test(name, fn)
    local ok, err = pcall(fn)
    if ok then passed = passed + 1 else failed = failed + 1; print('FAIL ' .. name .. ': ' .. tostring(err)) end
end

function Eq(a, b, what)
    if a ~= b then error(('%s: expected %s, got %s'):format(what or 'value', tostring(b), tostring(a)), 2) end
end

dofile(root .. '/shared/util.lua')
dofile(root .. '/shared/court_logic.lua')
dofile(root .. '/tests/court_test.lua')

print(failed == 0 and ('ALL PASS (' .. passed .. ')') or ('FAILED ' .. failed .. ' of ' .. (failed + passed)))
os.exit(failed == 0 and 0 or 1)
