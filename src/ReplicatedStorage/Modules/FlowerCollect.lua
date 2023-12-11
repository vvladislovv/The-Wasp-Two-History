local TablePlayerFlower = {}
game.Players.PlayerAdded:Connect(function(plr)
	TablePlayerFlower[plr.Name] = {White = 0, Blue = 0, Coin = 0,  Red = 0}
    --print("ok")
end)
--print(TablePlayerFlower)
--PData = game.ReplicatedStorage.Remotes.GetDataSave:InvokeServer()

local moduleFlower = {} do
	local FieldGame = require(game.ReplicatedStorage:WaitForChild("Modules").FieldSystems)
	local DataSave = require(game.ServerScriptService.ServerGame.DataStoreGame)
	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local TW = game:GetService("TweenService")
	local Workspacee = game:GetService("Workspace")
	local ModuleRS = RS.Modules
	local Item = require(ModuleRS:WaitForChild("ItemsGame"))
	local RemotesFolder = RS:WaitForChild("Remotes")
	-- Remote Event 
	local VEP  = RemotesFolder:WaitForChild("VisualEventPollen")

	local function GetRotation(Character, Orientation)
		local HOrient = Character.PrimaryPart.Orientation

		if HOrient.Magnitude >= 50 and HOrient.Magnitude < 110 then
			Orientation = CFrame.Angles(0, math.rad(90), 0)


		elseif HOrient.Magnitude > -90 and HOrient.Magnitude < 90 then
			Orientation = CFrame.Angles(0, math.rad(-90), 0)


		elseif HOrient.Magnitude > 0 and HOrient.Magnitude < 50 then
			Orientation = CFrame.Angles(0, math.rad(-180), 0)


		elseif HOrient.Magnitude <= 110 and HOrient.Magnitude >= 180 then
			Orientation = CFrame.Angles(0, math.rad(0), 0)


		elseif HOrient.Magnitude > 110 and HOrient.Magnitude < 180 then
			Orientation = CFrame.Angles(0, math.rad(0), 0)
		end

		return Orientation
	end


    function moduleFlower:CollectFlower(Player, Args)
		local PData = DataSave:Get(Player)
        local Character = game.Workspace:FindFirstChild(Player.Name)
        local ModelStamp = game.ServerStorage.Stamps[Args.Stamp]:Clone()
        ModelStamp.Parent = Workspacee.FolderGames.Stamps
        local hit = Instance.new("Part")
        hit.Name = "Hit"
        hit.CanCollide = false
        hit.Size = Vector3.new(0.1,0.1,0.1)
        hit.Parent = Args.RootPart
        hit.Orientation = Args.RootPart.Orientation
        hit.Transparency = 1
        hit.Anchored = false
        hit.Massless = true
        hit.Position = Args.RootPart.Position + Args.Offset

        hit.Touched:Connect(function(Part)
            if Part.Name == "FlowerClone" then
                
				spawn(function()
					--local toolsSop = coroutine.create
                    if ModelStamp:IsA("Model") then

                        for _, Object in pairs(ModelStamp:GetChildren()) do
                            Object.Anchored = false
                        end

						ModelStamp:SetPrimaryPartCFrame(CFrame.new(Part.Position) * GetRotation(Character))
                        task.wait(0.2)
                        
                        for _, Object in pairs(ModelStamp:GetChildren()) do
                            Object.Anchored = true
                        end

                    task.wait(0.1)
                    pcall(function()
                       ModelStamp:SetPrimaryPartCFrame(CFrame.new(Args.RootPart.Position))
                        end)
                    else
						ModelStamp.CFrame = CFrame.new(Part.Position) * GetRotation(Character)
                    end
                end)
                --coroutine.resume(toolsSop)
            end
        end)
    
    
    hit.Position = hit.Position + Vector3.new(0, -2.48, 0)
    task.wait()
    hit:Destroy()
    
    local WoldHit = Instance.new("WeldConstraint", hit)
    WoldHit.Part0 = Args.RootPart
    WoldHit.Part1 = hit

    local Flowers = {}
        if ModelStamp:IsA("Model") then
            for i, v in pairs(ModelStamp:GetChildren()) do
                if v.Name ~= "Root" then
                    v.Touched:Connect(function(part)
                        if part.name == "FlowerClone" then
                            if not table.find(Flowers, part) then
                                table.insert(Flowers, part)
								moduleFlower:CollectFieldINFlower(Player, PData, part, Args.RootPart, nil, ModelStamp.PrimaryPart)
                                task.wait(0.1)
                                ModelStamp:Destroy()
                            end
                        end
                    end)
                end
            end
    else
        ModelStamp.Touched:Connect(function(part)
				if part.Name == "FlowerClone" then
                if not table.find(Flowers, part) then
                    table.insert(Flowers, part)
                    if Args.StatsMOD then
							moduleFlower:CollectFieldINFlower(Player, PData, part, part.Position, Args.StatsMOD, ModelStamp.Position)
                    else
							moduleFlower:CollectFieldINFlower(Player, PData, part, part.Position, nil, ModelStamp.Position)
                    end
                    task.wait(0.1)
                    ModelStamp:Destroy()
                end
            end
        end)
    end
	end
	
	game.Players.PlayerRemoving:Connect(function(plr)
		TablePlayerFlower[plr.Name] = nil
	end)

    function moduleFlower:CollectFieldINFlower(Player, PData, Flower, Position, StatsMOD, Stamp)
		if Flower and PData and (Flower.Position.Y - FieldGame.FlowerTable[Flower.FlowerID.Value].MinP) > 0.2 then
			local CanScoop = true
			local V1 = 0
			local V2 = 0

			if PData.BaseSettings.Pollen < PData.BaseSettings.Capacity and CanScoop == true then
                --local TableGlobule = {Start = tick(),
				local Type = PData.ItemsUserEqiment.Tool 
				local Crit = false 
				local FColor = FieldGame.FlowerTable[Flower.FlowerID.Value].Color
				local FSize = FieldGame.FlowerTable[Flower.FlowerID.Value].Stat.Value 
				--}
				local SS, DecAm, FoodAm
				--print(FColor)
				local Percent = math.round(PData.Boost.PlayerBoost[FColor.." Instant"] + PData.Boost.PlayerBoost["Instant"])
                if Percent > 100 then
                    Percent = 100
                end
                if not StatsMOD then
					DecAm = Item.Tools[Type].ToolsSettings.PowerTools
					SS = Item.Tools[Type].ToolsSettings.Collecting

                    DecAm /= tonumber(FSize)
                    SS /= math.round(SS * tonumber(FSize))
                    
					if Item.Tools[Type].ToolsSettings.Color == FColor then -- Color * in Tools Сбор умножение 
						DecAm *= Item.Tools[Type].ToolsSettings.BlockFieldCoper
                        SS *= Item.Tools[Type].ToolsSettings.BlockFieldCoper
                    end

                    FoodAm = math.round(SS * ((PData.Boost.PlayerBoost["Pollen"] / 100) * (PData.Boost.PlayerBoost[FColor.." Pollen"] / 100) * (PData.Boost.PlayerBoost["Pollen From Collectors"] / 100)))
                else
                    
                    if StatsMOD["Color"] == "Red" then
                        if FColor == "Red" then
                            DecAm *= 1.5
                            SS *= 1.5
                        elseif FColor == "Blue" then
                            DecAm /= 1.5
                            SS /= 1.5
                        elseif FColor == "White" then
                            DecAm /= 1.5
                            SS /= 1.5
						end
						
                            elseif StatsMOD["Color"] == "Blue" then
                                if FColor == "Blue" then
                                    DecAm *= 1.5
                                    SS *= 1.5
                                elseif FColor == "Red" then
                                    DecAm /= 1.5
                                    SS /= 1.5
                                elseif FColor == "White" then
                                    DecAm /= 1.5
                                    SS /= 1.5
									end
						
                                elseif StatsMOD["Color"] == "White" then
                                    if FColor == "White" then
                                        DecAm *= 1.5
                                        SS *= 1.5
                                    elseif FColor == "Red" then
                                        DecAm /= 1.5
                                        SS /= 1.5
                                    elseif FColor == "Blue" then
                                        DecAm /= 1.5
                                        SS /= 1.5
						end
						
                    end
				end
				
				
                function moduleFlower.DownFlower()
                    local FlowerPos = Flower.Position - Vector3.new(0,DecAm,0)
					TW:Create(Flower, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = FlowerPos}):Play()
                    --Flower.TopTexture.Transparency = (Fields.Flowers[Flower.FlowerID.Value].MaxPosition-Flower.Position.Y)/2.5
					TW:Create(Flower.TopTexture, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = (FieldGame.FlowerTable[Flower.FlowerID.Value].MaxP-Flower.Position.Y)/2.5}):Play()
				end
				moduleFlower.DownFlower()
                
                local CoinAdd = 0

                    if FoodAm ~= nil and Percent ~= nil then
                        local Convert = math.round(FoodAm *(Percent / 100))
                        local PollenAdd = math.round(FoodAm - Convert)
                        
                        if PollenAdd < 0 then
                            PollenAdd = 0
                        elseif Convert < 0 then
                            Convert = 0
                        end
                        CoinAdd += Convert

                        if TablePlayerFlower[Player.Name] ~= nil then
                            TablePlayerFlower[Player.Name][FColor] += PollenAdd
						    TablePlayerFlower[Player.Name].Coin += CoinAdd
                        end
                      --  print(TablePlayerFlower)
							--local Tabs = coroutine.create
                            spawn(function()
                            task.wait(0.001)
                            if TablePlayerFlower[Player.Name] ~= nil then
							for i,v in pairs(TablePlayerFlower[Player.Name]) do
								--print(TablePlayerFlower)
                                    if v > 0 then
									VEP:FireClient(Player, {Pos = Stamp, Amt = v, Color = i, Crit = Crit})
                                    end
                                end
							TablePlayerFlower[Player.Name].Coin = 0
                                TablePlayerFlower[Player.Name].Blue = 0
                                TablePlayerFlower[Player.Name].Red = 0
                                TablePlayerFlower[Player.Name].White = 0
                            end
                        end)
--coroutine.resume(Tabs)

						PData.BaseSettings.Pollen += math.round(PollenAdd)
						PData.BaseSettings.Coin += math.round(CoinAdd)
                        PData.TotalStats.TotalCoin += math.round(CoinAdd)
                        PData.TotalStats.CoinDayGame += math.round(CoinAdd)

					PData.TotalStats["Total"..FColor] += math.round(PollenAdd)

                        RemotesFolder:WaitForChild("DataUpdate"):FireClient(Player,{"BaseSeting", PData.BaseSettings})
                    end
                else
					PData.BaseSettings.Pollen = PData.BaseSettings.Capacity
                    RemotesFolder:WaitForChild("DataUpdate"):FireClient(Player,{"BaseSeting", PData.BaseSettings})
                    end
              
			end	
		end
                function moduleFlower:RegenUp(Field : Instance)
                    local InfoFieldGame = FieldGame[Field.Name]
                    for _, Pollen in pairs(Field:GetChildren()) do
                        if Pollen:IsA("BasePart") then
                            InfoFieldGame = FieldGame.FlowerTable[Pollen.FlowerID.Value]
                            Pollen.Changed:Connect(function()
                                if Pollen.Position.Y <= InfoFieldGame.MinP then
                                    Pollen.Position = Vector3.new(Pollen.Position.X, InfoFieldGame.MinP, Pollen.Position.Z)
                                end
                            end)
                        end
                    end

                    if InfoFieldGame then
			--local UpFlower = coroutine.create
						spawn(function()
                            while Field do task.wait(5)
                                for i, Pollen in pairs(Field:GetChildren()) do
                                    if Pollen:IsA("BasePart") then
                                    InfoFieldGame = FieldGame.FlowerTable[Pollen.FlowerID.Value]

									if Pollen.Position.Y <= InfoFieldGame.MinP then
										--moduleFlower.DownFlower()
                                            Pollen.Position = Vector3.new(Pollen.Position.X, InfoFieldGame.MinP, Pollen.Position.Z)
                                        end

                                        if Pollen.Position.Y < InfoFieldGame.MaxP then
                                            local ToMaxFlower = tonumber(InfoFieldGame.MaxP - Pollen.Position.Y)
											local FlowerPos = Pollen.Position + Vector3.new(0, ToMaxFlower, 0)
											local FlowerPosTime = Pollen.Position + Vector3.new(0,InfoFieldGame.RegenFlower,0)

                                            if ToMaxFlower <= InfoFieldGame.RegenFlower then
                                                TW:Create(Pollen, TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = FlowerPos}):Play()
                                            else
												TW:Create(Pollen, TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = FlowerPosTime}):Play()
                                            end
                                            if Pollen.Position.Y > InfoFieldGame.MaxP then
                                                Pollen.Position = Vector3.new(Pollen.Position.X, InfoFieldGame.MaxP, Pollen.Position.Z)
                                            end
                                        end
                                    end 
                                end
                            end
                        end)
                       -- coroutine.resume(InfoFieldGame)
                    end
                end
                task.wait(0.05)
                for i, v in pairs(Workspacee.FieldsGame:GetChildren()) do
                    moduleFlower:RegenUp(v)
                
            end
		end



return moduleFlower