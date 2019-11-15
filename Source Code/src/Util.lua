--[[
    Helper functions.
]]

function translatePoints(points, dx, dy, scale)
    for i,point in pairs(points) do
        points[i][1] = math.floor(point[1]*scale + dx)
        points[i][2] = math.floor(point[2]*scale + dy)
    end
end

function scaleIncrement(value, lower, upper, incr)
    if incr > 0 then
        value = math.max(lower, (value + incr)%(upper + 1))
    elseif incr < 0 then
        value = (value + incr) % (upper + 1)
        while value <= 0 do
            value = value + upper
        end
    end
    return value
end

function getNewCycles(a, b)
    r = {}
    if #b == 0 then
        return deepcopy(a)
    end
    for k,c1 in pairs(a) do
        local contains = false
        for k,c2 in pairs(b) do
            if sameElements(c1, c2) then
                contains = true
                break
            end
        end
        if not contains then
            table.insert(r, c1)
        end
    end
    return r
    -- local ai = {}
    -- local r = {}
    -- for k,v in pairs(a) do r[k] = v; ai[v]=true end
    -- for k,v in pairs(b) do
    --     if ai[v]~=nil then   r[k] = nil   end
    -- end
    -- return r
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function compareTableElementsByLength(a, b)
    return #a < #b
end

function deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end
    return true
end

function table.removeElements(input, remove)
    --[[
    remove should be a boolean table whose keys are the elements to be removed, all values should be set to true
    ]]
    local n = #input

    for i = 1, n do
        if remove[input[i]] then
            input[i] = nil
        end
    end

    local j = 0
    for i = 1, n do
        if input[i] ~= nil then
            j = j + 1
            input[j] = input[i]
        end
    end
    for i = j + 1, n do
        input[i] = nil
    end
end

function table.contains(tbl, item)
    for key, value in pairs(tbl) do
        if deepcompare(value,item) then return true end
    end
    return false
end

function table.concatenate(t1, t2)
    k = deepcopy(t1)
    for i = 1, #t2 do
        k[#k + 1] = t2[i]
    end
    return k
end

function table.reverse(tbl)
    local new = {}
    for i = #tbl, 1, - 1 do
        table.insert(new, tbl[i])
    end
    return new
end

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
            love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
            tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val, indent..string.rep(" ", string.len(pos) + 8))
                        print(indent..string.rep(" ", string.len(pos) + 6).."}")
                    elseif (type(val) == "string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t).." {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

--[[
    Returns the length between two points on a 2D plane
]]
function point_length(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
end

function slope(line)
    return (line[2][2] - line[1][2]) / (line[2][1] - line[1][1])
end

function isSubsetOf(t1, t2)
    for i,v1 in pairs(t2) do
        if not table.contains(t1, v1) then
            return false
        end
    end
    return true
end

function lines_intersect(line1, line2, endpoints)
    endpoints = endpoints or false
    m1 = slope(line1)
    m2 = slope(line2)
    c1 = line1[2][2] - m1 * line1[2][1]
    c2 = line2[2][2] - m2 * line2[2][1]

    if m1 == m2 and c1 == c2 and m1 ~= 0 and math.abs(m1) ~= math.huge then
        return false
    end

    p0_x = line1[1][1]
    p0_y = line1[1][2]

    p1_x = line1[2][1]
    p1_y = line1[2][2]

    p2_x = line2[1][1]
    p2_y = line2[1][2]

    p3_x = line2[2][1]
    p3_y = line2[2][2]

    s1_x = p1_x - p0_x
    s1_y = p1_y - p0_y
    s2_x = p3_x - p2_x
    s2_y = p3_y - p2_y

    s = (-s1_y * (p0_x - p2_x) + s1_x * (p0_y - p2_y)) / (-s2_x * s1_y + s1_x * s2_y)
    t = ( s2_x * (p0_y - p2_y) - s2_y * (p0_x - p2_x)) / (-s2_x * s1_y + s1_x * s2_y)

    if endpoints then
        if (s >= 0 and s <= 1 and t >= 0 and t <= 1) then
            return true
        end
    else
        if (s > 0 and s < 1 and t >= 0 and t <= 1) then
            return true
        end
    end

    return false

end

function sameElements(t1, t2)
    return isSubsetOf(t1, t2) and isSubsetOf(t2, t1)
end
