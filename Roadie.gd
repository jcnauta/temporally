extends Node2D

var Roadside = preload("res://Roadside.gd")
var Delauney = preload("res://Delauney.gd")

var nWps = 25
var radius = 1000
var roadSize = 200
var wps = []
var points =  PoolVector2Array()
var boundary = PoolVector2Array()
var bIdxs = PoolIntArray()
var triang = PoolIntArray()
var triangCopy = PoolIntArray()
var counter = 0.0
var runNr = 0
var generate = false
var offendingPoint = null
var offPrev = null
var offNext = null

func _ready():
  var v1 = Vector2(0.0, 1.0)
  var v2 = Vector2(1.0, 0.0)
  print("angletest " + str(v1.angle_to(v2)))
  print("modulotest " + str(-2 % 6))
  createWaypoints(nWps)
  
#  wps = createWaypoints(nWps) # creates global wps
#  var leftSide = wayPointsBorder(wps, "left")
#  var rightSide = wayPointsBorder(wps, "right")
#  get_parent().call_deferred("add_child", Roadside.new(wps))
#  get_parent().call_deferred("add_child", Roadside.new(leftSide))
#  get_parent().call_deferred("add_child", Roadside.new(rightSide))
  set_process(true)

func _process(delta):
  counter += delta
  if counter > 1.0: #and !debugging:
    if generate:
      offendingPoint = null
      offPrev = null
      offNext = null
      createWaypoints(nWps)
      runNr += 1
      update()
      generate = false
    else:
      removeSharpCorners()
      update()
      generate = true
    counter = 0.0

# Generates the track.
# Method based on https://stackoverflow.com/a/14266101/804318
func createWaypoints(nWps):
  var failure = true
  
  while failure:
    print("new waypoints! runNr " + str(runNr))
    var side = 1000.0
    points =  PoolVector2Array()
    boundary = PoolVector2Array()
    triang = PoolIntArray()
    bIdxs = PoolIntArray()
    var tries = 0
    # regenerate point sets until triangulation succeeds
    while triang.size() == 0:
      tries += 1
      # first generate the point set
      points.resize(0)
      var minDist = 0.1 * side / sqrt(nWps) # always possible to place point
      for i in range(nWps):
        # regenerate points if they are too close to another
        var tooClose = true;
        var newPoint;
        while tooClose:
          newPoint = Vector2(randf() * side - side / 2, randf() * side - side / 2)
          tooClose = false
          for j in points.size():
            if newPoint.distance_to(points[j]) < minDist:
              tooClose = true
              break
        points.append(newPoint)
      triang = Delauney.triangulate(points)
    boundary = Geometry.convex_hull_2d(points)
    boundary.remove(boundary.size() - 1) # remove the last element, which is identical to the first
  
    var precision = 0.001
    for bPoint in boundary:
      for idx in len(points):
        var p = points[idx]
        if abs(bPoint.distance_to(p)) < precision:
          # assume these vectors are the same
          bIdxs.append(idx)
          break
    
    # remove boundary edges from triangulation until
    #  a. this would let boundary pass through same point twice
    #  b. the boundary passes through all points
    failure = false
    while bIdxs.size() < points.size() and !failure:
      # find edge we can remove
      var nrOfSteps = 0
      var idxInBoundary = randi() % bIdxs.size()
      var removedTriangle = false
      while nrOfSteps < bIdxs.size() and not removedTriangle:
        var b1 = bIdxs[idxInBoundary]
        var b2 = bIdxs[(idxInBoundary + 1) % bIdxs.size()]
        # find triangle for these points
        var tr = 0
        while tr < triang.size():
          var t1 = triang[tr].p1
          var t2 = triang[tr].p2
          var t3 = triang[tr].p3
          var newIdx
          if b1 == t1:
            if b2 == t2:
              newIdx = t3
            elif b2 == t3:
              newIdx = t2
          elif b1 == t2:
            if b2 == t1:
              newIdx = t3
            elif b2 == t3:
              newIdx = t1
          elif b1 == t3:
            if b2 == t1:
              newIdx = t2
            elif b2 == t2:
              newIdx = t1
          if newIdx == null:
            tr += 1
            continue
          # check if the newly found index is not already in the boundary
          var mayAdd = true
          for already in bIdxs:
            if newIdx == already:
              mayAdd = false
              break
          if mayAdd: # remove triangle and add new point to boundary
            triang.remove(tr)
            bIdxs.insert((idxInBoundary + 1) % bIdxs.size(), newIdx)
            removedTriangle = true
          break # We found the triangle for this edge (did not continue above), so break.
        # just in case no matching triangle was found for removal, go to next edge 
        idxInBoundary = (idxInBoundary + 1) % bIdxs.size()
        nrOfSteps += 1
        if nrOfSteps == bIdxs.size():
          # We traversed the boundary without finding another point to remove. Something is wrong.
          failure = true
          break
  if !failure:
#    removeSharpCorners()
    return bIdxs

# For each sharp corner:
# a. if possible, "cut" a small part off the corner, effectively turning the corner into an edge.
# b. if there is no room because one of the neighbors is too close, simply remove the corner.
func removeSharpCorners():
  var minSegment = 64
  var removedOne = true
  while bIdxs.size() > 2 and removedOne == true:
    print("iteration!  bIdxs: " + str(bIdxs.size()))
    removedOne = false
    for idx in range(bIdxs.size()):
      var b = bIdxs[idx]
      var point = points[b]
      var prevP = points[bIdxs[(idx - 1 + bIdxs.size()) % bIdxs.size()]]
      var nextP = points[bIdxs[(idx + 1) % bIdxs.size()]]
      var angle = (prevP - point).angle_to(nextP - point)
      if abs(angle) < PI / 8:
        removedOne = true
        offendingPoint = points[b]
        var vPrev = prevP - point
        var vNext = nextP - point
        # Calculate displacement based on angle
        var displacement = abs(0.5 * minSegment / sin(angle)) # sin angle = 0.5 * minSegment / displacement
        print("displacement " + str(displacement))
        if displacement < min (vPrev.length(), vNext.length() - minSegment):
          var dir1 = vPrev.normalized()
          var dir2 = vNext.normalized()
          var newPoint = Vector2(point.x, point.y)
          points[b] += dir1 * displacement
          newPoint += dir2 * displacement
          points.append(newPoint)
          bIdxs.insert((idx + 1) % bIdxs.size(), points.size() - 1)
        else:
          points.remove(b)
          bIdxs.remove(idx)
          for decreaseIdx in range(bIdxs.size()):
            if bIdxs[decreaseIdx] > b:
              bIdxs[decreaseIdx] -= 1
        
        break # so that we restart the for-loop with a smaller number

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

func _draw():
  if len(points) > 0:
    for point in points:
      draw_circle(point, 4, Color(1, 0, 0))
    for idx in len(bIdxs):
      draw_line(points[bIdxs[idx]], points[bIdxs[(idx + 1) % len(bIdxs)]], Color(0.0, 1.0, 0.0))
    if offendingPoint:
      draw_circle(offendingPoint, 12, Color(1, 0, 0))
#      draw_circle(offPrev, 8, Color(0, 1, 0))
#      draw_circle(offNext, 8, Color(0, 0, 1))
#    draw_circle(points[bIdxs[0]], 8, Color(0, 1, 0.5))
#    for idx in triangCopy.size():
#      var cor = Color(randf(), randf(), randf())
#      draw_line(points[triangCopy[idx]], points[triangCopy[idx + 1]], cor)
#      draw_line(points[triangCopy[idx + 1]], points[triangCopy[idx + 2]], cor)
#      draw_line(points[triangCopy[idx + 2]], points[triangCopy[idx]], cor)
    