extends Node


var pickupcounter = 0

var label= null

func _ready():
	label = get_tree().get_root().get_node("Node2D/HUD/Label")

	if label:
		label.text = "Pickups: " + str(pickupcounter)

func Pickup():
	return
	pickupcounter += 1
	if label:
		label.text = "Pickups: " + str(pickupcounter)

func rprint(v):
	print(v)

	return v


func restart():
	get_tree().reload_current_scene()


func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		restart()
