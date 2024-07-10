-- settings_screen.lua

function settings_screen_init()
    state = State.SETTINGS_SCREEN

    selected_button = 1
end


function settings_screen_update()
    if btnp(⬆️) then
        selected_button -= 1
    elseif btnp(⬇️) then
        selected_button += 1
    end
    if selected_button < 1 then
        selected_button = 3
    elseif selected_button > 3 then
        selected_button = 1
    end
    
    if btnp(🅾️) then
        if selected_button == 1 then
        elseif selected_button == 2 then
            -- reset highscore
            highscore = LongInt.new(0)
            dset(0, 0)
            dset(1, 0)
        elseif selected_button == 3 then
            title_screen_init()
        end
    end
    
    if btnp(❎) then
        -- back
        title_screen_init()
    end
end


function settings_screen_draw()
    rectfill(0, 0, 127, 127, 6)
    map(0, 0)

    draw_highscore()

    local width = 9
    local x_pos = 28

    draw_button("move speed", x_pos, 56, width, selected_button == 1)
    draw_button("reset highscore", x_pos, 76, width, selected_button == 2)
    draw_button("back", x_pos, 96, width, selected_button == 3)
end