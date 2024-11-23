extends RigidBody2D

func _physics_process(_delta: float) -> void:
	var dpad = Vector2(
		Input.get_action_strength("ui_right")-
		Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")-
		Input.get_action_strength("ui_up"))
	linear_velocity.x = move_toward(linear_velocity.x, dpad.x * 40, 8);
	if dpad.y:
		linear_velocity.y = move_toward(linear_velocity.y, dpad.y * 60, 15);
	else:
		linear_velocity.y = move_toward(linear_velocity.y, 40, 8);
	inertia = 99;
	angular_velocity = -rotation
