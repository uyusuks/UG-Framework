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

local request = {}

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

		if profile._get(p, "guild") == "" or profile._get(p, "grank") < 2 then return end

		local g_name = profile._get(p, "guild")

		if not ps:FindFirstChild(_req) then return end

		local receiver = ps:FindFirstChild(_req)

		if profile._get(receiver, "guild") == _req then return end

		local rid = receiver.UserId

		if request[rid] then return end

		request[rid] = true

		guild._invite(receiver, g_name, "fresh")

		await_req["cd_" .. rid] = true
		await_req["guild_" .. rid] = g_name

		task.delay(30, function()

			if await_req["cd_" .. rid] == nil then return end

			await_req["cd_" .. rid] = nil
			await_req["guild_" .. rid] = nil

			guild._invite(receiver, "expired")

			request[rid] = nil
		end)

	elseif _cmd == prefix .. "accept" then

		local receiver = p
		local rid = receiver.UserId

		if not await_req["cd_" .. rid] then return end

		await_req["cd_" .. rid] = nil
		request[rid] = nil

		local g_name = await_req["guild_" .. rid]

		await_req["guild_" .. rid] = nil

		guild._accept(receiver, g_name)

	elseif _cmd == prefix .. "refuse" then

		local receiver = p
		local rid = receiver.UserId

		if not await_req["cd_" .. rid] then return end

		await_req["cd_" .. rid] = nil
		request[rid] = nil

		local g_name = await_req["guild_" .. rid]

		await_req["guild_" .. rid] = nil

		guild._refuse(receiver, g_name)

	elseif _cmd == prefix .. "gc" or _cmd == prefix .. "gchat" then

		local _msg = _req
		local g_name = profile._get(p, "guild")

		guild._chat(p, g_name, _msg)
	end

	task.delay(10, function()

		handled_ids[_id] = nil
	end)
end)