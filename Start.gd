extends Node

var http_request_node
var http_downloader_node
var scene_file

func _ready():
	# Maybe not have a static name here? Plus is this relative "path" okay?
	scene_file = 'nextgame.pck'
	
	http_request_node = HTTPRequest.new()
	http_request_node.connect("request_completed", self, "_http_request_next_completed")
	add_child(http_request_node)
	
	http_downloader_node = HTTPRequest.new()
	http_downloader_node.connect("request_completed", self, "_http_request_download_completed")
	add_child(http_downloader_node)

# Call this from wherever
func load_next():
	var error = http_request_node.request("http://localhost:8082/godot-delivery/next-game")
	if error != OK:
		push_error("An error occurred in the HTTP request to load the next level identifier.")

func _http_request_next_completed(result, response_code, headers, body):
	if response_code >= 400:
		push_error("Next level loader got BadRequest")
		return
	
	var download_url = body.get_string_from_utf8()
	
	http_downloader_node.download_file = scene_file
	http_downloader_node.request(download_url)

func _http_request_download_completed(result, response_code, headers, body):
	if response_code >= 400:
		push_error("Next level downloader got BadRequest")
		return
		
	var error = get_tree().change_scene(scene_file)
	if error != OK:
		push_error("Unable to change to new scene")
