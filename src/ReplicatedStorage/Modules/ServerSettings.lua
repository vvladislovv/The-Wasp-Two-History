local GuiService = game:GetService("GuiService")
local RunS = game:GetService("RunService")
local CameraWork = workspace.Camera
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")


local Settings = {} do
    Settings.LoadScript = {}

    local TablePrefix = {
        "","k","M","B","T","qd","Qn","Sx","Sp","Oc","N"
    }

    local v1 = nil
    local v2 = 0
    local v3 = 0.75 * math.pi

    function Settings.GetNumTable(Table,Type)
        local NumV1 = 0
        for i, Chang in pairs(Table) do
            NumV1 += Chang
        end
        return NumV1
    end



    function Settings:AddPrefixT(Num)
        for i = 1, #TablePrefix do
            if Num < 10 ^ (i * 3) then
                return math.floor(Num / ((10 ^ ((i - 1) * 3)) / 100)) / (100) .. TablePrefix[i]
            end
        end
    end
    function Settings:CommandNumber(Num)
        Num = tostring(Num)
        return Num:reverse():gsub("%d%d$d","%1,"):reverse():gsub("^,", "")
    end


    function Settings:DeepCopy(Original)
        local Copy = {}
        
        for Key, value in pairs(Original) do
            if type(value) == "table" then
                value = Settings:DeepCopy()
            end
                Copy[Key] = value
        end
        return Copy
    end


    function Settings:TweenCam(CamPart, CframeCam, CF)
        CameraWork.cameraType = Enum.CameraType.Scriptable
        TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {FieldOfView = 55}):Play()
        
        if CamPart then
            CF = CamPart.CFrame 
            else
                CF = CframeCam 
            end
                local Info = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                local Tween = TweenService:Create(CameraWork, Info, {CFrame = CF})
                Tween:Play()
        
    end

    function Settings:TweenModel(Modele, CF, Info)
        if Modele:IsA("Model") then
            local CFrameValue = Instance.new("CFrameValue")
            CFrameValue.Value = Modele:GetPrimaryPartCFrame()

            CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
                if Modele.PrimaryPart ~= nil then
                    Modele:SetPrimaryPartCFrame(CFrameValue.Value)
                end
            end)

            local Tween = TweenService:Create(CFrameValue, Info, {Value = CF})

            Tween.Completed:Connect(function()
                CFrameValue:Destroy()
            end)
            else 
            warn("Error: Object to go fake!")
        end
    end
end

return Settings