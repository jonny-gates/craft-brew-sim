extends RefCounted
class_name Catalog

const _EQUIPMENT := [
	{"id": "amateur_mash_tun", "name": "Amateur Mash Tun", "price": 800, "tier": "amateur", "cap": "25L batch"},
	{"id": "amateur_brew_kettle", "name": "Amateur Brew Kettle", "price": 700, "tier": "amateur", "cap": "25L batch"},
	{"id": "amateur_wort_chiller", "name": "Amateur Wort Chiller", "price": 250, "tier": "amateur", "cap": "immersion coil"},
	{"id": "amateur_fermenter", "name": "Amateur Fermenter", "price": 300, "tier": "amateur", "cap": "25L bucket"},
	{"id": "amateur_keg_pack", "name": "Amateur Keg Pack", "price": 200, "tier": "amateur", "cap": "pack of 2"},
	{"id": "amateur_bottling_filler", "name": "Amateur Bottling Filler", "price": 150, "tier": "amateur", "cap": "hand-fill"},
	{"id": "mash_tun", "name": "Mash Tun", "price": 5500, "tier": "standard", "cap": "500L batch"},
	{"id": "brew_kettle", "name": "Brew Kettle", "price": 6500, "tier": "standard", "cap": "500L batch"},
	{"id": "wort_chiller", "name": "Wort Chiller", "price": 2800, "tier": "standard", "cap": "plate chiller"},
	{"id": "fermenter", "name": "Fermenter", "price": 4200, "tier": "standard", "cap": "500L cylindroconical"},
	{"id": "keg_pack", "name": "Keg Pack", "price": 900, "tier": "standard", "cap": "pack of 6"},
	{"id": "brite_tank", "name": "Brite Tank", "price": 4800, "tier": "standard", "cap": "500L"},
	{"id": "industrial_mash_tun", "name": "Industrial Mash Tun", "price": 28000, "tier": "industrial", "cap": "3000L batch"},
	{"id": "industrial_brew_kettle", "name": "Industrial Brew Kettle", "price": 32000, "tier": "industrial", "cap": "3000L batch"},
	{"id": "professional_heat_exchanger", "name": "Professional Heat Exchanger", "price": 14000, "tier": "industrial", "cap": "high-flow"},
	{"id": "industrial_fermenter", "name": "Industrial Fermenter", "price": 22000, "tier": "industrial", "cap": "4000L unitank"},
	{"id": "industrial_keg_pack", "name": "Industrial Keg Pack", "price": 3200, "tier": "industrial", "cap": "pack of 20"},
	{"id": "professional_brite_tank", "name": "Professional Brite Tank", "price": 19000, "tier": "industrial", "cap": "4000L"},
	{"id": "industrial_canning_line", "name": "Industrial Canning Line", "price": 120000, "tier": "industrial", "cap": "30 cans/min"},
]

const _INGREDIENTS := [
	{"id": "pale_malt", "name": "Pale Malt", "price": 55, "unit": "50lb sack"},
	{"id": "specialty_malt", "name": "Specialty Malt", "price": 75, "unit": "50lb sack"},
	{"id": "pellet_hops", "name": "Pellet Hops", "price": 18, "unit": "lb"},
	{"id": "ale_yeast", "name": "Ale Yeast", "price": 12, "unit": "packet"},
	{"id": "lager_yeast", "name": "Lager Yeast", "price": 15, "unit": "packet"},
	{"id": "water_salts", "name": "Water Treatment Salts", "price": 25, "unit": "box"},
]

static func equipment() -> Array[EquipmentItem]:
	var items: Array[EquipmentItem] = []
	for d in _EQUIPMENT:
		var item := EquipmentItem.new()
		item.id = d.id
		item.display_name = d.name
		item.price = d.price
		item.tier = d.tier
		item.capacity_desc = d.cap
		items.append(item)
	return items

static func ingredients() -> Array[IngredientItem]:
	var items: Array[IngredientItem] = []
	for d in _INGREDIENTS:
		var item := IngredientItem.new()
		item.id = d.id
		item.display_name = d.name
		item.price = d.price
		item.unit = d.unit
		items.append(item)
	return items

static func find_equipment(id: String) -> EquipmentItem:
	for item in equipment():
		if item.id == id:
			return item
	return null

static func find_ingredient(id: String) -> IngredientItem:
	for item in ingredients():
		if item.id == id:
			return item
	return null
