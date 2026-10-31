--
-- The world's region graph, read by scripts/logic/logic.lua:
--   REGIONS[name].exits  = list of { to = region } or { link = "next"|"alt"|"prev", stage = name }
--                          with an optional item rule and option conditions ("hard", "not hard",
--                          "carrie", "shopsanity"), as in the world's entrances.py.
--   STAGES[name]         = the stage's start / mid (warp) / end regions and its character, if any.

STAGE_ORDER = {
    "Forest of Silence",
    "Castle Wall",
    "Villa",
    "Tunnel",
    "Underground Waterway",
    "Castle Center",
    "Duel Tower",
    "Tower of Execution",
    "Tower of Science",
    "Tower of Sorcery",
    "Room of Clocks",
    "Clock Tower",
    "Castle Keep",
}

-- Stage links before any shuffling, for when the server sends no stage order.
VANILLA_STAGE_EXITS = {
    ["Forest of Silence"] = {
        next = "Castle Wall",
    },
    ["Castle Wall"] = {
        next = "Villa",
    },
    Villa = {
        next = "Tunnel",
        alt = "Underground Waterway",
    },
    Tunnel = {
        next = "Castle Center",
    },
    ["Underground Waterway"] = {
        next = "Castle Center",
    },
    ["Castle Center"] = {
        next = "Duel Tower",
        alt = "Tower of Science",
    },
    ["Duel Tower"] = {
        prev = "Castle Center",
        next = "Tower of Execution",
    },
    ["Tower of Execution"] = {
        prev = "Duel Tower",
        next = "Room of Clocks",
    },
    ["Tower of Science"] = {
        prev = "Castle Center",
        next = "Tower of Sorcery",
    },
    ["Tower of Sorcery"] = {
        prev = "Tower of Science",
        next = "Room of Clocks",
    },
    ["Room of Clocks"] = {
        next = "Clock Tower",
    },
    ["Clock Tower"] = {
        next = "Castle Keep",
    },
    ["Castle Keep"] = {},
}

STAGES = {
    ["Forest of Silence"] = {
        start = "Forest of Silence: first half",
        mid = "Forest of Silence: second half",
        ["end"] = "Forest of Silence: end area",
    },
    ["Castle Wall"] = {
        start = "Castle Wall: main area",
        mid = "Castle Wall: main area",
        ["end"] = "Castle Wall: exit room",
    },
    Villa = {
        start = "Villa: dog gates",
        mid = "Villa: storeroom",
        ["end"] = "Villa: crypt",
    },
    Tunnel = {
        start = "Tunnel: first half",
        mid = "Tunnel: second half",
        ["end"] = "Tunnel: second half",
        character = "Reinhardt",
    },
    ["Underground Waterway"] = {
        start = "Underground Waterway: main area",
        mid = "Underground Waterway: main area",
        ["end"] = "Underground Waterway: end",
        character = "Carrie",
    },
    ["Castle Center"] = {
        start = "Castle Center: main area",
        mid = "Castle Center: main area",
        ["end"] = "Castle Center: elevator top",
    },
    ["Duel Tower"] = {
        start = "Duel Tower",
        mid = "Duel Tower",
        ["end"] = "Duel Tower",
        character = "Reinhardt",
    },
    ["Tower of Execution"] = {
        start = "Tower of Execution: main area",
        mid = "Tower of Execution: main area",
        ["end"] = "Tower of Execution: main area",
        character = "Reinhardt",
    },
    ["Tower of Science"] = {
        start = "Tower of Science: turret lab",
        mid = "Tower of Science: spiky conveyors",
        ["end"] = "Tower of Science: spiky conveyors",
        character = "Carrie",
    },
    ["Tower of Sorcery"] = {
        start = "Tower of Sorcery",
        mid = "Tower of Sorcery",
        ["end"] = "Tower of Sorcery",
        character = "Carrie",
    },
    ["Room of Clocks"] = {
        start = "Room of Clocks",
        mid = "Room of Clocks",
        ["end"] = "Room of Clocks",
    },
    ["Clock Tower"] = {
        start = "Clock Tower: start",
        mid = "Clock Tower: middle",
        ["end"] = "Clock Tower: end",
    },
    ["Castle Keep"] = {
        start = "Castle Keep: exterior",
        mid = "Castle Keep: exterior",
        ["end"] = "Castle Keep: Dracula's chamber",
    },
}

REGIONS = {
    ["Forest of Silence: first half"] = {
        stage = "Forest of Silence",
        exits = {
            {
                name = "Descending bridge gate",
                to = "Forest of Silence: second half",
            },
        },
    },
    ["Forest of Silence: second half"] = {
        stage = "Forest of Silence",
        exits = {
            {
                name = "Werewolf gate",
                to = "Forest of Silence: end area",
            },
        },
    },
    ["Forest of Silence: end area"] = {
        stage = "Forest of Silence",
        exits = {
            {
                name = "Dracula's drawbridge",
                link = "next",
                stage = "Forest of Silence",
            },
        },
    },
    ["Castle Wall: main area"] = {
        stage = "Castle Wall",
        exits = {
            {
                name = "Central portcullis",
                to = "Castle Wall: exit room",
            },
            {
                name = "Do Left Tower Skip",
                conds = { "hard" },
                link = "next",
                stage = "Castle Wall",
            },
            {
                name = "Left Tower door",
                rule = "left_tower_key",
                to = "Castle Wall: left tower",
            },
        },
    },
    ["Castle Wall: exit room"] = {
        stage = "Castle Wall",
        exits = {},
    },
    ["Castle Wall: left tower"] = {
        stage = "Castle Wall",
        exits = {
            {
                name = "End portcullis",
                link = "next",
                stage = "Castle Wall",
            },
        },
    },
    ["Villa: dog gates"] = {
        stage = "Villa",
        exits = {
            {
                name = "Front dog gates",
                to = "Villa: main interior",
            },
        },
    },
    ["Villa: main interior"] = {
        stage = "Villa",
        exits = {
            {
                name = "Orb snipe the dogs",
                conds = { "carrie", "hard" },
                to = "Villa: dog gates",
            },
            {
                name = "Villa contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
            {
                name = "To Storeroom door",
                rule = "storeroom_key",
                to = "Villa: storeroom",
            },
            {
                name = "To Archives door",
                rule = "archives_key",
                to = "Villa: archives",
            },
            {
                name = "To maze gate",
                rule = "garden_key",
                to = "Villa: maze",
            },
        },
    },
    ["Villa: storeroom"] = {
        stage = "Villa",
        exits = {
            {
                name = "From Storeroom door",
                rule = "storeroom_key",
                to = "Villa: main interior",
            },
        },
    },
    ["Villa: archives"] = {
        stage = "Villa",
        exits = {},
    },
    ["Villa: maze"] = {
        stage = "Villa",
        exits = {
            {
                name = "From maze gate",
                rule = "garden_key",
                to = "Villa: servants entrance",
            },
            {
                name = "Copper door",
                rule = "copper_key",
                conds = { "not hard" },
                to = "Villa: crypt",
            },
            {
                name = "Get Copper Skip",
                conds = { "hard" },
                to = "Villa: crypt",
            },
        },
    },
    ["Villa: servants entrance"] = {
        stage = "Villa",
        exits = {
            {
                name = "Servants' door",
                to = "Villa: main interior",
            },
        },
    },
    ["Villa: crypt"] = {
        stage = "Villa",
        exits = {
            {
                name = "From bridge door",
                to = "Villa: maze",
            },
            {
                name = "Villa Reinhardt (daytime) exit",
                link = "next",
                stage = "Villa",
            },
            {
                name = "Villa Carrie (nighttime) exit",
                link = "alt",
                stage = "Villa",
            },
        },
    },
    ["Tunnel: first half"] = {
        stage = "Tunnel",
        exits = {
            {
                name = "Tunnel start contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
            {
                name = "Gondola ride",
                to = "Tunnel: second half",
            },
        },
    },
    ["Tunnel: second half"] = {
        stage = "Tunnel",
        exits = {
            {
                name = "Tunnel end contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
            {
                name = "End Tunnel door",
                link = "next",
                stage = "Tunnel",
            },
        },
    },
    ["Underground Waterway: main area"] = {
        stage = "Underground Waterway",
        exits = {
            {
                name = "Final waterfall",
                to = "Underground Waterway: end",
            },
            {
                name = "Underground Waterway contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
        },
    },
    ["Underground Waterway: end"] = {
        stage = "Underground Waterway",
        exits = {
            {
                name = "Do Waterfall Skip",
                conds = { "hard" },
                to = "Underground Waterway: main area",
            },
            {
                name = "End Waterway door",
                link = "next",
                stage = "Underground Waterway",
            },
        },
    },
    ["Castle Center: main area"] = {
        stage = "Castle Center",
        exits = {
            {
                name = "Torture Chamber door",
                rule = "chamber_key",
                to = "Castle Center: torture chamber",
            },
            {
                name = "Lower sealed cracked wall",
                rule = "bomb2",
                to = "Castle Center: big crystal",
            },
            {
                name = "Castle Center contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
            {
                name = "Upper cracked wall",
                rule = "bomb1",
                to = "Castle Center: library",
            },
        },
    },
    ["Castle Center: torture chamber"] = {
        stage = "Castle Center",
        exits = {},
    },
    ["Castle Center: library"] = {
        stage = "Castle Center",
        exits = {},
    },
    ["Castle Center: big crystal"] = {
        stage = "Castle Center",
        exits = {
            {
                name = "Activate crystal and ride elevator",
                to = "Castle Center: elevator top",
            },
        },
    },
    ["Castle Center: elevator top"] = {
        stage = "Castle Center",
        exits = {
            {
                name = "Castle Center Reinhardt (Medusa Head) exit",
                link = "next",
                stage = "Castle Center",
            },
            {
                name = "Castle Center Carrie (Ghost) exit",
                link = "alt",
                stage = "Castle Center",
            },
        },
    },
    ["Duel Tower"] = {
        stage = "Duel Tower",
        exits = {
            {
                name = "Duel Tower start passage",
                link = "prev",
                stage = "Duel Tower",
            },
            {
                name = "Duel Tower end passage",
                link = "next",
                stage = "Duel Tower",
            },
        },
    },
    ["Tower of Execution: main area"] = {
        stage = "Tower of Execution",
        exits = {
            {
                name = "Tower of Execution start passage",
                link = "prev",
                stage = "Tower of Execution",
            },
            {
                name = "Execution gate",
                rule = "execution_key",
                conds = { "not hard" },
                to = "Tower of Execution: gated ledge",
            },
            {
                name = "Just jump past the gate from above, bro!",
                conds = { "hard" },
                to = "Tower of Execution: gated ledge",
            },
            {
                name = "Tower of Execution end staircase",
                link = "next",
                stage = "Tower of Execution",
            },
        },
    },
    ["Tower of Execution: gated ledge"] = {
        stage = "Tower of Execution",
        exits = {},
    },
    ["Tower of Science: turret lab"] = {
        stage = "Tower of Science",
        exits = {
            {
                name = "Tower of Science start passage",
                link = "prev",
                stage = "Tower of Science",
            },
            {
                name = "Science Door 1",
                rule = "science_key1",
                to = "Tower of Science: locked key1 room",
            },
            {
                name = "To Science Door 2",
                rule = "science_key2",
                to = "Tower of Science: spiky conveyors",
            },
        },
    },
    ["Tower of Science: locked key1 room"] = {
        stage = "Tower of Science",
        exits = {},
    },
    ["Tower of Science: spiky conveyors"] = {
        stage = "Tower of Science",
        exits = {
            {
                name = "From Science Door 2",
                rule = "science_key2",
                to = "Tower of Science: turret lab",
            },
            {
                name = "Science Door 3",
                rule = "science_key3",
                to = "Tower of Science: locked key3 room",
            },
            {
                name = "Tower of Science end passage",
                link = "next",
                stage = "Tower of Science",
            },
        },
    },
    ["Tower of Science: locked key3 room"] = {
        stage = "Tower of Science",
        exits = {},
    },
    ["Tower of Sorcery"] = {
        stage = "Tower of Sorcery",
        exits = {
            {
                name = "Tower of Sorcery start passage",
                link = "prev",
                stage = "Tower of Sorcery",
            },
            {
                name = "Tower of Sorcery end passage",
                link = "next",
                stage = "Tower of Sorcery",
            },
        },
    },
    ["Room of Clocks"] = {
        stage = "Room of Clocks",
        exits = {
            {
                name = "Defeat boss gate",
                link = "next",
                stage = "Room of Clocks",
            },
        },
    },
    ["Clock Tower: start"] = {
        stage = "Clock Tower",
        exits = {
            {
                name = "To Clocktower Door 1",
                rule = "clocktower_key1",
                to = "Clock Tower: middle",
            },
        },
    },
    ["Clock Tower: middle"] = {
        stage = "Clock Tower",
        exits = {
            {
                name = "From Clocktower Door 1",
                rule = "clocktower_key1",
                to = "Clock Tower: start",
            },
            {
                name = "To Clocktower Door 2",
                rule = "clocktower_key2",
                to = "Clock Tower: end",
            },
        },
    },
    ["Clock Tower: end"] = {
        stage = "Clock Tower",
        exits = {
            {
                name = "From Clocktower Door 2",
                rule = "clocktower_key2",
                to = "Clock Tower: middle",
            },
            {
                name = "Clock Tower contract",
                conds = { "shopsanity" },
                to = "Renon's shop",
            },
            {
                name = "Clocktower Door 3",
                rule = "clocktower_key3",
                link = "next",
                stage = "Clock Tower",
            },
        },
    },
    ["Castle Keep: exterior"] = {
        stage = "Castle Keep",
        exits = {
            {
                name = "Slope Jump to boss tower",
                conds = { "hard" },
                to = "Room of Clocks",
            },
            {
                name = "Dracula's door",
                rule = "dracula",
                to = "Castle Keep: Dracula's chamber",
            },
        },
    },
    ["Renon's shop"] = {
        exits = {},
    },
    ["Castle Keep: Dracula's chamber"] = {
        exits = {},
    },
}

-- Region holding the Crystal for Dracula's "Crystal" condition.
CRYSTAL_REGION = "Castle Center: big crystal"
RENON_REGION = "Renon's shop"

-- Boss kills that count as trophies for Dracula's "Bosses" condition.
BOSS_EVENTS = {
    {
        location = "Forest of Silence: King Skeleton 1",
        region = "Forest of Silence: first half",
        section = "@Forest of Silence: King Skeleton 1/Defeated",
    },
    {
        location = "Forest of Silence: Were-tiger",
        region = "Forest of Silence: first half",
        section = "@Forest of Silence: Were-tiger/Defeated",
    },
    {
        location = "Forest of Silence: King Skeleton 2",
        region = "Forest of Silence: end area",
        section = "@Forest of Silence: King Skeleton 2/Defeated",
    },
    {
        location = "Castle Wall: Bone Dragons",
        region = "Castle Wall: main area",
        section = "@Castle Wall: Bone Dragons/Defeated",
    },
    {
        location = "Villa: J. A. Oldrey",
        region = "Villa: crypt",
        section = "@Villa: J. A. Oldrey/Defeated",
    },
    {
        location = "Villa: Undead Maiden",
        region = "Villa: crypt",
        section = "@Villa: Undead Maiden/Defeated",
    },
    {
        location = "Underground Waterway: Lizard-man trio",
        region = "Underground Waterway: main area",
        section = "@Underground Waterway: Lizard-man trio/Defeated",
    },
    {
        location = "Castle Center: Behemoth",
        region = "Castle Center: big crystal",
        section = "@Castle Center: Behemoth/Defeated",
    },
    {
        location = "Castle Center: Rosa/Camilla",
        region = "Castle Center: big crystal",
        section = "@Castle Center: Rosa or Camilla/Defeated",
    },
    {
        location = "Duel Tower: Were-jaguar",
        region = "Duel Tower",
        section = "@Duel Tower: Were-jaguar/Defeated",
    },
    {
        location = "Duel Tower: Werewolf",
        region = "Duel Tower",
        section = "@Duel Tower: Werewolf/Defeated",
    },
    {
        location = "Duel Tower: Were-bull",
        region = "Duel Tower",
        section = "@Duel Tower: Were-bull/Defeated",
    },
    {
        location = "Duel Tower: Were-tiger",
        region = "Duel Tower",
        section = "@Duel Tower: Were-tiger/Defeated",
    },
    {
        location = "Room of Clocks: Death/Actrise",
        region = "Room of Clocks",
        section = "@Room of Clocks: Death or Actrise/Defeated",
    },
    {
        location = "Castle Keep: Renon",
        region = "Castle Keep: exterior",
        section = "@Castle Keep: Renon/Defeated",
    },
    {
        location = "Castle Keep: Vincent",
        region = "Castle Keep: exterior",
        section = "@Castle Keep: Vincent/Defeated",
    },
}

-- Map sections for the Crystal and for beating Dracula (not AP locations, so not in LOCATION_MAPPING).
CRYSTAL_SECTION = "@Castle Center: Behind the seal/Activated"
GOAL_SECTION = "@Dracula/Defeated"

-- Bit order of the client's castlevania_64_events_<team>_<slot> data storage value.
EVENT_FLAG_ORDER = {
    "FLAG_ACTIVATED_CRYSTAL",
    "FLAG_DEFEATED_KING_SKELETON_1",
    "FLAG_DEFEATED_FOREST_WERE_TIGER",
    "FLAG_DEFEATED_KING_SKELETON_2",
    "FLAG_DEFEATED_WHITE_DRAGONS",
    "FLAG_DEFEATED_JA_OLDREY",
    "FLAG_DEFEATED_UNDEAD_MAIDEN",
    "FLAG_DEFEATED_LIZARD_MEN_TRIO",
    "FLAG_DEFEATED_BEHEMOTH",
    "FLAG_DEFEATED_ROSA",
    "FLAG_DEFEATED_CAMILLA",
    "FLAG_DEFEATED_WERE_JAGUAR",
    "FLAG_DEFEATED_WEREWOLF",
    "FLAG_DEFEATED_WERE_BULL",
    "FLAG_DEFEATED_DUEL_TOWER_WERE_TIGER",
    "FLAG_DEFEATED_DEATH",
    "FLAG_DEFEATED_ACTRISE",
    "FLAG_DEFEATED_RENON",
    "FLAG_DEFEATED_VINCENT",
}

-- Boss kill event flag -> the boss's map section (Rosa/Camilla and Death/Actrise share one).
EVENT_FLAG_BOSS = {
    FLAG_DEFEATED_KING_SKELETON_1 = "@Forest of Silence: King Skeleton 1/Defeated",
    FLAG_DEFEATED_FOREST_WERE_TIGER = "@Forest of Silence: Were-tiger/Defeated",
    FLAG_DEFEATED_KING_SKELETON_2 = "@Forest of Silence: King Skeleton 2/Defeated",
    FLAG_DEFEATED_WHITE_DRAGONS = "@Castle Wall: Bone Dragons/Defeated",
    FLAG_DEFEATED_JA_OLDREY = "@Villa: J. A. Oldrey/Defeated",
    FLAG_DEFEATED_UNDEAD_MAIDEN = "@Villa: Undead Maiden/Defeated",
    FLAG_DEFEATED_LIZARD_MEN_TRIO = "@Underground Waterway: Lizard-man trio/Defeated",
    FLAG_DEFEATED_BEHEMOTH = "@Castle Center: Behemoth/Defeated",
    FLAG_DEFEATED_ROSA = "@Castle Center: Rosa or Camilla/Defeated",
    FLAG_DEFEATED_CAMILLA = "@Castle Center: Rosa or Camilla/Defeated",
    FLAG_DEFEATED_WERE_JAGUAR = "@Duel Tower: Were-jaguar/Defeated",
    FLAG_DEFEATED_WEREWOLF = "@Duel Tower: Werewolf/Defeated",
    FLAG_DEFEATED_WERE_BULL = "@Duel Tower: Were-bull/Defeated",
    FLAG_DEFEATED_DUEL_TOWER_WERE_TIGER = "@Duel Tower: Were-tiger/Defeated",
    FLAG_DEFEATED_DEATH = "@Room of Clocks: Death or Actrise/Defeated",
    FLAG_DEFEATED_ACTRISE = "@Room of Clocks: Death or Actrise/Defeated",
    FLAG_DEFEATED_RENON = "@Castle Keep: Renon/Defeated",
    FLAG_DEFEATED_VINCENT = "@Castle Keep: Vincent/Defeated",
}

-- In-game map id -> stage.
MAP_ID_STAGE = {
    [0] = "Forest of Silence",
    [1] = "Castle Wall",
    [2] = "Castle Wall",
    [3] = "Villa",
    [4] = "Villa",
    [5] = "Villa",
    [6] = "Villa",
    [7] = "Tunnel",
    [8] = "Underground Waterway",
    [9] = "Castle Center",
    [10] = "Castle Center",
    [11] = "Castle Center",
    [12] = "Castle Center",
    [13] = "Castle Center",
    [14] = "Castle Center",
    [15] = "Castle Center",
    [16] = "Tower of Execution",
    [17] = "Tower of Sorcery",
    [18] = "Tower of Science",
    [19] = "Duel Tower",
    [20] = "Castle Keep",
    [21] = "Castle Keep",
    [23] = "Clock Tower",
    [24] = "Castle Keep",
    [25] = "Castle Center",
    [26] = "Villa",
    [27] = "Room of Clocks",
}

-- In-game map id -> the tracker tabs to activate (outer tab first), for
-- switching to where the player is. Matches layouts/map_tabs.json.
MAP_ID_TABS = {
    [0] = { "Forest of Silence" },
    [2] = { "Castle Wall" },
    [1] = { "Castle Wall" },
    [3] = { "Villa", "Yard" },
    [4] = { "Villa", "Interior" },
    [5] = { "Villa", "Interior" },
    [6] = { "Villa", "Garden Maze" },
    [26] = { "Villa", "Crypt" },
    [7] = { "Tunnel & Waterway", "Tunnel" },
    [8] = { "Tunnel & Waterway", "Waterway" },
    [9] = { "Castle Center", "Basement" },
    [10] = { "Castle Center", "Elevator" },
    [15] = { "Castle Center", "Elevator" },
    [11] = { "Castle Center", "Lizard Lab" },
    [12] = { "Castle Center", "Library" },
    [13] = { "Castle Center", "Library" },
    [14] = { "Castle Center", "Inventions" },
    [25] = { "Castle Center", "Inventions" },
    [19] = { "Towers", "Duel Tower" },
    [16] = { "Towers", "Tower of Execution" },
    [18] = { "Towers", "Tower of Science" },
    [17] = { "Towers", "Tower of Sorcery" },
    [27] = { "Clocks", "Room of Clocks" },
    [23] = { "Clocks", "Clock Tower" },
    [20] = { "Castle Keep" },
    [21] = { "Castle Keep" },
}
