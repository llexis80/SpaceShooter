extends Node


const options_path = "user://options.data"

var en_flag = preload("res://Translations/flags/BG.png")
var lv_flag = preload("res://Translations/flags/LV.png")

var locale_list = [
	{"locale": "en", "label": "settings.language.en", "flag": en_flag },
	{"locale": "lv", "label": "settings.language.lv", "flag": lv_flag },
]

var window_size_list = [
	{ "width": 1024, "height": 768 },
	{ "width": 1200, "height": 720 },
	{ "width": 1366, "height": 768 },
	{ "width": 1600, "height": 900 },
	{ "width": 1920, "height": 1080 },
]

func read_options():
	var options = {}
	var file = FileAccess.open(options_path, FileAccess.READ)
	if file:
		options = file.get_var()
		file.close()
	return options

func write_options(options):
	var file = FileAccess.open(options_path, FileAccess.WRITE)
	file.store_var(options)
	file.close()

func set_window_mode():
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	var options = read_options()
	if options.has("full_screen"):
		window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if options.full_screen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(window_mode)
	write_options(options)

#func resize_window():
	#var options = read_options()
	#if not options.has("full_screen") or not options.full_screen:
		#var window_size = Vector2i(options.window_width, options.window_height)
		#var screen_size = DisplayServer.screen_get_size()
		#get_window().size = window_size
		#DisplayServer.window_set_position(Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2))
		
#func resize_window():
	#var options = read_options()
	#if not options.has("full_screen") or not options.full_screen:
		#var window_size = Vector2i(options.window_width, options.window_height)
		#var screen_size = DisplayServer.screen_get_size()
		#get_window().size = window_size
		#DisplayServer.window_set_position(Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2))

func resize_window():
	var options = read_options()
	if not options.has("full_screen") or not options.full_screen:
		# Safely get window_width and window_height, or default to 1024x768
		var width = options.get("window_width", 1024)
		var height = options.get("window_height", 768)
		var window_size = Vector2i(width, height)
		var screen_size = DisplayServer.screen_get_size()
		get_window().size = window_size
		DisplayServer.window_set_position(Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2))

func set_locale():
	var options = read_options()
	if not options.has("locale"):
		options.locale = "en"
	TranslationServer.set_locale(options.locale)
	write_options(options)
