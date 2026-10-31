
-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/settings.json")

-- Logic before locations, so the functions used by access rules exist.
ScriptHost:LoadScript("scripts/logic/world_data.lua")
ScriptHost:LoadScript("scripts/logic/logic.lua")

Tracker:AddMaps("maps/maps.json")
Tracker:AddLocations("locations/locations.json")
-- map tabs are generated along with the maps
Tracker:AddLayouts("layouts/map_tabs.json")
Tracker:AddLayouts("layouts/tracker.json")

-- Defaults before connecting, matching the AP world's default options.
-- Connecting to a seed replaces these with the seed's options (slot_data).
local function default_stage(code, stage)
    local obj = Tracker:FindObjectForCode(code)
    if obj then obj.CurrentStage = stage end
end
default_stage("goal", 1)  -- Dracula's Condition: Crystal
local per_warp = Tracker:FindObjectForCode("special1s_per_warp")
if per_warp then per_warp.AcquiredCount = 1 end
-- Without slot_data the stage order and warps are unknown, so start with
-- every stage treated as enterable. Turned off automatically on connect
-- when the world sends its stage order.
local open = Tracker:FindObjectForCode("setting_open_stages")
if open then open.Active = true end

-- Archipelago autotracking needs PopTracker 0.18.0 or newer.
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking/archipelago.lua")
end
