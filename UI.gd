extends CanvasLayer

var laps = 0
var prevCheck = 0
var progress = 0

func reachCheckpoint(checkIdx):
  if checkIdx == (prevCheck + 1) % 3:
    progress += 1
    if checkIdx == 0 && progress == 3:
      progress = 0
      laps += 1
      $"./Label".text = str(laps)
  elif checkIdx == (prevCheck - 1 + 3) % 3:
    progress -= 1
  prevCheck = checkIdx