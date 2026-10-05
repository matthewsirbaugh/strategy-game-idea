class_name BattleSession
extends RefCounted

# One phase's setup: the map, the content, the loadouts the player picked, and what the team
# carried in from the phase before. Losing restarts the phase from exactly this.

var map: MapData
var content: BattleContent
var loadouts: Array[Loadout] = []
var carry := {}


static func from_presets(p_map: MapData, p_content: BattleContent) -> BattleSession:
	var session := BattleSession.new()
	session.map = p_map
	session.content = p_content
	for loadout in p_content.loadouts:
		session.loadouts.append(loadout.duplicate())
	return session


func start() -> BattleState:
	return BattleState.new(map, content, loadouts, carry)
