#region event scripts
function atestouch_init() {
	atestouch_elements = ds_list_create();
	atestouch_fingermap = ds_map_create();
	is_edit = false;
	is_selected = noone;
}

function atestouch_update() {
	for (var finger = 0; finger < 9; finger++) {
		var finger_x = device_mouse_x_to_gui(finger); // i made it like this so the rest is more readable
		var finger_y = device_mouse_y_to_gui(finger);
		var held = device_mouse_check_button(finger, mb_any);
		var tapped = device_mouse_check_button_pressed(finger, mb_any);
		var released = device_mouse_check_button_released(finger, mb_any);
		
		for (var element = 0; element < ds_list_size(atestouch_elements); element++) {
			var atestouch_element = atestouch_elements[| element]; //creates local vars beforehand so i dont have to check again and again
			var is_button = atestouch_element[| 0];
			var xx = atestouch_element[| 1];
			var yy = atestouch_element[| 2];
			var sprite = atestouch_element[| 3];
			var size = atestouch_element[| 4];
			var width = size * sprite_get_width(sprite);
			var height = size * sprite_get_height(sprite);
			var press = point_in_rectangle(finger_x, finger_y, xx, yy, xx + width, yy + width);
			if is_button {
				var key = atestouch_element[| 5];
				var special = atestouch_element[| 6];
			}
			else {
				var inner_sprite = atestouch_element[| 13];
				var inner_width = size * sprite_get_width(inner_sprite);
				var inner_height = size * sprite_get_height(inner_sprite);
				var center_x = inner_width / 2;
				var center_y = inner_height / 2;
			}
			
			if !is_edit {
				if is_button {
					if press && (tapped || held) {
						keyboard_key_press(key);
						atestouch_fingermap[? finger] = element;
					}
					
					if !press || released {
						var is_pressed = atestouch_fingermap[? finger];
						if is_pressed == element {
							keyboard_key_release(key);
							ds_map_delete(atestouch_fingermap, finger);
						}
					}
				}
				else {
					var joy_x = atestouch_element[| 9];
					var joy_y = atestouch_element[| 10];
					var up_key = atestouch_element[| 5];
					var down_key = atestouch_element[| 6];
					var left_key = atestouch_element[| 7];
					var right_key = atestouch_element[| 8];
					var range = atestouch_element[| 11];
					var deadzone = atestouch_element[| 12] / size;
					var dir = point_direction(xx, yy, finger_x - inner_width, finger_y - inner_height);
					var boundary_x = xx + lengthdir_x(125 * size, dir);
					var boundary_y = yy + lengthdir_y(125 * size, dir);
					var radius = range * size * 4;
					var cling = point_in_rectangle(finger_x, finger_y, xx - radius, yy - radius, xx + width + radius, yy + height + radius);
					var pull = point_in_circle(finger_x, finger_y, xx + width / 2, yy + height / 2, (width + height) / 4);
					
					
					if held && cling{
						var offset = 8 * size;
						atestouch_analog_action(joy_y < center_y - deadzone - offset, up_key);
						atestouch_analog_action(joy_y > center_y + deadzone + offset, down_key);
						atestouch_analog_action(joy_x > center_x + deadzone - offset, right_key);
						atestouch_analog_action(joy_x < center_x - deadzone + offset, left_key);
						atestouch_fingermap[? finger] = element;
						if !pull {
							joy_x = boundary_x + center_x;
							joy_y = boundary_y + center_y;
						}
						else {
							joy_x = finger_x - center_x;
							joy_y = finger_y - center_y;
						}
					}
					
					if released || !cling {
						var is_pressed = atestouch_fingermap[? finger];
						if is_pressed == element {
							joy_x = xx + center_x;
							joy_y = yy + center_y;
							ds_map_delete(atestouch_fingermap, finger);
						}
					}
					atestouch_element[| 9] = joy_x;
					atestouch_element[| 10] = joy_y;
				}
			}
			else {
				if press {
					if tapped {
						if special {
							atestouch_editmode_toggle();
						}
						else if is_selected != element {
							is_selected = element;
						}
					}
					
					if held && is_selected == element {
						xx = finger_x - width / 2;
						yy = finger_y - height / 2;
					}
				}
				atestouch_element[| 1] = xx;
				atestouch_element[| 2] = yy;
//				atestouch_element[| 4] = size; for future use..
				if !is_button {
					atestouch_element[| 9] = xx + center_x;
					atestouch_element[| 10] = yy + center_y;
				}
			}
		}
	}
}

function atestouch_draw() {
	for (var element = 0; element < ds_list_size(atestouch_elements); element++) {
		var atestouch_element = atestouch_elements[| element];
		var is_button = atestouch_element[| 0];
		var xx = atestouch_element[| 1];
		var yy = atestouch_element[| 2];
		var sprite = atestouch_element[| 3];
		var size = atestouch_element[| 4];
		if is_button {
			var key = atestouch_element[| 5];
			var special = atestouch_element[| 6];
			
			draw_sprite_ext(sprite, keyboard_check(key), xx, yy, size, size, 0, color, alpha + special);
		}
		else {
			var inner_sprite = atestouch_element[| 13];
			var joy_x = atestouch_element[| 9];
			var joy_y = atestouch_element[| 10];
			
			draw_sprite_ext(sprite, 0, xx, yy, size, size, 0, color, alpha);
			draw_sprite_ext(inner_sprite, 0, joy_x, joy_y, size, size, 0, color, alpha);
		}
	}
}
#endregion

#region atestouch functions
function atestouch_button_create(xx, yy, sprite, key, size = 0.7, special = false) {
	var atestouch_button = ds_list_create();
	
	ds_list_add(atestouch_button, true);
	ds_list_add(atestouch_button, xx);
	ds_list_add(atestouch_button, yy);
	ds_list_add(atestouch_button, sprite);
	ds_list_add(atestouch_button, size);
	ds_list_add(atestouch_button, key);
	ds_list_add(atestouch_button, special); //some keys that dont get affected by global modifiers (like esc key in ptp)

	ds_list_add(atestouch_elements, atestouch_button);
}

function atestouch_analog_create(xx, yy, inner_sprite, outer_sprite, size = 1, range = 25, deadzone = 25, up_key = vk_up, down_key = vk_down, left_key = vk_left, right_key = vk_right) {
	var atestouch_analog = ds_list_create();
	
	ds_list_add(atestouch_analog, false);
	ds_list_add(atestouch_analog, xx);
	ds_list_add(atestouch_analog, yy);
	ds_list_add(atestouch_analog, outer_sprite);
	ds_list_add(atestouch_analog, size);
	ds_list_add(atestouch_analog, up_key);
	ds_list_add(atestouch_analog, down_key);
	ds_list_add(atestouch_analog, left_key);
	ds_list_add(atestouch_analog, right_key);
	ds_list_add(atestouch_analog, xx + (size * sprite_get_width(inner_sprite)) / 2); //for the actual moving part of the joystick
	ds_list_add(atestouch_analog, yy + (size * sprite_get_height(inner_sprite)) / 2);
	ds_list_add(atestouch_analog, range);
	ds_list_add(atestouch_analog, deadzone);
	ds_list_add(atestouch_analog, inner_sprite);

	ds_list_add(atestouch_elements, atestouch_analog);
}

function atestouch_analog_action(condition, key) {
	if condition {
		keyboard_key_press(key);
	}
	else {
		keyboard_key_release(key);
	}
}

function atestouch_config_save() {
	ini_open("atestouch.ini");
	for (var element = 0; element < ds_list_size(atestouch_elements); element++) {
			ini_write_string("Elements", "Element " + string(element), ds_list_write(atestouch_elements[| element]));
	}
	ini_close();
}

function atestouch_config_load() {
	ini_open("atestouch.ini");
	for (var element = 0; element < ds_list_size(atestouch_elements); element++) {
		ds_list_read(atestouch_elements[| element], ini_read_string("Elements", "Element " + string(element), "Element " + string(element)));
	}
	ini_close();
}

function atestouch_editmode_toggle() {
	is_edit = !is_edit;
	atestouch_config_save();
}
#endregion