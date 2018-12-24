extends Node2D

var lineSeg = SegmentShape2D.new()
var areaShape = Area2D.new()
var checkIdx

func _init(p1, p2, checkIdx):
    lineSeg.a = p1
    lineSeg.b = p2
    self.checkIdx = checkIdx
    var collShape = CollisionShape2D.new()
    collShape.shape = lineSeg
    areaShape.add_child(collShape)
    add_child(areaShape)
    
func _ready():
  areaShape.connect('body_entered', self, '_on_Area2D_body_enter')
  areaShape.set_collision_layer_bit(7, true)

func _draw():
  draw_line(lineSeg.a, lineSeg.b, Color(1, 1, 0), 6)
  
func _on_Area2D_body_enter(body):
  if body.name == "Player":
    $"/root/Game/Viewports/VPC1/VP1/UI".reachCheckpoint(checkIdx)
  if body.name == "Player2":
    $"/root/Game/Viewports/VPC2/VP2/UI2".reachCheckpoint(checkIdx)