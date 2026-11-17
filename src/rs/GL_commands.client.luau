--!nonstrict

local tcs = game:GetService("TextChatService")
local rs = game:GetService("ReplicatedStorage")

local tch = tcs:WaitForChild("TextChannels")
local gch = tch:WaitForChild("RBXGeneral")

local pkgs = rs:WaitForChild("Packages")

local netray = require(pkgs:WaitForChild("netray"))

local guild_e = netray:GetEvent("guild_action")
local chat_e = netray:GetEvent("chat_action")

local prefix = "/"

local cmds = {

    prefix .. "gcmds",
    prefix .. "gcommands",

    prefix .. "crg",

    prefix .. "invite",

    prefix .. "accept",
    prefix .. "refuse"
}

tcs.SendingMessage:Connect(function(input)

    if not input:IsA("Instance") then return end
	
	local _id = input.MessageId
    local input = input.Text
	
	local _cmd, _req = input:match("^(/%S+)%s*(.*)")

	for _, cmd in cmds do

		if _cmd:lower() == cmd then

			guild_e:FireServer({_cmd = _cmd:lower(), _req = _req, _id = _id})
        end
    end
end)


--@will prob move chat related events to the different env later,

chat_e:OnEvent(function(data)

	local _req = data._req

	local _op
	
	local g_name
	
	if data.g_name then g_name = data.g_name end

	if _req == "g_cmdlist" then
        
		_op =
			
			"\n" ..
			"\n" ..
			"<font color='#FF3B30' size='20'><b><i>&lt;Commands&gt;</i></b></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/gcmds & /gcommands</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/invite</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/accept</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/decline</b></i></font>"
		
	elseif _req == "g_inv" then

		_op =

			"<font color='#90EE90' size='18'><b><i>You got an invite from guild named, <font color='#FFFFFF'>" .. g_name:upper() .. "</font>.</i></b></font>\n" ..
			"<font color='#E0E0E0' size='15'><i>&lt;got 30 secs of time to decide&gt;</i></font>"
		
	elseif _req == "g_invexp" then

		_op =

			"<font color='#E0E0E0' size='15'><i>&lt;the guild invitation expired&gt;</i></font>"
		
	elseif _req == "g_ref" then
		
		_op =

			"<font color='#E0E0E0' size='15'><i>&lt;you did refuse invitation from, " .. g_name:upper() .. "&gt;</i></font>"
		
	elseif _req == "g_apt" then

		_op =

			"<font color='#E0E0E0' size='15'><i>&lt;you did accept invitation from, " .. g_name:upper() .. "&gt;</i></font>"
    end

    gch:DisplaySystemMessage(_op)
end)