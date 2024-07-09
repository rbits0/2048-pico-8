-- cell.lua


-- colors: 7 15 -1 -2 8 -8 -14 -15 1 -13 3 -5 11 (or -6)
-- colors: 7 15 -1 -2 8 -8 2 -3 1 -13 3 -5 11 (or -6)
-- colours not used by tiles: 0, 5, and 6
-- 4 9 10 12 13 14
CELL_COLORS = {
    [2] = 7,
    [4] = 15,
    [8] = 4,
    [16] = 9,
    [32] = 8,
    [64] = 10,
    [128] = 2,
    [256] = 12,
    [512] = 1,
    [1024] = 13,
    [2048] = 3,
    [4096] = 14,
    [8192] = 11,
}
DEFAULT_COLOR = 11
TEXT_WHITE_NUMBERS = {64, 128, 256, 512, 1024, 2048}
TEXT_WHITE = 7
TEXT_BLACK = 5


Cell = {
    new = function(value, row, column)
        local obj = {
            value = value,
            row = row,
            column = column,
            merged_this_turn = false,
        }

        setmetatable(obj, { __index = function(table, key)
            return Cell[key]
        end })

        obj:calculate_position()

        return obj
    end,


    calculate_position = function(self)
        self.x, self.y = calculate_position(self.row, self.column)
    end,
    

    draw = function(self)
        draw_cell(self.x, self.y, self.value, 0)
    end,
}


function calculate_position(row, column)
    local gap = 2
    local margin = 13
    
    local x = (column - 1) * (24 + gap) + margin
    local y = (row - 1) * (24 + gap) + margin
    
    return x, y
end


function draw_cell(x, y, value, spr_offset)
    if value != nil then
        -- set background colour palette
        local color = CELL_COLORS[value]
        if color == nil then
            pal(7, DEFAULT_COLOR)
        else
            pal(7, color)
        end
    end
        
    -- 1st row
    spr(1 + spr_offset, x     , y     , 1, 1, false, false)
    spr(2 + spr_offset, x + 8 , y     , 1, 1, false, false)
    spr(1 + spr_offset, x + 16, y     , 1, 1, true, false)
    -- 2nd row
    spr(3 + spr_offset, x     , y + 8 , 1, 1, false, false)
    spr(4 + spr_offset, x + 8 , y + 8 , 1, 1, true, false)
    spr(3 + spr_offset, x + 16, y + 8 , 1, 1, true, false)
    -- 3rd row
    spr(1 + spr_offset, x     , y + 16, 1, 1, false, true)
    spr(2 + spr_offset, x + 8 , y + 16, 1, 1, false, true)
    spr(1 + spr_offset, x + 16, y + 16, 1, 1, true, true)

    -- spr(2 + spr_offset, x + 8 , y     )
    -- spr(1 + spr_offset, x + 16, y     , 1, 1, true, false)
    -- spr(20 + spr_offset, x     , y + 8 )
    -- spr(5 + spr_offset, x + 8 , y + 8 )
    -- spr(18 + spr_offset, x + 16, y + 8 )
    -- spr(3 + spr_offset, x     , y + 16)
    -- spr(19 + spr_offset, x + 8 , y + 16)
    -- spr(4 + spr_offset, x + 16, y + 16)
    
    local text = tostr(value)
    local size = #text * 4
    
    local text_color = TEXT_BLACK
    for num in all(TEXT_WHITE_NUMBERS) do
        if value == num then
            text_color = TEXT_WHITE
            break
        end
    end
    
    -- reset palette
    pal(7, 7)

    print(text, x + (13 - size / 2), y + 9, text_color)
end