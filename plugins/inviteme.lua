do

local function parsed_url(link)
local parsed_link=URL.parse(link)
local parsed_path=
URL.parse_path(parse_link_path)
return parsed_path[2]
end

function run(msg,matches)
local hash=parsed_url(matches[1])
join=import_chat_link(hash,ok_cd,false)
end

return{
doscription="Invite me info agroup chat",usage="!inviteme[invite link]",
patterns={
"^!inviteme(.*)$"
},
run=run
}
end
