extends RigidBody2D

export (float) var a
export (float) var maxGas

export (float) var turnSpeed
export (float) var maxTurn


var gas = 0.0
var turning = 0.0
var alive = true
var counter = 0
var resetting = false
var resetPrepared = false

var startPos
var startRot

func _ready():
  pass

func control():
  pass

func _process(delta):
  control(delta)

func _integrate_forces(state):  
  if not alive:
    return
  var front = Vector2(1.0, 0.0).rotated(rotation)
  var velocity = get_linear_velocity()
  var frontSpeed = velocity.dot(front)
  # longitudinal forces
  var thrust_force = front * gas
  var drag_force = (-0.001 * velocity.length() - 0.5) * velocity
  # lateral forces
  var right = front.tangent()
  var steering_force = velocity.dot(front) * turning * right
  var sideVelocity = velocity.dot(right)
  var lateral_drag = Vector2()
  if sideVelocity < 120.0:
    lateral_drag = -100 * velocity.dot(right) * right
  set_applied_force(thrust_force + drag_force + steering_force + lateral_drag)
                        # how much are we steering
                        # sharper turns at low speed
  var steering_torque = -50 * turning * \
                        (min(abs(frontSpeed), 200.0)) #+ \ 
                        # 0.02 * gas * \ # more thrust == more torque
                        # sign(frontSpeed))
  var drag_torque = -1000 * get_angular_velocity()
  if abs(get_angular_velocity()) > 3.0:
    drag_torque = -20000 * get_angular_velocity()
  set_applied_torque(steering_torque + drag_torque)
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