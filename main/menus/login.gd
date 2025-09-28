extends Control

const MAX = 5

func _ready() -> void:
	$start.show()
	$credentials.hide()
	

func _on_login_button_up() -> void:
	$start.hide()
	$credentials.show()



func _on_confirm_button_up() -> void:
	var email = $credentials/uname.text + "@gmail.com"
	var uname = $credentials/uname.text
	var passw = $credentials/pword.text
	
	print("autenticating %s" % email)
	
	var result = await Connection.auth_async(email, passw, uname, true)
	
	if result == "good":
		print("%s authentiated" % email)
		var x = 0
		while x < MAX:
			var conresult = await conncect_to_server()
			if conresult == OK:
				return
			else: x+=1
		
	else:
		print("%s NOT authentiated" % email)
		$errtext.show()
		$errtext.text = str(result)


func _on_back_button_up() -> void:
	_ready()

func conncect_to_server() -> int:
	var result : int = await Connection.connect_server_async()
	if result == OK:
		print("connected")
		$start.hide()
		$credentials.hide()
		$connected.show()
		await get_tree().create_timer(1).timeout
		
		#go to multiplayer scene
	else:
		print("could not connect")
		
	return result


func _on_singleplayer_button_up() -> void:
	#go to solo gamne
	pass
