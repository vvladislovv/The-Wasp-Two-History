local Data = {}

local Rep = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = Rep:WaitForChild("Remotes")
local Player = game:GetService("Players")
--_G.PData = game.ReplicatedStorage.Remotes.GetDataSave:InvokeServer()
local DataStore2 = require(game.ServerScriptService.DataStore2)
local AutoSave = {}

Data.PlayerData = {}

local Serverkey = 'Data_Serverkey_S'
local ClientKey = 'Data_Clientkey_S'


function Data.New(Player)
    local PData = {}
	
	PData.GameSettings = {
		HiveOwner = "",
		YouField = "",
	}
	
	PData.BaseSettings = { -- нужно убрать сохранение 
		Capacity = 350,
        Coin = 0,
		Pollen = 0,
		Wasp = 0,
		MarketItems = 0,
		
        CodeWriter = {},
		Location = {},
        Donats = {},
        Trade = {},
        
    }
    PData.Hives = {
        SlotHives = 5,
        WaspAllSlotHive = 0,
        WaspItemsSlotHive = 0
    }
    PData.ModsTime = {
        Artik = {
            Gametime = 0,
            Attack = 0
        }
    }
    PData.Invetory = {
        ["Classic eggs"] = 1
    }
    PData.Bagers = {
        ["Name Bagers"] = {
            Rank = 0,
            Series = "None",
            Amt = 0,
        } 
    }
    PData.AmuletesSetings = {
        NewAmuletes = {},
        OldAmuletes = {},
        
        SettingsAmuletes = {
            ["Name Amulet"] = {
                AStats = {
                    OneStats = "",
                    TwoStats = "",
                    ThreeStats = "",
                    FourStats = "",
                    FiveStas = "",
                }
            }
        }
    }
    PData.TotalStats = {
        TotalCapacity = 0,
        TotalPollen = 0,
        TotalCoin = 0,
        CoinDayGame = 0,
        TotalWasp = 0,
        TotalHiveSlot = 32,
        TotalQuestNPC = 0,
        TotalTimeGame = 0,
        TotalMarket = 0,
        TotalKillMods = 0,
		TotalPets = 0,
		
		TotalRed = 0,
		TotalWhite = 0,
		TotalBlue = 0
    }
    PData.ItemsUserEqiment = {
		Tool = "Scooper",
		Bag = "Handbag",
        Boot = "",
        Hat = "",
        Glove = "",
        Belt = "",
        RGuard = "",
        LGuard = "",
        Parachute = "",  
    }
	
	PData.EqimentDoper = {
		--[[Amulet = {
			AmuletPearBoss = "",
		},]]
		Pet = "",
	}
	
    PData.Quests = {
        ["Name NPC"] = {NewQuest = true, TotalQuestNPC = 0, TotalQuest = 10, InfQuest = false, HoliQuest = false}
    }
    PData.Boost = {
        WaspBoost = {
            --Attack
			["Attack"] = 100,
			["AttackRed"] = 100,
			["AttackBlue"] = 100,
			["AttackWhite"] = 100,
			["AtAcK"] = 100,
            -- Pollen
			["Pollen+"] = 100,
			["PollenTotal"] = 100,
			["Wasps Pollen"] = 100,
			["Boom"] = 100,
        

        },
        PlayerBoost = {
			["Pollen"] = 100,
			["Red Pollen"] = 100,
			["White Pollen"] = 100,
			["Blue Pollen"] = 100,
			
			["Instant"] = 0,
			["Red Instant"] = 0,
			["White Instant"] = 0,
			["Blue Instant"] = 0,
			["Pollen From Collectors"] = 100,
			["Collectors Speed"] = 100,
			["Critical Power"] = 100,
        },

    }
    PData.Donat = {
        BoostDonat = {
            ["Wasp is Pollen"]  = 0,
            ["WASPER"] = 0,
            ["Tools is Pollen"] = 0,
            ["Coin is 2x"] = 0,
            ["Pollen is 2x"] = 0,
        }
    }
    PData.GuiSettings = {
	    ["Music"] = false,
	    ["Text pollen"] = false,
	    ["Graphics"] = false,
	    ["Effects"] = false,
    }
    Data.PlayerData[Player.Name] = PData
    return PData
end

function CheakRunScript()
    if RunService:IsServer() then
        print("Data Start on server")
        else
        print("Data Died")
    end
end

function Data.DataTablePrint()
        local PData = Data.New()
        print(PData)
 end


function Data:Get(Player) --CheckServer
    if RunService:IsServer() then
        return Data.PlayerData[Player.Name]
    else
        Remotes.GetDataSave:InvokeServer()
    end
 end


function LoadData(Client)
    DataStore2.Combine(Serverkey, ClientKey)
    local PData = Data.New(Client)
    local DataStorage = DataStore2(ClientKey, Client):GetTable(PData)
	PData = GetTableData(Client, DataStorage)
	AutoSave[Client.Name] = Client
end
 
function GetTableData(Client, DataStorage)
    local PData = Data:Get(Client)
	
	for i,v in pairs(DataStorage) do
		PData.BaseSettings[i] = DataStorage.BaseSettings[i]
		PData.Hives[i] = DataStorage.Hives[i]
		PData.Invetory[i] = DataStorage.Invetory[i]
		PData.ModsTime[i] = DataStorage.ModsTime[i]
		PData.Bagers[i] = DataStorage.Bagers[i]
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
		PData.TotalStats[i] = DataStorage.TotalStats[i]
		PData.ItemsUserEqiment[i] = DataStorage.ItemsUserEqiment[i]
		PData.EqimentDoper[i] = DataStorage.EqimentDoper[i]
		PData.Quests[i] = DataStorage.Quests[i]
		PData.Boost[i] = DataStorage.Boost[i]
		PData.Donat[i] = DataStorage.Donat[i]
		PData.GuiSettings[i] = DataStorage.GuiSettings[i]
	end
	
	--[[
	for i, v in pairs(DataStorage.BaseSettings) do
		PData.BaseSettings[i] = DataStorage.BaseSettings[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.Hives[i] = DataStorage.Hives[i]
	end
	
	for i, v in pairs(DataStorage.ModsTime) do
		PData.ModsTime[i] = DataStorage.ModsTime[i]
	end
	
	for i, v in pairs(DataStorage.Invetory) do
		PData.Invetory[i] = DataStorage.Invetory[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.Hives[i] = DataStorage.Hives[i]
	end
	
	for i, v in pairs(DataStorage.Bagers) do
		PData.Bagers[i] = DataStorage.Bagers[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	
	for i, v in pairs(DataStorage.Hives) do
		PData.AmuletesSetings[i] = DataStorage.AmuletesSetings[i]
	end
	]]
end

function DataSave(Client, PData)
    DataStore2(ClientKey, Client):Set(PData)
    --Data.DataTablePrint()
end

do
    function DataAuto(AutoSave, Clint)
        local TiweDown = 120 -- 1 mintes
       		local ProgaramCO = coroutine.create(function()
                while TiweDown do
                    if AutoSave and TiweDown == 0 then
					DataSave(Player)
				else
					warn("DataAuto isn't save settings Player")
                    end
				end
		end)
		coroutine.resume(ProgaramCO)
		if coroutine.status(ProgaramCO) == "dead" then
			warn("Corontine INVALID BICH")
		end
		
    end

    game.ReplicatedStorage.Remotes.GetDataSave.OnServerInvoke = function(Client)
        local PData = Data:Get(Client)
        return PData
    end
    
    game.Players.PlayerAdded:Connect(function(Client)
        LoadData(Client)
        CheakRunScript()
    end)
    game.Players.PlayerRemoving:Connect(function(Client)
        DataSave(Client, Data:Get(Client))
        AutoSave[Client.Name] = nil
    end)

end


return Data

