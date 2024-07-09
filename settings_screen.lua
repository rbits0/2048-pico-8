-- settings_screen.lua

function settings_screen_init()
    state = State.SETTINGS_SCREEN

    title_screen_palette()
    
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
    rectfill(0, 0, 127, 127, 9)
    map(0, 0)

    local highscore = dget(0)
    print("highscore: "..highscore, 36, 40, 7)

    local width = 9
    local x_pos = 28

    draw_button("move speed", x_pos, 50, width, selected_button == 1)
    draw_button("reset highscore", x_pos, 70, width, selected_button == 2)
    draw_button("back", x_pos, 90, width, selected_button == 3)
end