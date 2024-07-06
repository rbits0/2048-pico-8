-- animation.lua

-- constants
CELL_ANIMATION_DURATION = 5

CellMoveAnimation = {
    new = function(cell, start_x, start_y, end_x, end_y, delete_on_finish) 
        local x_length = (end_x - start_x)
        local y_length = (end_y - start_y)
        local x_step_size = x_length / CELL_ANIMATION_DURATION
        local y_step_size = y_length / CELL_ANIMATION_DURATION
        local delete_on_finish = delete_on_finish != nil and delete_on_finish or false

        local obj = {
            cell = cell,
            start_x = start_x,
            start_y = start_y,
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
        
        return obj
    end,
    
    advance = function(self)
        if self.remaining_duration <= 0 then
            -- set end value to exact end value so we don't have rounding errors
            self.cell.x = self.end_x
            self.cell.y = self.end_y
        elseif self.remaining_duration == CELL_ANIMATION_DURATION then
            -- initialise start position
            self.cell.x = self.start_x
            self.cell.y = self.start_y
        else
            self.cell.x += self.x_step_size
            self.cell.y += self.y_step_size
        end

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
        
        return obj
    end,
    
    advance = function(self)
        if self.remaining_duration <= 0 then
            self.cell.value = self.end_value
        elseif self.remaining_duration == CELL_ANIMATION_DURATION then
            self.cell.value = self.start_value
        end
        
        self.remaining_duration -= 1
    end
}