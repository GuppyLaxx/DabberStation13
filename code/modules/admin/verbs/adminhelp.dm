/mob/verb/adminhelp(msg as text)
	set category = "Commands"
	set name = "adminhelp"


	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.muted)
		return

	for (var/mob/M in world)
		if (M.client && M.client.holder)
			M << sound('adminhelp.ogg') //hilarity %100
			M << "\blue <b><font color=red>HELP: </font>[key_name(src, M)](<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>X</A>):</b> [msg]"

	usr << "Your message has been broadcast to administrators (and the discord)."
	discord_relay("<@&464594497901166613> <@&480598635197759508> **ADMINHELP (from [key])** : [msg]",AdminhelpWebhook)
	log_admin("HELP: [key_name(src)]: [msg]")
