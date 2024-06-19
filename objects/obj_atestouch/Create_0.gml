atestouch_init();

color = c_grey; //color of all the buttons (must use c_ prefix)
alpha = 0.6; // transparency of all the buttons (0 to 1);
z_button = atestouch_button_create(630, 390, spr_z_button, ord("Z"));
x_button = atestouch_button_create(730, 340, spr_x_button, ord("X"));
c_button = atestouch_button_create(830, 280, spr_c_button, ord("C"));
joystick = atestouch_analog_create(30, 260, spr_joystick, spr_joybase);
edit_button = atestouch_button_create(0, 0, spr_joystick, vk_f7, 0.5, true); //example edit button
//you'll end up using the names for certain functions.

atestouch_config_load();