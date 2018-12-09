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
    gas = gas + a * delta
  elif Input.is_action_just_released('forward'):
    gas = min(gas, 0.0)
  if Input.is_action_pressed('back'):
    gas = gas - a * delta
  elif Input.is_action_just_released('back'):
    gas = max(gas, 0.0)
  if gas > 0.0:
    gas -= 0.5 * a * delta
    if gas < 0:
      gas = 0
  elif gas < 0.0:
    gas += 0.5 * a * delta
    if gas > 0:
      gas = 0
  gas = clamp(gas, -maxGas, maxGas)
#  velocity.rotated(Vector3(0, 1.0, 0), turning)
  