extends Button


func _on_Button_pressed():
	get_node("../../../..").load_next()
