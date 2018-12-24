extends "res://Car.gd"

export var id = 0

func control(delta):
  if Input.is_action_just_pressed('reposition%s' % id):
    resetting = true
  if Input.is_action_just_pressed('ghost%s' % id):
    set_collision_mask_bit(0, false)
    set_collision_layer_bit(0, false)
  elif Input.is_action_just_released('ghost%s' % id):
    set_collision_mask_bit(0, true)
    set_collision_layer_bit(0, true)
  
  var tLeft = Input.is_action_pressed('turnLeft%s' % id)
  var tRight = Input.is_action_pressed('turnRight%s' % id)
  if tLeft:
    turning = clamp(turning + turnSpeed * delta, -maxTurn, maxTurn) # set and limit steering wheel rotations
  elif Input.is_action_just_released('turnLeft%s' % id):
    turning = min(0.0, turning)
  if tRight:
    turning = clamp(turning - turnSpeed * delta, -maxTurn, maxTurn) # set and limit steering wheel rotations
  elif Input.is_action_just_released('turnRight%s' % id):
    turning = max(0.0, turning)
  turning -= 2 * turning * delta
  if Input.is_action_pressed('forward%s' % id):
    gas = gas + a * delta
  elif Input.is_action_just_released('forward%s' % id):
    gas = min(gas, 0.0)
  if Input.is_action_pressed('back%s' % id):
    gas = gas - a * delta
  elif Input.is_action_just_released('back%s' % id):
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