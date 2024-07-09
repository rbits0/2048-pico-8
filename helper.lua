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
        })


        return obj
    end,

    __add = function(self, num)
        local small = self.small
        local large = self.large

        if will_overflow(small, num, self.limit) then
            small = wrapping_int_add(small, num, self.limit)
            large += 1
        else
            small += num
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
    
    __shl = function(self)
        self.large <<= 1        
        
        if self.small >= 5000 then
            self.small -= 5000
            self.large += 1
        end
        
        self.small <<= 1
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

function wrapping_int_add(num1, num2, limit)
    return num2 - (limit - num1) - 1
end