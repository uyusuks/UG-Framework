--!nonstrict

local tcs = game:GetService("TextChatService")
local rs = game:GetService("ReplicatedStorage")

local module = rs:WaitForChild("module")

local netray = require(module:WaitForChild("netray"))
local chat_re = netray:GetEvent("chat")

local prefix = "/"

local commands = {

    prefix .. "request",
    prefix .. "leave",
    prefix .. "deposit",
    prefix .. "withdraw",
    prefix .. "kick",
    prefix .. "invite",
    prefix .. "logs",
    prefix .. "mbox",
    prefix .. "abandon",
    prefix .. "rename",
    prefix .. "settings"
}

tcs.SendingMessage:Connect(function(input)
    
    local input = input.Text

    if not string.find(input, prefix) then return end

    for _, cmd in pairs(commands) do
        
        if input:lower() == cmd then
            
            chat_re:FireServer({input = cmd:lower()})
        end
    end
end)