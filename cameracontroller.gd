extends Camera2D


var target = null


# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_tree().get_first_node_in_group("player").get_node("lookpoint")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not target:
		return

	var target_pos = target.global_position
	
	var newpos = global_position
	newpos = lerp(newpos, target_pos, 0.1)
	global_position = newpos

