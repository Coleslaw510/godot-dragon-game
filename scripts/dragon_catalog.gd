extends RefCounted
class_name DragonCatalog

const DRAGONS: Array[Dictionary] = [
	{"id": "blaze", "name": "Blaze", "element": "Fire", "color": Color("#E85D3F"), "action": "Breathe Fire"},
	{"id": "tide", "name": "Tide", "element": "Water", "color": Color("#3C9FD9"), "action": "Shoot Water"},
	{"id": "pebble", "name": "Pebble", "element": "Earth", "color": Color("#A47A4B"), "action": "Rock Slam"},
	{"id": "breeze", "name": "Breeze", "element": "Air", "color": Color("#79C6C4"), "action": "Wind Gust"},
	{"id": "spark", "name": "Spark", "element": "Lightning", "color": Color("#D5B34A"), "action": "Lightning Bolt"},
	{"id": "fern", "name": "Fern", "element": "Plant", "color": Color("#62A858"), "action": "Leaf Vine Blast"},
	{"id": "frost", "name": "Frost", "element": "Ice", "color": Color("#86BFE8"), "action": "Ice Breath"},
	{"id": "gleam", "name": "Gleam", "element": "Light", "color": Color("#E8C85A"), "action": "Light Beam"},
	{"id": "rivet", "name": "Rivet", "element": "Metal", "color": Color("#8596A3"), "action": "Metal Blast"},
	{"id": "twinkle", "name": "Twinkle", "element": "Star", "color": Color("#A87AD7"), "action": "Star Blast"},
]

static func by_id(dragon_id: String) -> Dictionary:
	for dragon: Dictionary in DRAGONS:
		if str(dragon.get("id", "")) == dragon_id:
			return dragon.duplicate(true)
	return {}

static func index_of(dragon_id: String) -> int:
	for index in DRAGONS.size():
		if str(DRAGONS[index].get("id", "")) == dragon_id:
			return index
	return -1

static func ids() -> Array[String]:
	var result: Array[String] = []
	for dragon: Dictionary in DRAGONS:
		result.append(str(dragon.id))
	return result
