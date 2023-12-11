
local Players = game:GetService("Players")
local FolderBlock = game.Workspace.ThemeGame
local FlowerBlock = game.ServerStorage:WaitForChild("FlowerClone")

local Theme = {}

local TableColor = {
    Color3.fromRGB(255, 255, 255),-- ~TODOColor3.fromRGB()
	Color3.fromRGB(209, 209, 209),
	Color3.fromRGB(222, 219, 216),
	Color3.fromRGB(234, 255, 235),
	Color3.fromRGB(227, 244, 248),
}

function ColorGame()
    FlowerBlock.Color = TableColor[5]
    
    for I, Thema in pairs(FolderBlock) do
        for i, Flower in pairs(Thema.Flower) do
            if Flower:IsA("MeshPart") then
                -- Значение 
            end
        end

        for i, Grass in pairs(Thema.Grass) do
            if Grass:IsA("MeshPart") then
                -- Значение 
            end
        end

        for i, GrassMin in pairs(Thema.GrassMin) do
            if GrassMin:IsA("MeshPart") then
                -- Значение 
            end
        end

        for i, DopBlock in pairs(Thema.DopBlock) do
            if DopBlock:IsA("MeshPart") then
                -- Значение 
            end
        end

        for i, Tree in pairs(Thema.Tree) do
            if Tree:IsA("MeshPart") then
                -- Значение 
            end
        end
        for i, Grover in pairs(Thema.Grover) do
            if Grover:IsA("MeshPart") then
                -- Значение + Проверка на модель И там уже менять Одна большая модель
            end
        end
    end
end

game.Players.PlayerAdded:Connect(ColorGame)

return Theme