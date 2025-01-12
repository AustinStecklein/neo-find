<div align="center">

# neo find

A fzf-lua extension to improve searching

</div>

## Overview
What is it?
neo-find extends fzf-lua to allow for the current working directory of fzf commands to be changed.
To make it easier to find the desired directory all file directories are found through the find
command and that selection is piped into the desired fzflua command

Install
```vim
call plug#begin()
Plug 'AustinStecklein/neo-find'
```
Example of setting up keybindings
```lua
local neo_find = require("neo-find")

-- Args are passed to the find command and can be used to filter out files. In this case it will
-- Filter out dot files
local ignore_args  = " ! -path '*/.*/*' ! -name '.*' "
local path = "~"
-- This works just like the files or live_grep command but only for directories
vim.keymap.set("n", "<Leader>df", function() neo_find.find_dir(ignore_args, path) end)
-- This is the bread and butter command
-- It will first pull up a window to find a directory then it will use that result to the passed in
-- fzf command as the cwd
vim.keymap.set("n", "<Leader>ff", function() neo_find.find_dir_and_search(ignore_args, fzflua.files, path) end)
vim.keymap.set("n", "<Leader>fg", function() neo_find.find_dir_and_search(ignore_args, fzflua.live_grep, path) end)
```
> [!TIP]
> The args ignore_args and path can accept nil as a value
> ignore_args will default to ""
> path will default to "~"
> So the following commands are valid
> ```lua
> vim.keymap.set("n", "<Leader>df", function() neo_find.find_dir() end)
> vim.keymap.set("n", "<Leader>fg", function() neo_find.find_dir_and_search(nil, fzflua.live_grep) end)
> ```

## TODOs
* Option to change neovims working dir to the dir that was picked. (not sure if this is possible)
* Add linting and lua style checker
* Add in correct prompts to the fzf-lua windows
