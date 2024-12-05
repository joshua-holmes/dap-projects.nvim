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
    local status_ok_config, config = pcall(require, project_config)
    if not status_ok_config then
        return
    end

    vim.notify("[dap-projects.nvim] Found custom configuration at." .. project_config, vim.log.levels.INFO, nil)

    -- copy custom config to dap
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
    end
    if dap.configurations ~= nil then
        for lang, conf in pairs(config.configurations) do
            if dap.configurations[lang] ~= nil then
                for key, val in pairs(conf) do
                    dap.adapters[lang][key] = val
                end
            else
                dap.adapters[lang] = conf
            end
        end
    end
end

return M
