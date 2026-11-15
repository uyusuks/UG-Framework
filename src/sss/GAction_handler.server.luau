local sss = game:GetService("ServerScriptService")
local ss = game:GetService("ServerStorage")
local rs = game:GetService("ReplicatedStorage")
local ps = game:GetService("Players")

local shared_module = rs:WaitForChild("_module")
local server_module = sss:WaitForChild("_module")

local profile = require(server_module:WaitForChild("profile"))
local guild = require(server_module:WaitForChild("guild"))

local netray = require(shared_module:WaitForChild("netray"))
local guild_re = netray:RegisterEvent("guild")

local is_gl = function(p)

	local grank = profile._get(p, "grank")

	if grank == 2 then return true end
end

local handled_ids = {}

local await_req = {}

local prefix = "/"

guild_re:OnEvent(function(p, data)

	local input_id = data.input_id

	if handled_ids[input_id] then return end

	handled_ids[input_id] = true

	local input = data.input

	local _, req = input:match("(%S+)%s*(.*)")

	local uid = p.UserId

	if string.find(input, prefix .. "gcmds") or string.find(input, prefix .. "gcommands") then

		guild_re:FireClient(p, {req = "gcmdslist"})

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

		-- elseif string.find(input, prefix .. "gstats") then

		-- 	local checker = p

		-- 	local checker_ign = checker:WaitForChild("ign")
		-- 	local guild_name = checker_ign:WaitForChild("guild").Value

		-- 	local stat = guild.stat_check(guild_name)

		-- 	guild_re:FireClient(checker, {req = "stat_check", stats = stat})
	end

	task.delay(10, function()

		handled_ids[input_id] = nil
	end)
end)