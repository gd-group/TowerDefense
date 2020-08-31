extends Node2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const FOLLOW_OFFSET = 64

var mob_pack = preload("res://Mob.tscn")
var tower_packs = [
	preload("res://Tower.tscn"), 
	preload("res://Tower.tscn"), 
	preload("res://Tower.tscn")
]
var offset_index = 0
var offsets = [-16, 0, 16, 0]
var last_tpos = Vector2()
var lifes = 20
onready var path_follow = $MapView/LevelMap/Path/Follow
onready var ui_life = $Panel/Life

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MobTimer.connect("timeout", self, "create_mob")
	$MobTimer.start(0.5)
	$MapView/TowerBuild.close()
	$MapView/TowerUpgrade.close()
	ui_life.text = str(lifes)

func create_mob():
	var mob = mob_pack.instance()
	var offset = offsets[offset_index]
	mob.setup(path_follow, offset)
	mob.connect("reach_end", self, "on_reach_end")
	$MapView.add_child_below_node($MapView/LevelMap, mob)
	offset_index = (offset_index + 1) % 4

func create_tower(tower_id: int, pos: Vector2):
	print("create_tower:", tower_id, pos)
	var tower = tower_packs[tower_id].instance()
	tower.setup(tower_id, pos, 100)
	tower.connect("tower_select", self, "on_tower_select")
	$MapView.add_child_below_node($MapView/LevelMap, tower)
	$MapView/LevelMap.set_tile("ground", pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func on_reach_end(damage: int):
	lifes -= damage
	if lifes <= 0:
		pass
	ui_life.text = str(lifes)

func is_ui_open():
	return $MapView/TowerBuild.visible or $MapView/TowerUpgrade.visible
	
func on_tower_select(tower: Tower):
	print("on_tower_select:", tower.position)
	if is_ui_open():
		return
	# open tower upgrade
	$MapView/TowerUpgrade.open(tower.position, tower, 100, 100)

func _on_LevelMap_click_tile(name, lpos) -> void:
	print("click_tile:", name, lpos)
	if is_ui_open():
		return
	# open tower build
	if name == "tower":
		last_tpos = lpos
		$MapView/TowerBuild.open(lpos)

func _on_TowerBuild_build_tower(tower_id) -> void:
	create_tower(tower_id, last_tpos)

func _on_TowerUpgrade_tower_action(action, cost) -> void:
	print("upgrade:", action, cost)
