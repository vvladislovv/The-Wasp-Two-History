local HiveModule = require(game.ReplicatedStorage.Modules:WaitForChild("HiveSytems"))
--local FieldFlower = require(Rep:WaitForChild("FlowerCollect"))
--local Field = require(Rep:WaitForChild("FieldSystems"))

HiveModule:StartScript()-- Start Module

require(script.ItemsSpawn):StartSysmes()
require(script.DataStoreGame) -- data
--require(script.Parent.HiveSytems):StartScript()

--print(_G.PData)
require(script.Tokens)
require(script.ThemeGame) -- Theme game 

