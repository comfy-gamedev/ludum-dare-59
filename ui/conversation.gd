class_name Conversation
extends Resource

## Initial character to show for the left side.
## Leave empty to have character slide in the first time they talk. 
@export var left_character: Character

## Initial character to show for the right side.
## Leave empty to have character slide in the first time they talk.
@export var right_character: Character

@export var steps: Array[ConversationStep]
