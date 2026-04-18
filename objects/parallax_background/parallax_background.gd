extends Parallax2D
signal segment_reset
signal segment_transition_complete

@onready var terrain_segments = {
	"MiddleStraight": preload("res://objects/terrains/middle_straight/straightaway_middle_straight.tscn"),
	"MiddleToRightTurn1": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_4.tscn"),
	"MiddleToRightTurn2": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_5.tscn"),
	"MiddleToRightTurn3": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_6.tscn"),
	"RightStraight": preload("res://objects/terrains/right_straight/straightaway_right_straight.tscn"),
}

var prev_scroll_offset_y = 0
var current_scroll_offset_y = 0
var segment_transition_queue = []

func _ready():
	var middle_straight = terrain_segments["MiddleStraight"].instantiate() #middle_straight_scene.instantiate()
	self.add_child(middle_straight)

func _process(_delta):
	prev_scroll_offset_y = current_scroll_offset_y
	current_scroll_offset_y = self.scroll_offset.y
	
	if current_scroll_offset_y < prev_scroll_offset_y:
		segment_reset.emit()

func queue_middle_to_right_segment_transition():
	segment_transition_queue.append_array(["MiddleToRightTurn1", "MiddleToRightTurn2", "MiddleToRightTurn3", "RightStraight"])
	
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
		var new_terrain_segment = terrain_segments[segment_transition_queue[0]].instantiate()
		# Set position offset to "queue" next segment above current segment.
		new_terrain_segment.position.y -= 480
		self.add_child(new_terrain_segment)
		segment_transition_queue.pop_front()
		
		if segment_transition_queue.size() == 0:
			segment_transition_complete.emit()

func free_other_segments(child_to_not_free):
	for child in self.get_children():
		if child_to_not_free != child:
			child.queue_free()


func _on_main_gameplay_initiate_middle_to_right_transition():
	queue_middle_to_right_segment_transition()
