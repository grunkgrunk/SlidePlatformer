extends Area2D


func _ready():
	body_entered.connect(_on_Area2D_body_entered)
	body_exited.connect(_on_Area2D_body_exited)

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.is_in_jumper = true

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.is_in_jumper = false
		