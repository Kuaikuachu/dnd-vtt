extends Option

func on_select():
	super()
	if base is Dice:
		base.roll.rpc()
