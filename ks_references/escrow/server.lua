local Framework = nil
local ESX, QBCore = nil, nil

if GetResourceState('es_extended') == 'started' then
    Framework = 'esx'
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    Framework = 'qb'
    QBCore = exports['qb-core']:GetCoreObject()
end

local References_FILE = "reference.json"
local Claims_FILE = "claims.json"
local ReferenceDB = {}
local ClaimsDB = {}

local function loadReference()
    local content = LoadResourceFile(GetCurrentResourceName(), References_FILE)
    if content then
        ReferenceDB = content ~= "" and json.decode(content) or {}
    else
        ReferenceDB = {}
    end
end

local function saveReference()
    SaveResourceFile(GetCurrentResourceName(), References_FILE, json.encode(ReferenceDB, { indent = true }), -1)
end

function GenerarCodigoReferido(longitud)
    longitud = longitud or 10
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local codigo = ''
    math.randomseed(os.time() + math.random(1000))
    for i = 1, longitud do
        local rand = math.random(1, #chars)
        codigo = codigo .. chars:sub(rand, rand)
    end
    return codigo
end


function RegistrarNuevoUsuario(codigo, identifier)
    ReferenceDB[codigo] = { usos = 0, identifier = identifier }
    saveReference()
end

function ObtenerCodigoPorUsuario(identifier)
    for codigo, data in pairs(ReferenceDB) do
        if data.identifier == identifier then
            return codigo
        end
    end
    local gencode = GenerarCodigoReferido(12)
    RegistrarNuevoUsuario(gencode, identifier)
    return gencode
end

local function loadClaims()
    local content = LoadResourceFile(GetCurrentResourceName(), Claims_FILE)
    if content then
        ClaimsDB = content ~= "" and json.decode(content) or {}
    else
        ClaimsDB = {}
    end
end

local function saveClaims()
    SaveResourceFile(GetCurrentResourceName(), Claims_FILE, json.encode(ClaimsDB, { indent = true }), -1)
end

function AgregarUsoACodigo(codigo, identifier)
    if ReferenceDB[codigo] then
        if ReferenceDB[codigo].identifier == identifier then
            return Config.Language.NoOwnCode
        end
        ReferenceDB[codigo].usos = ReferenceDB[codigo].usos + 1
        RegistrarUsuarioReclamado(identifier)
        saveReference()

        local ownerIdentifier = ReferenceDB[codigo].identifier
        local baseReward = Config.Reward.Owner 
        local totalReward = baseReward * ReferenceDB[codigo].usos

        if Framework == 'esx' then
            local ownerPlayer = ESX.GetPlayerFromIdentifier(ownerIdentifier)
            local useplayer = ESX.GetPlayerFromIdentifier(identifier)
            if useplayer then 
                useplayer.addMoney(Config.Reward.Referred)
            end
            if ownerPlayer then
                ownerPlayer.addMoney(totalReward)
            else
                MySQL.query('SELECT accounts FROM users WHERE identifier = ?', { ownerIdentifier }, function(result)
                    if result and result[1] then
                        local accounts = json.decode(result[1].accounts)
                        accounts.money = (accounts.money or 0) + totalReward
                        MySQL.prepare('UPDATE users SET accounts = ? WHERE identifier = ?', { json.encode(accounts), ownerIdentifier })
                    end
                end)
            end
        elseif Framework == 'qb' then
            local ownerPlayer = QBCore.Functions.GetPlayerByCitizenId(ownerIdentifier)
            local useplayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
            if useplayer then 
                useplayer.Functions.AddMoney('cash', Config.Reward.Referred)
            end
            if ownerPlayer then
                ownerPlayer.Functions.AddMoney('cash', totalReward)
            else
                MySQL.query('SELECT money FROM players WHERE citizenid = ?', { ownerIdentifier }, function(result)
                    if result and result[1] then
                        local money = result[1].cash or 0
                        money = money + totalReward
                        MySQL.prepare('UPDATE players SET money = ? WHERE citizenid = ?', { money, ownerIdentifier })
                    end
                end)
            end
        end

        return Config.Language.ClaimSuccess
    end
    return Config.Language.No
end

function RegistrarUsuarioReclamado(identifier)
    ClaimsDB[identifier] = true
    saveClaims()
end

function YaReclamo(identifier)
    return ClaimsDB[identifier] == true
end

loadReference()
loadClaims()

ESX.RegisterServerCallback("ks_referencias:getcode",function(source,cb,codigo)
    local player = ESX.GetPlayerFromId(source)
    local codigo = ObtenerCodigoPorUsuario(player.identifier)
    local usos = 0
    if ReferenceDB[codigo] and ReferenceDB[codigo].usos then
        usos = ReferenceDB[codigo].usos
    end
    cb(codigo, usos)
end)
ESX.RegisterServerCallback("ks_referencias:claim",function(source,cb,codigo)
    local player = ESX.GetPlayerFromId(source)
    if not YaReclamo(player.identifier) then 
        local claimcode = AgregarUsoACodigo(codigo,player.identifier)
        if claimcode == Config.Language.ClaimSuccess then 
            sendJobWebhook(player.identifier, codigo)
            cb(claimcode) 
        else
            cb(claimcode)
        end
    else
        cb(Config.Language.AlreadyClaimed)
    end
end)


function sendJobWebhook(identifier, code)
    local message = string.format("Identifier: %s\nCode: **%s**", identifier, code)
    PerformHttpRequest(Config.WEBHOOK_URL, function() end, 'POST', json.encode({
        username = Config.Language.WebhookUsername,
        embeds = {{
            title = Config.Language.WebhookTitle,
            description = message,
            color = Config.Language.WebhookColor
        }}
    }), { ['Content-Type'] = 'application/json' })
end