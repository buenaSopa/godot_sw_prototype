extends KinematicBody

onready var anim_tree: AnimationTree = get_node("AnimationTree")
onready var anim_play: AnimationPlayer = get_node("bot/AnimationPlayer")
onready var cam: Spatial = get_node("CamPivot")
onready var spatial: Spatial = get_node("bot")
onready var blade: MeshInstance = get_node("bot/Armature/Skeleton/hips/weapon_unhold/weapon/hilt/blade")
onready var blade_animplay: AnimationPlayer = get_node("bot/Armature/Skeleton/hips/weapon_unhold/weapon/AnimationPlayer")
onready var ray: RayCast = get_node("bot/Armature/Skeleton/hips/weapon_unhold/weapon/hilt/blade/RayCast")

var speed: float = 7.0
var combat_drop: float = 0.1
var acceleration: float = 20.0
var gravity: float = 35.0
var ground_gravity: float = 1.0
var wall_falling_glitch_prevention: float = -7.0
var jump_force: float = 22.0
export var sens: float = 0.2
var combat_mode: bool = false
var switching: bool = false
var prepare_land: bool = false
var dash_force: float = 0.0;

var velocity = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	loop_workaround()
	ray.set_enabled(false)
	blade.set_visible(false)

func _input(event):
	rotate_character(event)
	
	
func _physics_process(delta):
	exit_esc()
	move(delta)
	attack()
	
	if ray.is_colliding() and not ray.get_collider().is_in_group("PC"):
		print("ray colliding")
	
func _unhandled_key_input(_event):
	switch()
	
func rotate_character(event)-> void:
	if event is InputEventMouseMotion:
		var movement = event.relative
		cam.rotation.x += deg2rad(movement.y*sens)
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(movement.x*sens)
	 
	
func move(delta):
	var target_direction = Vector2(0,0)
	if anim_tree.get("parameters/sheathing_transition/current") and anim_tree.get("parameters/withdraw_transition/current")  and anim_tree.get("parameters/falling_transition/current"):
		switching = false
		if Input.is_action_pressed("forward"):
			target_direction.y -= 1
		if Input.is_action_pressed("backward"):
			target_direction.y += 1
		if Input.is_action_pressed("left"):
			target_direction.x += 1
		if Input.is_action_pressed("right"):
			target_direction.x -= 1
		 
	#jump
	if is_on_floor() and switching==false:
		if prepare_land and velocity.y < -jump_force:
			anim_tree.set("parameters/falling_transition/current", 0)
		elif anim_tree.get("parameters/falling_transition/current") != 0:
			prepare_land = false
			anim_tree.set("parameters/falling_transition/current", 1)
			set_anim(target_direction)
			if Input.is_action_just_pressed("jump"):
				velocity.y += jump_force
				
	elif not is_on_floor() and (velocity.y > 0 or velocity.y < wall_falling_glitch_prevention):
		anim_tree.set("parameters/falling_transition/current", 2)
		prepare_land = true
		if velocity.y < -(gravity*0.9):
			anim_tree.set("parameters/landing_type/blend_amount", 1)
		else:
			anim_tree.set("parameters/landing_type/blend_amount", 0)
	#jump end
	
	#dash
	if Input.is_action_pressed("dash"):
		if Input.is_action_pressed("forward"):
			target_direction.y -= 40
		elif Input.is_action_pressed("backward"):
			target_direction.y += 40
		elif Input.is_action_pressed("left"):
			target_direction.x += 40
		elif Input.is_action_pressed("right"):
			target_direction.x -= 40 
	
	target_direction =  -1*target_direction.rotated(-rotation.y).normalized()
	velocity.x = lerp(velocity.x, target_direction.x*speed, acceleration*delta) 
	velocity.z = lerp(velocity.z, target_direction.y*speed, acceleration*delta) 


	
	print(velocity, target_direction)
	
	#fall
	if velocity.y > -gravity:
		velocity.y -= gravity*delta
	if velocity.y < 0 and is_on_floor():
		velocity.y = -ground_gravity
		
	move_and_slide(velocity, Vector3(0,1,0), true)
	#fall end
	
func set_anim(dir)-> void:
	dir.y = -dir.y
	if combat_mode:
		anim_tree.set("parameters/combat_move/blend_position", dir)
	else:
		anim_tree.set("parameters/move/blend_position", dir)
	
func exit_esc()-> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
func switch()-> void:
	if Input.is_action_pressed("switch_style") and is_on_floor() and switching == false:
		if combat_mode == false:
			combat_mode = true
			switching = true
			anim_tree.set("parameters/withdraw_transition/current", 0)
			anim_tree.set("parameters/combat_transition/current", 1)

		elif combat_mode == true:
			combat_mode = false
			switching = true
			anim_tree.set("parameters/sheathing_transition/current", 0)
			anim_tree.set("parameters/combat_transition/current", 0)

func attack()-> void:
	if Input.is_action_pressed("attack") and combat_mode:
		anim_tree.set("parameters/atk_swing/blend_position", 1)
		anim_tree.set("parameters/slash/active", true)

		
func reparent(childNode: Node, newparentNode: Node)->void:
	var old_parent = childNode.get_parent()
	old_parent.remove_child(childNode)
	newparentNode.add_child(childNode)
	
func blade_ignition():
	if blade.is_visible():
		blade_animplay.play("retract")
		ray.set_enabled(false) 
		blade.set_visible(false)
		
	elif not blade.is_visible():
		blade.set_visible(true)
		blade_animplay.play("ignite")
		ray.set_enabled(true) 
		
	
func withdraw_sword(): #TODO: set in anime keyframe
	reparent(get_node("bot/Armature/Skeleton/hips/weapon_unhold").get_child(0), get_node("bot/Armature/Skeleton/right_hand/weapon_hold"))
	
func sheath_sword(): #TODO: set in anime keyframe
	reparent(get_node("bot/Armature/Skeleton/right_hand/weapon_hold").get_child(0), get_node("bot/Armature/Skeleton/hips/weapon_unhold"))
	
	
func loop_workaround():
	var animations = ['right up Slash-loop', 'Withdrawing Sword', 'Sheath Sword']

	for animation in animations:
		animation = anim_play.get_animation(animation)
		animation.set_loop(false)

	
	
	
	


