task.wait()
local Server = script.Parent:WaitForChild("Server")
local Player = game.Players.LocalPlayer
local Characte = Player.Character or Player.CharacterAdded:Wait()
local RS = game:GetService("ReplicatedStorage")
local Remote = RS.Remotes
local HRP = Characte:WaitForChild("HumanoidRootPart")
local Him = Characte:WaitForChild("Humanoid")
local Tools = require(RS:WaitForChild("Modules").ItemsGame).Tools
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
--local Data = require(game.ServerScriptService:FindFirstChild("ServerGame"):WaitForChild("DataStoreGame")).New().ItemsUserEqiment.Tool
-- 
_G.PData = game.ReplicatedStorage.Remotes.GetDataSave:InvokeServer()
-- нужно сделать _G для таблицы
local ToolInfo = Tools[_G.PData.ItemsUserEqiment.Tool]


if not ToolInfo then
	warn("Tool isn't in moduleScript. Please joiner ServerStrorage")
	return
end

local Collect = false
local Debonuce = false
local TableAnim = require(RS:WaitForChild("Modules").ItemsGame).Tools.Scooper.ToolsSettings.AnimTools
	--[[for v1, Anim in pairs(TableAnim) do
		Anim[v1].ToolsSettings.
	end]]
	--require(RS:WaitForChild("Modules").ItemsGame).Tools.AnimTools
-- копание 
UIS.InputBegan:Connect(function(v1,v2)
	if not v2 and v1.UserInputType == Enum.UserInputType.MouseButton1 then
		Collect = true
	end
end)

UIS.InputEnded:Connect(function(v1,v2)
	if not v2 and v1.UserInputType == Enum.UserInputType.MouseButton1 then
		Collect = false
	end
end)

CAS:BindAction("Scoop", function(_, State)
	if State == Enum.UserInputState.Begin then
		Collect = true
	else 
		Collect = false
	end
end, true, Enum.KeyCode.ButtonB)
CAS:SetPosition("Scoop", UDim2.new(1, -70, 0, 10))
CAS:SetTitle("Scoop", "Scoop")
game:GetService("RunService").RenderStepped:Connect(function()
	if Collect and not Debonuce then
		Debonuce = true
		
		local Anim = Instance.new("Animation")
		Anim.AnimationId = TableAnim
		
		local AnimTrack = Him:LoadAnimation(Anim)
		local Cooldown = ToolInfo.ToolsSettings.SpeedCoper / (_G.PData.Boost.PlayerBoost["Collectors Speed"] / 100)
		AnimTrack.Priority = Enum.AnimationPriority.Action
		AnimTrack:Play()
		

		Server.Collect:FireServer(HRP, AnimTrack.Length)
		
		task.wait(Cooldown)
		Debonuce = false
		
		spawn(function()
			--task.wait(AnimTrack.Lenght)
			Anim:Destroy()
		end)
		--coroutine.resume(Co)
	end
end)

