extends KinematicBody2D

signal die

onready var _animated_sprite = $AnimatedSprite
onready var _collision = $CollisionShape2D
onready var _dialogue = $TextureRect

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

export (int) var gravity = 300
enum STATES {ALIVE, DEAD}
enum MODES {IDLE, ATTACK,RUN,FEAR,DEAD,HIT}
var state = STATES.ALIVE
var mode = MODES.IDLE
var velocity = Vector2()
var send_exp = false
var count_frame = 0
var limit_frame = 25


func _hited(damage_value):
	my_health -= damage_value
	mode = MODES.HIT
	_animated_sprite.play("Hit")
	if my_health < int(max_health / 2):
		mode = MODES.ATTACK
	if my_health <= 0:
		state = STATES.DEAD
		_animated_sprite.play("Death")

func _process(_delta):
	if state == STATES.DEAD:
		if !send_exp:
			_animated_sprite.play("Death")
			_dialogue.visible = false
			emit_signal("die",level * 10 + armor + damage)
			send_exp = true
		else:
			_animated_sprite.play("End")
			_collision.disabled = true
			
			
	elif state == STATES.ALIVE:
		if mode == MODES.HIT:
			count_frame += 1
			_animated_sprite.play("Hit")
			if count_frame >= limit_frame:
				mode = MODES.IDLE
				count_frame = 0
		elif mode == MODES.ATTACK:
			_animated_sprite.play("Attack")
		elif mode == MODES.IDLE:
			_animated_sprite.play("Idle")
	else:
		velocity.y += gravity * _delta;
		velocity = move_and_slide(velocity,Vector2.UP);

# Called when the node enters the scene tree for the first time.
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
