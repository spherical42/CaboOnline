extends Control

var gametypes = {
	0 : 4,
	1 : 6,
	2 : 8
}

var numopps = {
	0 : 1,
	1 : 2,
	2 : 3
}


func _on_play_button_up() -> void:
	if ($Control/numcards.selected != -1)&&($Control/numopps.selected != -1):
		Connection.gametype = gametypes[$Control/numcards.selected]
		Connection.numbots = numopps[$Control/numopps.selected]
		Connection.botdiff = $Control/diff.selected
		get_tree().change_scene_to_file("res://main/games/solo.tscn")
