extends Camera2D

var target = null
var cam3D = null

func _ready():
  cam3D = $"/root/Game/Viewport/Spatial/Camera"
  
func _physics_process(delta):
    if target:
        position = target.position
        print("target at " + str(position))
        print(cam3D.transform.origin)
        var scaley = 0.001
        cam3D.transform.origin = Vector3(target.position.x, 800.0, target.position.y)
        var targetZoom = Vector2(1.5, 1.5) + 0.001 * Vector2(1, 1) * target.get_linear_velocity().length()
        zoom += delta * (targetZoom - zoom)