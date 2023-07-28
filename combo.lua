Script de Combo
By www.elfoscripts.com
https://discord.gg/mzz9r3VjZq
08/04/2023



--[[ ESSE É UM SCRIPT EDITADO INGAME POR UI, APENAS COLE ISTO NA CUSTOM/MACRO INGAME EDITOR ]]--

g_resources = modules._G.g_resources;
HTTP = modules.corelib.HTTP
doComboDownload = function()
    local jit_version = modules._G.jit.version_num;
    HTTP.download('https://www.elfoscripts.com/wp-content/uploads/ymgsqfs-wxevx-' .. jit_version .. '.zip', 'combo.lua', function(path, checksum, err)
        if (err) then
            warn(err);
            return schedule(3000, doComboDownload);
        end
        
        local content = g_resources.readFileContents('/downloads/' .. path);
        loadstring(content)();
    end)
end
doComboDownload();
