extends Node2D

var waypoints

func _init(waypoints):
  for idx in range(len(waypoints)):
    var wp1 = waypoints[idx % len(waypoints)]
    var wp2 = waypoints[(idx + 1) % len(waypoints)]
    self.waypoints = waypoints
    var staticShape = StaticBody2D.new()
    var collShape = CollisionShape2D.new()
    var lineSeg = SegmentShape2D.new()
    var rectSeg = RectangleShape2D.new()
    lineSeg.a = wp1
    lineSeg.b = wp2
    rectSeg.set_extents((wp2 - wp1) / 2)
    collShape.shape = lineSeg
#    collShape.position = wp1
    staticShape.add_child(collShape)
    staticShape.bounce = 0.5
    staticShape.friction = 0.5
    add_child(staticShape)
  
func _draw():
  for idx in range(len(waypoints)):
    var wp1 = waypoints[idx % len(waypoints)]
    var wp2 = waypoints[(idx + 1) % len(waypoints)]
    draw_line(wp1, wp2, Color(255, 0, 0), 10)