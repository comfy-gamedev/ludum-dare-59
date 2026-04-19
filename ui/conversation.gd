class_name Conversation
extends Resource

## Initial texture to show for the left side.
## Leave empty to have texture slide in the first time they talk. 
@export var left_texture: Texture2D

## Initial texture to show for the right side.
## Leave empty to have texture slide in the first time they talk.
@export var right_texture: Texture2D

@export var steps: Array[ConversationStep]
