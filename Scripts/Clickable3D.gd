extends Node3D
class_name Clickable3D

signal clicked(action_name : String)

func click():
	clicked.emit()
