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
        local gap = 4
        
        self.x = (self.column - 1) * (24 + gap) + 10
        self.y = (self.row - 1) * (24 + gap) + 10
    end,
    

    draw = function(self)
        -- set background colour palette
        local color = CELL_COLORS[self.value]
        if color == nil then
            pal(7, DEFAULT_COLOR)
        else
            pal(7, color)
        end
        
        spr(1, self.x     , self.y     )
        spr(5, self.x + 8 , self.y     )
        spr(2, self.x + 16, self.y     )
        spr(5, self.x     , self.y + 8 )
        spr(5, self.x + 8 , self.y + 8 )
        spr(5, self.x + 16, self.y + 8 )
        spr(3, self.x     , self.y + 16)
        spr(5, self.x + 8 , self.y + 16)
        spr(4, self.x + 16, self.y + 16)
        
        local text = tostr(self.value)
        local size = #text * 4
        
        print(self.value, self.x + (13 - size / 2), self.y + 9, 5)
        
        -- reset palette
        pal(7, 7)
    end,
}