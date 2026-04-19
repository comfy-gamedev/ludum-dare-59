extends Parallax2D
signal segment_reset
signal segment_transition_complete
signal segment_transition_initiated

@onready var terrain_segments = {
	"MiddleStraight": preload("res://objects/terrains/middle_straight/straightaway_middle_straight.tscn"),
	"MiddleToRightTurn1": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_4.tscn"),
	"MiddleToRightTurn2": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_5.tscn"),
	"MiddleToRightTurn3": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_6.tscn"),
	"RightStraight": preload("res://objects/terrains/right_straight/straightaway_right_straight.tscn"),
	"MiddleToLeftTurn1": preload("res://objects/terrains/middle_to_left/middle_to_left_1.tscn"),
	"MiddleToLeftTurn2": preload("res://objects/terrains/middle_to_left/middle_to_left_2.tscn"),
	"MiddleToLeftTurn3": preload("res://objects/terrains/middle_to_left/middle_to_left_3.tscn"),
	"LeftStraight": preload("res://objects/terrains/left_straight/straightaway_left_straight.tscn"),
	"LeftToMiddleTurn1": preload("res://objects/terrains/left_to_middle/left_to_middle_1.tscn"),
	"LeftToMiddleTurn2": preload("res://objects/terrains/left_to_middle/left_to_middle_2.tscn"),
	"LeftToMiddleTurn3": preload("res://objects/terrains/left_to_middle/left_to_middle_3.tscn"),
}

var prev_scroll_offset_y = 0
var current_scroll_offset_y = 0
var segment_transition_queue = []

var segment_transition_initialized = false
var segment_in_transition = false

func _ready():
	var middle_straight = terrain_segments["MiddleStraight"].instantiate() #middle_straight_scene.instantiate()
	self.add_child(middle_straight)

func _process(_delta):
	prev_scroll_offset_y = current_scroll_offset_y
	current_scroll_offset_y = self.scroll_offset.y
	
	if current_scroll_offset_y < prev_scroll_offset_y:
		segment_reset.emit()
	
	if not segment_transition_initialized and segment_in_transition:
		segment_transition_initiated.emit()
		segment_transition_initialized = true

func queue_middle_to_right_segment_transition():
	segment_transition_queue.append_array(["MiddleToRightTurn1", "MiddleToRightTurn2", "MiddleToRightTurn3", "RightStraight"])
	
func queue_middle_to_left_segment_transition():
	segment_transition_queue.append_array(["MiddleToLeftTurn1", "MiddleToLeftTurn2", "MiddleToLeftTurn3", "LeftStraight"])

func queue_left_to_middle_segment_transition():
	segment_transition_queue.append_array(["LeftToMiddleTurn1", "LeftToMiddleTurn2", "LeftToMiddleTurn3", "MiddleStraight"])
	
#func middle_straight_segment():
	#segment_transition_queue.append("MiddleStraight")
	
#func middle_right_segment():
	#segment_transition_queue.append("RightStraight")

func _on_segment_reset():
	if self.get_children().size() > 0:
		for n in self.get_children():
			if n.position.y < 0:
				# Reset position offset to normalize segment repeat behavior.
				n.position.y = 0
				free_other_segments(n)
		
		initiate_segment_transition()

func initiate_segment_transition():
	if segment_transition_queue.size() > 0:
		segment_in_transition = true
		var new_terrain_segment = terrain_segments[segment_transition_queue[0]].instantiate()
		# Set position offset to "queue" next segment above current segment.
		new_terrain_segment.position.y -= 480
		self.add_child(new_terrain_segment)
		segment_transition_queue.pop_front()
		
		if segment_transition_queue.size() == 0:
			segment_transition_initialized = false
			segment_in_transition = false
			segment_transition_complete.emit()

func free_other_segments(child_to_not_free):
	for child in self.get_children():
		if child_to_not_free != child:
			child.queue_free()


func _on_main_gameplay_initiate_middle_to_right_transition():
	queue_middle_to_right_segment_transition()


func _on_main_gameplay_initiate_middle_to_left_transition():
	queue_middle_to_left_segment_transition()

func _on_main_gameplay_initiate_left_to_middle_transition():
	queue_left_to_middle_segment_transition()
