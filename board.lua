-- board.lua

-- constants
NUM_ROWS = 4
NUM_COLUMNS = 4
NUM_START_TILES = 2

-- enum Direction
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

-- enum ActionType
ActionType = {
    NONE = 1,
    MOVE = 2,
    MERGE = 3,
}

-- struct MoveAction {
--     type = ActionType.MOVE,
--     moving_cell: Cell,
--     new_row: int,
--     new_column: int,
-- }


-- struct MergeAction {
--     type = ActionType.MERGE,
--     moving_cell: Cell,
--     merged_cell: Cell,
-- }


Board = {
    new = function() 
        local obj = {}

        setmetatable(obj, { __index = function(table, key)
            return Board[key]
        end })
        

        local board = {}
        for i=1, NUM_ROWS do
            local row = {}
            for j=1, NUM_COLUMNS do
                row[j] = nil
            end
            board[i] = row
        end
        obj.board = board
        
        for i=1, NUM_START_TILES do
            obj:add_random_cell()
        end
        
        obj.score = LongInt.new(0)
        obj.to_add_cell = false

        return obj
    end,
    

    add_random_cell = function(self)
        local value = rnd() < 0.9 and LongInt.new(2) or LongInt.new(4)
        
        -- ensure cell is empty
        local row = nil
        local column = nil
        while row == nil or self.board[row][column] != nil do
            row = flr(rnd(NUM_ROWS)) + 1
            column = flr(rnd(NUM_COLUMNS)) + 1
        end
        
        self.board[row][column] = Cell.new(value, row, column)
        
        if not self:can_move() then
            game_over_init()
        end

        self.to_add_cell = false
    end,
    

    move = function(self, direction)
        local max_row
        local max_column
        if direction == LEFT or direction == RIGHT then
            max_row = NUM_ROWS
            max_column = NUM_COLUMNS
        else
            max_row = NUM_COLUMNS
            max_column = NUM_ROWS
        end


        local moved = false
        for row=1, max_row do
            for column=1, max_column do
                local cell = self:get_cell_rotated(row, column, direction)
                if cell != nil then
                    local action = self:move_cell(cell, row, column, direction)
                    if not moved and action.type != ActionType.NONE then
                        moved = true
                    end
                    if action.type == ActionType.MERGE then
                        self.score += action.merged_cell.value << 1
                    end
                    self:do_action(action)
                end
            end
        end
        
        if moved then
            self:reset_cell_states()
            self.to_add_cell = true
            animation_running = true

            sfx(1)
        else
            sfx(0)
        end
    end,
    
    
    -- cell must not be nil
    move_cell = function(self, cell, row, column, direction)
        -- this function treats it as if it is moving left,
        -- get_cell_rotated takes care of different directions

        -- attempt to merge
        -- find rightmost cell up to target cell
        local rightmost_cell = nil
        for i=1, column - 1 do
            local curr_cell = self:get_cell_rotated(row, i, direction)
            if curr_cell == nil then
                break
            end

            rightmost_cell = curr_cell
        end
        
        -- if can merge
        if rightmost_cell != nil and
           -- cells can only merge once per turn
           rightmost_cell.merged_this_turn == false and
           rightmost_cell.value == cell.value
        then
            return {
                type = ActionType.MERGE,
                moving_cell = cell,
                merged_cell = rightmost_cell,
            }
        else
            -- instead of merging, move to empty space
            
            -- find leftmost empty space
            local leftmost_empty = nil
            for i=1, column - 1 do
                if self:get_cell_rotated(row, i, direction) == nil then
                    leftmost_empty = i
                    break
                end
            end
            
            if leftmost_empty != nil then
                local rotated_row, rotated_column = rotate_index(row, leftmost_empty, direction)
                return {
                    type = ActionType.MOVE,
                    moving_cell = cell,
                    new_row = rotated_row,
                    new_column = rotated_column,
                }
            end
            
            -- if there's no empty space, do nothing
            return {
                type = ActionType.NONE,
            }
        end
    end,
    

    -- gets cell corresponding to row and column of rotated board
    get_cell_rotated = function(self, row, column, direction)
        local rotated_row, rotated_column = rotate_index(row, column, direction)
        if rotated_row == nil then
            return nil
        end
        
        return self.board[rotated_row][rotated_column]
    end,
    

    do_action = function(self, action)
        if action.type == ActionType.NONE then
            return
        elseif action.type == ActionType.MOVE then
            local start_x = action.moving_cell.x
            local start_y = action.moving_cell.y
            self.board[action.moving_cell.row][action.moving_cell.column] = nil
            action.moving_cell.row = action.new_row
            action.moving_cell.column = action.new_column
            action.moving_cell:calculate_position()
            self.board[action.new_row][action.new_column] = action.moving_cell
            
            -- animate
            add(animations, CellMoveAnimation.new(
                action.moving_cell,
                start_x,
                start_y,
                action.moving_cell.x,
                action.moving_cell.y,
                false
            ))
        elseif action.type == ActionType.MERGE then
            self.board[action.moving_cell.row][action.moving_cell.column] = nil
            action.merged_cell.merged_this_turn = true
            
            -- animate moving cell
            add(animations, CellMoveAnimation.new(
                action.moving_cell,
                action.moving_cell.x,
                action.moving_cell.y,
                action.merged_cell.x,
                action.merged_cell.y,
                true
            ))
            -- add the moving cell to animation_cells,
            -- since it has been removed from the board but still needs to be drawn
            add(animation_cells, action.moving_cell)
            
            -- animate merged cell
            add(animations, CellChangeAnimation.new(
                action.merged_cell,
                action.merged_cell.value,
                action.merged_cell.value << 1
            ))
        end
    end,
    

    -- set cell.merged_this_turn back to false for all cells
    reset_cell_states = function(self)
        for row=1, NUM_ROWS do
            for column=1, NUM_COLUMNS do
                local cell = self.board[row][column]
                if cell != nil then
                    cell.merged_this_turn = false
                end
            end
        end
    end,
    

    can_move = function(self)
        return (
            self:try_move(LEFT) or
            self:try_move(RIGHT) or
            self:try_move(UP) or
            self:try_move(DOWN)
        )
    end,
    

    try_move = function(self, direction)
        local max_row
        local max_column
        if direction == LEFT or direction == RIGHT then
            max_row = NUM_ROWS
            max_column = NUM_COLUMNS
        else
            max_row = NUM_COLUMNS
            max_column = NUM_ROWS
        end

        for row=1, max_row do
            for column=1, max_column do
                local cell = self:get_cell_rotated(row, column, direction)
                if cell != nil then
                    local action = self:move_cell(cell, row, column, direction)
                    if action.type != ActionType.NONE then
                        return true
                    end
                end
            end
        end

        return false
    end,
    

    max_value = function(self)
        local max = LongInt.new(0)
        
        for row=1, NUM_ROWS do
            for column=1, NUM_COLUMNS do
                local cell = self.board[row][column]
                if cell != nil and cell.value > max then
                    max = cell.value
                end
            end
        end
        
        return max
    end,
    

    draw = function(self)
        for row=1, NUM_ROWS do
            for column=1, NUM_COLUMNS do
                local cell = self.board[row][column]
                if cell != nil then
                    cell:draw()
                end
            end
        end
    end,
}


function rotate_index(row, column, direction)
    if (
        (direction == LEFT or direction == RIGHT) and 
        (row > NUM_ROWS or column > NUM_COLUMNS)
    ) or (
       (direction == UP or direction == DOWN) and
       (row > NUM_COLUMNS or column > NUM_ROWS)
    ) then
        return nil, nil
    end

    local rotated_row
    local rotated_column

    if direction == LEFT then
        rotated_row = row
        rotated_column = column
    elseif direction == RIGHT then
        rotated_row = NUM_ROWS - row + 1
        rotated_column = NUM_COLUMNS - column + 1
    elseif direction == UP then
        rotated_row = column
        rotated_column = row
    elseif direction == DOWN then
        rotated_row = NUM_ROWS - column + 1
        rotated_column = NUM_COLUMNS - row + 1
    end
    
    return rotated_row, rotated_column
end
