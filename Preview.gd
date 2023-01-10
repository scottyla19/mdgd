extends HSplitContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("parse_md"):
		parse_markdown($EditorPane/TextEdit.text)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
		

func parse_markdown(text):
	var blocks = text.split("\n\n")
	var bbcode_str = ""
	var ol_regex = RegEx.new()
	ol_regex.compile("^[0-9]+\\. .*")
	
	for i in range(0,len(blocks)):
		var skip_line_parse = false
		var lines = blocks[i].split("\n")
		if (lines[0] == "```" &&  lines[len(lines)-1] == "```"):
			lines[0] = "[code][color=black]"
			lines[len(lines)-1] = "[/color][/code]"
			skip_line_parse = true
		elif lines[0].begins_with("- "):
			for l in range(0,len(lines)):
				lines[l] = "[indent]•%s[/indent]" % lines[l].right(1)
		elif lines[0].begins_with("> "):
			for l in range(0,len(lines)):
				lines[l] = "[indent][color=silver][i]%s[/i][/color][/indent]" % lines[l].right(2)
		elif ol_regex.search(lines[0]):
			for l in range(0,len(lines)):
				lines[l] = "[indent]%d %s[/indent]" % [l+1, lines[l].right(1)]
			
		if !skip_line_parse:
			for j in range(0,len(lines)):
				lines[j] = find_bolds(lines[j])
				lines[j] = find_italics(lines[j])
				lines[j] = find_inline_code(lines[j])
				lines[j] = find_image(lines[j])
				lines[j] = find_link(lines[j]) 
				lines[j] = find_strikethough(lines[j])
				lines[j] = find_headings(lines[j])

		blocks[i] = PoolStringArray(lines).join("\n")
		
	bbcode_str += PoolStringArray(blocks).join("\n\n")
	$PreviewPane/Preview.parse_bbcode(bbcode_str)

func find_bolds(line):
	var bolds_found = 0
	while "**" in line:
		var pattern = "\\*{2}"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			bolds_found += 1
			if bolds_found % 2 == 1:
				line = regex.sub(line, "[b]")
			elif bolds_found % 2 == 0:
				line = regex.sub(line, "[/b]")
	while "__" in line:
		var pattern = "\\_{2}"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			bolds_found += 1
			if bolds_found % 2 == 1:
				line = regex.sub(line, "[b]")
			elif bolds_found % 2 == 0:
				line = regex.sub(line, "[/b]")
	return line	

func find_italics(line):
	var bolds_found = 0
	while "*" in line:
		var pattern = "\\*"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			bolds_found += 1
			if bolds_found % 2 == 1:
				line = regex.sub(line, "[i]")
			elif bolds_found % 2 == 0:
				line = regex.sub(line, "[/i]")
	while "_" in line:
		var pattern = "\\_"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			bolds_found += 1
			if bolds_found % 2 == 1:
				line = regex.sub(line, "[i]")
			elif bolds_found % 2 == 0:
				line = regex.sub(line, "[/i]")
	return line	

func find_inline_code(line):
	var code_found = 0
	while "`" in line:
		var pattern = "`"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			code_found += 1
			if code_found % 2 == 1:
				line = regex.sub(line, "[code][color=black]")
			elif code_found % 2 == 0:
				line = regex.sub(line, "[/color][/code]")
	return line
	
func find_link(line):
	var pattern = ".*\\[(?<text>.+)\\]\\((?<url>.+)\\).*"
	var regex = RegEx.new()
	regex.compile(pattern)
	for result in regex.search_all(line):
		var sub_str = "[url=%s]%s[/url]" % [result.get_string("url"), result.get_string("text")]
		line = regex.sub(line, sub_str)
	return line

func find_image(line):
	var pattern = ".*!\\[(?<text>.*)\\]\\((?<url>.+)\\).*"
	var regex = RegEx.new()
	regex.compile(pattern)
	for result in regex.search_all(line):
		var sub_str = "[img]%s[/img]" % result.get_string("url")
		line = regex.sub(line, sub_str)
	return line

func find_strikethough(line):
	var strikes_found = 0
	while "~~" in line:
		var pattern = "~{2}"
		var regex = RegEx.new()
		regex.compile(pattern)
		for result in regex.search_all(line):
			strikes_found += 1
			if strikes_found % 2 == 1:
				line = regex.sub(line, "[s]")
			elif strikes_found % 2 == 0:
				line = regex.sub(line, "[/s]")
	return line	

func find_headings(line):
	if line.begins_with("### "):
		line = "[font=res://fonts/h3font.tres]%s[/font]\n" % line.right(4)
	elif line.begins_with("## "):
		line = "[font=res://fonts/h2font.tres]%s[/font]\n" % line.right(3)
	elif line.begins_with("# "):
		line = "[font=res://fonts/h1font.tres]%s[/font]\n" % line.right(2)
	return line
