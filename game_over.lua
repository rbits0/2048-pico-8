-- game_over.lua

function game_over_init()
    game_over = true

    -- enable key repeating
    poke(0x5f5c, 0)

    save_highscore()

    menuitem(1)

    selected_button = 1
end


function game_over_update()
    if btnp(➡️) or btnp(⬅️) then
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
            title_screen_init()
        end
    end
    
    if btnp(❎) then
        -- back
        title_screen_init()
    end
end


function game_over_draw()
    draw_rounded_box(12, 40, 13, 6)
    
    print("\^w\^tgame over", 28, 44, 5)
    local score_text = "score: "..board.score:tostr()
    local score_text_x = center(1, 128, #score_text * 4)
    print(score_text, score_text_x, 59, 5)

    local button_width = 5
    local button_y_pos = 68

    draw_button("restart", 21, button_y_pos, button_width, selected_button == 1)
    draw_button("back", 67, button_y_pos, button_width, selected_button == 2)
end