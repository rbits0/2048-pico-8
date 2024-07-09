pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include cell.lua
#include board.lua
#include animation.lua
#include title_screen.lua

-- main.p8

-- enum State
State = {
    TITLE_SCREEN = 1,
    GAME = 2,
}


function _init()
    state = State.TITLE_SCREEN
    title_screen_init()
    -- game_init()
end


function _update()
    if state == State.TITLE_SCREEN then
        title_screen_update()
    elseif state == State.GAME then
        game_update()
    end
end


function _draw()
    if state == State.TITLE_SCREEN then
        title_screen_draw()
    elseif state == State.GAME then
        game_draw()
    end
end


function game_init()
    printh(" ")
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
    cls()
    
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


function reset_palette()
    pal({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0}, 1)
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
            local x, y = calculate_position(row, column)
            draw_cell(x, y, "", 32)
        end
    end
end


function draw_animation_cells()
    for cell in all(animation_cells) do
        cell:draw()
    end
end


function draw_score()
    print(board.score, 4, 4, 7)
end






__gfx__
000000000000000000000000077777777777777077777777aaaaaaaa000000777700000000000077770000000000000007700000000007777770000000000000
000000000000077777700000077777777777777077777777aaaaaaaa000077777777000000007777777700000000000077700000000077777777000000000000
007007000007777777777000077777777777777077777777aaaaaaaa000777700777700000077770077770000000000777700000000777000077700000000000
000770000077777777777700007777777777770077777777aaaaaaaa007770000007770000077000000770000000007777700000000770000007700000000000
000770000077777777777700007777777777770077777777aaaaaaaa007700000000770000777000000777000000077707700000000777000077700000000000
007007000777777777777770000777777777700077777777aaaaaaaa000000000000770000770000000077000000777007700000000077777777000000000000
000000000777777777777770000007777770000077777777aaaaaaaa000000000000770000770000000077000007770007700000000007777770000000000000
000000000777777777777770000000000000000077777777aaaaaaaa000000000007770000770000000077000077700007700000000077777777000000000000
00000000000000007777777077777777077777770000000000000000000000000777700000770000000077000077777777777700000777000077700000000000
00000000777777777777777077777777077777770000000000000000000000007777000000770000000077000077777777777700000770000007700000000000
00000000777777777777777077777777077777770000000000000000000000777700000000770000000077000000000007700000000770000007700000000000
00000000777777777777777077777777077777770000000000000000000007777000000000777000000777000000000007700000000770000007700000000000
00000000777777777777777077777777077777770000000000000000000777700000000000077000000770000000000007700000000770000007700000000000
00000000777777777777777077777777077777770000000000000000007777000000000000077770077770000000000007700000000777700777700000000000
00000000777777777777777077777777077777770000000000000000007777777777770000007777777700000000000007700000000077777777000000000000
00000000777777777777777000000000077777770000000000000000007777777777770000000077770000000000000007700000000000777700000000000000
00000000000005555550000055555555555555555555555500000000000000000000000000000000000044444444444400000000000000000000000000000000
00000000000555555555500055555555555555555555555500000000000000000000000000000000004444444444444400000000000000000000000000000000
00000000005555555555550055555555555555555555555500000000000000000000000000000000044444444444444400000000000000000000000000000000
00000000055555555555555005555555555555505555555500000000000000000000000000000000044444444444444400000000000000000000000000000000
00000000055555555555555005555555555555505555555500000000000000000000000000000000444444444444444400000000000000000000000000000000
00000000555555555555555500555555555555005555555500000000000000000000000000000000444444444444444400000000000000000000000000000000
00000000555555555555555500055555555550005555555500000000000000000000000000000000444444444444444400000000000000000000000000000000
00000000555555555555555500000555555000005555555500000000000000000000000000000000444444444444444400000000000000000000000000000000
00000000555555555555555555555555555555550000000000777700007777000700070000777700000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000007700770077007700700070007000070000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000007000070070000700700070007000070000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000000000770070000700700070000777700000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000000077700070000700777777007000070000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000000770000070000700000070007000070000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000007700000077007700000070007000070000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555550000000007777770007777000000070000777700000000000000000000000000000000000000000000000000
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
000000000708090a0b0c0d0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001718191a1b1c1d1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
