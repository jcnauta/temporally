extends KinematicBody

export (float) var a
export (float) var mass
export (float) var turnSpeed
export (float) var maxSpeed

var speed = 0.0
var velocity = Vector3()
var turning = 0.0
var alive = true

func _ready():
  pass

func control(delta):
  pass

func _physics_process(delta):
  if not alive:
    return
  control(delta)
  move_and_slide(velocity, Vector3(0.0, 1.0, 0.0))