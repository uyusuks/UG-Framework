--!nonstrict

local sss = game:GetService("ServerScriptService")

local s_pkgs = sss:WaitForChild("ServerPackages")
local p_store = require(s_pkgs:WaitForChild("profilestore"))

local p_store = p_store.New("profile", {

	rank = 0,
	experience = 0,
	balance = 0,

	guild = "",
	guild_rank = 0
})

local profiles = {}

local profile = {}

profile._load = function(p)

	local uid = p.UserId

	local profile = p_store:StartSessionAsync("profile_" .. uid)

	profiles[uid] = profile
end

profile._end = function(p)

	local uid = p.UserId

	local profile = profiles[uid]

	profile:EndSession()
end

profile._get = function(p, req)

	local uid = p.UserId

	local profile = profiles[uid].Data

	return profile[req]
end

profile._set = function(p, req, rep_req)

	local uid = p.UserId

	local profile = profiles[uid].Data

	profile[req] = rep_req
end

return profile