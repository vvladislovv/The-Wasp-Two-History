local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Server game:GetService("ServerScriptService")
local Player = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--local Tokents = require(script.Parent.Toketns)
--local Flower = require(script.Parent.Flower)

local ModuleField = {} do
	ModuleField.FlowerModule = {
		["PearOneLevel"] = "Pear", -- 1(Name Part Field Model in Model); 2(Name Field in Table and in Workspace) PearGroup - название модели
		["PearTwoLevel"] = "Pear",
		["PearBoosLevel"] = "Pear",
		
		["BlackberryOneLevel"] = "Blackberry",
		["BlackberryTwoLevel"] = "Blackberry",
		
		["MacOnelevelMin"] = "Mac",
		["MacOnelevelBig"] = "Mac",
		
		["BananaOneLevel"] = "Banana",
		
	}
	ModuleField.FieldsFolder = {
		["Pear"] = {
			Flowers = {
				MinB = 4,
				TwoB = 0,
				ThreeB = 0,

				MinR = 0,
				TwoR = 5,
				ThreeFR = 0,

				MinW = 2,
				TwoW = 0,
				ThreeW = 0,

			},
		},
		["Blackberry"] = {
			Flowers = {
				MinFlowerB = 4,
				TwoB = 0,
				ThreeB = 0,

				MinR = 0,
				TwoR = 10,
				ThreeR = 0,

				MinW = 2,
				TwoW = 0,
				ThreeW = 0,

			},
		},
		["Mac"] = {
			Flowers = {
				MinFlowerB = 0,
				TwoB = 0,
				ThreeB = 5,

				MinR = 5,
				TwoR = 0,
				ThreeR = 5,

				MinW = 2,
				TwoW = 0,
				ThreeW = 5,

			},
		},
		["Banana"] = {
			Flowers = {
				MinB = 4,
				TwoB = 0,
				ThreeB = 0,

				MinR = 0,
				TwoR = 5,
				ThreeR = 0,

				MinW = 2,
				TwoW = 0,
				ThreeW = 0,

			},
		},
	}
	ModuleField.FlowerTable = {}
	ModuleField.MaxFlower = 3
	ModuleField.FlowerTexture = {
		["1Blue"] = "rbxassetid://15334797787",
		["2Blue"] = "rbxassetid://15334805307",
		["3Blue"] = "rbxassetid://15334801355",

		["1Red"] = "rbxassetid://15334798889",
		["2Red"] = "rbxassetid://15334807071",
		["3Red"] = "rbxassetid://15334802479",

		["1White"] = "rbxassetid://15334799916",
		["2White"] = "rbxassetid://15334813156",
		["3White"] = "rbxassetid://15334803638",
	}

	if RunService:IsClient() then
		print("Working is Client")
	elseif RunService:IsServer() then
		print("Working is Server")
	end


	function TextInType(FN)
		local Type = {}
		if string.find(FN, "Min") then --FN - FlowerName 
			Type["Value"] = "1"
		elseif string.find(FN, "Two") then
			Type["Value"] = "2"
		elseif string.find(FN, "Three") then
			Type["Value"] = "3"
		end

		if string.find(FN, "R") then
			Type["Color"] = "Red"
		elseif string.find(FN, "B") then
			Type["Color"] = "Blue"
		elseif string.find(FN, "W") then
			Type["Color"] = "White"
		end
		Type["Texture"] = ModuleField.FlowerTexture[FN]
		return Type
	end

	function RandomeNumber(FieldName)
		local Main = {}
		local Number = 0 

		for i, v in pairs(ModuleField.FieldsFolder[FieldName].Flowers) do
			if v > 0 then
				Main[#Main+1] = {v + Number, i}
				Number = Number + v
			end
		end
		local RandomeNumber = math.random(0, Number)
		for i, v in pairs(Main) do
			if RandomeNumber <= v[1] then
				return v[2]
			end 
		end
		return nil

	end

	function ModuleField:CreatFlower(Flower)
		local FlowerType = TextInType(RandomeNumber(ModuleField.FlowerModule[Flower.Parent.Name]))
		local FlowerID = Flower:FindFirstChild("FlowerID")
		local FlowerColor = FlowerType.Color
		local ID = #ModuleField.FlowerTable + 1
		FlowerID.Value = ID
		ModuleField.FlowerTable[ID] = {
			Stat = FlowerType,
			Color = FlowerColor,
			RegenFlower = 0.5,
			MaxP = Flower.Position.Y,
			MinP = Flower.Position.Y - 2,
		}
		Flower.TopTexture.Texture = ModuleField.FlowerTexture[ModuleField.FlowerTable[ID].Stat.Value..ModuleField.FlowerTable[ID].Color] -- Size; Color
	end

	function ModuleField:RegenFlower(FlowerPart)
		local TweenService = game:GetService("TweenService")
		local FlowerPart = SS:WaitForChild("FlowerClone")
		FlowerPart:Clone()
		local TweenSetings = TweenInfo.new(
			2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			-1,
			true
		)
		local TweenFlower = TweenService:Create(FlowerPart, TweenSetings, {Position = Vector3.new(0,0,0)}) -- Flower Vectore Y
		local TableSettings = {
			RegenFlower = 2,
			MaxP = FlowerPart.Position.Y,
			MinP = FlowerPart.Position.Y - 2,
		}

		if FlowerPart.Position.Y - 2.5 and TableSettings[3] == true  then
			task.wait(TableSettings[1])
			TweenFlower:Play()
			if TableSettings[2] == true then
				TweenFlower:Pause()
			end         
		end
	end

	function ModuleField:FlowerCreatINField(Field, Position, Orientation)
		
		local Flower = Instance.new("Part", Field)
		Flower.Name = "FlowerClone"
		Flower.Size = Vector3.new(4,3,4)
		--Flower.Parent = Field
		Flower.CFrame = Position
		Flower.Material = Enum.Material.SmoothPlastic
		Flower.Color = Color3.fromRGB(53, 177, 98)
		Flower.CanCollide = false
		Flower.Anchored = true

		local FlowerId = Instance.new("IntValue", Flower)
		FlowerId.Value = 0
		FlowerId.Name = "FlowerID"

		local TopTexture = Instance.new("Decal", Flower)
		TopTexture.Name = "TopTexture"
		TopTexture.Texture = "rbxassetid://"
		TopTexture.Transparency = 0
		TopTexture.Face = "Top" 
		
		local MathPOS = math.random(1,4)
		if MathPOS == 1 then Flower.Orientation = Vector3.new(0,90,0) 
		elseif MathPOS == 2 then Flower.Orientation = Vector3.new(0,180,0) 
		elseif MathPOS == 3 then Flower.Orientation = Vector3.new(0,-90,0) 
		elseif MathPOS == 4 then Flower.Orientation = Vector3.new(0,-180,0) end
		ModuleField:CreatFlower(Flower)
	end

	function ModuleField:GenerateField(FlowerZoneP)
		if workspace.FieldsGame:FindFirstChild(FlowerZoneP.Parent.Name) then
			local FieldRead = Workspace.FieldsGame:FindFirstChild(FlowerZoneP.Parent.Name)
			FlowerZoneP.Transparency = 1
			--Formaly
			-- left(a+b) одна сторона
			-- right(a+b) вторая сторона
			local left = FlowerZoneP.Position + Vector3.new((FlowerZoneP.Size.X / 2) -1, 0, (FlowerZoneP.Size.Z / 2) -1)
			local right = FlowerZoneP.Position - Vector3.new((FlowerZoneP.Size.X / 2) -1, 0, (FlowerZoneP.Size.Z / 2) -1)

			-- Размеры
			local v1 = left.X 
			local v2 = left.Z

			local v3 = right.X
			local v4 = right.Z
			-- ошибка тут в формуле 
			for CFright  = math.min(v1,v3), math.max(v1,v3), 4 do
				for CFleft  = math.min(v2,v4), math.max(v2,v4), 4 do
					ModuleField:FlowerCreatINField(FieldRead, CFrame.new(CFright, left.Y, CFleft))
					end
				end	
		else
			local FieldRead = Instance.new("Model", workspace.FieldsGame)
			FieldRead.Name = FlowerZoneP.Parent.Name
			FlowerZoneP.Transparency = 1
			--Formaly
			-- left(a+b) одна сторона
			-- right(a+b) вторая сторона
			local left = FlowerZoneP.Position + Vector3.new((FlowerZoneP.Size.X / 2)-1 , 0, (FlowerZoneP.Size.Z / 2) -1)
			local right = FlowerZoneP.Position - Vector3.new((FlowerZoneP.Size.X / 2)-1 , 0, (FlowerZoneP.Size.Z / 2) -1)

			-- Размеры
			local v1 = left.X 
			local v2 = left.Z

			local v3 = right.X
			local v4 = right.Z
			-- ошибка тут в формуле 
			for CFright  = math.min(v1,v3), math.max(v1,v3), 4 do
				for CFleft  = math.min(v2,v4), math.max(v2,v4), 4 do
					ModuleField:FlowerCreatINField(FieldRead, CFrame.new(CFright, left.Y, CFleft))

				end
			end
		end
	end

	-- Generator
	
for i, Fields in pairs(Workspace.FieldFolder:GetChildren()) do
	for i,V in pairs(Fields:GetChildren()) do
		if V:IsA("Part") then
			if not (V.Name == "World") then
				ModuleField:GenerateField(V)
			end
		end
	end
end
	
end	

return ModuleField
-- part workspace error SIZE AND POSITIONS
