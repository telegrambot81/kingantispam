--moderation.json
do

local function create_group(msg)
    if not is_admin(msg) then
        return "You Are Not Global Admin"
    end
    local group_creator = msg.from.print_name
    create_group_chat (group_creator, group_name, ok_cb, false)
	return 'Group '..string.gsub(group_name, '_', ' ')..' Created, Check Your Messages'
end

local function set_description(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local data_cat = 'description'
	data[tostring(msg.to.id)][data_cat] = deskripsi
	save_data(_config.moderation.data, data)
	return 'This Message Seted For About:\n'..deskripsi
end

local function get_description(msg, data)
    local data_cat = 'description'
    if not data[tostring(msg.to.id)][data_cat] then
		return 'Group Have Not About'
	end
    local about = data[tostring(msg.to.id)][data_cat]
    return about
end

local function set_rules(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local data_cat = 'rules'
	data[tostring(msg.to.id)][data_cat] = rules
	save_data(_config.moderation.data, data)
	return 'This Message Seted For Rules:\n'..rules
end

local function get_rules(msg, data)
    local data_cat = 'rules'
    if not data[tostring(msg.to.id)][data_cat] then
		return 'Group Have Not Rules'
	end
    local rules = data[tostring(msg.to.id)][data_cat]
    return rules
end

local function lock_group_name(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
    local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'yes' then
	    return 'Group Name is Already Locked'
	else
	    data[tostring(msg.to.id)]['settings']['lock_name'] = 'yes'
	    save_data(_config.moderation.data, data)
	    data[tostring(msg.to.id)]['settings']['set_name'] = string.gsub(msg.to.print_name, '_', ' ')
	    save_data(_config.moderation.data, data)
	return 'Group Name Locked'
	end
end

local function unlock_group_name(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
    local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'no' then
	    return 'Group Name is Not Locked'
	else
	    data[tostring(msg.to.id)]['settings']['lock_name'] = 'no'
	    save_data(_config.moderation.data, data)
	return 'Group Name Unlocked'
	end
end

local function lock_group_member(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'yes' then
	    return 'Group Members Are Already Locked'
	else
	    data[tostring(msg.to.id)]['settings']['lock_member'] = 'yes'
	    save_data(_config.moderation.data, data)
	end
	return 'Group Members Locked'
end

local function unlock_group_member(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'no' then
	    return 'Group Members Are Not Locked'
	else
	    data[tostring(msg.to.id)]['settings']['lock_member'] = 'no'
	    save_data(_config.moderation.data, data)
	return 'Group Members Unlocked'
	end
end

local function lock_group_photo(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'yes' then
	    return 'Group Photo is Already Locked'
	else
	    data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	    save_data(_config.moderation.data, data)
	end
	return 'Send Group Photo Now'
end

local function unlock_group_photo(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'no' then
	    return 'Group Photo is Not Locked'
	else
	    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'no'
	    save_data(_config.moderation.data, data)
	return 'Group Photo Unlocked'
	end
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    chat_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Group Photo Lock and Seted', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed Please try Again', ok_cb, false)
  end
end

local function show_group_settings(msg, data)
    if not is_momod(msg) then
        return "You Are Not Moderator"
    end
    local settings = data[tostring(msg.to.id)]['settings']
    local text = "Group Settings:\n\nLock Group Name : "..settings.lock_name.."\nLock Group Photo : "..settings.lock_photo.."\nLock Group Member : "..settings.lock_member
    return text
end

function run(msg, matches)
    if matches[1] == 'makegroup' and matches[2] then
        group_name = matches[2]
        return create_group(msg)
    end
    if not is_chat_msg(msg) then
	    return "This is Not Group"
	end
    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    if msg.media and is_chat_msg(msg) and is_momod(msg) then
    	if msg.media.type == 'photo' and data[tostring(msg.to.id)] then
    		if data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' then
    			load_photo(msg.id, set_group_photo, msg)
    		end
    	end
    end
    if data[tostring(msg.to.id)] then
		local settings = data[tostring(msg.to.id)]['settings']
		if matches[1] == 'setabout' and matches[2] then
		    deskripsi = matches[2]
		    return set_description(msg, data)
		end
		if matches[1] == 'about' then
		    return get_description(msg, data)
		end
		if matches[1] == 'setrules' then
		    rules = matches[2]
		    return set_rules(msg, data)
		end
		if matches[1] == 'rules' then
		    return get_rules(msg, data)
		end
		if matches[1] == '' and matches[2] == 'lock' then
		    if matches[3] == 'name' then
		        return lock_group_name(msg, data)
		    end
		    if matches[3] == 'member' then
		        return lock_group_member(msg, data)
		    end
		    if matches[3] == 'photo' then
		        return lock_group_photo(msg, data)
		    end
		end
		if matches[1] == '' and matches[2] == 'unlock' then
		    if matches[3] == 'name' then
		        return unlock_group_name(msg, data)
		    end
		    if matches[3] == 'member' then
		        return unlock_group_member(msg, data)
		    end
		    if matches[3] == 'photo' then
		    	return unlock_group_photo(msg, data)
		    end
		end
		if matches[1] == '' and matches[2] == 'settings' then
		    return show_group_settings(msg, data)
		end
		if matches[1] == 'chat_rename' then
		    if not msg.service then
		        return "Are You Trying to Troll Me?"
		    end
		    local group_name_set = settings.set_name
		    local group_name_lock = settings.lock_name
		    local to_rename = 'chat#id'..msg.to.id
		    if group_name_lock == 'yes' then
		        if group_name_set ~= tostring(msg.to.print_name) then
		            rename_chat(to_rename, group_name_set, ok_cb, false)
		        end
		    elseif group_name_lock == 'no' then
                return nil
            end
		end
		if matches[1] == 'setname' and is_momod(msg) then
		    local new_name = string.gsub(matches[2], '_', ' ')
		    data[tostring(msg.to.id)]['settings']['set_name'] = new_name
		    save_data(_config.moderation.data, data) 
		    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
		    local to_rename = 'chat#id'..msg.to.id
		    rename_chat(to_rename, group_name_set, ok_cb, false)
		end
		if matches[1] == 'setphoto' and is_momod(msg) then
		    data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	        save_data(_config.moderation.data, data)
	        return 'Send Group Photo Now'
		end
		if matches[1] == 'chat_add_user' then
		    if not msg.service then
		        return "Are You Trying to Troll Me?"
		    end
		    local group_member_lock = settings.lock_member
		    local user = 'user#id'..msg.action.user.id
		    local chat = 'chat#id'..msg.to.id
		    if group_member_lock == 'yes' then
		        chat_del_user(chat, user, ok_cb, true)
		    elseif group_member_lock == 'no' then
                return nil
            end
		end
		if matches[1] == 'chat_delete_photo' then
		    if not msg.service then
		        return "Are You Trying to Troll Me?"
		    end
		    local group_photo_lock = settings.lock_photo
		    if group_photo_lock == 'yes' then
		        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
		    elseif group_photo_lock == 'no' then
                return nil
            end
		end
		if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
		    if not msg.service then
		        return "Are You Trying to Troll Me?"
		    end
		    local group_photo_lock = settings.lock_photo
		    if group_photo_lock == 'yes' then
		        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
		    elseif group_photo_lock == 'no' then
		    	return nil
		    end
		 end
    end
end


return {
  description = "Group Manager", 
  usage = {
    "!makegroup <Name> : Create New Group",
    "!setabout <Message> : Set About For Group",
	"!setrules <Message> : Set Rules For Group",
    "!setname <Name> : Set Name For Group",
    "!setphoto : Set Photo For Group",
    "!lock name : Lock Group Name",
    "!lock photo : Lock Group Photo",
    "!lock member : Lock Group Member",		
    "!unlock name : Unlock Group Name",
    "!unlock photo : Unlock Group Photo",
    "!unlock member : Unlock Group Member",		
    "!settings : View Group Settings"
    "!about : View Group About",
    "!rules : View Group Rules",
    },
  patterns = {
    "^!(makegroup) (.*)$",
    "^!(setabout) (.*)$",
    "^!(setrules) (.*)$",
    "^!(setname) (.*)$",
    "^!(setphoto)$",
    "^!() (lock) (.*)$",
    "^!() (unlock) (.*)$",
    "^!() (settings)$",
    "^!(about)$",
    "^!(rules)$",
    "^!!tgservice (.+)$",
    "%[(photo)%]",
  }, 
  run = run,
}

end
