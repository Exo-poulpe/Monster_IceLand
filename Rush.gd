extends TextureRect


signal Rush
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var cooldown : float
var MouseOver = false
var my_cooldown = cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	my_cooldown = 0


func _input(event):
	if self.visible == false:
		return
	var  now = OS.get_ticks_msec()
	if now >= my_cooldown:
		if (event is InputEventMouseButton):
			if MouseOver == true:
				Execute_skill()
		if Input.is_key_pressed(KEY_1):
				Execute_skill()
		my_cooldown = now + cooldown
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func Execute_skill():
	emit_signal("Rush")

func _on_Skill1_mouse_entered():
	MouseOver = true
