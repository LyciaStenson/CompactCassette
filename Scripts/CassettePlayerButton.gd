extends Node3D
class_name CassettePlayerButton

signal pressed(button_name)

func press():
	pressed.emit()
