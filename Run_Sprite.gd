extends KinematicBody2D



onready var _animated_sprite = $AnimatedSprite
onready var _animated_player = $AnimationPlayer
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
enum MODES {IDLE,RUN,ATTACK,HIT,DEATH}
var state = STATES.ALIVE
var mode = MODES.IDLE
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
	
func UnHideSprite(name):
	if name == "Idle":
		$Idle.visible = true
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Attack.visible = false
		$Run.visible = false
		$Air.visible = false
		$Death.visible = false
	elif name == "Run":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Attack.visible = false
		$Air.visible = false
		$Run.visible = true
		$Death.visible = false
	elif name == "Air":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Attack.visible = false
		$Run.visible = false
		$Air.visible = true
		$Death.visible = false
	elif name == "Attack":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Air.visible = false
		$Run.visible = false
		$Attack.visible = true
		$Death.visible = false
	elif name == "Death":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Air.visible = false
		$Run.visible = false
		$Attack.visible = false
		$Death.visible = true
	elif name == "GameOver":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Air.visible = false
		$Run.visible = false
		$Attack.visible = false
		$Death.visible = false
		$OverPanel.visible = true
#	elif name == "Attack":
#		$Idle.visible = false
#		$Hit.visible = false
#		$Death.visible = false
#		$End.visible = false
#		$Attack.visible = true
#	elif name == "End":
#		$Idle.visible = false
#		$Hit.visible = false
#		$Death.visible = false
#		$End.visible = true
#		$Attack.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		_animated_player.stop()
		mode = MODES.DEATH
		UnHideSprite("GameOver")
		_animated_player.play("GameOver")
		_animated_player.connect("animation_finished",self,"GameOver")
	elif anim_name == "GameOver":
		_animated_player.stop()
		mode = MODES.DEATH
	elif anim_name == "Idle":
		mode = MODES.IDLE
	elif anim_name == "Attack":
		mode = MODES.IDLE
		UnHideSprite("Idle")
		_animated_player.play("Idle")

func _physics_process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit(0);
	var now = OS.get_ticks_msec()
	if Input.is_key_pressed(KEY_ALT) and now > next_time_damage:
		take_damage(50)
		next_time_damage = now + cooldown
	else:
		get_input(_delta);
		velocity = move_and_slide(velocity,Vector2.UP);

func take_damage(count):
	if state == STATES.DEAD:
		return
	my_health -= count
	if my_health <= 0:
		my_health = 0
		velocity.x = 0
		velocity.y = 0
		UnHideSprite("Death")
		_animated_player.play("Death")
		_animated_player.connect("animation_finished",self,"DeathEnd")
		emit_signal("died")
	else:
		UnHideSprite("Hit")
		_animated_player.play("Hit")

	emit_signal("health_changed", count)


func get_input(_delta):
	if state == STATES.DEAD:
		return
	if !Input.is_key_pressed(KEY_SPACE) and !Input.is_mouse_button_pressed(BUTTON_LEFT) and !Input.is_key_pressed(KEY_D) and !Input.is_key_pressed(KEY_A) and is_on_floor():
		velocity.x = 0;
		mode = MODES.IDLE
		UnHideSprite("Idle")
		_animated_player.play("Idle")
		_animated_player.connect("animation_finished",self,"IdleEnd")
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		_animated_sprite.play("Jump");
		velocity.y = -250 * my_jump;
		UnHideSprite("Air")
		_animated_player.play("Air")
	if Input.is_key_pressed(KEY_D):
		direction_setter(0)
		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
			velocity.x = 150 * my_speed;
		else:
			velocity.x = 150 * my_speed;
		if is_on_floor():
			UnHideSprite("Run")
			_animated_player.play("Run")
		else:
			UnHideSprite("Air")
			_animated_player.play("Air")
		_raycast.cast_to = velocity.normalized() * 15
	var now = OS.get_ticks_msec()
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and now > next_time_attack:
		UnHideSprite("Attack")
		_animated_player.play("Attack")
		_animated_player.connect("animation_finished",self,"IdleEnd")
		mode = MODES.ATTACK
		var target = _raycast.get_collider()
		if target != null:
				target._hited(my_damage)
		next_time_attack = now + attack_cooldown
	if Input.is_key_pressed(KEY_A):
		direction_setter(1)
		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
			velocity.x = -150 * my_speed
		else:
			velocity.x = -150 * my_speed;
		_raycast.cast_to = velocity.normalized() * 15
		if is_on_floor():
			UnHideSprite("Run")
			_animated_player.play("Run")
		else:
			UnHideSprite("Air")
			_animated_player.play("Air")
		
	velocity.y += gravity * _delta;
	

#func get_input(_delta):
#	if state == STATES.DEAD:
#		return
##	_animated_player.playback_speed = 1
#	if Input.is_key_pressed(KEY_Q):
#		my_experience += 1
#	if !Input.is_key_pressed(KEY_SPACE) and !Input.is_mouse_button_pressed(BUTTON_LEFT) and !Input.is_key_pressed(KEY_D) and !Input.is_key_pressed(KEY_A) and is_on_floor():
#		velocity.x = 0;
#		UnHideSprite("Idle")
#		_animated_player.play("Idle")
#	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
#		_animated_sprite.play("Jump");
#		velocity.y = -250 * my_jump;
#		UnHideSprite("Air")
#		_animated_player.play("Air")
#	var now = OS.get_ticks_msec()
#	if Input.is_mouse_button_pressed(BUTTON_LEFT) and now > next_time_attack:
#		UnHideSprite("Attack")
#		_animated_player.play("Attack")
#		var target = _raycast.get_collider()
#		if target != null:
#				target._hited(my_damage)
#		next_time_attack = now + attack_cooldown
#	if Input.is_key_pressed(KEY_D):
#		direction_setter(0)
#		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
#			velocity.x = 150 * my_speed;
#		else:
#			velocity.x = 150 * my_speed;
#		if is_on_floor():
#			UnHideSprite("Run")
#			_animated_player.play("Run")
#		else:
#			UnHideSprite("Air")
#			_animated_player.play("Air")
#		_raycast.cast_to = velocity.normalized() * 15
#	if Input.is_key_pressed(KEY_A):
#		direction_setter(1)
#		if Input.is_key_pressed(KEY_SHIFT) and is_on_floor():
#			velocity.x = -150 * my_speed
#		else:
#			velocity.x = -150 * my_speed;
#		_raycast.cast_to = velocity.normalized() * 15
#		if is_on_floor():
#			UnHideSprite("Run")
#			_animated_player.play("Run")
#		else:
#			UnHideSprite("Air")
#			_animated_player.play("Air")
#
#	if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
#		if Input.is_key_pressed(KEY_D):
#			velocity.x += 300
#		if Input.is_key_pressed(KEY_A):
#			velocity.x -= 300
#
#
#	velocity.y += gravity * _delta;

			
func direction_setter(direction):
	if direction == 0:
		$Run.flip_h = false
		$Air.flip_h = false
		$Idle.flip_h = false
		$Attack.flip_h = false
	else:
		$Attack.flip_h = true
		$Run.flip_h = true
		$Air.flip_h = true
		$Idle.flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _hited(value_damage):
	take_damage(value_damage)

func _on_Ennemie_tuto_die(value):
	my_experience += value
	while my_experience >= (my_level * my_max_experience):
		my_experience = my_experience - (my_level * my_max_experience)
		my_level += 1
		emit_signal("level_up",my_experience,my_max_experience,my_level)
	emit_signal("exp_up",my_experience)


func _on_Skill1_Rush():
#	print("Rush skill")
	if Input.is_key_pressed(KEY_D):
		velocity.x += 600
	if Input.is_key_pressed(KEY_A):
		velocity.x -= 600
	if Input.is_key_pressed(KEY_W):
		velocity.y -= 200
	if Input.is_key_pressed(KEY_S):
		velocity.y += 200
	velocity = move_and_slide(velocity,Vector2.UP);
		

func get_class():
	return "Player"

func _on_Player_died():
	$Body.visible = false
	state = STATES.DEAD
	
