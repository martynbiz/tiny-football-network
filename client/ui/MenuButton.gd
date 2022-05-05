extends Button

export(String, FILE, "*.tscn") var reference_path
export (bool) var start_focused = false

export var data = 0

## 
func _ready():

	# select the first selected button
	if start_focused:
		grab_focus()

## This is the default behaviour for when a button is focused
## If the button owner has a custom function, we'll use that
func _on_MenuButton_focus_entered():

	# owner custom/ override
	if owner.has_method("_on_MenuButton_focus_entered"):
		owner._on_MenuButton_focus_entered(self)

## button clicked
func _on_MenuButton_pressed():
	
	# if no reference path given, we'll use our own custom defined behaviour
	if owner.has_method("_on_MenuButton_pressed"):
		owner._on_MenuButton_pressed(self)
