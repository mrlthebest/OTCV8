doDownloadImage = function(imageUrl, widget, type)
    local function callback(filePath, error)
        if error then
            warn(error)
            return
        elseif (type == "icon") then
            widget:setIcon(filePath)
        elseif (type == "image") then
            widget:setImageSource(filePath)
        end
    end
    modules._G.HTTP.downloadImage(imageUrl, callback)
end

-- Exemplo de uso:
local rootWidget = g_ui.getRootWidget()
local urlImage = 'https://example.com/image.png' -- Substitua pela URL da sua imagem
if rootWidget then
    local botWindow = rootWidget:recursiveGetChildById("botWindow")
    if botWindow then
        doDownloadImage(urlImage, botWindow, 'image')
    end
end
