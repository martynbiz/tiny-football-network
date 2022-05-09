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

func _ready():
	
	# attempt to connect with token 
	# ERRORS
	# See: https://docs.godotengine.org/en/3.1/classes/class_file.html#class-file-method-open-encrypted-with-pass
	# See: https://docs.godotengine.org/en/3.1/classes/class_@globalscope.html#enum-globalscope-error 
	var token := SessionFileWorker.recover_session_token(email, password)
	if token:
		var new_session = Online.nakama_client.restore_session(token)
		if new_session.valid and not new_session.expired:
			Online.set_nakama_session(new_session)
			yield(Engine.get_main_loop(), "idle_frame")
			handle_successful_login()

func do_login(save_credentials: bool = false):

	# 
	var new_session = yield(Online.nakama_client.authenticate_email_async(email, password, null, false), "completed")
	
	if new_session.is_exception():
	
		var msg = new_session.get_exception().message
		print("Error: %s" % msg)
		
		# Clear stored email and password, but leave the fields alone so the
		# user can attempt to correct them.
		email = ''
		password = ''
		
		# We always set Online.new_session in case something is yielding
		# on the "session_changed" signal.
		Online.nakama_session = null

	else:

		# store token 
		if save_credentials:
			SessionFileWorker.write_auth_token(email, new_session.token, password)

		Online.set_nakama_session(new_session)

		handle_successful_login()

func handle_successful_login():

	if not Server.is_connected:
		Server.connect_to_server()

	if not Online.is_nakama_socket_connected():
		Online.connect_nakama_socket()

	load_screen(Constants.HOME_SCREEN_SCENE_PATH)

func _on_LoginButton_pressed():
	email = login_email_field.text.strip_edges()
	password = login_password_field.text.strip_edges()
	do_login($Control/TabContainer/Login/GridContainer/SaveCheckBox.pressed)

func _on_CreateAccountButton_pressed():
	email = email_field.text.strip_edges()
	password = password_field.text.strip_edges()
	
	var username = username_field.text.strip_edges()
	var save_credentials = save_checkbox.pressed
	
	if email == '':
		print("Must provide email")
		return
	if password == '':
		print("Must provide password")
		return
	if username == '':
		print("Must provide username")
		return
	
	visible = false

	var new_session = yield(Online.nakama_client.authenticate_email_async(email, password, username, true), "completed")
	
	if new_session.is_exception():
		visible = true
		
		var msg = new_session.get_exception().message
		
		# Nakama treats registration as logging in, so this is what we get if the
		# the email is already is use but the password is wrong.
		if msg == 'Invalid credentials.':
			msg = 'E-mail already in use.'
		elif msg == '':
			msg = "Unable to create account"
		print(msg)
		
		# We always set Online.new_session in case something is yielding
		# on the "session_changed" signal.
		Online.new_session = null
	else:

		# store token 
		if save_credentials:
			SessionFileWorker.write_auth_token(email, new_session.token, password)

		Online.set_nakama_session(new_session)

class SessionFileWorker:
	const AUTH := "user://auth"

	static func write_auth_token(email: String, token: String, password: String):
		var file := File.new()

		file.open_encrypted_with_pass(AUTH, File.WRITE, password)

		file.store_line(email)
		file.store_line(token)

		file.close()

	static func recover_session_token(email: String, password: String) -> String:
		var file := File.new()
		var error := file.open_encrypted_with_pass(AUTH, File.READ, password)

		print("error: ", error)
		
		if error == OK:
			var auth_email := file.get_line()
			var auth_token := file.get_line()
			file.close()

			if auth_email == email:
				return auth_token

		return ""
