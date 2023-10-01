extends Sprite2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

const tile_size = 16  # Adjust this based on your tile size
var current_tile = Vector2(1, 1)

var is_moving = false

func _physics_process(delta):
	if is_moving == false:
		state_machine.travel("Idle")
		return
		
	if global_position == sprite_2d.global_position:
		is_moving = false
		return

	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 1)
func _process(delta):
	if is_moving:
		state_machine.travel("walk")
		return
	
	if Input.is_action_pressed("ui_up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("ui_down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("ui_left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("ui_right"):
		move(Vector2.RIGHT)
	
	

func move(direction: Vector2):
	
	
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/walk/blend_position",direction)
	#current tile
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	# get target tile
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	prints(current_tile,target_tile)
	
	var tile_data: TileData = tile_map.get_cell_tile_data(0,target_tile)
	
	if tile_data.get_custom_data('Walkable') == false:
		return
	
	ray_cast_2d.target_position = direction * 16
	ray_cast_2d.force_raycast_update()
		
	if ray_cast_2d.is_colliding():
		return 
	
	#move player
	is_moving = true
	
	global_position = tile_map.map_to_local(target_tile)
	
	sprite_2d.global_position = tile_map.map_to_local(current_tile)

	if tile_data.get_custom_data('Teleporter') == true:
			#teleport to random tile or other teleporter (Make sure to 'paint' custom data value on tileset)
		teleport()
	if tile_data.get_custom_data('Force') == true:
			#forced movement tile
		var force_direction: Vector2 = tile_data.get_custom_data('ForcDirection')
		move_force(force_direction)

func move_force(direction: Vector2):
	# Check if the force movement is valid (not blocked by obstacles)
	var target_tile: Vector2i = current_tile + direction

	var tile_data_force: TileData = tile_map.get_cell_tile_data(0, target_tile)

	if tile_data_force.get_custom_data('Walkable') == false:
		return

	# Move the player to the force direction
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	current_tile = target_tile

	# Update the sprite position
	sprite_2d.global_position = tile_map.map_to_local(current_tile)

func teleport():
	# Find all teleporter tiles in the map
	var teleporter_tiles: Array = []

	# Iterate through all tiles to find those with the 'Teleporter' custom value
	for x in range(tile_map.get_used_rect().size.x):
		for y in range(tile_map.get_used_rect().size.y):
			var tile_pos = Vector2i(x, y)
			var tile_data_tp: TileData = tile_map.get_cell_tile_data(0,tile_pos)
			
			if tile_data_tp.get_custom_data('Teleporter') == true:
				teleporter_tiles.append(tile_pos)

	if teleporter_tiles.size() > 0:
		# Pick a random teleporter tile
		var random_index: int = randi() % teleporter_tiles.size()
		var random_teleporter: Vector2i = teleporter_tiles[random_index]

		# Set the player's position to the teleporter tile
		global_position = tile_map.map_to_local(random_teleporter)

		# Update the current tile
		current_tile = random_teleporter

