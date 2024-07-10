-- buttons.lua

function draw_button(text, x, y, width, active)
    if active then
        pal(4, 9)
    end

    -- draw corners
    spr(33, x, y)
    spr(33, x     , y + 8 , 1, 1, false, true)
    spr(33, x + (8 * (width - 1)), y     , 1, 1, true, false)
    spr(33, x + (8 * (width - 1)), y + 8 , 1, 1, true, true)
    
    -- draw top and bottom edges
    for i=1, width - 2 do
        spr(34, x + 8*i, y)
        spr(34, x + 8*i , y + 8)
    end

    local text_size = #text * 4
    local text_x = center(x, x + width * 8, text_size)
    local text_y = center(y, y + 16, 4)
    print(text, text_x, text_y, 5)
    
    -- reset palette
    pal(4, 4)
end
