-- cell.lua


Cell = {
    new = function(value, row, column)
        local obj = {
            value = value,
            row = row,
            column = column,
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
    end,
}