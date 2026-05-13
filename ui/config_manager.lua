local Module = {Name = "ui.config_manager", Kind = "lib"}

local HttpService = game:GetService("HttpService")

local function attachConfigManager(UI)
  if type(UI) ~= "table" then
    return false
  end

  function UI:CreateConfigManager(window, stateTable, opts)
    opts = opts or {}

    local folder = tostring(opts.Folder or "NovaConfigs")
    local defaultName = tostring(opts.DefaultName or "default")
    local sync = opts.Sync
    local tabName = tostring(opts.TabName or "Configs")
    local activeName = defaultName
    local selectedName = defaultName
    local configList
    local configInput
    local busy = false
    local refresh
    local hiddenDeleted = {}

    local function cleanName(name)
      local raw = tostring(name or defaultName)
      local clean = raw:gsub("[^%w_%-%s]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "_")
      return clean ~= "" and clean or defaultName
    end

    local function ensureFolder()
      if typeof(makefolder) == "function" and typeof(isfolder) == "function" and not isfolder(folder) then
        pcall(function()
          makefolder(folder)
        end)
      end
    end

    local function pathFor(name)
      return folder .. "/" .. cleanName(name) .. ".json"
    end

    local manager = {}

    local function notifyConfig(title, content)
      if window and window.Notify then
        window:Notify({
          Title = tostring(title or "Config"),
          Content = tostring(content or ""),
          Duration = 5,
        })
      end
    end

    local function fileExists(name)
      return typeof(isfile) == "function" and isfile(pathFor(name))
    end

    function manager:List()
      ensureFolder()
      local out = {}
      if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(folder) then
        local ok, files = pcall(function()
          return listfiles(folder)
        end)
        if ok and type(files) == "table" then
          for index = 1, #files do
            local fileName = tostring(files[index]):match("([^/\\]+)%.json$")
            if fileName and not hiddenDeleted[fileName] then
              table.insert(out, fileName)
            end
          end
        end
      end
      table.sort(out)
      if #out == 0 then
        table.insert(out, defaultName)
      end
      return out
    end

    local function uniqueName(base)
      local root = cleanName(base or "config")
      local used = {}
      for _, item in ipairs(manager:List()) do
        used[tostring(item)] = true
      end
      if not used[root] and not fileExists(root) then
        return root
      end
      for index = 1, 999 do
        local candidate = cleanName(root .. "_" .. tostring(index))
        if not used[candidate] and not fileExists(candidate) then
          return candidate
        end
      end
      return cleanName(root .. "_" .. tostring(math.floor(tick())))
    end

    function manager:Save(name)
      ensureFolder()
      if typeof(writefile) ~= "function" then
        return false, "writefile unavailable"
      end

      local targetName = cleanName(name or activeName)
      local payload = {}
      for key, value in pairs(stateTable or {}) do
        local valueType = type(value)
        if valueType == "boolean" or valueType == "number" or valueType == "string" then
          payload[key] = value
        end
      end

      local ok, err = pcall(function()
        writefile(pathFor(targetName), HttpService:JSONEncode(payload))
      end)
      if ok then
        activeName = targetName
        selectedName = targetName
        hiddenDeleted[targetName] = nil
      end
      return ok, ok and targetName or tostring(err)
    end

    function manager:Load(name)
      ensureFolder()
      if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
        return false, "readfile/isfile unavailable"
      end

      local targetName = cleanName(name or activeName)
      local path = pathFor(targetName)
      if not isfile(path) then
        return false, "config missing"
      end

      local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
      end)
      if not ok or type(data) ~= "table" then
        return false, "invalid config"
      end

      for key, value in pairs(data) do
        if stateTable and stateTable[key] ~= nil and type(stateTable[key]) == type(value) then
          stateTable[key] = value
        end
      end
      if type(sync) == "function" then
        pcall(sync, stateTable)
      end
      activeName = targetName
      selectedName = targetName
      return true, targetName
    end

    function manager:Delete(name)
      if typeof(delfile) ~= "function" then
        return false, "delfile unavailable"
      end

      local targetName = cleanName(name or activeName)
      local path = pathFor(targetName)
      if typeof(isfile) == "function" and not isfile(path) then
        hiddenDeleted[targetName] = true
        return true, targetName
      end

      local ok, err = pcall(function()
        delfile(path)
      end)
      if ok then
        hiddenDeleted[targetName] = true
      end
      if ok and activeName == targetName then
        activeName = defaultName
        selectedName = defaultName
      end
      return ok, ok and targetName or tostring(err)
    end

    function manager:Rename(oldName, newName)
      ensureFolder()
      if typeof(readfile) ~= "function" or typeof(writefile) ~= "function" then
        return false, "readfile/writefile unavailable"
      end

      local sourceName = cleanName(oldName or selectedName or activeName)
      local targetName = cleanName(newName or sourceName)
      if sourceName == targetName then
        activeName = targetName
        selectedName = targetName
        return true, targetName
      end

      local sourcePath = pathFor(sourceName)
      local targetPath = pathFor(targetName)
      if typeof(isfile) == "function" and not isfile(sourcePath) then
        return false, "source config missing"
      end
      if typeof(isfile) == "function" and isfile(targetPath) then
        return false, "target config exists"
      end

      local okRead, data = pcall(function()
        return readfile(sourcePath)
      end)
      if not okRead then
        return false, tostring(data)
      end

      local okWrite, writeErr = pcall(function()
        writefile(targetPath, data)
      end)
      if not okWrite then
        return false, tostring(writeErr)
      end

      if typeof(delfile) == "function" then
        pcall(function()
          delfile(sourcePath)
        end)
      end

      hiddenDeleted[sourceName] = true
      hiddenDeleted[targetName] = nil
      activeName = targetName
      selectedName = targetName
      return true, targetName
    end

    if window and window.CreateTab then
      local tab = window:CreateTab(tabName)
      configInput = tab:CreateInput({
        Name = "Config Name",
        CurrentValue = activeName,
        PlaceholderText = defaultName,
        Callback = function() end,
      })

      local listFactory = tab.CreateConfigList or tab.CreateOptionPicker or tab.CreateDropdown
      if listFactory then
        configList = listFactory(tab, {
          Name = "Saved Configs",
          Options = manager:List(),
          CurrentOption = {activeName},
          ListHeight = 232,
          DefaultName = defaultName,
          Callback = function(value)
            selectedName = cleanName(type(value) == "table" and value[1] or value)
            activeName = selectedName
            if configInput and configInput.Set then
              configInput:Set(selectedName)
            end
          end,
        })
      end

      local function currentInputName()
        if configInput and configInput.Get then
          local raw = tostring(configInput:Get() or "")
          if raw ~= "" then
            return cleanName(raw)
          end
        end
        return cleanName(activeName)
      end

      local function currentSelectedName()
        return cleanName(selectedName or activeName or currentInputName())
      end

      local function runConfigAction(action)
        if busy then
          return false
        end
        busy = true
        local ok, err = pcall(action)
        if not ok then
          if UI.Debug then
            warn("[NovaPremiumUI] Config action failed: " .. tostring(err))
          end
          notifyConfig("Config Fehler", tostring(err))
        end
        busy = false
        return ok
      end

      local function confirmOverwrite(targetName, confirmed)
        if fileExists(targetName) and window and window.Confirm then
          window:Confirm({
            Title = "Config ersetzen",
            Content = "Es besteht bereits eine Config mit diesem Namen. Moechtest du sie ersetzen?",
            ConfirmText = "Ersetzen",
            CancelText = "Abbrechen",
            ConfirmCallback = confirmed,
          })
        else
          confirmed()
        end
      end

      refresh = function(selectName)
        if configList and configList.Refresh then
          local names = manager:List()
          local selected = cleanName(selectName or activeName)
          local exists = false
          for _, item in ipairs(names) do
            if tostring(item) == selected then
              exists = true
              break
            end
          end
          if not exists then
            selected = names[1] or defaultName
          end
          activeName = selected
          selectedName = selected
          configList:Refresh(names)
          if configList.Set then
            configList:Set(selected)
          end
          if configInput and configInput.Set then
            configInput:Set(selected)
          end
        elseif configInput and configInput.Set then
          configInput:Set(cleanName(selectName or activeName))
        end
      end

      tab.OnShow = function()
        refresh(selectedName or activeName)
      end

      local function saveCurrent()
        local targetName = currentInputName()
        local function doSave()
          runConfigAction(function()
            local ok, saved = manager:Save(targetName)
            notifyConfig(ok and "Config gespeichert" or "Config Fehler", ok and ("Gespeichert: " .. tostring(saved)) or tostring(saved))
            refresh(ok and saved or activeName)
          end)
        end
        if fileExists(targetName) then
          confirmOverwrite(targetName, doSave)
        else
          doSave()
        end
      end

      local function createNew()
        runConfigAction(function()
          local name = uniqueName("config")
          local ok, saved = manager:Save(name)
          notifyConfig(ok and "Config erstellt" or "Config Fehler", ok and ("Erstellt: " .. tostring(saved)) or tostring(saved))
          refresh(ok and saved or activeName)
        end)
      end

      local function loadSelected()
        runConfigAction(function()
          local ok, loaded = manager:Load(currentSelectedName())
          notifyConfig(ok and "Config geladen" or "Config Fehler", ok and ("Geladen: " .. tostring(loaded)) or tostring(loaded))
          refresh(ok and loaded or activeName)
        end)
      end

      local function deleteSelectedAction()
        local targetName = currentSelectedName()
        local function deleteSelected()
          runConfigAction(function()
            local ok, deleted = manager:Delete(targetName)
            notifyConfig(ok and "Config geloescht" or "Config Fehler", ok and ("Geloescht: " .. tostring(deleted)) or tostring(deleted))
            refresh()
          end)
        end
        if window and window.Confirm then
          window:Confirm({
            Title = "Config loeschen",
            Content = "Moechtest du wirklich Config \"" .. tostring(targetName) .. "\" loeschen?",
            ConfirmText = "Loeschen",
            CancelText = "Abbrechen",
            ConfirmCallback = deleteSelected,
          })
        else
          deleteSelected()
        end
      end

      if tab.CreateActionGroup then
        tab:CreateActionGroup({
          Name = "Config Actions",
          Actions = {
            {Name = "Save", Style = "Primary", Callback = saveCurrent},
            {Name = "New", Style = "Primary", Callback = createNew},
            {Name = "Load", Style = "Primary", Callback = loadSelected},
            {Name = "Delete", Style = "Primary", Callback = deleteSelectedAction},
          },
          AllBlue = true,
        })
      else
        tab:CreateButton({Name = "Save", Callback = saveCurrent})
        tab:CreateButton({Name = "New", Callback = createNew})
        tab:CreateButton({Name = "Load", Callback = loadSelected})
        tab:CreateButton({Name = "Delete", Callback = deleteSelectedAction})
      end

      refresh(activeName)
    end

    return manager
  end

  UI.ConfigManagerModule = Module
  return true
end

function Module.Attach(UI)
  return attachConfigManager(UI)
end

function Module.Start(ctx)
  ctx = type(ctx) == "table" and ctx or {}
  local runtime = ctx.Runtime
  local ui = runtime and runtime.GetUI and runtime.GetUI()
  if not ui and getgenv then
    ui = getgenv().NovaPremiumUI
  end

  attachConfigManager(ui)

  return ui ~= nil
end

return Module
