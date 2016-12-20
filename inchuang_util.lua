local core = {}

-- trim whitespace from both ends of string
core.trim =  function(s)
    if s == nil then return nil else return s:find'^%s*$' and '' or s:match'^%s*(.*%S)' end
end

-- trim whitespace from left end of string
core.triml = function(s)
    if s == nil then return nil else return s:match'^%s*(.*)' end
end

-- trim whitespace from right end of string
core.trimr = function(s)
    if s == nil then return nil else return s:find'^%s*$' and '' or s:match'^(.*%S)' end
end


-- 
core.string_split = function(str, split_char)
    local sub_str_tab = {}
    local i = 1
    local j
    while true do
        j = string.find(str, split_char, i)
        if j == nil then
            table.insert(sub_str_tab, string.sub(str, i))
            break
        end
        table.insert(sub_str_tab, string.sub(str, i, j - 1))
        i = j + 1
    end
    return sub_str_tab
end



core.serialize = function (obj)
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{"  
        for k, v in pairs(obj) do  
            lua = lua .. "[" .. core.serialize(k) .. "]=" .. core.serialize(v) .. ","  
        end  
        local metatable = getmetatable(obj)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
            for k, v in pairs(metatable.__index) do  
                lua = lua .. "[" .. core.serialize(k) .. "]=" .. core.serialize(v) .. ","  
            end  
        end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  


core.unserialize = function (lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  

return core
