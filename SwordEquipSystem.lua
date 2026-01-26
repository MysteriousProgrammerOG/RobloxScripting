local function onSwordEquipRequest(player, standName)
	print("RemoteEvent fired! Player:", player.Name, "Stand:", standName)

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local swordStat = leaderstats:FindFirstChild("Sword")
	if not swordStat then return end

	local stand = game.Workspace.SwordStands:FindFirstChild(standName)
	if not stand then return end

	local successParticle = stand:FindFirstChild("SuccessParticle")
	local successSound = stand:FindFirstChild("SuccessSound")

	-- Update the Sword stat directly
	swordStat.Value = standName
	print("Sword stat updated to:", standName)

	-- Play success particle and sound
	if successParticle then
		successParticle.Enabled = true
		task.delay(2, function() successParticle.Enabled = false end)
	end

	if successSound then
		successSound:Play()
	end
end