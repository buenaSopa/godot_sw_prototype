extends Spatial

onready var inner_pivot: Spatial = $CameraPivot
var mouse_sens: float = 0.3

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(event.relative.x) * mouse_sens)
		inner_pivot.rotate_x(deg2rad(event.relative.y)* mouse_sens)
		
func follow_me(position_to_follow) -> void:
	translation = position_to_follow

func give_direction() -> Transform:
	return transform
