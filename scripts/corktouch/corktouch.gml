function Button(_x, _y, _sprite, _key, _size = 1, _special = false) constructor
{
	// init variables
	active = true;
	special = _special;
	
	// functions
	onClick = undefined;
	onRelease = undefined;

    static runOnClick = function(button)
    {
		if button.active
			button.onClick();
    }
	
	static runOnRelease = function(button)
    {
		if button.active
			button.onRelease();
    }
} 