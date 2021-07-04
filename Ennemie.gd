extends KinematicBody2D


onready var _animated_player = $AnimationPlayer
onready var _collision = $Body
onready var _dialogue = $Dialogue
onready var _raycast = $RayCast2D

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

enum STATES {ALIVE, DEAD}
enum MODES {IDLE, ATTACK, RUN, FEAR, DEAD, END, HIT}
var state = STATES.ALIVE
var mode = MODES.IDLE
var velocity = Vector2()
var send_exp = false
var attack_on = false

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



func UnHideSprite(name):
	if name == "Idle":
		$Idle.visible = true
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Attack.visible = false
	elif name == "Hit":
		$Idle.visible = false
		$Hit.visible = true
		$Death.visible = false
		$End.visible = false
		$Attack.visible = false
	elif name == "Death":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = true
		$End.visible = false
		$Attack.visible = false
	elif name == "Attack":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = false
		$Attack.visible = true
	elif name == "End":
		$Idle.visible = false
		$Hit.visible = false
		$Death.visible = false
		$End.visible = true
		$Attack.visible = false


func _hited(damage_value):
	my_health -= damage_value
	mode = MODES.HIT
	_animated_player.play("Hit")
	_animated_player.connect("animation_finished",self,"HitEnd")
	UnHideSprite("Hit")

func _process(_delta):
	if mode == MODES.END:
		return
	if my_health <= 0:
		$Dialogue.visible = false
		$Body.disabled = true
		mode = MODES.DEAD
		_animated_player.play("Death")
		_animated_player.connect("animation_finished",self,"DeathEnd")
		UnHideSprite("Death")
		return
	if _animated_player.get_current_animation() == "Attack":
		if _animated_player.get_current_animation_position() >= 0.5 and _animated_player.get_current_animation_position() < 1 and attack_on == true:
			var target = _raycast.get_collider()
			if target != null:
				target._hited(my_damage)
				attack_on = false
	if my_health < int(max_health / 2):
		var target = _raycast.get_collider()
		var now = OS.get_ticks_msec()
		if target != null and now >= my_attack_cooldown:
			mode = MODES.ATTACK
			_animated_player.play("Attack")
			_animated_player.connect("animation_finished",self,"AttackEnd")
			UnHideSprite("Attack")
			attack_on = true
			my_attack_cooldown = now + my_cooldown
			return
	if mode == MODES.IDLE:
		_animated_player.play("Idle")
		if _animated_player.current_animation != "Idle":
			_animated_player.connect("animation_finished",self,"IdleEnd")
		UnHideSprite("Idle")


func _on_AnimationPlayer_animation_finished(anim_name):
	if str(anim_name) == "Death":
		mode = MODES.END
	elif anim_name == "Hit":
		mode = MODES.IDLE
	elif anim_name == "Idle":
		mode = MODES.IDLE
	elif anim_name == "Attack":
		mode = MODES.IDLE


func _on_Player_died():
	self.visible = false


func _on_Zone_body_entered(body):
	if body is KinematicBody2D:
		if body.get_class() == "Player":
			print("Track")
			print(body.position.x)
			print(self.position.x)
			if body.position.x < self.position.x:
				velocity.x -= 10
			else:
				velocity.x += 10
	velocity = move_and_slide(velocity,Vector2.UP)
