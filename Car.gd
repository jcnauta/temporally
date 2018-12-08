extends KinematicBody2D

export (float) var a
export (float) var maxSpeed

export (float) var turnSpeed
export (float) var maxTurn


var speed = 0.0
var velocity = Vector2()
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
  rotation_degrees -= turning * speed * delta
  velocity = Vector2(1.0, 0.0).rotated(rotation) * speed
  move_and_slide(velocity)