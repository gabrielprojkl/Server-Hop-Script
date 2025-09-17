-- Create the ScreenGui and Buttons
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
local toggleInvisibilityButton = Instance.new("TextButton")
local toggleNameVisibilityButton = Instance.new("TextButton")

-- Set up ScreenGui
screenGui.Name = "InvisibilityToggleGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Set up the Invisibility Button
toggleInvisibilityButton.Size = UDim2.new(0, 200, 0, 50) -- Button size
toggleInvisibilityButton.Position = UDim2.new(0.5, -100, 0.4, -25) -- Centered position
toggleInvisibilityButton.Text = "Toggle Invisibility"
toggleInvisibilityButton.Parent = screenGui

-- Set up the Name Visibility Button
toggleNameVisibilityButton.Size = UDim2.new(0, 200, 0, 50) -- Button size
toggleNameVisibilityButton.Position = UDim2.new(0.5, -100, 0.5, -25) -- Centered below the first button
toggleNameVisibilityButton.Text = "Toggle Name Visibility"
toggleNameVisibilityButton.Parent = screenGui

local invisible = false
local nameVisible = true

-- Function to toggle invisibility
local function toggleInvisibility()
    local character = player.Character or player.CharacterAdded:Wait()
    
    invisible = not invisible -- Toggle the invisibility state
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = invisible and 1 or 0 -- Set transparency based on invisibility state
            part.CanCollide = not invisible -- Disable collision if invisible
        end
    end
end

-- Function to toggle name visibility
local function toggleNameVisibility()
    local character = player.Character or player.CharacterAdded:Wait()
    
    nameVisible = not nameVisible -- Toggle the name visibility state
    if character:FindFirstChild("Head") and character.Head:FindFirstChild("Name") then
        character.Head.Name.Visible = nameVisible -- Set visibility based on the state
    end
end

-- Function to allow button movement
local function makeButtonMovable(button)
    local dragging
    local dragInput
    local mousePos
    local buttonPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            buttonPos = button.Position
            mousePos = input.Position

            -- Start dragging
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            button.Position = UDim2.new(buttonPos.X.Scale, buttonPos.X.Offset + delta.X, buttonPos.Y.Scale, buttonPos.Y.Offset + delta.Y)
        end
    end)
end

-- Connect the button click events
toggleInvisibilityButton.MouseButton1Click:Connect(toggleInvisibility)
toggleNameVisibilityButton.MouseButton1Click:Connect(toggleNameVisibility)

-- Make buttons movable
makeButtonMovable(toggleInvisibilityButton)
makeButtonMovable(toggleNameVisibilityButton)
