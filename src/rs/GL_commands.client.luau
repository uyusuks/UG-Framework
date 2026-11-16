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
    prefix .. "leave"
}

tcs.SendingMessage:Connect(function(input)

    if not input:IsA("Instance") then return end
	
	local _id = input.MessageId
    local input = input.Text:lower()

	for _, cmd in cmds do
		
        if input == cmd then

			guild_e:FireServer({input = input, _id = _id})
        end
    end
end)

chat_e:OnEvent(function(data)

	local _req = data._req

    local _op

    if _req == "gcmdslist" then
        
		_op =
			
			"\n" ..
			"\n" ..
			"<font color='#FF3B30' size='20'><b><i>&lt;Commands&gt;</i></b></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/gcmds & /gcommands</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/invite</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/accept</b></i></font>\n" ..
			"<font color='#E0E0E0' size='18'><i><b>/decline</b></i></font>\n"
    end

    gch:DisplaySystemMessage(_op)
end)