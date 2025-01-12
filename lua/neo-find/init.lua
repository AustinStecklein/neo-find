-- FzfLua Extension for finding files easier
local M = {}
local fzflua = require("fzf-lua")
local builtin = require("fzf-lua.previewer.builtin")
local path = require("fzf-lua.path")
local uv = vim.uv or vim.loop

-- Inherit from the "buffer_or_file" previewer
local LsPreviewer = builtin.buffer_or_file:extend()

function LsPreviewer:new(o, opts, fzf_win)
    LsPreviewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, LsPreviewer)
    return self
end

-- This was straight up taken from stack overflow
function LsPreviewer:scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function LsPreviewer:populate_preview_buf(entry_str)
    if entry_str == nil then 
        return
    end
    local tmpbuf = self:get_tmp_buffer()
    vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, self:scandir(entry_str))
    self:set_preview_buf(tmpbuf)
end

function clean_file_path(selected, opts)
    -- this whole function straight up ripped out of actions.lua at the start of M.vimcmd_entry
    -- going to assume that only one selection was made since it doesn't make sense to make
    -- more than one.
    local entry = path.entry_to_file(selected[1], opts, opts._uri)
    -- "<none>" could be set by `autocmds`
    if entry.path == "<none>" then return end
    local fullpath = entry.bufname or entry.uri and entry.uri:match("^%a+://(.*)") or entry.path
    -- Something is not right, goto next entry
    if not fullpath then return end
    if not path.is_absolute(fullpath) then
      fullpath = path.join({ opts.cwd or opts._cwd or uv.cwd(), fullpath })
    end
    return fullpath
end

function start_up_callback(additional_args, search_callback) 
    return function(selected, opts) 
	if selected[1] == nil then
	    return
	end
    	search_callback({
		cwd=clean_file_path(selected, opts),
		-- create a path back out to find_dir_and_search. This is like a repo on the dir search
		actions={["ctrl-r"] = function() find_dir_and_search(additional_args, search_callback) end},
    	}) 
    end
end

-- very basic version of searching for a directory. Going to keep this one simple since I don't see 
-- a need to expand it's features past this
function find_dir(additional_args, path) 
    if path == nil then
        path = "~"
    end 

    if additional_args == nil then
        additional_args = ""
    end

    fzflua.files(
        { 
            prompt="Find Directory> ", 
            cmd="find " .. path .. " \\( " .. additional_args .. " \\)", 
        }
    ) 
end

-- This is the bread and butter of the whole feature
function find_dir_and_search(additional_args, search_callback, path) 
    if path == nil then
        path = "~"
    end 

    if additional_args == nil then
        additional_args = ""
    end

    fzflua.files(
        { 
            prompt="Find Directory> ", 
            cmd="find " .. path .. " \\( -type d " .. additional_args .. " \\)", 
            -- magic action that opens up the second fzf window with the dir previously selected
            actions={
                -- This assumes that the only command that we would want to run is the enter key.
                -- I wonder if there is something else we can do.
                ["enter"] = start_up_callback(additional_args, search_callback),
            },
            previewer=LsPreviewer,
            git_icons=false,
        }
    ) 
end

M.find_dir_and_search = find_dir_and_search
M.find_dir = find_dir
return M
