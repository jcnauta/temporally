extends Node2D

var Obstacle = preload("res://Obstacle.tscn")

func spawnOnGrid(leftSide, rightSide):
  for idx in (leftSide.size() / 3):
    var idxInPoints = 3 * idx + 2
    var nextIdxInPoints = (3 * idx + 3) % leftSide.size()
    var l1 = leftSide[idxInPoints]
    var l2 = leftSide[nextIdxInPoints]
    var r1 = rightSide[idxInPoints]
    var r2 = rightSide[nextIdxInPoints]
    var lineBegin = r1 - l1
    var lineEnd = r2 - l2
    var lineLeft = l2 - l1
    var lineRight = r2 - r1
    var p1a
    var p1b
    var p2a
    var p2b
    var shortLine
    var shortSide
    # Pick most narrow part to determine spacing
    if lineEnd.length() > lineBegin.length(): # first line is shorter
      shortLine = lineBegin
      if lineLeft.length() > lineRight.length(): # right side is shorter
        shortSide = lineRight
        p1a = r1 # use this as reference point
        p1b = l1 # and this is across the track from it
        p2a = r2
        p2b = l2
      else: # right side is shorter
        shortSide = lineLeft
        p1a = l1
        p1b = r1
        p2a = l2
        p2b = r2
    else: # end line is shorter
      shortLine = lineEnd
      if lineLeft.length() > lineRight.length(): # right side is shorter
        shortSide = lineRight
        p1a = r2
        p1b = l2
        p2a = r1
        p2b = l1
      else:
        shortSide = lineLeft
        p1a = l2
        p1b = r2
        p2a = l1
        p2b = r1
    # Pick the shortest part to determine spacing
    var breadthBins = int(floor(shortLine.length() / 128.0) - 1)
    var lengthBins = int(floor(shortSide.length() / 128.0) - 1)
    if breadthBins >= 1 && lengthBins >= 1:
      # Calculate surface to determine number of obstacles to spawn
      var trBase = l1 - r2
      var trHeightLeft = abs((l2 - r2).dot(trBase.tangent().normalized()))
      var trHeightRight = abs((r1 - l1).dot(trBase.tangent().normalized()))
      var surfaceLeft = 0.5 * trBase.length() * trHeightLeft
      var surfaceRight = 0.5 * trBase.length() * trHeightRight
      
      for jdx in round(0.000002 * (surfaceLeft + surfaceRight)):
        var breadthOffset = randi() % breadthBins
        var rightFrac = (breadthOffset + 1.0) / (breadthBins + 1.0)
        var leftFrac = 1.0 - rightFrac
        var lengthOffset = randi() % lengthBins
        var lengthFrac = (lengthOffset + 1.0) / (lengthBins + 1.0)
        var obstacle = Obstacle.instance()
        obstacle.position = p1a + \
            rightFrac * (p1b - p1a) + \
            lengthFrac * (leftFrac * (p2a - p1a) + rightFrac * (p2b - p1b))
        $"../YSort".add_child(obstacle)
    
    
    
    
func spawn(leftSide, rightSide):
  # traverse left and right side, make convex combinations and add obstacles as children of YSort
  for idx in (leftSide.size() / 3):
    var idxInPoints = 3 * idx + 1
    var nextIdxInPoints = (3 * idx + 4) % leftSide.size()
    var l1 = leftSide[idxInPoints]
    var l2 = leftSide[nextIdxInPoints]
    var r1 = rightSide[idxInPoints]
    var r2 = rightSide[nextIdxInPoints]
    # Generate points homogeneously in the convex shape.
    # First subdivide into two clockwise triangles
    # Then pick triangle weighted by surface area
    var trBase = l1 - r2
    var trHeightLeft = abs((l2 - r2).dot(trBase.tangent().normalized()))
    var trHeightRight = abs((r1 - l1).dot(trBase.tangent().normalized()))
    var weightLeft = trBase.length() * trHeightLeft
    var weightRight = trBase.length() * trHeightRight
    
    for jdx in round(0.000001 * (weightLeft + weightRight)):
      var p1
      var p2
      var p3
      if randf() < weightLeft / (weightLeft + weightRight): # Use left triangle
        p1 = l1
        p2 = l2
        p3 = r2
      else: # use right triangle  
        p1 = l1
        p2 = r2
        p3 = r1
      var v1 = p2 - p1
      var v2 = p3 - p1
      var factor1 = randf()
      var factor2 = randf()
      if factor1 + factor2 > 1.0:
        factor1 = 1.0 - factor1
        factor2 = 1.0 - factor2
      var randLocation = p1 + factor1 * v1 + factor2 * v2
      var obstacle = Obstacle.instance()
      obstacle.position = randLocation
      $"../YSort".add_child(obstacle)