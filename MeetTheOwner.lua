-- Basic Meet The Owner badge, but allowing multiple UserIDs incase the game has multiple owners (or owner alt accounts)

local ownersIds = {3972688973, 5146822757} -- add all owner/alt account IDs here
local badgeId = 3925121998198832

local BadgeService = game:GetService("BadgeService")

game.Players.PlayerAdded:Connect(function(plr)
	for _, id in ipairs(ownersIds) do
		if plr.UserId == id then
			-- Award badge to all players currently in the game
			for _, player in pairs(game.Players:GetPlayers()) do
				pcall(function()
					BadgeService:AwardBadge(player.UserId, badgeId)
				end)
			end
			break -- stop looping once a match is found
		end
	end
end)
