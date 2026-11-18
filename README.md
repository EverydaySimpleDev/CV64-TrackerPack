# Castlevania 64 AP Map Tracker

A [PopTracker](https://github.com/black-sliver/PopTracker) pack for the
[Castlevania 64 Archipelago randomizer](https://github.com/LiquidCat64/LiquidCatipelago/tree/CV64_tracker_stuff/worlds/cv64).

- Maps of every stage with all 352 AP locations, grouped into spots
- Logic created from the AP world: keys, Nitro/Mandragora walls, stage order,
  warps, Special1s per warp and Dracula's door condition
- Checks that need **Hard Logic** tricks show up yellow ("sequence break") when Hard Logic is off
- Archipelago autotracking for items and checks
- With a CV64 client that writes the tracker data storage keys: boss kills and the Crystal
  are tracked, and the tracker switches to the tab of the map you are on
- Hinted items: the pins of locations in your world that hold a hinted item get an
  outline in the hint's priority color (PopTracker 0.32.0 or newer)

## Install

Requires PopTracker 0.26.0 or newer.

Copy the pack zip, or the whole pack folder, into PopTracker's `packs` folder.

Then open PopTracker, click the folder icon and pick **Castlevania 64 AP Map Tracker**.

## Connecting to Archipelago

Click the **AP** button at the top and enter the server address, your slot name and the password (if any).

When the world sends its options (`slot_data`), the tracker sets everything up for the seed:
stage order, warps, which checks exist and Dracula's condition. The stage order and warps
are also printed to the PopTracker console and shown in the **Stage Order** panel.

Versions of the world that send no `slot_data` (such as the one in the main Archipelago
release) still autotrack items and checks, but the tracker cannot know the seed's options
or stage order. Set the options in the **Settings** panel and, if the seed uses Stage
Shuffle, fill in the **Stage Order** panel as you learn the order (see below).

## Reading the maps

Each tab shows one stage, or one part of a larger stage, drawn from the game's level
geometry. Each pin is a spot; checks right next to each other share a pin with a section
for each one. Renon's shop (Shopsanity only) has a pin on every contract scroll you can
open the shop from.

Pin colours: green = in logic, yellow = needs Hard Logic tricks, red = out of logic.

Checks that only exist with a setting on (multi-hit breakables, lizard lockers, sub-weapon
shuffle, ...) are hidden while that setting is off.

## Settings panel

| Setting                                                                                     | Meaning                                                                                                                                            |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hard Logic, Carrie Logic                                                                    | Same as the AP options. With Hard Logic off, hard-only checks show in yellow.                                                                      |
| Multi-hit Breakables, Empty Breakables, Lizard Locker Items, Shopsanity, Sub-weapon Shuffle | Which optional checks exist.                                                                                                                       |
| Character Stages                                                                            | Which character stages are in the seed (used without `slot_data`).                                                                                 |
| Dracula's Condition, NEED                                                                   | What opens Dracula's door, and how many bosses or Special2s it takes.                                                                              |
| S1 per Warp                                                                                 | Special1s needed per warp menu entry.                                                                                                              |
| Stage Shuffle                                                                               | Turn on if the seed uses Stage Shuffle. Stage links left at `?` in the Stage Order panel then lead nowhere instead of following the vanilla order. |
| Open Stages                                                                                 | Ignore the stage order and treat every stage as reachable. Off by default; turned off on connect when the stage order is known.                    |

All of these are set automatically from `slot_data` when it is available.

## Stage Order panel

Only needed with a world that sends no `slot_data`; otherwise it fills itself in on connect.
Click an icon to pick the next stage, right-click to go back; `?` means not known yet.

- **START, W1-W7**: copy these from the in-game warp menu, top to bottom. Each warp
  opens once you have that many times **S1 per Warp** Special1s and lands at the stage's
  warp point (for most stages, past a key door).
- **FoS>, CW>, ...**: the stage you reach by finishing that stage. **VIL'>** and
  **CC'>** are the Carrie path exits of Villa and Castle Center (only with branching
  Character Stages). Fill these in as you clear stages, or from the spoiler log.

The four towers (Duel Tower and the Towers of Execution, Science and Sorcery) can be left
backwards into the end of the stage before them; the tracker works that out from the
links you entered. With **Stage Shuffle** off, every link left at `?` follows the vanilla
order, so only the warp menu needs filling in.

The item grid also has **Crystal (activated)** and **Bosses defeated**. With a client that
writes the events key they are filled in automatically. For the Bosses condition the logic
counts the boss arenas you can reach, not the **Bosses defeated** counter.

## Credits

- Castlevania 64 AP world and client: Liquid Cat
