--// Eps1lon Hub Notifier - Brainrot Pet Finder & Discord Notifier //-- 

-- SERVICES
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- BACKEND URL (Node.js Express server)
local BACKEND_URL = "https://discordbot-production-800b.up.railway.app/brainrots"
-- DISCORD WEBHOOK (for notifications)
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1402730478989082716/WzT96zfVL3Ep0Qrw1cyF1lIUJhlGxju3vLNW72tULQl6dLqTbprSFzwIGut80bgwBGCg"

-- MINIMUM DPS THRESHOLD (1M+)
local MIN_DPS_THRESHOLD = 1000000 -- 1M

-- MUTATION MULTIPLIERS
local mutationMultipliers = {
    -- Common Mutations
    ['Default'] = 1,
    ['Gold'] = 1.25,
    ['Diamond'] = 1.5,
    ['Rainbow'] = 10,
    -- Event Mutations
    ['Bloodrot'] = 2,
    ['Celestial'] = 4,
    ['Candy'] = 4,
    ['Lava'] = 6
}

-- TRAIT MULTIPLIERS
local traitMultipliers = {
    ['Taco'] = 3,
    ['Galactic'] = 4,
    ['Explosive'] = 4,
    ['Bubblegum'] = 4,
    ['Zombie'] = 5,
    ['Glitched'] = 5,
    ['Claws'] = 5,
    ['Fireworks'] = 6,
    ['Nyan'] = 6,
    ['Fire'] = 6,
    ['Wet'] = 2.5,
    ['Snowy'] = 3,
    ['Cometstruck'] = 3.5,
    ['Disco'] = 5
}

-- RARITY DICTIONARY (Brainrot God & Secret only) - stored as numbers for calculation
local brainrotDict = {
    -- BRAINROT GOD PETS
    ['Cocofanto Elefanto'] = { rarity = 'Brainrot God', dps = 10000 },
    ['Coco Elefanto'] = { rarity = 'Brainrot God', dps = 10000 },
    ['Girafa Celestre'] = { rarity = 'Brainrot God', dps = 20000 },
    ['Gattatino Neonino'] = { rarity = 'Brainrot God', dps = 35000 },
    ['Gattatino Nyanino'] = { rarity = 'Brainrot God', dps = 35000 },
    ['Matteo'] = { rarity = 'Brainrot God', dps = 50000 },
    ['Tralalero Tralala'] = { rarity = 'Brainrot God', dps = 50000 },
    ['Los Crocodillitos'] = { rarity = 'Brainrot God', dps = 55000 },
    ['Tigroligre Frutonni'] = { rarity = 'Brainrot God', dps = 60000 },
    ['Trigoligre Frutonni'] = { rarity = 'Brainrot God', dps = 60000 },
    ['Espresso Signora'] = { rarity = 'Brainrot God', dps = 70000 },
    ['Odin Din Din Dun'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Statutino Libertino'] = { rarity = 'Brainrot God', dps = 75000 },
    ['Orcalero Orcala'] = { rarity = 'Brainrot God', dps = 100000 },
    ['Tukanno Bananno'] = { rarity = 'Brainrot God', dps = 150000 },
    ['Trenostruzzo Turbo 3000'] = { rarity = 'Brainrot God', dps = 150000 },
    ['Trippi Troppi Troppa Trippa'] = { rarity = 'Brainrot God', dps = 175000 },
    ['Ballerino Lololo'] = { rarity = 'Brainrot God', dps = 200000 },
    ['Los TungTungTungCitos'] = { rarity = 'Brainrot God', dps = 0 },
    ['Los Tungtungtungcitos'] = { rarity = 'Brainrot God', dps = 0 },
    ['Piccione Macchina'] = { rarity = 'Brainrot God', dps = 0 },
    ['Brainrot God Lucky Block'] = { rarity = 'Brainrot God', dps = 0 },
    -- SECRET PETS
    ['La Vacca Saturno Saturnita'] = { rarity = 'Secret', dps = 250000 },
    ['La Vacca Staturno Saturnita'] = { rarity = 'Secret', dps = 250000 },
    ['Chimpanzini Spiderini'] = { rarity = 'Secret', dps = 325000 },
    ['Torrtuginni Dragonfrutini'] = { rarity = 'Secret', dps = 350000 },
    ['Tortuginni Dragonfruitini'] = { rarity = 'Secret', dps = 350000 },
    ['Agarrini La Palini'] = { rarity = 'Secret', dps = 400000 },
    ['Agarrini la Palini'] = { rarity = 'Secret', dps = 400000 },
    ['Los Tralaleritos'] = { rarity = 'Secret', dps = 500000 },
    ['Las Tralaleritas'] = { rarity = 'Secret', dps = 650000 },
    ['Las Vaquitas Saturnitas'] = { rarity = 'Secret', dps = 750000 },
    ['Graipusseni Medussini'] = { rarity = 'Secret', dps = 1000000 },
    ['Graipuss Medussi'] = { rarity = 'Secret', dps = 1000000 },
    ['Pot Hotspot'] = { rarity = 'Secret', dps = 2500000 },
    ['Chicleteira Bicicleteira'] = { rarity = 'Secret', dps = 5000000 },
    ['La Grande Combinasion'] = { rarity = 'Secret', dps = 10000000 },
    ['La Grande Combinassion'] = { rarity = 'Secret', dps = 10000000 },
    ['Los Combinasionas'] = { rarity = 'Secret', dps = 15000000 },
    ['Nuclearo Dinossauro'] = { rarity = 'Secret', dps = 15000000 },
    ['Garama and Mandundung'] = { rarity = 'Secret', dps = 50000000 },
    ['Garama and Madundung'] = { rarity = 'Secret', dps = 50000000 },
    ['Dragon Cannelloni'] = { rarity = 'Secret', dps = 100000000 },
    ['Secret Lucky Block'] = { rarity = 'Secret', dps = 0 },
}

-- Helper: Format number to $K/M/B notation
local function formatMoney(num)
    if num == 0 then return "TBA" end
    if num >= 1000000000 then
        return string.format("$%.1fB", num / 1000000000)
    elseif num >= 1000000 then
        return string.format("$%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("$%.0fK", num / 1000)
    else
        return "$" .. tostring(num)
    end
end

-- Helper: Clean string
local function clean(str)
    return tostring(str or ''):gsub('%*+', ''):gsub('^%s*(.-)%s*$', '%1')
end

-- Helper: Calculate total multiplier using the formula:
-- Total Multiplier = Mutation Multiplier + ∑(Trait Multipliers) - (N-1)
-- Where N = 1 mutation + number of traits
local function calculateMultiplier(mutation, traits)
    local sumOfMultipliers = 0
    local N = 0 -- Total number of multipliers
    
    -- Add mutation multiplier
    if mutation and mutationMultipliers[mutation] then
        sumOfMultipliers = sumOfMultipliers + mutationMultipliers[mutation]
        N = N + 1
    else
        -- Default mutation if none specified
        sumOfMultipliers = sumOfMultipliers + 1
        N = N + 1
    end
    
    -- Add trait multipliers
    if traits and type(traits) == "table" then
        for _, trait in ipairs(traits) do
            if traitMultipliers[trait] then
                sumOfMultipliers = sumOfMultipliers + traitMultipliers[trait]
                N = N + 1
            end
        end
    end
    
    -- Apply formula: Total = Sum of all multipliers - (N-1)
    local totalMultiplier = sumOfMultipliers - (N - 1)
    
    -- Ensure multiplier is at least 1
    if totalMultiplier < 1 then
        totalMultiplier = 1
    end
    
    return totalMultiplier
end

-- Helper: Get mutation and traits from a pet model
local function getMutationAndTraits(model)
    local mutation, traits
    
    -- Check for mutation as attribute
    pcall(function() mutation = model:GetAttribute("Mutation") end)
    
    -- Check for mutation as StringValue
    if not mutation then
        local v = model:FindFirstChild("Mutation")
        if v and v:IsA("StringValue") then mutation = v.Value end
    end
    
    -- Check for mutation in a folder
    if not mutation then
        local mutationFolder = model:FindFirstChild("MutationFolder") or model:FindFirstChild("Mutations")
        if mutationFolder then
            for _, child in ipairs(mutationFolder:GetChildren()) do
                if child:IsA("StringValue") then
                    mutation = child.Value
                    break
                end
            end
        end
    end
    
    -- Check for traits as attribute
    pcall(function()
        if model:GetAttribute("Traits") then 
            traits = model:GetAttribute("Traits")
        elseif model:GetAttribute("Trait") then
            traits = { model:GetAttribute("Trait") }
        end
    end)
    
    -- Check for traits as folder
    if not traits then
        local t = model:FindFirstChild("Traits") or model:FindFirstChild("TraitsFolder")
        if t and t:IsA("Folder") then
            traits = {}
            for _, v in ipairs(t:GetChildren()) do
                if v:IsA("StringValue") then 
                    table.insert(traits, v.Value) 
                end
            end
        end
    end
    
    -- Check for individual trait StringValues
    if not traits then
        traits = {}
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("StringValue") and child.Name:lower():find("trait") then
                table.insert(traits, child.Value)
            end
        end
        if #traits == 0 then traits = nil end
    end
    
    -- Convert string to table if needed
    if type(traits) == "string" then
        traits = { traits }
    end
    
    return mutation, traits
end

-- Helper: Get player stats info for this server
local function getPlayerStats()
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers or 8
    return ("%d/%d"):format(playerCount, maxPlayers)
end

-- Helper: Send pet to backend (POST)
local function sendBrainrotToBackend(payload)
    local json = HttpService:JSONEncode(payload)
    local success, result
    if syn and syn.request then
        success, result = pcall(syn.request, {
            Url = BACKEND_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif http and http.request then
        success, result = pcall(http.request, {
            Url = BACKEND_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif request then
        success, result = pcall(request, {
            Url = BACKEND_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif http_request then
        success, result = pcall(http_request, {
            Url = BACKEND_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end
    -- Silent operation - no console output
end

-- Helper: Format Discord embed (Eps1lon Hub Notifier style)
local function buildDiscordEmbed(payload)
    local joinScript = string.format([[```lua
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local placeId = %s
local jobId = "%s"

local success, err = pcall(function()
    TeleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
end)

if not success then
    warn("Teleport failed: " .. tostring(err))
else
    print("Teleporting to job ID: " .. jobId)
end
```]], payload.placeId or payload.serverId or "109983668079237", payload.jobId)

    local embed = {
        title = "Eps1lon Hub Notifier",
        color = 0xB366FF, -- purple
        fields = {
            { name = "🏷️ Name", value = payload.name, inline = false },
            { name = "💰 Money per sec", value = payload.moneyPerSec .. "/s", inline = false },
            { name = "👥 Players", value = payload.players or "?", inline = false },
            { name = "📜 Join Script", value = joinScript, inline = false },
            { name = "🆔 Job ID (Mobile)", value = payload.jobId, inline = false }
        },
        footer = { text = os.date("Reported %Y-%m-%d %H:%M:%S") }
    }

    -- Add mutation if present
    if payload.mutation and payload.mutation ~= "" and payload.mutation ~= "Default" then
        local mutMultiplier = mutationMultipliers[payload.mutation] or 1
        table.insert(embed.fields, 3, { name = "🧬 Mutation", value = payload.mutation .. " (" .. mutMultiplier .. "x)", inline = true })
    end
    
    -- Add traits if present
    if payload.traits and type(payload.traits) == "table" and #payload.traits > 0 then
        local traitStr = ""
        for _, trait in ipairs(payload.traits) do
            local traitMult = traitMultipliers[trait] or 0
            if traitStr ~= "" then traitStr = traitStr .. ", " end
            traitStr = traitStr .. trait .. " (" .. traitMult .. "x)"
        end
        table.insert(embed.fields, 4, { name = "✨ Traits", value = traitStr, inline = true })
    end
    
    -- Add total multiplier if greater than 1
    if payload.totalMultiplier and payload.totalMultiplier > 1 then
        table.insert(embed.fields, 5, { name = "🔢 Total Multiplier", value = string.format("%.2fx", payload.totalMultiplier), inline = true })
    end

    return embed
end

-- Helper: Send to Discord (as embed)
local function sendToDiscord(payload)
    local embed = buildDiscordEmbed(payload)
    local json = HttpService:JSONEncode({ embeds = { embed } })
    local success, result
    if syn and syn.request then
        success, result = pcall(syn.request, {
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif http and http.request then
        success, result = pcall(http.request, {
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif request then
        success, result = pcall(request, {
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    elseif http_request then
        success, result = pcall(http_request, {
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    end
    -- Silent operation - no console output
end

-- Already reported pets (avoid duplicate spam per session)
local reportedPets = {}

-- Main: scan workspace for pets in brainrotDict and report if not already sent
local function scanAndReportPets()
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and brainrotDict[model.Name] and not reportedPets[model] then
            -- Get pet data
            local mutation, traits = getMutationAndTraits(model)
            local totalMultiplier = calculateMultiplier(mutation, traits)
            local baseDps = brainrotDict[model.Name].dps
            local actualDps = baseDps * totalMultiplier
            
            -- ONLY REPORT IF DPS IS 1M+ 
            if actualDps >= MIN_DPS_THRESHOLD then
                -- Prepare payload with calculated money per second
                local payload = {
                    name = model.Name,
                    serverId = tostring(game.PlaceId),
                    jobId = tostring(game.JobId),
                    instanceId = tostring(game.JobId),
                    placeId = tostring(game.PlaceId),
                    players = getPlayerStats(),
                    moneyPerSec = formatMoney(actualDps), -- This is the calculated value
                    lastSeen = os.time() * 1000,
                    active = true,
                    source = "lua-script",
                    mutation = mutation or "Default",
                    traits = traits or {},
                    totalMultiplier = totalMultiplier
                }
                
                sendBrainrotToBackend(payload)
                sendToDiscord(payload)
            end
            
            reportedPets[model] = true
        end
    end
end

-- Repeat scan every 1 second
spawn(function()
    while true do
        scanAndReportPets()
        wait(1)
    end
end)

-- Silent operation - no loading message
