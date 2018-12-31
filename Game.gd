extends Node2D

onready var viewport1 = $Viewports/VPC1/VP1
onready var viewport2 = $Viewports/VPC2/VP2
onready var camera1 = $Viewports/VPC1/VP1/CarCam
onready var camera2 = $Viewports/VPC2/VP2/CarCam
onready var world = $Viewports/VPC1/VP1/World

var viewport_3D = null
var viewport_3D_sprite = null

func _ready():
  viewport_3D = get_node("Viewport")
  viewport_3D_sprite = $"Viewports/VPC1/VP1/World/3D_objects"
  viewport_3D.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  viewport_3D_sprite.texture = viewport_3D.get_texture()
  viewport_3D_sprite.position = get_node("Viewports/VPC1/VP1/World/YSort/Player").position + Vector2(50, 50)
  print(viewport_3D_sprite.position)
  
  viewport2.world_2d = viewport1.world_2d
  camera1.target = world.get_node("YSort/Player")
  camera2.target = world.get_node("YSort/Player2")
    