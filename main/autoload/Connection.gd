extends Node2D

const PLAT := "DEV v0.0"

const KEY := "bigboykey"

const HOST := "localhost"
const PORT := 7350

var _session : NakamaSession

var _client := Nakama.create_client(KEY, HOST, 7350, 'http')

var _socket : NakamaSocket

var _match_id := ""
var _presences := {}

var username

enum OpCode {
	JoinUpdate = 0
}


#signals here

func auth_async(email: String, passw: String, uname, logORreg: bool):
	var result = "good"
	
	var new_session = await _client.authenticate_email_async(email, passw, uname, logORreg)
	
	if not new_session.is_exception():
		_session = new_session
		username = _session.username
	else:
		result = new_session.get_exception().message
	
	
	return result


func connect_server_async():
	_socket = Nakama.create_socket_from(_client)
	var result : NakamaAsyncResult = await _socket.connect_async(_session)
	if not result.is_exception():
		_socket.closed.connect(self._on_Socket_closed)
		_socket.connected.connect(self._on_Socket_connected)
		_socket.connection_error.connect(self._on_Socket_connection_error)
		_socket.received_error.connect(self._on_Socket_received_error)
		_socket.received_match_state.connect(self._on_Socket_received_match_state)
		_socket.received_match_presence.connect(self._on_Socket_received_match_presence)
		
		print("socket connected")
		
		
		
		return OK
		
	
	return ERR_CANT_CONNECT



func join_match_async(matchid, spec = false):
	if not _socket:
		print("error not connected")
		return
	
	
	if matchid:
		var match_join_result : NakamaRTAPI.Match = await _socket.join_match_async(matchid)
		if match_join_result.is_exception():
			var exception : NakamaException = match_join_result.get_exception()
			print("err joining match %s - %s" % [exception.status_code, exception.message])
			return
		
		_match_id = matchid
		
		# send a nothing update so we get all of the data on the other players
		var payload := {id = _session.user_id}
		_socket.send_match_state_async(_match_id, OpCode.JoinUpdate, JSON.stringify(payload))
		
		
		for presence in match_join_result.presences:
			_presences[presence.user_id] = presence
		if _presences == {}:
			_presences = {"nobody" = 0}
	
	print(str(_presences))
	return _presences


func leave_match_async():
	var match_leave_result : NakamaAsyncResult = await _socket.leave_match_async(_match_id)
	if match_leave_result.is_exception():
		var exception : NakamaException = match_leave_result.get_exception()
		print("err leaving match %s - %s" % [exception.status_code, exception.message])

func create_match_async(_payload):
	var match_id = await _client.rpc_async(_session, "create_match", _payload)
	print(str(match_id.payload))
	pass


func get_elo_async():
	if not _socket:
		print("error not connected")
		return
	return await _client.rpc_async(_session, "get_elo")

func find_matches_async(pmap, ptype):
	var _payload = str(pmap)+str(ptype)
	var _matches = await _client.rpc_async(_session, "get_matches", _payload)
	print(str(_matches))
	_matches = _matches.payload
	
	_matches = JSON.parse_string(_matches)
	print(str(_matches))
	
	var _ids := []
	for i in _matches.size():
		_ids.append(_matches[i].get("match_id"))
		print(str(_matches[i].get("size")))
		print(_matches[i].get("label"))
		_ids[i] = _ids[i].insert(0,str(_matches[i].get("size")))
		#adds the number of players in the match onto the beginning of the id string, gets taken out in the selectable match code
	print(_ids)
	
	return _ids



func sendReady():
	if _socket:
		var payload := {id = _session.user_id}
		#_socket.send_match_state_async(_match_id, OpCode.something, JSON.stringify(payload))

func _on_Socket_closed():
	_socket = null
func _on_Socket_connected():
	pass


func _on_Socket_connection_error(err):
	print("Unable to connect with code %s" % err)
	_socket = null
func _on_Socket_received_error(err):
	print(str(err))
	_socket = null



func _on_Socket_received_match_state(match_state: NakamaRTAPI.MatchData):
	var code := match_state.op_code
	var raw := match_state.data
	
	match code:
		_: pass



func _on_Socket_received_match_presence(_new_presences: NakamaRTAPI.MatchPresenceEvent):
	pass


func disc():
	_socket.close()
	


func save_token():
	pass
