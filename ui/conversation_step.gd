class_name ConversationStep
extends Resource

@export var side: TextureSide

## Texture to show, leave empty to use previous
@export var texture: Texture2D

## BBCode
@export var message: String

## Time in seconds to auto advance to the next step.
## 0 seconds waits for user input.
@export var time: float

enum TextureSide { LEFT, RIGHT }
