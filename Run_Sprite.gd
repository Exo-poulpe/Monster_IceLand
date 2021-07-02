extends KinematicBody2D



onready var _animated_sprite = $AnimatedSprite
onready var _raycast = $RayCast2D

signal health_changed
signal died
signal ready_stats
signal exp_up
signal level_up

export var job_name : String = "Player"
export var level : int
export var experience : int
export var max_experience : int
export var max_health : int
export var max_mana : int
export var damage : float
export var armor : int
export var speed : float
export var jump : float
export var critical : float
export var heal : float
export var cooldown : float
export var attack_cooldown : float

#export (int) var speed = 200
export (int) var gravity = 300
enum STATES {ALIVE, DEAD}
var state = STATES.ALIVE
var velocity = Vector2()
#
var next_time_damage = 0
var next_time_attack = 0
var my_health = max_health
var my_mana = max_mana
var my_cooldown = cooldown
var my_experience = experience
var my_damage = damage
var my_max_experience = max_experience
var my_level = level
var my_armor = armor
var my_speed = speed
var my_jump = jump
var my_attack_cooldown = attack_cooldown

func _ready():
	next_time_damage = 0
	next_time_attack = 0
	my_health = max_health
	my_mana = max_mana
	my_damage = damage
	my_cooldown = cooldown
	my_experience = experience
	my_max_experience = max_experience
	my_level = level
	my_armor = armor
	my_speed = speed
	my_jump = jump
	my_attack_cooldown = attack_cooldown
	emit_signal("ready_stats",my_health,max_health,my_mana,max_mana,my_damage,
	my_experience,my_max_experience,my_level,my_armor,my_speed,my_jump,my_attack_cooldown);
	


func _physics_process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit(0);
	var now = OS.get_ticks_msec()
	if Input.is_key_pressed(KEY_ALT) and now > next_time_damage:
		take_damage(10)
		next_time_damage = now + cooldown
	if state == STATES.DEAD:
		_animated_sprite.play("Death")
	else:
		get_input(_delta);
		velocity = move_and_slide(velocity,Vector2.UP);

func take_damage(count):
	if state == STATES.DEAD:
		return

	my_health -= count
	if my_health <= 0:
		my_health = 0
		state = STATES.DEAD
		emit_signal("died")

	_animated_sprite.play("Hit")

	emit_signal("health_changed", count)



func get_input(_delta):
	_animated_sprite.speed_scale = 1;
	
	if Input.is_key_pressed(KEY_Q):
		_on_Ennemie_tuto_die(1)
	if !Input.is_key_pressed(KEY_SPACE) and !Input.is_mouse_button_pressed(BUTTON_LEFT) and !Input.is_key_pressed(KEY_D) and !Input.is_key_pressed(KEY_A) and is_on_floor():
		velocity.x = 0;
		_animated_sprite.speed_scale = 0.25;
		_animated_sprite.play("Stop");
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		_animated_sprite.play("Jump");
		velocity.y = -250 * my_jump;
		_animated_sprite.play("Air");
	var now = OS.get_ticks_msec()
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and now > next_time_attack:
		_animated_sprite.speed_scale = 3;
		_animated_sprite.play("Attack");
		var target = _raycast.get_collider()
		if target != null:
				target._hited(my_damage)
		next_time_attack = now + attack_cooldown
	if Input.is_key_pressed(KEY_D):
		_animated_sprite.flip_h = false;
		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
			velocity.x = 100 * my_speed;
		else:
			velocity.x = 80 * my_speed;
		if is_on_floor():
			_animated_sprite.play("Run")
		else:
			_animated_sprite.play("Air");
		_raycast.cast_to = velocity.normalized() * 15
	if Input.is_key_pressed(KEY_A):
		_animated_sprite.flip_h = true;
		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
			velocity.x *= 2
		else:
			velocity.x = -80 * my_speed;
		_raycast.cast_to = velocity.normalized() * 15
		if is_on_floor():
			_animated_sprite.play("Run")
		else:
			_animated_sprite.play("Air");
		
		
	
	
	velocity.y += gravity * _delta;

			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Ennemie_tuto_die(value):
	my_experience += value
	if my_experience >= (my_level * my_max_experience):
		if my_experience == (my_level * my_max_experience):
			my_experience = 0
		elif my_experience > (my_level * my_max_experience):
			my_experience = my_experience - (my_level * my_max_experience)
		my_level += 1
		emit_signal("level_up",my_experience,my_max_experience,my_level)
	emit_signal("exp_up",my_experience)
