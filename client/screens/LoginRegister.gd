extends BaseScreen

onready var email_field := $"Control/TabContainer/Create Account/GridContainer/Email"
onready var password_field := $"Control/TabContainer/Create Account/GridContainer/Password"
onready var username_field := $"Control/TabContainer/Create Account/GridContainer/Username"
onready var save_checkbox := $"Control/TabContainer/Create Account/GridContainer/SaveCheckBox"

onready var tab_container := $Control/TabContainer
onready var login_email_field := $Control/TabContainer/Login/GridContainer/Email
onready var login_password_field := $Control/TabContainer/Login/GridContainer/Password

var email: String = ''
var password: String = ''

var _server_request_attempts := 0

# Maximum number of times to retry a server request if the previous attempt failed.
const MAX_REQUEST_ATTEMPTS := 3

func _ready():
	pass
	
	# # attempt to connect with token 
	# # ERRORS
	# # See: https://docs.godotengine.org/en/3.1/classes/class_file.html#class-file-method-open-encrypted-with-pass
	# # See: https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html#enum-globalscope-error 
	# var token := SessionFileWorker.recover_session_token(email, password)
	# if token:
	# 	var new_session = Online.nakama_client.restore_session(token)
	# 	if new_session.valid and not new_session.expired:
	# 		Online.set_nakama_session(new_session)
	# 		yield(Engine.get_main_loop(), "idle_frame")
	# 		handle_successful_login()

func _on_LoginButton_pressed():
	email = login_email_field.text.strip_edges()
	password = login_password_field.text.strip_edges()
	# var save_credentials = $Control/TabContainer/Login/GridContainer/SaveCheckBox.pressed
	var do_remember_email = true # TODO test

	print("logging in with creds %s %s" % [email, password])
	yield(authenticate_user_async(email, password, do_remember_email), "completed")


func _on_CreateAccountButton_pressed():
	var email = email_field.text.strip_edges()
	var password = password_field.text.strip_edges()
	var username = username_field.text.strip_edges()
	# var save_credentials = save_checkbox.pressed
	var do_remember_email = true # TODO test

	var result: int = yield(ServerConnection.register_async(email, password, username), "completed")
	if result == OK:
		yield(authenticate_user_async(email, password, do_remember_email), "completed")
	else:
		print("Error code %s: %s" % [result, ServerConnection.error_message])


# Requests the server to authenticate the player using their credentials.
# Attempts authentication up to `MAX_REQUEST_ATTEMPTS` times.
func authenticate_user_async(email: String, password: String, do_remember_email := false) -> int:
	var result := -1

	# login_and_register.is_enabled = false
	while result != OK:
		if _server_request_attempts == MAX_REQUEST_ATTEMPTS:
			break
		_server_request_attempts += 1
		result = yield(ServerConnection.login_async(email, password), "completed")

	if result == OK:
		# if do_remember_email:
		# 	ServerConnection.save_email(email)
		# open_character_menu_async()

		load_screen(Constants.ONLINE_SCREEN_PATH)

		# # Connect to game server 
		# if not Server.is_connected:
		# 	Server.connect_to_server()

	else:
		print("Error code %s: %s" % [result, ServerConnection.error_message])
		# login_and_register.is_enabled = true

	_server_request_attempts = 0
	return result
