-- Archipelago autotracking
--
-- PopTracker connects to the AP server itself (the "AP" button), so nothing
-- has to run next to the game besides the normal CV64 BizHawk client.
--
--   onClear     new connection: reset everything, then read slot_data
--   onItem      an item was received: update the item grid
--   onLocation  a location was checked: clear its map section
--
-- Versions of the CV64 client with tracker support also write two data
-- storage keys that the tracker watches:
--   castlevania_64_current_map_<team>_<slot>  in-game map id -> switch to that stage's tab
--   castlevania_64_events_<team>_<slot>       bitfield of boss kills and the Crystal
-- With other clients these keys never appear and only items and locations track.
--
-- Hints come from the server's own key _read_hints_<team>_<slot>: a location
-- in this world that holds a hinted item gets its map pin outlined by the
-- hint's status (needs PopTracker 0.32.0 or newer; older versions skip it).

ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1

-- Set to false to stop the tracker from switching tabs on its own.
AUTO_SWITCH_TABS = true

-- Which tabs to activate for each in-game map is generated with the maps:
-- MAP_ID_TABS in scripts/logic/world_data.lua (matches layouts/map_tabs.json).

local function map_key()
    return "castlevania_64_current_map_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
end

local function events_key()
    return "castlevania_64_events_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
end

local function hints_key()
    return "_read_hints_" .. Archipelago.TeamNumber .. "_" .. Archipelago.PlayerNumber
end

-- AP hint status -> PopTracker highlight. Found hints (40) get no outline,
-- since the location is already checked.
local HINT_HIGHLIGHT = Highlight and {
    [0] = Highlight.Unspecified,
    [10] = Highlight.NoPriority,
    [20] = Highlight.Avoid,
    [30] = Highlight.Priority,
    [40] = Highlight.None,
}

-- slot_data options arrive as numbers (0/1) or booleans depending on the world version.
local function truthy(v)
    return v == true or (type(v) == "number" and v ~= 0)
end

local function set_toggle(code, on)
    local obj = Tracker:FindObjectForCode(code)
    if obj then obj.Active = on end
end

local function set_stage(code, stage)
    local obj = Tracker:FindObjectForCode(code)
    if obj and stage then obj.CurrentStage = stage end
end

local function set_count(code, n)
    local obj = Tracker:FindObjectForCode(code)
    if obj and n then obj.AcquiredCount = n end
end

local function clear_section(path)
    local obj = path and Tracker:FindObjectForCode(path)
    if obj then obj.AvailableChestCount = 0 end
end

local function set_highlight(location_id, level)
    if not HINT_HIGHLIGHT then return end
    for _, path in ipairs(LOCATION_MAPPING[location_id] or {}) do
        local obj = Tracker:FindObjectForCode(path)
        if obj then obj.Highlight = level end
    end
end

local hinted = {}   -- location ids currently highlighted

-- Outline the locations in this world that hold hinted items.
local function apply_hints(hints)
    if not HINT_HIGHLIGHT or type(hints) ~= "table" then return end
    for id in pairs(hinted) do set_highlight(id, Highlight.None) end
    hinted = {}
    for _, hint in ipairs(hints) do
        if hint.finding_player == Archipelago.PlayerNumber then
            local level
            if hint.status ~= nil then
                level = HINT_HIGHLIGHT[hint.status] or Highlight.Unspecified
            else
                -- servers from before hint statuses: only "found" or not
                level = hint.found and Highlight.None or Highlight.Unspecified
            end
            set_highlight(hint.location, level)
            if level ~= Highlight.None then hinted[hint.location] = true end
        end
    end
end

local function reset_section(path)
    local obj = Tracker:FindObjectForCode(path)
    if obj then obj.AvailableChestCount = obj.ChestCount end
end

-- Copy the seed's options from slot_data into the setting items, so the
-- visibility rules and logic match the seed. World versions without
-- slot_data leave the settings as the player set them.
local function apply_slot_data(slot_data)
    if slot_data == nil or slot_data.stage_exits == nil then
        SLOT.stage_exits = nil
        SLOT.warp_list = nil
        print("CV64 tracker: no slot_data from this world version - set the options in the Settings panel")
        return
    end

    SLOT.stage_exits = slot_data.stage_exits
    SLOT.warp_list = slot_data.warp_list

    set_toggle("setting_hard_logic", truthy(slot_data.hard_logic))
    set_toggle("setting_carrie_logic", truthy(slot_data.carrie_logic))
    set_toggle("setting_multi_hit", truthy(slot_data.multi_hit_breakables))
    set_toggle("setting_empty", truthy(slot_data.empty_breakables))
    set_toggle("setting_lizard_lockers", truthy(slot_data.lizard_locker_items))
    set_toggle("setting_shopsanity", truthy(slot_data.shopsanity))
    set_toggle("setting_open_stages", false)  -- the real stage order is known now
    set_stage("subweapons", slot_data.sub_weapon_shuffle)
    set_stage("characters", slot_data.character_stages)
    set_stage("goal", slot_data.draculas_condition)
    set_count("special1s_per_warp", slot_data.special1s_per_warp)

    local goal = slot_data.draculas_condition
    if goal == 2 then
        set_count("goal_count", slot_data.bosses_required)
    elseif goal == 3 then
        set_count("goal_count", slot_data.special2s_required)
    else
        set_count("goal_count", 0)
    end

    -- Print the stage order to the console, useful with stage shuffle.
    if SLOT.warp_list then
        local names = {}
        for i, stage in ipairs(SLOT.warp_list) do
            names[#names + 1] = (i == 1 and "Start: " or ("Warp " .. (i - 1) .. ": ")) .. stage
        end
        print("CV64 tracker: " .. table.concat(names, ", "))
    end
end

function onClear(slot_data)
    CUR_INDEX = -1

    -- every map section back to unchecked, with no hint outline
    for id, paths in pairs(LOCATION_MAPPING) do
        for _, path in ipairs(paths) do reset_section(path) end
        if HINT_HIGHLIGHT then set_highlight(id, Highlight.None) end
    end
    hinted = {}
    for _, boss in ipairs(BOSS_EVENTS) do reset_section(boss.section) end
    reset_section(CRYSTAL_SECTION)
    reset_section(GOAL_SECTION)

    -- every tracked item back to none
    for _, v in pairs(ITEM_MAPPING) do
        if v[2] == "toggle" then set_toggle(v[1], false)
        elseif v[2] == "consumable" then set_count(v[1], 0) end
    end
    set_toggle("crystal", false)
    set_count("trophy", 0)

    apply_slot_data(slot_data)
    SLOT_GENERATION = SLOT_GENERATION + 1

    if Archipelago.PlayerNumber and Archipelago.PlayerNumber > 0 then
        local keys = { map_key(), events_key(), hints_key() }
        Archipelago:SetNotify(keys)
        Archipelago:Get(keys)
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then return end
    CUR_INDEX = index
    local v = ITEM_MAPPING[item_id]
    if not v then return end
    local obj = Tracker:FindObjectForCode(v[1])
    if not obj then return end
    if v[2] == "toggle" then
        obj.Active = true
    elseif v[2] == "consumable" then
        obj.AcquiredCount = obj.AcquiredCount + obj.Increment
    end
end

function onLocation(location_id, location_name)
    local paths = LOCATION_MAPPING[location_id]
    if not paths then return end
    for _, path in ipairs(paths) do clear_section(path) end
end

-- Boss kills and the Crystal, from the client's event bitfield.
local function apply_events(value)
    if type(value) ~= "number" then return end
    local defeated, n = {}, 0
    for i, flag in ipairs(EVENT_FLAG_ORDER) do
        if math.floor(value / 2 ^ (i - 1)) % 2 == 1 then
            if flag == "FLAG_ACTIVATED_CRYSTAL" then
                set_toggle("crystal", true)
                clear_section(CRYSTAL_SECTION)
            elseif EVENT_FLAG_BOSS[flag] and not defeated[EVENT_FLAG_BOSS[flag]] then
                -- EVENT_FLAG_BOSS (world_data.lua) maps the flag to the boss's map section
                defeated[EVENT_FLAG_BOSS[flag]] = true
                n = n + 1
                clear_section(EVENT_FLAG_BOSS[flag])
            end
        end
    end
    set_count("trophy", n)
end

-- Switch to the tab of the stage the player just entered.
local function apply_map(value)
    if not AUTO_SWITCH_TABS or type(value) ~= "number" then return end
    local path = MAP_ID_TABS[value]
    if not path then return end
    for _, tab in ipairs(path) do
        Tracker:UiHint("ActivateTab", tab)
    end
end

local function onDataStorage(key, value)
    if key == map_key() then
        apply_map(value)
    elseif key == events_key() then
        apply_events(value)
    elseif key == hints_key() then
        apply_hints(value)
    end
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddRetrievedHandler("retrieved handler", onDataStorage)
Archipelago:AddSetReplyHandler("set reply handler", function(key, value, old) onDataStorage(key, value) end)
