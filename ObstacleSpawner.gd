extends Node2D

var Obstacle = preload("res://Obstacle.tscn")

func spawn(leftSide, rightSide):
  # traverse left and right side, make convex combinations and add obstacles as children of YSort
  for idx in leftSide.size() - 1:
    var l1 = leftSide[idx]
    var l2 = leftSide[idx + 1]
    var r1 = rightSide[idx]
    var r2 = rightSide[idx + 1]
    # Create convex combination of these four points
    # generate four random numbers, summing to one
    var randoms = []
    var totalRand = 0
    for rIdx in 4:
      var newRand = randf()
      totalRand += newRand
      randoms.append(newRand)
    for rIdx in 4:
      randoms[rIdx] = randoms[rIdx] / totalRand
    var location = randoms[0] * l1 + randoms[1] * l2 + randoms[2] * r1 + randoms[3] * r2
    var obstacle = Obstacle.instance()
    obstacle.position = location
    $"../YSort".add_child(obstacle)