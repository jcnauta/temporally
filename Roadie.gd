extends Node2D

var Roadside = preload("res://Roadside.gd")

var waypoints = []
var nWps = 10
var radius = 100
# Generates the track.
# First pick the center point of the track, then generate waypoints
# at random distances from it, which will be the parcours.
# Then create points for the track borders using bisectors,
# and connect these to create collision objects.
func _ready():
  var trackCenter = Vector2(200, 200)
  var angle = 0
  var angles = []
  for wp in range (nWps):
    angles.push_back(randf() * 2 * PI)
  angles.sort()
  for wp in range(nWps):
    waypoints.push_back(trackCenter + Vector2(radius + randf() * 50, 0).rotated(angles[wp]))
  get_parent().call_deferred("add_child", Roadside.new(waypoints))