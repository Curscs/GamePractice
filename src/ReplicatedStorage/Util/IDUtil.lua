local Util = {}

function Util:GenerateID(length: number)
    local function Generator(length: number)
        local Chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local RandomString = ""

        for i = 1, length do
            local RandomNum = math.random(1,#Chars)
            RandomString = RandomString .. string.sub(Chars,RandomNum,RandomNum)
        end
        return RandomString
    end
    return Generator(length) .. "-" .. Generator(length) .. "-" .. Generator(length) .. "-" .. Generator(length) .. "-" .. Generator(length)
end

return Util