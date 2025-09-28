extends PanelContainer
var val : int
var up := false : 
	set(n): 
		up = n
		set_up()
var ownerhand = ""
var row = "top"

var rows = {
	bot = 0,
	top = 1
}

signal entered(h, r, p)
signal exited()


func _ready() -> void:
	$back.visible = !up
	$MarginContainer/contents/valuetxt.text = str(val)

func _on_mouse_entered() -> void:
	var r = rows.row
	var p = get_parent().get_children().find(self)
	entered.emit(ownerhand, r, p)


func _on_mouse_exited() -> void:
	
	exited.emit()


func set_up():
	$back.visible = !up
