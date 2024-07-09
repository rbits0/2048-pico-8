-- helper.lua


-- centers width within outer range
-- returns the start position
function center(outer_start, outer_end, width)
    local middle = (outer_start + outer_end) / 2
    return flr(middle - (width / 2))
end


function reset_palette()
    pal({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0}, 1)
end


function pad_num(num, length)
    local num_text = tostr(num)
    local pad_length = length - #num_text
    
    local padding = ""
    for i=1, pad_length do
        padding ..= "0"
    end
    
    return padding..num_text
end


-- will go up to 9999 before incrementing next place
LongInt = {
    limit = 9999,

    new = function(small, large)
        if large == nil then
            large = 0
        end

        local obj = {
            small = small,
            large = large,
        }

        setmetatable(obj, {
            __index = function(table, key)
                return LongInt[key]
            end,
            __add = LongInt.__add,
            __lt = LongInt.__lt,
            __shl = LongInt.__shl,
            __eq = LongInt.__eq,
        })


        return obj
    end,

    __add = function(num1, num2)
        -- int is not necessarily int, but long is always long
        local int
        local long
        if type(num2) == "number" then
            int = num2
            long = num1
        else
            int = num1
            long = num2
        end

        local small = long.small
        local large = long.large

        if will_overflow(small, int, LongInt.limit) then
            small += int
            large += 1
        else
            small += int
        end
        
        return LongInt.new(small, large)
    end,
    
    __lt = function(num1, num2)
        if type(num1) == "number" then
            return num2.large > 0 or num1 < num2.small
        elseif type(num2) == "number" then
            return num1.large < 0 and num1.small < num2
        else
            return (num1.large < num2.large) or
                   (num1.large == num2.large and num1.small < num2.small)
        end
    end,
    
    __eq = function(self, num)
        return self.large == num.large and self.small == num.small
    end,
    
    __shl = function(self)
        local large = self.large << 1        
        
        local small = self.small
        if small >= 5000 then
            small -= 5000
            large += 1
        end
        
        small <<= 1
        
        return LongInt.new(small, large)
    end,

    tostr = function(self)
        if self.large > 0 then
            return self.large..pad_num(self.small, 4)
        else
            return tostr(self.small)
        end
    end
}

function will_overflow(num1, num2, limit)
    return (limit - num1 < num2)
end