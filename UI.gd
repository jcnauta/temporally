extends CanvasLayer

var lapNr = 1
var prevCheck = 0
var progress = 0

var startTime
var bestTime = null

func reachCheckpoint(checkIdx):
  if checkIdx == (prevCheck + 1) % 3:
    progress += 1
    if checkIdx == 0 && progress == 3:
        progress = 0
        lapNr += 1
        $"./LabelLaps".text = "Lap #" + str(lapNr)
        var lapTime = OS.get_ticks_msec() - startTime
        $"./LabelLapTime".text = "previous lap time: " + str(lapTime / 1000.0)
        if bestTime == null || lapTime < bestTime:
          bestTime = lapTime
          $"./LabelLapRecord".text = "lap record: " + str(bestTime / 1000.0)
        
  elif checkIdx == (prevCheck - 1 + 3) % 3:
    progress -= 1
  if checkIdx == 0:
    startTime = OS.get_ticks_msec()
    print("starttime: " + str(startTime))
  prevCheck = checkIdx