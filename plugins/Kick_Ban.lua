local function kick_user(user_id, chat_id)
  local chat = 'chat#id'..chat_id
  local user = 'user#id'..user_id
  chat_del_user(chat, user, ok_cb, true)
end

local function ban_user(user_id, chat_id)
  local hash =  'Banned '..chat_id..' ('..user_id..')'
  redis:set(hash, true)
  kick_user(user_id, chat_id)
end

local function superban_user(user_id, chat_id)
  local hash =  'Globally Banned '..chat_id..' ('..user_id..')'
  redis:set(hash, true)
  kick_user(user_id, chat_id)
end

local function is_banned(user_id, chat_id)
  local hash =  'Banned '..chat_id..' ('..user_id..')'
  local banned = redis:get(hash)
  return banned or false
end

local function is_super_banned(user_id)
    local hash =  'Globally Banned '..user_id
    local superbanned = redis:get(hash)
    return superbanned or false
end

local function pre_process(msg)
  if msg.action and msg.action.type then
    local action = msg.action.type
    if action == 'chat_add_user' or action == 'chat_add_user_link' then
      local user_id
      if msg.action.link_issuer then
          user_id = msg.from.id
      else
	      user_id = msg.action.user.id
      end
      print('Checking invited user '..user_id)
      local superbanned = is_super_banned(user_id)
      local banned = is_banned(user_id, msg.to.id)
      if superbanned or banned then
        print('User is banned!')
        kick_user(user_id, msg.to.id)
      end
    end
    return msg
  end

  if msg.to.type == 'chat' then
    local user_id = msg.from.id
    local chat_id = msg.to.id
    local superbanned = is_super_banned(user_id)
    local banned = is_banned(user_id, chat_id)
    if superbanned then
      print('SuperBanned user talking!')
      superban_user(user_id, chat_id)
      msg.text = 'User is Globally Banned'
    end
    if banned then
      print('Banned user talking!')
      ban_user(user_id, chat_id)
      msg.text = 'User is Banned'
    end
  end
  
  local issudo = is_sudo(msg)

local function username_id(cb_extra, success, result)
   local get_cmd = cb_extra.get_cmd
   local receiver = cb_extra.receiver
   local chat_id = cb_extra.chat_id
   local member = cb_extra.member
   local text = 'No User @'..member..' in Group'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
      	member_username = member
      	member_id = v.id
      	if get_cmd == 'kick' then
      	    return kick_user(member_id, chat_id)
      	elseif get_cmd == 'ban' then
      	    send_large_msg(receiver, 'User @'..member..' ('..member_id..') Banned')
      	    return ban_user(member_id, chat_id)
      	elseif get_cmd == 'globalban' then
      	    send_large_msg(receiver, 'User @'..member..' ('..member_id..') Globally Banned')
      	    return superban_user(member_id, chat_id)
      	end
      end
   end
   return send_large_msg(receiver, text)
end

local function run(msg, matches)
  if matches[1] == 'kickme' then
  	kick_user(msg.from.id, msg.to.id)
  end
  if not is_momod(msg) then
    return nil
  end
  local receiver = get_receiver(msg)
  if matches[4] then
      get_cmd = matches[1]..' '..matches[2]..' '..matches[3]
  elseif matches[3] then
      get_cmd = matches[1]..' '..matches[2]
  else
      get_cmd = matches[1]
  end

  if matches[1] == 'ban' then
    local user_id = matches[3]
    local chat_id = msg.to.id
    if msg.to.type == 'chat' then
      if matches[2] == '' then
        if string.match(matches[3], '^%d+$') then
            ban_user(user_id, chat_id)
            send_large_msg(receiver, 'User '..user_id..' Banned')
        else
            local member = string.gsub(matches[3], '@', '')
            chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=chat_id, member=member})
        end
      end
      if matches[2] == 'del' then
        local hash =  'Banned '..chat_id..' ('..user_id..')'
        redis:del(hash)
        return 'User '..user_id..' Unbanned'
      end
    else
      return 'This isn\'t a chat group'
    end
  end

  if matches[1] == 'globalban' and is_admin(msg) then
    local user_id = matches[3]
    local chat_id = msg.to.id
    if matches[2] == '' then
        if string.match(matches[3], '^%d+$') then
            superban_user(user_id, chat_id)
            send_large_msg(receiver, 'User '..user_id..' Globally Banned')
        else
            local member = string.gsub(matches[3], '@', '')
            chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=chat_id, member=member})
        end
    end
    if matches[2] == 'del' then
        local hash =  'Globally Banned '..user_id
        redis:del(hash)
        return 'User '..user_id..' Globally Unbanned'
    end
  end

  if matches[1] == 'kick' then
    if msg.to.type == 'chat' then
      if string.match(matches[2], '^%d+$') then
          kick_user(matches[2], msg.to.id)
      else
          local member = string.gsub(matches[2], '@', '')
          chat_info(receiver, username_id, {get_cmd=get_cmd, receiver=receiver, chat_id=msg.to.id, member=member})
      end
    else
      return 'This isn\'t a chat group'
    end
  end
end

return {
  description = "Kick and Ban Options", 
  usage = {
      user = "!kickme : Leave of Group",
      moderator = {
          "!kick <ID> : Kick of Group",
          "!kick <@User> : Kick of Group",
          "!ban <ID> : Kick of Group for Ever",
          "!ban <@User> : Kick of Group for Ever",
          "!ban del <ID> : UnBan User",
          },
      admin = {
          "!globalban <ID> : Kick of All Groups for Ever",
          "!globalban <@User> : Kick of All Groups for Ever",
          "!globalban del <ID> : Globally Unbanned",
          },
      },
  patterns = {
    "^!(kickme)$",
    "^!(kick) (.*)$",	
    "^!(ban) () (.*)$",
    "^!(ban) (del) (.*)$",
    "^!(globalban) () (.*)$",
    "^!(globalban) (del) (.*)$",
    "^!!tgservice (.+)$",
  }, 
  run = run,
  pre_process = pre_process
}
