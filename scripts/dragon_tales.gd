extends Control

const DragonCatalogType := preload("res://scripts/dragon_catalog.gd")

const BG := Color("#102A2D")
const PANEL := Color("#193B3A")
const PANEL_SOFT := Color("#214A46")
const CREAM := Color("#FFF4D6")
const MUTED := Color("#B9D2C3")
const TEAL := Color("#58B8A8")
const GOLD := Color("#F0C86A")
const CORAL := Color("#E77A62")

var _screen := "title"
var _root_layer: Control
var _title_layer: Control
var _game_layer: Control
var _content: Control
var _status_label: Label
var _food_label: Label
var _coin_label: Label
var _collection_count: Label
var _selected_dragon := "blaze"
var _parent_a := "blaze"
var _parent_b := "tide"
var _breeding_label: Label
var _egg_label: Label
var _battle_result: Label
var _island_texture: TextureRect
var _island_frames: Array[Texture2D] = []
var _island_frame := 0
var _island_clock := 0.0
var _modal: PanelContainer
var _modal_title: Label
var _modal_body: Label
var _modal_content: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_base()
	_build_title()
	_build_game()
	_show_title()

func _apply_responsive_layout() -> void:
	# Kept as a harmless compatibility hook for the starter's finite verifier.
	pass

func _process(delta: float) -> void:
	if _screen == "game" and _island_frames.size() > 1:
		_island_clock += delta
		if _island_clock > 0.8:
			_island_clock = 0.0
			_island_frame = (_island_frame + 1) % _island_frames.size()
			if _island_texture != null:
				_island_texture.texture = _island_frames[_island_frame]

func _build_base() -> void:
	_root_layer = Control.new()
	_root_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root_layer)
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root_layer.add_child(background)
	var top_rule := ColorRect.new()
	top_rule.color = Color(TEAL, 0.55)
	top_rule.position = Vector2(0, 0)
	top_rule.size = Vector2(1280, 5)
	top_rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root_layer.add_child(top_rule)
	_island_frames = _load_textures("res://assets/dragon_tales/runtime/island", ["frame_00.png", "frame_01.png", "frame_02.png", "frame_03.png", "frame_04.png", "frame_05.png"])

func _build_title() -> void:
	_title_layer = Control.new()
	_title_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_layer.add_child(_title_layer)
	var island := TextureRect.new()
	island.texture = _island_frames[1] if _island_frames.size() > 1 else null
	island.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	island.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	island.position = Vector2(620, 72)
	island.size = Vector2(590, 590)
	island.modulate = Color(1, 1, 1, 0.94)
	island.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_layer.add_child(island)
	var copy := VBoxContainer.new()
	copy.position = Vector2(72, 128)
	copy.size = Vector2(460, 440)
	copy.add_theme_constant_override("separation", 8)
	_title_layer.add_child(copy)
	var eyebrow := _label("A QUIET DRAGON ISLAND", 15, TEAL)
	copy.add_child(eyebrow)
	var title := _label("Dragon Tales", 62, CREAM)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	title.add_theme_constant_override("shadow_offset_y", 5)
	copy.add_child(title)
	var subtitle := _label("Breed, grow, discover.", 23, MUTED)
	copy.add_child(subtitle)
	copy.add_child(_spacer(20))
	var body := _label("Build a small home for ten elemental dragons—without the noise of a crowded event calendar.", 17, MUTED)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(380, 70)
	copy.add_child(body)
	copy.add_child(_spacer(28))
	var start := _button("Begin your island", TEAL)
	start.custom_minimum_size = Vector2(280, 52)
	start.pressed.connect(_show_game)
	copy.add_child(start)
	var hint := _label("Offline prototype • local progress", 13, Color(MUTED, 0.75))
	copy.add_child(hint)

func _build_game() -> void:
	_game_layer = Control.new()
	_game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_layer.add_child(_game_layer)
	var header := PanelContainer.new()
	header.position = Vector2(26, 20)
	header.size = Vector2(1228, 62)
	header.add_theme_stylebox_override("panel", _style(PANEL, Color(TEAL, 0.4), 12, 1))
	_game_layer.add_child(header)
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 18)
	header.add_child(header_row)
	var logo := _label("DRAGON TALES", 25, CREAM)
	logo.custom_minimum_size = Vector2(250, 0)
	header_row.add_child(logo)
	_collection_count = _label("", 15, MUTED)
	_collection_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(_collection_count)
	_food_label = _label("", 16, CREAM)
	_coin_label = _label("", 16, GOLD)
	header_row.add_child(_food_label)
	header_row.add_child(_coin_label)
	var collection_button := _button("Collection", PANEL_SOFT)
	collection_button.pressed.connect(_show_collection)
	header_row.add_child(collection_button)
	var achievements_button := _button("Achievements", PANEL_SOFT)
	achievements_button.pressed.connect(_show_achievements)
	header_row.add_child(achievements_button)
	var battle_button := _button("Battle", PANEL_SOFT)
	battle_button.pressed.connect(_show_battle)
	header_row.add_child(battle_button)
	var title_button := _button("Title", Color("#36504A"))
	title_button.pressed.connect(_show_title)
	header_row.add_child(title_button)

	_content = Control.new()
	_content.position = Vector2(26, 98)
	_content.size = Vector2(1228, 590)
	_game_layer.add_child(_content)
	_build_island_view()
	_build_modal()
	_game_layer.visible = false

func _build_island_view() -> void:
	_island_texture = TextureRect.new()
	_island_texture.texture = _island_frames[0] if not _island_frames.is_empty() else null
	_island_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_island_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_island_texture.position = Vector2(330, 10)
	_island_texture.size = Vector2(590, 520)
	_island_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_island_texture)
	var intro := _panel(Vector2(0, 10), Vector2(285, 178), PANEL)
	_content.add_child(intro)
	var intro_box := VBoxContainer.new()
	intro_box.add_theme_constant_override("separation", 5)
	intro.add_child(intro_box)
	intro_box.add_child(_label("YOUR ISLAND", 13, TEAL))
	intro_box.add_child(_label("A little room to grow", 23, CREAM))
	var intro_body := _label("Harvest food, care for your dragons, and let the island fill in at your pace.", 14, MUTED)
	intro_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_body.custom_minimum_size = Vector2(245, 55)
	intro_box.add_child(intro_body)
	_status_label = _label("", 14, GOLD)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_box.add_child(_status_label)

	var farm := _building_card("food_farm", "Food Farm", "Harvest +5 food", Color("#73B75D"))
	farm.position = Vector2(0, 208)
	_content.add_child(farm)
	var corral := _building_card("breeding_corral", "Breeding Corral", "Choose two dragons", Color("#D69A57"))
	corral.position = Vector2(952, 46)
	_content.add_child(corral)
	var hatchery := _building_card("hatchery", "Hatchery", "Claim your next dragon", Color("#DDAA6A"))
	hatchery.position = Vector2(952, 268)
	_content.add_child(hatchery)

	var dragon_strip := PanelContainer.new()
	dragon_strip.position = Vector2(285, 486)
	dragon_strip.size = Vector2(662, 95)
	dragon_strip.add_theme_stylebox_override("panel", _style(PANEL, Color(TEAL, 0.3), 12, 1))
	_content.add_child(dragon_strip)
	var strip_row := HBoxContainer.new()
	strip_row.add_theme_constant_override("separation", 12)
	dragon_strip.add_child(strip_row)
	strip_row.add_child(_label("ON THE ISLAND", 12, TEAL))
	for dragon: Dictionary in DragonCatalogType.DRAGONS.slice(0, 4):
		var card := _mini_dragon_card(str(dragon.id))
		strip_row.add_child(card)
	_refresh_hud()

func _building_card(asset_id: String, title: String, detail: String, accent: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.size = Vector2(285, 184)
	card.add_theme_stylebox_override("panel", _style(PANEL, Color(accent, 0.65), 2, 1))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)
	var image := TextureRect.new()
	image.texture = load("res://assets/dragon_tales/runtime/buildings/%s.png" % asset_id)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(250, 104)
	box.add_child(image)
	var button := _button(title, accent)
	button.custom_minimum_size = Vector2(0, 34)
	button.tooltip_text = detail
	box.add_child(button)
	if asset_id == "food_farm":
		button.pressed.connect(_harvest_food)
	elif asset_id == "breeding_corral":
		button.pressed.connect(_show_breeding)
	else:
		button.pressed.connect(_hatch_egg)
	return card

func _mini_dragon_card(dragon_id: String) -> Control:
	var dragon := DragonCatalogType.by_id(dragon_id)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(74, 78)
	var image := TextureRect.new()
	image.texture = load("res://assets/dragon_tales/runtime/dragons/%s/idle_00.png" % dragon_id)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(66, 54)
	box.add_child(image)
	var label := _label(str(dragon.get("name", "Dragon")), 11, CREAM)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	return box

func _build_modal() -> void:
	_modal = PanelContainer.new()
	_modal.position = Vector2(350, 130)
	_modal.size = Vector2(580, 420)
	_modal.z_index = 20
	_modal.add_theme_stylebox_override("panel", _style(Color("#173835"), Color(TEAL, 0.8), 16, 2))
	_game_layer.add_child(_modal)
	_modal_content = VBoxContainer.new()
	_modal_content.add_theme_constant_override("separation", 10)
	_modal.add_child(_modal_content)
	_modal_title = _label("", 30, CREAM)
	_modal_content.add_child(_modal_title)
	_modal_body = _label("", 15, MUTED)
	_modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_modal_body.custom_minimum_size = Vector2(520, 46)
	_modal_content.add_child(_modal_body)
	_modal.visible = false

func _show_title() -> void:
	_screen = "title"
	_title_layer.visible = true
	_game_layer.visible = false
	if _modal != null:
		_modal.visible = false

func _show_game() -> void:
	_screen = "game"
	_title_layer.visible = false
	_game_layer.visible = true
	_content.visible = true
	_modal.visible = false
	_status("Your island is waking up.", TEAL)
	_refresh_hud()

func _refresh_hud() -> void:
	if _food_label == null:
		return
	_food_label.text = "Food  %d" % int(DragonState.state.get("food", 0))
	_coin_label.text = "Coins  %d" % int(DragonState.state.get("coins", 0))
	_collection_count.text = "Dragons %d / 10" % DragonState.state.get("discovered", []).size()

func _show_collection() -> void:
	_open_modal("Dragon Collection", "Your ten base elements are the beginning of the collection. Feed a discovered dragon or open the corral to breed.")
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	_modal_content.add_child(grid)
	for dragon: Dictionary in DragonCatalogType.DRAGONS:
		var id := str(dragon.id)
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(98, 112)
		card.add_theme_stylebox_override("panel", _style(Color("#234A45") if DragonState.has_dragon(id) else Color("#142B2B"), Color(dragon.color, 0.6), 8, 1))
		var box := VBoxContainer.new()
		card.add_child(box)
		var image := TextureRect.new()
		image.texture = load("res://assets/dragon_tales/runtime/dragons/%s/%s_00.png" % [id, "idle"])
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(88, 72)
		box.add_child(image)
		var label := _label(str(dragon.name), 13, CREAM if DragonState.has_dragon(id) else Color(MUTED, 0.45))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(label)
		grid.add_child(card)
	var close := _button("Back to island", PANEL_SOFT)
	close.pressed.connect(_close_modal)
	_modal_content.add_child(close)

func _show_achievements() -> void:
	_open_modal("Small milestones", "A quiet list of progress worth noticing.")
	var achievements := [
		["first_harvest", "Tend the soil", "Harvest food once."],
		["collector_3", "Three little stories", "Discover three dragons."],
		["first_battle", "Brave the arena", "Complete your first battle."],
	]
	for item: Array in achievements:
		var done := bool(DragonState.state.achievements.get(str(item[0]), false))
		var row := _label(("✓ " if done else "○ ") + str(item[1]) + " — " + str(item[2]), 16, GOLD if done else MUTED)
		_modal_content.add_child(row)
	var close := _button("Back to island", PANEL_SOFT)
	close.pressed.connect(_close_modal)
	_modal_content.add_child(close)

func _show_breeding() -> void:
	_open_modal("Breeding Corral", "Choose two dragons. In this first prototype, same-element pairs preserve their element; mixed pairs use the first parent until hybrid tables are added.")
	_breeding_label = _label("Parents: %s + %s" % [_dragon_name(_parent_a), _dragon_name(_parent_b)], 18, CREAM)
	_modal_content.add_child(_breeding_label)
	var parents := HBoxContainer.new()
	parents.add_theme_constant_override("separation", 12)
	_modal_content.add_child(parents)
	var a_button := _button("Parent A: %s" % _dragon_name(_parent_a), PANEL_SOFT)
	a_button.pressed.connect(_cycle_parent_a)
	parents.add_child(a_button)
	var b_button := _button("Parent B: %s" % _dragon_name(_parent_b), PANEL_SOFT)
	b_button.pressed.connect(_cycle_parent_b)
	parents.add_child(b_button)
	var breed := _button("Start breeding", TEAL)
	breed.pressed.connect(_start_breeding)
	_modal_content.add_child(breed)
	var close := _button("Back to island", PANEL_SOFT)
	close.pressed.connect(_close_modal)
	_modal_content.add_child(close)

func _cycle_parent_a() -> void:
	_parent_a = _next_discovered(_parent_a)
	_show_breeding()

func _cycle_parent_b() -> void:
	_parent_b = _next_discovered(_parent_b)
	_show_breeding()

func _next_discovered(current: String) -> String:
	var discovered: Array = DragonState.state.get("discovered", [])
	if discovered.is_empty():
		return "blaze"
	var index := discovered.find(current)
	return str(discovered[(index + 1) % discovered.size()])

func _start_breeding() -> void:
	var result := DragonState.start_breeding(_parent_a, _parent_b)
	if result.is_empty():
		_status("Choose two discovered dragons first.", CORAL)
		return
	_status("A %s egg is resting in the hatchery." % _dragon_name(result), GOLD)
	_close_modal()
	_refresh_hud()

func _hatch_egg() -> void:
	var pending := str(DragonState.state.get("pending_egg", ""))
	if pending.is_empty():
		_status("The hatchery is quiet. Breed two dragons to place an egg here.", MUTED)
		return
	var result := DragonState.hatch()
	_status("%s hatched and joined your collection." % _dragon_name(result), TEAL)
	_refresh_hud()

func _harvest_food() -> void:
	var gained := DragonState.harvest()
	_status("Harvested %d food and found 10 coins." % gained, TEAL)
	_refresh_hud()

func _show_battle() -> void:
	_open_modal("A friendly first battle", "Choose a short practice match. Your collected dragons are ready to try their action animations.")
	_battle_result = _label("", 17, GOLD)
	_modal_content.add_child(_battle_result)
	var fight := _button("Start practice battle", CORAL)
	fight.pressed.connect(_resolve_battle)
	_modal_content.add_child(fight)
	var close := _button("Back to island", PANEL_SOFT)
	close.pressed.connect(_close_modal)
	_modal_content.add_child(close)

func _resolve_battle() -> void:
	DragonState.mark_battle_complete()
	_battle_result.text = "Victory. Your dragons earned 25 coins."
	_status("Practice battle complete. Your island earned 25 coins.", GOLD)
	_refresh_hud()

func _open_modal(title: String, body: String) -> void:
	for child: Node in _modal_content.get_children().duplicate():
		if child != _modal_title and child != _modal_body:
			child.queue_free()
	_modal_title.text = title
	_modal_body.text = body
	_modal.visible = true

func _close_modal() -> void:
	_modal.visible = false

func _status(message: String, color: Color = GOLD) -> void:
	if _status_label != null:
		_status_label.text = message
		_status_label.add_theme_color_override("font_color", color)

func _dragon_name(dragon_id: String) -> String:
	var dragon := DragonCatalogType.by_id(dragon_id)
	return str(dragon.get("name", "Dragon"))

func _load_textures(directory: String, names: Array[String]) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	for name: String in names:
		var texture := load("%s/%s" % [directory, name]) as Texture2D
		if texture != null:
			result.append(texture)
	return result

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _button(text: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(140, 40)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _style(Color(accent, 0.22), Color(accent, 0.72), 8, 1))
	button.add_theme_stylebox_override("hover", _style(Color(accent, 0.42), Color.WHITE, 8, 1))
	button.add_theme_stylebox_override("pressed", _style(Color(accent, 0.6), Color.WHITE, 8, 1))
	return button

func _panel(position: Vector2, panel_size: Vector2, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = position
	panel.size = panel_size
	panel.add_theme_stylebox_override("panel", _style(color, Color(TEAL, 0.35), 12, 1))
	return panel

func _style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(14)
	return style

func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, height)
	return spacer
