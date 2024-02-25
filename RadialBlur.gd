extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	var p = %Player
	if not p:
		return
	var c = p.get_node("lookpoint/Camera2D")
	if not c:
		return

	var view =  get_viewport_rect().size
	var topLeft = c.global_position - get_viewport_rect().size / 2 
	var nx = (p.position.x - topLeft.x) / view.x
	var ny = (p.position.y - topLeft.y) / view.y

	material.set_shader_parameter("blur_center", Vector2(nx, ny))
