extends Control

@export var gradient : Gradient

var colorStep = 0;
var colorStepSpeed = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Info/Window/Panel/ScrollContainer/VBoxContainer/VersionLabel.text = "   " + ProjectSettings.get_setting("application/config/version")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_change_bg_color(delta)

func _change_bg_color(delta):
	if colorStep >= 1:
		colorStep = 0
	
	colorStep += delta * colorStepSpeed;
	
	RenderingServer.set_default_clear_color(gradient.sample(colorStep))

func _open_credits_window():
	$Info/Window.show();
