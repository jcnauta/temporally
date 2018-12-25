extends Node2D

var points
var colors

func _init(points, colors):
  self.points = PoolVector2Array(points)
  self.colors = PoolColorArray(colors)
  
func _draw():
  draw_polygon(points, colors)