-- Castlevania 64 logic
--
-- The AP world describes CV64 as a graph of regions joined by entrances, and
-- each check belongs to one region
--
-- On top of the plain graph the world adds:
--   * Stage order: each stage's end leads to the start of the next stage in
--     the seed's order (stage shuffle), and some stages lead back to the end
--     of the previous one. The order comes from slot_data, or the vanilla
--     order for the chosen character setting when there is no slot_data.
--   * Warps: from the menu, warp N goes to the middle of a stage once you have
--     N x "Special1s per warp" Special1s.
--   * Dracula's door: needs the Crystal, enough boss kills or enough
--     Special2s, depending on Dracula's Condition.
--
-- Two walks are done per change of state: one with your logic settings, and
-- one that also allows the hard logic tricks. A region only reachable in the
-- second walk shows its pins as "sequence break" (yellow).

-- Filled in by scripts/autotracking/archipelago.lua from slot_data.
-- When nil, the settings items are used instead.
SLOT = {
    stage_exits = nil,  -- {[stage] = {prev = ..., next = ..., alt = ...}}
    warp_list = nil,    -- {starting stage, warp 1 stage, ..., warp 7 stage}
}
-- Bumped whenever SLOT changes so the cached walks are thrown away.
SLOT_GENERATION = 0

local function has(code)
    return Tracker:ProviderCountForCode(code) > 0
end

local function count(code)
    return Tracker:ProviderCountForCode(code)
end

-- Progressive settings: which stage they are on (0-based).
local function setting_stage(code)
    local obj = Tracker:FindObjectForCode(code)
    return obj and obj.CurrentStage or 0
end

-- Character Stages option values, matching the world's options.py.
local CHARACTERS_BOTH, CHARACTERS_BRANCHLESS, CHARACTERS_REINHARDT, CHARACTERS_CARRIE = 0, 1, 2, 3
-- Dracula's Condition option values.
local GOAL_NONE, GOAL_CRYSTAL, GOAL_BOSSES, GOAL_SPECIALS = 0, 1, 2, 3

-- ---------------------------------------------------------------------------
-- Stage order
-- ---------------------------------------------------------------------------

-- Is a character stage in this seed? Only matters without slot_data, where
-- it follows the Character Stages setting like the world's verify_character_stage.
local function character_allows(stage, characters)
    local who = STAGES[stage].character
    if who == "Reinhardt" then return characters ~= CHARACTERS_CARRIE end
    if who == "Carrie" then return characters ~= CHARACTERS_REINHARDT end
    return true
end

-- The vanilla stage links for a Character Stages setting, the same way the
-- world's get_normal_stage_exits builds them before any stage shuffle.
local vanilla_cache = {}
local function vanilla_exits(characters)
    if vanilla_cache[characters] then return vanilla_cache[characters] end
    local exits = {}
    for i, stage in ipairs(STAGE_ORDER) do
        if character_allows(stage, characters) then
            local v = VANILLA_STAGE_EXITS[stage]
            local e = { prev = v.prev, next = v.next, alt = v.alt }
            if characters ~= CHARACTERS_BOTH then
                -- no branching paths: everything follows one line
                if characters == CHARACTERS_CARRIE and e.alt ~= nil then
                    e.next = e.alt
                elseif characters == CHARACTERS_BRANCHLESS and i < #STAGE_ORDER then
                    e.next = STAGE_ORDER[i + 1]
                end
                e.alt = nil
            end
            exits[stage] = e
        end
    end
    vanilla_cache[characters] = exits
    return exits
end

local function current_exits()
    return SLOT.stage_exits or vanilla_exits(setting_stage("characters"))
end

-- Used by visibility rules: hides the checks of stages that are not in the seed.
function stage_active(stage)
    return current_exits()[stage] ~= nil
end

-- The region an entrance between stages leads to, or nil if it leads nowhere
-- (start of the line, or a stage that is not in the seed).
local function stage_link_target(exit, exits)
    local links = exits[exit.stage]
    if links == nil then return nil end
    local stage = links[exit.link]
    if type(stage) ~= "string" or STAGES[stage] == nil or exits[stage] == nil then return nil end
    if exit.link == "prev" then return STAGES[stage]["end"] end
    return STAGES[stage].start
end

-- ---------------------------------------------------------------------------
-- Entrance rules
-- ---------------------------------------------------------------------------

-- Number of trophies the walk has reached so far (boss kills are events in
-- the world, collected as soon as their region is reachable).
local function trophies(reached)
    local n = 0
    for _, boss in ipairs(BOSS_EVENTS) do
        if reached[boss.region] then n = n + 1 end
    end
    return n
end

local function can_open_dracula_door(reached)
    local goal = setting_stage("goal")
    local needed = count("goal_count")
    if goal == GOAL_CRYSTAL then
        return reached[CRYSTAL_REGION] or has("crystal")
    elseif goal == GOAL_BOSSES then
        return trophies(reached) >= needed
    elseif goal == GOAL_SPECIALS then
        return count("special2") >= needed
    end
    return true
end

local function rule_passes(rule, reached)
    if rule == nil then return true end
    if rule == "bomb1" then
        return count("magical_nitro") >= 1 and count("mandragora") >= 1
    elseif rule == "bomb2" then
        return count("magical_nitro") >= 2 and count("mandragora") >= 2
    elseif rule == "dracula" then
        return can_open_dracula_door(reached)
    end
    return has(rule)  -- a key
end

-- Option conditions on entrances ("add conds" in the world's entrances.py).
local function conds_pass(conds, hard)
    if conds == nil then return true end
    for _, c in ipairs(conds) do
        if c == "hard" and not hard then return false end
        if c == "not hard" and hard then return false end
        if c == "carrie" and not has("setting_carrie_logic") then return false end
        if c == "shopsanity" and not has("setting_shopsanity") then return false end
    end
    return true
end

-- Regions reachable straight from the menu: the starting stage and warps.
local function menu_regions(exits)
    local out = {}
    if has("setting_open_stages") then
        -- stage order unknown: treat every stage in the seed as enterable
        for stage in pairs(exits) do
            out[#out + 1] = STAGES[stage].start
            out[#out + 1] = STAGES[stage].mid
        end
        return out
    end

    local warps = SLOT.warp_list
    if warps and warps[1] then
        out[#out + 1] = STAGES[warps[1]].start
        local per_warp = count("special1s_per_warp")
        local s1 = count("special1")
        for i = 2, #warps do
            if STAGES[warps[i]] and s1 >= per_warp * (i - 1) then
                out[#out + 1] = STAGES[warps[i]].mid
            end
        end
    else
        -- no slot_data: the first stage in vanilla order, no known warps
        for _, stage in ipairs(STAGE_ORDER) do
            if exits[stage] then
                out[#out + 1] = STAGES[stage].start
                break
            end
        end
    end
    return out
end

-- Every region reachable with the current items. `hard` allows hard logic
-- entrances and drops the ones the world only uses without hard logic.
local function walk(hard)
    local exits = current_exits()
    local reached = {}
    for _, region in ipairs(menu_regions(exits)) do
        reached[region] = true
    end
    -- Keep sweeping until nothing new is found. A full sweep is cheap (under
    -- forty regions) and also picks up Dracula's door once enough bosses are in.
    repeat
        local found = false
        local list = {}
        for region in pairs(reached) do list[#list + 1] = region end
        for _, region in ipairs(list) do
            local info = REGIONS[region]
            if info then
                for _, exit in ipairs(info.exits) do
                    local target = exit.to or stage_link_target(exit, exits)
                    if target and not reached[target]
                            and conds_pass(exit.conds, hard)
                            and rule_passes(exit.rule, reached) then
                        reached[target] = true
                        found = true
                    end
                end
            end
        end
    until not found
    return reached
end

local STATE_CODES = {
    "archives_key", "left_tower_key", "storeroom_key", "garden_key", "copper_key", "chamber_key",
    "execution_key", "science_key1", "science_key2", "science_key3",
    "clocktower_key1", "clocktower_key2", "clocktower_key3",
    "magical_nitro", "mandragora", "special1", "special2", "crystal",
    "setting_hard_logic", "setting_carrie_logic", "setting_shopsanity", "setting_open_stages",
    "special1s_per_warp", "goal_count",
}

local cache_key, cache_normal, cache_hard = nil, nil, nil

local function state_key()
    local parts = { SLOT_GENERATION, setting_stage("characters"), setting_stage("goal") }
    for _, code in ipairs(STATE_CODES) do
        parts[#parts + 1] = count(code)
    end
    return table.concat(parts, ",")
end

local function walks()
    local key = state_key()
    if key ~= cache_key then
        cache_key = key
        local hard_setting = has("setting_hard_logic")
        cache_normal = walk(hard_setting)
        -- with hard logic already on there is nothing extra to show
        cache_hard = hard_setting and cache_normal or walk(true)
    end
    return cache_normal, cache_hard
end

-- Access rule for every pin: "^$reach|<region>".
-- Returns an AccessibilityLevel: Normal (green), SequenceBreak (yellow,
-- needs hard logic tricks) or None (red).
function reach(region)
    local normal, hard = walks()
    if normal[region] then return AccessibilityLevel.Normal end
    if hard[region] then return AccessibilityLevel.SequenceBreak end
    return AccessibilityLevel.None
end
