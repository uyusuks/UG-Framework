local sss = game:GetService("ServerScriptService")
local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

local pkgs = rs:WaitForChild("Packages")
local _module = sss:WaitForChild("_module")

local profile = require(_module:WaitForChild("Profile"))
local guild = require(_module:WaitForChild("Guild"))

local netray = require(pkgs:WaitForChild("netray"))

local guild_e = netray:RegisterEvent("guild_action")

local handled_ids = {}

local await_req = {}

local prefix = "/"

guild_e:OnEvent(function(p, data)

	local _id = data._id

	if handled_ids[_id] then return end

	handled_ids[_id] = true

	local _req = data._req
	local _cmd = data._cmd
	
	if _cmd == prefix .. "gcmds" or _cmd == prefix .. "gcommands" then

		guild._listcommands(p)

	elseif _cmd == prefix .. "crg" then

		local g_name = _req

		guild._create(p, g_name)

		profile._set(p, "grank", 2)
		profile._set(p, "guild", g_name)

	elseif _cmd == prefix .. "invite" then

		if profile._get(p, "guild") == "" then return end

		local g_name = profile._get(p, "guild")
		
		if not ps:FindFirstChild(_req) then return end
		
		local reciever = ps:FindFirstChild(_req)
		
		local rid = reciever.UserId

		guild._invite(reciever, g_name, "fresh")

		await_req["cd_" .. rid] = true
		await_req["guild_" .. rid] = g_name

		task.delay(30, function()

			await_req["cd_" .. rid] = nil
			await_req["guild_" .. rid] = nil
			
			guild._invite(reciever, "expired")
		end)

	elseif _cmd == prefix .. "accept" then
		
		local reciever = p
		local rid = reciever.UserId
		
		if not await_req["cd_" .. rid] then return end

		local req_guild = await_req["guild_" .. rid]

		guild._accept(reciever, req_guild)
	end

	task.delay(10, function()

		handled_ids[_id] = nil
	end)
end)