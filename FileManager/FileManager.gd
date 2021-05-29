extends Popup
var start_path :String = ""
onready var path :Node = get_node("ColorRect/VBoxContainer/Path Container/Path")
onready var Folder_button :Node = get_node("ColorRect/VBoxContainer/ScrollContainer/Button Container")
onready var new_folder :Popup = get_node("New Folder")
var pc_mode :bool = false
signal Selected(location)

var default_paths :Dictionary = {
	"android" : "/storage/emulated/0/",
	"pc" : str(OS.get_executable_path().get_base_dir(), "/")
}

#func _ready():
#	popup()

func _on_File_Manager_about_to_show():
	for button in Folder_button.get_child_count():
		Folder_button.get_child(button).queue_free()
	
	# initializing start_path
	var test_dir := Directory.new()
	
	if start_path == "" || test_dir.open(start_path) != OK:
		print("failed to open given path.., Switching to Default path...")
		
		if OS.get_name() == "Android":
			start_path = default_paths.android
			var _err = OS.request_permissions()
		else:
			start_path = default_paths.pc
			pc_mode = true
			print("pc mode")
	
	path.text = start_path
	
	Directories_at_path(path.text)


func Go_to(folder_name):
	if Folder_button.get_parent().swiping:
		return
	var dir:Directory = Directory.new()
	if dir.dir_exists(str(path.text,folder_name,"/")):
		Directories_at_path(str(path.text,folder_name,"/"))
		path.text = str(path.text,folder_name,"/")


func _on_Up_Directory_pressed():
	if not pc_mode:
		if path.text == start_path:
			Directories_at_path(start_path)
			return
	var dir :Directory = Directory.new()
	var err_a = dir.open(path.text)
	if err_a == OK:
		var err_b = dir.change_dir("..")
		if err_b == OK:
			path.text = dir.get_current_dir()
			if not path.text.ends_with("/"):
				path.text = str(path.text, "/")
	Directories_at_path(path.text)


func _on_New_Folder_pressed():
	new_folder.popup()


func _on_Cancel_pressed():
	new_folder.hide()


func _on_Create_pressed():
	var dir :Directory = Directory.new()
	if dir.dir_exists(str(path.text,new_folder.get_node("Panel/name of New").text,"/")):
		return
	path.text = str(path.text,new_folder.get_node("Panel/name of New").text,"/")
	new_folder.hide()
	var error = dir.make_dir_recursive(path.text)
	if error != OK:
		return
	Directories_at_path(path.text)


func Directories_at_path(read_path):
	var log_Dirs = []
	var dir = Directory.new()
	if dir.dir_exists(read_path):
		dir.open(read_path)
		dir.list_dir_begin()
		while true:
			var Folders = dir.get_next()
			if Folders == "":
				break
			elif not "." in Folders:
				log_Dirs.append(Folders)
		refresh_list(log_Dirs)
	dir.list_dir_end()


func refresh_list(new_dir :Array):
	#clear old buttons
	for button in Folder_button.get_child_count():
		Folder_button.get_child(button).queue_free()
	#add new buttons
	var button_path = load("res://FileManager/UI/Folder Button.tscn")
	for name in new_dir:
		var new_button = button_path.instance()
		new_button.get_node("Name").text = name
		new_button.connect("pressed",self,"Go_to",[name])
		Folder_button.add_child(new_button)


func _on_Close_manager_pressed():
	new_folder.hide()
	hide()



func _on_Select_folder_pressed():
	emit_signal("Selected",path.text)
	hide()


func _on_Home_pressed():
	path.text = start_path
	Directories_at_path(path.text)


func _on_name_of_New_gui_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			new_folder.get_node("Panel/name of New").text = str(new_folder.get_node("Panel/name of New").get_line(0),new_folder.get_node("Panel/name of New").get_line(1))


func _on_New_Folder_about_to_show():
	new_folder.get_node("Panel/name of New").text = ""
