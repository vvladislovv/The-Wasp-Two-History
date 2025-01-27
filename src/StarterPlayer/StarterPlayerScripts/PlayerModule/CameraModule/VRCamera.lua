--!nonstrict
--[[
	VRCamera - Roblox VR camera control module
	2021 Roblox VR
--]]

--[[ Services ]]--
local PlayersService = game:GetService("Players")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Local private variables and constants
local CAMERA_BLACKOUT_TIME = 0.1
local FP_ZOOM = 0.5

-- requires
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local Util = require(script.Parent:WaitForChild("CameraUtils"))

local FFlagUserVRRotationUpdate do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserVRRotationUpdate")
	end)
	FFlagUserVRRotationUpdate = success and result
end

local FFlagUserVRFollowCamera do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserVRFollowCamera2")
	end)
	FFlagUserVRFollowCamera = success and result
end

local FFlagUserVRRotationTweeks do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserVRRotationTweeks")
	end)
	FFlagUserVRRotationTweeks = success and result
end

local FFlagUserVRTorsoEstimation do
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled("UserVRTorsoEstimation")
	end)
	FFlagUserVRTorsoEstimation = success and result
end

--[[ The Module ]]--
local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local VRCamera = setmetatable({}, VRBaseCamera)
VRCamera.__index = VRCamera

function VRCamera.new()
	local self = setmetatable(VRBaseCamera.new(), VRCamera)

	self.lastUpdate = tick()
	if FFlagUserVRFollowCamera then
		self.focusOffset = CFrame.new()
	end
	self:Reset()

	return self
end

function VRCamera:Reset()
	self.needsReset = true
	self.needsBlackout = true
	self.motionDetTime = 0.0
	self.blackOutTimer = 0
	self.lastCameraResetPosition = nil
	if not FFlagUserVRRotationUpdate then
		self.stepRotateTimeout = 0.0
		self.cameraOffsetRotation = 0
		self.cameraOffsetRotationDiscrete = 0
	else
		VRBaseCamera.Reset(self)
	end
end

function VRCamera:Update(timeDelta)
	local camera = workspace.CurrentCamera
	local newCameraCFrame = camera.CFrame
	local newCameraFocus = camera.Focus

	local player = PlayersService.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = camera.CameraSubject

	if self.lastUpdate == nil or timeDelta > 1 then
		self.lastCameraTransform = nil
	end

	-- update fullscreen effects
	self:UpdateFadeFromBlack(timeDelta)
	self:UpdateEdgeBlur(player, timeDelta)

	local lastSubjPos = self.lastSubjectPosition
	local subjectPosition: Vector3 = self:GetSubjectPosition()
	-- transition from another camera or from spawn
	if self.needsBlackout then 
		self:StartFadeFromBlack()

		local dt = math.clamp(timeDelta, 0.0001, 0.1)
		self.blackOutTimer += dt
		if self.blackOutTimer > CAMERA_BLACKOUT_TIME and game:IsLoaded() then
			self.needsBlackout = false
			self.needsReset = true
		end
	end

	if subjectPosition and player and camera then
		newCameraFocus = self:GetVRFocus(subjectPosition, timeDelta)
		-- update camera cframe based on first/third person
		if self:IsInFirstPerson() then
			-- update camera CFrame
			newCameraCFrame, newCameraFocus = self:UpdateFirstPersonTransform(
				timeDelta,newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
		else -- 3rd person
			if FFlagUserVRFollowCamera then

				if VRService.ThirdPersonFollowCamEnabled then
					newCameraCFrame, newCameraFocus = self:UpdateThirdPersonFollowTransform(
						timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
				else
					newCameraCFrame, newCameraFocus = self:UpdateThirdPersonComfortTransform(
						timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
				end

			else
				newCameraCFrame, newCameraFocus = self:UpdateThirdPersonComfortTransform(
					timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
			end
		end

		self.lastCameraTransform = newCameraCFrame
		self.lastCameraFocus = newCameraFocus
	end

	self.lastUpdate = tick()
	return newCameraCFrame, newCameraFocus
end

-- returns where the floor should be placed given the camera subject, nil if anything is invalid
function VRCamera:GetAvatarFeetWorldYValue(): number?
	local camera = workspace.CurrentCamera
	local cameraSubject = camera.CameraSubject
	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") and cameraSubject.RootPart then
		local rootPart = cameraSubject.RootPart
		return rootPart.Position.Y - rootPart.Size.Y / 2 - cameraSubject.HipHeight
	end

	return nil
end

function VRCamera:UpdateFirstPersonTransform(timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
	-- transition from TP to FP
	if self.needsReset then
		self:StartFadeFromBlack()
		self.needsReset = false
		if not FFlagUserVRRotationUpdate then
			self.stepRotateTimeout = 0.25
			self.VRCameraFocusFrozen = true
			self.cameraOffsetRotation = 0
			self.cameraOffsetRotationDiscrete = 0
		end
	end

	-- blur screen edge during movement
	local player = PlayersService.LocalPlayer
	local subjectDelta = lastSubjPos - subjectPosition
	if subjectDelta.magnitude > 0.01 then
		self:StartVREdgeBlur(player)
	end
	-- straight view, not angled down
	local cameraFocusP = newCameraFocus.p
	local cameraLookVector = self:GetCameraLookVector()
	cameraLookVector = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

	local yawDelta -- inline with FFlagVRRotationUpdate
	if FFlagUserVRRotationUpdate then

		yawDelta = self:getRotation(timeDelta)
	else
		if self.stepRotateTimeout > 0 then
			self.stepRotateTimeout -= timeDelta
		end
		-- step rotate in 1st person
		local rotateInput = CameraInput.getRotation()
		yawDelta = 0
		if UserGameSettings.VRSmoothRotationEnabled then
			yawDelta = rotateInput.X
		else
			if self.stepRotateTimeout <= 0.0 and math.abs(rotateInput.X) > 0.03 then
				yawDelta = 0.5
				if rotateInput.X < 0 then
					yawDelta = -0.5
				end
				self.needsReset = true
			end
		end
	end

	local newLookVector = self:CalculateNewLookVectorFromArg(cameraLookVector, Vector2.new(yawDelta, 0))
	newCameraCFrame = CFrame.new(cameraFocusP - (FP_ZOOM * newLookVector), cameraFocusP)

	return newCameraCFrame, newCameraFocus
end

function VRCamera:UpdateThirdPersonComfortTransform(timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
	local zoom = self:GetCameraToSubjectDistance()
	if zoom < 0.5 then
		zoom = 0.5
	end

	if lastSubjPos ~= nil and self.lastCameraFocus ~= nil then
		-- compute delta of subject since last update
		local player = PlayersService.LocalPlayer
		local subjectDelta = lastSubjPos - subjectPosition
		local moveVector = require(player:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")):GetMoveVector()

		-- is the subject still moving?
		local isMoving = subjectDelta.magnitude > 0.01 or moveVector.magnitude > 0.01
		if isMoving then
			self.motionDetTime = 0.1
		end

		self.motionDetTime = self.motionDetTime - timeDelta
		if self.motionDetTime > 0 then
			isMoving = true
		end

		if isMoving and not self.needsReset then
			-- if subject moves keep old camera focus
			newCameraFocus = self.lastCameraFocus

			-- if the focus subject stopped, time to reset the camera
			self.VRCameraFocusFrozen = true
		else
			local subjectMoved = self.lastCameraResetPosition == nil or (subjectPosition - self.lastCameraResetPosition).Magnitude > 1

			-- compute offset for 3rd person camera rotation
			if FFlagUserVRRotationUpdate then
				local yawDelta = self:getRotation(timeDelta)
				if math.abs(yawDelta) > 0 then
					local cameraOffset = newCameraFocus:ToObjectSpace(newCameraCFrame)
					local rotatedFocus -- inline with FFlagUserVRRotationTweeks
					if FFlagUserVRRotationTweeks then
						rotatedFocus = newCameraFocus * CFrame.Angles(0, -yawDelta, 0)
					else
						rotatedFocus = newCameraFocus * CFrame.Angles(0, yawDelta, 0)
					end
					newCameraCFrame = rotatedFocus * cameraOffset
				end

				-- recenter the camera on teleport
				if (self.VRCameraFocusFrozen and subjectMoved) or self.needsReset then
					VRService:RecenterUserHeadCFrame()

					self.VRCameraFocusFrozen = false
					self.needsReset = false
					self.lastCameraResetPosition = subjectPosition

					self:ResetZoom()
					self:StartFadeFromBlack()

					-- get player facing direction
					local humanoid = self:GetHumanoid()
					local forwardVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or Vector3.new(1,0,0)
					-- adjust camera height
					local vecToCameraAtHeight = Vector3.new(forwardVector.X, 0, forwardVector.Z)
					local newCameraPos = newCameraFocus.Position - vecToCameraAtHeight * zoom
					-- compute new cframe at height level to subject
					local lookAtPos = Vector3.new(newCameraFocus.Position.X, newCameraPos.Y, newCameraFocus.Position.Z)

					newCameraCFrame = CFrame.new(newCameraPos, lookAtPos)
				end

			else
				local rotateInput = CameraInput.getRotation()
				local userCameraPan = rotateInput ~= Vector2.new()
				local panUpdate = false
				if userCameraPan then
					if rotateInput.X ~= 0 then
						local tempRotation = self.cameraOffsetRotation + rotateInput.X;
						if(tempRotation < -math.pi) then
							tempRotation = math.pi - (tempRotation + math.pi) 
						else
							if (tempRotation > math.pi) then
								tempRotation = -math.pi + (tempRotation - math.pi) 
							end
						end
						self.cameraOffsetRotation = math.clamp(tempRotation, -math.pi, math.pi)
						if UserGameSettings.VRSmoothRotationEnabled then
							self.cameraOffsetRotationDiscrete = self.cameraOffsetRotation
							-- get player facing direction
							local humanoid = self:GetHumanoid()
							local forwardVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or Vector3.new(1,0,0)
							-- adjust camera height
							local vecToCameraAtHeight = Vector3.new(forwardVector.X, 0, forwardVector.Z)
							local newCameraPos = newCameraFocus.Position - vecToCameraAtHeight * zoom
							-- compute new cframe at height level to subject
							local lookAtPos = Vector3.new(newCameraFocus.Position.X, newCameraPos.Y, newCameraFocus.Position.Z)
							local tempCF = CFrame.new(newCameraPos, lookAtPos)
							tempCF = tempCF * CFrame.fromAxisAngle(Vector3.new(0,1,0), self.cameraOffsetRotationDiscrete)
							newCameraPos = lookAtPos - (tempCF.LookVector * (lookAtPos - newCameraPos).Magnitude)
							newCameraCFrame = CFrame.new(newCameraPos, lookAtPos)
						else
							local tempRotDisc = math.floor(self.cameraOffsetRotation * 12 / 12)
							if tempRotDisc ~= self.cameraOffsetRotationDiscrete then
								self.cameraOffsetRotationDiscrete = tempRotDisc
								panUpdate = true
							end
						end
					end
				end

				-- recenter the camera on teleport
				if (self.VRCameraFocusFrozen and subjectMoved) or self.needsReset or panUpdate then
					if not panUpdate then
						self.cameraOffsetRotationDiscrete = 0
						self.cameraOffsetRotation = 0
					end

					VRService:RecenterUserHeadCFrame()

					self.VRCameraFocusFrozen = false
					self.needsReset = false
					self.lastCameraResetPosition = subjectPosition

					self:ResetZoom()
					self:StartFadeFromBlack()

					-- get player facing direction
					local humanoid = self:GetHumanoid()
					local forwardVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or Vector3.new(1,0,0)
					-- adjust camera height
					local vecToCameraAtHeight = Vector3.new(forwardVector.X, 0, forwardVector.Z)
					local newCameraPos = newCameraFocus.Position - vecToCameraAtHeight * zoom
					-- compute new cframe at height level to subject
					local lookAtPos = Vector3.new(newCameraFocus.Position.X, newCameraPos.Y, newCameraFocus.Position.Z)

					if self.cameraOffsetRotation ~= 0 then
						local tempCF = CFrame.new(newCameraPos, lookAtPos)
						tempCF = tempCF * CFrame.fromAxisAngle(Vector3.new(0,1,0), self.cameraOffsetRotationDiscrete)
						newCameraPos = lookAtPos - (tempCF.LookVector * (lookAtPos - newCameraPos).Magnitude)
					end

					newCameraCFrame = CFrame.new(newCameraPos, lookAtPos)
				end
			end
		end
	end

	return newCameraCFrame, newCameraFocus
end

function VRCamera:UpdateThirdPersonFollowTransform(timeDelta, newCameraCFrame, newCameraFocus, lastSubjPos, subjectPosition)
	local camera = workspace.CurrentCamera :: Camera
	local zoom = self:GetCameraToSubjectDistance()
	local vrFocus = self:GetVRFocus(subjectPosition, timeDelta)

	if self.needsReset then

		self.needsReset = false

		VRService:RecenterUserHeadCFrame()
		self:ResetZoom()
		self:StartFadeFromBlack()
	end
	
	if self.recentered then
		local subjectCFrame = self:GetSubjectCFrame()
		if not subjectCFrame then -- can't perform a reset until the subject is valid
			return camera.CFrame, camera.Focus
		end
		
		-- set the camera and focus to zoom distance behind the subject
		newCameraCFrame = vrFocus * subjectCFrame.Rotation * CFrame.new(0, 0, zoom)

		self.focusOffset = vrFocus:ToObjectSpace(newCameraCFrame) -- GetVRFocus returns a CFrame with no rotation
		
		self.recentered = false
		return newCameraCFrame, vrFocus
	end

	local trackCameraCFrame = vrFocus:ToWorldSpace(self.focusOffset)
	
	-- figure out if the player is moving
	local player = PlayersService.LocalPlayer
	local subjectDelta = lastSubjPos - subjectPosition
	local controlModule = require(player:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local moveVector = controlModule:GetMoveVector()

	-- while moving, slowly adjust camera so the avatar is in front of your head
	if subjectDelta.magnitude > 0.01 or moveVector.magnitude > 0 then -- is the subject moving?

		local headOffset = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		if FFlagUserVRTorsoEstimation then
			headOffset = controlModule:GetEstimatedVRTorsoFrame()
		end
		-- account for headscale
		headOffset = headOffset.Rotation + headOffset.Position * camera.HeadScale
		local headCframe = camera.CFrame * headOffset
		local headLook = headCframe.LookVector

		local headVectorDirection = Vector3.new(headLook.X, 0, headLook.Z).Unit * zoom
		local goalHeadPosition = vrFocus.Position - headVectorDirection
		
		-- place the camera at currentposition + difference between goalHead and currentHead 
		local moveGoalCameraCFrame = CFrame.new(camera.CFrame.Position + goalHeadPosition - headCframe.Position) * trackCameraCFrame.Rotation 

		newCameraCFrame = trackCameraCFrame:Lerp(moveGoalCameraCFrame, 0.01)
	else
		newCameraCFrame = trackCameraCFrame
	end

	-- compute offset for 3rd person camera rotation
	local yawDelta = self:getRotation(timeDelta)
	if math.abs(yawDelta) > 0 then
		local cameraOffset = vrFocus:ToObjectSpace(newCameraCFrame)
		local rotatedFocus -- inline with FFlagUserVRRotationTweeks
		if FFlagUserVRRotationTweeks then
			 rotatedFocus = vrFocus * CFrame.Angles(0, -yawDelta, 0)
		 else
			 rotatedFocus = vrFocus * CFrame.Angles(0, yawDelta, 0)
		 end

		newCameraCFrame = rotatedFocus * cameraOffset
	end

	self.focusOffset = vrFocus:ToObjectSpace(newCameraCFrame) -- GetVRFocus returns a CFrame with no rotation

	-- focus is always in front of the camera
	newCameraFocus = newCameraCFrame * CFrame.new(0, 0, -zoom)

	-- vignette
	if (newCameraFocus.Position - camera.Focus.Position).Magnitude > 0.01 then
		self:StartVREdgeBlur(PlayersService.LocalPlayer)
	end

	return newCameraCFrame, newCameraFocus
end

function VRCamera:EnterFirstPerson()
	self.inFirstPerson = true

	self:UpdateMouseBehavior()
end

function VRCamera:LeaveFirstPerson()
	self.inFirstPerson = false
	self.needsReset = true
	self:UpdateMouseBehavior()
	if self.VRBlur then
		self.VRBlur.Visible = false
	end
end

return VRCamera