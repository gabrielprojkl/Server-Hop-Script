-- steal_a_brainrot_hopper_ultra.lua
-- Ultra Dashboard + Server hop + Escaneo + Notificaciones

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local placeId = 1234567890 -- << REEMPLAZA por el PlaceId real
local targetName = "La Grande Combinasion"

-- Historial de servidores visitados y encontrados
getgenv().visitedServers = getgenv().visitedServers or {}
getgenv().foundPlayers = getgenv().foundPlayers or {}

-- Crear GUI Ultra Dashboard
local function createDashboard()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotUltraDashboard"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 300)
    frame.Position = UDim2.new(0.5, -250, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 2
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Brainrot Ultra Dashboard"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextScaled = true
    title.Parent = frame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = frame

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 5)
    uiList.Parent = scrollFrame

    return scrollFrame
end

local scrollFrame = createDashboard()

local function showNotification(titleText, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = titleText;
        Text = text;
        Duration = duration or 5;
    })
end

-- Esperar jugadores y workspace cargado
local function waitForLoad()
    while #Players:GetPlayers() == 0 or not workspace:IsDescendantOf(game) do
        wait(1)
    end
end

-- Revisar base de un jugador
local function base_contains_item(base)
    if not base then return false end
    for _, item in pairs(base:GetChildren()) do
        if item.Name == targetName then
            return true
        end
    end
    return false
end

-- Escanear jugadores en servidor actual
local function scanCurrentServer()
    local encontrados = {}
    for _, player in pairs(Players:GetPlayers()) do
        local base = workspace:FindFirstChild(player.Name .. "'s Base")
        if base and base_contains_item(base) then
            table.insert(encontrados, player.Name)
        end
    end
    return encontrados
end

-- Obtener todos los servidores públicos
local function fetchAllServers()
    local cursor = ""
    getgenv().serverList = {}
    repeat
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            placeId,
            cursor ~= "" and "&cursor="..cursor or ""
        )
        local response = HttpService:GetAsync(url)
        local data = HttpService:JSONDecode(response)

        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers then
                table.insert(getgenv().serverList, server)
            end
        end
        cursor = data.nextPageCursor
    until not cursor or cursor == ""

    -- Ordenar servidores por cantidad de jugadores
    table.sort(getgenv().serverList, function(a, b)
        return a.playing > b.playing
    end)
end

-- Actualizar GUI
local function updateDashboard(currentServer, encontrados)
    -- Crear etiqueta para el servidor actual
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    label.TextColor3 = encontrados and #encontrados > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Text = "Servidor: "..currentServer.." | Jugadores encontrados: "..(#encontrados > 0 and table.concat(encontrados, ", ") or "Ninguno")
    label.Parent = scrollFrame

    -- Ajustar tamaño del canvas
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scrollFrame:GetChildren()*30)
end

-- Server hop ultra optimizado
local function serverHopUltra()
    waitForLoad()
    fetchAllServers()

    for _, server in ipairs(getgenv().serverList) do
        if not table.find(getgenv().visitedServers, server.id) then
            table.insert(getgenv().visitedServers, server.id)
            
            -- Saltar al servidor
            TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
            return -- Se ejecutará de nuevo al entrar al nuevo servidor
        end
    end

    -- Escanear servidor actual
    local encontrados = scanCurrentServer()
    if #encontrados > 0 then
        table.insert(getgenv().foundPlayers, encontrados)
        updateDashboard(game.JobId, encontrados)
        showNotification("¡Brainrot encontrado!", table.concat(encontrados, ", "), 10)
        print("Jugadores encontrados:", table.concat(encontrados, ", "))
    else
        updateDashboard(game.JobId, encontrados)
        print("Ningún jugador encontrado en este servidor:", game.JobId)
    end
end

-- Ejecutar
serverHopUltra()
