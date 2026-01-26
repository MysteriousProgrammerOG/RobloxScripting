Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

local Kills = script.Kills.Value

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local BaseUrl = "rbxassetid://"

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

DamageValues = {
	BaseDamage = 0,
	SlashDamage = 2,
	LungeDamage = 5
}

--For R15 avatars
Animations = {
	R15Slash = 522635514,
	R15Lunge = 522638767
}

Damage = DamageValues.BaseDamage

Grips = {
	Up = CFrame.new(0, 0, -1.70000005, 0, 0, 1, 1, 0, 0, 0, 1, 0),
	Out = CFrame.new(0, 0, -1.70000005, 0, 1, 0, 1, -0, 0, 0, 0, -1)
}

Sounds = {
	Slash = Handle:WaitForChild("SwordSlash"),
	Lunge = Handle:WaitForChild("SwordLunge"),
	Unsheath = Handle:WaitForChild("Unsheath")
}

ToolEquipped = false

local CounterPlace = Tool.Handle.KillCounter

local confirm = false

--For Omega Rainbow Katana thumbnail to display a lot of particles.
for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("ParticleEmitter") then
		v.Rate = 20
	end
end

Tool.Grip = Grips.Up
Tool.Enabled = true

-- === Custom Kill Value Support ===
local function GetKillValueFromHumanoid(humanoid)
	local killValue = 1 -- default
	if humanoid.Parent then
		-- Check for Attribute first
		if humanoid.Parent:GetAttribute("KillValue") then
			killValue = humanoid.Parent:GetAttribute("KillValue")
		else
			-- Then check for a NumberValue child named "KillValue"
			local val = humanoid.Parent:FindFirstChild("KillValue")
			if val and val:IsA("NumberValue") then
				killValue = val.Value
			end
		end
	end
	return killValue
end

-- Modular Kill Function 
-- Kill Table (This is where phases are stored)
local KillPhases = {
	[5] = {
		WalkSpeed = 20,
		JumpPower = 50,
		LungeDamage = 5,
		SlashDamage = 2,
		BaseDamage = 1,
		MaxHealth = 100,
		CurrentHealth = 100,
		RegenRate = 5, -- per second
		Sound = "M5",
		Highlight = "H5",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura1",
		Extra = function(plr)
			local handle = Tool:FindFirstChild("Handle")
			if handle then
				handle.Fire.Enabled = true
				handle.Fire2.Enabled = true
			end
		end
	},
	[10] = {
		WalkSpeed = 39,
		JumpPower = 55,
		LungeDamage = 14,
		SlashDamage = 7,
		BaseDamage = 2,
		MaxHealth = 150,
		CurrentHealth = 150,
		RegenRate = 8,
		Sound = "M10",
		Highlight = "H10",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura2",
		ColorEffect = {TintColor = Color3.fromRGB(255,0,0), Flash = true}
	},
	[25] = {
		WalkSpeed = 52,
		JumpPower = 60,
		LungeDamage = 20,
		SlashDamage = 10,
		BaseDamage = 3,
		MaxHealth = 200,
		CurrentHealth = 200,
		RegenRate = 10,
		Sound = "M25",
		Highlight = "H25",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura3",
		ColorEffect = {TintColor = Color3.fromRGB(0,255,255), Flash = true, Delay = 20}, -- This effects the screen of all server members
		Extra = function(plr) -- the Extra variable is used to create a function within the phase, usful for adding special effect like part rotations or forcefeilds for cutscenes
			local Debris = game:GetService("Debris")
			local field = Instance.new("ForceField", plr.Character)
			Debris:AddItem(field, 20)
		end
	},
	[50] = {
		WalkSpeed = 25,
		JumpPower = 70,
		LungeDamage = 148,
		SlashDamage = 89,
		BaseDamage = 5,
		MaxHealth = 2147483647,
		CurrentHealth = 2147483647,
		RegenRate = 50,
		Sound = "M50",
		Highlight = "H50",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura4",
		ColorEffect = {TintColor = Color3.fromRGB(0,255,0), Flash = true}
	},
	[75] = {
		WalkSpeed = 33,
		JumpPower = 72,
		LungeDamage = 28,
		SlashDamage = 18,
		BaseDamage = 5,
		MaxHealth = 500,
		CurrentHealth = 500,
		RegenRate = 15,
		Sound = "M75",
		Highlight = "H75",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura5",
		ColorEffect = {TintColor = Color3.fromRGB(170,85,255), Flash = true}
	},
	[100] = {
		WalkSpeed = 78,
		JumpPower = 80,
		LungeDamage = 56,
		SlashDamage = 28,
		BaseDamage = 10,
		MaxHealth = 450,
		CurrentHealth = 450,
		RegenRate = 20,
		Sound = "M100",
		Highlight = "H100",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura6",
		ColorEffect = {TintColor = Color3.fromRGB(255,255,0), Flash = true, Blur = 20}
	},
	[175] = {
		WalkSpeed = 91,
		JumpPower = 85,
		MaxHealth = 750,
		CurrentHealth = 750,
		RegenRate = 25,
		Sound = "M175",
		Highlight = "H175",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura7",
		ColorEffect = {TintColor = Color3.fromRGB(255,85,255), Flash = true}
	},
	[250] = {
		WalkSpeed = 32,
		JumpPower = 75,
		LungeDamage = 99,
		SlashDamage = 59,
		BaseDamage = 15,
		MaxHealth = 1250,
		CurrentHealth = 1250,
		RegenRate = 30,
		Sound = "M250",
		Highlight = "H250",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura8",
		ColorEffect = {TintColor = Color3.fromRGB(255,255,255), Flash = true, Blur = 21}
	},
	[500] = {
		WalkSpeed = 25,
		JumpPower = 80,
		LungeDamage = 148,
		SlashDamage = 89,
		BaseDamage = 20,
		MaxHealth = 2500,
		CurrentHealth = 2500,
		RegenRate = 50,
		Sound = "M500",
		Highlight = "H500",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura9",
		ColorEffect = {TintColor = Color3.fromRGB(85,255,0), Flash = true}
	},
	[750] = {
		WalkSpeed = 25,
		JumpPower = 90,
		LungeDamage = 148,
		SlashDamage = 89,
		BaseDamage = 25,
		MaxHealth = 2500,
		CurrentHealth = 2500,
		RegenRate = 50,
		Sound = "M750",
		Highlight = "H750",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura10",
		ColorEffect = {TintColor = Color3.fromRGB(162, 0, 255), Flash = true}
	},
	[1000] = {
		WalkSpeed = 100,
		JumpPower = 100,
		LungeDamage = 199,
		SlashDamage = 136,
		BaseDamage = 40,
		MaxHealth = 10000,
		CurrentHealth = 10000,
		RegenRate = 200,
		Sound = "M1K",
		Highlight = "H1k",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura11",
		ColorEffect = {TintColor = Color3.fromRGB(255,255,255), Flash = true}
	},
	[1750] = {
		WalkSpeed = 120,
		JumpPower = 110,
		LungeDamage = 250,
		SlashDamage = 180,
		BaseDamage = 60,
		MaxHealth = 15000,
		CurrentHealth = 15000,
		RegenRate = 500,
		Sound = "M1.75K",
		Highlight = "H1.75k",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura12",
		ColorEffect = {TintColor = Color3.fromRGB(255,128,0), Flash = true}
	},
	[2500] = {
		WalkSpeed = 150,
		JumpPower = 120,
		LungeDamage = 400,
		SlashDamage = 300,
		BaseDamage = 80,
		MaxHealth = 20000,
		CurrentHealth = 20000,
		RegenRate = 800,
		Sound = "M2.5K",
		Highlight = "H2.5k",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura13",
		ColorEffect = {TintColor = Color3.fromRGB(0,255,255), Flash = true}
	},
	[5000] = {
		WalkSpeed = 200,
		JumpPower = 140,
		LungeDamage = 999,
		SlashDamage = 666,
		BaseDamage = 150,
		MaxHealth = 50000,
		CurrentHealth = 50000,
		RegenRate = 2000,
		Sound = "M5K",
		Highlight = "H5K",
		AuraFolder = "KillstreakAuras",
		AuraPart = "Aura14",
		ColorEffect = {TintColor = Color3.fromRGB(255,0,255), Flash = true}
	}
}

local CurrentPhaseInstances = {} -- track spawned effects: AuraPart, Highlight, Sound

if not Tool:GetAttribute("CurrentPhaseThreshold") then
	Tool:SetAttribute("CurrentPhaseThreshold", 0)
end

function Kill(amount, isAdmin) -- The kill function is what handels EVERYTHING, changing anything without knowing what your doing could be dangerous
	amount = amount or 1  -- default to 1 if no amount provided
	local Plr = Players:GetPlayerFromCharacter(Tool.Parent)
	if not Plr or not Plr.Character then return end

	local Hum = Plr.Character:FindFirstChildOfClass("Humanoid")
	local Root = Plr.Character:FindFirstChild("HumanoidRootPart") or Plr.Character:FindFirstChild("Torso") or Plr.Character:FindFirstChild("UpperTorso")
	if not Hum or not Root then return end

	-- Play basic kill sound once for feedback
	if Handle.Kill then
		Handle.Kill:Play()
	end

	-- determine killValue (your existing logic)
	amount = amount or 1
	isAdmin = isAdmin or false

	local totalKillValue

	if isAdmin then
		-- Admin kills are exact and clean
		totalKillValue = amount
	else
		-- Combat kills respect NPC KillValue
		local killValue = 1
		if _G.LastTaggedHumanoid and _G.LastTaggedHumanoid.Parent then
			killValue = GetKillValueFromHumanoid(_G.LastTaggedHumanoid)
		end
		totalKillValue = killValue * amount
	end

	-- award kills and update UI
	Kills += totalKillValue
	CounterPlace.TextLabel.Text = tostring(Kills)

	-- Default per-kill damage progression (apply once per total kills)
	if not isAdmin then
		DamageValues.BaseDamage += 1 * amount
		DamageValues.SlashDamage += 2.5 * amount
		DamageValues.LungeDamage += 5 * amount
	end

	-- ===== Phase logic remains mostly the same =====
	local function GetClosestPhaseKey(killCount)
		local bestKey = nil
		local bestValue = -math.huge
		for k, _ in pairs(KillPhases) do
			if type(k) == "number" and k <= killCount and k > bestValue then
				bestValue = k
				bestKey = k
			end
		end
		if bestKey then
			return bestKey, KillPhases[bestKey]
		end
		return nil, nil
	end

	local phaseKey, phase = GetClosestPhaseKey(Kills)
	if not phaseKey or not phase then return end

	local currentActiveKey = Tool:GetAttribute("CurrentPhaseThreshold") or 0
	if phaseKey == currentActiveKey then return end

	Tool:SetAttribute("CurrentPhaseThreshold", phaseKey)

	-- Clean up previous instances on phase change
	for _, v in pairs(CurrentPhaseInstances) do
		if typeof(v) == "Instance" then
			pcall(function() v:Destroy() end)
		elseif typeof(v) == "table" then
			for _, sub in pairs(v) do
				if typeof(sub) == "Instance" then
					pcall(function() sub:Destroy() end)
				end
			end
		end
	end
	CurrentPhaseInstances = {}
	
	-- Play phase sound (if the phase defined one)
	if phase.Sound and Tool.Handle:FindFirstChild(phase.Sound) then
		local soundClone = Tool.Handle[phase.Sound]:Clone()
		soundClone.Parent = Root or Tool.Handle
		soundClone:Play()
		CurrentPhaseInstances.Sound = soundClone
	end

	-- Apply stat changes ON PHASE CHANGE (these override progression)
	if phase.WalkSpeed then Hum.WalkSpeed = phase.WalkSpeed end
	if phase.JumpPower then Hum.JumpPower = phase.JumpPower end
	if phase.MaxHealth then
		-- Be careful changing MaxHealth while Health > MaxHealth — clamp safely
		Hum.MaxHealth = phase.MaxHealth
		if Hum.Health > Hum.MaxHealth then
			Hum.Health = Hum.MaxHealth
		end
	end
	if phase.CurrentHealth then Hum.Health = math.min(phase.CurrentHealth, Hum.MaxHealth) end

	-- Phase damage overrides (if present) — only on change so they don't get re-set each kill
	if phase.BaseDamage then DamageValues.BaseDamage = phase.BaseDamage end
	if phase.SlashDamage then DamageValues.SlashDamage = phase.SlashDamage end
	if phase.LungeDamage then DamageValues.LungeDamage = phase.LungeDamage end

	-- Regeneration (destroy previous regen marker then spawn new loop)
	if phase.RegenRate then
		if Hum:FindFirstChild("KillPhaseRegen") then
			Hum.KillPhaseRegen:Destroy()
		end
		local regenMarker = Instance.new("BoolValue")
		regenMarker.Name = "KillPhaseRegen"
		regenMarker.Parent = Hum
		task.spawn(function()
			while Hum.Parent and regenMarker.Parent do
				if Hum.Health < Hum.MaxHealth then
					Hum.Health = math.min(Hum.Health + phase.RegenRate * 0.25, Hum.MaxHealth)
				end
				task.wait(0.25)
			end
		end)
		CurrentPhaseInstances.RegenMarker = regenMarker
	end

	-- Spawn aura (supports BasePart, ParticleEmitter, Attachment, or Folder)
	if phase.AuraFolder and phase.AuraPart then
		local storage = game:GetService("ServerStorage")
		local streak = storage:FindFirstChild("StreakAuras")
		local folder = streak and streak:FindFirstChild(phase.AuraFolder)
		local template = folder and folder:FindFirstChild(phase.AuraPart)

		if template then
			-- Case 1: BasePart
			if template:IsA("BasePart") then
				local aura = template:Clone()
				aura.Transparency = 1
				aura.Anchored = false
				aura.CanCollide = false
				aura.CanTouch = false
				aura.CanQuery = false
				aura.Parent = Plr.Character
				-- align CFrame relative to root
				pcall(function()
					aura.CFrame = Root.CFrame * (template.CFrame - template.Position)
				end)

				local weld = Instance.new("WeldConstraint")
				weld.Part0 = aura
				weld.Part1 = Root
				weld.Parent = aura

				CurrentPhaseInstances.Aura = {aura}

				-- Case 2: ParticleEmitter
			elseif template:IsA("ParticleEmitter") then
				local attach = Instance.new("Attachment")
				attach.Name = "AuraAttach_"..Kills
				attach.Parent = Root
				local emitter = template:Clone()
				emitter.Enabled = true
				emitter.Parent = attach
				CurrentPhaseInstances.Aura = {attach, emitter}

				-- Case 3: Attachment
			elseif template:IsA("Attachment") then
				local attach = template:Clone()
				attach.Name = "AuraAttach_"..Kills
				attach.Parent = Root
				for _, obj in ipairs(attach:GetChildren()) do
					if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
						obj.Enabled = true
					end
				end
				CurrentPhaseInstances.Aura = {attach}

				-- Case 4: Folder
			elseif template:IsA("Folder") then
				CurrentPhaseInstances.Aura = {}
				local orbitParts = {} -- << define ONCE here, top of the Folder case

				for _, obj in ipairs(template:GetChildren()) do
					if obj:IsA("BasePart") then
						local partClone = obj:Clone()
						partClone.Transparency = 1
						partClone.Anchored = true
						partClone.CanCollide = false
						partClone.CanTouch = false
						partClone.CanQuery = false
						partClone.Parent = workspace
						table.insert(CurrentPhaseInstances.Aura, partClone)
						table.insert(orbitParts, partClone) -- track for Extra
					elseif obj:IsA("Attachment") or obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
						local attach = Instance.new("Attachment")
						attach.Name = obj.Name.."_Aura_"..Kills
						attach.Parent = Root
						local clone = obj:Clone()
						clone.Parent = attach
						if clone:IsA("ParticleEmitter") then clone.Enabled = true end
						table.insert(CurrentPhaseInstances.Aura, attach)
					end
				end

				-- Run Extra with orbitParts (safe)
				if phase.Extra and #orbitParts > 0 then
					phase.Extra(Plr, orbitParts)
				end
			end
		end
	end

	-- Highlight
	if phase.Highlight and Tool:FindFirstChild(phase.Highlight) then
		local highlightClone = Tool[phase.Highlight]:Clone()
		highlightClone.Parent = Plr.Character
		highlightClone.Adornee = Plr.Character
		highlightClone.Enabled = true
		CurrentPhaseInstances.Highlight = highlightClone
	end

	-- Color effects (only on phase change)
	if phase.ColorEffect then
		local color = Instance.new("ColorCorrectionEffect")
		color.Parent = game.Lighting
		color.TintColor = phase.ColorEffect.TintColor or Color3.new(1,1,1)
		if phase.ColorEffect.Flash then
			for i = 0, 0.2, 0.025 do
				color.Brightness = i
				task.wait(0.075)
			end
			task.wait(phase.ColorEffect.Delay or 0)
		end
		if phase.ColorEffect.Blur then
			local blur = Instance.new("BlurEffect")
			blur.Parent = game.Lighting
			blur.Size = phase.ColorEffect.Blur
			task.wait(2)
			for i = phase.ColorEffect.Blur, 0, -0.5 do
				blur.Size = i
				task.wait(0.04)
			end
			blur:Destroy()
		end
		color:Destroy()
	end

	-- Extra per-phase logic
	if phase.Extra then
		pcall(function() phase.Extra(Plr) end)
	end

	-- Award badge if defined (only attempt on phase change)
	if phase.BadgeId then
		local BadgeService = game:GetService("BadgeService")
		pcall(function()
			if not BadgeService:UserHasBadgeAsync(Plr.UserId, phase.BadgeId) then
				BadgeService:AwardBadge(Plr.UserId, phase.BadgeId)
			end
		end)
	end

	Hum.Died:Connect(function()
		Tool:SetAttribute("CurrentPhaseThreshold", 0)
		for _, v in pairs(CurrentPhaseInstances) do
			pcall(function()
				if typeof(v) == "Instance" then v:Destroy() end
			end)
		end
		CurrentPhaseInstances = {}
	end)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid

	-- Save this humanoid globally for kill value lookup
	_G.LastTaggedHumanoid = humanoid

	humanoid.Died:Connect(function()
		if Creator_Tag.Parent == humanoid then
			Kill()
		end
	end)
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)	
end


function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()

	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Instance.new("StringValue")
			Anim.Name = "toolanim"
			Anim.Value = "Slash"
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Slash")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end	
end

function Lunge()
	Damage = DamageValues.LungeDamage

	Sounds.Lunge:Play()
	
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			local Anim = Instance.new("StringValue")
			Anim.Name = "toolanim"
			Anim.Value = "Lunge"
			Anim.Parent = Tool
		elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
			local Anim = Tool:FindFirstChild("R15Lunge")
			if Anim then
				local Track = Humanoid:LoadAnimation(Anim)
				Track:Play(0)
			end
		end
	end	
	--[[
	if CheckIfAlive() then
		local Force = Instance.new("BodyVelocity")
		Force.velocity = Vector3.new(0, 10, 0) 
		Force.maxForce = Vector3.new(0, 4000, 0)
		Debris:AddItem(Force, 0.4)
		Force.Parent = Torso
	end
	]]
	
	wait(0.2)
	Tool.Grip = Grips.Out
	wait(0.6)
	Tool.Grip = Grips.Up

	Damage = DamageValues.SlashDamage
end

Tool.Enabled = true
LastAttack = 0

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack < 0.2) then
		Lunge()
	else
		Attack()
	end
	LastAttack = Tick
	--wait(0.5)
	Damage = DamageValues.BaseDamage
	local SlashAnim = (Tool:FindFirstChild("R15Slash") or Create("Animation"){
		Name = "R15Slash",
		AnimationId = BaseUrl .. Animations.R15Slash,
		Parent = Tool
	})
	
	local LungeAnim = (Tool:FindFirstChild("R15Lunge") or Create("Animation"){
		Name = "R15Lunge",
		AnimationId = BaseUrl .. Animations.R15Lunge,
		Parent = Tool
	})
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Sounds.Unsheath:Play()
	if confirm == false then
		CounterPlace.Parent = Player.Character.Head
		confirm = true
	end
	
	if Hum then
		-- Prevent multiple .Died connections per equip
		if not Hum:FindFirstChild("KillPhaseDiedConnection") then
			local diedFlag = Instance.new("BoolValue")
			diedFlag.Name = "KillPhaseDiedConnection"
			diedFlag.Parent = Hum

			Hum.Died:Connect(function()
				-- Reset phase progress and cleanup visuals
				Tool:SetAttribute("CurrentPhaseThreshold", 0)

				for _, v in pairs(CurrentPhaseInstances) do
					pcall(function()
						if typeof(v) == "Instance" then
							v:Destroy()
						elseif typeof(v) == "table" then
							for _, sub in pairs(v) do
								if typeof(sub) == "Instance" then
									sub:Destroy()
								end
							end
						end
					end)
				end

				CurrentPhaseInstances = {}
			end)
		end
	end
end

function Unequipped()
	Tool.Grip = Grips.Up
	ToolEquipped = false
end

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

Connection = Handle.Touched:Connect(Blow)

-- Allow external scripts (like admin buttons) to safely trigger Kill()
local remote = Tool:FindFirstChild("Kill") or Instance.new("BindableFunction")
remote.Name = "Kill"
remote.Parent = Tool

-- Updated to accept amount
remote.OnInvoke = function(amount, isAdmin)
	Kill(amount, isAdmin)
end