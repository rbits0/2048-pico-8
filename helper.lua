-- helper.lua


-- centers width within outer range
-- returns the start position
function center(outer_start, outer_end, width)
    local middle = (outer_start + outer_end) / 2
    return flr(middle - (width / 2))
end


function reset_palette()
    pal({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0}, 1)
end