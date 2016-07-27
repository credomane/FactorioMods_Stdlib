--- Config_JsonPath module
-- @module Config_JsonPath

require 'stdlib/core'
require 'stdlib/string'
require 'stdlib/table'

-----------------------------------------------------------------------
--Setup repeated code for use in sub functions here
-----------------------------------------------------------------------
--Optional dependencies to enable JsonPath query support
local haslpeg, lpeg = pcall(require, "stdlib-dep/lulpeg/lulpeg")
local hasjsonpath, jsonpath = pcall(require, "stdlib-dep/jsonpath/jsonpath")

if not haslpeg then
    error("JsonPath Config_JsonPath requires an external dependency 'LuLPeg' but it is missing.")
end

if not hasjsonpath then
    error("JsonPath Config_JsonPath requires an external dependency 'JSONPath' but it is missing.")
end

Config_JsonPath = {}

--- Creates a new Config_JsonPath object
-- to ease the management of a config table.
-- @param config_table [required] The table to be managed.
-- @return the Config_JsonPath instance for managing config_table
function Config_JsonPath.new(config_table)
    if not config_table then
        error("config_table is a required parameter.")
    elseif type(config_table) ~= "table" then
        error("config_table must be a table. Was given [" .. type(options) .. "]")
    elseif type(config_table.get) == "function" then
        error("Config_JsonPath can't manage another Config object")
    end

    -----------------------------------------------------------------------
    --Setup the Config_JsonPath object
    -----------------------------------------------------------------------
    local Config_JsonPath = {}

    --- Get a stored config value.
    -- @param path [required] a string representing the variable to retrieve
    -- @return value at path or nil if not found and no default given
    function Config_JsonPath.get(path)
        if type(path) ~= "string" or path:is_empty() then error("path is invalid") end

        local config = config_table

        local matches = jsonpath.nodes(config, path)
        if #matches == 0 then
            return nil
        end

        local part = config;
        local value = nil;
        local i
        for i=1, #matches, 1 do
            table.remove(matches[i].path, 1) --Remove $ from path
            matches[i].path = table.concat(matches[i].path, ".")
        end
        return matches
    end

    --- Set a stored config value.
    -- @param path [required] a string, config variable to set
    -- @param data (optional) to set path to. If nil it behaves identical to Config.delete()
    -- @return boolean true on success; false on failure.
    function Config_JsonPath.set(path, data)
        if type(path) ~= "string" or path:is_empty() then error("path is invalid") end

        local config = config_table

        local matches = jsonpath.nodes(config, path)
        if #matches == 0 then
            return 0
        end

        local part = config;
        local i
        for i=1, #matches, 1 do
            if #matches[i].path == 2 then
                part[matches[i].path[2]] = data;
            else
                for key = 2, #matches[i].path - 1, 1 do
                    part = part[matches[i].path[key]];
                end
                part[matches[i].path[#matches[i].path]] = data;
            end
        end
        return #matches
    end

    --- Delete a stored config value.
    -- @param path a string, config variable to set
    -- @return boolean, true on success, false on failure.
    function Config_JsonPath.delete(path)
        if type(path) ~= "string" or path:is_empty() then error("path is invalid") end

        local config = config_table

        local matches = jsonpath.nodes(config, path)
        if #matches == 0 then
            return 0
        end

        local part = config;
        local value = nil;
        local i
        for i=1, #matches, 1 do
            if #matches[i].path == 2 then
                part[matches[i].path[2]] = nil;
            else
                for key = 2, #matches[i].path - 1, 1 do
                    part = part[matches[i].path[key]];
                end
                part[matches[i].path[#matches[i].path]] = nil;
            end
        end
        return #matches
    end

    --- Test the existence of a stored config value.
    -- @param path a string, config variable to test
    -- @return boolean, true on success, false otherwise
    function Config_JsonPath.is_set(path)
        if type(path) ~= "string" or path:is_empty() then error("path is invalid") end

        local config = config_table

        local matches = jsonpath.nodes(config, path)
        return #matches
    end

    return Config_JsonPath
end

return Config_JsonPath
