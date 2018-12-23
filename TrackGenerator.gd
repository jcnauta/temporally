extends Node2D

var BarrierSegment = preload("res://BarrierSegment.gd")
var Checkpoint = preload("res://Checkpoint.gd")
var Delauney = preload("res://Delauney.gd")

#export(NodePath) var playerPath
#onready var player = $"../YSort/Player"

var initWps = 20
var points =  PoolVector2Array()
var boundary = PoolVector2Array()
var bIdxs = PoolIntArray()
var triang = PoolIntArray()
var triangCopy = PoolIntArray()
var counter = 0.0
var runNr = 0
var generate = true
var offendingPoint = null
var offPrev = null
var offNext = null
var minDist
var roadSize

var burnRuns = 0

func _ready():
  createValidWaypoints(initWps)
  var leftSide = wayPointsBorder(bIdxs, "left")
  var rightSide = wayPointsBorder(bIdxs, "right")
  var cp0Idx = 1
  var cp1Idx = leftSide.size() / 3.0 + 2
  var cp2Idx = leftSide.size() * 2.0/3.0 + 3
  get_parent().call_deferred("add_child", Checkpoint.new(leftSide[cp0Idx], rightSide[cp0Idx], 0))
  get_parent().call_deferred("add_child", Checkpoint.new(leftSide[cp1Idx], rightSide[cp1Idx], 1))
  get_parent().call_deferred("add_child", Checkpoint.new(leftSide[cp2Idx], rightSide[cp2Idx], 2))
  get_parent().call_deferred("add_child", BarrierSegment.new(leftSide))
  get_parent().call_deferred("add_child", BarrierSegment.new(rightSide))
  var player = $"../YSort/Player"
  var player2 = $"../YSort/Player2"
  for player in [player, player2]:
    var towards = points[bIdxs[1]] - points[bIdxs[0]]
    player.setStartPosition(points[bIdxs[0]], towards.angle())
    player.resetPosition()
    
  $"../ObstacleSpawner".spawn(leftSide, rightSide)
  
  set_process(true)

func createValidWaypoints(initWps):
  var isBad = true
  var failures = -1
  var failureLimit = 30
  while isBad && failures < failureLimit:
    failures += 1
    bIdxs = createWaypoints(initWps)
    var removedCorners = true
    var someMoved = true
    var confirmed = false
    var maxMods = 100
    var cmods = 0
    var mmods = 0
    while removedCorners || someMoved:
      removedCorners = removeSharpCorners()
      someMoved = segmentsPushPoints()
      if removedCorners:
        cmods += 1
      if someMoved:
        mmods += 1
      if cmods > maxMods || mmods > maxMods:
        break
    if cmods > maxMods || mmods > maxMods:
      print("Softening corners and pushing points was too difficult.")
      print("cmods: " + str(cmods) + ", mmods: " + str(mmods))
      isBad = true
    else:
      isBad = circuitHasIntersections()
  if failures == failureLimit:
    print("Failed to create circuit, difficult parameters.")
    get_tree().quit()

# Generates the track.
# Method based on https://stackoverflow.com/a/14266101/804318
func createWaypoints(initWps):
  roadSize = 500
#  minDist = 0.5 * side / sqrt(initWps) # always possible to place point
#  roadSize = 0.5 * minDist
  minDist = 2 * roadSize
  var side = 3 * minDist * sqrt(initWps)
  var failure = true  
  while failure:
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
      for i in initWps:
        # regenerate points if they are too close to another
        var tooClose = true;
        var newPoint;
        while tooClose:
          newPoint = Vector2(randf() * side + side / 2, randf() * side - side / 2)
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
    return bIdxs
  print("Failure creating points, returning empty track indices.")
  return PoolIntArray()
  
func circuitHasIntersections():
  var bSize = bIdxs.size()
  for bIdx in (bSize - 1):
    var b1 = points[bIdxs[bIdx]]
    var b2 = points[bIdxs[(bIdx + 1) % bSize]]
    # Need to exclude the last segment for the first iteration
    # since neighboring segments always overlap
    var upperCIdx = bSize
    if bIdx == 0:
      upperCIdx -= 1 
    for cIdx in range(bIdx + 2, upperCIdx):
      var c1 = points[bIdxs[cIdx]]
      var c2 = points[bIdxs[(cIdx + 1) % bSize]]
      if (cIdx == bIdx || cIdx == (bIdx + 1) % bSize || (cIdx + 1) % bSize == bIdx):
        print("something went wrong here, segment should not be subsequent.")
      var intersection = Geometry.segment_intersects_segment_2d(b1, b2, c1, c2)
      if (typeof(intersection) == TYPE_VECTOR2):
        return true
  return false
  
func segmentsPushPoints():
  var movedSome = false
  var bSize = bIdxs.size()
  for bIdx in bSize:
    var b1 = points[bIdxs[bIdx]]
    var b2 = points[bIdxs[(bIdx + 1) % bSize]]
    for pIdx in bSize:
      if pIdx != bIdx && pIdx != (bIdx + 1) % bSize:
        var point = points[bIdxs[pIdx]]
        var closest = Geometry.get_closest_point_to_segment_2d(point, b1, b2)
        var dist = (point - closest).length()
        if dist < minDist:
          # move point away from the segment
          points[bIdxs[pIdx]] += minDist * (point - closest).normalized()
          movedSome = true
  return movedSome
# For each sharp corner:
# a. if possible, "cut" a small part off the corner, effectively turning the corner into an edge.
# b. if there is no room because one of the neighbors is too close, simply remove the corner.
func removeSharpCorners():
  var minSegment = 64
  var removedSome = false
  var removedOne = true
  while bIdxs.size() > 2 and removedOne == true:
#    print("iteration!  bIdxs: " + str(bIdxs.size()))
    removedOne = false
    for idx in bIdxs.size():
      var b = bIdxs[idx]
      var point = points[b]
      var prevP = points[bIdxs[(idx - 1 + bIdxs.size()) % bIdxs.size()]]
      var nextP = points[bIdxs[(idx + 1) % bIdxs.size()]]
      var angle = (prevP - point).angle_to(nextP - point)
      if abs(angle) < PI / 6.0:
        removedOne = true
        removedSome = true
        offendingPoint = points[b]
        var vPrev = prevP - point
        var vNext = nextP - point
        # Calculate displacement based on angle
        var displacement = abs(0.5 * minSegment / sin(angle)) # sin angle = 0.5 * minSegment / displacement
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
          for decreaseIdx in bIdxs.size():
            if bIdxs[decreaseIdx] > b:
              bIdxs[decreaseIdx] -= 1
        break # so that we restart the for-loop with a smaller number
  return removedSome

# Create the inside/outside of the track, using bisectors at each point.
# side can be "left" or "right", which will correspond to the outside/inside
# of the track for clockwise waypoints.
func wayPointsBorder(waypoints, side):
  var prevPoint
  var thisPoint
  var nextPoint
  var border = []
  for wp in waypoints.size():
    prevPoint = points[waypoints[(wp + len(waypoints) - 1) % len(waypoints)]]
    thisPoint = points[waypoints[wp % len(waypoints)]]
    nextPoint = points[waypoints[(wp + 1) % len(waypoints)]]
    var toNext = (nextPoint - thisPoint).normalized()
    var toPrev = (prevPoint - thisPoint).normalized()
    # Use cross product to decide which side to pick
    var turn = (-1 * toPrev.x) * toNext.y - (-1 * toPrev.y) * toNext.x
    var borderPoint = (toNext + toPrev).normalized() * roadSize
    if side == "right":
      if turn > 0: # inner curve
        for innerIdx in 3:
          border.push_back(thisPoint + borderPoint)
      else: # this is the outer curve
        var outerPrev = roadSize * toPrev.tangent()
        border.push_back(thisPoint + outerPrev)
        border.push_back(thisPoint - borderPoint)
        var outerNext = roadSize * -toNext.tangent()
        border.push_back(thisPoint + outerNext)
    if side == "left":
      if turn < 0: # inner curve
        for innerIdx in 3:
          border.push_back(thisPoint + borderPoint)
      else: # outer curve
#        for innerIdx in 3:
#          border.push_back(thisPoint - borderPoint)
        var outerPrev = roadSize * toPrev.tangent()
        border.push_back(thisPoint - outerPrev)
        border.push_back(thisPoint - borderPoint)
        var outerNext = roadSize * -toNext.tangent()
        border.push_back(thisPoint - outerNext)
  return border

func _draw():
  pass
#  if len(points) > 0:
#    for idx in bIdxs.size():
#      draw_line(points[bIdxs[idx]], points[bIdxs[(idx + 1) % bIdxs.size()]], Color(0.0, 1.0, 0.0))
#    for point in points:
#      draw_circle(point, 10, Color(1, 0, 1))
    