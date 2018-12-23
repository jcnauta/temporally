extends Node2D

var Obstacle = preload("res://Obstacle.tscn")

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
    var test = trBase.tangent()
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