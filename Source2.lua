local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local HopButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.Size = UDim2.new(0, 200, 0, 100)

HopButton.Parent = Frame
HopButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
HopButton.Size = UDim2.new(1, 0, 0, 50)
HopButton.Text = "Hop to Server"
HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)

StatusLabel.Parent = Frame
StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Position = UDim2.new(0, 0, 0, 50)
StatusLabel.Size = UDim2.new(1, 0, 0, 50)
StatusLabel.Text = "Status: Ready"

local function hopToServer()
    StatusLabel.Text = "Status: Hopping..."
    local success, err = pcall(function()
        local servers = game:GetService("TeleportService"):GetServerList("PlaceId", "La Grande Combinasion")
        if #servers > 0 then
            local server = servers[math.random(1, #servers)]
            game:GetService("TeleportService"):TeleportToPlaceInstance("PlaceId", server)
        else
            StatusLabel.Text = "Status: No servers found"
        end
    end)
    if not success then
        StatusLabel.Text = "Status: Error - " .. err
    end
end

HopButton.MouseButton1Click:Connect(hopToServer)
