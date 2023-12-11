local FlowerReg = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules").FlowerCollect)
local Remote = game.ReplicatedStorage:WaitForChild("Remotes")
local ItemsGame = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules").ItemsGame).Tools
local DataSave = require(game:GetService("ServerScriptService"):WaitForChild("ServerGame").DataStoreGame)
-- этот скрипн нужно переделать на клиентский, чтобы вызывал с клиента FlowerCollect

local Cooldowns = {}
script.Collect.OnServerEvent:Connect(function(player, RootPart, Waittinger)
	local PData = DataSave:Get(player)
	--[[if PData.BaseSettings.Pollen >= ItemsGame.Bags.Capacite then
		-- оповищение что полно
	end
	]]
	local Char = RootPart.Parent
	local ModuleTool = ItemsGame[PData.ItemsUserEqiment.Tool]
	if PData.BaseSettings.Pollen < PData.BaseSettings.Capacity and not Cooldowns[player.Name] then
		Cooldowns[player.Name] = true
		task.wait(Waittinger-0.8)
		
		FlowerReg:CollectFlower(player,{
			RootPart = RootPart,
			Offset = Vector3.new(0,0,0),
			Stamp = ModuleTool.ToolsSettings.BlockFieldCoper,
			StatsMOD = ModuleTool.ToolsSettings,
		})

		
		task.wait(ModuleTool.ToolsSettings.SpeedCoper - 0.2)
		Cooldowns[player.Name] = false
	end
end)