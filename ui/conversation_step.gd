class_name ConversationStep
extends Resource

@export var side: TextureSide

## Character to show, leave empty to use previous
@export var character: Character

## BBCode
@export var message: String

## Time in seconds to auto advance to the next step.
## 0 seconds waits for user input.
@export var time: float

enum TextureSide { LEFT, RIGHT }
