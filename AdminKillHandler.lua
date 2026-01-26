-- This is an Admin Kill Handler, Built for my killstreak game, it allows the admin to give themselves as many kills as they wish, and this script handles it making sure nothign goes wrong.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local AdminList = require(script.Parent:WaitForChild("AdminList"))

-- Ensure RemoteEvent exists
local event = ReplicatedStorage:FindFirstChild("GiveAdminKillsEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "GiveAdminKillsEvent"
	event.Parent = ReplicatedStorage
end

-- Finds ANY tool with a Kill BindableFunction in backpack or character
local function FindKillTool(player)
	-- Check backpack
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Kill") and tool.Kill:IsA("BindableFunction") then
			return tool
		end
	end
	-- Check equipped tools
	local char = player.Character
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("Kill") and tool.Kill:IsA("BindableFunction") then
				return tool
			end
		end
	end
	return nil
end

-- Finds ANY tool with an AddKills RemoteEvent (gloves)
local function FindGloveTool(player)
	-- Check backpack
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("AddKills") and tool.AddKills:IsA("RemoteEvent") then
			return tool
		end
	end

	-- Check character
	local char = player.Character
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("AddKills") and tool.AddKills:IsA("RemoteEvent") then
				return tool
			end
		end
	end

	return nil
end

-- Safely give streak kills
local function GivePlayerStreakKills(player, amount)
	amount = amount or 1
	if amount <= 0 then return end

	local tool = FindKillTool(player)

	if tool then
		tool.Kill:Invoke(amount)
		return
	end

	-- If no tool found, temporarily clone KillstreakSword or Reaper
	local swordTemplate = ServerStorage:FindFirstChild("KillstreakSword") or ServerStorage:FindFirstChild("Reaper")
	if swordTemplate then
		local tempTool = swordTemplate:Clone()
		tempTool.Parent = player:FindFirstChildOfClass("Backpack") or player.Character
		if tempTool:FindFirstChild("Kill") and tempTool.Kill:IsA("BindableFunction") then
			tempTool.Kill:Invoke(amount)
		end
		tempTool:Destroy()
	end
end

-- Safely give glove streak kills
local function GivePlayerGloveKills(player, amount)
	amount = amount or 1
	if amount <= 0 then return end

	local glove = FindGloveTool(player)
	if glove then
		glove.AddKills:FireServer(amount)
	end
end

-- Give leaderboard kills
local function GivePlayerLBKills(player, amount)
	amount = amount or 1
	if amount <= 0 then return end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lbStat = leaderstats:FindFirstChild("LBKills")
		if lbStat and lbStat:IsA("IntValue") then
			lbStat.Value += amount
		end
	end
end

-- RemoteEvent handler
event.OnServerEvent:Connect(function(admin, killType, amount, targetName)
	-- Check admin
	if not (AdminList[admin.Name] or AdminList[admin.UserId]) then return end

	local target = targetName and Players:FindFirstChild(targetName) or admin
	if not target then return end
	amount = amount or 1

	if killType == "Streak" then
		GivePlayerStreakKills(target, amount)
	elseif killType == "GloveStreak" then
		GivePlayerGloveKills(target, amount)
	elseif killType == "LBKills" then
		GivePlayerLBKills(target, amount)
	end

end)
