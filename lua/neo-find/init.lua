-- FzfLua Extension for finding files easier
local M = {}

local fzflua = require("fzf-lua")
local fzf_lua_extenstion = require("neo-find.core")

function start_up_callback(additional_args, search_callback) 
    return function(selected, opts) 
	if selected[1] == nil then
	    return
	end
    	search_callback({
		cwd=fzf_lua_extenstion.clean_file_path(selected, opts),
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
            cmd="find " .. path .. " \\( -type d " .. additional_args .. " \\)", 
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
