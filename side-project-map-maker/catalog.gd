extends RefCounted

const TILE := 1.5

static func entries() -> Array[Dictionary]:
	return [
		{"id":"floor", "name":"Concrete floor", "category":"Ground", "grid":true, "size":Vector3(TILE, 0.08, TILE), "color":Color("75838c"), "base":-0.08},
		{"id":"street", "name":"Street tile", "category":"Ground", "grid":true, "size":Vector3(TILE, 0.08, TILE), "color":Color("394751"), "base":-0.08},
		{"id":"grass", "name":"Garden tile", "category":"Ground", "grid":true, "size":Vector3(TILE, 0.08, TILE), "color":Color("536d59"), "base":-0.08},
		{"id":"wall", "name":"Wall segment", "category":"Structures", "grid":true, "size":Vector3(TILE, 2.8, 0.22), "color":Color("c4c5bc")},
		{"id":"low_wall", "name":"Low barrier", "category":"Structures", "grid":true, "size":Vector3(TILE, 0.9, 0.3), "color":Color("7c8c8e")},
		{"id":"building", "name":"Building block", "category":"Structures", "grid":true, "size":Vector3(TILE*4, 6, TILE*4), "color":Color("73878c")},
		{"id":"room", "name":"Room • 4 × 4 tiles", "category":"Prefabs", "grid":true, "assembly":"room"},
		{"id":"yard", "name":"Yard • 6 × 6 tiles", "category":"Prefabs", "grid":true, "assembly":"yard"},
		{"id":"crate_cluster", "name":"Three-crate cluster", "category":"Prefabs", "grid":false, "assembly":"crates"},
		{"id":"access_point", "name":"Access panel", "category":"Props", "grid":false, "height":1.2},
		{"id":"security_camera", "name":"Security camera", "category":"Props", "grid":false, "height":0.6},
		{"id":"security_door", "name":"Security door", "category":"Props", "grid":false, "height":2.4},
		{"id":"vault_door", "name":"Vault door", "category":"Props", "grid":false, "height":2.6},
		{"id":"server_rack", "name":"Server rack", "category":"Props", "grid":false, "height":2.2},
		{"id":"shipping_crates", "name":"Shipping crates", "category":"Props", "grid":false, "height":1.6},
		{"id":"delivery_van", "name":"Delivery van", "category":"Props", "grid":false, "height":2.6},
		{"id":"guard_booth", "name":"Guard booth", "category":"Props", "grid":false, "height":2.6},
		{"id":"loading_dock", "name":"Loading dock", "category":"Props", "grid":false, "height":2.8},
		{"id":"floodlight_pole", "name":"Floodlight pole", "category":"Props", "grid":false, "height":6.0},
		{"id":"reception_desk", "name":"Reception desk", "category":"Props", "grid":false, "height":1.2},
		{"id":"turret", "name":"Turret", "category":"Props", "grid":false, "height":1.3},
	]
