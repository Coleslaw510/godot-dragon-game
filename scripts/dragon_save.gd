extends Node

signal state_changed

const SAVE_PATH := "user://dragon_tales_save.json"
const TEMP_PATH := "user://dragon_tales_save.tmp"
const SAVE_VERSION := 1
const DragonCatalogType := preload("res://scripts/dragon_catalog.gd")

var state: Dictionary = {}

func _ready() -> void:
	_load()

func _default_state() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"food": 12,
		"coins": 250,
		"discovered": ["blaze", "tide"],
		"levels": {"blaze": 1, "tide": 1},
		"pending_egg": "",
		"achievements": {
			"first_harvest": false,
			"collector_3": false,
			"first_battle": false,
		},
	}

func _load() -> void:
	state = _default_state()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	var candidate: Dictionary = parsed
	if int(candidate.get("version", 0)) != SAVE_VERSION:
		return
	state.food = clampi(int(candidate.get("food", 12)), 0, 999999)
	state.coins = clampi(int(candidate.get("coins", 250)), 0, 999999999)
	state.discovered = _clean_ids(candidate.get("discovered", ["blaze", "tide"]))
	if state.discovered.is_empty():
		state.discovered = ["blaze"]
	state.levels = {}
	var levels: Variant = candidate.get("levels", {})
	if levels is Dictionary:
		for dragon_id: String in state.discovered:
			state.levels[dragon_id] = clampi(int(levels.get(dragon_id, 1)), 1, 99)
	state.pending_egg = str(candidate.get("pending_egg", "")) if str(candidate.get("pending_egg", "")) in DragonCatalogType.ids() else ""
	state.achievements = _clean_achievements(candidate.get("achievements", {}))

func _clean_ids(raw: Variant) -> Array:
	var result: Array = []
	if raw is Array:
		for value: Variant in raw:
			var dragon_id := str(value)
			if dragon_id in DragonCatalogType.ids() and dragon_id not in result:
				result.append(dragon_id)
	return result

func _clean_achievements(raw: Variant) -> Dictionary:
	var result := {"first_harvest": false, "collector_3": false, "first_battle": false}
	if raw is Dictionary:
		for key: String in result.keys():
			result[key] = bool(raw.get(key, false))
	return result

func save() -> bool:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state, "  "))
	file.close()
	var temporary := ProjectSettings.globalize_path(TEMP_PATH)
	var destination := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		var remove_error := DirAccess.remove_absolute(destination)
		if remove_error != OK:
			return false
	var result := DirAccess.rename_absolute(temporary, destination) == OK
	if result:
		state_changed.emit()
	return result

func has_dragon(dragon_id: String) -> bool:
	return dragon_id in state.discovered

func discover(dragon_id: String) -> bool:
	if dragon_id not in DragonCatalogType.ids():
		return false
	if dragon_id not in state.discovered:
		state.discovered.append(dragon_id)
		state.levels[dragon_id] = 1
		state.achievements.collector_3 = state.discovered.size() >= 3
		save()
		return true
	return false

func feed(dragon_id: String) -> bool:
	if not has_dragon(dragon_id) or int(state.food) < 2:
		return false
	state.food = maxi(0, int(state.food) - 2)
	state.levels[dragon_id] = clampi(int(state.levels.get(dragon_id, 1)) + 1, 1, 99)
	save()
	return true

func harvest() -> int:
	state.food = int(state.food) + 5
	state.coins = maxi(0, int(state.coins) + 10)
	state.achievements.first_harvest = true
	save()
	return 5

func start_breeding(parent_a: String, parent_b: String) -> String:
	if not has_dragon(parent_a) or not has_dragon(parent_b):
		return ""
	# Version 0.1 keeps the result deterministic: same-element pairs preserve
	# their element; different pairs use the first parent until hybrid tables land.
	var result := parent_a if parent_a == parent_b else parent_a
	state.pending_egg = result
	save()
	return result

func hatch() -> String:
	var result := str(state.pending_egg)
	if result.is_empty():
		return ""
	state.pending_egg = ""
	discover(result)
	save()
	return result

func mark_battle_complete() -> void:
	state.achievements.first_battle = true
	state.coins = int(state.coins) + 25
	save()
