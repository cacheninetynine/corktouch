atestouch_init();

color = c_grey; //color of all the buttons (must use c_ prefix)
alpha = 0.6; // transparency of all the buttons (0 to 1);
atestouch_button_create(630, 390, spr_z_button, ord("Z"));
atestouch_button_create(730, 340, spr_x_button, ord("X"));
atestouch_button_create(830, 280, spr_c_button, ord("C"));
atestouch_analog_create(30, 260, spr_joystick, spr_joybase);
atestouch_button_create(0, 0, spr_joystick, vk_f7, 0.5, true); //example edit button

atestouch_config_load();