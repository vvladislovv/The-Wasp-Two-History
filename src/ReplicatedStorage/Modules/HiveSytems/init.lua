--_G.PData = game.ReplicatedStorage.Remotes.GetDataSave:InvokeServer()
--print(_G.PData)
local HiveFolder = workspace:WaitForChild("Hive")
local DataSave = require(game.ServerScriptService.ServerGame.DataStoreGame)
local TweenService = game:GetService("TweenService")
local Remotes = game.ReplicatedStorage:WaitForChild("Remotes")

local HS = {}

function GetHiveNameText(UIS1,UIS2, Player, PData)
	UIS1.TextUser.Text = Player.Name
	UIS2.NamePlayer.Text = Player.Name
end


function HiveOwner()
	local Prox1 = workspace:WaitForChild("Hive").PlatformHive.One.Text.Promt.ProximityPrompt
	local Prox2 = workspace:WaitForChild("Hive").PlatformHive.Two.Text.Promt.ProximityPrompt
	local Prox3 = workspace:WaitForChild("Hive").PlatformHive.Three.Text.Promt.ProximityPrompt
	local Prox4 = workspace:WaitForChild("Hive").PlatformHive.Four.Text.Promt.ProximityPrompt
	local Prox5 = workspace:WaitForChild("Hive").PlatformHive.Five.Text.Promt.ProximityPrompt
	local Prox6 = workspace:WaitForChild("Hive").PlatformHive.Six.Text.Promt.ProximityPrompt
	for _, Hive in pairs(HiveFolder.PlatformHive:GetChildren()) do
		Hive:WaitForChild("Text").Promt.ProximityPrompt.Triggered:Connect(function(Player) -- может на клиент через ремут и все
			local PData = DataSave:Get(Player)
			if game.Players:FindFirstChild(Player.Name) then
					
				if Hive.OwnerHive.Value == "" and PData.GameSettings.HiveOwner == "" then
					
					Hive.OwnerHive.Value = Player.Name
					PData.GameSettings.HiveOwner = Player.Name

					GetHiveNameText(Hive.Text.TextGui, Hive.Text.TextTwo.BillboardGui, Player, PData)
					for _, SlotAll in pairs(Hive.SlotHive:GetChildren()) do
						SlotTranslater(SlotAll)
					end
					Prox1.Enabled = false
					Prox2.Enabled = false
					Prox3.Enabled = false
					Prox4.Enabled = false
					Prox5.Enabled = false
					Prox6.Enabled = false
					
				elseif Hive.OwnerHive.Value ~= "" and PData.GameSettings.HiveOwner ~= "" then
					Hive:WaitForChild("Text").Promt.ProximityPrompt.Enabled = true
					--print("Owner")
				
				end
					--Player.Name = Hive.OwnerHive.Value
			
			--GetHiveNameText(Hive.Text.TextGui, Hive.Text.TextTwo.BillboardGui, PData)
			end
		end)
		
	end
end	

function SlotTranslater(SlotHive)
	if SlotHive.Name == "OneLevel" then
		TweenService:Create(SlotHive, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
	end
	if SlotHive.Name == "TwoLevel" then
		TweenService:Create(SlotHive, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
	end
	if SlotHive.Name == "ThreeLevel" then
		TweenService:Create(SlotHive, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
	end
	if SlotHive.Name == "FourLevel" then
		TweenService:Create(SlotHive, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
	end
	if SlotHive.Name == "FiveLevel" then
		TweenService:Create(SlotHive, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
	end
end

--[[function NewPlayer(SlotHive) -- красивое появление 
	for _, Hive in pairs(HiveFolder.PlatformHive:GetChildren()) do
		Hive.Text.Promt.ProximityPrompt.Triggered:Connect(function(Player)
			if game.Players:FindFirstChild(Player.Name) then
				local PData = DataSave:Get(Player)
				if PData.Hives.SlotHives == 5 then
					if SlotHive.Name == "OneLevel" then
						TweenService:Create(SlotHive, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Transparency = 0.2}):Play()
					end
				end
			end
		end)
	end
end]]



function HS:GetHives()
	for _, Hive in pairs(HiveFolder.PlatformHive:GetChildren()) do
		if Hive:WaitForChild("Text").Promt.ProximityPrompt.Triggered then -- тут смотри все 
			for _, SlotAll in pairs(Hive.SlotHive:GetChildren()) do -- Появления словта сделать проверку на дату + как у дарка
				HiveOwner()
			end
		end
	
	end
end






function HS:StartScript()
	HS:GetHives()
end

return HS
