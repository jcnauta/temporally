extends Node2D

var points
var pointOrder
var nrOfSegments

func _init(pointsParam, closedLoop = true, pIdxs = null):
  points = pointsParam
  if pIdxs == null:
    pointOrder = PoolIntArray()
    for idx in range(points.size()):
      pointOrder.push_back(idx)
  else:
    pointOrder = pIdxs
  nrOfSegments = len(pointOrder)
  if !closedLoop:
    nrOfSegments -= 1
  for idx in nrOfSegments:
    var wp1 = points[pointOrder[idx % len(pointOrder)]]
    var wp2 = points[pointOrder[(idx + 1) % len(pointOrder)]]
    var staticShape = StaticBody2D.new()
    var collShape = CollisionShape2D.new()
    var lineSeg = SegmentShape2D.new()
    lineSeg.a = wp1
    lineSeg.b = wp2
    collShape.shape = lineSeg
    staticShape.add_child(collShape)
    staticShape.bounce = 0.5
    staticShape.friction = 0.0
    add_child(staticShape)
  
func _draw():
  for idx in nrOfSegments:
    var wp1 = points[pointOrder[idx % len(pointOrder)]]
    var wp2 = points[pointOrder[(idx + 1) % len(pointOrder)]]
    draw_line(wp1, wp2, Color(255, 0, 0), 5)
  for point in points:
      draw_circle(point, 10, Color(1, 1, 0))