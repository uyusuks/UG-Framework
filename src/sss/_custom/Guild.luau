local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")

local pkgs = rs:WaitForChild("Packages")
local s_pkgs = sss:WaitForChild("ServerPackages")

local netray = require(pkgs:WaitForChild("netray"))
local chat_e = netray:RegisterEvent("chat_action")

local p_store = require(s_pkgs:WaitForChild("profilestore"))

local guild_store = p_store.New("guild", {

	name = "",
	experience = 0,
	capacity = 0
})

local guilds = {}

local guild = {}

guild._create = function(p, req_name)

	local uid = p.UserId

	local guild = guild_store:StartSessionAsync("guild_" .. uid)
	local guild_profile = guild.Data
	
	guilds[uid] = guild_profile
	
	guild_profile["name"] = req_name
	
	guild_profile["experience"] = 0
	guild_profile["capacity"] = 0
end

guild._load = function(p)

	local uid = p.UserId

	local guild = guild_store:StartSessionAsync("guild_" .. uid)
	local guild_profile = guild.Data

	guilds[uid] = guild_profile
end

guild._end = function(p)

	local uid = p.UserId

	local guild_profile = guilds[uid]

	guild_profile:EndSession()
end

guild._get = function(p, req)

	local uid = p.UserId

	local guild = guild_store:StartSessionAsync("guild_" .. uid)
	local guild_profile = guild.Data

	return guild_profile[req]
end

guild._set = function(p, req, rep_req)

	local uid = p.UserId

	local guild = guild_store:StartSessionAsync("guild_" .. uid)
	local guild_profile = guild.Data

	guild_profile[req] = rep_req
end

guild._listcommands = function(p)
	
	chat_e:FireClient(p, {_req = "g_cmdlist"})
end

guild._invite = function(reciever, g_name, _type)

	if _type ~= "fresh" then chat_e:FireClient(reciever, {_req = "g_invexp"}) return end
	
	chat_e:FireClient(reciever, {g_name = g_name, _req = "g_inv"})
end

guild._accept = function(p, rep_req)

	--chat_e:FireClient(p, {_req = "guild_accept", g_name = @})
	
	return
end

guild._leave = function(p, rep_req)

	return
end

guild._kick = function(p, rep_req)

	return
end

return guild