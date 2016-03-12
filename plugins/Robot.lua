local function is_channel_disabled( receiver )
	if not _config.disabled_channels then
		return false
	end

	if _config.disabled_channels[receiver] == nil then
		return false
	end

  return _config.disabled_channels[receiver]
end

local function enable_channel(receiver)
	if not _config.disabled_channels then
		_config.disabled_channels = {}
	end

	if _config.disabled_channels[receiver] == nil then
		return 'Robot is Not Disable'
	end
	
	_config.disabled_channels[receiver] = false

	save_config()
	return "Robot is Not Disable"
end

local function disable_channel( receiver )
	if not _config.disabled_channels then
		_config.disabled_channels = {}
	end
	
	_config.disabled_channels[receiver] = true

	save_config()
	return "Robot Disabled"
end

local function pre_process(msg)
	local receiver = get_receiver(msg)
	
	if is_momod(msg) then
	  if msg.text == "!bot enable" then
	    enable_channel(receiver)
	  end
	end

  if is_channel_disabled(receiver) then
  	msg.text = ""
  end

	return msg
end

local function run(msg, matches)
	local receiver = get_receiver(msg)
	if matches[1] == 'enable' then
		return enable_channel(receiver)
	end
	if matches[1] == 'disable' then
		return disable_channel(receiver)
	end
end

return {
	description = "Robot Enable / Disable", 
	usage = {
		"!bot enable: Enable Robot",
		"!bot disable: Disable Robot" },
	patterns = {
		"^!bot? (enable)",
		"^!bot? (disable)" }, 
	run = run,
	moderated = true,
	pre_process = pre_process
}
