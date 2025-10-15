-- Lua table parser with limited evaluation

local TableReader = {
}
TableReader.__index = TableReader

function TableReader.new()
    return setmetatable({ i = 1 }, self)
end

function TableReader:read(str)
    local i = 1
    local function chr() return str:sub(i, i) end
    local function eof()  return i > #str end
    local function next(n) i = i + (n or 1) end
    local function expect_chr(ch)
        if chr() ~= ch then
            error("Unexpected char, got '" .. chr() .. "' but expected '" .. ch .. "'")
        end
    end

    expect_chr '{'
    next() 

    while true do
        local key = TableReader.read_tbl_key()
    end
    
    expect_chr '}'
end

function TableReader:read_tbl_key()
    local start = 0
    while true do
    end
end

return TableReader
