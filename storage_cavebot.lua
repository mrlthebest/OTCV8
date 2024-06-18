
local verify_looping = 5; -- delay para verificar e salvar todas configurações(minutos)


-- n altera nada abaixo
MAIN_DIRECTORY = "/bot/" .. modules.game_bot.contentsPanel.config:getCurrentOption().text .. "/storage/" .. g_game.getWorldName() .. "/";
STORAGE_DIRECTORY = "" .. MAIN_DIRECTORY .. name() .. ".json";
profile = {
    _storage={
        caveBot= {},
        targetBot= {}
    }
};

if not g_resources.directoryExists(MAIN_DIRECTORY) then
	g_resources.makeDir(MAIN_DIRECTORY);
end


if (type(load_file) ~= "function") then
	function load_file()
		if (g_resources.fileExists(STORAGE_DIRECTORY)) then
			local content = g_resources.readFileContents(STORAGE_DIRECTORY);
			local status, result = pcall(json.decode, content);
			if status then
				profile = result;
			end
		else
			save_file();
		end
	end
end


if (type(save_file) ~= "function") then
	function save_file()
		local status, result = pcall(json.encode, profile, 4);
		if status then
			g_resources.writeFileContents(STORAGE_DIRECTORY, result);
		end
	end
end


change_main_logic = function()
	if profile._storage then
		profile._storage.caveBot.enabled = CaveBot.isOn();
		profile._storage.targetBot.enabled = TargetBot.isOn();
		if profile._storage.caveBot.selected then
			if (storage._configs.cavebot_configs.selected ~= profile._storage.caveBot.selected) then
				profile._storage.caveBot.selected = storage._configs.cavebot_configs.selected;
			end
		else
			profile._storage.caveBot.selected = storage._configs.cavebot_configs.selected;
		end
		if profile._storage.targetBot.selected then
			if (storage._configs.targetbot_configs.selected ~= profile._storage.targetBot.selected) then
				profile._storage.targetBot.selected = storage._configs.targetbot_configs.selected;
			end
		else
			profile._storage.targetBot.selected = storage._configs.targetbot_configs.selected;
		end
	end
	save_file();
end


do
	load_file();
	if (profile._storage.caveBot.enabled == nil) then
		profile._storage.caveBot.enabled = CaveBot.isOn();
	elseif profile._storage.caveBot.enabled then
		CaveBot.setOn();
	else
		CaveBot.setOff();
	end
	if (profile._storage.targetBot.enabled == nil) then
		profile._storage.targetBot.enabled = TargetBot.isOn();
	elseif profile._storage.targetBot.enabled then
		TargetBot.setOn();
	else
		TargetBot.setOff();
	end
    change_main_logic();
end


macro(verify_looping * 1000, change_main_logic)