extends CanvasLayer


func _ready() -> void:
	initialize_hud()


func update_puck_dash_progress(progress_value: float) -> void:
	$TopHBoxContainer/PowersHBoxContainer/PuckDash.set_value(progress_value)


func update_Io_status_icon(power_active: bool) -> void: 
	if power_active:
		$TopHBoxContainer/PowersHBoxContainer/Io_Phase.set_modulate(Color(0.93,15.7,100))
	else: 
		$TopHBoxContainer/PowersHBoxContainer/Io_Phase.set_modulate(Color(0.93,0.4,0.26))


func initialize_hud() -> void:
	update_puck_dash_progress(100)
	update_Io_status_icon(false)


func _on_Puck_Dash_puck_timer_elapsing(percentage_elapsed) -> void:
	update_puck_dash_progress(percentage_elapsed)
	
func _on_phaseAbilityManager_phase_ability_on(activated) -> void:
	if(activated):
		$TopHBoxContainer/PowersHBoxContainer/phaseAbility.modulate.a = 0.5
	else :
		$TopHBoxContainer/PowersHBoxContainer/phaseAbility.modulate.a = 1
		


func _on_phaseAbilityManager_power_triggered(power_active: bool) -> void:
	update_Io_status_icon(power_active)
