extends PanelContainer
var val : int
var up = false
var pos = Vector2(0, 0)
var ownerhand = ""

signal entered()

func _ready() -> void:
	$back.visible = !up
	$MarginContainer/contents/valuetxt.text = str(val)

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass # Replace with function body.
