extends Node

# should swith 'res' out for 'users'
const SAVE_PATH = "res://savegame.bin"

func SaveGame():
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		# Here is where you save the json data e.g. "Key": GameManager.Variable,
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)


func LoadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var currentLine = JSON.parse_string(file.get_line())
			if currentLine:
				# Here is where you would set your values you saved in SaveGame() e.g. GameManager.Variable = currentLine["Key"]
				pass
