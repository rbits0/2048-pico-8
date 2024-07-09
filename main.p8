pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include helper.lua
#include cell.lua
#include board.lua
#include animation.lua
#include buttons.lua
#include title_screen.lua
#include settings_screen.lua

-- main.p8

-- enum State
State = {
    TITLE_SCREEN = 1,
    GAME = 2,
    SETTINGS_SCREEN = 3,
}


function _init()
    printh(" ")

    cartdata("rbits_2048")
    highscore = LongInt.new(dget(0), dget(1))
    
    title_screen_init()
    -- game_init()
end


function _update()
    if state == State.TITLE_SCREEN then
        title_screen_update()
    elseif state == State.GAME then
        game_update()
    elseif state == State.SETTINGS_SCREEN then
        settings_screen_update()
    end
end


function _draw()
    cls()
    
    if state == State.TITLE_SCREEN then
        title_screen_draw()
    elseif state == State.GAME then
        game_draw()
    elseif state == State.SETTINGS_SCREEN then
        settings_screen_draw()
    end
end


function game_init()
    state = State.GAME
    
    -- disable key repeating
    poke(0x5f5c, 255)

    modify_palette()

    animations = {}
    -- cells that are animating, but not on the board and will disappear when animation finished
    animation_cells = {}
    animation_running = false

    board = Board.new()
end


function game_update()
    if not animation_running then
        if btnp(⬅️) then
            board:move(LEFT)
        elseif btnp(➡️) then
            board:move(RIGHT)
        elseif btnp(⬆️) then
            board:move(UP)
        elseif btnp(⬇️) then
            board:move(DOWN)
        end
    end
    
    run_animations()
end


function game_draw()
    draw_background()
    board:draw()
    draw_animation_cells()
    draw_score()
end


function modify_palette()
    reset_palette()

    pal(4, -1, 1)
    pal(9, -2, 1)
    pal(10, -8, 1)
    pal(12, -3, 1)
    pal(13, -13, 1)
    pal(14, -5, 1)
    
    -- background colour
    pal(6, -10, 1)
end


function run_animations()
    local to_delete = {}

    for i=1, #animations do
        local animation = animations[i]

        if animation.remaining_duration >= 0 then
            animation:advance()
        else
            -- animations finished
            animation_running = false

            add(to_delete, i)
            if animation.delete_on_finish then
                del(animation_cells, animation.cell)
            end
        end
    end
    
    local del_offset = 0
    for i in all(to_delete) do
        deli(animations, i + del_offset)
        del_offset -= 1
    end
    
    if not animation_running and board.to_add_cell then
        board:add_random_cell()
    end
end


function draw_background()
    rectfill(0, 0, 127, 127, 6)

    for row=1, NUM_ROWS do
        for column=1, NUM_COLUMNS do
            local x, y = cell_calculate_position(row, column)
            draw_cell(x, y, nil, 16)
        end
    end
end


function draw_animation_cells()
    for cell in all(animation_cells) do
        cell:draw()
    end
end


function draw_score()
    print(board.score:tostr(), 4, 4, 7)
end


function game_end()
    printh("GAME_OVER")
    save_highscore()
end


function save_highscore()
    if board.score > highscore then
        highscore = board.score
        dset(0, board.score.small)
        dset(1, board.score.large)
    end
end






__gfx__
00000000000000000000000007777777777777770000007777000000000000777700000000000000077000000000077777700000000000000000000000000000
00000000000007777777777707777777777777770000777777770000000077777777000000000000777000000000777777770000000000000000000000000000
00700700000777777777777707777777777777770007777007777000000777700777700000000007777000000007770000777000000000000000000000000000
00077000007777777777777707777777777777770077700000077700000770000007700000000077777000000007700000077000000000000000000000000000
00077000007777777777777707777777777777770077000000007700007770000007770000000777077000000007770000777000000000000000000000000000
00700700077777777777777707777777777777770000000000007700007700000000770000007770077000000000777777770000000000000000000000000000
00000000077777777777777707777777777777770000000000007700007700000000770000077700077000000000077777700000000000000000000000000000
00000000077777777777777707777777777777770000000000077700007700000000770000777000077000000000777777770000000000000000000000000000
00000000000005555555555555555555555555550000000007777000007700000000770000777777777777000007770000777000000000000000000000000000
00000000000555555555555555555555555555550000000077770000007700000000770000777777777777000007700000077000000000000000000000000000
00000000005555555555555555555555555555550000007777000000007700000000770000000000077000000007700000077000000000000000000000000000
00000000055555555555555555555555555555550000077770000000007770000007770000000000077000000007700000077000000000000000000000000000
00000000055555555555555555555555555555550007777000000000000770000007700000000000077000000007700000077000000000000000000000000000
00000000555555555555555555555555555555550077770000000000000777700777700000000000077000000007777007777000000000000000000000000000
00000000555555555555555555555555555555550077777777777700000077777777000000000000077000000000777777770000000000000000000000000000
00000000555555555555555555555555555555550077777777777700000000777700000000000000077000000000007777000000000000000000000000000000
00000000000044444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077700000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077700000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077700000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077700000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015161718191a1b1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
