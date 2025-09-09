-- steal_a_brainrot_dashboard_final.lua
-- Server hop optimizado + dashboard + historial + notificaciones

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local placeId = 1234567890 -- << REEMPLAZA por el PlaceId de Steal a Brainrot
local targetName = "La Grande Combinasion"

-- Historial de servidores visitados
local visitedServers = {}

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotDashboard"
screenGui.ResetOnSpawn = false
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 250)
frame.Position = UDim2.new(0.5, -225, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 2
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Brainrot Dashboard (Final)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 1, -40)
infoLabel.Position = UDim2.new(0, 5, 0, 35)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextScaled = false
infoLabel.TextWrapped = true
infoLabel.Text = "Iniciando..."
infoLabel.Parent = frame

-- Función para mostrar notificación
local function show_notification(titleText, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = titleText;
        Text = text;
        Duration = duration or 5;
    })
end

-- Revisar la base de un jugador
local function base_contains_item(base)
    if not base then return false end
    for _, item in pairs(base:GetChildren()) do
        if item.Name == targetName then
            return true
        end
    end
    return false
end

-- Escanea jugadores en el servidor actual
local function scan_current_server()
    local encontrados = {}
    for _, player in pairs(Players:GetPlayers()) do
        local base = workspace:FindFirstChild(player.Name .. "'s Base")
        if base and base_contains_item(base) then
            table.insert(encontrados, player.Name)
        end
    end
    return encontrados
end

-- Obtener servidores públicos
local function get_servers(cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
        placeId,
        cursor and "&cursor="..cursor or ""
    )
    local response = HttpService:GetAsync(url)
    return HttpService:JSONDecode(response)
end

-- Actualizar dashboard
local function update_dashboard(totalScanned, currentServer, encontrados)
    local message = string.format(
        "Servidores escaneados: %d\nServidor actual: %s\nServidores visitados: %d\nJugadores encontrados:\n%s",
        totalScanned,
        currentServer,
        #visitedServers,
        #encontrados > 0 and table.concat(encontrados, ", ") or "Ninguno"
    )
    infoLabel.Text = message
end

-- Server hop optimizado
local function server_hop()
    local cursor = ""
    local totalScanned = 0

    while true do
        -- Revisar servidor actual
        local encontrados = scan_current_server()
        totalScanned = totalScanned + 1
        table.insert(visitedServers, game.JobId)
        update_dashboard(totalScanned, game.JobId, encontrados)
        print("Servidor escaneado:", game.JobId)

        if #encontrados > 0 then
            show_notification("¡Brainrot encontrado!", table.concat(encontrados, ", "), 10)
            break -- Detener hopping si encontramos alguien
        end

        -- Obtener servidores públicos
        local data = get_servers(cursor)
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and not table.find(visitedServers, server.id) then
                print("Saltando al servidor:", server.id)
                update_dashboard(totalScanned, server.id, encontrados)
                TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                return -- Al teletransportar se detiene el script en este cliente
            end
        end

        if data.nextPageCursor then
            cursor = data.nextPageCursor
        else
            cursor = ""
            print("No quedan servidores disponibles. Esperando 5 segundos...")
            update_dashboard(totalScanned, "Ninguno", encontrados)
            wait(5)
        end

        wait(1)
    end
end

-- Ejecutar al cargar
server_hop()
