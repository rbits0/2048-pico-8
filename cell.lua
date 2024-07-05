-- cell.lua


-- colors: 7 15 -1 -2 8 -8 -14 -15 1 -13 3 -5 11 (or -6)
-- colours not used by tiles: 0, 5, and 6
CELL_COLORS = {
    [2] = 7,
    [4] = 15,
    [8] = 2,
    [16] = 4,
    [32] = 8,
    [64] = 9,
    [128] = 10,
    [256] = 12,
    [512] = 1,
    [1024] = 13,
    [2048] = 3,
    [4096] = 14,
    [8192] = 11,
}
DEFAULT_COLOR = 11


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
        
    spr(1 + spr_offset , x     , y     )
    spr(17 + spr_offset, x + 8 , y     )
    spr(2 + spr_offset , x + 16, y     )
    spr(20 + spr_offset, x     , y + 8 )
    spr(5 + spr_offset , x + 8 , y + 8 )
    spr(18 + spr_offset, x + 16, y + 8 )
    spr(3 + spr_offset , x     , y + 16)
    spr(19 + spr_offset, x + 8 , y + 16)
    spr(4 + spr_offset , x + 16, y + 16)
    
    local text = tostr(value)
    local size = #text * 4
    
    print(text, x + (13 - size / 2), y + 9, 5)
    
    -- reset palette
    pal(7, 7)
end