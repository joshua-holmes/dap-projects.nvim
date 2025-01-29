local M = {}

M.config_paths = {"./.nvim/dap.lua", "./.dap.lua", "./dap.lua"}

M.search_project_config = function()
    local status_ok, dap = pcall(require, "dap")
    if not status_ok then
        vim.notify("[dap-projects.nvim] Could not find nvim-dap, make sure you load it before dap-projects.nvim.", vim.log.levels.ERROR, nil)
        return
    end
    local project_config = ""
    for _, p in ipairs(M.config_paths) do
        local f = io.open(p)
        if f ~= nil then
            f:close()
            project_config = p
            break
        end
    end

    local status_ok_config = loadfile(project_config)
    if not status_ok_config then
        return
    end
    local config = status_ok_config()

    vim.notify("[dap-projects.nvim] Found custom configuration at " .. project_config, vim.log.levels.INFO, nil)

    -- copy custom config to dap
    if config.adapters ~= nil then
        if dap.adapters ~= nil then
            for adapter, conf in pairs(config.adapters) do
                if dap.adapters[adapter] ~= nil then
                    for key, val in pairs(conf) do
                        dap.adapters[adapter][key] = val
                    end
                else
                    dap.adapters[adapter] = conf
                end
            end
        else
            dap.adapters = config.adapters
        end
        -- Apply overrides if necessary,
        -- We assume there is only one entry,
        -- since providing any more is useless
        if config.override ~= nil then
            local override_key = next(config.adapters, nil)
            setmetatable(dap.adapters, {
                __index = function(table, key)
                    return rawget(table, override_key)
                end
            })
        end
    end
    if config.configurations ~= nil then
        if dap.configurations ~= nil then
            for lang, conf in pairs(config.configurations) do
                local tab = dap.configurations[lang]
                local tab_len = 0
                if tab ~= nil then
                    for _, _ in pairs(tab) do tab_len = tab_len + 1 end
                end
                if tab_len > 0 then
                    for key, val in pairs(conf) do
                        dap.configurations[lang][1][key] = val
                    end
                else
                    dap.configurations[lang] = { conf }
                end
            end
        else
            dap.configurations = config.configurations
        end
        -- Apply overrides if necessary
        if config.override ~= nil then
            local override_key = next(config.configurations, nil)
            setmetatable(dap.configurations, {
                __index = function(table, key)
                    return rawget(table, override_key)
                end
            })
        end
    end
end

return M
