-- title_screen.lua

function title_screen_init()
    state = State.TITLE_SCREEN
    
    -- enable key repeating
    poke(0x5f5c, 0)
    
    menuitem(1)

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
    rectfill(0, 0, 127, 127, 6)
    map(0, 0)
    
    draw_highscore()
    draw_buttons()
end


function draw_buttons()
    local width = 6
    local x_pos = 40

    draw_button("play", x_pos, 62, width, selected_button == 1)
    draw_button("settings", x_pos, 82, width, selected_button == 2)
end


function draw_highscore()
    local highscore_text = "highscore: "..highscore:tostr()
    local highscore_pos = center(0, 128, #highscore_text * 4)
    print(highscore_text, highscore_pos, 35, 7)
    
    local cell_highscore_text = "largest number: "..cell_highscore:tostr()
    local cell_highscore_pos = center(0, 128, #cell_highscore_text * 4)
    print(cell_highscore_text, cell_highscore_pos, 43, 7)
end