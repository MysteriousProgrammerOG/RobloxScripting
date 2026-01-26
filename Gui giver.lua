local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminList = require(script.Parent:WaitForChild("AdminList"))

Players.PlayerAdded:Connect(function(player)
	-- Check if user is admin
	if AdminList[player.Name] or AdminList[player.UserId] then
		-- Give GUI safely
		local gui = ReplicatedStorage:WaitForChild("AdminGUI"):Clone()
		gui.Parent = player:WaitForChild("PlayerGui")
		gui.ResetOnSpawn = false
	end
end)