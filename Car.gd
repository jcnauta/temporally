extends RigidBody2D

export (float) var a
export (float) var maxGas

export (float) var turnSpeed
export (float) var maxTurn

var ghosting = false
var ghostFuel = 0.0
var gas = 0.0
var turning = 0.0
var drifting = false

var alive = true
var counter = 0
var resetting = false
var resetPrepared = false

var startPos
var startRot

func _ready():
  set_collision_mask_bit(7, true)
  set_collision_mask_bit(6, true)
  a = 20000

func control():
  pass

func updateUI():
  pass

func _process(delta):
  control(delta)
  if drifting && !ghosting:
    ghostFuel = min(ghostFuel + 20 * delta, 100.0)
    updateUI(ghostFuel)
  if ghosting && ghostFuel > 0.0:
    ghostFuel = max(0.0, ghostFuel - 50 * delta)
    updateUI(ghostFuel)
    if ghostFuel == 0:
      tryGhosting(false)

func _integrate_forces(state):  
  if not alive:
    return
  var front = Vector2(1.0, 0.0).rotated(rotation)
  var velocity = get_linear_velocity()
  var frontSpeed = velocity.dot(front)
  var right = front.tangent()
  # determine drifting status
  var sideSpeed = abs(velocity.dot(right))
  if sideSpeed > 200.0:
    drifting = true
    print(applied_torque)
  elif (sideSpeed < 50.0 && abs(applied_torque) < 1000.0):
    drifting = false
    
  # longitudinal forces
  var thrustForce
  var dragForce
  if drifting:
    thrustForce = 0.5 * front * gas
    dragForce = (-0.0001 * velocity.length() - 1.0) * velocity
  else:
    thrustForce = front * gas
    dragForce = (-0.001 * velocity.length() - 1.0) * velocity
  # lateral forces
  var steeringForce = velocity.dot(front) * turning * right
  var lateralDrag = Vector2()
  if !drifting:
    lateralDrag = -100 * velocity.dot(right) * right
  set_applied_force(thrustForce + dragForce + steeringForce + lateralDrag)
                        # how much are we steering
                        # sharper turns at low speed
  var steeringTorque
  if gas > 0:
    steeringTorque = -100 * turning * min(200, abs(frontSpeed))
  elif gas < 0:
    steeringTorque = 100 * turning * min(200, abs(frontSpeed))
  else:
    steeringTorque = -100 * turning * clamp(frontSpeed, -200, 200.0)
                        
  var phi = get_angular_velocity()
  var drag_torque = -3000 * phi * phi * sign(phi)
  if abs(get_angular_velocity()) > 3.0:
    drag_torque = -20000 * get_angular_velocity()
  set_applied_torque(steeringTorque + drag_torque)
  counter += 1
  
  if resetting:
    resetPosition(state)
    resetting = false
#  if counter % 50 == 0:
#    print ("velocity: " + str(velocity))
#    print ("rotation: " + str(rotation) + ", front: " + str(front) + ", turning: " + str(turning) + ", frontSpeed: " + str(frontSpeed))

func setStartPosition(startPos, startRot):
  self.startPos = startPos
  self.startRot = startRot
  
func resetPosition(state = null):
  if state == null:
    transform = Transform2D(self.startRot, self.startPos)
  else:
    state.transform = Transform2D(self.startRot, self.startPos)
  turning = 0
  gas = 0
  self.linear_velocity = Vector2()
  self.angular_velocity = 0.0
  self.set_applied_force(Vector2())
  
func tryGhosting(ghosting):
  if ghosting && ghostFuel > 0.0:
    print(ghostFuel)
    set_collision_mask_bit(0, false)
    set_collision_layer_bit(0, false)
    modulate.a = 0.3
    self.ghosting = ghosting
  elif !ghosting:
    set_collision_mask_bit(0, true)
    set_collision_layer_bit(0, true)
    modulate.a = 1.0
    self.ghosting = ghosting
  