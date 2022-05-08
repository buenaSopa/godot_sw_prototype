extends Spatial

onready var blade: SpatialMaterial = get_node("hilt/blade").mesh.surface_get_material(0)
onready var light: OmniLight = get_node("hilt/blade/blade light")

func _ready():
	randomize()
	pass


func _physics_process(delta):
	pass
	
	
func _on_Timer_timeout():
	#buzzing effect
	var random_value = rand_range(5,7)
	#light.set_param(3, random_value-3)
	blade.set_emission_energy(random_value) 
	
