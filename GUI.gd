extends MarginContainer

onready var hp_bar = $H/MC/NinePatchRect/Life_bar
onready var exp_bar = $H/MC/NinePatchRect/Exp_bar
onready var number = $H/MC/NinePatchRect/Life
onready var niveau = $H/MC/NinePatchRect/Margin_niveau/Niveau
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_player_level_up(value):
	hp_bar.max_value += value
	hp_bar.value = hp_bar.max_value

func _on_Player_health_changed(damage):
	hp_bar.value -= damage
	if(hp_bar.value <= 30):
		hp_bar.tint_progress = Color("ff1e00")
	number.text = str(hp_bar.value) + "/" + str(hp_bar.max_value)



func _on_Player_ready_stats(my_health,max_health,my_mana,max_mana,my_damage,
	my_experience,my_max_experience,my_level,my_armor,my_speed,my_jump,my_attack_cooldown):
	hp_bar.tint_progress = Color("c1ff00")
	hp_bar.max_value = max_health
	hp_bar.value = my_health
	exp_bar.max_value = my_max_experience
	exp_bar.value = my_experience
	niveau.text = str(my_level)
	
	number.text =  str(hp_bar.value) + "/" + str(hp_bar.max_value)



func _on_Player_exp_up(value):
	exp_bar.value = value
	


func _on_Player_level_up():
	# TODO
	pass
