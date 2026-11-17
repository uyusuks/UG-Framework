local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

local pkgs = rs:WaitForChild("Packages")
local s_pkgs = sss:WaitForChild("ServerPackages")

local netray = require(pkgs:WaitForChild("netray"))
local chat_e = netray:RegisterEvent("chat_action")

local p_store = require(s_pkgs:WaitForChild("profilestore"))

local guild_store = p_store.New("guild", {

	name = "",
	experience = 0,
	capacity = 0,

	members = {}
})

local guilds = {}

local guild = {}

guild._create = function(p, g_name)

	local guild = guild_store:StartSessionAsync("guild_" .. g_name)
	local guild_profile = guild.Data

	guilds[g_name] = guild_profile

	guild_profile["name"] = g_name

	guild_profile["experience"] = 0
	guild_profile["capacity"] = 5

	table.insert(guild_profile["members"], p.Name)
end

guild._load = function(g_name)

	local guild = guild_store:StartSessionAsync("guild_" .. g_name)
	local guild_profile = guild.Data

	guilds[g_name] = guild_profile
end

guild._end = function(g_name)

	local guild_profile = guilds[g_name]

	guild_profile:EndSession()
end

--@access/replace properties inside of the guild

guild._get = function(g_name, req) return guilds[g_name][req] end

guild._set = function(g_name, _req, r_req) guilds[g_name][_req] = r_req end

--@guild basic-functions

guild._listcommands = function(p) chat_e:FireClient(p, {_req = "g_cmdlist"}) end

guild._accept = function(p, g_name) chat_e:FireClient(p, {_req = "g_apt", g_name = g_name}) end

guild._refuse = function(p, g_name) chat_e:FireClient(p, {_req = "g_ref", g_name = g_name}) end

guild._invite = function(reciever, g_name, _type)

	if _type ~= "fresh" then chat_e:FireClient(reciever, {_req = "g_invexp"}) return end

	chat_e:FireClient(reciever, {g_name = g_name, _req = "g_inv"})
end

guild._chat = function(_p, g_name, _msg)

	for _, member in guilds[g_name]["members"] do

		if not ps:FindFirstChild(member) then continue end

		local member = ps:FindFirstChild(member)

		chat_e:FireClient(member, {_p = _p, g_name = g_name, _msg = _msg,  _req = "g_c"})
	end
end

return guild