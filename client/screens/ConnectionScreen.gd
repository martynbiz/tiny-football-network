extends BaseScreen # Control

# var ui_layer: UILayer

# func _setup_screen(_ui_layer: UILayer):
# 	ui_layer = _ui_layer

# func _show_screen(_info: Dictionary = {}):
# 	pass

func _hide_screen():
	pass

onready var tab_container := $Control/TabContainer
onready var login_email_field := $Control/TabContainer/Login/GridContainer/Email
onready var login_password_field := $Control/TabContainer/Login/GridContainer/Password

const CREDENTIALS_FILENAME = 'user://credentials.json'

var email: String = ''
var password: String = ''

var _reconnect: bool = false
var _next_screen

func _ready():
	var file = File.new()
	if file.file_exists(CREDENTIALS_FILENAME):
		file.open(CREDENTIALS_FILENAME, File.READ)
		var result := JSON.parse(file.get_as_text())
		if result.result is Dictionary:
			email = result.result['email']
			password = result.result['password']
			login_email_field.text = email
			login_password_field.text = password
		file.close()

func _save_credentials():
	var file = File.new()
	file.open(CREDENTIALS_FILENAME, File.WRITE)
	var credentials = {
		email = email,
		password = password,
	}
	file.store_line(JSON.print(credentials))
	file.close()

# func _show_screen(info: Dictionary = {}):
# 	_reconnect = info.get('reconnect', false)
# 	_next_screen = info.get('next_screen', 'MatchScreen')
	
# 	tab_container.current_tab = 0
	
# 	# If we have a stored email and password, attempt to login straight away.
# 	if email != '' and password != '':
# 		do_login()

func do_login(save_credentials: bool = false):
	visible = false
	
	if _reconnect:
		# ui_layer.show_message("Session expired! Reconnecting...")
		print("Session expired! Reconnecting...")
	else:
		# ui_layer.show_message("Logging in...")
		print("Logging in...")
	
	var nakama_session = yield(Online.nakama_client.authenticate_email_async(email, password, null, false), "completed")
	
	if nakama_session.is_exception():
		visible = true
		# ui_layer.show_message("Login failed!")
		print("Login failed!")
		
		# Clear stored email and password, but leave the fields alone so the
		# user can attempt to correct them.
		email = ''
		password = ''
		
		# We always set Online.nakama_session in case something is yielding
		# on the "session_changed" signal.
		Online.nakama_session = null
	else:
		if save_credentials:
			_save_credentials()
		Online.nakama_session = nakama_session
		# ui_layer.hide_message()
		
		# if _next_screen:
		# 	# ui_layer.show_screen(_next_screen)
		# 	load_screen(_next_screen)

		Server.connect_to_server()

		load_screen("Home")

func _on_LoginButton_pressed():
	print("_on_LoginButton_pressed")
	email = login_email_field.text.strip_edges()
	password = login_password_field.text.strip_edges()
	do_login($Control/TabContainer/Login/GridContainer/SaveCheckBox.pressed)

func _on_CreateAccountButton_pressed():
	email = $"Control/TabContainer/Create Account/GridContainer/Email".text.strip_edges()
	password = $"Control/TabContainer/Create Account/GridContainer/Password".text.strip_edges()
	
	var username = $"Control/TabContainer/Create Account/GridContainer/Username".text.strip_edges()
	var save_credentials = $"Control/TabContainer/Create Account/GridContainer/SaveCheckBox".pressed
	
	if email == '':
		# ui_layer.show_message("Must provide email")
		print("Must provide email")
		return
	if password == '':
		# ui_layer.show_message("Must provide password")
		print("Must provide password")
		return
	if username == '':
		# ui_layer.show_message("Must provide username")
		print("Must provide username")
		return
	
	visible = false
	# ui_layer.show_message("Creating account...")
	print("Creating account...")

	var nakama_session = yield(Online.nakama_client.authenticate_email_async(email, password, username, true), "completed")
	
	if nakama_session.is_exception():
		visible = true
		
		var msg = nakama_session.get_exception().message
		# Nakama treats registration as logging in, so this is what we get if the
		# the email is already is use but the password is wrong.
		if msg == 'Invalid credentials.':
			msg = 'E-mail already in use.'
		elif msg == '':
			msg = "Unable to create account"
		# ui_layer.show_message(msg)
		print(msg)
		
		# We always set Online.nakama_session in case something is yielding
		# on the "session_changed" signal.
		Online.nakama_session = null
	else:
		if save_credentials:
			_save_credentials()
		Online.nakama_session = nakama_session
		# ui_layer.hide_message()
		# ui_layer.show_screen("MatchScreen")
