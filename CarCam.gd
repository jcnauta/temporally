extends Camera2D

var target = null

func _physics_process(delta):
    if target:
        position = target.position
        var targetZoom = Vector2(1.5, 1.5) + 0.001 * Vector2(1, 1) * target.get_linear_velocity().length()
        zoom += delta * (targetZoom - zoom)