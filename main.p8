pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--2048
--by rbits
--repo: https://github.com/rbits0/2048-pico-8/
--original game by Gabriele Cirulli (https://github.com/gabrielecirulli/2048)

#include helper.lua
#include cell.lua
#include board.lua
#include animation.lua
#include widgets.lua
#include title_screen.lua
#include settings_screen.lua
#include game_over.lua

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
    cell_highscore = LongInt.new(dget(3), dget(4))
    move_speed = dget(32)
    if move_speed == 0 then
        -- default move speed
        move_speed = 5
    end

    modify_palette()
    
    title_screen_init()
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
    game_over = false
    
    -- disable key repeating
    poke(0x5f5c, 255)

    modify_palette()

    animations = {}
    -- cells that are animating, but not on the board and will disappear when animation finished
    animation_cells = {}
    animation_running = false
    
    button_buffer = nil

    board = Board.new()

    menuitem(1, "end game", game_over_init)
end


function game_update()
    if not game_over then
        game_running_update()
    else
        game_over_update()
    end
end


function game_running_update()
    if not animation_running then
        if button_buffer != nil then
            board:move(button_buffer)
            button_buffer = nil
        elseif btnp(⬅️) then
            board:move(LEFT)
        elseif btnp(➡️) then
            board:move(RIGHT)
        elseif btnp(⬆️) then
            board:move(UP)
        elseif btnp(⬇️) then
            board:move(DOWN)
        end
    elseif button_buffer == nil then
        if btnp(⬅️) then
            button_buffer = LEFT
        elseif btnp(➡️) then
            button_buffer = RIGHT
        elseif btnp(⬆️) then
            button_buffer = UP
        elseif btnp(⬇️) then
            button_buffer = DOWN
        end
    end
    
    run_animations()
end


function game_draw()
    draw_background()
    board:draw()
    draw_animation_cells()
    draw_score()
    
    if game_over then
        game_over_draw()
    end
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
        
    local max_value = board:max_value()
    if max_value > cell_highscore then
        cell_highscore = max_value
        dset(3, max_value.small)
        dset(4, max_value.large)
    end
end






__gfx__
0000000000000000000000000777777777777777000000777700000000000077770000000000000007700000000007777770000000ffffffffffff0000000000
000000000000077777777777077777777777777700007777777700000000777777770000000000007770000000007777777700000ffffffffffffff000000000
00700700000777777777777707777777777777770007777007777000000777700777700000000007777000000007770000777000ffffffffffffffff00000000
00077000007777777777777707777777777777770077700000077700000770000007700000000077777000000007700000077000ffffffffffffffff00000000
00077000007777777777777707777777777777770077000000007700007770000007770000000777077000000007770000777000ffffffffffffffff00000000
00700700077777777777777707777777777777770000000000007700007700000000770000007770077000000000777777770000ffffffffffffffff00000000
00000000077777777777777707777777777777770000000000007700007700000000770000077700077000000000077777700000f555f555f5f5f55500000000
00000000077777777777777707777777777777770000000000077700007700000000770000777000077000000000777777770000fff5f5f5f5f5f5f500000000
00000000000005555555555555555555555555550000000007777000007700000000770000777777777777000007770000777000f555f5f5f555f55500000000
00000000000555555555555555555555555555550000000077770000007700000000770000777777777777000007700000077000f5fff5f5fff5f5f500000000
00000000005555555555555555555555555555550000007777000000007700000000770000000000077000000007700000077000f555f555fff5f55500000000
00000000055555555555555555555555555555550000077770000000007770000007770000000000077000000007700000077000ffffffffffffffff00000000
00000000055555555555555555555555555555550007777000000000000770000007700000000000077000000007700000077000ffffffffffffffff00000000
00000000555555555555555555555555555555550077770000000000000777700777700000000000077000000007777007777000ffffffffffffffff00000000
000000005555555555555555555555555555555500777777777777000000777777770000000000000770000000007777777700000ffffffffffffff000000000
0000000055555555555555555555555555555555007777777777770000000077770000000000000007700000000000777700000000ffffffffffff0000000000
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
__label__
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmm777m777m77mm777m7mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmm7m7mmmm7mmmm7m7mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmm777m777mm7mmmm7m777mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmm7mmmmm7mm7mmmm7m7m7mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmm777m777m777mmm7m777mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm553333333333333355mmmmmmmm55ffffffffffffff55mmmmmmmm55ffffffffffffff55mmmmmmmm555555555555555555mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmm53333333333333333335mmmmmm5ffffffffffffffffff5mmmmmm5ffffffffffffffffff5mmmmmm55555555555555555555mmmmmmmmmmmmmmm
mmmmmmmmmmmmmm5333333333333333333335mmmm5ffffffffffffffffffff5mmmm5ffffffffffffffffffff5mmmm5555555555555555555555mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5333333333333333333335mmmm5ffffffffffffffffffff5mmmm5ffffffffffffffffffff5mmmm5555555555555555555555mmmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533337773777373737773335mm5ffffffffff5f5fffffffff5mm5ffffffffff5f5fffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333373737373737373335mm5ffffffffff5f5fffffffff5mm5ffffffffff5f5fffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533337773737377737773335mm5ffffffffff555fffffffff5mm5ffffffffff555fffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533337333737333737373335mm5ffffffffffff5fffffffff5mm5ffffffffffff5fffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533337773777333737773335mm5ffffffffffff5fffffffff5mm5ffffffffffff5fffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmm533333333333333333333335mm5ffffffffffffffffffffff5mm5ffffffffffffffffffffff5mm555555555555555555555555mmmmmmmmmmmmm
mmmmmmmmmmmmmm5333333333333333333335mmmm5ffffffffffffffffffff5mmmm5ffffffffffffffffffff5mmmm5555555555555555555555mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5333333333333333333335mmmm5ffffffffffffffffffff5mmmm5ffffffffffffffffffff5mmmm5555555555555555555555mmmmmmmmmmmmmm
mmmmmmmmmmmmmmm53333333333333333335mmmmmm5ffffffffffffffffff5mmmmmm5ffffffffffffffffff5mmmmmm55555555555555555555mmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm553333333333333355mmmmmmmm55ffffffffffffff55mmmmmmmm55ffffffffffffff55mmmmmmmm555555555555555555mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm551111111111111155mmmmmmmm55vvvvvvvvvvvvvv55mmmmmmmm55ffffffffffffff55mmmmmmmm55vvvvvvvvvvvvvv55mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmm51111111111111111115mmmmmm5vvvvvvvvvvvvvvvvvv5mmmmmm5ffffffffffffffffff5mmmmmm5vvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmmm
mmmmmmmmmmmmmm5111111111111111111115mmmm5vvvvvvvvvvvvvvvvvvvv5mmmm5ffffffffffffffffffff5mmmm5vvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5111111111111111111115mmmm5vvvvvvvvvvvvvvvvvvvv5mmmm5ffffffffffffffffffff5mmmm5vvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111177717711777111115mm5vvvvvvvvvv555vvvvvvvvv5mm5ffffffffff5f5fffffffff5mm5vvvvvvvvvv555vvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111171111711117111115mm5vvvvvvvvvv5v5vvvvvvvvv5mm5ffffffffff5f5fffffffff5mm5vvvvvvvvvv5v5vvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111177711711777111115mm5vvvvvvvvvv555vvvvvvvvv5mm5ffffffffff555fffffffff5mm5vvvvvvvvvv555vvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111711711711111115mm5vvvvvvvvvv5v5vvvvvvvvv5mm5ffffffffffff5fffffffff5mm5vvvvvvvvvv5v5vvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111177717771777111115mm5vvvvvvvvvv555vvvvvvvvv5mm5ffffffffffff5fffffffff5mm5vvvvvvvvvv555vvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmm511111111111111111111115mm5vvvvvvvvvvvvvvvvvvvvvv5mm5ffffffffffffffffffffff5mm5vvvvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmm
mmmmmmmmmmmmmm5111111111111111111115mmmm5vvvvvvvvvvvvvvvvvvvv5mmmm5ffffffffffffffffffff5mmmm5vvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5111111111111111111115mmmm5vvvvvvvvvvvvvvvvvvvv5mmmm5ffffffffffffffffffff5mmmm5vvvvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmm
mmmmmmmmmmmmmmm51111111111111111115mmmmmm5vvvvvvvvvvvvvvvvvv5mmmmmm5ffffffffffffffffff5mmmmmm5vvvvvvvvvvvvvvvvvv5mmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm551111111111111155mmmmmmmm55vvvvvvvvvvvvvv55mmmmmmmm55ffffffffffffff55mmmmmmmm55vvvvvvvvvvvvvv55mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm557777777777777755mmmmmmmm552222222222222255mmmmmmmm558888888888888855mmmmmmmm557777777777777755mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmm57777777777777777775mmmmmm52222222222222222225mmmmmm58888888888888888885mmmmmm57777777777777777775mmmmmmmmmmmmmmm
mmmmmmmmmmmmmm5777777777777777777775mmmm5222222222222222222225mmmm5888888888888888888885mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5777777777777777777775mmmm5222222222222222222225mmmm5888888888888888888885mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777775557777777775mm522222277227772777222225mm588888888555855588888885mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777757777777775mm522222227222272727222225mm588888888885888588888885mm577777777777757777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777775557777777775mm522222227227772777222225mm588888888855855588888885mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777775777777777775mm522222227227222727222225mm588888888885858888888885mm577777777775777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777775557777777775mm522222277727772777222225mm588888888555855588888885mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm577777777777777777777775mm522222222222222222222225mm588888888888888888888885mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmmm5777777777777777777775mmmm5222222222222222222225mmmm5888888888888888888885mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5777777777777777777775mmmm5222222222222222222225mmmm5888888888888888888885mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmmm57777777777777777775mmmmmm52222222222222222225mmmmmm58888888888888888885mmmmmm57777777777777777775mmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm557777777777777755mmmmmmmm552222222222222255mmmmmmmm558888888888888855mmmmmmmm557777777777777755mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm558888888888888855mmmmmmmm55ffffffffffffff55mmmmmmmm557777777777777755mmmmmmmm557777777777777755mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmm58888888888888888885mmmmmm5ffffffffffffffffff5mmmmmm57777777777777777775mmmmmm57777777777777777775mmmmmmmmmmmmmmm
mmmmmmmmmmmmmm5888888888888888888885mmmm5ffffffffffffffffffff5mmmm5777777777777777777775mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5888888888888888888885mmmm5ffffffffffffffffffff5mmmm5777777777777777777775mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888555855588888885mm5ffffffffff5f5fffffffff5mm577777777775557777777775mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888885888588888885mm5ffffffffff5f5fffffffff5mm577777777777757777777775mm577777777777757777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888855855588888885mm5ffffffffff555fffffffff5mm577777777775557777777775mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888885858888888885mm5ffffffffffff5fffffffff5mm577777777775777777777775mm577777777775777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888555855588888885mm5ffffffffffff5fffffffff5mm577777777775557777777775mm577777777775557777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmm588888888888888888888885mm5ffffffffffffffffffffff5mm577777777777777777777775mm577777777777777777777775mmmmmmmmmmmmm
mmmmmmmmmmmmmm5888888888888888888885mmmm5ffffffffffffffffffff5mmmm5777777777777777777775mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmm5888888888888888888885mmmm5ffffffffffffffffffff5mmmm5777777777777777777775mmmm5777777777777777777775mmmmmmmmmmmmmm
mmmmmmmmmmmmmmm58888888888888888885mmmmmm5ffffffffffffffffff5mmmmmm57777777777777777775mmmmmm57777777777777777775mmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmm558888888888888855mmmmmmmm55ffffffffffffff55mmmmmmmm557777777777777755mmmmmmmm557777777777777755mmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmm55555555555555mmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005060708090a0b0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015161718191a1b1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000250501d0501805013050110500f0500d0500c0500b0500c0500c0500c0501400014000130001350013500135001350013500165000050000500000000000000000000000000000000000000000000000
000100000a6301905014050120501005015000120000f000110000f0000c0000a0000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
