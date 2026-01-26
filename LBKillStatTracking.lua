-- Leaderboard Stat Tracker by Zamiko - This script tracks leaderboard stats and updates them accordingly, and saves apon leaving.

local DataStoreService = game:GetService("DataStoreService")
local killsDataStore = DataStoreService:GetDataStore("KillsDataStore")

-- Function to handle when a player joins
game.Players.PlayerAdded:Connect(function(player)
	-- Check if leaderstats folder exists; if not, create it
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	-- Check if the LBKills stat exists; if not, create it
	local kills = leaderstats:FindFirstChild("LBKills")
	if not kills then
		kills = Instance.new("IntValue")
		kills.Name = "LBKills" -- Shortened name for the leaderboard
		kills.Parent = leaderstats
	end

	-- Try to load the saved kills value
	local success, savedKills = pcall(function()
		return killsDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and savedKills then
		kills.Value = savedKills -- Set to saved value
	else
		kills.Value = 0 -- Default to 0 if no saved data
	end

	print("Player joined: " .. player.Name .. ", Kills loaded: " .. kills.Value)
end)

-- Function to handle when a player leaves
game.Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local kills = leaderstats and leaderstats:FindFirstChild("LBKills")

	if kills then
		-- Save the kills value to the DataStore
		local success, errorMessage = pcall(function()
			killsDataStore:SetAsync(tostring(player.UserId), kills.Value)
		end)

		if success then
			print("Kills saved for " .. player.Name .. ": " .. kills.Value)
		else
			warn("Failed to save kills for " .. player.Name .. ": " .. errorMessage)
		end
	end

end)
