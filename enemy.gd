extends Area2D


const SPEED = 400.0

var player = null
var velocity = Vector2()

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * SPEED

	global_position += velocity * delta
	