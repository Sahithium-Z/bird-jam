extends KinematicBody2D
class_name Player

export(int) var JUMP_FORCE = -180
export(int) var JUMP_RELEASE_FORCE = -70
export(int) var MAX_SPEED = 50
export(int) var MAX_AIR_SPEED = 80 # Used as the bird's top airspeed
export(int) var ACCELERATION = 10
export(int) var FRICTION = 8
export(int) var AIR_FRICTION = 1
export(int) var GRAVITY = 4
export(int) var FASTFALL_GRAV = 2
export(int) var MAX_STAMINA = 150 # Max frames bird can gain altitude

var velocity = Vector2.ZERO

var bird = false
var stamina = MAX_STAMINA

onready var animatedSprite = $AnimatedSprite
onready var collisionShape2D = $CollisionShape2D

func _ready():
	animatedSprite.frames = load("res://PlayerHuman.tres")

func _physics_process(delta):
	apply_gravity()
	
	if is_on_floor():
			stamina = MAX_STAMINA
	
	# Poll inputs
	var input = Vector3.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	if Input.is_action_just_pressed("bird"):
		bird = not bird
		print("bird")
		velocity = Vector2.ZERO
		animatedSprite.play("Transform")
		# Gotta figure out how to pause physics while the transform anim happens
		if bird:
			collisionShape2D.scale.y = 0.35
			animatedSprite.frames = load("res://PlayerBird.tres")
		else:
			collisionShape2D.scale.y = 1
			animatedSprite.frames = load("res://PlayerHuman.tres")
			
	
	if not bird:
		# HUMAN PHYSICS
		if input.x == 0:
			apply_friction()
			animatedSprite.animation = "Idle"
		else:
			apply_acceleration(input.x)
			animatedSprite.animation = "Run"
			
			animatedSprite.flip_h = input.x < 0

		if is_on_floor():
			if Input.is_action_just_pressed("ui_up"):
				velocity.y = JUMP_FORCE
		else:
			animatedSprite.animation = "Jump"
			if Input.is_action_just_released("ui_up") and velocity.y < JUMP_RELEASE_FORCE:
				velocity.y = JUMP_RELEASE_FORCE
			
			if velocity.y > 0:
				# Increased gravity while jumping
				velocity.y += FASTFALL_GRAV
				animatedSprite.frame = 1
			else:
				# Jump anim frame changes based on whether the player is jumping or falling
				animatedSprite.frame = 0
		
		# Checks if in air to mess with run anims
		var was_in_air = not is_on_floor()
		velocity = move_and_slide(velocity, Vector2.UP)
		var just_landed = is_on_floor() and was_in_air
		if just_landed:
			animatedSprite.animation = "Run"
			animatedSprite.frame = 5
	
	else:
		# BIRD PHYSICS
		if input.x == 0:
			apply_friction()
			animatedSprite.animation = "Idle"
		else:
			apply_acceleration(input.x)
			animatedSprite.animation = "Run"
			
			animatedSprite.flip_h = input.x < 0
		
		if input.y > 0 and stamina > 0:
			velocity.y = -50
			stamina -= 1
		else:
			velocity.y += 2
			if velocity.y > GRAVITY:
				velocity.y = GRAVITY
			if input.y < 0:
				velocity.y += 50
		
		velocity = move_and_slide(velocity, Vector2.UP)

func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 280)

func apply_friction():
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	elif bird:
		# Bird has even more reduced air friction
		velocity.x = move_toward(velocity.x, 0, 0.1)
	else:
		velocity.x = move_toward(velocity.x, 0, AIR_FRICTION)

func apply_acceleration(amount):
	if bird and not is_on_floor():
		velocity.x = move_toward(velocity.x, MAX_AIR_SPEED * amount, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
