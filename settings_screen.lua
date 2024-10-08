-- settings_screen.lua

function settings_screen_init()
    state = State.SETTINGS_SCREEN

    selected_button = 1
    confirmation = false
end


function settings_screen_update()
    if not confirmation then
        settings_screen_active_update()
    else
        confirmation_update()
    end
end


function settings_screen_active_update()
    if btnp(⬆️) then
        selected_button -= 1
    elseif btnp(⬇️) then
        selected_button += 1
    end
    if selected_button < 1 then
        selected_button = 4
    elseif selected_button > 4 then
        selected_button = 1
    end
    
    if btnp(🅾️) then
        if selected_button == 1 then
            move_speed = (
                move_speed == 3 and 1 or
                move_speed == 5 and 3 or
                move_speed == 10 and 5 or
                10
            )
            
            dset(32, move_speed)
        elseif selected_button == 2 then
            confirmation_init()
        elseif selected_button == 3 then
            sound_on = not sound_on
            
            dset(33, sound_on and 0 or 1)
        elseif selected_button == 4 then
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
    
    local move_speed_string = (
        move_speed == 1 and "instant" or
        move_speed == 3 and "fast" or
        move_speed == 5 and "normal" or
        move_speed == 10 and "slow" or
        "error"
    )
    
    local sound_string = sound_on and "on" or "off"

    local width = 10
    local x_pos = 24

    draw_button("move speed: "..move_speed_string, x_pos, 51, width, selected_button == 1)
    draw_button("reset highscore", x_pos, 70, width, selected_button == 2)
    draw_button("sound: "..sound_string, x_pos, 89, width, selected_button == 3)
    draw_button("back", x_pos, 108, width, selected_button == 4)
    
    if confirmation then
        confirmation_draw(64)
    end
end


function confirmation_init()
    confirmation = true
    confirmation_selected_button = 1
end


function confirmation_update()
    if btnp(⬅️) or btnp(➡️) then
        if confirmation_selected_button == 1 then
            confirmation_selected_button = 2
        else
            confirmation_selected_button = 1
        end
    end
    
    if btnp(🅾️) then
        if confirmation_selected_button == 2 then
            reset_highscore()
        end

        confirmation = false
    end
    
    if btnp(❎) then
        -- back
        confirmation = false
    end
end


function confirmation_draw(y)
    draw_rounded_box(24, y, 10, 5)
    
    print("reset highscore", 35, y + 8)
    
    local button_y = y + 20
    local button_width = 4
    
    draw_button("cancel", 30, button_y, button_width, confirmation_selected_button == 1)
    draw_button("confirm", 66, button_y, button_width, confirmation_selected_button == 2)
end


function reset_highscore()
    highscore = LongInt.new(0)
    cell_highscore = LongInt.new(0)
    dset(0, 0)
    dset(1, 0)
    dset(2, 0)
    dset(3, 0)
end