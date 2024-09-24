extends Control

@export var gradient : Gradient

var colorStep = 0;
var colorStepSpeed = 0.1;

var runs : Array[Run]
var runLabels : Array[Label]

var defaultSave = {
	"level_name": "",
	"runs": [
		{
			"start": null,
			"end": null
		}
	]
}

var data = {}

func save_game(dict):
	var saveGame = FileAccess.open("user://gdptsave.json", FileAccess.WRITE)
	var json_string = JSON.stringify(dict)
	saveGame.store_line(json_string)
	saveGame.close()

func load_game():
	if not FileAccess.file_exists("user://gdptsave.json"): #User hasn't played the game before
		return defaultSave
	var saveGame = FileAccess.open("user://gdptsave.json", FileAccess.READ)
	while saveGame.get_position() < saveGame.get_length(): # User has played the game before
		var json_string = saveGame.get_line()
		var json = JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data = json.get_data()
		saveGame.close()
		return node_data


# Called when the node enters the scene tree for the first time.
func _ready():
	$Info/Window/Panel/ScrollContainer/VBoxContainer/VersionLabel.text = "   " + ProjectSettings.get_setting("application/config/version")
	
	data = load_game()
	##save_game(defaultSave)
	
	$Panel/ScrollContainer/MarginContainer/VBoxContainer/LineEdit.text = data.level_name
	
	for i in data.runs:
		var run = Run.new()
		if i.start != null && i.end != null:
			run.start = i.start
			run.end = i.end
			runs.append(run)
		print(i)
	
	refresh_runs()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_change_bg_color(delta)

func _change_bg_color(delta):
	if colorStep >= 1:
		colorStep = 0
	
	colorStep += delta * colorStepSpeed
	
	RenderingServer.set_default_clear_color(gradient.sample(colorStep))

func _open_credits_window():
	$Info/Window.show()

func _open_addrun_window():
	$AddRunWindow.show()

func _add_run():
	var start = float($AddRunWindow/Panel/VBoxContainer/HBoxContainer/StartRunEdit.text)
	var end = float($AddRunWindow/Panel/VBoxContainer/HBoxContainer2/EndRunEdit.text)
	
	var run = Run.new()
	run.start = start
	run.end = end
	
	runs.append(run)
	
	refresh_runs()
	
	$AddRunWindow.hide()

func _remove_run(start : float, end : float):
	for i in range(runs.size()):
		if runs[i].start == start && runs[i].end == end:
			print("correct run found, deleting")
			runs.remove_at(i)
			break
		else:
			print("incorrect run")
	
	refresh_runs()

func refresh_runs():
	for i in range(runLabels.size()):
		var label = runLabels[0]
		runLabels.remove_at(0)
		label.queue_free()
	
	for i in range(runs.size()):
		var currRun = Run.new()
		currRun.start = runs[i].start
		currRun.end = runs[i].end
		
		var label = Label.new()
		label.name = "RunLabel"
		label.text = str(runs[i].start) + "-" + str(runs[i].end)
		
		var btn = Button.new()
		btn.name = "RunDelete"
		btn.text = "Remove Run"
		label.add_child(btn)
		btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		btn.set_anchor_and_offset(SIDE_LEFT, 0, 914)
		btn.button_down.connect(_remove_run.bind(currRun.start, currRun.end))
		
		$Panel/ScrollContainer/MarginContainer/VBoxContainer/AllRuns.add_child(label)
		runLabels.append(label)
		
		if(runs[i].start == 0):
			$Panel/ScrollContainer/MarginContainer/VBoxContainer/ProgressBar.value = runs[i].end
	
	data.level_name = $Panel/ScrollContainer/MarginContainer/VBoxContainer/LineEdit.text
	
	for i in runs:
		data.runs.remove_at(0)
	
	for i in runs:
		data.runs.append({"start": null, "end": null})
	
	for i in range(runs.size()):
		data.runs[i].start = runs[i].start
		data.runs[i].end = runs[i].end
	
	save_game(data)

class Run:
	var start : float
	var end : float
