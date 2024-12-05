# dap-projects.nvim

A fork of [nvim-dap-projects](https://github.com/ldelossa/nvim-dap-projects) that gives you the same functionality with less configuration.

A very simple plugin which implements "per-project" nvim-dap debugger adapters and configurations.

This plugin allows source code maintainers to place a `.dap.lua` (or other) configuration file in their repository. When this plugin discovers the file, it will overwrite only the `nvim-dap` configs specified in `.dap.lua`.

If this plugin does not find a local configuration file it simply performs no action and `nvim-dap`'s global configuration file will be used to display debugger configurations.


## Usage

Using packer or your favorite plugin manager:
```lua
use "joshua-holmes/dap-projects.nvim"
...
lua require("dap-projects").search_project_config()
```

Install the plugin and then call it's `search_project_config` method at any point after its install, and after your global `nvim-dap` config is loaded.

By default, the paths `./.dap.lua`, `./dap.lua` and `./.nvim/dap.lua` are searched for. What do you put in these files? An `adapters` table and/or a `configurations` table with as many languages and properties that you want to overwrite your global `nvim-dap` configs with.

Here is an example of what I might want to put into a file like `./.dap.lua` if I wanted to change some Rust and Python `nvim-dap` configs:
```lua
local M = {}
M.adapters = {
    python = {
        command = "python310"
    },
    gdb = {
        command = "gdb",
        args = { "--quiet", "--interpreter=dap" }
    }
}
M.configurations = {
    python = {
        program = "${workspaceFolder}/python-app/main.py"
    },
    rust = {
        program = "${workspaceFolder}/rust-app/target/debug/rust-app"
    }
}
return M
```

In the above example, dap-projects.nvim would only overwrite the following properties, leaving the rest of the global `nvim-dap` config untouched:
* `require("dap").adapters.python.command`
* `require("dap").adapters.gdb.command`
* `require("dap").adapters.gdb.args`
* `require("dap").configurations.python.program`
* `require("dap").configurations.rust.program`

NOTE: It would overwrite all of `require("dap").adapters.gdb.args`


## Configuration

You may modify where dap-projects.nvim looks for project-level config files by changing or appending to the plugin's `config_paths` array before calling `search_project_config()`. For example, this will ask dap-projects.nvim to only search for the `dappy.lua` file:
```
lua require('dap-projects').config_paths = {"./dappy.lua"}
lua require('dap-projects').search_project_config()
```

Always provide the relative path to the actual config file.


## How this plugin differs from its fork
To be clear, I love the old plugin! It is what inspired this one, after all. I think it adds a great quality-of-life feature to my favorite text editor! However, I just wanted to see a plugin that did things a little differently, and thus dap-projects.nvim was born.

This plugin allows you to overwrite only the `nvim-dap` properties that you want to change, rather than overwriting your global configuration. For example, say I have a Python configuration like so:
```lua
require("dap").configurations.python = {
    name = "${workspaceFolderBasename}",
    request = "launch",
    cwd = "${workspaceFolder}",
    type = "python",
    program = "${workspaceFolder}/app.py",
    justMyCode = false,
}
```
But let's say the entry point for the project I'm working on is called `main.py`, not `app.py`. If I tried to solve it by doing this with the old plugin...
```lua
require("dap").configurations.python.program = "${workspaceFolder}/main.py"
```
...then all the properties except `dap.configurations.python.program` would `nil`, even `dap.configurations.rust`, `.zig`, and every other language config! I would be forced to copy/paste my entire global `nvim-dap` config into the local config and change just that one line.

With dap-projects.nvim, I can create a `.dap.lua` file in the root directory of my project and put this in it:
```lua
local M = {}
M.configurations = {
    python = {
        program = "${workspaceFolder}/main.py"
    }
}
return M
```
That's it! Less config, less room for me to make a mistake, easier to read, and if I want to globally change a different property later on, like `python.cwd`, I don't also need to update all of my project configs to match.
