--!nonstrict

local sss = game:GetService("ServerScriptService")
local ps = game:GetService("Players")

local _module = sss:WaitForChild("_module")
local profile = require(_module:WaitForChild("Profile"))

ps.PlayerAdded:Connect(function(p) profile._load(p) end)

ps.PlayerRemoving:Connect(function(p) profile._end(p) end)