extends Node2D

var waypoints

func _init(waypoints):
  self.waypoints = waypoints
  print (waypoints)
  
func _draw():
  print("draw")
  for idx in range(len(waypoints)):
    var wp1 = waypoints[idx % len(waypoints)]
    var wp2 = waypoints[(idx + 1) % len(waypoints)]
    draw_line(wp1, wp2, Color(255, 0, 0), 1)
