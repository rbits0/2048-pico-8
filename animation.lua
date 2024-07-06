-- animation.lua

-- constants
CELL_ANIMATION_DURATION = 10

CellMoveAnimation = {
    new = function(cell, start_x, start_y, end_x, end_y, delete_on_finish) 
        local x_length = (end_x - start_x)
        local y_length = (end_y - start_y)
        local x_step_size = x_length / CELL_ANIMATION_DURATION
        local y_step_size = y_length / CELL_ANIMATION_DURATION
        local delete_on_finish = delete_on_finish != nil and delete_on_finish or false

        local obj = {
            cell = cell,
            end_x = end_x,
            end_y = end_y,
            x_step_size = x_step_size,
            y_step_size = y_step_size,
            remaining_duration = CELL_ANIMATION_DURATION,
            delete_on_finish = delete_on_finish,
        }
        
        setmetatable(obj, { __index = function(table, key)
            return CellMoveAnimation[key]
        end })
        
        cell.x = start_x
        cell.y = start_y

        return obj
    end,
    
    advance = function(self)
        if self.remaining_duration <= 0 then
            return
        end

        if self.remaining_duration == 1 then
            -- set end value to exact end value so we don't have rounding errors
            self.cell.x = self.end_x
            self.cell.y = self.end_y
            self.remaining_duration -= 1
            return
        end
        
        self.cell.x += self.x_step_size
        self.cell.y += self.y_step_size
        self.remaining_duration -= 1
    end
}
    

CellChangeAnimation = {
    new = function(cell, start_value, end_value) 
        local obj = {
            cell = cell,
            start_value = start_value,
            end_value = end_value,
            remaining_duration = CELL_ANIMATION_DURATION,
        }
        
        setmetatable(obj, { __index = function(table, key)
            return CellChangeAnimation[key]
        end })
        
        cell.value = start_value
        
        return obj
    end,
    
    advance = function(self)
        if self.remaining_duration <= 0 then
            return
        end

        if self.remaining_duration == 1 then
            self.cell.value = self.end_value
            return
        end
        
        self.remaining_duration -= 1
    end
}