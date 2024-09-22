extends Control

@export var gradient : Gradient

var colorStep = 0;
var colorStepSpeed = 0.1;

var runs : Array[Run]
var runLabels : Array[Label]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Info/Window/Panel/ScrollContainer/VBoxContainer/VersionLabel.text = "   " + ProjectSettings.get_setting("application/config/version")
	
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

func refresh_runs():
	for i in range(runLabels.size()):
		var label = runLabels[0]
		runLabels.remove_at(0)
		label.queue_free()
	
	for i in range(runs.size()):
		var label = Label.new()
		label.name = "RunLabel"
		label.text = str(runs[i].start) + "-" + str(runs[i].end)
		$Panel/ScrollContainer/MarginContainer/VBoxContainer/AllRuns.add_child(label)
		runLabels.append(label)
		
		if(runs[i].start == 0):
			$Panel/ScrollContainer/MarginContainer/VBoxContainer/ProgressBar.value = runs[i].end

class Run:
	var start : float
	var end : float
