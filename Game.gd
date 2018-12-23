extends Node2D

onready var viewport1 = $Viewports/VPC1/VP1
onready var viewport2 = $Viewports/VPC2/VP2
onready var camera1 = $Viewports/VPC1/VP1/CarCam
onready var camera2 = $Viewports/VPC2/VP2/CarCam
onready var world = $Viewports/VPC1/VP1/World

func _ready():
    viewport2.world_2d = viewport1.world_2d
    camera1.target = world.get_node("YSort/Player")
    camera2.target = world.get_node("YSort/Player2")