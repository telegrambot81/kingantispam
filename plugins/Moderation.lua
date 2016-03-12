do

local function check_member(cb_extra, success, result)
   local receiver = cb_extra.receiver
   local data = cb_extra.data
   local msg = cb_extra.msg
   for k,v in pairs(result.members) do
      local member_id = v.id
      if member_id ~= our_id then
          local username = v.username
          data[tostring(msg.to.id)] = {
              moderators = {[tostring(member_id)] = username},
              settings = {
                  set_name = string.gsub(msg.to.print_name, '_', ' '),
                  lock_name = 'no',
                  lock_photo = 'no',
                  lock_member = 'no'
                  }
            }
          save_data(_config.moderation.data, data)
          return send_large_msg(receiver, 'You Are Seted For Moderation')
      end
    end
end

local function automodadd(msg)
    local data = load_data(_config.moderation.data)
  if msg.action.type == 'chat_created' then
      receiver = get_receiver(msg)
      chat_info(receiver, check_member,{receiver=receiver, data=data, msg = msg})
  else
      if data[tostring(msg.to.id)] then
        return 'Group Have Already Moderator List'
      end
      if msg.from.username then
          username = msg.from.username
      else
          username = msg.from.print_name
      end
      data[tostring(msg.to.id)] = {
          moderators ={[tostring(msg.from.id)] = username},
          settings = {
              set_name = string.gsub(msg.to.print_name, '_', ' '),
              lock_name = 'no',
              lock_photo = 'no',
              lock_member = 'no'
              }
          }
      save_data(_config.moderation.data, data)
      return 'Moderator List Added and @'..username..' Are Seted For Moderation'
   end
end

local function modadd(msg)
    if not is_admin(msg) then
        return "You Are Not Global Admin"
    end
    local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    return 'Group Have Already Moderator List'
  end
  data[tostring(msg.to.id)] = {
      moderators ={},
      settings = {
          set_name = string.gsub(msg.to.print_name, '_', ' '),
          lock_name = 'no',
          lock_photo = 'no',
          lock_member = 'no'
          }
      }
  save_data(_config.moderation.data, data)

  return 'Moderator List Added'
end

local function modrem(msg)
    if not is_admin(msg) then
        return "You Are Not Global Admin"
    end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
  if not data[tostring(msg.to.id)] then
    return 'Group Have Not Moderator List'
  end

  data[tostring(msg.to.id)] = nil
  save_data(_config.moderation.data, data)

  return 'Moderator List Removed'
end

local function promote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group Have Not Moderator List')
  end
  if data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is Already Moderator')
    end
    data[group]['moderators'][tostring(member_id)] = member_username
    save_data(_config.moderation.data, data)
    return send_large_msg(receiver, '@'..member_username..' Seted For Moderation')
end

local function demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
    local group = string.gsub(receiver, 'chat#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group Have Not Moderator List')
  end
  if not data[group]['moderators'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is Not Moderator')
  end
  data[group]['moderators'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, '@'..member_username..' Demoted')
end

local function admin_promote(receiver, member_username, member_id)  
  local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end

  if data['admins'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is Already Global Admin')
  end
  
  data['admins'][tostring(member_id)] = member_username
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver, '@'..member_username..' Seted in Global Admins List')
end

local function admin_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end

  if not data['admins'][tostring(member_id)] then
    return send_large_msg(receiver, member_username..' is Not Global Admin')
  end

  data['admins'][tostring(member_id)] = nil
  save_data(_config.moderation.data, data)

  return send_large_msg(receiver, member_username..' Demoted of Global Admins List')
end

local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'No @'..member..' in Group.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
        member_username = member
        member_id = v.id
        if mod_cmd == 'modset' then
            return promote(receiver, member_username, member_id)
        elseif mod_cmd == 'moddem' then
            return demote(receiver, member_username, member_id)
        elseif mod_cmd == 'adminset' then
            return admin_promote(receiver, member_username, member_id)
        elseif mod_cmd == 'admindem' then
            return admin_demote(receiver, member_username, member_id)
        end
      end
   end
   send_large_msg(receiver, text)
end

local function modlist(msg)
    local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
    return 'Group Have Not Moderator List'
  end
  if next(data[tostring(msg.to.id)]['moderators']) == nil then --fix way
    return 'Group Have Not Moderator'
  end
  local message = 'Moderators List For ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message .. '> @'..v..' (' ..k.. ') \n'
  end

  return message
end

local function admin_list(msg)
    local data = load_data(_config.moderation.data)
  if not data['admins'] then
    data['admins'] = {}
    save_data(_config.moderation.data, data)
  end
  if next(data['admins']) == nil then 
    return 'Global Admins List Not Available'
  end
  local message = 'Robot Global Admins List:\n'
  for k,v in pairs(data['admins']) do
    message = message .. '> @'.. v ..' ('..k..') \n'
  end
  return message
end

function run(msg, matches)
  if matches[1] == 'debug' then
    return debugs(msg)
  end
  if not is_chat_msg(msg) then
    return "Works in Group"
  end
  local mod_cmd = matches[1]
  local receiver = get_receiver(msg)
  if matches[1] == 'modadd' then
    return modadd(msg)
  end
  if matches[1] == 'modrem' then
    return modrem(msg)
  end
  if matches[1] == 'modset' and matches[2] then
    if not is_momod(msg) then
        return "You Are Not Moderator or Global Admin"
    end
  local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'moddem' and matches[2] then
    if not is_momod(msg) then
        return "You Are Not Moderator or Global Admin"
    end
    if string.gsub(matches[2], "@", "") == msg.from.username then
        return "Can Not Demote Yourself"
    end
  local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'modlist' then
    return modlist(msg)
  end
  if matches[1] == 'adminset' then
    if not is_admin(msg) then
        return "You Are Not Sudo or Global Admin"
    end
  local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'admindem' then
    if not is_admin(msg) then
        return "You Are Not Sudo or Global Admin"
    end
    local member = string.gsub(matches[2], "@", "")
    chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
  end
  if matches[1] == 'adminlist' then
    if not is_admin(msg) then
        return 'You Are Not Sudo or Global Admin'
    end
    return admin_list(msg)
  end
  if matches[1] == 'chat_add_user' and msg.action.user.id == our_id then
    return automodadd(msg)
  end
  if matches[1] == 'chat_created' and msg.from.id == 0 then
    return automodadd(msg)
  end
end

return {
  description = "Global Admin and Moderation Options", 
  usage = {
      moderator = {
          "!modset <@User> : Set Moderator",
          "!moddem <@user> : Demote Moderator",
          "!modlist : Moderators List",
          },
      admin = {
          "!modadd : Add Moderator List",
          "!modrem : Remove Moderator List",
          },
      sudo = {
          "!adminset <@User> : Set Global Admin",
          "!admindem <@User> : Demote Global Admin",
		  "!adminlist : Global Admins List",
          },
      },
  patterns = {
    "^!(modset) (.*)$",
    "^!(moddem) (.*)$",
    "^!(modlist)$",
    "^!(modadd)$",
    "^!(modrem)$",
    "^!(adminset) (.*)$",
    "^!(admindem) (.*)$",
    "^!(adminlist)$",
    "^!!tgservice (chat_add_user)$",
    "^!!tgservice (chat_created)$",
  }, 
  run = run,
}

end
