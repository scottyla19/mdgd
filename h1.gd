tool
extends RichTextEffect
class_name RichTextGhost

# Syntax: [ghost freq=5.0 span=10.0][/ghost]

# Define the tag name.
var bbcode = "h1"

func _process_custom_fx(char_fx):
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://fonts/Roboto-Regular.ttf")
	dynamic_font.size = 40
	
	char_fx.set("font",dynamic_font)
#	char_fx.set()
#	$"Label".set("custom_fonts/font-h1", dynamic_font)
	return true
