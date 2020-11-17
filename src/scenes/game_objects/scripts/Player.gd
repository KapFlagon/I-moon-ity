extends KinematicBody2D

# Exported variables
export var facing: int = 1
export var gravity: int = 200
export var ground_friction: int = 0.25
export var air_friction: int = 0.02
export var base_movement_speed: int = 300
export var max_movement_speed: int = 100
export var jump_force: int = 180

# Additional variables
var velocity: Vector2 = Vector2(0, 0)
var current_state: int = Enums.PLAYER_STATE.IDLE
var spawn_location: Vector2 =  Vector2(30,170)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = spawn_location

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_player_velocity(delta)
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2.UP)
#	Place Holder for now
	$TitanAbilityManager.checkActionButtonPressed()
	$phaseAbilityManager.checkActionButtonPressed()
	
#	Tilesets don't allow on body entered signals ? so have to loop over collision 
#	of player with every Frame and check to see if it has hit...deadness?
	_check_collision_with_death_stuff()
	

func update_player_velocity(delta: float) -> void:
	velocity.x = update_player_horizontal_velocity()
	velocity.y = update_player_vertical_velocity(delta, velocity.y) 
	if Input.is_action_just_pressed("power_1"):
		velocity.x = launch_dash(velocity.x)


func update_player_horizontal_velocity() -> float:
	var horizontal_velocity
	var horizontal_input = get_horizontal_input()
	if horizontal_input != 0:
		horizontal_velocity = horizontal_input * base_movement_speed 
		horizontal_velocity = clamp(horizontal_velocity, -max_movement_speed, max_movement_speed)
		update_facing(horizontal_input)
	else:
		horizontal_velocity = 0
	return horizontal_velocity


func get_horizontal_input() -> float:
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")


func update_facing(horizontal_input: float) -> void:
	var direction_strength = horizontal_input
	if direction_strength > 0:
		# Only flips the sprite if the direction is new, accounts for starting positions
		if facing != 1:
			$Sprite.flip_h = false
		facing = 1		
	elif direction_strength < 0:
		if facing != -1:
			# Only flips the sprite if the direction is new, accounts for starting positions
			$Sprite.flip_h = true
		facing = -1


func update_player_vertical_velocity(delta: float, current_vertical_velocity: float) -> float: 
	# TODO Need to redesing the jump and on floor logic, for smoother platforming. 
	var vertical_velocity = current_vertical_velocity + (delta * gravity)
	if is_on_floor():
		if Input.is_action_just_pressed("move_jump"):
			vertical_velocity = current_vertical_velocity - jump_force
		else: 
			vertical_velocity = lerp(current_vertical_velocity, 0, ground_friction)
	else:
		if Input.is_action_just_released("move_jump") and current_vertical_velocity < (-jump_force/2):
			vertical_velocity = current_vertical_velocity + (jump_force/2)
	return vertical_velocity


func launch_dash(current_horizontal_velocity: float) -> float: 
	var dash_force = 2000
	var input_dir = get_horizontal_input()
	var output_horizontal_velocity
	if facing == 1:
		output_horizontal_velocity = current_horizontal_velocity + dash_force
	elif facing == -1:
		output_horizontal_velocity = current_horizontal_velocity - dash_force
	return output_horizontal_velocity

func _respawn_player():
	self.position = spawn_location
	current_state = Enums.PLAYER_STATE.IDLE

func _on_checkPoint_body_entered(body):
	if body.name == self.name:
		self.spawn_location = position
		
		
func _check_collision_with_death_stuff():
	for i in get_slide_count():
		var collisionTile = get_slide_collision(i).collider.name
		if collisionTile == "deathTileMap" || "Launcher_projectile" in collisionTile:
			current_state = Enums.PLAYER_STATE.DEAD
			_respawn_player()

