extends "res://Car.gd"

func control(delta):
  var tLeft = Input.is_action_pressed('turnLeft')
  var tRight = Input.is_action_pressed('turnRight')
  if tLeft:
    turning = clamp(turning + turnSpeed * delta, -maxTurn, maxTurn) # set and limit steering wheel rotations
  if tRight:
    turning = clamp(turning - turnSpeed * delta, -maxTurn, maxTurn) # set and limit steering wheel rotations
  turning -= 2 * turning * delta
  if Input.is_action_pressed('forward'):
    speed += a * delta
    print(speed)
  if Input.is_action_pressed('back'):
    speed -= a * delta

#  velocity.rotated(Vector3(0, 1.0, 0), turning)
  