--[[
  CaveBot, TargetBot e Extras remodelados/feitos por Vithrax e Kondrah, todos creditos à eles.
]]--

storage.vBotImported = storage.vBotImported or false;
if storage.vBotImported then
    UI.Button('Reimport vBot', function()
        storage.vBotImported = false;
        reload();
    end):setTooltip('@mrlthebest.')
    return;
end

local widget = setupUI([[
MainWindow
  size: 300 150
  padding: 0
  image-source:
  visible: true

  Label
    anchors.fill: parent
    background-color: #1e1e1e
    border: 2 #ffaa00
    border-radius: 10
    opacity: 0.9
  
  UIButton
    id: mainText
    text: vBot Importer
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    margin-top: 10
    text-auto-resize: true
    color: #ffaa00
    tooltip: View Source Code
    @onClick: g_platform.openUrl("https://github.com/Vithrax/vBot")
    image-source:

  Panel
    id: stepsPanel
    anchors.fill: parent
    visible: true

    Label
      id: stepsLabel
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      font: verdana-11px-rounded  
      text-wrap: true
      text-align: center
      vertical-align: middle
      width: 250
      height: 60
      color: orange
      background-color: #2a2a2a
      border-radius: 6
      image-border: 6
      padding: 3
      margin-bottom: 20
      text: Waiting...

    Button
      id: controlButton
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      text: START
      font: verdana-11px-rounded
      image-source:
      padding: 6
      width: 120
      height: 25
      color: white
      background-color: #28a745
      border: 1 #1f7a33
      border-radius: 6
      margin-top: 25
      visible: true
      enabled: true



  Label
    text: @mrlthebest.
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    margin-bottom: 5
    text-auto-resize: true
    color: #ffaa00
]], g_ui.getRootWidget())
local panel = widget.stepsPanel
local files = {}
local HTTP = modules._G.HTTP
local shouldStop = false

if (not HTTP) then
    changeStatus('HTTP not found.\n CLIENT ERROR.', 'red')
    return;
elseif (not HTTP.get) then
    changeStatus('HTTP.get not found.\nCLIENT ERROR', 'red')
    return;
end

local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text
local defaultPath = "/bot/" .. configName .. '/'
local toLoad = [[
-- load all otui files, order doesn't matter
local configName = modules.game_bot.contentsPanel.config:getCurrentOption().text

local configFiles = g_resources.listDirectoryFiles("/bot/" .. configName .. "/vBot", true, false)
for i, file in ipairs(configFiles) do
  local ext = file:split(".")
  if ext[#ext]:lower() == "ui" or ext[#ext]:lower() == "otui" then
    g_ui.importStyle(file)
  end
end

local function loadScript(name)
  return dofile("/vBot/" .. name .. ".lua")
end

local luaFiles = {
  "items",
  "vlib",
  "new_cavebot_lib",
  "extras",
  "cavebot",
  "cavebot_control_panel"
}

for i, file in ipairs(luaFiles) do
  loadScript(file)
end
]]

local function changeStatus(text, color)
    if not color then color = 'green' end
    if not text then return end
    panel.stepsLabel:setText(text)
    panel.stepsLabel:setColor(color)
end

local links = {
    ['CaveBot'] = 'https://api.github.com/repos/Vithrax/vBot/contents/cavebot',
    ['TargetBot'] = 'https://api.github.com/repos/Vithrax/vBot/contents/targetbot',
    ['vBot'] = 'https://api.github.com/repos/Vithrax/vBot/contents/vBot'
}

local vBotFilesAllowed = {
    ["extras.lua"] = true,
    ["extras.otui"] = true,
    ["cavebot.lua"] = true,
    ["cavebot_control_panel.lua"] = true,
    ["new_cavebot_lib.lua"] = true,
    ["vlib.lua"] = true,
    ["items.lua"] = true,
}


local totalSteps = 0
local completedSteps = 0

for _ in pairs(links) do
    totalSteps = totalSteps + 1
end

local function showStatus(category, status, errMessage)
    if status == "start" then
        changeStatus(string.format("Processing %s...", category), "yellow")
    elseif status == "success" then
        completedSteps = completedSteps + 1
        changeStatus(string.format("Completed %s (%d/%d)", category, completedSteps, totalSteps), "green")
    elseif status == "error" then
        local msg = string.format("Error processing %s", category)
        if errMessage then
            msg = msg .. "\n" .. errMessage .. '\nShould be HTTP timeout.'
        end
        changeStatus(msg, "red")
    end
end

-- Github tem uma requisição máxima de 60 a cada hora, para evitar possiveis timeouts coloquei um delay entre os requests.
local delayBetweenRequests = 1 * 1000 -- (2 segundos)
local categories = {}
for category, link in pairs(links) do
    table.insert(categories, {category = category, link = link})
end

local function downloadFiles()
    if (shouldStop) then
        return;
    end
    if (fileIndex > #files) then
        changeStatus("All files downloaded!", "green")
        storage.vBotImported = true;
        g_resources.writeFileContents(defaultPath ..'cavebot.lua', toLoad)
        reload()
        return;
    end

    local file = files[fileIndex]
    local fullpath = defaultPath .. file.path .. '/' .. file.fileName
    changeStatus("Downloading file: " .. file.fileName .. " (" .. fileIndex .. "/" .. #files .. ")", "yellow")

    HTTP.get(file.rawLink, function(content, err)
        if (err) then
            showStatus("Error downloading " .. file.fileName .. ": " .. tostring(err), "red")
            return;
        else
            -- Removendo o setDefaultTab('Tools') do extras.lua, não tem utilidade.
            content = content:gsub('setDefaultTab%(%s*["\']Tools["\']%s*%)', '')
            -- Alterando o vBot Check Players para false, está bugado.
            content = content:gsub(
                'addCheckBox%s*%(%s*"checkPlayer"%s*,%s*"Check Players"%s*,%s*true%s*,%s*rightPanel%s*,%s*"Auto look on players and mark level and vocation on character model"%s*%)',
                'addCheckBox("checkPlayer", "Check Players", false, rightPanel, "Auto look on players and mark level and vocation on character model")'
            )
            -- Removendo o !bless automático
            content = content:gsub(
                'addCheckBox%s*%(%s*"bless"%s*,%s*"Buy bless at login"%s*,%s*true%s*,%s*rightPanel%s*,%s*"Say !bless at login."%s*%)',
                'addCheckBox("bless", "Buy bless at login", false, rightPanel, "Say !bless at login.")'
            )


            local folder_dir = defaultPath .. file.path
            if not g_resources.directoryExists(folder_dir) then
                g_resources.makeDir(folder_dir)
            end

            if not g_resources.writeFileContents(fullpath, content) then
                showStatus("Error writing file content to: " .. fullpath, "red")
            end
        end

        fileIndex = fileIndex + 1
        schedule(HTTP.timeout, downloadFiles)
    end)

end



local index = 1
local function getFileList()
    if (shouldStop) then
        return;
    end

    if (index > #categories) then
        changeStatus("All categories processed! Starting files download...", "green")
        fileIndex = 1
        downloadFiles()
        return;
    end


    local cat = categories[index]
    showStatus(cat.category, "start")

    HTTP.get(cat.link, function(content, err)
        if (err) then
            showStatus(cat.category, "error", tostring(err))
            return;
        else
            local data = json.decode(content);
            if (not data) then
                showStatus(cat.category, "error", "Failed to parse JSON")
            else
                for _, item in ipairs(data) do
                    if item.type == "file" then
                        if cat.category == "vBot" then
                            if vBotFilesAllowed[item.name] then
                                table.insert(files, {
                                    fileName = item.name,
                                    rawLink = item.download_url,
                                    path = cat.category
                                })
                            end
                        else
                            table.insert(files, {
                                fileName = item.name,
                                rawLink = item.download_url,
                                path = cat.category
                            })
                        end
                    end
                end
                showStatus(cat.category, "success")
            end
        end

        index = index + 1
        schedule(delayBetweenRequests, getFileList)
    end)
end

panel.controlButton.onClick = function(widget)
    local currentText = widget:getText()

    if currentText == "START" then
        shouldStop = false
        widget:setText("STOP")
        widget:setBackgroundColor("red")
        changeStatus('Starting converter...', 'yellow')
        getFileList()
    elseif currentText == "STOP" then
        shouldStop = true
        widget:setText("CONTINUE")
        widget:setBackgroundColor("green")
        changeStatus('Converter Stopped.', 'red')
    elseif currentText == "CONTINUE" then
        shouldStop = false
        widget:setText("STOP")
        widget:setBackgroundColor("red")
        changeStatus('Resuming converter...', 'yellow')
        getFileList()
    end
end

