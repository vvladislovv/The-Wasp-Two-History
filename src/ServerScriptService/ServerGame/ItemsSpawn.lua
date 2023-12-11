local PhysicsService = game:GetService("PhysicsService")
local Player = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Wroks = game:GetService("Workspace")
local Remote = RS:WaitForChild("Remotes")
local Items = RS:FindFirstChild("Assert")
local AssertSS = game.ServerStorage:FindFirstChild("Assert")
local DataSave = require(script.Parent.DataStoreGame)
local PlayerGroup = PhysicsService:RegisterCollisionGroup("p")
PhysicsService:CollisionGroupSetCollidable("p","p", false)


local Equiment = {} do
    
	function NoCollide(Model)
        
            Model:WaitForChild("Humanoid")
            Model:WaitForChild("HumanoidRootPart")
            Model:WaitForChild("Head")
            for index, value in pairs(Model:GetChildren()) do
                if value:IsA("BasePart") then
                    value.CollisionGroup = "p"
                end
            end
        
    end

	function LoadImage(Players, PData)
        local BlackList = {
            ["Tool"] = true,
            ["Bag"] = true,
            ["Boot"] = true,
            ["Hat"] = true,
            ["Glove"] = true,
            ["Belt"] = true,
            ["RGuard"] = true,
            ["LGuard"] = true,
            ["Parachute"] = true,
        }
		
    end

    function Equiment:LoadItems(Player, PData, Character)
        NoCollide(Character)
		local Humanoid = Character:FindFirstChild("Humanoid")

		Equiment:EquipItemsGame(Character, "Boot", PData)
		Equiment:EquipItemsGame(Character, "Parachute", PData)
		Equiment:EquipItemsGame(Character, "RGuard", PData)
		Equiment:EquipItemsGame(Character, "LGuard", PData)
		Equiment:EquipItemsGame(Character, "Glove", PData)
		Equiment:EquipItemsGame(Character, "Hat", PData)
		Equiment:EquipItemsGame(Character, "Tool", PData)
		Equiment:EquipItemsGame(Character, "Bag", PData)
		Equiment:EquipItemsGame(Character, "Belt", PData)


		Humanoid.Died:Connect(function()
            local Character = Player.CharacterAdded:Wait()
            local PData = DataSave:Get(Player)
            --TODO(Оповищение.что.рюкзак.пуст)
            PData.BaseSettings.Pollen = 0
			Equiment:LoadItems(Player, PData, Character)
        end)
    end

    function Equiment:StartSysmes()
        Player.PlayerAdded:Connect(function(Player)
            task.wait(2)
            local Character = workspace:WaitForChild(Player.Name)
            local PData = DataSave:Get(Player)
            Equiment:LoadItems(Player, PData, Character)
            LoadImage(Player, PData)
        end)
    end

    function Equiment:EquipItemsGame(Character, TypeItem, PData)
        local Humanoid = Character:WaitForChild("Humanoid")
		if PData.ItemsUserEqiment[TypeItem] then
			local Item = PData.ItemsUserEqiment[TypeItem]
			local ItemObj1
			local ItemObj2

            if Item ~= "" then
               if TypeItem == "Boot" then
                    if Item ~= "" then
						ItemObj1 = Items:WaitForChild(TypeItem.."s")[Item.."L"]:Clone()
						ItemObj2 = Items:WaitForChild(TypeItem.."s")[Item.."R"]:Clone()
                        Humanoid:AddAccessory(ItemObj1)
						Humanoid:AddAccessory(ItemObj2)
                        ItemObj1.Name = "Boot"
                        ItemObj2.Name = "Boot"
                    	end
                elseif TypeItem == "Glove" then
                    if Item ~= "" then
						ItemObj1 = Items:WaitForChild(TypeItem.."s")[Item.."L"]:Clone()
						ItemObj2 = Items:WaitForChild(TypeItem.."s")[Item.."R"]:Clone()
						Humanoid:AddAccessory(ItemObj1)
						Humanoid:AddAccessory(ItemObj2)
                        ItemObj1.Name = "Glove"
                        ItemObj2.Name = "Glove"
                    	end
                    else
					ItemObj1 = Items:WaitForChild(TypeItem.."s")[Item]:Clone() -- папки в RS с буквой S без этого не видно 
					if ItemObj1:IsA("Accessory") then
--						print("FFFFF")
                            for i,v in pairs(ItemObj1:GetChildren()) do
                                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") then
                                    v.Anchored = false
                                    v.CanCollide = false
                                    v.Massless = true
                                end
                            end

						if TypeItem == "Bag" then
							ItemObj1.Name = "Bag"
							Humanoid:AddAccessory(ItemObj1)
							--print("FFFF")
						elseif TypeItem == "Hat" then
							ItemObj1.Name = "Hat"
							Humanoid:AddAccessory(ItemObj1)
							
						elseif TypeItem == "LGuard" then
							ItemObj1.Name = "LGuard"
							Humanoid:AddAccessory(ItemObj1)
						elseif TypeItem == "RGuard" then
							ItemObj1.Name = "RGuard"
							Humanoid:AddAccessory(ItemObj1)
							
						elseif TypeItem == "Belt" then
							ItemObj1.Name = "Belt"
							Humanoid:AddAccessory(ItemObj1)
                        end
                    elseif ItemObj1:IsA("Tool") then
								local CollectScript = AssertSS.Tools:Clone()
								CollectScript.Parent = ItemObj1
								ItemObj1.Parent = Character
								ItemObj1.Name = "Tool"
									--print("FFFF")
                            else
                                ItemObj1.Parent = Character
                    end
               end
            end
        end
    end
end

return Equiment