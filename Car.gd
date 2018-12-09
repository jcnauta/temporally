extends RigidBody2D

export (float) var a
export (float) var maxGas

export (float) var turnSpeed
export (float) var maxTurn


var gas = 0.0
var turning = 0.0
var alive = true
var counter = 0

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
  var drag_force = -velocity
  # lateral forces
  var right = front.tangent()
  var steering_force = velocity.dot(front) * turning * right
  var lateral_drag = -100 * velocity.dot(right) * right
  set_applied_force(thrust_force + drag_force + steering_force + lateral_drag)
  
  print("froV: " + str(frontSpeed))
  var steering_torque = -50 * turning * (min(frontSpeed, 200.0) + 0.02 * gas * sign(frontSpeed))
  var drag_torque = -1000 * get_angular_velocity()
  if abs(get_angular_velocity()) > 3.0:
    drag_torque = -20000 * get_angular_velocity()
  print ("angv: " + str(get_angular_velocity()))
  print("sto " + str(steering_torque) + ", drat " + str(drag_torque))
  set_applied_torque(steering_torque + drag_torque)
  counter += 1
  if counter % 50 == 0:
    print ("velocity: " + str(velocity))
    print ("rotation: " + str(rotation) + ", front: " + str(front) + ", turning: " + str(turning) + ", frontSpeed: " + str(frontSpeed))
