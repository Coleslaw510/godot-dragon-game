extends Node

var _failures := PackedStringArray()
var _checks := 0
var _saved_dragon_file: Variant
var _saved_dragon_state: Dictionary

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_saved_dragon_file = FileAccess.get_file_as_bytes(DragonState.SAVE_PATH) if FileAccess.file_exists(DragonState.SAVE_PATH) else null
	_saved_dragon_state = DragonState.state.duplicate(true)
	_check(ResourceLoader.exists("res://scenes/main.tscn"), "main scene must load")
	_check(ResourceLoader.exists("res://assets/dragon_tales/runtime/island/frame_00.png"), "starter island runtime art must exist")
	_check(ResourceLoader.exists("res://assets/dragon_tales/runtime/buildings/hatchery.png"), "hatchery runtime art must exist")
	_check(ResourceLoader.exists("res://assets/dragon_tales/runtime/dragons/blaze/idle_00.png"), "dragon runtime art must exist")
	_check(DragonCatalog.DRAGONS.size() == 10, "catalog must expose ten base dragons")
	_check(DragonCatalog.ids().has("twinkle"), "catalog must include the Star dragon")
	_check(DragonState.has_dragon("blaze"), "fresh state must include the starter dragon")

	var packed: PackedScene = load("res://scenes/main.tscn")
	var instance := packed.instantiate()
	get_tree().root.add_child(instance)
	await get_tree().process_frame
	_check(instance.get("_screen") == "title", "game must boot on the title screen")
	_check(bool((instance.get("_title_layer") as Control).visible), "title layer must be visible on boot")
	instance.call("_show_game")
	await get_tree().process_frame
	_check(bool((instance.get("_game_layer") as Control).visible), "start must open the island view")
	_check(instance.get("_island_frames").size() == 6, "island must load all six supplied animation frames")
	_check((instance.get("_content") as Control).get_child_count() >= 5, "island must contain management anchors")

	var initial_food := int(DragonState.state.food)
	DragonState.harvest()
	_check(int(DragonState.state.food) == initial_food + 5, "harvesting must increase food")
	_check(bool(DragonState.state.achievements.first_harvest), "harvesting must complete its achievement")
	var egg := DragonState.start_breeding("blaze", "tide")
	_check(egg == "blaze", "base breeding must produce a deterministic first-prototype egg")
	_check(str(DragonState.state.pending_egg) == "blaze", "breeding must place an egg in the hatchery")
	_check(DragonState.hatch() == "blaze", "hatching must return the pending dragon")
	DragonState.discover("pebble")
	_check(bool(DragonState.state.achievements.collector_3), "discovering three dragons must complete the collection achievement")
	DragonState.mark_battle_complete()
	_check(bool(DragonState.state.achievements.first_battle), "battle completion must persist its achievement")

	instance.queue_free()
	await get_tree().process_frame
	_restore_dragon_state()
	if _failures.is_empty():
		print("[dragon-tales-tests] PASS: %d checks" % _checks)
		get_tree().quit(0)
		return
	for failure: String in _failures:
		push_error("[dragon-tales-tests] " + failure)
	print("[dragon-tales-tests] FAIL: %d failures across %d checks" % [_failures.size(), _checks])
	get_tree().quit(1)

func _restore_dragon_state() -> void:
	DragonState.state = _saved_dragon_state.duplicate(true)
	if _saved_dragon_file == null:
		if FileAccess.file_exists(DragonState.SAVE_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(DragonState.SAVE_PATH))
		return
	var file := FileAccess.open(DragonState.SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_buffer(_saved_dragon_file)
		file.close()

func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
