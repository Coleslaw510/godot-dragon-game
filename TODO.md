# Dragon Tales TODO

## 1. Replace the generic starter with the Dragon Tales launch flow

- The title screen identifies the game as **Dragon Tales**.
- Starting the game opens a landscape-oriented island management view rather than the inherited maze/chase game.
- The first view has a clear island, readable controls, a compact resource/status strip, and no event calendar, promotion stack, monetization prompt, or forced popup.
- The game retains a usable pause/restart or return-to-title path and can recover from a fresh launch.

## 2. Integrate the supplied Dragon Tales art package

- The original uploaded sheets remain preserved as source assets.
- The game uses the supplied starter-island frames, ten dragon sheets, ten habitat assets, ten base-element egg assets, hatchery, food farm, and breeding corral.
- Dragon sheets are interpreted as four animation rows—idle, walk, fly, and action—with six frames per row.
- Presentation-sheet labels, grid lines, and opaque background clutter are not visible in the runtime crops used by the game.
- No generated replacement art is added.

## 3. Implement the ten base dragons and collection view

- The ten base elements are Fire, Water, Earth, Air, Lightning, Plant, Ice, Light, Metal, and Star.
- The named base dragons are Blaze, Tide, Pebble, Breeze, Spark, Fern, Frost, Gleam, Rivet, and Twinkle respectively.
- A collection view shows which base dragons are discovered and provides a readable selection for feeding, breeding, and battle.
- The view can be opened and closed without losing island state.

## 4. Implement the food farm and feeding loop

- The food farm has a visible harvest action.
- Harvesting increases the player's food resource and gives one concise status response.
- A selected dragon can be fed when food is available.
- Feeding consumes food, increases dragon progress/level, and persists after saving.
- The initial economy remains small and understandable; no energy system or ad-gated action is introduced.

## 5. Implement breeding, eggs, and hatching

- The breeding corral can accept two selected dragons from the available collection.
- The first milestone supports base-element breeding outcomes and a readable egg result.
- The hatchery can hold the produced egg and expose a clear hatch/claim action.
- Hatching adds the resulting dragon to the collection and updates the island state.
- The ten supplied base-element eggs are used for the corresponding results.
- The system is data-driven so hybrid combinations can be added later without rewriting the main UI flow.

## 6. Implement achievements and the first battle prototype

- At least one achievement is visible and can be completed through normal play, such as collecting three dragons or harvesting food.
- Achievement progress persists locally and is readable from a dedicated compact view.
- A small battle prototype can be opened from the island using collected dragons.
- Battle actions, outcome, and reward are understandable and can be replayed without corrupting the island save.

## 7. Implement local persistence and clean recovery

- The game automatically saves meaningful state changes to a versioned local save file.
- A fresh launch restores food, dragon discovery, dragon levels, achievements, and hatchery/breeding state.
- Invalid or incompatible save data falls back safely to a new default state.
- Future accounts, friend visits, and coin gifts are not required for this milestone and are not silently provisioned.

## 8. Prepare the public repository workflow

- The project is prepared for a public repository named `godot-dragon-game`.
- The repository contains source, data, documentation, and redistributable supplied assets only.
- Apple signing certificates, provisioning profiles, API keys, credentials, and private account material are excluded.
- The first saved version is labeled as an incomplete but playable prototype if later systems remain unfinished.
