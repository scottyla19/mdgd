extends Control

var app_name = "mdgd"
var current_file = "Untitled"

func _ready():
	update_window_title()
	$MenuButtonFile.get_popup().connect("id_pressed", self, "_on_menu_item_pressed")

func update_window_title():
	OS.set_window_title(app_name + " - " + current_file)
	
func _on_menu_item_pressed(id):
	var item_name = $MenuButtonFile.get_popup().get_item_text(id)
	if item_name == "New":
		new_file()
	elif item_name == "Open":
		$OpenFileDialog.popup()
	elif item_name == "Save":
		save_file()
	elif item_name == "Save As":
		$SaveFileDialog.popup()
	elif item_name == "Quit":
		get_tree().quit()

func new_file():
	current_file =  "Untitled"
	update_window_title()
	$EditorSplitContainer/EditorPane/TextEdit.text = ""
	$EditorSplitContainer/PreviewPane/Preview.text = ""
	
func save_file():
	var path = current_file
	if path == "Untitled":
		$SaveFileDialog.popup()
	else:
		var f = File.new()
		f.open(path, 2)
		f.store_string($EditorSplitContainer/EditorPane/TextEdit.text)
		f.close()
		
func _on_OpenFileDialog_file_selected(path):
	var f = File.new()
	f.open(path, File.READ)
	$EditorSplitContainer/EditorPane/TextEdit.text = f.get_as_text()
	$EditorSplitContainer.parse_markdown(f.get_as_text())
	f.close()
	current_file = path
	update_window_title()

func _on_SaveFileDialog_file_selected(path):
	var f = File.new()
	f.open(path, 2)
	f.store_string($EditorSplitContainer/EditorPane/TextEdit.text)
	f.close()
	current_file = path
	update_window_title()

func _on_Preview_meta_clicked(meta):
	OS.shell_open(str(meta))
