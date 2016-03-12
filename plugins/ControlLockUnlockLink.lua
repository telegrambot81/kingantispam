-- By Mouamle_ telegram { @Mouamle }

-- how to use inside telegram --
-- if you want to prevent link sharing just do this command /link lock
-- if you want to disable the protection just do this command /link unlock
-- if you want to check the protection use this command /link ? 

-- a function that i make to cut the command and the / from the text and send me the text after the command  
function getText(msg)
    TheString = msg["text"];
    SpacePos = string.find(TheString, " ")
    FinalString = string.sub(TheString, SpacePos + 1)
    return FinalString;
end

do
local function run(msg, matches)
    -- Get the receiver 
    local receiver = get_receiver(msg)
    
    -- use my function to get the text without the command
    Command = getText(msg)

    -- loading the data from _config.moderation.data
    local data = load_data(_config.moderation.data)
    if ( is_realm(msg) and is_admin(msg) or is_sudo(msg) or is_momod(msg) ) then
        -- check if the command is lock and by command i mean when you write /link lock   : lock here is the command
        if ( Command == "lock" ) then
            
            -- check if the lock_adds is already yes then tell the user and exit out 
            if ( data[tostring(msg.to.id)]['settings']['lock_adds'] == "yes" ) then
                send_large_msg ( receiver , "Link sharing already locked" ); -- send a message
                return -- exit
            end

            -- set the data 'lock_adds' in the table settings to yes
            data[tostring(msg.to.id)]['settings']['LockAds'] = "yes"
        
            -- send a message
            send_large_msg(receiver, "Link sharing Locked")

            -- save the data
            save_data(_config.moderation.data, data)


        -- check if the command is unlock
        elseif ( Command == "unlock" ) then

            -- check if the lock_adds is already no then tell the user and exit out 
            if ( data[tostring(msg.to.id)]['settings']['LockAds'] == "no" ) then
                send_large_msg ( receiver , "Link sharing already unlocked" ); -- send a message
                return -- exit
            end

            -- set the data 'lock_adds' in the table settings to no
            data[tostring(msg.to.id)]['settings']['LockAds'] = "no"
        
            -- send a message
            send_large_msg(receiver, "Link sharing Unlocked")

            -- save the data
            save_data(_config.moderation.data, data)

        -- check if the command is ? 
        elseif ( Command == "?" ) then

            -- load the data
            data = load_data(_config.moderation.data)

            -- get the data and set it to variable called EXSstring 
            EXString = data[tostring(msg.to.id)].settings.LockAds
        
            -- send the data ass a message 
            send_large_msg(receiver, "Link lock is : " .. EXString)
        end
    end
    return true;
end
 
return {
  patterns = {
    "[Ll][Ii][Nn][Kk]"
  },
  run = run
}
end