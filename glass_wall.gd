extends StaticBody2D

func _ready():
    add_to_group("glass_wall")

func destroy():
    $Glass.hide()
    $GlassBroken.show()
    set_collision_layer_value(1,false)

