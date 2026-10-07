extends Control

# The pre-battle test tool: swap each Operator's armor, gear and chips between test runs. It
# starts from the V1 loadouts, and a battle restarted after losing keeps whatever was picked here.

const MAP := preload("res://content/maps/facility_yard.tres")
const CONTENT := preload("res://content/battle.tres")

var _session: BattleSession
var _columns: HBoxContainer


func _ready() -> void:
	_session = SceneRouter.session if SceneRouter.session else BattleSession.from_presets(MAP, CONTENT)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 14)
	%Main.add_child(rows)
	var kicker := Label.new()
	kicker.text = "01  /  FACILITY EXTERIOR     /     TEST LOADOUTS"
	kicker.theme_type_variation = &"Kicker"
	kicker.add_theme_color_override("font_color", Color(0.95, 0.66, 0.46))
	rows.add_child(kicker)
	var title := Label.new()
	title.text = "LOADOUT"
	title.theme_type_variation = &"Heading"
	title.add_theme_font_size_override("font_size", 56)
	rows.add_child(title)
	var note := Label.new()
	note.text = "Each Operator carries armor, one robot or %d flashbangs, and up to %d chips plus the movement chip." % [Loadout.FLASHBANGS, Loadout.MAX_CHIPS]
	note.add_theme_color_override("font_color", Color(0.79, 0.83, 0.79))
	rows.add_child(note)
	_columns = HBoxContainer.new()
	_columns.add_theme_constant_override("separation", 22)
	_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(_columns)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	rows.add_child(buttons)
	var deploy := _button("DEPLOY     →", func() -> void: SceneRouter.goto_battle(_session))
	buttons.add_child(deploy)
	buttons.add_child(_button("RESET TO V1 LOADOUTS", _reset))
	buttons.add_child(_button("BACK", SceneRouter.goto_title))
	_build_columns()
	deploy.grab_focus()


func _reset() -> void:
	_session.loadouts.clear()
	for loadout in _session.content.loadouts:
		_session.loadouts.append(loadout.duplicate())
	_build_columns()


func _build_columns() -> void:
	for child in _columns.get_children():
		_columns.remove_child(child)
		child.queue_free()
	for i in _session.content.operators.size():
		_columns.add_child(_column(_session.content.operators[i], _session.loadouts[i]))


func _column(operator: UnitDef, loadout: Loadout) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(margin)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	margin.add_child(rows)
	var name_label := Label.new()
	name_label.text = operator.display_name.to_upper()
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", operator.color.lightened(0.2))
	rows.add_child(name_label)
	var role := Label.new()
	role.text = loadout.role
	role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	role.theme_type_variation = &"Kicker"
	rows.add_child(role)
	rows.add_child(_choice("ARMOR", Loadout.ARMOR_NAMES, loadout.armor, func(index: int) -> void: loadout.armor = index as Loadout.Armor,
		["No armor: down after %d hit" % Loadout.HITS[0], "Basic: %d hits" % Loadout.HITS[1],
			"Heavy: %d hits, but %d AP a turn" % [Loadout.HITS[2], operator.ap - Loadout.HEAVY_AP_COST]]))
	rows.add_child(_choice("GEAR", Loadout.GEAR_NAMES, loadout.gear, func(index: int) -> void: loadout.gear = index as Loadout.Gear,
		_gear_tips()))
	var chips_title := Label.new()
	chips_title.text = "CHIPS  (up to %d)" % Loadout.MAX_CHIPS
	chips_title.theme_type_variation = &"Kicker"
	rows.add_child(chips_title)
	var grid := GridContainer.new()
	grid.columns = 2
	rows.add_child(grid)
	var boxes: Array[CheckBox] = []
	for chip in _session.content.chips:
		if chip.type == ChipDef.Type.MOVEMENT:
			continue
		var box := CheckBox.new()
		box.text = chip.display_name
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_font_size_override("font_size", 18)
		box.tooltip_text = "%s\nLoad: %dM context\n%s\nDegraded: %s" % [chip.display_name, chip.load_cost, chip.effect, chip.degraded_effect]
		box.button_pressed = loadout.chips.has(chip.id)
		box.toggled.connect(func(on: bool) -> void:
			var chips := loadout.chips
			if on and not chips.has(chip.id):
				chips.append(chip.id)
			elif not on and chips.has(chip.id):
				chips.remove_at(chips.find(chip.id))
			loadout.chips = chips
			_limit(boxes, loadout))
		boxes.append(box)
		grid.add_child(box)
	_limit(boxes, loadout)
	return panel


func _gear_tips() -> Array:
	var drone := _session.content.drone
	var dog := _session.content.dog_bot
	return ["%s: %d AP, speed %d, flies over low obstacles" % [drone.display_name, drone.ap, drone.speed],
		"%s: %d AP, carries a single-use stun" % [dog.display_name, dog.ap],
		"Flashbangs: %d AP each, thrown up to %d tiles" % [BattleState.FLASHBANG_COST, BattleState.FLASHBANG_RANGE]]


# With the most chips picked, the rest can't be ticked until one comes off.
func _limit(boxes: Array[CheckBox], loadout: Loadout) -> void:
	for box in boxes:
		box.disabled = not box.button_pressed and loadout.chips.size() >= Loadout.MAX_CHIPS


func _choice(title: String, options: Array, selected: int, on_pick: Callable, tips: Array) -> Control:
	var row := VBoxContainer.new()
	var label := Label.new()
	label.text = title
	label.theme_type_variation = &"Kicker"
	row.add_child(label)
	var picker := OptionButton.new()
	for i in options.size():
		picker.add_item(options[i])
		picker.set_item_tooltip(i, tips[i])
	picker.select(selected)
	picker.item_selected.connect(on_pick)
	row.add_child(picker)
	return row


func _button(text: String, on_press: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(240, 52)
	button.pressed.connect(on_press)
	return button
