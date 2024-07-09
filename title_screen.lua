-- title_screen.lua

function title_screen_init()
    title_screen_palette()

    selected_button = 1
end


function title_screen_update()
    if btnp(⬆️) or btnp(⬇️) then
        if selected_button == 1 then
            selected_button = 2
        else
            selected_button = 1
        end
    end
end


function title_screen_draw()
    rectfill(0, 0, 127, 127, 9)
    map(0, 0)
    
    draw_buttons()
end


function title_screen_palette()
    reset_palette()
    pal(9, -10, 1)
    pal(10, -12, 1)
end


function draw_buttons()
    local width = 6
    local x_pos = 40

    draw_button("play", x_pos, 56, width, selected_button == 1)
    draw_button("settings", x_pos, 76, width, selected_button == 2)
end


function draw_button(text, x, y, width, active)
    if active then
        pal(4, 10)
    end

    -- draw corners
    spr(42, x, y)
    spr(42, x     , y + 8 , 1, 1, false, true)
    spr(42, x + (8 * (width - 1)), y     , 1, 1, true, false)
    spr(42, x + (8 * (width - 1)), y + 8 , 1, 1, true, true)
    
    -- draw top and bottom edges
    for i=1, width - 2 do
        spr(43, x + 8*i, y)
        spr(43, x + 8*i , y + 8)
    end

    local text_size = #text * 4
    local text_x = center(x, x + width * 8, text_size)
    local text_y = center(y, y + 16, 4)
    print(text, text_x, text_y, 7)
    
    -- reset palette
    pal(4, 4)
end


-- centers width within outer range
-- returns the start position
function center(outer_start, outer_end, width)
    local middle = (outer_start + outer_end) / 2
    return flr(middle - (width / 2))
end
