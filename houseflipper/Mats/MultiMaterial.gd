extends StandardMaterial3D
class_name MultiMaterial3D

# TODO - this doesn't really work :\ 
# having to set CurrentVarient multiple times is a hack and feels wrong, and
# either way even with local to scene checked modifying one material changes
# all of them.  Need to read up on how managing resources is supposed to work,
# as assignin a resource to a mesh instance doesn't copy it, it references it

@export var CurrentVarient: int = 0:
	set(value):
		print("Set for value ", value)
		print("Default Texture is ", DefaultTexture)
		if value == 0:
			albedo_texture = DefaultTexture
			CurrentVarient = value
		elif value-1 < len(Variants):
			albedo_texture = Variants[value-1]
			CurrentVarient = value
		else:
			push_warning("Varient Texture ID out of range!")

@export_group("Material Settings")
@export var DefaultTexture: Texture2D:
	set(val):
		print("Setting default texture")
		DefaultTexture = val
		CurrentVarient = CurrentVarient
@export var Variants: Array[Texture2D]:
	set(val):
		Variants = val
		CurrentVarient = CurrentVarient


func _init() -> void:
	print("MulitTexture init with ", CurrentVarient)
	print("My Default Texture is ", DefaultTexture)
	if CurrentVarient == 0:
		if DefaultTexture:
			albedo_texture = DefaultTexture
	elif CurrentVarient-1 < len(Variants):
		albedo_texture = Variants[CurrentVarient-1]
	else:
		push_warning("MultiMaterial got invalid varient!")
