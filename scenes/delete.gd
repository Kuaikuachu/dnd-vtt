extends Option

func on_select():
	super()
	base.self_destruct.rpc()
