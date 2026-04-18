extends Parallax2D
signal segment_reset

#@onready var middle_straight_scene = preload("res://objects/terrains/middle_straight/middle_straight.tscn")

@onready var terrain_segments = {
	"MiddleStraight": preload("res://objects/terrains/middle_straight/straightaway_middle_straight.tscn"),
	"MiddleToRightTurn1": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_4.tscn"),
	"MiddleToRightTurn2": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_5.tscn"),
	"MiddleToRightTurn3": preload("res://objects/terrains/middle_to_right_turn/middle_to_right_6.tscn"),
}

var prev_scroll_offset_y = 0
var current_scroll_offset_y = 0
var segment_transition_queue = []

func _ready():
	var middle_straight = terrain_segments["MiddleStraight"].instantiate() #middle_straight_scene.instantiate()
	self.add_child(middle_straight)
	#middle_to_right_segment()

func _process(_delta):
	prev_scroll_offset_y = current_scroll_offset_y
	current_scroll_offset_y = self.scroll_offset.y
	
	if current_scroll_offset_y < prev_scroll_offset_y:
		segment_reset.emit()

func middle_straight_segment():
	segment_transition_queue.append("MiddleStraight")
	
func middle_to_right_segment():
	segment_transition_queue.append_array(["MiddleToRightTurn1", "MiddleToRightTurn2", "MiddleToRightTurn3"])
	
func middle_right_segment():
	segment_transition_queue.append("RightStraight")

func _on_segment_reset():
	if self.get_children().size() > 0:
		if segment_transition_queue.size() > 0:
			free_current_segment()
			var new_terrain_segment = terrain_segments[segment_transition_queue[0]].instantiate() #middle_straight_scene.instantiate()
			self.add_child(new_terrain_segment)
			segment_transition_queue.pop_front()
		
		#print(self.get_child(0).name)
	#print("segment_reset")

func free_current_segment():
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
