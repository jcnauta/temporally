extends Node2D

var Roadside = preload("res://Roadside.gd")

var nWps = 20
var radius = 2000
var roadSize = 200


func _ready():
  var waypoints = createWaypoints()
  var leftSide = wayPointsBorder(waypoints, "left")
  var rightSide = wayPointsBorder(waypoints, "right")
#  get_parent().call_deferred("add_child", Roadside.new(waypoints))
  get_parent().call_deferred("add_child", Roadside.new(leftSide))
  get_parent().call_deferred("add_child", Roadside.new(rightSide))
# Generates the track.
# First pick the center point of the track, then generate waypoints
# at random distances from it, which will be the parcours.
func createWaypoints():
  var waypoints = []
  var trackCenter = Vector2(1600, 200)
  var angle = 0
  var angles = []
  for wp in range (nWps):
    angles.push_back(randf() * 2 * PI)
  angles.sort()
  for wp in range(nWps):
    waypoints.push_back(trackCenter + Vector2(radius + randf() * 50, 0).rotated(angles[wp]))
  return waypoints

# Create the inside/outside of the track, using bisectors at each point.
# side can be "left" or "right", which will correspond to the outside/inside
# of the track for clockwise waypoints.
func wayPointsBorder(waypoints, side):
  var prevPoint
  var thisPoint
  var nextPoint
  var border = []
  for wp in range (nWps):
    prevPoint = waypoints[(wp + len(waypoints) - 1) % len(waypoints)]
    thisPoint = waypoints[wp % len(waypoints)]
    nextPoint = waypoints[(wp + 1) % len(waypoints)]
    var toNext = (nextPoint - thisPoint).normalized()
    var toPrev = (prevPoint - thisPoint).normalized()
    # Use cross product to decide which side to pick
    var turn = (-1 * toPrev.x) * toNext.y - (-1 * toPrev.y) * toNext.x
    var borderPoint = (toNext + toPrev).normalized() * roadSize
    if side == "right":
      if turn > 0.001:
        border.push_back(thisPoint + borderPoint)
      elif turn < -0.001:
        border.push_back(thisPoint - borderPoint)
      else:
        print("TODO: straight segments")
    if side == "left":
      if turn > 0.001:
        border.push_back(thisPoint - borderPoint)
      elif turn < -0.001:
        border.push_back(thisPoint + borderPoint)
      else:
        print("TODO: straight segments")
  return border
      
      
    