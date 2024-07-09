-- title_screen.lua

function title_screen_init()
    state = State.TITLE_SCREEN

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
    
    if btnp(🅾️) then
        if selected_button == 1 then
            game_init()
        elseif selected_button == 2 then
            settings_screen_init()
        end
    end
end


function title_screen_draw()
    rectfill(0, 0, 127, 127, 9)
    map(0, 0)
    
    local highscore = dget(0)
    print("highscore: "..highscore, 36, 40, 7)
    
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
