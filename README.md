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
require("dap-projects").search_project_config()
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

In the above example, `dap-projects.nvim` would only overwrite the following properties, leaving the rest of the global `nvim-dap` config untouched:
* `require("dap").adapters.python.command`
* `require("dap").adapters.gdb.command`
* `require("dap").adapters.gdb.args`
* `require("dap").configurations.python[1].program`
* `require("dap").configurations.rust[1].program`

A few notes for those that care about the details:
1. It would overwrite *all* of `require("dap").adapters.gdb.args`, not just the specified properties within the `.args` table. This is because of how deeply it is nested. The design is intentional.
2. It modifies the first item in the `require("dap").configurations.<lang>` array, even though arrays are not used in my `.dap.lua` file. This is because `nvim-dap` uses arrays in `.configurations.<lang>`, but I don't see a need to edit any of the tables except the first one in the array. So, I would rather keep the `.dap.lua` config simple than true to how the `nvim-dap` config is set up.
3. If `require("dap").configurations.python` table doesn't exist at the time of reading my `.dap.lua` config file above, then one is created using the `.dap.lua` file! Same if `require("dap").configurations` table is `nil`. In other words, there is no problem with *only* having project-level configs and leaving global `nvim-dap` config absent.


## Configuration

You may modify where `dap-projects.nvim` looks for project-level config files by changing or appending to the plugin's `config_paths` array before calling `search_project_config()`. For example, this will ask `dap-projects.nvim` to only search for the `dappy.lua` file:
```
lua require('dap-projects').config_paths = {"./dappy.lua"}
lua require('dap-projects').search_project_config()
```

Always provide the relative path to the actual config file.


## How this plugin differs from its fork
To be clear, I love the old plugin! It is what inspired this one, after all. I think it adds a great quality-of-life feature to my favorite text editor! However, I just wanted to see a plugin that did things a little differently, and thus `dap-projects.nvim` was born.

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

With `dap-projects.nvim`, I can create a `.dap.lua` file in the root directory of my project and put this in it:
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
