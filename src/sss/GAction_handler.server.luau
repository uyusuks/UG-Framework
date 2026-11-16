local sss = game:GetService("ServerScriptService")
local ss = game:GetService("ServerStorage")
local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

local pkgs = rs:WaitForChild("Packages")
local _module = sss:WaitForChild("_module")

local profile = require(_module:WaitForChild("Profile"))
local guild = require(_module:WaitForChild("Guild"))

local netray = require(pkgs:WaitForChild("netray"))

local guild_e = netray:RegisterEvent("guild_action")
local chat_e = netray:RegisterEvent("chat_action")

local is_gl = function(p)

	local grank = profile._get(p, "grank")

	if grank == 2 then return true end
end

local handled_ids = {}

local await_req = {}

local prefix = "/"

guild_e:OnEvent(function(p, data)

	local _id = data._id

	if handled_ids[_id] then return end

	handled_ids[_id] = true

	local input = data.input

	local _, req = input:match("(%S+)%s*(.*)")

	if string.find(input, prefix .. "gcmds") or string.find(input, prefix .. "gcommands") then

		chat_e:FireClient(p, {_req = "gcmdslist"})

	elseif string.find(input, prefix .. "crg") then

		guild._create(p, req)

		profile._set(p, "grank", 2)
		profile._set(p, "guild", req)

		local _guild = ss:WaitForChild("_guild")
		local _grank = _guild:WaitForChild("_grank")

		local l_gl = _grank:WaitForChild("grank_2"):Clone()

		local ch = p.Character or p.CharacterAdded:Wait()

		l_gl.Parent = ch

	elseif string.find(input, prefix .. "inv") then

		if profile._get(p, "guild") == "" or not is_gl(p) then return end

		local req_guild = profile._get(p, "guild")
		local req = ps:FindFirstChild(req)

		guild._invite(req)

		await_req["cd_" .. req.UserId] = true
		await_req["guild_" .. req.UserId] = req_guild

		task.delay(30, function()

			await_req["cd_" .. req.UserId] = nil
			await_req["guild_" .. req.UserId] = nil
		end)

	elseif string.find(input, prefix .. "accept") then

		if not await_req["cd_" .. p.UserId] then return end

		local req_guild = await_req["guild_" .. p.UserId]

		guild._accept(p, req_guild)
	end

	task.delay(10, function()

		handled_ids[_id] = nil
	end)
end)