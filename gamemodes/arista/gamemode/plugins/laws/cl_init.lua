--[[
Name: "cl_init.lua".
Product: "gofuckyourself".
--]]
local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

include("sh_init.lua")

-- Register the plugin.
cityrp.plugin.register(PLUGIN);