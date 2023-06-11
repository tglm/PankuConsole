class_name PankuModuleInteractiveShell extends PankuModule
func get_module_name(): return "InteractiveShell"

var window:PankuLynxWindow
var interactive_shell:Control
var simple_launcher:Control

enum InputMode {
	Window,
	Launcher
}

var gui_mode:InputMode = InputMode.Window
var pause_if_input:bool = true

func get_intro() -> String:
	var intro:PackedStringArray = PackedStringArray()
	intro.append("[font_size=24][b][color=#478cbf]Panku Console[/color] ~ [color=#478cbf]version %s[/color][/b][/font_size]" % core.Utils.get_plugin_version())
	intro.append("")
	intro.append("All-in-One Godot 4 runtime debugging tool.")
	intro.append("")
	intro.append("[b][color=#478cbf]🌟Repo[/color][/b]: 🔗[url=https://github.com/Ark2000/PankuConsole]https://github.com/Ark2000/PankuConsole[/url]")
	intro.append("")
	intro.append("[b][color=#478cbf]❤️Contributors[/color][/b]: 🔗[url=https://github.com/Ark2000]Ark2000(Feo Wu)[/url], 🔗[url=https://github.com/scriptsengineer]scriptengineer(Rafael Correa)[/url], 🔗[url=https://github.com/winston-yallow]winston-yallow(Winston)[/url], 🔗[url=https://github.com/CheapMeow]CheapMeow[/url].")
	intro.append("")
	intro.append("> Tips: you can always access current scene root by `[b]current[/b]`.")
	intro.append("")
	return "\n".join(intro)

func init_module():
	# register env
	var env = preload("./env.gd").new()
	env._module = self
	core.register_env("interactive_shell", env)

	interactive_shell = preload("./console_ui/panku_console_ui.tscn").instantiate()
	window = core.create_window(interactive_shell)
	window.queue_free_on_close = false
	window.set_caption("Interative Shell V2")
	window.hide_options_button()
	load_window_data(window)

	interactive_shell.output(get_intro())

	simple_launcher = preload("./mini_repl_2.tscn").instantiate()
	simple_launcher.console = core
	core.add_child(simple_launcher)
	simple_launcher.hide()

	core.toggle_console_action_just_pressed.connect(
		func():
			if gui_mode == InputMode.Window:
				window.visible = not window.visible
			elif gui_mode == InputMode.Launcher:
				simple_launcher.visible = not simple_launcher.visible
	)

	gui_mode = load_module_data("gui_mode", InputMode.Window)
	pause_if_input = load_module_data("pause_if_input", true)

	var update_gui_state = func():
		var is_gui_open = window.visible or simple_launcher.visible
		if is_gui_open and pause_if_input:
			Engine.time_scale = 0.01
		else:
			Engine.time_scale = 1.0

	window.visibility_changed.connect(update_gui_state)
	simple_launcher.visibility_changed.connect(update_gui_state)
	update_gui_state.call()

func quit_module():
	save_window_data(window)
	save_module_data("gui_mode", gui_mode)
	save_module_data("pause_if_input", pause_if_input)

func open_window():
	Engine.time_scale = 0.01
	if gui_mode == InputMode.Window:
		if not window.visible:
			window.show()
		else:
			core.notify("The window is alreay opened.")
	elif gui_mode == InputMode.Launcher:
		gui_mode = InputMode.Window
		simple_launcher.hide()
		window.show()

func open_launcher():
	Engine.time_scale = 0.01
	if gui_mode == InputMode.Window:
		gui_mode = InputMode.Launcher
		window.hide()
		simple_launcher.show()
	elif gui_mode == InputMode.Launcher:
		if not simple_launcher.visible:
			simple_launcher.show()
		else:
			core.notify("The launcher is alreay opened.")
